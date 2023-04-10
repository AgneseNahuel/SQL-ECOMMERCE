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
	FOREIGN KEY (id_usuario) REFERENCES usuarios (id),
    id_detalles_pedidos int,
    foreign key (id_detalles_pedidos) references detalles_pedidos (id)
);

CREATE TABLE productos (
	id INT AUTO_INCREMENT PRIMARY KEY,
	nombre VARCHAR(30),
	descripcion VARCHAR(30),
	precio FLOAT,
	id_pedido INT
);

CREATE TABLE categorias (
	id INT AUTO_INCREMENT PRIMARY KEY,
	nombre VARCHAR(30),
	descripcion VARCHAR(50),
    id_producto INT,
    FOREIGN KEY (id_producto) REFERENCES productos (id)
);

CREATE TABLE detalles_pedidos (
	id INT AUTO_INCREMENT PRIMARY KEY,
	cantidad int,
	id_producto INT,
	FOREIGN KEY (id_producto) REFERENCES productos (id)
);

CREATE TABLE RE_PRODUCTOS_CATEGORIAS (
	id INT AUTO_INCREMENT PRIMARY KEY,
    id_producto INT,
    id_categoria int,
	FOREIGN KEY (id_producto) REFERENCES productos (id),
    FOREIGN KEY (id_categoria) REFERENCES categorias (id)
);





drop SCHEMA ecommerce;