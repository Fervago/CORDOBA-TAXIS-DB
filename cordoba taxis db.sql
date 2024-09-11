DROP DATABASE IF EXISTS CORDOBA_TAXIS;
CREATE DATABASE CORDOBA_TAXIS;
USE CORDOBA_TAXIS;


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

CREATE TABLE Viaje (
    id_viaje INT AUTO_INCREMENT PRIMARY KEY,
    id_asignacion INT NOT NULL,
    id_cliente INT NOT NULL,
    fecha_viaje DATE NOT NULL,
    hora_inicio TIME NOT NULL,
    hora_fin TIME NOT NULL,
    tarifa DECIMAL(10, 2) NOT NULL,
    foreign key (id_asignacion) references asignacion_vehiculo(id_asignacion),
	foreign key (id_cliente) references cliente(id_cliente)
);