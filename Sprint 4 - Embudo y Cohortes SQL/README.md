# Embudo de conversión y retención por cohortes: dónde se está perdiendo el negocio

## Desafío

Una plataforma de e-commerce en LATAM necesitaba entender en qué paso exacto del recorrido de compra —desde la primera visita hasta el pago— se estaba perdiendo la mayor parte de los usuarios, y si quienes sí compraban regresaban o abandonaban la plataforma en las semanas siguientes.

## Proceso

Escribí las consultas en SQL (PostgreSQL) usando CTEs para aislar a los usuarios únicos en cada paso del embudo (`first_visit`, `select_item`, `add_to_cart`, `begin_checkout`, `add_shipping_info`, `add_payment_info`, `purchase`), calculando la tasa de conversión de cada etapa respecto a la primera visita, tanto de forma global como segmentada por país. En paralelo, construí un análisis de cohortes mensuales para medir qué porcentaje de usuarios seguía activo 7, 14, 21 y 28 días después de registrarse.

Consulta clave (embudo global):

```sql
SELECT
    ROUND(usuarios_select_item * 100.0 / NULLIF(usuarios_first_visit, 0), 2) AS conversion_select_item,
    ROUND(usuarios_add_to_cart * 100.0 / NULLIF(usuarios_first_visit, 0), 2) AS conversion_add_to_cart,
    ...
FROM funnel_counts;
```

## Resultado

Identifiqué una caída crítica de **65.88 puntos porcentuales entre `select_item` y `add_to_cart`** — el mayor cuello de botella de todo el embudo, muy por encima de cualquier caída posterior en checkout o pago. En el análisis de cohortes, la retención mostró un abandono pronunciado a partir de la tercera semana después del registro, lo que sugiere que el problema no es solo de conversión inicial, sino también de que a la plataforma le cuesta generar hábito de recompra.

## Visuales

<img width="1345" height="1263" alt="retencion_por_cohorte" src="https://github.com/user-attachments/assets/259b6445-db93-42ec-a141-a291e928dc56" />
<img width="1959" height="1263" alt="embudo_por_pais" src="https://github.com/user-attachments/assets/74f6f5ba-ac56-408f-9a22-1d9f2201c2ad" />


## Lección

Aprendí que la forma en que unes las tablas del embudo importa tanto como el análisis en sí: aquí usé `LEFT JOIN` por `user_id` para relacionar cada etapa con la primera visita, lo cual funciona bien para medir alcance, pero no obliga a que un usuario haya pasado *en orden* por cada paso anterior. Más adelante, en el proyecto de RappiPlus, corregí este matiz usando `INTERSECT` para construir un embudo estrictamente secuencial — una mejora directa que nace de haber hecho este proyecto primero.

**Tecnologías:** SQL (PostgreSQL), CTEs, funciones de ventana, análisis de cohortes.
