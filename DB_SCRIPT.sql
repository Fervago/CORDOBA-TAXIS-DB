DROP DATABASE IF EXISTS CORDOBA_TAXIS;
CREATE DATABASE CORDOBA_TAXIS;
USE CORDOBA_TAXIS;

-- TABLAS
CREATE TABLE conductor (
	id_conductor INT auto_increment NOT NULL PRIMARY KEY,
	dni INT NOT NULL,
    nombre varchar(30) NOT NULL,
    apellido varchar(30) NOT NULL,
    email varchar(50),    
    fecha_nacimiento DATE NOT NULL,
    domicilio varchar(50) NOT NULL
    );
    
    
CREATE TABLE vehiculo (
	id_vehiculo INT auto_increment NOT NULL PRIMARY KEY,
    marca varchar(30) NOT NULL,
    modelo varchar(30) NOT NULL,
    patente varchar(7) NOT NULL UNIQUE,
    año DATE NOT NULL
    );
    
    
CREATE TABLE cliente (
	id_cliente INT auto_increment NOT NULL PRIMARY KEY,
	dni INT NOT NULL,
    nombre varchar(30) NOT NULL,
    apellido varchar(30) NOT NULL,
    email varchar(50),    
    fecha_nacimiento DATE NOT NULL,
    direccion varchar(150) NOT NULL
    );
    

CREATE TABLE asignacion_vehiculo (
	id_asignacion INT auto_increment NOT NULL PRIMARY KEY, 
	id_conductor INT NOT NULL, 
	id_vehiculo INT NOT NULL,
	fecha_inicio DATE NOT NULL,
    hora_inicio TIME NOT NULL,
	fecha_fin DATE NOT NULL,
	hora_fin TIME NOT NULL,
	foreign key (id_conductor) references conductor(id_conductor),
	foreign key (id_vehiculo) references vehiculo(id_vehiculo)
);

CREATE TABLE viaje (
    id_viaje INT AUTO_INCREMENT PRIMARY KEY,
    id_asignacion INT NOT NULL,
    id_solicitud INT NOT NULL,
    monto decimal(10,2) NOT NULL,
    metodo_pago varchar(30) NOT NULL, /* efectivo, transferencia */
    foreign key (id_asignacion) references asignacion_vehiculo(id_asignacion)
);


CREATE TABLE pais (
id_pais INT auto_increment NOT NULL PRIMARY KEY,
nombre_pais varchar(30) NOT NULL,
continente varchar(15) NOT NULL
);


CREATE TABLE marca (
id_marca INT auto_increment NOT NULL PRIMARY KEY,
nombre_marca varchar(30) NOT NULL,
id_pais_origen INT NOT NULL,
foreign key (id_pais_origen) references pais(id_pais)
);


CREATE TABLE modelo (
id_modelo INT auto_increment NOT NULL PRIMARY KEY,
nombre_modelo varchar(30) NOT NULL,
año_modelo year NOT NULL,
tipo_vehiculo varchar(30),
capacidad_pasajeros INT NOT NULL,
tipo_combustible varchar(30) NOT NULL, 
tipo_transmision varchar(30) NOT NULL,
consumo_promedio decimal(5,2) NOT NULL
);


ALTER TABLE vehiculo drop año;
ALTER TABLE vehiculo add id_pais_origen INT NOT NULL;
ALTER TABLE vehiculo rename column marca to id_marca;
ALTER TABLE vehiculo modify id_marca INT NOT NULL;
ALTER TABLE vehiculo rename column modelo to id_modelo;
ALTER TABLE vehiculo modify id_modelo INT NOT NULL;

ALTER TABLE vehiculo 
add constraint fk_pais_origen foreign key (id_pais_origen) references pais(id_pais);

ALTER TABLE vehiculo 
add constraint fk_marca foreign key (id_marca) references marca(id_marca);

ALTER TABLE vehiculo
add constraint fk_modelo foreign key (id_modelo) references modelo(id_modelo);


CREATE TABLE solicitud_servicio (
    id_solicitud INT auto_increment NOT NULL PRIMARY KEY,
    id_cliente INT NOT NULL,
    fecha_solicitud date NOT NULL,
    hora_solicitud time NOT NULL,
    ubicacion_origen varchar(100) NOT NULL,
    ubicacion_destino varchar(100) NOT NULL,
    estado VARCHAR(30) NOT NULL,   /* completada o cancelada */
    foreign key (id_cliente) references cliente(id_cliente)
);

ALTER TABLE viaje add constraint fk_solicitud foreign key (id_solicitud) references solicitud_servicio(id_solicitud);



