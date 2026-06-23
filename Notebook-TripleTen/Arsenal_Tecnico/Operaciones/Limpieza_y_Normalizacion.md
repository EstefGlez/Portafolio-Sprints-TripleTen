---
tags: [operacion, limpieza, normalizacion, google-sheets, pandas, sql]
tipo: nota-operacion
herramientas: [google-sheets, pandas, sql]
---

# 🧹 Limpieza y Normalización de Datos

Operaciones para auditar, corregir y estandarizar datos crudos antes de cualquier análisis. Este es normalmente el **primer paso** de todo pipeline de datos.

---

## 📋 Índice de Operaciones

| Operación | Herramienta | Ir a |
|---|---|---|
| Normalizar texto (mayúsculas + espacios) | Google Sheets | [[#normalizar-texto]] |
| Imputar valores faltantes (nulos) | Google Sheets | [[#imputar-nulos-sheets]] |
| Tratar fechas en formato texto | Google Sheets | [[#fechas-texto-sheets]] |
| Detectar y eliminar duplicados | Google Sheets | [[#duplicados-sheets]] |

---

## 🔤 Normalizar Texto {#normalizar-texto}

**Herramienta:** Google Sheets
**Cuándo usarlo:** Al importar datos manuales donde los usuarios escriben libremente. Evita que registros idénticos se traten como distintos por diferencias de capitalización o espacios invisibles.
**Contexto real:** Sprint 1 — columna `Ciudad` tenía entradas como `"CALI"`, `"cali"` y `"Guadalajara "` (con espacio al final).

```excel
=NOMPROPIO(ESPACIOS(A2))
```

**Parámetros:**
- `ESPACIOS(texto)` — elimina espacios al inicio, al final y los dobles espacios internos
- `NOMPROPIO(texto)` — capitaliza la primera letra de cada palabra y pone el resto en minúscula

> [!NOTE] Buena práctica
> Siempre crear una columna nueva (ej. `Ciudad_Limpia`) en lugar de sobreescribir el dato original. Preserva la trazabilidad de los cambios.

---

## 🔢 Imputar Valores Faltantes (Nulos) {#imputar-nulos-sheets}

**Herramienta:** Google Sheets
**Cuándo usarlo:** Cuando existen celdas vacías en columnas numéricas que tienen una relación matemática directa entre sí. Permite reconstruir el dato exacto sin distorsionar promedios ni totales.
**Contexto real:** Sprint 1 — se detectaron 16 nulos: 10 en `Precio Unitario` y 6 en `Monto Total`.

### A. Reconstruir Monto Total faltante

$$\text{Monto Total} = \text{Cantidad} \times \text{Precio Unitario}$$

```excel
=C2*D2
```

### B. Reconstruir Precio Unitario faltante

$$\text{Precio Unitario} = \frac{\text{Monto Total}}{\text{Cantidad}}$$

```excel
=F2/C2
```

> [!IMPORTANT] Imputación Determinista vs. Estadística
> Este método (imputación determinista) solo aplica cuando existe una **dependencia matemática rígida** entre columnas. Si no existe esa relación, usar la media o mediana es incorrecto — distorsiona la distribución real de los datos.

---

## 📅 Tratar Fechas en Formato Texto {#fechas-texto-sheets}

**Herramienta:** Google Sheets
**Cuándo usarlo:** Cuando las fechas importadas de sistemas externos llegan como texto plano (`string`) y Sheets no permite agruparlas por mes, trimestre o año en tablas dinámicas.
**Contexto real:** Sprint 1 — columna `Fecha` importada de sistema transaccional llegó como texto y bloqueaba la agrupación temporal.

```excel
=VALOR(A2)
```

**Paso posterior obligatorio:** Seleccionar la columna resultante → `Formato > Número > Fecha`

> [!WARNING] Sin el formato manual posterior, el resultado es un número de serie (ej. `45123`) en lugar de una fecha legible.

---

## 🔍 Detectar Duplicados {#duplicados-sheets}

**Herramienta:** Google Sheets
**Cuándo usarlo:** Como primer paso de auditoría en cualquier dataset nuevo, antes de calcular métricas. Un duplicado no detectado infla totales y promedios.
**Contexto real:** Sprint 1 — auditoría sobre `ID de Orden` arrojó 0 duplicados en 753 registros.

**Método visual (filtro):**
1. Seleccionar la columna del identificador único (ej. `ID de Orden`)
2. `Datos > Crear un filtro`
3. Ordenar de A→Z y revisar visualmente registros consecutivos idénticos

**Método con fórmula (conteo condicional):**
```excel
=COUNTIF($A$2:$A$754, A2) > 1
```
Devuelve `TRUE` en las filas con ID duplicado. Aplicar a toda la columna para marcarlos.

---

## 📐 Formato de Máscaras Numéricas y Financieras

**Herramienta:** Google Sheets
**Cuándo usarlo:** Para estandarizar la visualización de columnas monetarias en reportes ejecutivos o dashboards.

**Máscara financiera estándar:**
```
$ #,##0.00
```
Resultado: `$ 3,910.52`

**Aplicación:** Seleccionar columna → `Formato > Número > Número personalizado` → pegar la máscara.

---

## 🔗 Conexiones Estratégicas

- **Herramienta completa:** [[Google_Sheets]]
- **Siguiente operación:** [[Agregacion_y_Reportes]]
- **Proyecto de referencia:** Sprint 1 — VentaExpress Q4 (`$2,919,072.38` | 753 transacciones)
