---
tags: [operacion, agregacion, reportes, google-sheets, sql]
tipo: nota-operacion
herramientas: [google-sheets, sql]
---

# 📈 Agregación y Reportes de Datos

Operaciones para resumir, agrupar y extraer métricas clave de un dataset limpio. Este es normalmente el **segundo paso** del pipeline, después de limpiar los datos.

---

## 📋 Índice de Operaciones

| Operación | Herramienta | Ir a |
|---|---|---|
| Consultas dinámicas con agrupación | Google Sheets (QUERY) | [[#query-sheets]] |
| Segmentar texto compuesto en columnas | Google Sheets | [[#split-texto]] |
| Calcular KPIs de negocio | Google Sheets | [[#kpis-sheets]] |

---

## 🔎 Consultas Dinámicas con Motor QUERY {#query-sheets}

**Herramienta:** Google Sheets
**Cuándo usarlo:** Cuando necesitas generar un reporte resumido o un KPI específico de forma dinámica, sin construir tablas dinámicas manuales. Equivale a escribir SQL directamente dentro de Sheets.
**Contexto real:** Sprint 1 — se usó para obtener ventas promedio por ciudad y por categoría de producto desde la pestaña `Datos_Limpios`.

```excel
=QUERY(Datos_Limpios!A1:I754, "SELECT B, SUM(F) WHERE B IS NOT NULL GROUP BY B ORDER BY SUM(F) DESC LABEL SUM(F) 'Ventas Totales'", 1)
```

**Anatomía del comando:**

| Parte | Qué hace |
|---|---|
| `Datos_Limpios!A1:I754` | Rango fuente: pestaña + rango completo incluyendo encabezado |
| `SELECT B, SUM(F)` | Columnas a mostrar: `B` = Ciudad, `F` = Monto Total |
| `WHERE B IS NOT NULL` | Filtra filas vacías en la columna de agrupación |
| `GROUP BY B` | Agrupa los resultados por ciudad única |
| `ORDER BY SUM(F) DESC` | Ordena de mayor a menor venta |
| `LABEL SUM(F) 'Ventas Totales'` | Renombra el encabezado de la columna calculada |
| `1` | Indica que la primera fila del rango es encabezado |

**Funciones de agregación disponibles en QUERY:**

```excel
SUM(col)    ; Suma total
AVG(col)    ; Promedio
COUNT(col)  ; Conteo de registros
MAX(col)    ; Valor máximo
MIN(col)    ; Valor mínimo
```

> [!TIP] Cuándo QUERY supera a las tablas dinámicas
> Cuando necesitas que el reporte se **actualice automáticamente** al agregar filas al dataset fuente, o cuando quieres encadenar múltiples filtros y ordenamientos en una sola fórmula sin clicks manuales.

---

## ✂️ Segmentar Texto Compuesto en Columnas {#split-texto}

**Herramienta:** Google Sheets
**Cuándo usarlo:** Cuando una sola columna contiene múltiples variables concatenadas con un separador (guión, coma, barra). Descomponerla permite filtrar y agrupar por cada atributo independientemente.
**Contexto real:** Sprint 1 — columna `Producto` contenía valores como `Tablet-Estándar-8GB`. Se separó en `Categoría`, `Tipo` y `Especificaciones`.

**Método 1 — Fórmula SPLIT:**
```excel
=SPLIT(A2, "-")
```
Genera automáticamente columnas adyacentes con cada fragmento.

**Método 2 — Menú (sin fórmula):**
`Datos > Dividir texto en columnas` → seleccionar separador `-`

> [!NOTE] Diferencia clave entre métodos
> `SPLIT()` es dinámico (se actualiza si cambia el dato fuente). El menú es estático (opera una sola vez). Para datos que no cambiarán, el menú es más rápido.

---

## 📊 Calcular KPIs de Negocio {#kpis-sheets}

**Herramienta:** Google Sheets
**Cuándo usarlo:** Para construir el resumen ejecutivo del análisis con métricas accionables para el negocio.

### Ticket Promedio (Venta Promedio por Transacción)

$$\text{Ticket Promedio} = \frac{\sum \text{Monto Total de Ventas}}{\text{Número Total de Transacciones}}$$

```excel
=SUM(F2:F754)/COUNTA(A2:A754)
```

**Contexto real:** Sprint 1 → Ticket Promedio = `$3,910.52`

---

### Participación de Categoría (% del Total)

```excel
=SUMIF(categorias, "Tablet", montos) / SUM(montos)
```
Formato de la celda: `0.00%`

---

### Variación Mensual (Δ%)

$$\Delta\% = \frac{\text{Mes Actual} - \text{Mes Anterior}}{\text{Mes Anterior}}$$

```excel
=(C3-C2)/C2
```
Formato de la celda: `0.0%`

**Contexto real:** Sprint 1 — Octubre a Diciembre mostró una contracción del `-8.9%`, indicando estacionalidad de fin de año.

---

## 🔗 Conexiones Estratégicas

- **Herramienta completa:** [[Google_Sheets]]
- **Operación previa:** [[Limpieza_y_Normalizacion]]
- **Proyecto de referencia:** Sprint 1 — Top Ciudad: Monterrey `$541,137.36` | Top Producto: Tablet `672 unidades`
