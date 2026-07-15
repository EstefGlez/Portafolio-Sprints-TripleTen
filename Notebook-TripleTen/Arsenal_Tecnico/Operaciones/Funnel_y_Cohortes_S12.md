---
tags: [operacion, sql, funnel, cohortes, retencion, lag, case-when, sprint-12]
tipo: nota-operacion
herramientas: [sql, python]
---

# 🌊 Funnel de Conversión y Cohortes de Retención — SQL + Python

Operaciones para analizar el comportamiento de usuarios en un funnel de compra y medir la retención por cohortes, combinando SQL para la extracción y Python para la visualización. Patrón del S12 con `pd.read_sql`.

---

## 📋 Índice de Operaciones

| Operación | Ir a |
|---|---|
| Funnel: conteo de usuarios por etapa | [[#funnel-conteo]] |
| Funnel: tasa de conversión con LAG() | [[#funnel-conversion]] |
| Cohortes: retención semanal con LEFT JOIN + CASE WHEN | [[#cohortes-sql]] |
| Cohortes: transformación y heatmap en Python | [[#cohortes-python]] |

---

## 📊 Funnel — Conteo de Usuarios por Etapa {#funnel-conteo}

**Cuándo:** Para saber cuántos usuarios únicos llegan a cada paso del proceso de compra (visita → carrito → pago → compra).

```python
query_funnel = '''
SELECT 
    nombre_evento,
    COUNT(DISTINCT id_usuario) AS total_usuarios
FROM events
WHERE nombre_evento IN (
    'first_visit', 'select_item', 'add_to_cart',
    'begin_checkout', 'add_payment_info', 'purchase'
)
GROUP BY nombre_evento
ORDER BY 
    CASE nombre_evento
        WHEN 'first_visit'       THEN 1
        WHEN 'select_item'       THEN 2
        WHEN 'add_to_cart'       THEN 3
        WHEN 'begin_checkout'    THEN 4
        WHEN 'add_payment_info'  THEN 5
        WHEN 'purchase'          THEN 6
    END;
'''

funnel_data = pd.read_sql(query_funnel, con=engine)
funnel_data
```

**Puntos clave:**
- `COUNT(DISTINCT id_usuario)` — cuenta usuarios únicos, no eventos. Un usuario puede visitar 3 veces pero cuenta como 1
- `WHERE nombre_evento IN (...)` — filtra solo las etapas del funnel, elimina eventos de ruido
- `CASE` en el `ORDER BY` — ordena el funnel en secuencia lógica, no alfabéticamente

> [!IMPORTANT] Sin el filtro WHERE el funnel no tiene sentido
> Si no filtras los eventos relevantes, aparecen etapas con más usuarios que la etapa anterior (tasas > 100%), lo que rompe la lógica del funnel.

**Contexto real:** S12 — Funnel de 6 etapas para el análisis de conversión de RappiPlus/MercadoLibre.

---

## 📉 Funnel — Tasa de Conversión con LAG() {#funnel-conversion}

**Cuándo:** Para calcular qué porcentaje de usuarios pasa de una etapa a la siguiente, e identificar el "cuello de botella" donde se pierde más gente.

```python
query_conversion = '''
WITH funnel_counts AS (
    SELECT 
        nombre_evento,
        COUNT(DISTINCT id_usuario) AS total_usuarios
    FROM events
    WHERE nombre_evento IN (
        'first_visit', 'select_item', 'add_to_cart',
        'begin_checkout', 'add_payment_info', 'purchase'
    )
    GROUP BY nombre_evento
),
ordered_funnel AS (
    SELECT 
        nombre_evento,
        total_usuarios,
        LAG(total_usuarios) OVER (
            ORDER BY 
                CASE nombre_evento
                    WHEN 'first_visit'       THEN 1
                    WHEN 'select_item'       THEN 2
                    WHEN 'add_to_cart'       THEN 3
                    WHEN 'begin_checkout'    THEN 4
                    WHEN 'add_payment_info'  THEN 5
                    WHEN 'purchase'          THEN 6
                END
        ) AS usuarios_paso_anterior
    FROM funnel_counts
)
SELECT 
    nombre_evento,
    total_usuarios,
    ROUND(
        total_usuarios::numeric / NULLIF(usuarios_paso_anterior, 0), 4
    ) AS conversion_rate
FROM ordered_funnel
ORDER BY 
    CASE nombre_evento
        WHEN 'first_visit'       THEN 1
        WHEN 'select_item'       THEN 2
        WHEN 'add_to_cart'       THEN 3
        WHEN 'begin_checkout'    THEN 4
        WHEN 'add_payment_info'  THEN 5
        WHEN 'purchase'          THEN 6
    END;
'''

conversion = pd.read_sql(query_conversion, con=engine)
conversion
```

**Anatomía del patrón:**

| Función | Qué hace |
|---|---|
| `LAG(total_usuarios) OVER (ORDER BY CASE...)` | Trae el valor de la fila anterior según el orden del funnel |
| `::numeric` | Convierte entero a decimal para evitar división entera |
| `NULLIF(..., 0)` | Evita error de división por cero si una etapa tiene 0 usuarios |
| `ROUND(..., 4)` | 4 decimales para ver el porcentaje con precisión |

> [!NOTE] LAG() es el equivalente SQL de .shift(1) en Pandas
> `LAG(col)` trae el valor de la fila anterior en la ventana ordenada. Es la herramienta estándar para calcular variaciones entre filas consecutivas.

**Contexto real:** S12 — Tasa de conversión del funnel de MercadoLibre. Se detectó que algunos pasos tenían tasas > 100% porque los usuarios entran al carrito desde múltiples puntos de entrada (no solo desde `select_item`).

---

## 🔁 Cohortes — Retención Semanal con SQL {#cohortes-sql}

**Cuándo:** Para medir qué porcentaje de usuarios registrados en un mes sigue activo en las semanas siguientes. Estructura diferente al S4 (que usaba CTEs de cohortes mensuales puras).

```python
query_cohort = '''
SELECT 
    DATE_TRUNC('month', CAST(u.fecha_registro AS DATE)) AS cohort_month,
    COUNT(DISTINCT u.id_usuario)                         AS total_usuarios,
    
    -- Retención semanal: activo = 1 dentro del rango de días
    COUNT(DISTINCT CASE 
        WHEN a.dias_despues_registro BETWEEN 7  AND 13 AND a.activo = 1 
        THEN u.id_usuario END) AS retenido_w1,
    
    COUNT(DISTINCT CASE 
        WHEN a.dias_despues_registro BETWEEN 14 AND 20 AND a.activo = 1 
        THEN u.id_usuario END) AS retenido_w2,
    
    COUNT(DISTINCT CASE 
        WHEN a.dias_despues_registro BETWEEN 21 AND 27 AND a.activo = 1 
        THEN u.id_usuario END) AS retenido_w3

FROM users u
LEFT JOIN user_activity a ON u.id_usuario = a.id_usuario
GROUP BY 1
ORDER BY 1;
'''

cohorte_data = pd.read_sql(query_cohort, con=engine)
```

**Por qué este patrón es diferente al S4:**

| S4 (MercadoLibre) | S12 (RappiPlus) |
|---|---|
| CTE + JOIN de retención D7/D14/D28 | CASE WHEN directo con rangos de días |
| Columna `day_after_signup` calculada | Columna `dias_despues_registro` ya existe |
| Conteo de usuarios activos por período | Mismo resultado, sintaxis más directa |
| `COUNT(DISTINCT CASE WHEN day >= N AND active = 1)` | `COUNT(DISTINCT CASE WHEN dias BETWEEN X AND Y AND activo = 1)` |

> [!IMPORTANT] LEFT JOIN es obligatorio aquí
> Con `INNER JOIN`, los usuarios que se registraron pero nunca tuvieron actividad desaparecen del resultado. El `total_usuarios` quedaría inflado (solo contaría activos), haciendo que las tasas de retención superen el 100%. El `LEFT JOIN` conserva a TODOS los registrados, incluso sin actividad.

> [!WARNING] El filtro `activo = 1` va DENTRO del CASE WHEN
> Si pones `WHERE activo = 1` en el filtro principal, eliminas a los inactivos antes de contar, arruinando el denominador. El filtro debe ir dentro de cada `CASE WHEN` para que solo afecte al numerador.

**Contexto real:** S12 — La tabla `user_activity` ya tenía `dias_despues_registro` y `activo`, lo que permitió simplificar la query vs. el patrón del S4.

---

## 🐍 Cohortes — Transformación y Heatmap en Python {#cohortes-python}

**Cuándo:** Una vez que `pd.read_sql` devuelve la tabla de cohortes (en formato "ancho"), calcular los porcentajes y visualizar como mapa de calor.

```python
# 1. Convertir la columna de fecha a datetime
cohorte_data['cohort_month'] = pd.to_datetime(cohorte_data['cohort_month'])

# 2. Usar cohort_month como índice
cohorte_data.set_index('cohort_month', inplace=True)

# 3. Formatear índice a 'YYYY-MM' para que sea legible en el eje Y
cohorte_data.index = cohorte_data.index.strftime('%Y-%m')

# 4. Calcular porcentajes de retención (dividir retenidos / total)
retention_df = cohorte_data.copy()
retention_df['w1'] = retention_df['retenido_w1'] / retention_df['total_usuarios']
retention_df['w2'] = retention_df['retenido_w2'] / retention_df['total_usuarios']
retention_df['w3'] = retention_df['retenido_w3'] / retention_df['total_usuarios']

# 5. Seleccionar solo las columnas de porcentaje
heatmap_data = retention_df[['w1', 'w2', 'w3']]

# 6. Visualizar
import seaborn as sns
import matplotlib.pyplot as plt

plt.figure(figsize=(10, 6))
sns.heatmap(heatmap_data, annot=True, fmt='.1%', cmap='YlGnBu')
plt.title('Retención de usuarios por cohorte mensual (semanas 1-3)')
plt.ylabel('Mes de registro')
plt.show()
```

**¿Por qué este flujo es más simple que el S4?**
- La SQL ya entrega el resultado en formato "ancho" (`retenido_w1`, `retenido_w2`, `retenido_w3`)
- No necesitas `pivot_table` — la tabla ya está pivotada desde SQL
- Solo calculas porcentajes dividiendo columnas y graficar

> [!WARNING] Error 1970-01 en el índice
> Si el índice del heatmap muestra `1970-01`, significa que Pandas está interpretando la fecha como milisegundos (timestamp Unix). Solución: `pd.to_datetime(cohorte_data['cohort_month'])` antes de `set_index`.

**Contexto real:** S12 — Heatmap de retención de usuarios de RappiPlus con cohortes mensuales y retención semanal W1/W2/W3.

---

## 🔗 Conexiones Estratégicas

- **Índice Maestro:** [[Indice_Maestro]]
- **Herramientas:** [[SQL]] | [[Python_SQL]] | [[Pandas]]
- **Operación relacionada S4:** [[SQL_Financiero_y_Metricas#embudo-ctes]] | [[SQL_Financiero_y_Metricas#cohortes]]
- **Visualización:** [[Visualizacion#heatmap]]
- **Sprint de referencia:** S12 — Proyecto Final RappiPlus

---

## 🔁 Cohortes Acumuladas — Patrón con >= N días {#cohortes-acumuladas}

**Cuándo:** Alternativa al patrón `BETWEEN` cuando las instrucciones piden retención acumulada (usuarios activos **desde** el día N en adelante, no solo en esa ventana).

```python
query_cohortes_acumuladas = '''
SELECT
    DATE_TRUNC('month', CAST(u.fecha_registro AS DATE)) AS cohort_month,
    COUNT(DISTINCT u.id_usuario) AS total_usuarios,

    -- Retención acumulada: activo EN O DESPUÉS del día N
    COUNT(DISTINCT CASE 
        WHEN a.dias_despues_registro >= 7  AND a.activo = 1 
        THEN u.id_usuario END) AS retenido_d7,

    COUNT(DISTINCT CASE 
        WHEN a.dias_despues_registro >= 14 AND a.activo = 1 
        THEN u.id_usuario END) AS retenido_d14,

    COUNT(DISTINCT CASE 
        WHEN a.dias_despues_registro >= 21 AND a.activo = 1 
        THEN u.id_usuario END) AS retenido_d21

FROM users u
LEFT JOIN user_activity a ON u.id_usuario = a.id_usuario
GROUP BY 1
ORDER BY 1;
'''

cohorte_acum = pd.read_sql(query_cohortes_acumuladas, con=engine)
```

**Diferencia clave entre los dos patrones:**

| Patrón | Sintaxis SQL | Qué mide |
|---|---|---|
| Ventana semanal | `BETWEEN 7 AND 13` | Usuarios activos **solo** en esa semana |
| Acumulado | `>= 7` | Usuarios activos **desde** ese día en adelante |

> [!NOTE] ¿Cuál usar?
> - `BETWEEN` → retención por período (¿volvieron esa semana específica?)
> - `>= N` → retención acumulada (¿siguen activos después de N días?) — más común en análisis de producto

**Contexto real:** S12 — Patrón visto en el contexto del S4 (MercadoLibre D7/D14/D21/D28) y aplicado también en RappiPlus.

---

## 🔀 Funnel con INTERSECT — Patrón Alternativo {#funnel-intersect}

**Cuándo:** Para construir un funnel estricto donde cada etapa solo cuenta usuarios que **también** pasaron por todas las etapas anteriores. Diferente al patrón de `LEFT JOIN` que cuenta usuarios únicos por etapa independientemente.

```python
query_funnel_intersect = '''
-- Usuarios que llegaron a cada etapa (y también pasaron por las anteriores)
SELECT 'first_visit'      AS etapa, COUNT(DISTINCT id_usuario) AS usuarios, 1 AS orden
FROM events WHERE nombre_evento = 'first_visit'

UNION ALL

SELECT 'select_item', COUNT(DISTINCT id_usuario), 2
FROM events WHERE nombre_evento = 'select_item'
AND id_usuario IN (SELECT DISTINCT id_usuario FROM events WHERE nombre_evento = 'first_visit')

UNION ALL

SELECT 'add_to_cart', COUNT(DISTINCT id_usuario), 3
FROM events WHERE nombre_evento = 'add_to_cart'
AND id_usuario IN (SELECT DISTINCT id_usuario FROM events WHERE nombre_evento = 'select_item')

UNION ALL

SELECT 'purchase', COUNT(DISTINCT id_usuario), 4
FROM events WHERE nombre_evento = 'purchase'
AND id_usuario IN (SELECT DISTINCT id_usuario FROM events WHERE nombre_evento = 'add_to_cart')

ORDER BY orden;
'''

funnel_estricto = pd.read_sql(query_funnel_intersect, con=engine)
```

**Diferencia entre los dos patrones de funnel:**

| Patrón | Cómo cuenta | Cuándo usarlo |
|---|---|---|
| `COUNT(DISTINCT) + WHERE IN (...)` | Solo usuarios que pasaron por etapas previas | Funnel estricto y secuencial |
| `COUNT(DISTINCT) + GROUP BY evento` | Todos los usuarios únicos por etapa, independientemente | Funnel de alcance (más común) |

> [!NOTE] Los resultados pueden diferir significativamente
> El patrón con `IN` siempre da números menores o iguales al patrón de `GROUP BY`, porque filtra usuarios que saltaron etapas. Elige según lo que quiera medir el negocio.

**Contexto real:** S12 — Patrón alternativo para análisis de funnel estricto donde cada etapa es prerequisito de la siguiente.
