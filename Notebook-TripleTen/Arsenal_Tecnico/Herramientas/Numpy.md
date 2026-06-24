---
tags: [herramienta, numpy, python, algebra, arrays, indice]
tipo: indice-herramienta
---

# 🔢 NumPy — Índice de Capacidades

Librería de computación numérica de Python. Es la base matemática sobre la que Pandas y Seaborn están construidos. En el bootcamp se usa principalmente de forma indirecta (a través de Pandas), pero tiene usos directos clave en cálculos matemáticos y manejo de nulos.

---

## 🗂️ Capacidades por Categoría

### 🔢 Operaciones Matemáticas
| Qué hace | Función clave | Nota |
|---|---|---|
| Raíz cuadrada | `np.sqrt(valor)` | [[Numpy#sqrt]] |
| Valor nulo numérico estándar | `np.nan` | [[Numpy#nan]] |

### 🔗 Integración con Pandas
| Qué hace | Cómo se usa | Nota |
|---|---|---|
| Convertir booleano a entero (0/1) | `.astype(int)` — usa tipos NumPy internamente | [[Numpy#astype]] |
| Reemplazar valores inválidos por nulo | `.replace(valor, np.nan)` | [[Numpy#nan]] |
| Tipos de dato subyacentes | `float64`, `int64` — base de todos los dtypes de Pandas | [[Numpy#dtypes]] |

---

## 📐 Referencia Completa de Funciones

### `np.sqrt()` {#sqrt}
**Cuándo:** Para calcular raíces cuadradas en fórmulas estadísticas. El uso más común en el bootcamp es el cálculo de la **V de Cramér** después de una prueba Chi-cuadrado.

```python
import numpy as np
from scipy.stats import chi2_contingency

tabla = pd.crosstab(df["variable_a"], df["variable_b"])
chi2_stat, p_value, dof, expected = chi2_contingency(tabla)

# V de Cramér: mide la magnitud del efecto
n = tabla.sum().sum()
v_cramer = np.sqrt(chi2_stat / (n * (min(tabla.shape) - 1)))

print(f"V de Cramér: {v_cramer:.4f}")
```

**Contexto real:** S8 NovaRetail — cálculo de V de Cramér ≈ 0.60 entre variables categóricas y segmentos de ingreso.

> [!NOTE] ¿Por qué `np.sqrt` y no `math.sqrt`?
> `np.sqrt` opera sobre arrays y Series de Pandas completos (vectorizado). `math.sqrt` solo funciona con un número a la vez. En análisis de datos siempre preferir `np.sqrt`.

---

### `np.nan` {#nan}
**Cuándo:** Para representar valores nulos numéricos de forma explícita y compatible con Pandas. Es el estándar para marcar "dato ausente" en columnas numéricas.

```python
import numpy as np

# Reemplazar un valor inválido con nulo real
df["columna"] = df["columna"].replace(-999, np.nan)

# Convertir errores de conversión a nulo
df['city_gdp_capita'] = df['city_gdp_capita'].apply(
    lambda x: float(x) if str(x).replace('.', '').isdigit() else np.nan
)
```

**Diferencia con `pd.NA` y `pd.NaT`:**

| Tipo de nulo | Cuándo usarlo |
|---|---|
| `np.nan` | Columnas numéricas (`float64`) |
| `pd.NA` | Columnas categóricas o de texto |
| `pd.NaT` | Columnas de fecha/tiempo (`datetime`) |

**Contexto real:** S5 LADB — registros económicos con valores corruptos reemplazados por `np.nan` antes de limpiar. S7 ConnectaTel — valores sentinel `-999` en `age` reemplazados por `np.nan` para imputar con mediana.

---

### `.astype(int)` — Conversión Booleana {#astype}
**Cuándo:** Para convertir una condición booleana (`True`/`False`) en una variable binaria numérica (`1`/`0`) que pueda sumarse, promediarse o usarse en modelos.

```python
# Crear flags binarios desde condiciones
usage["is_text"] = (usage["type"] == "text").astype(int)
usage["is_call"] = (usage["type"] == "call").astype(int)

# Verificar resultado
usage[["type", "is_text", "is_call"]].head()
```

**Por qué funciona:** `.astype(int)` usa los tipos enteros de NumPy (`int64`) bajo el capó para transformar el array booleano de Pandas.

**Contexto real:** S7 ConnectaTel — columna `type` con valores `call/text/data` convertida en flags para poder sumar interacciones por usuario con `.groupby().sum()`.

---

### Tipos de Dato NumPy en Pandas {#dtypes}
**Cuándo:** Para entender qué está pasando cuando `.info()` muestra tipos de dato inesperados o cuando necesitas forzar un tipo específico.

```python
# Los dtypes de Pandas son tipos NumPy
df["columna"].dtype        # → dtype('float64') o dtype('int64')

# Conversión explícita de tipos
df["precio"] = df["precio"].astype(float)   # → float64 de NumPy
df["cantidad"] = df["cantidad"].astype(int)  # → int64 de NumPy

# Ver el tipo de cada columna
df.dtypes
```

**Mapa de tipos comunes:**

| Pandas muestra | NumPy subyacente | Qué significa |
|---|---|---|
| `float64` | `np.float64` | Número decimal (acepta NaN) |
| `int64` | `np.int64` | Número entero (no acepta NaN) |
| `object` | — | Texto o tipo mixto |
| `bool` | `np.bool_` | Booleano True/False |
| `datetime64[ns]` | `np.datetime64` | Fecha y hora |

> [!IMPORTANT] `int64` no acepta NaN
> Si intentas meter `np.nan` en una columna `int64`, Pandas la convierte automáticamente a `float64`. Para columnas enteras con nulos usar `pd.Int64Dtype()` (con mayúscula).

---

## 📌 Sprints donde se usó NumPy

| Sprint | Proyecto | Uso específico |
|---|---|---|
| S5 | LADB — Movilidad urbana | `np.nan` para valores corruptos en dataset económico |
| S7 | ConnectaTel — Segmentación | `.astype(int)` para flags binarios de tipo de uso |
| S8 | NovaRetail+ — Comportamiento | `np.sqrt()` en cálculo de V de Cramér |
| S9 | Landing Page — A/B Testing | Tipos NumPy en conversiones de proporciones |

---

## 🔗 Conexiones Estratégicas

- **Índice Maestro:** [[Indice_Maestro]]
- **Nota de operación:** [[Transformacion_y_Feature_Engineering]] | [[Analisis_Estadistico]]
- **Herramienta relacionada:** [[Pandas]] | [[Matplotlib_Seaborn]]
