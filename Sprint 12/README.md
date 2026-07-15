# RappiPlus: de datos crudos a una decisión de negocio

## Desafío

Evaluar si el servicio RappiPlus era rentable, en qué paso del embudo de compra se perdían más usuarios, y si una nueva interfaz de checkout mejoraba la conversión — combinando en un solo proyecto limpieza de datos, SQL, estadística inferencial y comunicación ejecutiva de resultados.

## Proceso

1. **Calidad de datos primero:** audité tres fuentes en Python (pedidos, catálogo de productos, inversión en marketing), detectando y corrigiendo 100 filas duplicadas y 50 registros sin `cantidad` o `precio_unitario` — sin esa limpieza, cualquier cifra de revenue o costo habría quedado mal calculada desde la raíz.
2. **Rentabilidad:** crucé pedidos con el catálogo para incorporar el costo por producto y calculé revenue, costo y profit a nivel de negocio.
3. **Funnel de conversión (SQL/PostgreSQL):** construí un embudo **secuencial** usando `INTERSECT`, de forma que cada etapa solo cuenta a los usuarios que de verdad avanzaron desde la etapa anterior — no eventos sueltos.
4. **Retención por cohortes:** medí qué porcentaje de cada cohorte mensual seguía activo en las semanas siguientes a su registro.
5. **Experimento de checkout:** validé un rediseño de interfaz con un **Z-test de proporciones** sobre la tasa de conversión de control vs. tratamiento.
6. **Dashboard ejecutivo en Power BI:** medidas DAX para Revenue, Costo, Margen operativo, Profit neto y Ticket promedio, con vistas de Overview y Detalle.

```sql
paso_3 AS (
    SELECT id_usuario FROM usuarios_evento WHERE nombre_evento = 'add_to_cart'
    INTERSECT
    SELECT id_usuario FROM paso_2
)
```

## Resultado

- **El negocio es rentable:** profit neto de **$5.97M** sobre un revenue de **$51.97M** (margen ~11.5%), después de descontar costo de productos e inversión en marketing.
- **Mayor fuga del embudo:** entre `begin_checkout` y `add_payment_info` (90.2% → 78.1%, ~12 puntos perdidos) — la etapa prioritaria a optimizar, probablemente reduciendo fricción en el formulario de pago.
- **Concentración de riesgo:** un solo producto (`laptop-gaming-16gb`) domina las ventas de la categoría Electrónica, lo que es tanto la principal fuente de ingresos como un riesgo de dependencia.
- **El experimento de checkout no mostró efecto:** p-value = 0.4161, muy por encima de α = 0.05 → no se recomienda adoptar la nueva interfaz solo con esta evidencia.

## Visuales

*(Agregar aquí: captura del dashboard de Power BI — vista Overview con los KPIs de Revenue/Profit/Ticket promedio.)*

## Lección

Aquí entendí que la limpieza de datos no es un paso previo aburrido: es donde en realidad se decide si el número final es confiable. Ese 0.12% de productos que quedó sin costo tras el cruce de tablas pudo pasar totalmente desapercibido y, aun así, torcer el profit reportado si no se audita a propósito. Este proyecto también fue donde corregí un matiz que se me había pasado en un proyecto anterior de embudo (Sprint 4): ahí unía las etapas por `user_id` sin forzar el orden; aquí usé `INTERSECT` para que cada paso dependiera estrictamente del anterior, evitando conversiones infladas por eventos sueltos.

**Tecnologías:** Python (Pandas, SciPy, Statsmodels), SQL (PostgreSQL, CTEs, INTERSECT), Power BI (DAX), pruebas de hipótesis (Z-test de proporciones).
