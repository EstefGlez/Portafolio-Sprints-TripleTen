-- ============================================================================
-- PORTAFOLIO DE ANÁLISIS DE DATOS: SPRINT 4
-- OPTIMIZACIÓN DE EMBUDOS DE CONVERSIÓN Y ANÁLISIS DE RETENCIÓN POR COHORTES
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 1. ANÁLISIS DEL EMBUDO DE CONVERSIÓN GLOBAL (MÉTRICAS BASE)
-- ----------------------------------------------------------------------------
WITH first_visit AS (
    SELECT DISTINCT user_id
    FROM mercadolibre_funnel
    WHERE event_name = 'first_visit'
      AND event_date BETWEEN '2025-01-01' AND '2025-08-31'
),
select_item AS (
    SELECT DISTINCT user_id
    FROM mercadolibre_funnel
    WHERE event_name IN ('select_item', 'select_promotion')
      AND event_date BETWEEN '2025-01-01' AND '2025-08-31'
),
add_to_cart AS (
    SELECT DISTINCT user_id
    FROM mercadolibre_funnel
    WHERE event_name = 'add_to_cart'
      AND event_date BETWEEN '2025-01-01' AND '2025-08-31'
),
begin_checkout AS (
    SELECT DISTINCT user_id
    FROM mercadolibre_funnel
    WHERE event_name = 'begin_checkout'
      AND event_date BETWEEN '2025-01-01' AND '2025-08-31'
),
add_shipping_info AS (
    SELECT DISTINCT user_id
    FROM mercadolibre_funnel
    WHERE event_name = 'add_shipping_info'
      AND event_date BETWEEN '2025-01-01' AND '2025-08-31'
),
add_payment_info AS (
    SELECT DISTINCT user_id
    FROM mercadolibre_funnel
    WHERE event_name = 'add_payment_info'
      AND event_date BETWEEN '2025-01-01' AND '2025-08-31'
),
purchase AS (
    SELECT DISTINCT user_id
    FROM mercadolibre_funnel
    WHERE event_name = 'purchase'
      AND event_date BETWEEN '2025-01-01' AND '2025-08-31'
), 
funnel_counts AS (
    SELECT
        COUNT(fv.user_id)  AS usuarios_first_visit,
        COUNT(si.user_id)  AS usuarios_select_item,
        COUNT(a.user_id)   AS usuarios_add_to_cart,
        COUNT(bc.user_id)  AS usuarios_begin_checkout,
        COUNT(asi.user_id) AS usuarios_add_shipping_info,
        COUNT(api.user_id) AS usuarios_add_payment_info,
        COUNT(p.user_id)   AS usuarios_purchase
    FROM first_visit AS fv
    LEFT JOIN select_item AS si        ON fv.user_id = si.user_id
    LEFT JOIN add_to_cart AS a         ON fv.user_id = a.user_id
    LEFT JOIN begin_checkout AS bc     ON fv.user_id = bc.user_id
    LEFT JOIN add_shipping_info AS asi ON fv.user_id = asi.user_id
    LEFT JOIN add_payment_info AS api  ON fv.user_id = api.user_id
    LEFT JOIN purchase AS p            ON fv.user_id = p.user_id
)
SELECT
    ROUND(usuarios_select_item * 100.0 / NULLIF(usuarios_first_visit, 0), 2)     AS conversion_select_item,
    ROUND(usuarios_add_to_cart * 100.0 / NULLIF(usuarios_first_visit, 0), 2)     AS conversion_add_to_cart,
    ROUND(usuarios_begin_checkout * 100.0 / NULLIF(usuarios_first_visit, 0), 2)  AS conversion_begin_checkout,
    ROUND(usuarios_add_shipping_info * 100.0 / NULLIF(usuarios_first_visit, 0), 2) AS conversion_add_shipping_info,
    ROUND(usuarios_add_payment_info * 100.0 / NULLIF(usuarios_first_visit, 0), 2)  AS conversion_add_payment_info,
    ROUND(usuarios_purchase * 100.0 / NULLIF(usuarios_first_visit, 0), 2)          AS conversion_purchase
