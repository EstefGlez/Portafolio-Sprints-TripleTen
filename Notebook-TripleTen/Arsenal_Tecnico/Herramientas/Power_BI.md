---
tags: [herramienta, power-bi, bi, dashboards, dax, power-query, indice]
tipo: indice-herramienta
---

# 📊 Power BI — Índice de Capacidades

Referencia rápida de conceptos, patrones y técnicas de Power BI aplicados en el bootcamp. Basado en el Sprint 10 — Andes Retail Group.

---

## 🗂️ Capacidades por Categoría

### 🔄 Power Query (ETL Visual)
| Qué hace | Técnica | Nota |
|---|---|---|
| Normalizar formato de fechas | Cambiar tipo → Fecha (idioma ES-LATAM) | [[Power_BI_S10#power-query]] |
| Corregir tipos de datos numéricos | Cambiar tipo → Número decimal / entero | [[Power_BI_S10#power-query]] |
| Crear columna condicional | Columna condicional visual (sin DAX) | [[Power_BI_S10#nivel-venta]] |
| Validar calidad del dataset | Vista Perfil de Columna | [[Power_BI_S10#power-query]] |

### 📐 Métricas y KPIs (DAX básico)
| Qué hace | Patrón | Nota |
|---|---|---|
| Suma total de ingresos | `SUM(tabla[Ingresos])` | [[Power_BI_S10#kpis]] |
| Ganancia neta | `SUM(Ingresos) - SUM(Costos)` | [[Power_BI_S10#kpis]] |
| Conteo de unidades vendidas | `SUM(tabla[Unidades_Vendidas])` | [[Power_BI_S10#kpis]] |
| Conteo único de clientes | `DISTINCTCOUNT(tabla[ID_Cliente])` | [[Power_BI_S10#kpis]] |
| Columna calculada condicional | `IF(Ingresos >= 1000, "Venta Alta", "Venta Baja")` | [[Power_BI_S10#nivel-venta]] |

### 📉 Visualizaciones
| Visual | Cuándo usarlo | Vista |
|---|---|---|
| Tarjeta KPI | Un solo valor macro en cabecera | Overview |
| Gráfico de líneas (multi-serie) | Comparar evolución temporal entre años o segmentos | Overview + Detalle |
| Gráfico de barras agrupadas | Comparar métricas entre categorías | Overview + Detalle |
| Gráfico de barras apiladas 100% | Ver composición proporcional por grupo | Detalle |
| Filtros desplegables | Segmentar por País o Segmento_Cliente | Detalle |
| Segmentador (Slicer) | Filtro interactivo por Estación | Overview |

### 🎛️ Interactividad
| Qué hace | Técnica | Nota |
|---|---|---|
| Filtrar por temporada | Slicer de Estación (Invierno/Otoño/Primavera/Verano) | Overview |
| Filtrar por país y segmento | Filtros desplegables en cabecera | Detalle |
| Navegar entre vistas | Páginas del reporte (Vista Overview / Vista Detalle) | Ambas |

---

## 🏗️ Arquitectura del Dashboard — S10 Andes Retail Group

### Vista Overview (Página 1 — Ejecutiva)
```
┌─────────────────────────────────────────────────────┐
│  [Slicer: Estación]                                 │
│  KPI: 6M Ingresos | $1.94M Ganancia | 58K Unidades  │
│                                                     │
│  Líneas: Ingresos por Mes (2024 vs 2025)            │
│  Barras: Ganancia por Región (Norte/Centro/Sur)     │
└─────────────────────────────────────────────────────┘
```

### Vista Detalle (Página 2 — Operativa)
```
┌─────────────────────────────────────────────────────┐
│  [Filtro: País]  [Filtro: Segmento_Cliente]         │
│  KPI: 6M Ingresos | 58K Unidades                   │
│                                                     │
│  Barras: Ingresos por Categoría_Producto            │
│  Barras 100%: Región vs Nivel_Venta                 │
│  Líneas: Ingresos por Mes y Segmento_Cliente        │
└─────────────────────────────────────────────────────┘
```

---

## 📖 Framework Narrativo SCQA

Marco para presentar dashboards ejecutivos. Traduce métricas en decisiones estratégicas.

| Etapa | Pregunta que responde | Ejemplo S10 |
|---|---|---|
| **S** Situación | ¿Cuál es el contexto actual? | $6M ingresos, $1.94M ganancia, 58K unidades en operación estable |
| **C** Complicación | ¿Qué problema o cambio existe? | Caída de ingresos en 2025 concentrada en enero, febrero y diciembre |
| **Q** Pregunta | ¿Qué necesitamos entender? | ¿Dónde está la causa raíz de la caída estacional? |
| **A** Respuesta | ¿Qué acción concreta se recomienda? | Segmento Premium estancado → reestructurar captación y blindar campañas de apertura/cierre de año |

---

## 📌 Sprints donde se usó Power BI

| Sprint | Proyecto | Elementos destacados |
|---|---|---|
| S10 | Andes Retail Group | 2 vistas, columna `Nivel_Venta`, KPIs macro, análisis por Segmento_Cliente y Región |

---

## 🔗 Conexiones Estratégicas

- **Índice Maestro:** [[Indice_Maestro]]
- **Herramienta relacionada:** [[SQL]] | [[Google_Sheets]]
