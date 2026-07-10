---
tags: [operacion, power-bi, visualizacion, dashboard, ux, sprint-11]
tipo: nota-operacion
herramientas: [power-bi]
---

# 🎨 Power BI — Visualizaciones y Diseño Avanzado de Dashboards

Técnicas avanzadas de visualización, diseño UI/UX y configuración de reportes ejecutivos interactivos en Power BI. Basado en el Sprint 11 — Proyecto Inmobiliario Grupo Andes.

---

## 📋 Índice de Operaciones

| Operación | Ir a |
|---|---|
| Sistema de navegación con botones | [[#navegacion]] |
| Gráfico de eje dual (barras + línea) | [[#eje-dual]] |
| Línea de tendencia + bandas de confianza | [[#tendencia]] |
| Líneas de referencia semáforo | [[#semaforo]] |
| Formato condicional en tablas | [[#formato-condicional]] |
| Tooltips de participación | [[#tooltips]] |
| Formato de unidades ejecutivo | [[#unidades]] |
| Matriz de cohortes con mapa de calor | [[#matriz-cohortes]] |
| Limpieza de datos en Power Query | [[#power-query]] |

---

## 🧭 Sistema de Navegación con Botones {#navegacion}

**Cuándo:** Para dashboards de más de una página — permite al usuario navegar entre vistas sin usar las pestañas de la parte inferior.

**Configuración:**
1. Insertar → Botones → Botón en blanco
2. En el panel de formato del botón → Acción → Tipo: **Navegación de páginas** → Destino: página correspondiente
3. Duplicar el botón para cada página del reporte

**UI/UX — Estado activo vs. inactivo:**
- Botón de la página actual → fondo gris oscuro (estado activo)
- Botones de otras páginas → fondo blanco (estado inactivo)
- Mantener consistencia milimétrica de posición entre todas las páginas

**Contexto real:** S11 — botonera con 3 estados: `Overview Ejecutivo` / `Análisis Comercial` / `Análisis de Cohortes`.

---

## 📊 Gráfico de Eje Dual (Barras + Línea) {#eje-dual}

**Cuándo:** Para comparar una métrica volumétrica absoluta (barras) contra una métrica de rendimiento relativo (línea) en el mismo espacio temporal. Evita duplicar visuales.

**Caso de uso S11:** Ingreso Total (barras, eje Y izquierdo) + Crecimiento % YoY (línea, eje Y derecho) por Año-Mes.

**Configuración:**
1. Insertar visual de **Gráfico de líneas y columnas agrupadas**
2. Eje X → `dim_fecha[Año-Mes]`
3. Columnas → `[Ingreso Total]`
4. Líneas → `[Crecimiento YoY]`
5. En formato → activar **Eje Y secundario** para la serie de líneas
6. Formatear etiquetas de ambas series por separado para evitar solapamiento

> [!TIP] Cuándo usar eje dual vs. dos gráficos separados
> Eje dual cuando las métricas comparten el mismo eje X temporal y se quiere mostrar la relación causa-efecto. Dos gráficos separados cuando las escalas son muy distintas y generan confusión visual.

**Contexto real:** S11 — visual "Ingreso Total y Crecimiento % YoY por Año-Mes" en Overview Ejecutivo.

---

## 📈 Línea de Tendencia + Bandas de Confianza {#tendencia}

**Cuándo:** Para suavizar la estacionalidad mensual e identificar la dirección macro del negocio eliminando el ruido de variaciones puntuales.

**Configuración (Panel de Análisis):**
1. Seleccionar el visual de gráfico de líneas
2. Ir al panel de **Análisis** (ícono de lupa con líneas, debajo del panel de Formato)
3. Expandir **Línea de tendencia** → Activar toggle
4. Expandir **Banda de confianza** → Activar toggle → ajustar opacidad del área sombreada

**Qué muestra:**
- **Línea de tendencia** → dirección macro del negocio (crecimiento, caída o estabilidad)
- **Banda de confianza (área gris)** → margen de variabilidad estadística esperada — si los datos reales salen de la banda, es una señal de anomalía

**Contexto real:** S11 — "Cantidad de Ventas por Año y Mes" con línea de tendencia creciente y bandas de confianza visibles.

---

## 🚦 Líneas de Referencia Semáforo {#semaforo}

**Cuándo:** Para mostrar umbrales de rendimiento (metas) como benchmarks visuales en un gráfico temporal. El usuario puede ver de un vistazo si cada período cumplió, estuvo en precaución o falló.

**Configuración:**
1. Seleccionar el visual
2. Panel de **Análisis** → **Línea constante** → Agregar línea
3. Valor → ingresar el umbral numérico (ej. 400 para meta óptima)
4. Color → Verde (óptimo) / Amarillo (precaución) / Rojo (mínimo operativo)
5. Estilo de línea → Punteado
6. Repetir para cada umbral

**Lógica del semáforo:**
```
Verde  (línea superior) → Meta óptima — por encima = excelente
Amarillo (línea media)  → Zona de precaución
Rojo   (línea inferior) → Mínimo operativo — por debajo = alerta
```

**Contexto real:** S11 — tres líneas de referencia punteadas en "Cantidad de Ventas por Año y Mes" para evaluación rápida del director comercial.

---

## 🎨 Formato Condicional en Tablas {#formato-condicional}

**Cuándo:** Para convertir una tabla de datos numéricos en un visual híbrido que combina el dato exacto con una representación gráfica proporcional — acelera la lectura sin perder detalle.

**Barras de datos en celdas:**
1. Seleccionar el visual de **Tabla** o **Matriz**
2. En el panel de Formato → buscar el campo numérico → **Formato condicional** → **Barras de datos**
3. Configurar color de las barras y valor mínimo/máximo

**Escala de color (mapa de calor):**
1. Panel de Formato → campo numérico → **Formato condicional** → **Color de fondo**
2. Seleccionar escala de colores (ej. verde alto → rojo bajo para retención)
3. Configurar valores mínimo, medio y máximo de la escala

**Contexto real S11:**
- Tabla de tipo_propiedad con barras de datos en columna de Ingreso Total (Análisis Comercial)
- Matriz de cohortes con escala de color semáforo para visualizar retención (Análisis de Cohortes)

---

## 💬 Tooltips de Participación {#tooltips}

**Cuándo:** Para enriquecer un gráfico de barras con información adicional (como el % de participación) sin saturar el diseño del visual — la información aparece solo al pasar el cursor.

**Configuración:**
1. Crear las medidas de participación con `CALCULATE + ALL + DIVIDE`
2. Seleccionar el gráfico de barras
3. En el panel de campos → cajón **Información sobre herramientas**
4. Arrastrar la medida de participación correspondiente a ese cajón

**Resultado:** Al pasar el cursor sobre una barra, el tooltip flotante muestra tanto el valor absoluto como el porcentaje de participación.

**Contexto real:** S11 — tooltips de participación en gráficos de `tipo_propiedad`, `segmento_comprador` y `canal_venta`.

---

## 🔢 Formato de Unidades Ejecutivo {#unidades}

**Cuándo:** Cuando los valores numéricos tienen más de 9 dígitos — los números largos saturan visualmente las tarjetas KPI y las etiquetas de gráficos.

**Configuración:**
1. Seleccionar el visual (tarjeta o gráfico)
2. Panel de Formato → campo numérico → **Mostrar unidades**
3. Seleccionar: **Millones (M)** para cifras en rango de millones

**Resultado:** `$6,012,500,000` → `$6,012.50 mill.` → `$6.01 mil M`

> [!NOTE] Cuándo usar cada unidad
> Millones (M) → ingresos totales, presupuestos
> Miles (K) → cantidades de unidades, transacciones
> Ninguna → valores donde el decimal importa (ticket promedio, tasas)

**Contexto real:** S11 — Ingreso Total abreviado a `$6.01 mil M` en tarjetas KPI del Overview Ejecutivo.

---

## 🔁 Matriz de Cohortes con Mapa de Calor {#matriz-cohortes}

**Cuándo:** Para analizar el comportamiento de recompra de clientes a lo largo del tiempo — identifica qué cohortes retienen mejor y en qué momento se produce el abandono.

**Configuración del visual:**
1. Insertar → Visual: **Matriz**
2. Filas → `hecho_ventas_propiedades[Mes Cohorte]`
3. Columnas → `hecho_ventas_propiedades[Mes Venta]`
4. Valores → `[Cantidad de Ventas]`
5. Formato condicional → Color de fondo → escala semáforo

**Cómo leer la matriz:**
```
           2023-01  2023-02  2023-03  ...
2023-01  [  224  ] [  13  ] [  35  ]      ← cohorte enero 2023
2023-02           [  234  ] [  26  ]      ← cohorte febrero 2023
2023-03                    [  373  ]      ← cohorte marzo 2023
```
- **Diagonal** → primera compra de cada cohorte (valor más alto)
- **Hacia la derecha** → recompras en meses posteriores
- **Color verde** → alta retención / **Rojo** → caída de retención
- **Triángulo vacío** → un cliente no puede comprar antes de su primera compra

**Hallazgo S11:** Cohortes de inicios 2023 mostraron zonas naranja/amarillo (mayor salud). Cohortes 2024 mostraron caída acelerada al rojo — señal de alerta para estrategia de retención.

---

## 🧹 Limpieza de Datos en Power Query {#power-query}

**Cuándo:** Antes de cargar los datos al modelo — errores de codificación de caracteres especiales (tildes, ñ) que llegan rotos desde el origen.

**Problema:** Archivos CSV con codificación incorrecta generan caracteres corruptos:
```
BogotÃ¡        → Bogotá
Ciudad de MÃ©xico → Ciudad de México
UsaquÃ©n       → Usaquén
ChicÃ³         → Chicó
CoyoacÃ¡n      → Coyoacán
Santa BÃ¡rbara  → Santa Bárbara
San Ãngel      → San Ángel
```

**Solución en Power Query:**
1. Seleccionar la columna afectada
2. Clic derecho → **Reemplazar los valores...**
3. Valor a buscar: texto corrupto (ej. `BogotÃ¡`)
4. Reemplazar por: texto correcto (ej. `Bogotá`)
5. Repetir para cada valor corrupto

**Otro problema común — encabezados en primera fila:**
Cuando los nombres de columnas (`id_cliente`, `ciudad`) aparecen como datos en la fila 1 y las columnas se llaman `Column1`, `Column2`:
- Inicio → **Usar la primera fila como encabezado**
- Verificar que los tipos de dato se asignen correctamente después

> [!IMPORTANT] Power Query vs. DAX — dónde hacer cada cosa
> Power Query (lenguaje M) → transformaciones de origen: tipos, reemplazos, encabezados
> DAX → cálculos del modelo: medidas, columnas calculadas, inteligencia de tiempo
> Las columnas calculadas en DAX NO aparecen en Power Query — son capas diferentes

**Contexto real:** S11 — limpieza de columnas `ciudad` y `barrio` en `dim_propiedades` y `dim_clientes` antes de construir el modelo estrella.

---

## 🔗 Conexiones Estratégicas

- **Índice Maestro:** [[Indice_Maestro]]
- **Herramienta:** [[Power_BI]]
- **DAX utilizado:** [[DAX_Modelado_PowerBI]]
- **Modelo base:** [[Modelado_Star_Schema]]
- **Sprint de referencia:** S11 — Ventas de propiedades inmobiliarias (Grupo Andes)

---

## 🔌 Conexión Python → Power BI (Flujo de datos) {#python-to-pbi}

**Cuándo:** Cuando limpias datos en Python y necesitas cargarlos a Power BI para construir el dashboard.

```python
# Exportar DataFrames limpios desde Python
orders.to_csv('orders_clean.csv',    index=False)
catalog.to_csv('catalog_clean.csv',  index=False)
marketing.to_csv('marketing_clean.csv', index=False)
```

Luego en Power BI: **Obtener datos > Texto/CSV** → cargar los `_clean.csv`.

> [!IMPORTANT] Normalizar llaves de cruce ANTES de exportar
> Si exportas con diferencias de capitalización en `nombre_producto`, Power BI tendrá los mismos problemas de M:M que tuviste en Python. Aplicar `.str.lower().str.strip()` antes del `.to_csv()`.

**Contexto real:** S12 — Pipeline completo: Python (limpieza) → CSV → Power BI (modelado y visualización).

---

## ⚠️ Solución al Error M:M (Muchos a Muchos) {#error-mm}

**Cuándo:** Power BI sugiere una relación M:M al intentar conectar dos tablas.

**Causas más comunes:**
1. Columnas de fecha con tipos distintos (`Date` vs `DateTime`) entre tablas
2. Duplicados en la columna que debería ser clave primaria de la dimensión
3. Intentar relacionar dos tablas de hechos directamente sin pasar por una dimensión

**Solución estándar — crear `dim_fecha` como hub:**
```dax
dim_fecha = 
VAR BaseCalendar = 
    CALENDAR(
        MIN(MIN(orders_clean[fecha_hora_pedido]), MIN(marketing_clean[fecha])),
        MAX(MAX(orders_clean[fecha_hora_pedido]), MAX(marketing_clean[fecha]))
    )
RETURN
    ADDCOLUMNS(
        BaseCalendar,
        "Año",           YEAR([Date]),
        "Mes",           FORMAT([Date], "MMMM"),
        "Mes Número",    MONTH([Date]),
        "Año-Mes",       FORMAT([Date], "YYYY-MM"),
        "Trimestre",     "Q" & FORMAT([Date], "Q")
    )
```

Luego crear dos relaciones `1:*`:
- `dim_fecha[Date]` → `orders_clean[fecha_hora_pedido]`
- `dim_fecha[Date]` → `marketing_clean[fecha]`

> [!NOTE] Nunca relacionar dos tablas de hechos directamente
> `orders_clean` y `marketing_clean` son ambas tablas de hechos. Relacionarlas directamente siempre da M:M. La `dim_fecha` actúa como "hub" que las conecta indirectamente.

**Contexto real:** S12 — Error M:M al intentar relacionar `orders_clean` con `marketing_clean` por fecha. Se resolvió creando `dim_fecha` como dimensión central.

---

## 📌 Sprints donde se usaron estas visualizaciones avanzadas

| Sprint | Proyecto | Técnicas aplicadas |
|---|---|---|
| S10 | Andes Retail Group | Eje dual, semáforo, tooltips, navegación, formato condicional |
| S11 | Ventas inmobiliarias | Drill-through, cohortes, matriz de retención |
| S12 | RappiPlus | Conexión Python→PBI, solución M:M, SUMX+RELATED, drill-through |
