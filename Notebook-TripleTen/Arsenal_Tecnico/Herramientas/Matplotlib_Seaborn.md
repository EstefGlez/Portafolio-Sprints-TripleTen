---
tags: [herramienta, matplotlib, seaborn, visualizacion, python, indice]
tipo: indice-herramienta
---

# 📉 Matplotlib & Seaborn — Índice de Capacidades

Librerías de visualización del ecosistema Python. Matplotlib es la base de bajo nivel y Seaborn construye sobre ella con una API de alto nivel orientada a estadística. Se usan juntas en todos los proyectos de Python del bootcamp.

---

## 🗂️ Matplotlib (`plt.`) — Capacidades por Categoría

### 🖼️ Configuración del Lienzo
| Qué hace | Función clave | Nota |
|---|---|---|
| Crear figura con tamaño personalizado | `plt.figure(figsize=(ancho, alto))` | [[Visualizacion#config-global]] |
| Crear múltiples gráficos en una figura | `plt.subplots(filas, cols, figsize=(...))` | [[Visualizacion#subplots]] |
| Ajustar márgenes automáticamente | `plt.tight_layout()` | [[Matplotlib_Seaborn#tight-layout]] |
| Renderizar y mostrar el gráfico | `plt.show()` | [[Matplotlib_Seaborn#show]] |
| Obtener el eje activo actual | `plt.gca()` | [[Matplotlib_Seaborn#gca]] |

### 🏷️ Etiquetas y Títulos
| Qué hace | Función clave | Nota |
|---|---|---|
| Título del gráfico | `plt.title("texto", fontsize=14, fontweight='bold')` | [[Matplotlib_Seaborn#titulos]] |
| Etiqueta eje X | `plt.xlabel("texto", fontsize=12)` | [[Matplotlib_Seaborn#titulos]] |
| Etiqueta eje Y | `plt.ylabel("texto", fontsize=12)` | [[Matplotlib_Seaborn#titulos]] |
| Título/etiqueta en subplot específico | `axes[i].set_title()` / `axes[i].set_xlabel()` | [[Matplotlib_Seaborn#subplots-labels]] |
| Rotar etiquetas del eje X | `plt.xticks(rotation=45, ha='right')` | [[Matplotlib_Seaborn#xticks]] |
| Controlar rotación en subplot | `axes[i].tick_params(axis='x', rotation=0)` | [[Matplotlib_Seaborn#xticks]] |

### 📝 Anotaciones
| Qué hace | Función clave | Nota |
|---|---|---|
| Agregar texto sobre una barra | `ax.text(x, y, s, ha, va, fontsize)` | [[Matplotlib_Seaborn#anotaciones]] |
| Leyenda personalizada | `plt.legend(title=, labels=, loc=, bbox_to_anchor=)` | [[Matplotlib_Seaborn#leyenda]] |

---

## 🗂️ Seaborn (`sns.`) — Capacidades por Categoría

### 📊 Gráficos de Distribución
| Qué hace | Función clave | Nota |
|---|---|---|
| Histograma + KDE | `sns.histplot(data, x, kde=True, bins, hue, palette)` | [[Visualizacion#histplot]] |
| Histograma segmentado por grupo | `sns.histplot(..., hue="plan", palette=[...])` | [[Visualizacion#hue]] |
| Boxplot con media | `sns.boxplot(data, y, showmeans=True)` | [[Visualizacion#boxplot]] |
| Boxplot en subplot | `sns.boxplot(data, y=col, ax=axes[i])` | [[Visualizacion#subplots]] |

### 📈 Gráficos de Relación
| Qué hace | Función clave | Nota |
|---|---|---|
| Scatterplot simple | `sns.scatterplot(data, x, y)` | [[Visualizacion#scatterplot]] |
| Scatterplot con burbujas y color | `sns.scatterplot(data, x, y, hue, size, sizes, palette)` | [[Visualizacion#scatterplot]] |
| Pairplot multivariante | `sns.pairplot(df)` | [[Matplotlib_Seaborn#pairplot]] |

### 📊 Gráficos de Comparación
| Qué hace | Función clave | Nota |
|---|---|---|
| Barplot de promedios | `sns.barplot(data, x, y, errorbar=None)` | [[Visualizacion#barplot]] |
| Countplot de frecuencias absolutas | `sns.countplot(data, x, hue, palette, ax)` | [[Matplotlib_Seaborn#countplot]] |

### 🌡️ Gráficos de Correlación
| Qué hace | Función clave | Nota |
|---|---|---|
| Heatmap de correlación | `sns.heatmap(matriz, annot=True, cmap, vmin, vmax)` | [[Analisis_Estadistico#heatmap]] |

---

## 📐 Referencia Completa de Funciones

### `plt.tight_layout()` {#tight-layout}
**Cuándo:** Siempre al final de una figura con múltiples subplots. Previene que títulos, etiquetas y leyendas se recorten o encimen.
```python
plt.tight_layout()
plt.show()
```
**Contexto real:** S9 — figura con 2 subplots de countplot lado a lado.

---

### `plt.show()` {#show}
**Cuándo:** Al final de cada bloque de visualización para renderizar el gráfico y limpiar el buffer de memoria de Jupyter.
```python
plt.show()
```
> [!NOTE] Sin `plt.show()` en Jupyter
> Jupyter a veces muestra el gráfico sin él, pero puede generar texto residual como `<Figure size ...>`. Siempre incluirlo para reportes limpios.

---

### `plt.gca()` {#gca}
**Cuándo:** Para capturar el eje activo y poder iterar sobre sus barras para añadir anotaciones dinámicas.
```python
ax = plt.gca()
for bar in ax.patches:
    height = bar.get_height()
    ax.text(
        x = bar.get_x() + bar.get_width() / 2,
        y = height + (height * 0.005),
        s = f"{int(height)}",
        ha = 'center',
        va = 'bottom',
        fontsize = 10
    )
```
**Contexto real:** S9 — anotar conteos absolutos encima de cada barra del countplot.

---

### Títulos y Etiquetas {#titulos}
**Cuándo:** En toda visualización de reporte. Obligatorio para que el gráfico sea autoexplicativo.
```python
plt.title("Título del Gráfico", fontsize=14, fontweight='bold')
plt.xlabel("Variable X", fontsize=12)
plt.ylabel("Variable Y", fontsize=12)
```

### Títulos en Subplots {#subplots-labels}
```python
axes[0].set_title("Gráfico Izquierdo", fontsize=14, fontweight='bold')
axes[0].set_xlabel("Fuente de Tráfico", fontsize=12)
axes[0].set_ylabel("Cantidad de Usuarios", fontsize=12)
```
**Contexto real:** S9 — dos countplots con títulos independientes por eje.

---

### `plt.xticks()` y `tick_params()` {#xticks}
**Cuándo:** Cuando las etiquetas del eje X se enciman por ser texto largo o haber muchas categorías.
```python
# Rotar etiquetas (gráfico individual)
plt.xticks(rotation=45, ha='right')

# Rotar en subplot específico
axes[1].tick_params(axis='x', rotation=0)
```
**Contexto real:** S5 — nombres de 10 ciudades rotados 45° en barplot.

---

### Leyenda Personalizada {#leyenda}
**Cuándo:** Cuando el gráfico tiene `hue` y quieres renombrar las categorías o reposicionar la leyenda fuera del área del gráfico.
```python
axes[1].legend(
    title='¿Convirtió?',
    labels=['No (0)', 'Sí (1)'],
    loc='upper left',
    bbox_to_anchor=(1, 1)    # mueve la leyenda fuera del gráfico
)
```
**Contexto real:** S9 — leyenda de conversión binaria fuera del countplot para no obstruir las barras.

---

### Anotaciones sobre Barras {#anotaciones}
**Cuándo:** Para mostrar el valor numérico exacto encima de cada barra en reportes ejecutivos donde la precisión del número importa.
```python
ax = plt.gca()
for bar in ax.patches:
    height = bar.get_height()
    ax.text(
        x = bar.get_x() + bar.get_width() / 2,
        y = height + (height * 0.005),
        s = f"{int(height)}",
        ha = 'center',
        va = 'bottom',
        fontsize = 10
    )
plt.show()
```

---

### `sns.pairplot()` {#pairplot}
**Cuándo:** Para exploración visual multivariante rápida al inicio del análisis. Genera automáticamente histogramas en la diagonal y scatterplots cruzados para todas las variables numéricas.
```python
sns.pairplot(df)
plt.show()
```
> [!WARNING] Solo para exploración, no para reportes
> Con muchas variables genera una figura muy densa. Úsalo para exploración inicial, luego selecciona los pares relevantes para gráficos individuales.

**Contexto real:** S8 NovaRetail — exploración multivariante del dataset de comportamiento de consumidores.

---

### `sns.countplot()` {#countplot}
**Cuándo:** Para comparar frecuencias absolutas (conteos) entre categorías. A diferencia de `barplot`, no calcula promedios — muestra cuántos registros hay en cada grupo.
```python
# Simple
sns.countplot(data=df, x="grupo_uso")

# Segmentado por grupo (hue) con colores personalizados
sns.countplot(
    data=df,
    x='traffic_source',
    hue='converted',
    palette=["#95D5B2", "#F4A261"],
    ax=axes[0]
)
```

**Diferencia con `barplot`:**
- `countplot` → cuenta filas por categoría (frecuencia absoluta)
- `barplot` → calcula el promedio de una variable numérica por categoría

**Contexto real:** S7 ConnectaTel — conteo de usuarios por `grupo_uso` y `grupo_edad`. S9 Landing Page — usuarios convertidos vs no convertidos por fuente de tráfico.

---

## 📌 Sprints donde se usaron estas librerías

| Sprint | Proyecto | Funciones destacadas |
|---|---|---|
| S5 | LADB — Movilidad urbana | `boxplot`, `histplot`, `barplot`, `xticks(rotation=45)` |
| S7 | ConnectaTel — Segmentación | `histplot(hue)`, `boxplot(loop)`, `countplot`, `figure(figsize)` |
| S8 | NovaRetail+ — Comportamiento | `heatmap`, `pairplot`, `scatterplot`, `figure(figsize)` |
| S9 | Landing Page — A/B Testing | `countplot(hue)`, `subplots`, `tight_layout`, `gca`, `ax.text`, `legend(bbox_to_anchor)` |

---

## 🔗 Conexiones Estratégicas

- **Índice Maestro:** [[Indice_Maestro]]

- **Índice Maestro:** [[Indice_Maestro]]
- **Nota de operación:** [[Visualizacion]] | [[Analisis_Estadistico]]
- **Herramienta relacionada:** [[Pandas]] | [[Numpy]]

---

## 📌 Actualización S8/S9 — Patrones Nuevos

### 📊 Nuevas visualizaciones documentadas
| Visual | Cuándo usarlo | Nota |
|---|---|---|
| Subplots 2x2 de scatterplots | Explorar múltiples pares de correlación en una figura | [[Visualizacion#subplots-scatter]] |
| Boxplot comparativo A vs B | Comparar distribuciones entre grupos experimentales | [[Visualizacion#boxplot-ab]] |
| Barplot de tasa de conversión | Visualizar proporciones por segmento antes del Z-test | [[Visualizacion#barplot-conversion]] |

### 🎨 Parámetros nuevos documentados

| Parámetro | Función | Qué hace |
|---|---|---|
| `alpha=0.5` | `sns.scatterplot()` | Transparencia para ver densidad de puntos solapados |
| `plt.suptitle(texto, y=1.02)` | `plt.figure()` | Título global de figura con múltiples subplots |
| `palette=['#hex1', '#hex2']` | `sns.boxplot()` | Colores personalizados por categoría con hex codes |
| `axes[fila, col]` | `plt.subplots(2,2)` | Referencia exacta a subplot en cuadrícula 2D |
