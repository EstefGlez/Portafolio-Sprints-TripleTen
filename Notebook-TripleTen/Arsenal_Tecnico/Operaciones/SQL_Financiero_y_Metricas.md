---
tags: [operacion, sql, financiero, roi, margen, kpis, cohortes, retencion]
tipo: nota-operacion
herramientas: [sql]
---

# 💰 SQL — Métricas Financieras, Embudos y Retención

Operaciones SQL para calcular rentabilidad, analizar embudos de conversión y medir retención por cohortes. Sprints 3 y 4.

---

## 📋 Índice de Operaciones

| Operación | Sprint | Ir a |
|---|---|---|
| Calcular ingresos y costos por transacción | S3 | [[#ingreso-costo]] |
| Agregar por geografía con SUM + GROUP BY | S3 | [[#agrupacion-geo]] |
| Calcular Margen % y ROI % | S3 | [[#margen-roi]] |
| NULLIF para evitar división por cero | S3/S4 | [[#nullif]] |
| Embudo de conversión con CTEs | S4 | [[#embudo-ctes]] |
| Retención acumulada D7-D28 | S4 | [[#retencion-dx]] |
| Cohortes mensuales de retención | S4 | [[#cohortes]] |

---

## 💵 Calcular Ingresos y Costos por Transacción {#ingreso-costo}

**Cuándo:** Para derivar métricas financieras a nivel de línea de pedido combinando precio, costo y cantidad. Es el primer paso del análisis de rentabilidad.

```sql
SELECT
    v.numero_pedido,
    p.nombre_producto,
    COALESCE(p.precio_producto, 0) * COALESCE(v.cantidad_pedido, 0) AS ingreso_total,
    COALESCE(p.costo_producto, 0)  * COALESCE(v.cantidad_pedido, 0) AS costo_total
FROM ventas_2017 AS v
JOIN productos AS p
    ON v.clave_producto = p.clave_producto;
```

**Contexto real:** S3 SQL Financiero — base de todas las métricas posteriores. Se guardan en una vista o CTE llamada `ventas_clean`.

---

## 🌍 Agregar por Geografía {#agrupacion-geo}

**Cuándo:** Para resumir ingresos y costos por país o territorio, preparando la base para calcular rentabilidad geográfica.

```sql
SELECT
    pais,
    clave_territorio,
    SUM(ingreso_total)::INT AS total_ingresos,
    SUM(costo_total)::INT   AS total_costos
FROM ventas_clean
GROUP BY pais, clave_territorio
ORDER BY total_ingresos DESC;
```

**Contexto real:** S3 — agregación geográfica como paso intermedio antes de incorporar costos de campaña de marketing.

---

## 📈 Calcular Margen % y ROI % {#margen-roi}

**Cuándo:** Para evaluar la rentabilidad real de cada territorio, incorporando tanto el costo de producto como la inversión en marketing.

```sql
SELECT
    pais,
    SUM(ingresos)::INTEGER                                                      AS ingresos,
    SUM(costos)::INTEGER                                                        AS costos,
    COALESCE(SUM(costo_campana::INTEGER), 0)                                    AS costo_campana,
    (SUM(ingresos) - SUM(costos))::INT                                          AS beneficio_bruto,

    -- Margen %: qué porcentaje de los ingresos es ganancia
    ((SUM(ingresos) - SUM(costos)) * 100.0 / NULLIF(SUM(ingresos), 0))         AS margen_pct,

    -- ROI %: retorno sobre la inversión en marketing
    ((SUM(ingresos) - SUM(costos)) * 100.0 / NULLIF(SUM(costo_campana), 0))    AS roi_pct

FROM pais_ingreso_costo AS p
LEFT JOIN pais_campanas AS c ON p.clave_territorio = c.clave_territorio
GROUP BY pais, clave_territorio
ORDER BY ingresos DESC;
```

**Fórmulas:**

$$\text{Margen \%} = \frac{\text{Ingresos} - \text{Costos}}{\text{Ingresos}} \times 100$$

$$\text{ROI \%} = \frac{\text{Ingresos} - \text{Costos}}{\text{Inversión en Marketing}} \times 100$$

**Contexto real:** S3 — métrica final para identificar territorios con mayor eficiencia de retorno sobre inversión publicitaria.

---

## ⚠️ NULLIF para Evitar División por Cero {#nullif}

**Cuándo:** Siempre que calcules un porcentaje o tasa en SQL. Si el denominador es 0, la query fallará con un error de división por cero.

```sql
-- Sin NULLIF: falla si usuarios_first_visit = 0
usuarios_purchase / usuarios_first_visit

-- Con NULLIF: devuelve NULL en lugar de error
usuarios_purchase * 100.0 / NULLIF(usuarios_first_visit, 0)

-- Con ROUND para limpiar decimales
ROUND(usuarios_purchase * 100.0 / NULLIF(usuarios_first_visit, 0), 2) AS conv_pct
```

**Contexto real:** S3 — `NULLIF(SUM(ingresos), 0)` en el cálculo de margen. S4 — `NULLIF(COUNT(DISTINCT user_id), 0)` en todas las tasas de retención.

---

## 🌊 Embudo de Conversión con CTEs {#embudo-ctes}

**Cuándo:** Para calcular en cuántos usuarios únicos completan cada etapa de un proceso (visita → carrito → compra) y las tasas de caída entre etapas.

```sql
WITH first_visit AS (
    SELECT DISTINCT user_id
    FROM mercadolibre_funnel
    WHERE event_name = 'first_visit'
      AND event_date BETWEEN '2025-01-01' AND '2025-08-31'
),
add_to_cart AS (
    SELECT DISTINCT user_id
    FROM mercadolibre_funnel
    WHERE event_name = 'add_to_cart'
      AND event_date BETWEEN '2025-01-01' AND '2025-08-31'
),
purchase AS (
    SELECT DISTINCT user_id
    FROM mercadolibre_funnel
    WHERE event_name = 'purchase'
      AND event_date BETWEEN '2025-01-01' AND '2025-08-31'
)
SELECT
    COUNT(fv.user_id)  AS usuarios_first_visit,
    COUNT(a.user_id)   AS usuarios_add_to_cart,
    COUNT(p.user_id)   AS usuarios_purchase,
    ROUND(COUNT(a.user_id) * 100.0 / NULLIF(COUNT(fv.user_id), 0), 2) AS conv_carrito_pct,
    ROUND(COUNT(p.user_id) * 100.0 / NULLIF(COUNT(fv.user_id), 0), 2) AS conv_compra_pct
FROM first_visit AS fv
LEFT JOIN add_to_cart AS a ON fv.user_id = a.user_id
LEFT JOIN purchase AS p    ON fv.user_id = p.user_id;
```

**Contexto real:** S4 — embudo de 7 etapas para MercadoLibre (2025 Jan-Aug), segmentado también por país.

---

## 📅 Retención Acumulada D7-D28 {#retencion-dx}

**Cuándo:** Para medir qué porcentaje de usuarios que se registraron sigue activo después de 7, 14, 21 y 28 días. Métrica clave de salud del producto.

```sql
SELECT
    country,
    ROUND(
        COUNT(DISTINCT CASE WHEN day_after_signup >= 7  AND active = 1 THEN user_id END)
        * 100.0 / NULLIF(COUNT(DISTINCT user_id), 0), 1
    ) AS retention_d7_pct,
    ROUND(
        COUNT(DISTINCT CASE WHEN day_after_signup >= 14 AND active = 1 THEN user_id END)
        * 100.0 / NULLIF(COUNT(DISTINCT user_id), 0), 1
    ) AS retention_d14_pct,
    ROUND(
        COUNT(DISTINCT CASE WHEN day_after_signup >= 28 AND active = 1 THEN user_id END)
        * 100.0 / NULLIF(COUNT(DISTINCT user_id), 0), 1
    ) AS retention_d28_pct
FROM mercadolibre_retention
WHERE activity_date BETWEEN '2025-01-01' AND '2025-08-31'
GROUP BY country
ORDER BY country;
```

**Lógica del patrón `COUNT(DISTINCT CASE WHEN ... THEN user_id END)`:**
- El `CASE WHEN` actúa como filtro condicional
- Solo cuenta el `user_id` si cumple **ambas** condiciones: antigüedad suficiente Y activo = 1
- `DISTINCT` evita contar el mismo usuario múltiples veces si tiene varias filas de actividad

**Contexto real:** S4 — retención D7/D14/D21/D28 segmentada por país para MercadoLibre.

---

## 🗓️ Cohortes Mensuales de Retención {#cohortes}

**Cuándo:** Para agrupar usuarios por el mes en que se registraron y ver cómo evoluciona su retención a lo largo del tiempo. Permite comparar si las cohortes nuevas retienen mejor que las antiguas.

```sql
WITH cohort AS (
    SELECT
        user_id,
        TO_CHAR(DATE_TRUNC('month', MIN(signup_date)), 'YYYY-MM') AS cohort
    FROM mercadolibre_retention
    GROUP BY user_id
),
activity AS (
    SELECT
        a.user_id,
        c.cohort,
        a.day_after_signup,
        a.active
    FROM mercadolibre_retention AS a
    LEFT JOIN cohort AS c ON a.user_id = c.user_id
    WHERE activity_date BETWEEN '2025-01-01' AND '2025-08-31'
)
SELECT
    cohort,
    ROUND(100.0 * COUNT(DISTINCT CASE WHEN day_after_signup >= 7  AND active = 1 THEN user_id END)
          / NULLIF(COUNT(DISTINCT user_id), 0), 1) AS retention_d7_pct,
    ROUND(100.0 * COUNT(DISTINCT CASE WHEN day_after_signup >= 28 AND active = 1 THEN user_id END)
          / NULLIF(COUNT(DISTINCT user_id), 0), 1) AS retention_d28_pct
FROM activity
GROUP BY cohort
ORDER BY cohort;
```

**Funciones clave:**
- `DATE_TRUNC('month', fecha)` — trunca la fecha al primer día de su mes
- `TO_CHAR(..., 'YYYY-MM')` — formatea la fecha como `"2025-01"` para legibilidad
- `MIN(signup_date)` — la primera fecha de registro define la cohorte del usuario

**Contexto real:** S4 — cohortes mensuales de retención para evaluar si MercadoLibre mejoraba la retención de cohortes nuevas vs antiguas.

---

## 🔗 Conexiones Estratégicas

- **Herramienta:** [[SQL]]
- **Operación previa:** [[Joins_y_Combinacion]]
- **Sprint de referencia:** S3 SQL Financiero | S4 Embudo y Cohortes