CREATE TABLE mantenimiento_vehiculo (
    id_mantenimiento INT auto_increment NOT NULL PRIMARY KEY,
    id_vehiculo INT NOT NULL,
    fecha_mantenimiento date NOT NULL,
    tipo_mantenimiento varchar(30) NOT NULL, /*preventivo o correctivo */
    descripcion TEXT NOT NULL,
    costo decimal(10,2) NOT NULL,
    proxima_revision date,
    foreign key (id_vehiculo) references vehiculo(id_vehiculo)
);


    CREATE TABLE combustible (
    id_combustible INT auto_increment NOT NULL PRIMARY KEY,
    id_vehiculo INT NOT NULL,
    fecha_recarga date NOT NULL,
    tipo_combustible varchar(30) NOT NULL, /* nafta, gas */
    costo_total decimal(10,2) NOT NULL,
    foreign key (id_vehiculo) references vehiculo(id_vehiculo)
);


CREATE TABLE incidencias_vehiculo (
    id_incidencia INT auto_increment NOT NULL PRIMARY KEY,
    id_vehiculo INT NOT NULL,
    fecha_incidencia date NOT NULL,
    tipo_incidencia varchar(30) NOT NULL, /* tipo de daño/accidente */
    estado_vehiculo varchar(30) NOT NULL, 
    id_conductor INT NOT NULL,
    foreign key (id_vehiculo) references vehiculo(id_vehiculo),
     foreign key (id_conductor) references conductor(id_conductor)
);


CREATE TABLE licencia_vehiculo (
    id_licencia INT auto_increment NOT NULL PRIMARY KEY,
    id_vehiculo INT NOT NULL,
    fecha_emision date NOT NULL,
    fecha_expiracion date NOT NULL,
    estado varchar(30) NOT NULL, /* renovada, expirada */
    foreign key (id_vehiculo) references vehiculo(id_vehiculo)
);


CREATE TABLE historial_conductor (
    id_historial INT auto_increment NOT NULL PRIMARY KEY,
    id_conductor INT NOT NULL,
    fecha_evento date NOT NULL,
    tipo_evento varchar(30) NOT NULL, /* multa, evaluación */
    descripcion text,
    estado varchar(30) NOT NULL, /* activo, sancionado, licencia */
    foreign key (id_conductor) references conductor(id_conductor)
);


CREATE TABLE registro_vehiculo (
id_registro INT auto_increment NOT NULL PRIMARY KEY,
marca varchar(30) NOT NULL,
modelo varchar(30) NOT NULL,
patente varchar(30) NOT NULL,
registro_dt datetime
);

CREATE TABLE notificacion_solicitud (
id_notificacion INT auto_increment NOT NULL PRIMARY KEY,
mensaje TEXT,
solicitud_dt datetime
);


-- VISTAS
DROP VIEW IF exists vista_vehiculos;
CREATE VIEW vista_vehiculos AS
SELECT 
	v.id_vehiculo,
    m.nombre_marca as Marca,
    mo.nombre_modelo as Modelo,
    v.patente as Patente,
    p.nombre_pais as Pais_Origen
FROM 
    vehiculo v
INNER JOIN 
    marca m ON v.id_marca = m.id_marca
INNER JOIN 
    modelo mo ON v.id_modelo = mo.id_modelo
INNER JOIN
	pais p ON v.id_pais_origen = p.id_pais
ORDER BY v.id_vehiculo ASC;


DROP VIEW IF exists conductor_general;
CREATE VIEW conductor_general AS
SELECT 
  c.id_conductor,
  c.nombre,
  c.apellido,
  c.dni,
  c.email,
  c.fecha_nacimiento,
  COUNT(av.id_asignacion) AS cantidad_asignaciones,
  COUNT(v.id_viaje) AS cantidad_viajes
FROM 
  conductor c
  LEFT JOIN asignacion_vehiculo av ON c.id_conductor = av.id_conductor
  LEFT JOIN viaje v ON av.id_asignacion = v.id_asignacion
GROUP BY 
  c.id_conductor;


DROP VIEW IF exists Vehiculo_Mantenimiento_Resumen;
CREATE VIEW Vehiculo_Mantenimiento_Resumen AS
SELECT 
  v.id_vehiculo,
  v.patente,
  SUM(mv.costo) AS costo_mantenimiento_total,
  SUM(CASE WHEN mv.tipo_mantenimiento = 'Preventivo' THEN 1 ELSE 0 END) AS mantenimientos_preventivos,
  SUM(CASE WHEN mv.tipo_mantenimiento = 'Correctivo' THEN 1 ELSE 0 END) AS mantenimientos_correctivos,
  MAX(mv.fecha_mantenimiento) AS ultima_revision,
  MIN(mv.proxima_revision) AS proxima_revision
