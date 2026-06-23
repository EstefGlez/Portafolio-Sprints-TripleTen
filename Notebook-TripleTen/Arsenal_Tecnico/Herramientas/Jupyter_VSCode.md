---
tags: [herramienta, entorno, jupyter, vscode, python, kernel]
tipo: indice-herramienta
---

# ⚙️ Entorno de Desarrollo — Jupyter en VS Code

Documentación del entorno de trabajo configurado para ejecutar los proyectos de Python del bootcamp. No es una librería de análisis — es el **ambiente** donde corre todo el código.

---

## 🖥️ Stack del Entorno

| Componente | Detalle |
|---|---|
| **Editor** | Visual Studio Code |
| **Interfaz de notebooks** | Jupyter integrado en VS Code (extensión oficial) |
| **Kernel activo** | `env (Python 3.14.6)` — entorno virtual dedicado |
| **Formato de archivos** | `.ipynb` (Jupyter Notebook) |
| **Formato alternativo** | Celdas interactivas `# %%` en archivos `.py` |

---

## 🚀 Cómo Funciona el Entorno

```
VS Code
  └── Extensión Jupyter
        └── Kernel: env (Python 3.14.6)
              └── Librerías instaladas en el entorno virtual:
                    pandas, numpy, matplotlib, seaborn, scipy, re
```

El kernel `env` es un **entorno virtual aislado** — las librerías instaladas aquí no interfieren con el sistema operativo ni con otros proyectos. Esto garantiza consistencia entre sesiones.

---

## 📓 Tipos de Archivo

### Jupyter Notebook (`.ipynb`)
Formato principal usado en todos los sprints de Python (S5, S7, S8, S9).

```
Ventajas:
- Renderiza outputs (tablas, gráficos) directamente bajo cada celda
- Permite mezclar celdas de código y celdas Markdown en el mismo archivo
- Vista de Jupyter Variables para inspeccionar DataFrames en tiempo real
```

### Celdas Interactivas en `.py` (`# %%`)
Alternativa cuando se trabaja en scripts Python normales pero se quiere ejecución celda por celda.

```python
# %% Celda 1 — Importaciones
import pandas as pd
import seaborn as sns

# %% Celda 2 — Carga de datos
df = pd.read_csv("datos.csv")
df.head()
```

---

## 🎛️ Barra de Herramientas de Jupyter en VS Code

Cuando abres un `.ipynb`, aparece esta barra en la parte superior:

| Botón | Qué hace |
|---|---|
| `▶ Run All` | Ejecuta todas las celdas del notebook de arriba a abajo |
| `↺ Restart` | Reinicia el kernel (limpia todas las variables en memoria) |
| `✕ Clear All Outputs` | Borra todos los outputs sin borrar el código |
| `Jupyter Variables` | Abre panel lateral con todos los DataFrames y variables activos |
| `Outline` | Muestra el índice de headers Markdown del notebook |
| `env (Python 3.14.6)` | Selector de kernel — aquí cambias el entorno si necesitas |

> [!TIP] Cuándo hacer Restart
> Si modificas una celda de transformación anterior y los resultados de celdas posteriores parecen incorrectos, haz `Restart` + `Run All` para asegurar que todo corra en orden limpio desde cero.

---

## 📦 Librerías del Entorno (`env`)

Librerías instaladas en el kernel y usadas en los sprints:

```python
# Análisis de datos
import pandas as pd        # manipulación de DataFrames
import numpy as np         # operaciones numéricas

# Visualización
import matplotlib.pyplot as plt   # gráficos base
import seaborn as sns             # gráficos estadísticos de alto nivel

# Estadística
from scipy.stats import chi2_contingency   # prueba Chi-cuadrado

# Utilidades
import re                  # expresiones regulares (snake_case, limpieza)
```

---

## 🗂️ Convención de Estructura de Celdas

Estándar aplicado en todos los notebooks del portafolio:

```python
# 🧩 Paso 1: Importación de Librerías
import pandas as pd
...

# 🧩 Paso 2: Carga de Datos
df = pd.read_csv(...)

# 🧩 Paso 3: Exploración y Auditoría
df.info()
df.isna().sum()

# 🧩 Paso 4: Limpieza y Transformación
...

# 🧩 Paso 5: Análisis y Visualización
...

# 🧩 Paso 6: Conclusiones
```

> [!NOTE] Por qué esta estructura importa
> Sigue el orden lógico de un pipeline de datos real. Cualquier persona (o IA) que lea el notebook entiende inmediatamente en qué etapa está cada celda sin necesidad de leer el código completo.

---

## 📌 Sprints ejecutados en este entorno

| Sprint | Archivo | Kernel usado |
|---|---|---|
| S5 | `S5_ladb_mobility_economy_project_student.ipynb` | `env (Python 3.14.6)` |
| S7 | `S7_Version-Estudiante-Project-ConnectaTel.ipynb` | `env (Python 3.14.6)` |
| S8 | `S8_Student_Version-Project-NovaRetail.ipynb` | `env (Python 3.14.6)` |
| S9 | `S9_Version_Student_Proyecto_Landing_Experiment.ipynb` | `env (Python 3.14.6)` |

---

## 🔗 Conexiones Estratégicas

- **Índice Maestro:** [[Indice_Maestro]]
- **Librería principal:** [[Pandas]]
- **Operaciones ejecutadas aquí:** [[Carga_y_Exploracion]] | [[Transformacion_y_Feature_Engineering]] | [[Visualizacion]] | [[Analisis_Estadistico]]
