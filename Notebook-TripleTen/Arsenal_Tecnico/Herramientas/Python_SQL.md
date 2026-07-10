---
tags: [herramienta, python, sql, sqlalchemy, conexion, pd-read-sql]
tipo: indice-herramienta
---

# 🔌 Python + SQL — Conexión y Consultas con sqlalchemy

Librería que permite conectar Python con bases de datos relacionales (PostgreSQL, MySQL, etc.) y ejecutar consultas SQL directamente desde un notebook, recibiendo los resultados como DataFrames de Pandas.

---

## 🗂️ Capacidades por Categoría

### 🔗 Conexión a Base de Datos
| Qué hace | Función clave | Nota |
|---|---|---|
| Crear string de conexión PostgreSQL | `'postgresql://user:pwd@host:port/db'` | [[Python_SQL#conexion]] |
| Crear motor de conexión | `create_engine(connection_string)` | [[Python_SQL#conexion]] |
| Conexión con SSL (producción) | `connect_args={'sslmode':'require'}` | [[Python_SQL#conexion]] |

### 📥 Ejecución de Consultas
| Qué hace | Función clave | Nota |
|---|---|---|
| Ejecutar query y obtener DataFrame | `pd.read_sql(query, con=engine)` | [[Python_SQL#read-sql]] |
| Explorar tabla completa | `SELECT * FROM tabla` dentro de query | [[Python_SQL#read-sql]] |
| Query con CTEs y lógica compleja | String multilínea con `'''...'''` | [[Python_SQL#queries-avanzadas]] |

---

## 📐 Referencia Completa de Funciones

### 🔌 Configurar la Conexión {#conexion}

**Cuándo:** Al inicio de cualquier notebook que necesite consultar una base de datos relacional. La conexión se crea una sola vez y se reutiliza en todas las queries.

```python
import pandas as pd
from sqlalchemy import create_engine

# Configuración de credenciales
db_config = {
    'user': 'nombre_usuario',
    'pwd':  'contraseña',
    'host': 'host.cluster.region.rds.amazonaws.com',
    'port': 5432,
    'db':   'nombre_base_de_datos'
}

# Construir el string de conexión
connection_string = 'postgresql://{}:{}@{}:{}/{}'.format(
    db_config['user'],
    db_config['pwd'],
    db_config['host'],
    db_config['port'],
    db_config['db']
)

# Crear el motor (se usa en todos los pd.read_sql posteriores)
engine = create_engine(connection_string, connect_args={'sslmode': 'require'})
```

**Parámetros clave:**
- `postgresql://` — prefijo del dialecto (cambia a `mysql://`, `sqlite:///` etc. según la DB)
- `connect_args={'sslmode':'require'}` — obligatorio en conexiones a servidores remotos de producción
- `engine` — objeto que se reutiliza en todas las consultas del notebook

> [!IMPORTANT] No modificar el bloque de conexión
> En entornos de curso o producción, el bloque de `db_config` y `engine` suele estar pregrabado. No lo modifiques — solo úsalo como referencia en tus queries.

**Contexto real:** S12 — Conexión a base de datos PostgreSQL de TripleTen para análisis de funnel y cohortes de RappiPlus.

---

### 📥 Ejecutar Consultas con `pd.read_sql()` {#read-sql}

**Cuándo:** Para ejecutar cualquier consulta SQL y recibir el resultado directamente como un DataFrame de Pandas, listo para analizar o visualizar.

```python
# Patrón estándar: query en variable → leer con pd.read_sql
query_events = '''
SELECT *
FROM events
LIMIT 10;
'''

events = pd.read_sql(query_events, con=engine)
events.head()
```

**¿Por qué funciona así?**
- La query se guarda en una variable string (multilínea con `'''`) para que sea legible
- `pd.read_sql()` envía la query al servidor, ejecuta el SQL allá y devuelve solo el resultado
- El resultado es un DataFrame normal de Pandas — aplicas `.head()`, `.info()`, `.groupby()` como siempre

> [!TIP] SQL hace el trabajo pesado
> Deja que la base de datos filtre, agrupe y ordene. Solo trae a Python lo que necesitas. Si tienes 10 millones de filas, un `WHERE` en SQL es 100x más rápido que un `.query()` de Pandas sobre el DataFrame completo.

**Contexto real:** S12 — `events = pd.read_sql(query_events, con=engine)` para explorar la tabla de eventos de usuario.

---

### 🔢 Queries Avanzadas (CTEs, JOINs, CASE WHEN) {#queries-avanzadas}

**Cuándo:** Para análisis complejos como funnels de conversión o cohortes, donde la lógica SQL es extensa. El patrón es idéntico — solo cambia el contenido del string.

```python
# Query compleja con CTE — el patrón de pd.read_sql no cambia
query_funnel = '''
WITH funnel_counts AS (
    SELECT 
        nombre_evento,
        COUNT(DISTINCT id_usuario) AS total_usuarios
    FROM events
    WHERE nombre_evento IN ('first_visit', 'add_to_cart', 'purchase')
    GROUP BY nombre_evento
)
SELECT 
    nombre_evento,
    total_usuarios,
    LAG(total_usuarios) OVER (ORDER BY 
        CASE nombre_evento
            WHEN 'first_visit' THEN 1
            WHEN 'add_to_cart'  THEN 2
            WHEN 'purchase'     THEN 3
        END
    ) AS usuarios_paso_anterior
FROM funnel_counts
ORDER BY 2 DESC;
'''

funnel_data = pd.read_sql(query_funnel, con=engine)
funnel_data
```

> [!NOTE] Python + SQL — División de responsabilidades
> - **SQL** → filtrar, agrupar, ordenar, hacer JOINs (trabajo en el servidor)
> - **Python** → pivotar, calcular porcentajes, visualizar (trabajo en memoria local)
> Esta división es el estándar profesional: más rápido, más escalable y más fácil de depurar.

**Contexto real:** S12 — Funnel de conversión de MercadoLibre y análisis de cohortes de retención usando CTEs en SQL leídos con `pd.read_sql`.

---

## 📌 Sprints donde se usó Python + SQL

| Sprint | Proyecto | Uso específico |
|---|---|---|
| S12 | RappiPlus — Proyecto Final | Funnel de conversión, cohortes de retención, conexión a PostgreSQL en AWS |

---

## 🔗 Conexiones Estratégicas

- **Índice Maestro:** [[Indice_Maestro]]
- **Operaciones SQL:** [[SQL_Financiero_y_Metricas]] | [[Joins_y_Combinacion]]
- **Operaciones Python:** [[Carga_y_Exploracion]] | [[Transformacion_y_Feature_Engineering]]
- **Herramienta relacionada:** [[Pandas]] | [[SQL]]