FROM 
  vehiculo v
  JOIN mantenimiento_vehiculo mv ON v.id_vehiculo = mv.id_vehiculo
GROUP BY 
  v.id_vehiculo;
  
  
DROP VIEW IF exists viaje_resumen;
CREATE VIEW viaje_resumen AS
SELECT 
  v.id_viaje,
  v.id_asignacion,
  v.monto,
  v.metodo_pago,
  ss.id_cliente,
  ss.ubicacion_origen,
  ss.ubicacion_destino,
  ss.estado AS estado_solicitud
FROM 
  viaje v
  JOIN solicitud_servicio ss ON v.id_solicitud = ss.id_solicitud;
  
  
DROP VIEW IF exists historial_conductor_vehiculo;
CREATE VIEW historial_conductor_vehiculo AS
SELECT 
  hc.id_historial,
  c.id_conductor,
  c.nombre,
  c.apellido,
  v.id_vehiculo,
  v.patente,
  hc.fecha_evento,
  hc.tipo_evento,
  hc.descripcion,
  hc.estado
FROM 
  historial_conductor hc
  JOIN conductor c ON hc.id_conductor = c.id_conductor
  JOIN asignacion_vehiculo av ON c.id_conductor = av.id_conductor
  JOIN vehiculo v ON av.id_vehiculo = v.id_vehiculo;



-- STORED PROCEDURES
DELIMITER //
DROP PROCEDURE IF EXISTS obtener_estado_conductores
//
CREATE PROCEDURE obtener_estado_conductores()
BEGIN

SELECT DISTINCT c.id_conductor, c.nombre AS nombre, c.apellido AS apellido, h.estado AS estado 
	FROM conductor c
	JOIN historial_conductor h ON c.id_conductor = h.id_conductor
	WHERE h.estado = "activo"
	ORDER BY  id_conductor asc, c.nombre, c.apellido;


SELECT DISTINCT c.id_conductor, c.nombre AS nombre, c.apellido AS apellido, h.estado AS estado 
	FROM conductor c
	JOIN historial_conductor h ON c.id_conductor = h.id_conductor
	WHERE h.estado = "sancionado"
	ORDER BY id_conductor asc, c.nombre, c.apellido;
    
SELECT h.estado, count(DISTINCT h.id_conductor) as cantidad_conductores
	FROM historial_conductor h
    GROUP BY h.estado
    HAVING h.estado IN ('activo','sancionado');

END
//


DELIMITER //
DROP PROCEDURE IF EXISTS analizar_rendimiento_conductores 
//
CREATE PROCEDURE analizar_rendimiento_conductores(
    IN p_fecha_inicio DATE, 
    IN p_fecha_fin DATE
)
BEGIN
    
    SELECT c.id_conductor, c.nombre, c.apellido,
           COUNT(v.id_viaje) AS cantidad_viajes,
           SUM(v.monto) AS monto_total_generado
    FROM conductor c
    JOIN asignacion_vehiculo av ON c.id_conductor = av.id_conductor
    JOIN viaje v ON av.id_asignacion = v.id_asignacion
    JOIN solicitud_servicio s ON v.id_solicitud = s.id_solicitud
    WHERE s.fecha_solicitud BETWEEN p_fecha_inicio AND p_fecha_fin 
    GROUP BY c.id_conductor, c.nombre, c.apellido
    ORDER BY monto_total_generado DESC;
END //



-- FUNCIONES
DELIMITER //
DROP FUNCTION IF EXISTS ultimo_mantenimiento 
//
CREATE FUNCTION ultimo_mantenimiento(
    vehiculo_id INT
) 
RETURNS VARCHAR(255)
DETERMINISTIC
BEGIN
    DECLARE fecha DATE DEFAULT NULL;
    DECLARE tipo VARCHAR(30) DEFAULT NULL;
    DECLARE descripcion TEXT DEFAULT NULL;
    DECLARE mensaje VARCHAR(255);

    SELECT fecha_mantenimiento, tipo_mantenimiento, descripcion
    INTO fecha, tipo, descripcion
    FROM mantenimiento_vehiculo
    WHERE id_vehiculo = vehiculo_id
    ORDER BY fecha_mantenimiento DESC
    LIMIT 1;


    IF fecha IS NOT NULL THEN
        SET mensaje = CONCAT('Fecha: ', IFNULL(fecha, 'N/A'), 
                             ', Tipo: ', IFNULL(tipo, 'N/A'));
    ELSE
        SET mensaje = 'No se ha registrado ningún mantenimiento para este vehículo.';
    END IF;

    RETURN mensaje;
