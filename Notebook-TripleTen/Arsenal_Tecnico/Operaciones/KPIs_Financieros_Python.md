---
tags: [operacion, pandas, kpis, merge, profit, roi, sprint-12]
tipo: nota-operacion
herramientas: [pandas]
---

# 💹 KPIs Financieros — Merge Seguro y Cálculo de Profit/ROI

Operaciones para calcular métricas financieras clave (Revenue, Profit, ROI, Ticket Promedio) cuando los datos están distribuidos en múltiples tablas que deben cruzarse. Parte del pipeline de análisis del S12.

---

## 📋 Índice de Operaciones

| Operación | Ir a |
|---|---|
| Merge seguro sin columnas duplicadas | [[#merge-seguro]] |
| Calcular Revenue (Ingreso Bruto) | [[#revenue]] |
| Calcular Profit (Utilidad Neta) | [[#profit]] |
| Calcular ROI | [[#roi]] |
| Ticket Promedio por Orden | [[#ticket]] |
| Cantidad Promedio de Productos por Orden | [[#cantidad-promedio]] |
| Producto más vendido | [[#top-producto]] |
| Gasto por canal de marketing | [[#gasto-canal]] |

---

## 🔀 Merge Seguro Sin Columnas Duplicadas {#merge-seguro}

**Cuándo:** Al cruzar una tabla de hechos con un catálogo que comparte nombres de columnas. Sin este patrón, Pandas crea columnas `_x` y `_y` que rompen el código posterior.

```python
# ✅ Patrón profesional: traer SOLO las columnas que no existen ya en orders
cols_to_use = catalog.columns.difference(orders.columns).tolist() + ['nombre_producto']
orders = pd.merge(orders, catalog[cols_to_use], on='nombre_producto', how='left')
```

**¿Por qué funciona?**
- `catalog.columns.difference(orders.columns)` — devuelve solo las columnas de catalog que NO están en orders
- Al agregar la llave de cruce (`nombre_producto`) manualmente, garantizas que el merge tenga su columna de unión
- Resultado: cero columnas `_x` o `_y`, cero confusión

> [!IMPORTANT] Normalizar la llave de cruce ANTES del merge
> Si los nombres de productos tienen diferencias de capitalización, el merge devuelve 0 coincidencias.
> ```python
> orders['nombre_producto']  = orders['nombre_producto'].str.lower().str.strip()
> catalog['nombre_producto'] = catalog['nombre_producto'].str.lower().str.strip()
> ```
> Aplicar `.str.lower().str.strip()` en ambas tablas antes del `pd.merge()`.

> [!WARNING] El "Merge Hell"
> Si ejecutas el merge más de una vez sin reiniciar el DataFrame, acumulas columnas `_x`, `_y`, `_x_x`... La solución es recargar el CSV original (`pd.read_csv()`) y aplicar toda la limpieza desde cero en orden.

**Contexto real:** S12 — cruce de `orders_clean` con `catalog_clean` usando `nombre_producto` como llave. Sin este patrón, el merge fallaba con 0 coincidencias por diferencias de capitalización.

---

## 💰 Revenue (Ingreso Bruto) {#revenue}

**Cuándo:** Primera métrica financiera de cualquier análisis. Es la suma total del dinero que entró por ventas, sin descontar costos.

```python
# Revenue = suma de todos los montos de venta
revenue = orders['monto_total'].sum()
print(f"Revenue: ${revenue:,.2f}")
```

> [!NOTE] Revenue vs. Profit
> `Revenue` = dinero que entró (bruto). `Profit` = lo que queda después de costos y marketing. Para un director, el Revenue dice "cuánto vendimos"; el Profit dice "cuánto ganamos".

**Contexto real:** S12 — `orders['monto_total'].sum()` sobre `orders_clean` post-limpieza.

---

## 📊 Profit (Utilidad Neta) {#profit}

**Cuándo:** Para saber si el negocio es realmente rentable, descontando tanto el costo de los productos (COGS) como la inversión en marketing.

```python
# Paso 1: calcular el costo total de cada línea de venta
orders['costo_total'] = (orders['cantidad'] * orders['costo_unitario']).fillna(0)

# Paso 2: sumar las tres variables
revenue             = orders['monto_total'].sum()
costo_total_prod    = orders['costo_total'].sum()
inversion_marketing = marketing['gasto'].sum()

# Paso 3: Profit
profit = revenue - costo_total_prod - inversion_marketing

print(f"Revenue:             ${revenue:,.2f}")
print(f"Costo de productos:  ${costo_total_prod:,.2f}")
print(f"Inversión marketing: ${inversion_marketing:,.2f}")
print("-" * 40)
print(f"Profit:              ${profit:,.2f}")
```

**Fórmula:**
$$\text{Profit} = \text{Revenue} - \text{COGS} - \text{Gasto Marketing}$$

> [!IMPORTANT] `.fillna(0)` en costo_total
> Si algún producto no hizo match en el merge con el catálogo, `costo_unitario` será `NaN`. Al multiplicar por `cantidad`, el resultado es `NaN`, que contamina la suma total. Siempre aplicar `.fillna(0)` al crear la columna `costo_total`.

> [!TIP] Verificar el nombre de la columna de gasto
> El nombre de la columna de inversión en marketing puede variar (`gasto`, `monto_inversion`, `spend`). Verificar con `marketing.columns` antes de usarla.

**Contexto real:** S12 — Profit de RappiPlus calculado cruzando `orders_clean` (revenue + costo via catálogo) con `marketing_clean` (gasto por canal).

---

## 📈 ROI (Retorno sobre Inversión en Marketing) {#roi}

**Cuándo:** Para evaluar si la inversión en marketing fue eficiente — cuántos pesos de ganancia se obtuvieron por cada peso invertido en publicidad.

$$\text{ROI \%} = \frac{\text{Profit}}{\text{Inversión en Marketing}} \times 100$$

```python
roi = (profit / inversion_marketing) * 100
print(f"ROI: {roi:.2f}%")
```

> [!NOTE] Interpretación del ROI
> - **ROI > 100%** → Por cada peso invertido en marketing, se ganó más de un peso. El negocio es eficiente.
> - **ROI < 100%** → La inversión en marketing no se está recuperando completamente.
> - **ROI negativo** → El negocio está perdiendo dinero.

**Contexto real:** S12 — KPI de eficiencia de marketing del dashboard de RappiPlus.

---

## 🎫 Ticket Promedio por Orden {#ticket}

**Cuándo:** Para saber cuánto gasta en promedio un cliente por cada transacción. Métrica clave para estrategias de cross-selling y up-selling.

```python
# Agrupar por ID de orden para sumar el monto de cada pedido completo
ticket_por_orden = orders.groupby('id_pedido')['monto_total'].sum()
ticket_promedio  = ticket_por_orden.mean()

print(f"Ticket promedio por orden: ${ticket_promedio:,.2f}")
```

> [!WARNING] No usar `.mean()` directo sobre la columna
> `orders['monto_total'].mean()` calcula el promedio por **línea de producto**, no por **orden**. Si una orden tiene 3 productos, cuenta 3 veces y el promedio sale artificialmente bajo. Siempre agrupar por `id_pedido` primero.

**Contexto real:** S12 — Ticket promedio de RappiPlus calculado sobre `orders_clean` agrupando por `id_pedido`.

---

## 📦 Cantidad Promedio de Productos por Orden {#cantidad-promedio}

**Cuándo:** Para medir el UPT (Units Per Transaction) — cuántas unidades lleva en promedio cada cliente por compra. Métrica de cross-selling.

```python
# 1. Sumar la cantidad total de unidades por pedido
productos_por_orden = orders.groupby('id_pedido')['cantidad'].sum()

# 2. Promediar entre todos los pedidos
promedio_productos = productos_por_orden.mean()

print(f"Cantidad promedio de productos por orden: {promedio_productos:.2f}")
```

**Contexto real:** S12 — UPT de RappiPlus para análisis de comportamiento de compra.

---

## 🏆 Producto Más Vendido {#top-producto}

**Cuándo:** Para identificar el "producto estrella" del catálogo por frecuencia de aparición en pedidos.

```python
# Por frecuencia (cuántas veces aparece en pedidos)
producto_mas_frecuente = orders['nombre_producto'].value_counts()
print("Top 5 productos por frecuencia:")
print(producto_mas_frecuente.head(5))

# Solo el #1
print(f"\nProducto estrella: {orders['nombre_producto'].value_counts().idxmax()}")
```

> [!NOTE] Frecuencia vs. Volumen
> - `value_counts()` → cuántos pedidos incluyen ese producto (frecuencia)
> - `groupby('nombre_producto')['cantidad'].sum()` → cuántas unidades se vendieron en total (volumen)
> Para decisiones de inventario usar volumen; para marketing usar frecuencia.

**Contexto real:** S12 — `Laptop-gaming-16gb` resultó ser el producto estrella de RappiPlus con diferencia.

---

## 📣 Gasto en Marketing por Canal {#gasto-canal}

**Cuándo:** Para identificar en qué canales se está invirtiendo más y si esa inversión está generando retorno.

```python
# Gasto total agrupado por canal de adquisición
gasto_por_canal = marketing.groupby('canal')['gasto'].sum()
print("Gasto en marketing por canal:")
print(gasto_por_canal)
```

**Contexto real:** S12 — desglose del gasto de RappiPlus entre canales (Email, Social, Search, etc.).

---

## 🔗 Conexiones Estratégicas

- **Índice Maestro:** [[Indice_Maestro]]
- **Herramientas:** [[Pandas]] | [[Python_SQL]]
- **Operación previa:** [[Limpieza_y_Normalizacion]] | [[Joins_y_Combinacion]]
- **Sprint de referencia:** S12 — Proyecto Final RappiPlus
