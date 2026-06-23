---
tags: [operacion, estadistica, hipotesis, chi2, correlacion, pandas, scipy]
tipo: nota-operacion
herramientas: [pandas, scipy]
---

# 🧪 Análisis Estadístico y Pruebas de Hipótesis

Operaciones para cuantificar relaciones entre variables y determinar si las diferencias observadas son estadísticamente significativas o producto del azar.

---

## 📋 Índice de Operaciones

| Operación | Herramienta | Ir a |
|---|---|---|
| Matriz de correlación (Pearson) | Pandas | [[#correlacion-pearson]] |
| Heatmap de correlación | Seaborn | [[#heatmap]] |
| Tabla de contingencia (crosstab) | Pandas | [[#crosstab]] |
| Prueba Chi-cuadrado de independencia | SciPy | [[#chi2]] |
| Interpretar p-value | — | [[#interpretar-pvalue]] |

---

## 📐 Matriz de Correlación (Pearson) {#correlacion-pearson}

**Herramienta:** Pandas
**Cuándo:** Para medir la fuerza y dirección de la relación lineal entre pares de variables numéricas. Útil como paso exploratorio antes de modelado o para identificar variables relacionadas con el KPI objetivo.

```python
# Seleccionar solo las variables numéricas de interés
variables_numericas = [
    "edad", "tiempo_navegacion", "paginas_visitadas",
    "satisfaccion", "gasto_total", "ingreso_anual"
]

# Calcular la matriz de correlación
matriz_corr = df[variables_numericas].corr(method="pearson")
matriz_corr
```

**Interpretación de valores:**
- `1.0` — correlación positiva perfecta
- `0.0` — sin relación lineal
- `-1.0` — correlación negativa perfecta
- `> 0.7` o `< -0.7` — correlación fuerte
- Entre `0.3` y `0.7` — correlación moderada

**Contexto real:** S8 NovaRetail — matriz de 6 variables para identificar qué factores se correlacionan más con `gasto_total` e `ingreso_anual`.

---

## 🌡️ Heatmap de Correlación {#heatmap}

**Herramienta:** Seaborn + Matplotlib
**Cuándo:** Para visualizar la matriz de correlación de forma que sea fácil identificar los pares con mayor y menor relación a golpe de vista.

```python
import seaborn as sns
import matplotlib.pyplot as plt

plt.figure(figsize=(10, 8))

sns.heatmap(
    matriz_corr,
    annot=True,          # mostrar los valores numéricos en cada celda
    fmt=".2f",           # formato de 2 decimales
    cmap="coolwarm",     # paleta divergente: azul (negativo) → rojo (positivo)
    linewidths=0.5,      # líneas entre celdas
    vmin=-1,             # límite mínimo de la escala de color
    vmax=1               # límite máximo de la escala de color
)

plt.title("Matriz de Correlación: NovaRetail+", fontsize=14, pad=15)
plt.tight_layout()
plt.show()
```

**Parámetros clave de `sns.heatmap()`:**

| Parámetro | Qué hace |
|---|---|
| `annot=True` | Muestra el número dentro de cada celda |
| `fmt=".2f"` | Formato decimal de los números |
| `cmap="coolwarm"` | Paleta divergente centrada en 0 |
| `vmin / vmax` | Fija los extremos de la escala de color |

**Contexto real:** S8 NovaRetail — heatmap de 6x6 variables para identificar factores de comportamiento de consumidores.

---

## 📊 Tabla de Contingencia (crosstab) {#crosstab}

**Herramienta:** Pandas
**Cuándo:** Para construir la tabla de frecuencias absolutas que relaciona dos variables categóricas. Es el input obligatorio para la prueba Chi-cuadrado.

```python
# Tabla de contingencia: filas = variable A, columnas = variable B
tabla = pd.crosstab(df["traffic_source"], df["converted"])
tabla
```

> [!IMPORTANT] Usar siempre frecuencias absolutas
> La prueba Chi-cuadrado debe recibir **conteos reales** (frecuencias absolutas), nunca porcentajes ni proporciones normalizadas. `pd.crosstab()` por defecto entrega frecuencias absolutas — no usar `normalize=True`.

**Contexto real:** S9 Landing Page — tablas de contingencia para `traffic_source vs converted` y `device vs converted`.

---

## χ² Prueba Chi-cuadrado de Independencia {#chi2}

**Herramienta:** SciPy
**Cuándo:** Para determinar si dos variables categóricas son estadísticamente independientes o si existe una asociación significativa entre ellas. Requiere la tabla de contingencia con frecuencias absolutas.

```python
from scipy.stats import chi2_contingency

# Construir la tabla de contingencia primero
tabla = pd.crosstab(df["traffic_source"], df["converted"])

# Ejecutar el test
chi2_stat, p_value, dof, expected = chi2_contingency(tabla)

# Mostrar resultados de forma estructurada
print("=" * 60)
print("   RESULTADOS CHI-CUADRADO")
print("=" * 60)
print(f"Estadístico Chi²  : {chi2_stat:.4f}")
print(f"Valor P (p-value) : {p_value:.6e}")
print(f"Grados de Libertad: {dof}")
print("=" * 60)
```

**Valores devueltos:**
- `chi2_stat` — estadístico de la prueba (qué tan grande es la diferencia observada vs esperada)
- `p_value` — probabilidad de observar esa diferencia por azar
- `dof` — grados de libertad `(filas-1) × (columnas-1)`
- `expected` — frecuencias esperadas bajo independencia

**Contexto real:** S9 — prueba para `traffic_source vs converted` y para `device vs converted`, ambas con α = 0.05.

---

## 🎯 Interpretar el p-value {#interpretar-pvalue}

**Cuándo:** Después de cualquier prueba estadística. El p-value es la evidencia para tomar la decisión estadística.

**Marco de decisión con α = 0.05:**

```
Si p-value < 0.05  → Rechazar H₀
                     Existe asociación estadísticamente significativa.
                     La diferencia observada NO se debe al azar.

Si p-value ≥ 0.05  → No rechazar H₀
                     No hay evidencia suficiente de asociación.
                     Las diferencias observadas pueden ser producto del azar.
```

**Plantilla de hipótesis para Chi-cuadrado:**

$$H_0: \text{Las variables son independientes (no hay asociación)}$$
$$H_1: \text{Las variables están asociadas (existe dependencia)}$$

**Nivel de significancia estándar:**
$$\alpha = 0.05$$

**Contexto real:** S9 — si `p_value < 0.05` para `traffic_source`, el canal de adquisición influye significativamente en la conversión y el equipo de marketing debe optimizar por canal.

> [!WARNING] p-value no mide magnitud
> Un p-value significativo solo dice que la diferencia no es azar — no dice qué tan grande es el efecto. Para eso se usan métricas como el tamaño del efecto (V de Cramér para Chi-cuadrado).

---

## 🔗 Conexiones Estratégicas

- **Herramientas:** [[Pandas]] | `scipy.stats`
- **Operación previa:** [[Transformacion_y_Feature_Engineering]]
- **Sprint de referencia:** S9 Landing Page Experiment | S8 NovaRetail
