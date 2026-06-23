---
tags: [herramienta, google-sheets, indice]
tipo: indice-herramienta
---

# 📗 Google Sheets — Índice de Capacidades

Referencia rápida de todo lo que puedes hacer con Google Sheets en el contexto del bootcamp. Cada entrada enlaza a la nota de operación correspondiente donde está el código completo.

---

## 🗂️ Capacidades por Categoría

### 🧹 Limpieza y Normalización
| Qué hace | Función clave | Nota |
|---|---|---|
| Normalizar texto (mayúsculas + espacios) | `=NOMPROPIO(ESPACIOS())` | [[Limpieza_y_Normalizacion#normalizar-texto]] |
| Imputar monto total faltante | `=Cantidad * Precio` | [[Limpieza_y_Normalizacion#imputar-nulos-sheets]] |
| Imputar precio unitario faltante | `=Monto / Cantidad` | [[Limpieza_y_Normalizacion#imputar-nulos-sheets]] |
| Convertir fecha-texto a fecha real | `=VALOR()` | [[Limpieza_y_Normalizacion#fechas-texto-sheets]] |
| Detectar duplicados | `=COUNTIF() > 1` | [[Limpieza_y_Normalizacion#duplicados-sheets]] |
| Formato financiero estándar | `$ #,##0.00` | [[Limpieza_y_Normalizacion#formato-mascaras]] |

### 📈 Agregación y Reportes
| Qué hace | Función clave | Nota |
|---|---|---|
| Consultas dinámicas con agrupación | `=QUERY()` | [[Agregacion_y_Reportes#query-sheets]] |
| Segmentar texto compuesto | `=SPLIT()` | [[Agregacion_y_Reportes#split-texto]] |
| Ticket promedio | `=SUM()/COUNTA()` | [[Agregacion_y_Reportes#kpis-sheets]] |
| Participación de categoría (%) | `=SUMIF()/SUM()` | [[Agregacion_y_Reportes#kpis-sheets]] |
| Variación mensual (Δ%) | `=(C3-C2)/C2` | [[Agregacion_y_Reportes#kpis-sheets]] |

---

## 📌 Sprints donde se usó Google Sheets

| Sprint | Proyecto | Operaciones aplicadas |
|---|---|---|
| Sprint 1 | VentaExpress Q4 — Limpieza transaccional | Imputación, NOMPROPIO, QUERY, SPLIT |
| S2 | Walmart 2012 — Dashboard comercial | BUSCARV, Star Schema, Ventas/m², Participación %, QA pipeline |

---

## 🔗 Conexiones Estratégicas

- **Índice Maestro:** [[Indice_Maestro]]
- **Siguiente herramienta:** [[SQL]]