END 
//


DELIMITER //
DROP FUNCTION IF EXISTS analizar_consumo_combustible
//
CREATE FUNCTION analizar_consumo_combustible(
    vehiculo_id INT,
    fecha_inicio DATE,
    fecha_fin DATE
) 
RETURNS VARCHAR(255)
DETERMINISTIC
BEGIN
    DECLARE total_consumo DECIMAL(10,2);
    DECLARE consumo_promedio DECIMAL(5,2);
    DECLARE nombre_modelo VARCHAR(30);
    DECLARE mensaje VARCHAR(255);
    
    SELECT SUM(costo_total)
    INTO total_consumo
    FROM combustible
    WHERE id_vehiculo = vehiculo_id
    AND fecha_recarga BETWEEN fecha_inicio AND fecha_fin;

    SELECT m.consumo_promedio
    INTO consumo_promedio
    FROM vehiculo v
    JOIN modelo m ON v.id_modelo = m.id_modelo
    WHERE v.id_vehiculo = vehiculo_id;
    
    SELECT m.nombre_modelo
    INTO nombre_modelo
    FROM vehiculo v
    JOIN modelo m ON v.id_modelo = m.id_modelo
    WHERE v.id_vehiculo = vehiculo_id;

    IF total_consumo IS NOT NULL THEN
        SET mensaje = CONCAT('Modelo:', nombre_modelo, "    "'Consumo total de combustible entre ', fecha_inicio, ' y ', fecha_fin, ': $', total_consumo, 
                             '. Consumo promedio del vehículo: ', consumo_promedio, ' l/100 km.');
    ELSE
        SET mensaje = 'No se registraron recargas de combustible para este vehículo en el período indicado.';
    END IF;

    RETURN mensaje;
END //  


DELIMITER //
DROP FUNCTION IF EXISTS ganancia
//
CREATE FUNCTION ganancia(
    ingresos_totales DECIMAL(10, 2),
    costo_combustible DECIMAL(10, 2),
    costo_mantenimiento DECIMAL(10, 2)
)
RETURNS DECIMAL(10, 2)
DETERMINISTIC
BEGIN
    DECLARE calcular_ganancia DECIMAL(10, 2);
    SET calcular_ganancia = ingresos_totales - (costo_combustible + costo_mantenimiento);
    RETURN calcular_ganancia;
END //



-- TRIGGERS
DELIMITER //
DROP TRIGGER IF EXISTS tr_after_insert_vehiculo
//
CREATE TRIGGER tr_after_insert_vehiculo AFTER INSERT ON vehiculo
FOR EACH ROW
BEGIN 

	DECLARE v_marca varchar(30);
    DECLARE v_modelo varchar(30);
    
    SELECT nombre_marca INTO v_marca from marca WHERE id_marca = NEW.id_marca;
	SELECT nombre_modelo INTO v_modelo from modelo  WHERE id_modelo = NEW.id_modelo;

	INSERT INTO registro_vehiculo(marca, modelo, patente, registro_dt)
	VALUES (v_marca, v_modelo, new.patente, sysdate());
    
END
//

DELIMITER //
DROP TRIGGER IF EXISTS tr_after_insert_solicitud 
//
CREATE TRIGGER tr_after_insert_solicitud AFTER INSERT ON solicitud_servicio 
FOR EACH ROW
BEGIN 
    DECLARE mensaje TEXT;
    
    SET mensaje = CONCAT("Solicitud de viaje: ", NEW.id_cliente, " desde ", NEW.ubicacion_origen, " hasta ", NEW.ubicacion_destino);
    
    INSERT INTO notificacion_solicitud(mensaje, solicitud_dt)
    VALUES (mensaje, SYSDATE());
    
END
//

select * from registro_vehiculo;


-- EJEMPLOS de CONSULTAS
-- select * from vista_vehiculos;
-- select * from conductor_general;
-- select * from Vehiculo_Mantenimiento_Resumen;
-- select * from viaje_resumen;
-- call obtener_estado_conductores();
-- call analizar_rendimiento_conductores('2023-10-08', '2024-10-05');
-- SELECT ultimo_mantenimiento(41);
-- SELECT ultimo_mantenimiento(17);
-- SELECT analizar_consumo_combustible(62, '2024-01-01', '2024-12-31');
-- SELECT ganancia(5000.00, 1200.00, 800.00);