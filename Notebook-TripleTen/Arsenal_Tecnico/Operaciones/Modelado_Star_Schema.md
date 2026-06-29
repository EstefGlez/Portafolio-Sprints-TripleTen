---
tags: [concepto, star-schema, modelado, power-bi, bi, sprint-11]
tipo: nota-concepto
herramientas: [power-bi]
---

# ⭐ Star Schema — Modelado Relacional para BI

Arquitectura de diseño de modelos de datos optimizada para Business Intelligence. Es el estándar de la industria para construir modelos en Power BI, Tableau y cualquier herramienta de BI.

---

## 🏗️ Arquitectura del Modelo

```
         dim_clientes
              │
              │ (1)
              ▼
dim_fecha ──(*) hecho_ventas_propiedades (*) ── dim_propiedades
              ▲
              │ (1)
              │
         dim_ubicacion
```

**Regla fundamental:** El filtro siempre viaja desde la dimensión `(1)` hacia los hechos `(*)`, nunca al revés.

---

## 📋 Componentes del Modelo

### 🎯 Tabla de Hechos (Fact Table)
**Qué es:** Tabla central que registra los eventos cuantitativos del negocio.

**Características:**
- Es la tabla más grande del modelo (millones de filas)
- Contiene métricas numéricas (ingresos, cantidades, costos)
- Responde a "¿qué pasó y cuánto?"
- Contiene llaves foráneas (FK) para conectarse con cada dimensión

**Ejemplo S11:** `hecho_ventas_propiedades`
```
id_venta | fecha_venta | id_cliente | id_propiedad | precio_venta | monto_comision | canal_venta
```

---

### 📚 Tablas de Dimensiones (Dimension Tables)
**Qué es:** Tablas que contienen los atributos cualitativos que dan contexto a los números.

**Características:**
- Son catálogos o tablas maestras
- Contienen una clave primaria (PK) única — sin duplicados
- Responden a "¿quién?, ¿qué?, ¿dónde?, ¿cuándo?"
- Son las que reciben los filtros del usuario (slicers)

**Ejemplos S11:**

| Dimensión | Clave primaria | Atributos |
|---|---|---|
| `dim_clientes` | `id_cliente` | nombre, segmento_comprador |
| `dim_propiedades` | `id_propiedad` | tipo_propiedad, superficie |
| `dim_fecha` | `Date` | Año, Mes, Año-Mes |

---

## ⚠️ Errores Críticos de Modelado

### Relación Muchos a Muchos (M:M) — Señal de Alerta
**Qué significa:** Power BI sugiere una relación M:M cuando detecta duplicados en la columna que debería ser clave primaria de una dimensión.

**Causas:**
- Duplicados en `id_cliente` de `dim_clientes`
- Valores nulos en `id_producto` de la tabla de hechos
- Datos crudos sin limpiar usados directamente como dimensión

**Consecuencia:** Rompe la integridad del modelo — los filtros se comportan de forma impredecible y las métricas se pueden duplicar.

> [!WARNING] Regla de oro
> Antes de aceptar una relación M:M que Power BI sugiere, siempre investigar primero si hay un problema de calidad de datos. El M:M casi nunca es la solución — es la señal del problema.

**Ejemplo real S11:** 5 valores vacíos en `id_producto` generaron alerta de M:M → solución: limpiar nulos antes de cargar al modelo.

---

### Claves Primarias vs. Foráneas

| Tipo | Dónde vive | Característica |
|---|---|---|
| **PK (Primary Key)** | Tabla de dimensión | Única, sin duplicados, sin nulos |
| **FK (Foreign Key)** | Tabla de hechos | Referencia a la PK de la dimensión |

```
dim_clientes[id_cliente] (PK) ←── hecho_ventas[id_cliente] (FK)
         (1)                                  (*)
```

---

## 🔄 Flujo de Construcción del Modelo en Power BI

```
1. Cargar datos fuente (Power Query)
        ↓
2. Limpiar y verificar calidad
   - Sin duplicados en PKs de dimensiones
   - Sin nulos en FKs de hechos
        ↓
3. Crear tabla calendario (dim_fecha con CALENDAR + ADDCOLUMNS)
        ↓
4. Definir relaciones en vista de Modelo
   - Siempre 1 (dimensión) → * (hechos)
        ↓
5. Crear medidas DAX
   - Primero medidas base (SUM, COUNT, DIVIDE)
   - Luego medidas avanzadas (CALCULATE, ALL, YTD)
        ↓
6. Construir visualizaciones
```

---

## 💡 Analogía con SQL

| Concepto BI | Equivalente SQL |
|---|---|
| Tabla de hechos | Tabla transaccional principal |
| Tabla de dimensión | Tabla de catálogo / lookup |
| Relación 1:* | LEFT JOIN con llave única |
| Medida DAX | Query con GROUP BY + agregación |
| Contexto de filtro | WHERE clause dinámica |
| CALCULATE + ALL | SUM() OVER() (función de ventana) |

---

## 🔗 Conexiones Estratégicas

- **Índice Maestro:** [[Indice_Maestro]]
- **Herramienta:** [[Power_BI]]
- **DAX aplicado:** [[DAX_Modelado_PowerBI]]
- **Sprint de referencia:** S11 — Modelo estrella de ventas inmobiliarias
