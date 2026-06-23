---
tags: [operacion, carga, exploracion, pandas, sql, google-sheets]
tipo: nota-operacion
herramientas: [pandas, sql, google-sheets]
---

# 📦 Carga y Exploración de Datos

Primera operación de todo pipeline. El objetivo es entender la estructura del dataset antes de tocarlo: dimensiones, tipos de datos, valores nulos y duplicados.

---

## 📋 Índice de Operaciones

| Operación | Herramienta | Ir a |
|---|---|---|
| Cargar CSV | Pandas | [[#cargar-csv]] |
| Cargar múltiples fuentes | Pandas | [[#cargar-multiples]] |
| Vista preliminar | Pandas | [[#vista-previa]] |
| Auditoría de dimensiones y tipos | Pandas | [[#auditoria-basica]] |
| Auditoría de nulos | Pandas | [[#auditoria-nulos]] |
| Auditoría de duplicados | Pandas | [[#duplicados]] |
| Exploración inicial SQL | SQL | [[#exploracion-sql]] |

---

## 📥 Cargar CSV {#cargar-csv}

**Herramienta:** Pandas
**Cuándo:** Siempre que el dataset fuente sea un archivo `.csv` local o de un entorno como Jupyter/Colab.

```python
import pandas as pd

df = pd.read_csv("ruta/del/archivo.csv")
```

**Contexto real:** S8 NovaRetail — `pd.read_csv("/datasets/novaretail_behavior.csv")`

---

## 📥 Cargar Múltiples Fuentes {#cargar-multiples}

**Herramienta:** Pandas
**Cuándo:** Cuando el análisis requiere cruzar datos de más de una tabla (tráfico + economía, usuarios + uso, etc.).

```python
# Cargar todas las fuentes al inicio, cada una en su propio DataFrame
df_planes  = pd.read_csv('/datasets/plans.csv')
df_usuarios = pd.read_csv('/datasets/users_latam.csv')
df_uso     = pd.read_csv('/datasets/usage.csv')
```

**Contexto real:** S7 ConnectaTel — 3 fuentes independientes cargadas al inicio. S5 LADB — `traffic` + `eco`.

> [!NOTE] Convención de nombres
> Nombrar cada DataFrame con un prefijo descriptivo (`df_`, `traffic_`, `eco_`) evita confusión cuando conviven múltiples tablas en el mismo notebook.

---

## 👁️ Vista Preliminar {#vista-previa}

**Herramienta:** Pandas
**Cuándo:** Inmediatamente después de cargar, para verificar que los datos se leyeron correctamente y ver la estructura real de columnas y valores.

```python
# Ver primeras 5 filas (renderizado nativo en Jupyter)
df.head()

# Ver últimas 5 filas (útil para detectar filas de totales al final)
df.tail()

# Ver una muestra aleatoria
df.sample(5)
```

**Contexto real:** S5, S7, S8 — `.head(5)` como primer paso después de cada `pd.read_csv()`.

---

## 🔬 Auditoría de Dimensiones y Tipos {#auditoria-basica}

**Herramienta:** Pandas
**Cuándo:** Antes de cualquier transformación. Confirma cuántas filas y columnas tienes, y si los tipos de datos son los correctos (ej. fechas cargadas como `object` en lugar de `datetime`).

```python
# Dimensiones del dataset (filas, columnas)
print(f"Dimensiones: {df.shape}")

# Tipos de datos + conteo de no-nulos por columna
df.info()
```

**Parámetros de `.info()`:**
- `Dtype` — tipo de dato asignado por Pandas al cargar
- `Non-Null Count` — valores no vacíos por columna (detecta nulos indirectamente)

**Contexto real:** S8 — `print(f"Dimensiones del dataset NovaRetail+: {df_retail.shape}")` + `df_retail.info()`

> [!WARNING] Señales de alerta en `.info()`
> - Columnas de fecha con `dtype: object` → necesitan `pd.to_datetime()`
> - Columnas numéricas con `dtype: object` → contienen caracteres especiales (`%`, `,`, `$`) que bloquean cálculos

---

## 🔍 Auditoría de Nulos {#auditoria-nulos}

**Herramienta:** Pandas
**Cuándo:** Después de `.info()`, para cuantificar exactamente cuántos valores faltan por columna, tanto en número absoluto como en proporción.

```python
# Conteo absoluto de nulos por columna
print("Nulos absolutos:\n", df.isna().sum())

# Proporción relativa de nulos (0.0 a 1.0)
print("\nProporción de nulos:\n", df.isna().mean())

# Combinado en un solo DataFrame para comparar fácilmente
pd.DataFrame({
    'nulos': df.isna().sum(),
    'porcentaje': (df.isna().mean() * 100).round(2)
}).query('nulos > 0')
```

**Contexto real:** S7 — `users` tenía 11% de nulos en `city` y 88% en `churn_date` (lógico: son clientes activos). S8 — integridad del 100%, 0 nulos en 15,000 registros.

> [!IMPORTANT] Interpretar el % de nulos
> Un 88% de nulos no siempre es un problema. En `churn_date`, significa que el 88% de clientes sigue activo — es información valiosa, no un error.

---

## 🔁 Auditoría de Duplicados {#duplicados}

**Herramienta:** Pandas
**Cuándo:** Para verificar que cada fila representa una observación única. Duplicados en IDs de transacción o usuarios inflan métricas.

```python
# Conteo global de filas duplicadas
print(f"Duplicados: {df.duplicated().sum()}")

# Duplicados por columna específica (ID único)
print(f"IDs duplicados: {df['id_orden'].duplicated().sum()}")

# Ver las filas duplicadas
df[df.duplicated(keep=False)]
```

**Contexto real:** S7 — `usage['user_id'].duplicated()` devolvió muchos duplicados, pero era correcto: un usuario puede tener muchas transacciones de uso. S8 — 0 duplicados en dataset de 15,000 filas.

> [!NOTE] Duplicados esperados vs. inesperados
> En tablas transaccionales (usage, ventas), un mismo `user_id` aparece muchas veces — eso es normal. El duplicado problemático es cuando el `id_transaccion` se repite.

---

## 🗄️ Exploración Inicial SQL {#exploracion-sql}

**Herramienta:** SQL (PostgreSQL)
**Cuándo:** Para inspeccionar tablas en una base de datos relacional antes de escribir queries de análisis. Equivale al `.head()` de Pandas.

```sql
-- Vista de las primeras 10 filas de cada tabla
SELECT * FROM ventas_2017 LIMIT 10;
SELECT * FROM productos LIMIT 10;
SELECT * FROM territorios LIMIT 10;

-- QA: detectar nulos en columnas clave
SELECT
    SUM(CASE WHEN numero_pedido IS NULL THEN 1 ELSE 0 END)    AS nulos_pedido,
    SUM(CASE WHEN clave_producto IS NULL THEN 1 ELSE 0 END)   AS nulos_producto,
    SUM(CASE WHEN clave_territorio IS NULL THEN 1 ELSE 0 END) AS nulos_territorio
FROM ventas_2017;

-- QA: detectar anomalías numéricas
SELECT COUNT(*) AS filas_invalidas
FROM ventas_2017
WHERE cantidad_pedido <= 0;
```

**Contexto real:** S3 SQL Financiero — auditoría de integridad referencial sobre `ventas_2017` antes de calcular márgenes y ROI.

---

## 🔗 Conexiones Estratégicas

- **Herramientas:** [[Pandas]] | [[SQL]] | [[Google_Sheets]]
- **Siguiente operación:** [[Limpieza_y_Normalizacion]]
