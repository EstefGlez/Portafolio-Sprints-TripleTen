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

- **Índice Maestro:** [[Indice_Maestro]]

- **Herramienta completa:** [[Google_Sheets]]
- **Operación previa:** [[Limpieza_y_Normalizacion]]
- **Proyecto de referencia:** Sprint 1 — Top Ciudad: Monterrey `$541,137.36` | Top Producto: Tablet `672 unidades`

---

## 🏆 Producto Más Vendido por Volumen de Unidades {#top-producto-volumen}

**Herramienta:** Pandas
**Cuándo:** Para identificar el producto estrella por unidades físicas vendidas (no por frecuencia de aparición en pedidos). Útil para decisiones de inventario y producción.

```python
# Top productos por volumen total de unidades
top_productos = (
    orders.groupby('nombre_producto')['cantidad']
    .sum()
    .sort_values(ascending=False)
    .reset_index()
)
top_productos.columns = ['nombre_producto', 'unidades_vendidas']

print("Top 5 productos por volumen de unidades:")
print(top_productos.head(5))

# Solo el #1
producto_estrella = top_productos.iloc[0]['nombre_producto']
unidades_estrella = top_productos.iloc[0]['unidades_vendidas']
print(f"\nProducto estrella: {producto_estrella} ({unidades_estrella:,.0f} unidades)")
```

**Diferencia con `value_counts()`:**

| Método | Qué mide | Cuándo usarlo |
|---|---|---|
| `value_counts()` | Frecuencia de aparición en pedidos | Marketing — ¿qué producto atrae más clientes? |
| `groupby().sum().sort_values()` | Unidades físicas totales vendidas | Inventario — ¿qué producto mueve más stock? |

**Contexto real:** S12 RappiPlus — `Laptop-gaming-16gb` resultó ser el producto estrella con una diferencia enorme en unidades vs. los demás productos.

---

## 📊 Resumen Ejecutivo Multi-KPI con Print Formateado {#resumen-ejecutivo}

**Herramienta:** Pandas
**Cuándo:** Para imprimir un bloque de KPIs financieros de forma limpia y profesional al final de la sección de análisis, antes de pasar a visualizaciones.

```python
# Bloque de resumen ejecutivo
print("=" * 50)
print("   RESUMEN EJECUTIVO — KPIs FINANCIEROS")
print("=" * 50)
print(f"  Revenue total:              ${revenue:>15,.2f}")
print(f"  Costo total productos:      ${costo_total_prod:>15,.2f}")
print(f"  Inversión marketing:        ${inversion_marketing:>15,.2f}")
print(f"  Profit:                     ${profit:>15,.2f}")
print(f"  ROI:                        {roi:>14.2f}%")
print("-" * 50)
print(f"  Ticket promedio por orden:  ${ticket_promedio:>15,.2f}")
print(f"  Und. promedio por orden:    {promedio_productos:>15.2f}")
print(f"  Producto estrella:          {producto_estrella}")
print("=" * 50)
```

> [!TIP] Alineación con `>` en f-strings
> El especificador `>15` alinea el valor a la derecha en un campo de 15 caracteres. Hace que los números queden en columna y el reporte sea mucho más legible.

**Contexto real:** S12 RappiPlus — bloque de resumen al final de la sección de KPIs antes de pasar al análisis SQL.
