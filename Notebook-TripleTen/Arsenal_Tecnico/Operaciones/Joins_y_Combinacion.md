---
tags: [operacion, joins, merge, combinacion, pandas, sql]
tipo: nota-operacion
herramientas: [pandas, sql]
---

# 🔗 Joins y Combinación de Datasets

Operaciones para cruzar dos o más fuentes de datos usando una llave común. Es el paso clave cuando el análisis requiere información que está repartida en varias tablas.

---

## 📋 Índice de Operaciones

| Operación | Herramienta | Ir a |
|---|---|---|
| Merge (Inner Join) | Pandas | [[#merge-inner]] |
| Merge (Left Join) | Pandas | [[#merge-left]] |
| Seleccionar columnas antes del merge | Pandas | [[#preselect]] |
| LEFT JOIN multi-tabla | SQL | [[#left-join-sql]] |
| JOIN en embudo de conversión (CTEs) | SQL | [[#join-ctes]] |

---

## 🔀 Merge — Inner Join {#merge-inner}

**Herramienta:** Pandas
**Cuándo:** Cuando solo quieres filas que existen en **ambas** tablas. Ideal cuando tienes certeza de que las llaves coinciden en los dos datasets.

```python
# Inner join: solo filas que tienen match en ambas tablas
merged = pd.merge(df_left, df_right, on=["city", "year"])

# Con llaves de diferente nombre en cada tabla
merged = pd.merge(
    df_left,
    df_right,
    left_on="ciudad",
    right_on="city"
)
```

**Contexto real:** S5 LADB — cruce de `traffic_2024_small` + `eco_2024_small` usando `["city", "year"]` como llaves compuestas. Solo las ciudades con datos en ambas fuentes quedaron en el análisis.

---

## ⬅️ Merge — Left Join {#merge-left}

**Herramienta:** Pandas
**Cuándo:** Cuando quieres **conservar todas las filas de la tabla izquierda**, aunque no tengan match en la derecha. Los campos sin match quedan como `NaN`.

```python
# Left join: todas las filas de df_usuarios, con datos de df_uso si existen
user_profile = users.merge(usage_agg, on="user_id", how="left")
```

**Contexto real:** S7 ConnectaTel — `users.merge(usage_agg, on="user_id", how="left")` para construir el perfil maestro. Algunos usuarios podrían no tener registros de uso aún.

---

## 🎯 Seleccionar Columnas Antes del Merge {#preselect}

**Herramienta:** Pandas
**Cuándo:** Cuando las tablas tienen muchas columnas y solo necesitas algunas. Hacer la selección **antes** del merge reduce el tamaño en memoria y evita columnas `_x`/`_y` duplicadas.

```python
# Definir explícitamente qué columnas llevar de cada tabla
left_cols  = ["city", "country", "year", "jams_delay", "traffic_index_live"]
right_cols = ["city", "year", "city_gdp_capita", "unemployment_pct", "population"]

# Filtrar antes de mergear
df_left_small  = df_traffic[left_cols].copy()
df_right_small = df_eco[right_cols].copy()

# Merge limpio
merged = pd.merge(df_left_small, df_right_small, on=["city", "year"])
```

**Contexto real:** S5 LADB — patrón aplicado antes del merge de tráfico y economía para evitar arrastrar 15+ columnas innecesarias.

> [!TIP] Siempre usar `.copy()`
> Al hacer `.copy()` en el subset evitas el `SettingWithCopyWarning` de Pandas si después modificas el DataFrame resultante.

---

## 🗄️ LEFT JOIN Multi-tabla en SQL {#left-join-sql}

**Herramienta:** SQL (PostgreSQL)
**Cuándo:** Para enriquecer una tabla de hechos con atributos de múltiples catálogos (productos, territorios, categorías). El LEFT JOIN preserva todos los registros de ventas aunque algún catálogo no tenga match.

```sql
SELECT
    v.numero_pedido,
    v.clave_producto,
    p.nombre_producto,
    pc.clave_categoria,
    t.pais,
    t.continente,
    COALESCE(p.precio_producto, 0) AS precio_unitario,
    COALESCE(v.cantidad_pedido, 0) AS cantidad,
    COALESCE(p.costo_producto, 0)  AS costo_unitario
FROM ventas_2017 AS v
LEFT JOIN productos AS p
    ON v.clave_producto = p.clave_producto
LEFT JOIN productos_categorias AS pc
    ON p.clave_subcategoria = pc.clave_subcategoria
LEFT JOIN territorios AS t
    ON v.clave_territorio = t.clave_territorio;
```

**Contexto real:** S3 SQL Financiero — `ventas_2017` como tabla de hechos central, enriquecida con 3 catálogos mediante LEFT JOINs encadenados.

---

## 🏗️ JOIN en Embudo de Conversión con CTEs {#join-ctes}

**Herramienta:** SQL (PostgreSQL)
**Cuándo:** Para construir un embudo de conversión donde cada etapa es un conjunto de usuarios únicos, y necesitas cruzarlas contra la etapa inicial para calcular tasas de conversión.

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

**Anatomía del patrón:**
- Cada CTE aísla los usuarios únicos que completaron **una** etapa del embudo
- El JOIN final cruza todas las etapas contra `first_visit` (la base 100%)
- `NULLIF(..., 0)` evita división por cero si una etapa tiene 0 usuarios

**Contexto real:** S4 SQL Embudo — MercadoLibre, 7 etapas desde `first_visit` hasta `purchase`, segmentado también por país.

> [!IMPORTANT] DISTINCT en cada CTE del embudo
> Sin `DISTINCT`, un usuario que visitó 3 veces cuenta 3 veces. El embudo mide usuarios únicos por etapa, no eventos totales.

---

## 🔗 Conexiones Estratégicas

- **Herramientas:** [[Pandas]] | [[SQL]]
- **Operación previa:** [[Transformacion_y_Feature_Engineering]]
- **Siguiente operación:** [[Agregacion_y_Reportes]]
