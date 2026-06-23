---
tags: [herramienta, sql, postgresql, indice]
tipo: indice-herramienta
---

# 🗄️ SQL (PostgreSQL) — Índice de Capacidades

Referencia rápida de todo lo que puedes hacer con SQL en el contexto del bootcamp. Cada entrada enlaza a la nota de operación donde está el código completo.

---

## 🗂️ Capacidades por Categoría

### 📦 Exploración Inicial
| Qué hace | Sintaxis clave | Nota |
|---|---|---|
| Ver primeras filas de una tabla | `SELECT * FROM tabla LIMIT 10` | [[Carga_y_Exploracion#exploracion-sql]] |
| Detectar nulos en columnas clave | `SUM(CASE WHEN col IS NULL THEN 1 ELSE 0 END)` | [[Carga_y_Exploracion#exploracion-sql]] |
| Detectar anomalías numéricas | `COUNT(*) WHERE cantidad <= 0` | [[Carga_y_Exploracion#exploracion-sql]] |

### ⚙️ Transformación y Calidad
| Qué hace | Sintaxis clave | Nota |
|---|---|---|
| Reemplazar NULL con valor por defecto | `COALESCE(columna, 0)` | [[Transformacion_y_Feature_Engineering#coalesce-sql]] |
| Convertir tipo de dato | `valor::INT` `valor::INTEGER` | [[Transformacion_y_Feature_Engineering#casting-sql]] |
| División decimal (evitar división entera) | `valor * 100.0 / otro_valor` | [[Transformacion_y_Feature_Engineering#casting-sql]] |
| Evitar división por cero | `NULLIF(denominador, 0)` | [[SQL_Financiero_y_Metricas#nullif]] |
| Redondear decimales | `ROUND(valor, 2)` | [[SQL_Financiero_y_Metricas#nullif]] |

### 🔗 Joins y Combinación
| Qué hace | Sintaxis clave | Nota |
|---|---|---|
| LEFT JOIN multi-tabla (hechos + catálogos) | `FROM tabla AS t LEFT JOIN otro AS o ON ...` | [[Joins_y_Combinacion#left-join-sql]] |
| Embudo de conversión con CTEs | `WITH etapa AS (SELECT DISTINCT user_id ...)` | [[Joins_y_Combinacion#join-ctes]] |
| JOIN con múltiples llaves | `ON t.ciudad = o.ciudad AND t.año = o.año` | [[Joins_y_Combinacion#left-join-sql]] |

### 📈 Agregación y Métricas Financieras
| Qué hace | Sintaxis clave | Nota |
|---|---|---|
| Calcular ingresos y costos por transacción | `precio * cantidad AS ingreso_total` | [[SQL_Financiero_y_Metricas#ingreso-costo]] |
| Agregar por geografía | `SUM(...) GROUP BY pais ORDER BY total DESC` | [[SQL_Financiero_y_Metricas#agrupacion-geo]] |
| Calcular Margen % | `(ingresos - costos) * 100.0 / NULLIF(ingresos, 0)` | [[SQL_Financiero_y_Metricas#margen-roi]] |
| Calcular ROI % | `(ingresos - costos) * 100.0 / NULLIF(costo_campana, 0)` | [[SQL_Financiero_y_Metricas#margen-roi]] |

### 🌊 Embudos de Conversión
| Qué hace | Sintaxis clave | Nota |
|---|---|---|
| Aislar usuarios únicos por etapa | `SELECT DISTINCT user_id WHERE event_name = 'etapa'` | [[SQL_Financiero_y_Metricas#embudo-ctes]] |
| Calcular tasa de conversión por etapa | `COUNT(etapa) * 100.0 / NULLIF(COUNT(base), 0)` | [[SQL_Financiero_y_Metricas#embudo-ctes]] |
| Segmentar embudo por país | `GROUP BY country` + JOIN por país | [[SQL_Financiero_y_Metricas#embudo-ctes]] |

### 📅 Retención y Cohortes
| Qué hace | Sintaxis clave | Nota |
|---|---|---|
| Retención acumulada D7/D14/D21/D28 | `COUNT(DISTINCT CASE WHEN day >= N AND active = 1 THEN user_id END)` | [[SQL_Financiero_y_Metricas#retencion-dx]] |
| Definir cohorte mensual de un usuario | `DATE_TRUNC('month', MIN(signup_date))` | [[SQL_Financiero_y_Metricas#cohortes]] |
| Formatear cohorte como texto legible | `TO_CHAR(fecha, 'YYYY-MM')` | [[SQL_Financiero_y_Metricas#cohortes]] |
| Análisis de cohortes completo | CTE `cohort` + CTE `activity` + `GROUP BY cohort` | [[SQL_Financiero_y_Metricas#cohortes]] |

---

## ⚠️ Reglas Críticas (No olvidar)

| Regla | Por qué importa |
|---|---|
| Siempre `DISTINCT` en CTEs de embudo | Sin DISTINCT, un usuario con 3 visitas cuenta 3 veces |
| Siempre `NULLIF(denominador, 0)` en divisiones | Sin esto, la query falla con error si el denominador es 0 |
| Siempre `COALESCE(col, 0)` antes de multiplicar | `NULL × cualquier_número = NULL`, destruye el cálculo |
| Usar `100.0` (no `100`) en porcentajes | `100` fuerza división entera y trunca decimales |

---

## 📌 Sprints donde se usó SQL

| Sprint | Proyecto | Operaciones destacadas |
|---|---|---|
| S3 | SQL Financiero — ROI & Márgenes | LEFT JOIN × 3 tablas, COALESCE, Margen%, ROI% |
| S4 | Embudo y Cohortes — MercadoLibre | CTEs, DISTINCT, retención D7-D28, cohortes mensuales por TO_CHAR |

---

## 🔗 Conexiones Estratégicas

- **Índice Maestro:** [[Indice_Maestro]]
- **Herramienta relacionada:** [[Pandas]] | [[Google_Sheets]]
