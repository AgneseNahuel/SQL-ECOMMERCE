CREATE SCHEMA ecommerce;
USE ecommerce;

CREATE TABLE usuarios (
	id INT AUTO_INCREMENT PRIMARY KEY,
	password VARCHAR(30),
	email VARCHAR(30)
);

CREATE TABLE pedidos (
	id INT AUTO_INCREMENT PRIMARY KEY,
	fecha DATE,
	id_usuario INT,
	FOREIGN KEY (id_usuario) REFERENCES usuarios (id)
);

CREATE TABLE productos (
	id INT AUTO_INCREMENT PRIMARY KEY,
	nombre VARCHAR(30),
	descripcion VARCHAR(30),
	precio FLOAT,
	id_pedido INT,
	FOREIGN KEY (id_pedido) REFERENCES pedidos (id)
);

CREATE TABLE categorias (
	id INT AUTO_INCREMENT PRIMARY KEY,
	nombre VARCHAR(30),
	descripcion VARCHAR(50),
    id_producto INT,
    #agregada
    FOREIGN KEY (id_producto) REFERENCES productos (id)
);

CREATE TABLE detalles_pedidos (
	id INT AUTO_INCREMENT PRIMARY KEY,
	cantidad FLOAT,
	id_producto INT,
	FOREIGN KEY (id_producto) REFERENCES productos (id)
);

alter table pedidos add id_detalles_pedidos INT;
alter table pedidos add FOREIGN KEY (id_detalles_pedidos) REFERENCES detalles_pedidos (id);

ALTER TABLE detalles_pedidos MODIFY cantidad INT;