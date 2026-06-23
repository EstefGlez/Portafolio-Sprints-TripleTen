---
tags: [operacion, visualizacion, matplotlib, seaborn, pandas]
tipo: nota-operacion
herramientas: [pandas, matplotlib, seaborn]
---

# 📉 Visualización de Datos

Operaciones para comunicar patrones, distribuciones y relaciones a través de gráficos. La visualización va después del análisis, no antes.

---

## 📋 Índice de Operaciones

| Gráfico | Cuándo usarlo | Ir a |
|---|---|---|
| Configuración global de estilo | Siempre, al inicio | [[#config-global]] |
| Histograma + KDE | Distribución de 1 variable numérica | [[#histplot]] |
| Boxplot | Distribución con outliers | [[#boxplot]] |
| Scatterplot | Relación entre 2 variables numéricas | [[#scatterplot]] |
| Barplot | Comparar promedios por categoría | [[#barplot]] |
| Histograma múltiple (hue) | Distribución segmentada por grupo | [[#hue]] |
| Subplots (múltiples gráficos) | Comparar varias distribuciones juntas | [[#subplots]] |

---

## ⚙️ Configuración Global de Estilo {#config-global}

**Herramienta:** Seaborn + Matplotlib
**Cuándo:** Al inicio de cada notebook, antes del primer gráfico. Establece el estilo visual de todos los gráficos del análisis.

```python
import matplotlib.pyplot as plt
import seaborn as sns

# Estilo base (rejilla blanca, fondo limpio)
sns.set_theme(style="whitegrid")

# Tamaño por defecto de todas las figuras
plt.rcParams["figure.figsize"] = (10, 6)
```

**Estilos disponibles en Seaborn:**
- `"whitegrid"` — fondo blanco con rejilla (más limpio para reportes)
- `"darkgrid"` — fondo oscuro con rejilla
- `"white"` — solo fondo blanco, sin rejilla
- `"ticks"` — minimalista con marcas de eje

**Contexto real:** S5, S7, S8, S9 — `sns.set_theme(style="whitegrid")` como primera línea de configuración.

---

## 📊 Histograma + KDE {#histplot}

**Herramienta:** Seaborn
**Cuándo:** Para visualizar la distribución de una variable numérica continua. El KDE (curva de densidad) suaviza el histograma para ver la forma de la distribución.

```python
sns.histplot(
    data=df,
    x="city_gdp_capita",
    kde=True,           # superpone curva de densidad
    bins=10,            # número de barras
    color="#55a868"
)
plt.title("Distribución del PIB per Cápita")
plt.xlabel("PIB per Cápita (USD)")
plt.ylabel("Frecuencia de Ciudades")
plt.show()
```

**Parámetros clave:**

| Parámetro | Qué hace |
|---|---|
| `kde=True` | Superpone curva de densidad de kernel |
| `bins` | Número de intervalos del histograma |
| `hue` | Colorea por categoría (ver [[#hue]]) |

**Contexto real:** S5 — distribución de PIB per cápita de ciudades del dataset OECD.

---

## 📦 Boxplot {#boxplot}

**Herramienta:** Seaborn
**Cuándo:** Para ver la distribución de una variable numérica mostrando mediana, cuartiles y outliers. Más informativo que el histograma cuando hay valores extremos.

```python
sns.boxplot(
    data=df,
    y="jams_delay",
    color="#4c72b0",
    showmeans=True,
    meanprops={
        "marker": "o",
        "markerfacecolor": "white",
        "markeredgecolor": "black",
        "markersize": "8"
    }
)
plt.title("Distribución de Retrasos por Tráfico")
plt.ylabel("Minutos de retraso promedio")
plt.show()
```

**Anatomía del boxplot:**
- Línea central → **mediana**
- Caja → **IQR** (rango intercuartílico, Q1-Q3)
- Bigotes → valores hasta 1.5×IQR
- Puntos fuera → **outliers**
- Punto blanco (con `showmeans=True`) → **media**

**Contexto real:** S5 LADB — retrasos de tráfico por ciudad, donde Ciudad de México aparecía como outlier severo desplazando la media sobre la mediana.

---

## 🔵 Scatterplot {#scatterplot}

**Herramienta:** Seaborn
**Cuándo:** Para visualizar la relación entre dos variables numéricas. Con `hue` segmentas por categoría, con `size` añades una tercera dimensión cuantitativa (burbujas).

```python
plt.figure(figsize=(12, 6))

sns.scatterplot(
    data=df,
    x="city_gdp_capita",
    y="jams_delay",
    hue="country",          # color por categoría
    size="population",      # tamaño de burbuja por variable numérica
    sizes=(40, 400),        # rango de tamaños mínimo y máximo
    palette="viridis"
)

plt.title("PIB per Cápita vs Retraso por Tráfico")
plt.xlabel("PIB per Cápita (USD)")
plt.ylabel("Retraso Promedio (Minutos)")
plt.legend(bbox_to_anchor=(1.05, 1), loc="upper left", title="Referencias")
plt.grid(True, linestyle="--", alpha=0.6)
plt.show()
```

**Contexto real:** S5 — relación entre productividad económica (PIB) y congestión urbana, con burbujas proporcionales a la población de cada ciudad.

---

## 📊 Barplot {#barplot}

**Herramienta:** Seaborn
**Cuándo:** Para comparar el promedio (u otra métrica) de una variable numérica entre categorías. Más limpio que el histograma cuando el eje X es categórico.

```python
sns.barplot(
    data=df,
    x="traffic_source",
    y="converted",
    errorbar=None,       # elimina barras de error (intervalo de confianza)
    palette="Blues_d"
)
plt.title("Tasa de Conversión por Fuente de Tráfico")
plt.xlabel("Fuente de Tráfico")
plt.ylabel("Proporción de Conversión")
plt.show()
```

> [!NOTE] `errorbar=None`
> Por defecto Seaborn dibuja intervalos de confianza en los barplots. Para reportes ejecutivos donde el foco es la métrica central, se elimina con `errorbar=None`.

**Contexto real:** S9 Landing Page — tasa de conversión por `traffic_source` y por `device` en subplots lado a lado.

---

## 🎨 Histograma Segmentado por Grupo (hue) {#hue}

**Herramienta:** Seaborn
**Cuándo:** Para comparar la distribución de una variable entre grupos (ej. plan A vs plan B) en un mismo gráfico.

```python
sns.histplot(
    data=user_profile,
    x="age",
    hue="plan",          # variable categórica que define los colores
    kde=True,
    multiple="stack",    # apilar las distribuciones
    palette="muted"
)
plt.title("Distribución de Edad por Plan")
plt.show()
```

**Valores de `multiple`:**
- `"stack"` — apila las barras (bueno para ver composición)
- `"dodge"` — barras lado a lado (bueno para comparar alturas)
- `"fill"` — normaliza a 100% (bueno para ver proporciones)

**Contexto real:** S7 ConnectaTel — 4 histogramas (edad, mensajes, llamadas, minutos) segmentados por tipo de plan (`hue="plan"`).

---

## 🗂️ Subplots — Múltiples Gráficos en una Figura {#subplots}

**Herramienta:** Matplotlib + Seaborn
**Cuándo:** Para mostrar varios gráficos relacionados en una sola figura, evitando que el lector tenga que saltar entre celdas.

```python
# Crear la figura con N filas × M columnas
fig, axes = plt.subplots(2, 2, figsize=(16, 12))

# Pasar el ax correspondiente a cada gráfico de Seaborn
sns.histplot(data=df, x="age",          ax=axes[0, 0])
sns.histplot(data=df, x="mensajes",     ax=axes[0, 1])
sns.histplot(data=df, x="llamadas",     ax=axes[1, 0])
sns.histplot(data=df, x="minutos",      ax=axes[1, 1])

plt.tight_layout()   # evita que los títulos se sobrepongan
plt.show()
```

**Para 1 fila × 2 columnas (más simple):**
```python
fig, axes = plt.subplots(1, 2, figsize=(16, 6))

sns.boxplot(data=df, y="jams_delay", ax=axes[0])
sns.histplot(data=df, x="gdp",      ax=axes[1])

plt.tight_layout()
plt.show()
```

**Contexto real:** S5 — boxplot + histograma en `(1, 2)`. S7 — 4 histogramas en `(2, 2)`. S9 — 2 barplots en `(1, 2)`.

---

## 🔗 Conexiones Estratégicas

- **Herramientas:** [[Pandas]] | `matplotlib.pyplot` | `seaborn`
- **Operación previa:** [[Analisis_Estadistico]]
- **Sprint de referencia:** S5 LADB | S7 ConnectaTel | S8 NovaRetail | S9 Landing Page