FROM funnel_counts;

-- ----------------------------------------------------------------------------
-- 2. EMBUDO DE CONVERSIÓN SEGMENTADO POR PAÍS (% RESPECTO A FIRST_VISIT)
-- ----------------------------------------------------------------------------
WITH first_visits AS (
    SELECT DISTINCT user_id, country
    FROM mercadolibre_funnel
    WHERE event_name = 'first_visit'
      AND event_date BETWEEN '2025-01-01' AND '2025-08-31'
),
select_item AS (
    SELECT DISTINCT user_id, country
    FROM mercadolibre_funnel
    WHERE event_name IN ('select_item', 'select_promotion')
      AND event_date BETWEEN '2025-01-01' AND '2025-08-31'
),
add_to_cart AS (
    SELECT DISTINCT user_id, country
    FROM mercadolibre_funnel
    WHERE event_name = 'add_to_cart'
      AND event_date BETWEEN '2025-01-01' AND '2025-08-31'
),
begin_checkout AS (
    SELECT DISTINCT user_id, country
    FROM mercadolibre_funnel
    WHERE event_name = 'begin_checkout'
      AND event_date BETWEEN '2025-01-01' AND '2025-08-31'
),
add_shipping_info AS (
    SELECT DISTINCT user_id, country
    FROM mercadolibre_funnel
    WHERE event_name = 'add_shipping_info'
      AND event_date BETWEEN '2025-01-01' AND '2025-08-31'
),
add_payment_info AS (
    SELECT DISTINCT user_id, country
    FROM mercadolibre_funnel
    WHERE event_name = 'add_payment_info'
      AND event_date BETWEEN '2025-01-01' AND '2025-08-31'
),
purchase AS (
    SELECT DISTINCT user_id, country
    FROM mercadolibre_funnel
    WHERE event_name = 'purchase'
      AND event_date BETWEEN '2025-01-01' AND '2025-08-31'
),
funnel_counts AS (
    SELECT
        fv.country,
        COUNT(fv.user_id)  AS usuarios_first_visit,
        COUNT(si.user_id)  AS usuarios_select_item,
        COUNT(a.user_id)   AS usuarios_add_to_cart,
        COUNT(bc.user_id)  AS usuarios_begin_checkout,
        COUNT(asi.user_id) AS usuarios_add_shipping_info,
        COUNT(api.user_id) AS usuarios_add_payment_info,
        COUNT(p.user_id)   AS usuarios_purchase
    FROM first_visits AS fv
    LEFT JOIN select_item AS si        ON fv.user_id = si.user_id   AND fv.country = si.country
    LEFT JOIN add_to_cart AS a         ON fv.user_id = a.user_id    AND fv.country = a.country
    LEFT JOIN begin_checkout AS bc     ON fv.user_id = bc.user_id   AND fv.country = bc.country
    LEFT JOIN add_shipping_info AS asi ON fv.user_id = asi.user_id  AND fv.country = asi.country
    LEFT JOIN add_payment_info AS api  ON fv.user_id = api.user_id   AND fv.country = api.country
    LEFT JOIN purchase AS p            ON fv.user_id = p.user_id    AND fv.country = p.country
    GROUP BY fv.country
)
SELECT
    country,
    usuarios_select_item * 100.0 / NULLIF(usuarios_first_visit, 0)       AS conversion_select_item,
    usuarios_add_to_cart * 100.0 / NULLIF(usuarios_first_visit, 0)       AS conversion_add_to_cart,
    usuarios_begin_checkout * 100.0 / NULLIF(usuarios_first_visit, 0)    AS conversion_begin_checkout,
    usuarios_add_shipping_info * 100.0 / NULLIF(usuarios_first_visit, 0)  AS conversion_add_shipping_info,
    usuarios_add_payment_info * 100.0 / NULLIF(usuarios_first_visit, 0)   AS conversion_add_payment_info,
    usuarios_purchase * 100.0 / NULLIF(usuarios_first_visit, 0)           AS conversion_purchase
FROM funnel_counts
ORDER BY conversion_purchase DESC;

