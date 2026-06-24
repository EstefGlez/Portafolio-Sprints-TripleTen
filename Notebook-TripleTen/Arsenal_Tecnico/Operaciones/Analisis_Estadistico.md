---
tags: [operacion, estadistica, hipotesis, chi2, correlacion, pandas, scipy, statsmodels]
tipo: nota-operacion
herramientas: [pandas, scipy, statsmodels]
---

# 🧪 Análisis Estadístico y Pruebas de Hipótesis

Operaciones para cuantificar relaciones entre variables y determinar si las diferencias observadas son estadísticamente significativas o producto del azar.

---

## 📋 Índice de Operaciones

| Operación | Herramienta | Ir a |
|---|---|---|
| Matriz de correlación (Pearson) | Pandas | [[#correlacion-pearson]] |
| Correlación de Spearman | SciPy | [[#spearman]] |
| Correlación de Punto Biserial | SciPy | [[#punto-biserial]] |
| Heatmap de correlación | Seaborn | [[#heatmap]] |
| Tabla de contingencia (crosstab) | Pandas | [[#crosstab]] |
| Prueba Chi-cuadrado de independencia | SciPy | [[#chi2]] |
| V de Cramér (magnitud del efecto) | SciPy + cálculo manual | [[#cramer]] |
| Prueba Exacta de Fisher | SciPy | [[#fisher]] |
| Prueba T de Student (2 muestras independientes) | SciPy | [[#ttest]] |
| Prueba de Levene (homogeneidad de varianzas) | SciPy | [[#levene]] |
| Prueba Z de Proporciones (A/B Testing) | statsmodels | [[#ztest]] |
| Prueba de Shapiro-Wilk (normalidad) | SciPy | [[#shapiro]] |
| Interpretar p-value | — | [[#interpretar-pvalue]] |
| Árbol de decisión: ¿qué prueba usar? | — | [[#arbol-decision]] |

---

## 🗺️ Árbol de Decisión: ¿Qué Prueba Usar? {#arbol-decision}

```
¿Qué tipo de métrica estás comparando?
│
├── NUMÉRICA (dinero, tiempo, edad, minutos)
│     ├── ¿Cuántos grupos?
│     │     ├── 2 grupos independientes → T-test (ttest_ind)
│     │     └── Mismo grupo en 2 momentos → T-test pareado (ttest_rel)
│     └── Antes del T-test: verificar varianzas → Levene
│
└── CATEGÓRICA (clics, conversiones, cancelaciones, proporciones)
      ├── ¿Tabla 2×2 con muestras pequeñas (esperados < 5)? → Fisher Exact
      ├── ¿Dos grupos, comparar proporciones? → Z-test de proporciones
      └── ¿Dos variables categóricas (cualquier tamaño)? → Chi-cuadrado
            └── + medir magnitud del efecto → V de Cramér
```

> [!TIP] Regla de oro para entrevistas técnicas
> - Métrica = Dinero / Tiempo / Edad (numérica) → **T-test**
> - Métrica = Clics / Conversiones / Cancelaciones (categórica) → **Chi-cuadrado o Z-test**

---

## 📐 Correlación de Pearson {#correlacion-pearson}

**Herramienta:** Pandas
**Cuándo:** Para medir la fuerza y dirección de la relación **lineal** entre dos variables numéricas continuas. Requiere que ambas variables tengan distribución aproximadamente normal.

```python
variables_numericas = [
    "edad", "tiempo_navegacion", "paginas_visitadas",
    "satisfaccion", "gasto_total", "ingreso_anual"
]

matriz_corr = df[variables_numericas].corr(method="pearson")
```

**Interpretación:** `1.0` perfecta positiva · `0.0` sin relación · `-1.0` perfecta negativa · `> 0.7` fuerte · `0.3–0.7` moderada

**Contexto real:** S8 NovaRetail — matriz de 6 variables de comportamiento de consumidores.

---

## 📊 Correlación de Spearman {#spearman}

**Herramienta:** SciPy
**Cuándo:** Para evaluar relaciones **monótonas** (no necesariamente lineales) entre dos variables numéricas. No requiere distribución normal — ideal cuando la distribución tiene asimetrías o outliers.

```python
from scipy.stats import spearmanr

coef, p_value = spearmanr(df["variable_a"], df["variable_b"])
print(f"Spearman r: {coef:.4f} | p-value: {p_value:.4f}")
```

**Diferencia clave con Pearson:** Pearson mide relación lineal exacta. Spearman mide si cuando una variable sube, la otra también sube (aunque no sea de forma proporcional).

**Contexto real:** S8 NovaRetail — usado para verificar relaciones entre variables con distribuciones asimétricas del dataset de comportamiento.

---

## 🔵 Correlación de Punto Biserial {#punto-biserial}

**Herramienta:** SciPy
**Cuándo:** Para medir la relación entre una **variable numérica** y una **variable binaria** (0/1). Es el método matemáticamente correcto cuando uno de los ejes es dicotómico.

```python
from scipy.stats import pointbiserialr

# Relación entre ser miembro premium (0/1) y el ingreso anual
coef, p_value = pointbiserialr(df["miembro_premium"], df["ingreso_anual"])
print(f"Punto Biserial r: {coef:.4f} | p-value: {p_value:.4f}")
```

**Contexto real:** S8 NovaRetail — análisis de variables binarias `miembro_premium` y `abandono` contra `ingreso_anual`.

> [!IMPORTANT] Cuándo NO usar Pearson
> Si una de tus variables es binaria (0/1), Pearson técnicamente funciona pero Punto Biserial es el método estadísticamente correcto y más preciso.

---

## 🌡️ Heatmap de Correlación {#heatmap}

**Herramienta:** Seaborn + Matplotlib
**Cuándo:** Para visualizar la matriz de correlación e identificar pares con mayor/menor relación a golpe de vista.

```python
import seaborn as sns
import matplotlib.pyplot as plt

plt.figure(figsize=(10, 8))
sns.heatmap(
    matriz_corr,
    annot=True,
    fmt=".2f",
    cmap="coolwarm",
    linewidths=0.5,
    vmin=-1,
    vmax=1
)
plt.title("Matriz de Correlación", fontsize=14, pad=15)
plt.tight_layout()
plt.show()
```

**Contexto real:** S8 NovaRetail — heatmap de 6×6 variables con paleta divergente `coolwarm`.

---

## 📊 Tabla de Contingencia (crosstab) {#crosstab}

**Herramienta:** Pandas
**Cuándo:** Para construir la tabla de frecuencias absolutas que relaciona dos variables categóricas. Es el input obligatorio para Chi-cuadrado y Fisher.

```python
tabla = pd.crosstab(df["traffic_source"], df["converted"])
```

> [!IMPORTANT] Siempre frecuencias absolutas
> Chi-cuadrado y Fisher requieren **conteos reales**, nunca porcentajes. No usar `normalize=True`.

**Contexto real:** S9 Landing Page — tablas para `traffic_source vs converted` y `device vs converted`.

---

## χ² Prueba Chi-cuadrado de Independencia {#chi2}

**Herramienta:** SciPy
**Cuándo:** Para determinar si dos variables **categóricas** son estadísticamente independientes. Funciona con cualquier número de categorías.

```python
from scipy.stats import chi2_contingency

tabla = pd.crosstab(df["traffic_source"], df["converted"])
chi2_stat, p_value, dof, expected = chi2_contingency(tabla)

print("=" * 50)
print(f"Chi²      : {chi2_stat:.4f}")
print(f"p-value   : {p_value:.6e}")
print(f"Grados lib: {dof}")
print("=" * 50)
```

**Contexto real:** S9 Landing Page — canal de adquisición vs conversión. S8 NovaRetail — variables categóricas vs segmentos de ingreso.

---

## 📏 V de Cramér (Magnitud del Efecto) {#cramer}

**Herramienta:** SciPy + cálculo manual
**Cuándo:** Después de Chi-cuadrado, para medir **qué tan fuerte** es la asociación (el p-value solo dice si existe, no qué tan grande es).

```python
from scipy.stats import chi2_contingency
import numpy as np

tabla = pd.crosstab(df["variable_a"], df["variable_b"])
chi2_stat, p_value, dof, expected = chi2_contingency(tabla)

# Calcular V de Cramér
n = tabla.sum().sum()                          # total de observaciones
min_dim = min(tabla.shape) - 1                 # dimensión mínima - 1
v_cramer = np.sqrt(chi2_stat / (n * min_dim))

print(f"V de Cramér: {v_cramer:.4f}")
```

**Interpretación de V de Cramér:**
- `< 0.10` — asociación débil
- `0.10–0.30` — asociación moderada
- `> 0.30` — asociación fuerte
- `~0.60` — asociación muy fuerte (resultado S8)

**Contexto real:** S8 NovaRetail — V de Cramér ≈ 0.60 entre variables categóricas y segmentos de ingreso.

---

## 🎣 Prueba Exacta de Fisher {#fisher}

**Herramienta:** SciPy
**Cuándo:** Alternativa a Chi-cuadrado cuando la tabla es **2×2** y las frecuencias esperadas son menores a 5 (muestras pequeñas). Más precisa que Chi-cuadrado en esos casos.

```python
from scipy.stats import fisher_exact

# Solo para tablas 2×2
tabla_2x2 = [[2, 8], [12, 3]]
odds_ratio, p_value = fisher_exact(tabla_2x2)

print(f"Odds Ratio: {odds_ratio:.4f}")
print(f"p-value   : {p_value:.4f}")
```

> [!NOTE] Chi-cuadrado vs Fisher
> - Tabla grande o frecuencias esperadas ≥ 5 → **Chi-cuadrado**
> - Tabla 2×2 con frecuencias esperadas < 5 → **Fisher Exact**

---

## 📉 Prueba T de Student — 2 Muestras Independientes {#ttest}

**Herramienta:** SciPy
**Cuándo:** Para comparar si el **promedio** de una variable numérica es significativamente diferente entre **dos grupos independientes**.

```python
from scipy.stats import ttest_ind

grupo_a = df[df["landing"] == "A"]["monto_compra"]
grupo_b = df[df["landing"] == "B"]["monto_compra"]

# equal_var=False → usa corrección de Welch (recomendado cuando varianzas son distintas)
t_stat, p_value = ttest_ind(grupo_a, grupo_b, equal_var=False)

print(f"t-stat  : {t_stat:.4f}")
print(f"p-value : {p_value:.6e}")
```

**Contexto real:** S9 — comparar monto de compra promedio entre usuarios de landing A vs B.

> [!TIP] ¿`equal_var=True` o `False`?
> Ejecuta primero la prueba de Levene. Si p-value de Levene < 0.05 → varianzas distintas → usa `equal_var=False` (Welch). Si p-value ≥ 0.05 → varianzas iguales → `equal_var=True`.

---

## ⚖️ Prueba de Levene (Homogeneidad de Varianzas) {#levene}

**Herramienta:** SciPy
**Cuándo:** Antes del T-test, para verificar si los dos grupos tienen varianzas similares. Define qué variante del T-test usar.

```python
from scipy.stats import levene

stat, p_value = levene(grupo_a, grupo_b)

print(f"Levene stat: {stat:.4f}")
print(f"p-value    : {p_value:.4f}")

if p_value < 0.05:
    print("→ Varianzas distintas: usar ttest_ind(..., equal_var=False)")
else:
    print("→ Varianzas iguales: usar ttest_ind(..., equal_var=True)")
```

**Contexto real:** S9 — verificación de supuestos antes del T-test entre grupos de landing page.

---

## 📊 Prueba Z de Proporciones — A/B Testing {#ztest}

**Herramienta:** statsmodels
**Cuándo:** Para comparar si la **tasa de conversión** (u otra proporción) es significativamente diferente entre exactamente dos grupos. Es la herramienta clásica del A/B Testing.

```python
from statsmodels.stats.proportion import proportions_ztest

# 100 conversiones de 1000 usuarios en A, 130 conversiones de 1050 en B
exitos = [100, 130]
observaciones = [1000, 1050]

z_stat, p_value = proportions_ztest(count=exitos, nobs=observaciones)

print(f"Z-stat  : {z_stat:.4f}")
print(f"p-value : {p_value:.6e}")
```

**Contexto real:** S9 — comparar tasas de conversión entre variantes de landing page.

> [!NOTE] Chi-cuadrado vs Z-test de proporciones
> Ambos sirven para comparar proporciones entre 2 grupos. La diferencia: Z-test es más directo para exactamente 2 grupos y da un estadístico Z interpretable. Chi-cuadrado escala a más de 2 grupos.

---

## 🔔 Prueba de Shapiro-Wilk (Normalidad) {#shapiro}

**Herramienta:** SciPy
**Cuándo:** Para verificar si una variable numérica sigue una distribución normal **antes** de aplicar pruebas paramétricas (T-test, Pearson). Si no es normal, considerar Spearman o pruebas no paramétricas.

```python
from scipy.stats import shapiro

stat, p_value = shapiro(df["monto_compra"])

print(f"Shapiro stat: {stat:.4f}")
print(f"p-value     : {p_value:.4f}")

if p_value < 0.05:
    print("→ No es normal: considerar Spearman o pruebas no paramétricas")
else:
    print("→ Distribución normal: T-test y Pearson son válidos")
```

> [!WARNING] Shapiro-Wilk con muestras grandes
> Con n > 5,000 el test casi siempre rechaza normalidad por ser muy sensible. En esos casos, confiar en el histograma + QQ-plot visualmente.

---

## 🎯 Interpretar el p-value {#interpretar-pvalue}

**Marco de decisión con α = 0.05:**

```
p-value < 0.05  → Rechazar H₀
                  La diferencia/asociación es estadísticamente significativa.
                  No se debe al azar.

p-value ≥ 0.05  → No rechazar H₀
                  No hay evidencia suficiente.
                  Las diferencias pueden ser producto del azar.
```

**Plantillas de hipótesis:**

```
Chi-cuadrado / Fisher:
H₀: Las variables son independientes (no hay asociación)
H₁: Las variables están asociadas

T-test / Z-test:
H₀: No hay diferencia significativa entre los grupos (μ₁ = μ₂)
H₁: Existe diferencia significativa entre los grupos (μ₁ ≠ μ₂)
```

$$\alpha = 0.05$$

> [!WARNING] p-value ≠ magnitud
> Un p-value significativo solo confirma que la diferencia no es azar — no dice qué tan grande es el efecto. Para la magnitud usar V de Cramér (categóricas) o Cohen's d (numéricas).

---

## 🔗 Conexiones Estratégicas

- **Herramientas:** [[Pandas]] | `scipy.stats` | `statsmodels`
- **Operación previa:** [[Transformacion_y_Feature_Engineering]]
- **Sprint de referencia:** S9 Landing Page | S8 NovaRetail
