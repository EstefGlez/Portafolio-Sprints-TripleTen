-- ============================================================================
-- PORTAFOLIO DE ANÁLISIS DE DATOS: SPRINT 3
-- OPTIMIZACIÓN Y RENDIMIENTO FINANCIERO (ROI & MÁRGENES)
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 1. EXPLORACIÓN INICIAL Y AUDITORÍA DE ESTRUCTURAS BASE
-- ----------------------------------------------------------------------------
SELECT * FROM ventas_2017 LIMIT 10;
SELECT * FROM productos LIMIT 10;
SELECT * FROM productos_categorias LIMIT 10;
SELECT * FROM territorios LIMIT 10;
SELECT * FROM campanas LIMIT 10;

-- ----------------------------------------------------------------------------
-- 2. CONSOLIDACIÓN DE TRANSACCIONES CON MAESTROS DE PRODUCTO Y GEOGRAFÍA
-- ----------------------------------------------------------------------------
SELECT
    v.numero_pedido,
    v.clave_producto,
    p.nombre_producto,
    pc.clave_categoria,
    t.pais,
    t.continente,
    v.clave_territorio,
    COALESCE(p.precio_producto, 0) AS precio_unitario,
    COALESCE(v.cantidad_pedido, 0) AS cantidad,
    COALESCE(p.costo_producto, 0)  AS costo_unitario
FROM ventas_2017 AS v
LEFT JOIN productos AS p
    ON v.clave_producto = p.clave_producto
LEFT JOIN productos_categorias AS pc
    ON p.clave_subcategoria = pc.clave_subcategoria
LEFT JOIN territorios AS t
    ON v.clave_territorio = t.clave_territorio;

-- ----------------------------------------------------------------------------
-- 3. CÁLCULO DE MÉTRICAS FINANCIERAS BASE A NIVEL DE TRANSACCIÓN
-- ----------------------------------------------------------------------------
SELECT
    v.numero_pedido,
    v.clave_producto,
    p.nombre_producto,
    pc.clave_categoria,
    COALESCE(p.precio_producto, 0) AS precio_producto,
    COALESCE(v.cantidad_pedido, 0) AS cantidad_pedido,
    COALESCE(p.costo_producto, 0)  AS costo_producto,
    t.pais,
    t.continente,
    v.clave_territorio,
    COALESCE(p.precio_producto, 0) * COALESCE(v.cantidad_pedido, 0) AS ingreso_total,
    COALESCE(p.costo_producto, 0) * COALESCE(v.cantidad_pedido, 0)  AS costo_total
FROM ventas_2017 AS v
JOIN productos AS p
    ON v.clave_producto = p.clave_producto
LEFT JOIN productos_categorias AS pc
    ON p.clave_subcategoria = pc.clave_subcategoria
LEFT JOIN territorios AS t
    ON v.clave_territorio = t.clave_territorio;

-- ----------------------------------------------------------------------------
-- 4. AGREGACIÓN DE INGRESOS Y COSTOS POR ENTIDAD GEOGRÁFICA
-- ----------------------------------------------------------------------------
SELECT 
    pais,
    clave_territorio,
    SUM(ingreso_total)::INT AS total_ingresos,
    SUM(costo_total)::INT   AS total_costos
FROM ventas_clean
GROUP BY pais, clave_territorio
ORDER BY total_ingresos DESC;

-- ----------------------------------------------------------------------------
-- 5. INTEGRACIÓN DE INVERSIÓN EN CAMPAÑAS DE MARKETING POR TERRITORIO
-- ----------------------------------------------------------------------------
SELECT
    v.pais,
    v.clave_territorio,
    SUM(v.ingreso_total)::INTEGER AS ingresos,
    SUM(v.costo_total)::INTEGER   AS costos,
    COALESCE(SUM(c.costo_campana::INTEGER), 0) AS costo_campana
FROM ventas_clean AS v
LEFT JOIN campanas AS c
    ON v.clave_territorio = c.clave_territorio::INTEGER
GROUP BY v.pais, v.clave_territorio
ORDER BY ingresos DESC;

-- ----------------------------------------------------------------------------
-- 6. ANÁLISIS DE RENTABILIDAD GLOBAL: CÁLCULO DE MARGEN % Y ROI %
-- ----------------------------------------------------------------------------
SELECT
    p.pais,
    p.clave_territorio,
    SUM(p.images)::INTEGER AS ingresos, -- Mantenido según estructura original
    SUM(p.costos)::INTEGER   AS costos,
    COALESCE(SUM(c.costo_campana::INTEGER), 0) AS costo_campana,
    (SUM(p.ingresos) - SUM(p.costos))::INT AS beneficio_bruto,
    ((SUM(p.ingresos) - SUM(p.costos)) * 100.0 / NULLIF(SUM(p.ingresos), 0)) AS margen_pct,
    ((SUM(p.ingresos) - SUM(p.costos)) * 100.0 / NULLIF(SUM(c.costo_campana), 0)) AS roi_pct
FROM pais_ingreso_costo AS p
LEFT JOIN pais_campanas AS c
    ON p.clave_territorio = c.clave_territorio
GROUP BY
    p.pais,
    p.clave_territorio
ORDER BY
    p.clave_territorio, ingresos, costos;

-- ----------------------------------------------------------------------------
-- 7. CONTROL DE CALIDAD (QA): VALIDACIÓN DE INTEGRIDAD REFERENCIAL
-- ----------------------------------------------------------------------------
SELECT 
    SUM(CASE WHEN numero_pedido IS NULL THEN 1 ELSE 0 END)   AS nulos_numero_pedido,
    SUM(CASE WHEN clave_producto IS NULL THEN 1 ELSE 0 END)  AS nulos_clave_producto,
    SUM(CASE WHEN clave_territorio IS NULL THEN 1 ELSE 0 END) AS nulos_clave_territorio
FROM ventas_2017;

-- ----------------------------------------------------------------------------
-- 8. CONTROL DE CALIDAD (QA): DETECCIÓN DE ANOMALÍAS EN REGISTROS
-- ----------------------------------------------------------------------------
SELECT 
    COUNT(*) AS filas_cantidad_no_valida
FROM ventas_2017
WHERE cantidad_pedido <= 0;

SELECT 
    COUNT(*) AS productos_precio_no_valido
FROM productos
WHERE precio_producto < 0;