-- ----------------------------------------------------------------------------
-- 3. ANÁLISIS DE USUARIOS ACTIVOS ACUMULADOS POR PAÍS
-- ----------------------------------------------------------------------------
SELECT
    country,
    COUNT(DISTINCT CASE WHEN active = 1 AND day_after_signup >= 7  THEN user_id END) AS users_d7,
    COUNT(DISTINCT CASE WHEN active = 1 AND day_after_signup >= 14 THEN user_id END) AS users_d14,
    COUNT(DISTINCT CASE WHEN active = 1 AND day_after_signup >= 21 THEN user_id END) AS users_d21,
    COUNT(DISTINCT CASE WHEN active = 1 AND day_after_signup >= 28 THEN user_id END) AS users_d28
FROM mercadolibre_retention
WHERE activity_date BETWEEN '2025-01-01' AND '2025-08-31'
GROUP BY country
ORDER BY country ASC;

-- ----------------------------------------------------------------------------
-- 4. TASA DE RETENCIÓN PORCENTUAL POR PAÍS (D7 - D28)
-- ----------------------------------------------------------------------------
SELECT
    country,
    ROUND(COUNT(DISTINCT CASE WHEN day_after_signup >= 7  AND active = 1 THEN user_id END) * 100.0 / NULLIF(COUNT(DISTINCT user_id), 0), 1) AS retention_d7_pct,
    ROUND(COUNT(DISTINCT CASE WHEN day_after_signup >= 14 AND active = 1 THEN user_id END) * 100.0 / NULLIF(COUNT(DISTINCT user_id), 0), 1) AS retention_d14_pct,
    ROUND(COUNT(DISTINCT CASE WHEN day_after_signup >= 21 AND active = 1 THEN user_id END) * 100.0 / NULLIF(COUNT(DISTINCT user_id), 0), 1) AS retention_d21_pct,
    ROUND(COUNT(DISTINCT CASE WHEN day_after_signup >= 28 AND active = 1 THEN user_id END) * 100.0 / NULLIF(COUNT(DISTINCT user_id), 0), 1) AS retention_d28_pct
FROM mercadolibre_retention
WHERE activity_date BETWEEN '2025-01-01' AND '2025-08-31'
GROUP BY country
ORDER BY country;

-- ----------------------------------------------------------------------------
-- 5. ANÁLISIS COHORTES MENSUALES: TASA DE RETENCIÓN PORCENTUAL CRUZA
-- ----------------------------------------------------------------------------
WITH cohort AS (
    SELECT
        user_id,
        TO_CHAR(DATE_TRUNC('month', MIN(signup_date)), 'YYYY-MM') AS cohort
    FROM mercadolibre_retention
    GROUP BY user_id
),
activity AS (
    SELECT
        a.user_id,
        c.cohort,
        a.day_after_signup,
        a.active
    FROM mercadolibre_retention AS a
    LEFT JOIN cohort AS c
        ON a.user_id = c.user_id
    WHERE activity_date BETWEEN '2025-01-01' AND '2025-08-31'
)
SELECT
    cohort,
    ROUND(100.0 * COUNT(DISTINCT CASE WHEN day_after_signup >= 7  AND active = 1 THEN user_id END) / NULLIF(COUNT(DISTINCT user_id), 0), 1) AS retention_d7_pct,
    ROUND(100.0 * COUNT(DISTINCT CASE WHEN day_after_signup >= 14 AND active = 1 THEN user_id END) / NULLIF(COUNT(DISTINCT user_id), 0), 1) AS retention_d14_pct,
    ROUND(100.0 * COUNT(DISTINCT CASE WHEN day_after_signup >= 21 AND active = 1 THEN user_id END) / NULLIF(COUNT(DISTINCT user_id), 0), 1) AS retention_d21_pct,
    ROUND(100.0 * COUNT(DISTINCT CASE WHEN day_after_signup >= 28 AND active = 1 THEN user_id END) / NULLIF(COUNT(DISTINCT user_id), 0), 1) AS retention_d28_pct
FROM activity
GROUP BY cohort
ORDER BY cohort;