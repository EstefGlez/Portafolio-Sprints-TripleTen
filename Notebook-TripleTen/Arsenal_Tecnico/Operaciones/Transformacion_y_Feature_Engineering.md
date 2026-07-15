---
tags: [operacion, transformacion, feature-engineering, pandas, sql]
tipo: nota-operacion
herramientas: [pandas, sql]
---

# ⚙️ Transformación y Feature Engineering

Operaciones para limpiar tipos de datos incorrectos, crear nuevas variables derivadas, estandarizar columnas y preparar el dataset para análisis o modelado. Va después de la exploración y antes del análisis.

---

## 📋 Índice de Operaciones

| Operación | Herramienta | Ir a |
|---|---|---|
| Estandarizar nombres de columnas (snake_case) | Pandas | [[#snake-case]] |
| Convertir texto a fecha (datetime) | Pandas | [[#to-datetime]] |
| Limpiar strings con caracteres especiales | Pandas | [[#limpiar-strings]] |
| Imputar nulos (mediana, reemplazo) | Pandas | [[#imputar-pandas]] |
| Tratar fechas futuras / anomalías cronológicas | Pandas | [[#fechas-anomalas]] |
| Crear variables indicadoras (flags) | Pandas | [[#flags]] |
| Segmentar numérico en categorías (pd.cut) | Pandas | [[#pd-cut]] |
| Conversión de unidades | Pandas | [[#conversion-unidades]] |
| Renombrar columnas con caracteres especiales | Pandas | [[#rename-sql]] |
| COALESCE para nulos en SQL | SQL | [[#coalesce-sql]] |
| Casting de tipos en SQL | SQL | [[#casting-sql]] |

---

## 🐍 Estandarizar Nombres de Columnas (snake_case) {#snake-case}

**Herramienta:** Pandas
**Cuándo:** Cuando los nombres de columnas vienen en CamelCase, con espacios, o con caracteres especiales. snake_case es el estándar en Python.

```python
import re

# Función para convertir CamelCase → snake_case
def to_snake(name):
    s1 = re.sub("(.)([A-Z][a-z]+)", r"\1_\2", name)
    return re.sub("([a-z0-9])([A-Z])", r"\1_\2", s1).lower()

# Aplicar a todas las columnas del DataFrame
df.columns = [to_snake(col) for col in df.columns]

# Alternativa simple para columnas con espacios (sin CamelCase)
df.columns = [col.lower().replace(" ", "_") for col in df.columns]
```

**Contexto real:** S5 LADB — `traffic` tenía columnas como `UpdateTimeUTC` → se convirtió a `update_time_utc`. `eco` tenía columnas como `City GDP/capita` → renombrado a `city_gdp_capita`.

---

## 📅 Convertir Texto a Fecha (datetime) {#to-datetime}

**Herramienta:** Pandas
**Cuándo:** Cuando `.info()` muestra fechas con `dtype: object`. Sin esta conversión no puedes agrupar por mes, trimestre, extraer año, etc.

```python
# Conversión estándar
df['fecha'] = pd.to_datetime(df['fecha'])

# Con manejo de errores (convierte valores inválidos a NaT en lugar de romper)
df['fecha'] = pd.to_datetime(df['fecha'], errors='coerce')

# Extraer componentes temporales
df['year']  = df['fecha'].dt.year
df['month'] = df['fecha'].dt.month
df['day']   = df['fecha'].dt.day
```

**Contexto real:** S5 — `traffic["update_time_utc"] = pd.to_datetime(traffic["update_time_utc"], errors="coerce")`. S7 — `users['reg_date'] = pd.to_datetime(users["reg_date"])`.

---

## 🧹 Limpiar Strings con Caracteres Especiales {#limpiar-strings}

**Herramienta:** Pandas
**Cuándo:** Cuando columnas numéricas tienen `dtype: object` porque contienen `%`, `,`, `.` como separadores de miles, o símbolos de moneda.

```python
# Limpiar y convertir columna con formato europeo (coma decimal, punto miles)
df['city_gdp_capita'] = (
    df['city_gdp_capita']
    .astype(str)
    .str.replace(".", "", regex=False)   # eliminar separador de miles
    .str.replace(",", ".", regex=False)  # convertir coma decimal a punto
    .astype(float)
)

# Limpiar columna de porcentajes
df['unemployment_pct'] = (
    df['unemployment_pct']
    .astype(str)
    .str.replace("%", "", regex=False)
    .str.replace(",", ".", regex=False)
    .astype(float)
)
```

**Contexto real:** S5 LADB — dataset económico `eco` tenía `City GDP/capita` en formato europeo con puntos como miles y comas como decimales.

---

## 🩹 Imputar Nulos en Pandas {#imputar-pandas}

**Herramienta:** Pandas
**Cuándo:** Para reemplazar valores faltantes o valores sentinel (-999, ?) con un valor estadístico o lógico.

```python
# Imputar con la mediana de los valores válidos (excluyendo el sentinel)
mediana = df.loc[df["age"] != -999, "age"].median()
df["age"] = df["age"].replace(-999, mediana)

# Reemplazar marcadores de desconocido con NaN reconocido por Pandas
df["city"] = df["city"].replace("?", pd.NA)

# Imputar nulos con la media
df["columna"].fillna(df["columna"].mean(), inplace=True)
```

**Contexto real:** S7 ConnectaTel — `age` tenía 1.3% de registros con valor sentinel `-999`. Se imputaron con la mediana de la población válida. `city` tenía `"?"` como marcador de desconocido → reemplazado por `pd.NA`.

> [!IMPORTANT] Mediana vs. Media para imputar
> Usar la **mediana** cuando la distribución tiene outliers o está sesgada. La **media** distorsiona la distribución si hay valores extremos.

---

## 📆 Tratar Fechas Futuras / Anomalías Cronológicas {#fechas-anomalas}

**Herramienta:** Pandas
**Cuándo:** Cuando el dataset tiene fechas que son lógicamente imposibles (registros del futuro, fechas de 1900, etc.).

```python
# Definir la fecha límite lógica
max_fecha = pd.Timestamp("2024-12-31")

# Reemplazar fechas futuras con NaT (Not a Time)
df.loc[df["reg_date"] > max_fecha, "reg_date"] = pd.NaT
```

**Contexto real:** S7 — se detectaron 40 registros con `reg_date` en el año 2026, inconsistente con el límite operativo de 2024. Se trataron como errores de captura.

---

## 🚩 Crear Variables Indicadoras (Flags) {#flags}

**Herramienta:** Pandas
**Cuándo:** Para convertir variables categóricas binarias en enteros (0/1) que permiten conteos y sumas eficientes.

```python
# Crear flag binario desde condición booleana
df["is_text"] = (df["type"] == "text").astype(int)
df["is_call"] = (df["type"] == "call").astype(int)

# Rellenar NaN en la variable derivada (cuando el tipo no aplica)
df["call_minutes"] = (df["duration"] / 60).fillna(0)
```

**Contexto real:** S7 ConnectaTel — columna `type` con valores `call`/`text`/`data` se convirtió en flags para poder sumar conteos por usuario con `.groupby().sum()`.

---

## ✂️ Segmentar Numérico en Categorías (pd.cut) {#pd-cut}

**Herramienta:** Pandas
**Cuándo:** Para discretizar una variable continua (como satisfacción 0-10) en rangos etiquetados que permiten análisis por grupo.

```python
bins   = [0, 2, 4, 6, 8, 10]
labels = ["Muy_insatisfecho", "Insatisfecho", "Neutral", "Satisfecho", "Muy_satisfecho"]

df["satisfaccion_cat"] = pd.cut(
    df["satisfaccion"],
    bins=bins,
    labels=labels,
    include_lowest=True   # incluye el valor mínimo del primer bin
)

# Ver la distribución resultante
df["satisfaccion_cat"].value_counts().sort_index()
```

**Parámetros clave:**
- `bins` — límites de los intervalos
- `labels` — nombre para cada intervalo
- `include_lowest=True` — asegura que el valor mínimo quede incluido en el primer bin

**Contexto real:** S8 NovaRetail — `satisfaccion` (escala 0-10) segmentada en 5 niveles categóricos para análisis de distribución.

---

## 🔢 Conversión de Unidades {#conversion-unidades}

**Herramienta:** Pandas
**Cuándo:** Cuando el dataset almacena métricas en una unidad y el análisis requiere otra (segundos→minutos, millones→unidades, etc.).

```python
# Convertir segundos a minutos
df["call_minutes"] = df["duration"] / 60

# Convertir millones a unidades absolutas
eco["population"] = eco["population_m"] * 1_000_000
```

**Contexto real:** S5 LADB — `population_m` (en millones) convertida a `population` (en unidades) para poder usarse como tamaño de burbuja en scatterplot. S7 — `duration` en segundos convertida a minutos.

---

## 🗄️ COALESCE para Nulos en SQL {#coalesce-sql}

**Herramienta:** SQL (PostgreSQL)
**Cuándo:** Para reemplazar NULLs con un valor por defecto (generalmente 0 en campos numéricos) antes de hacer cálculos. Evita que un NULL contamine toda una multiplicación.

```sql
COALESCE(precio_producto, 0)  AS precio_unitario,
COALESCE(cantidad_pedido, 0)  AS cantidad,
COALESCE(costo_producto, 0)   AS costo_unitario
```

**Contexto real:** S3 SQL Financiero — todos los campos monetarios en el JOIN de `ventas_2017` + `productos` fueron envueltos en `COALESCE(..., 0)` antes de calcular `ingreso_total` y `costo_total`.

> [!IMPORTANT] Por qué COALESCE antes de multiplicar
> `NULL * cualquier_número = NULL`. Si un producto no tiene precio en el catálogo y no usas COALESCE, la fila completa devuelve NULL en lugar de 0.

---

## 🏷️ Casting de Tipos en SQL {#casting-sql}

**Herramienta:** SQL (PostgreSQL)
**Cuándo:** Para convertir el tipo de dato de una columna directamente en la query, sin modificar la tabla fuente.

```sql
-- Casting con ::
SUM(ingreso_total)::INT         AS total_ingresos
SUM(costo_total)::INTEGER       AS total_costos

-- Necesario para evitar división entera en porcentajes
ROUND(usuarios_purchase * 100.0 / NULLIF(usuarios_first_visit, 0), 2) AS conversion_pct
-- El 100.0 (float) fuerza que la división sea decimal, no entera
```

**Contexto real:** S3 — `::INT` para redondear totales financieros. S4 — `100.0` (en lugar de `100`) para obtener decimales en tasas de conversión.

---

## 🔗 Conexiones Estratégicas

- **Índice Maestro:** [[Indice_Maestro]]

- **Herramientas:** [[Pandas]] | [[SQL]]
- **Operación previa:** [[Carga_y_Exploracion]]
- **Siguiente operación:** [[Agregacion_y_Reportes]]

---

## 🔁 Estandarización de Pipeline Completo en Función {#pipeline-funcion}

**Herramienta:** Pandas
**Cuándo:** Cuando tienes múltiples DataFrames que necesitan exactamente la misma limpieza (snake_case + normalize + fillna). Encapsular el pipeline en una función evita repetir el mismo bloque 3 veces.

```python
def limpiar_dataframe(df, cols_fecha=None, cols_categoricas=None, cols_fillna=None):
    """
    Pipeline estándar de limpieza para DataFrames del proyecto.
    
    Parámetros:
        df              : DataFrame a limpiar
        cols_fecha      : lista de columnas a convertir a datetime
        cols_categoricas: lista de columnas a normalizar (lower + strip)
        cols_fillna     : dict {columna: valor_fill} para imputar nulos
    
    Retorna:
        DataFrame limpio (in-place no; devuelve copia)
    """
    df = df.copy()
    
    # Snake_case en nombres de columnas
    df.columns = [col.lower().replace(' ', '_') for col in df.columns]
    
    # Convertir fechas
    if cols_fecha:
        for col in cols_fecha:
            df[col] = pd.to_datetime(df[col], errors='coerce')
    
    # Normalizar texto
    if cols_categoricas:
        for col in cols_categoricas:
            df[col] = df[col].str.lower().str.strip()
    
    # Imputar nulos categóricos
    if cols_fillna:
        for col, valor in cols_fillna.items():
            df[col] = df[col].fillna(valor)
    
    return df

# Uso en S12
orders = limpiar_dataframe(
    orders,
    cols_fecha       = ['fecha_hora_pedido'],
    cols_categoricas = ['nombre_producto', 'categoria_producto', 'pais'],
    cols_fillna      = {'dispositivo': 'desconocido', 'fuente_referencia': 'desconocido'}
)
```

> [!TIP] Esta función es candidata a la carpeta Funciones/
> Con parámetros opcionales (`None` por defecto), es adaptable a cualquier proyecto sin modificar su código interno.

**Contexto real:** S12 — Pipeline de limpieza aplicado a `orders`, `catalog` y `marketing` con diferentes configuraciones por DataFrame.

---

## 🔍 Verificación Post-Limpieza Estandarizada {#verificacion-post}

**Herramienta:** Pandas
**Cuándo:** Después de cada fase de limpieza, para confirmar que el resultado es el esperado antes de continuar. Bloque reutilizable que imprime el estado del DataFrame.

```python
def verificar_df(df, nombre):
    """Imprime un resumen de estado del DataFrame para QA."""
    print(f"\n{'='*40}")
    print(f"  QA: {nombre}")
    print(f"{'='*40}")
    print(f"  Dimensiones: {df.shape}")
    print(f"  Nulos totales: {df.isna().sum().sum()}")
    nulos = df.isna().sum()
    nulos_cols = nulos[nulos > 0]
    if len(nulos_cols) > 0:
        print(f"  Columnas con nulos:")
        for col, n in nulos_cols.items():
            print(f"    - {col}: {n}")
    else:
        print("  ✅ Sin nulos")
    print(f"  Duplicados: {df.duplicated().sum()}")

# Uso
verificar_df(orders,    "orders_clean")
verificar_df(catalog,   "catalog_clean")
verificar_df(marketing, "marketing_clean")
```

> [!TIP] También candidata a Funciones/
> Reemplaza el bloque `print(orders.isna().sum())` que se repite en todos los proyectos. Un solo `verificar_df(df, nombre)` da más información en menos líneas.

**Contexto real:** S12 — QA post-limpieza de los tres DataFrames antes de exportar a CSV.
