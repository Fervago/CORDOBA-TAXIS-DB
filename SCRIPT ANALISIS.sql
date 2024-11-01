USE CORDOBA_TAXIS;

-- vista_ingresos_totales_periodo1
DROP VIEW IF EXISTS vista_ingresos_totales_periodo1;
CREATE VIEW vista_ingresos_totales_periodo1 AS
SELECT
    SUM(v.monto) AS ingresos_totales
FROM 
    viaje v
LEFT JOIN 
    solicitud_servicio ss ON v.id_solicitud = ss.id_solicitud
WHERE 
    ss.fecha_solicitud BETWEEN '2023-10-07' AND '2024-03-14';


-- vista_cantidad_viajes_periodo1
DROP VIEW IF EXISTS vista_cantidad_viajes_periodo1;
CREATE VIEW vista_cantidad_viajes_periodo1 AS
SELECT
    COUNT(v.id_viaje) AS cantidad_viajes
FROM 
    viaje v
LEFT JOIN 
    solicitud_servicio ss ON v.id_solicitud = ss.id_solicitud
WHERE 
    ss.fecha_solicitud BETWEEN '2023-10-07' AND '2024-03-14';


-- vista_costo_combustible_periodo1
DROP VIEW IF EXISTS vista_costo_combustible_periodo1;
CREATE VIEW vista_costo_combustible_periodo1 AS
SELECT
    SUM(c.costo_total) AS costo_combustible
FROM 
    combustible c
WHERE 
    c.id_vehiculo IN (
        SELECT id_vehiculo FROM asignacion_vehiculo WHERE fecha_inicio >= '2023-10-07'
    )
    AND c.fecha_recarga BETWEEN '2023-10-07' AND '2024-03-14';



-- vista_costo_mantenimiento_periodo1
DROP VIEW IF EXISTS vista_costo_mantenimiento_periodo1;
CREATE VIEW vista_costo_mantenimiento_periodo1 AS
SELECT
    SUM(m.costo) AS costo_mantenimiento
FROM 
    mantenimiento_vehiculo m
WHERE 
    m.id_vehiculo IN (
        SELECT id_vehiculo FROM asignacion_vehiculo WHERE fecha_inicio >= '2023-10-07'
    )
    AND m.fecha_mantenimiento BETWEEN '2023-10-07' AND '2024-03-14';



-- vista_ingresos_totales_periodo2
DROP VIEW IF EXISTS vista_ingresos_totales_periodo2;
CREATE VIEW vista_ingresos_totales_periodo2 AS
SELECT
    SUM(v.monto) AS ingresos_totales
FROM 
    viaje v
LEFT JOIN 
    solicitud_servicio ss ON v.id_solicitud = ss.id_solicitud
WHERE 
    ss.fecha_solicitud BETWEEN '2024-03-15' AND '2024-10-06';


-- vista_cantidad_viajes_periodo2
DROP VIEW IF EXISTS vista_cantidad_viajes_periodo2;
CREATE VIEW vista_cantidad_viajes_periodo2 AS
SELECT
    COUNT(v.id_viaje) AS cantidad_viajes
FROM 
    viaje v
LEFT JOIN 
    solicitud_servicio ss ON v.id_solicitud = ss.id_solicitud
WHERE 
    ss.fecha_solicitud BETWEEN '2024-03-15' AND '2024-10-06';

-- vista_costo_combustible_periodo2
DROP VIEW IF EXISTS vista_costo_combustible_periodo2;
CREATE VIEW vista_costo_combustible_periodo2 AS
SELECT
    SUM(c.costo_total) AS costo_combustible
FROM 
    combustible c
WHERE 
    c.id_vehiculo IN (
        SELECT id_vehiculo FROM asignacion_vehiculo WHERE fecha_inicio >= '2024-03-15'
    )
    AND c.fecha_recarga BETWEEN '2024-03-15' AND '2024-10-06';

-- vista_costo_mantenimiento_periodo2 
DROP VIEW IF EXISTS vista_costo_mantenimiento_periodo2;
CREATE VIEW vista_costo_mantenimiento_periodo2 AS
SELECT
    SUM(m.costo) AS costo_mantenimiento
FROM 
    mantenimiento_vehiculo m
WHERE 
    m.id_vehiculo IN (
        SELECT id_vehiculo FROM asignacion_vehiculo WHERE fecha_inicio >= '2024-03-15'
    )
    AND m.fecha_mantenimiento BETWEEN '2024-03-15' AND '2024-10-06';





-- select_vistas_periodos
SELECT 
    (SELECT ingresos_totales FROM vista_ingresos_totales_periodo1) AS ingresos_totales,
    (SELECT cantidad_viajes FROM vista_cantidad_viajes_periodo1) AS cantidad_viajes,
    (SELECT costo_combustible FROM vista_costo_combustible_periodo1) AS costo_combustible,
    (SELECT costo_mantenimiento FROM vista_costo_mantenimiento_periodo1) AS costo_mantenimiento,
    ganancia(
        (SELECT ingresos_totales FROM vista_ingresos_totales_periodo1),
        (SELECT costo_combustible FROM vista_costo_combustible_periodo1),
        (SELECT costo_mantenimiento FROM vista_costo_mantenimiento_periodo1)) AS ganancia
UNION ALL
SELECT 
    (SELECT ingresos_totales FROM vista_ingresos_totales_periodo2) AS ingresos_totales,
    (SELECT cantidad_viajes FROM vista_cantidad_viajes_periodo2) AS cantidad_viajes,
    (SELECT costo_combustible FROM vista_costo_combustible_periodo2) AS costo_combustible,
    (SELECT costo_mantenimiento FROM vista_costo_mantenimiento_periodo2) AS costo_mantenimiento,
    ganancia(
        (SELECT ingresos_totales FROM vista_ingresos_totales_periodo2),
        (SELECT costo_combustible FROM vista_costo_combustible_periodo2),
        (SELECT costo_mantenimiento FROM vista_costo_mantenimiento_periodo2)) AS ganancia;
        
        
call obtener_estado_conductores();

call analizar_rendimiento_conductores('2023-10-07', '2024-03-14');

call analizar_rendimiento_conductores('2023-10-07', '2024-10-06');