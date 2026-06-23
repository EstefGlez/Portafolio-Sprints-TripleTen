---
tags: [google-sheets, vlookup, buscarv, tablas-dinamicas, kpis, sprint-2, walmart]
tipo: nota-operacion
herramientas: [google-sheets]
---

# 🛒 Google Sheets — Modelado Analítico y Dashboard (Sprint 2)

Técnicas avanzadas de Google Sheets aplicadas al proyecto Walmart 2012: modelado en estrella simulado, cruce de tablas con VLOOKUP, QA de integridad y construcción de KPIs de negocio.

---

## 📋 Índice de Operaciones

| Operación | Ir a |
|---|---|
| Arquitectura del modelo (Star Schema en Sheets) | [[#star-schema]] |
| Cruce de tablas con VLOOKUP / BUSCARV | [[#vlookup]] |
| Pipeline de QA — Control de integridad | [[#qa-pipeline]] |
| KPI: Ventas por Metro Cuadrado | [[#ventas-m2]] |
| KPI: Participación de Departamento (% del total) | [[#participacion]] |
| Análisis de estacionalidad (`esferiado`) | [[#estacionalidad]] |

---

## 🏗️ Arquitectura del Modelo (Star Schema en Sheets) {#star-schema}

**Cuándo:** Cuando el dataset transaccional necesita enriquecerse con atributos de catálogos separados antes de poder calcular KPIs. Simula un modelo estrella dentro de Sheets.

```
Tabla de Hechos:       raw_ventas
                       (transacciones semanales, montos, llaves foráneas)
                            │
              ┌─────────────┴─────────────┐
              ▼                           ▼
Dimensión: raw_departamento     Dimensión: raw_tiendas
(nombres de departamentos)      (tipo de tienda, superficie m²)
              │                           │
              └─────────────┬─────────────┘
                            ▼
                    clean_ventas
              (tabla desnormalizada lista para análisis)
```

**Contexto real:** S2 Walmart — 754 filas de transacciones semanales enriquecidas con nombre de departamento y superficie de tienda mediante BUSCARV.

---

## 🔍 Cruce de Tablas con VLOOKUP / BUSCARV {#vlookup}

**Herramienta:** Google Sheets
**Cuándo:** Para inyectar atributos de una tabla dimensional hacia la tabla de hechos usando una llave de cruce (equivalente a un LEFT JOIN en SQL).

```excel
; Traer el nombre del departamento desde raw_departamento
=BUSCARV(A2, raw_departamento!$A:$B, 2, 0)

; Traer la superficie (m²) desde raw_tiendas
=BUSCARV(B2, raw_tiendas!$A:$C, 3, 0)
```

**Parámetros de BUSCARV:**
- `A2` — valor a buscar (llave foránea en la tabla de hechos)
- `raw_departamento!$A:$B` — rango de la tabla dimensional (fijar con `$`)
- `2` — número de columna a devolver dentro del rango
- `0` — coincidencia exacta (siempre usar `0` en análisis de datos)

> [!IMPORTANT] Fijar el rango con `$`
> Al arrastrar la fórmula hacia abajo, el rango de búsqueda debe ser absoluto (`$A:$B`), no relativo. Sin `$`, el rango se desplaza y devuelve resultados incorrectos.

**Contexto real:** S2 — BUSCARV aplicado en 754 filas para mapear `depto_id` → nombre de departamento y `tienda_id` → superficie en m².

---

## ✅ Pipeline de QA — Control de Integridad {#qa-pipeline}

**Herramienta:** Google Sheets
**Cuándo:** Después de construir `clean_ventas`, antes de calcular cualquier KPI. Detecta errores de cruce, valores negativos y riesgo de división por cero.

```excel
; Control 1: Errores de cruce en BUSCARV (¿algún #N/A?)
=COUNTIF(clean_ventas!I:I, "#N/A") + COUNTBLANK(clean_ventas!I:I)
; Resultado esperado: 0

; Control 2: Anomalías financieras (ventas negativas o cero)
=COUNTIF(clean_ventas!D:D, "<=0")
; Resultado esperado: 0

; Control 3: Riesgo de división por cero (superficie = 0)
=COUNTIF(clean_ventas!H:H, 0) + COUNTBLANK(clean_ventas!H:H)
; Resultado esperado: 0
```

**Contexto real:** S2 Walmart — los tres controles devolvieron `0`, validando la integridad completa del dataset antes del análisis.

> [!NOTE] Por qué este orden importa
> Calcular KPIs sobre datos con errores de cruce produce métricas incorrectas silenciosamente — no hay error visible, solo números equivocados. El QA previene esto.

---

## 📐 KPI: Ventas por Metro Cuadrado {#ventas-m2}

**Herramienta:** Google Sheets
**Cuándo:** Para medir la eficiencia operativa del espacio físico de exhibición. Permite comparar departamentos independientemente de su tamaño.

$$\text{Ventas}/m^2 = \frac{\sum \text{Ventas Semanales}}{\text{Superficie máxima del departamento}}$$

```excel
; En la tabla pivot, por departamento:
=SUMIF(clean_ventas!C:C, A2, clean_ventas!D:D) / MAXIF(clean_ventas!C:C, A2, clean_ventas!H:H)
```

**Interpretación de negocio:**
- **Alto Ventas/m²** → departamento eficiente, candidato a más espacio
- **Bajo Ventas/m²** → sobreasignación de espacio, candidato a reducción de área

**Contexto real:** S2 — se detectaron departamentos "ancla" con alto volumen pero baja eficiencia por m² debido a sobreasignación de espacio físico.

---

## 📊 KPI: Participación de Departamento (% del Total) {#participacion}

**Herramienta:** Google Sheets
**Cuándo:** Para identificar qué departamentos concentran la mayor parte de los ingresos (análisis de Pareto / concentración de riesgo).

$$\text{Participación \%} = \frac{\text{Ventas del Departamento}}{\text{Ventas Totales}} \times 100$$

```excel
; Ventas de un departamento sobre el total
=SUMIF(clean_ventas!C:C, A2, clean_ventas!D:D) / SUM(clean_ventas!D:D)

; Formatear la celda como porcentaje: Formato > Número > Porcentaje
```

**Hallazgo clave S2:** El **45.45%** de los ingresos totales estaba concentrado en solo 4 de 15 departamentos (*Despensa y Básicos*, *Comida Fresca*, *Artículos del Hogar y Papel*, *Salud y Bienestar*). Riesgo de concentración crítico.

---

## 📅 Análisis de Estacionalidad (`esferiado`) {#estacionalidad}

**Herramienta:** Google Sheets
**Cuándo:** Para aislar el efecto de días festivos en las ventas y comparar semanas festivas vs. semanas normales.

```excel
; Ventas promedio en semanas con festivo
=AVERAGEIF(clean_ventas!E:E, "Si", clean_ventas!D:D)

; Ventas promedio en semanas normales
=AVERAGEIF(clean_ventas!E:E, "No", clean_ventas!D:D)

; Diferencia porcentual entre ambos periodos
=(B2 - B3) / B3
```

**Contexto real:** S2 — la columna `esferiado` actuó como variable de control para aislar la variación estacional y cuantificar el multiplicador de demanda en semanas festivas vs. estándar.

---

## 💡 Hallazgos Estratégicos del Sprint 2

```
[Resumen Ejecutivo — Walmart 2012]
   ├── Dataset ──────────► 754 filas | 3 tablas | Modelo estrella en Sheets
   ├── QA ───────────────► Errores BUSCARV: 0 | Ventas negativas: 0 | Div/0: 0
   ├── Concentración ────► 45.45% de ingresos en 4/15 departamentos (Riesgo Alto)
   ├── Eficiencia ───────► Dpto. anclas: alto volumen, baja eficiencia/m²
   └── Estacionalidad ───► Semanas festivas muestran multiplicador de demanda significativo
```

---

## 🔗 Conexiones Estratégicas

- **Herramienta:** [[Google_Sheets]]
- **Operación base:** [[Limpieza_y_Normalizacion]] | [[Agregacion_y_Reportes]]
- **Sprint anterior:** [[Limpieza_y_Normalizacion]] (S1 VentaExpress)
- **Siguiente herramienta:** [[SQL]] (S3 Financiero)
