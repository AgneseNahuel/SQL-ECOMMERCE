#													CREACION BASE DE DATOS
CREATE SCHEMA ecommerce;
USE ecommerce;
#													NUEVAS TABLAS

CREATE TABLE GENEROS(
	id_usuario INT AUTO_INCREMENT PRIMARY KEY,
    genero VARCHAR(30)
   
);

CREATE TABLE NACIONALIDADES(
	id_usuario INT AUTO_INCREMENT PRIMARY KEY,
    pais VARCHAR(30)    
);

CREATE TABLE PROVINCIAS (
	id_usuario INT AUTO_INCREMENT PRIMARY KEY,
    provincia VARCHAR(30)
);

#													CREACION DE TABLAS

CREATE TABLE usuarios (
	id INT AUTO_INCREMENT PRIMARY KEY,
	password VARCHAR(30),
	email VARCHAR(30),
    genero INT,
    pais INT,
    provincia INT,
    FOREIGN KEY (genero) REFERENCES GENEROS(id_usuario),
    FOREIGN KEY (pais) REFERENCES NACIONALIDADES(id_usuario),
    FOREIGN KEY (provincia) REFERENCES PROVINCIAS(id_usuario)
);

CREATE TABLE categorias (
	id INT AUTO_INCREMENT PRIMARY KEY,
	categoria VARCHAR(30),
	descripcion VARCHAR(50)
);

CREATE TABLE productos (
	id INT AUTO_INCREMENT PRIMARY KEY,
	producto VARCHAR(30),
	descripcion VARCHAR(30),
	precio FLOAT,
    categoria INT,
    FOREIGN KEY (categoria) REFERENCES categorias (id)
);


CREATE TABLE detalles_pedidos (
	id INT AUTO_INCREMENT PRIMARY KEY,
	cantidad int,
	id_producto INT,
	FOREIGN KEY (id_producto) REFERENCES productos (id)
);


CREATE TABLE pedidos (
	id INT AUTO_INCREMENT PRIMARY KEY,
	fecha DATE,
	id_usuario INT,
	FOREIGN KEY (id_usuario) REFERENCES usuarios (id),
    id_detalles_pedidos int,
    foreign key (id_detalles_pedidos) references detalles_pedidos (id)
);



CREATE TABLE RE_PRODUCTOS_CATEGORIAS (
	id INT AUTO_INCREMENT PRIMARY KEY,
    id_producto INT,
    id_categoria int,
	FOREIGN KEY (id_producto) REFERENCES productos (id),
    FOREIGN KEY (id_categoria) REFERENCES categorias (id)
);



#												TABLA AUDITORIA, LOG, 

CREATE TABLE AUDITORIAS_PRODUCTOS (
  id INT NOT NULL AUTO_INCREMENT,
  nombre_tabla VARCHAR(50) NOT NULL,
  tipo_accion VARCHAR(10) NOT NULL,
  fecha_hora TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  usuario VARCHAR(50) NOT NULL,
  PRIMARY KEY (id)
);


#----------------------------------------------------------------------------------------------------------------------------------------------
#												INCERCION DE DATOS

insert into usuarios (password, email) values
	("password1","nanana@hotmail.com"),
    ("password1","nanana@hotmail.com"),
    ("password1","nanana@hotmail.com"),
    ("password1","nanana@hotmail.com");

insert into categorias (categoria,descripcion) values 
	("Yoga","descripcion"),
    ("Gym","descripcion"),
    ("Deporte","descripcion"),
    ("Running","descripcion");
    
insert into productos (producto,descripcion,precio, categoria) values
	("Pantalon x","descripcion", 6.7,1),
    ("Remera x","descripcion", 6.7,2),
    ("Ropa Agregada","descripcion", 6.7,2),
    ("Short x","descripcion", 6.7,3),
    ("Gorra x","descripcion", 6.7,4);


insert into detalles_pedidos (cantidad, id_producto) values
	(30,2),
    (30,2),
    (30,2),
    (30,2);


INSERT INTO pedidos (fecha, id_usuario, id_detalles_pedidos) VALUES 
	('1997-10-15', 3, 2),
    ('1997-10-15', 3, 2),
    ('1997-10-15', 3, 2),
    ('1997-10-15', 3, 2);



insert into re_productos_categorias (id_producto,id_categoria) values
	(2,3),
    (2,3),
    (2,3),
    (2,3);

#------------------------------------------------------------------------------------------------------------------------------------------
#															VISTAS

#Ganancia total de todos los productos por separado.
CREATE VIEW ganancia AS
SELECT productos.producto as producto, SUM(detalles_pedidos.cantidad * productos.precio) as total_ganancia, productos.id
FROM productos, detalles_pedidos
group by productos.id;


#productos en stock, los productos no se van a repetir!
create view stock as
select productos.producto as producto, length(productos.producto) as cantidad
from productos
GROUP BY producto;

#ver categorias que estan relacionadas a un producto
CREATE VIEW relacion_producto AS
SELECT productos.producto as producto, categorias.categoria as categoria
FROM productos
INNER JOIN categorias ON productos.categoria = categorias.id;

#TODOS LOS MAILS
CREATE VIEW MAILS AS
SELECT USUARIOS.ID AS ID, usuarios.email AS email
from usuarios;

#IVA del precio base, en esta caso el IVA es del 65%
create view precio_IVA as
select PRODUCTOS.producto as Producto, (productos.precio * 0.65) + productos.precio as Precio_IVA
FROM productos;

#---------------------------------------------------------------------------------------------------------------------------------------
#													FUNCIONES

#CANTIDAD DE USUARIOS CREADOS
DELIMITER $$
CREATE FUNCTION cantidad_usuarios ()
RETURNS INTEGER
DETERMINISTIC
BEGIN

declare cantidad INT;
select count(id) into cantidad from usuarios;

RETURN cantidad;
END
$$

#CANTIDAD DE PEDIDOS REALIZADOS HACE MAS DE 3 DIAS
delimiter $$
CREATE FUNCTION pedido_antiguo(pedido_date DATE) 
RETURNS VARCHAR(20)
deterministic
BEGIN
DECLARE resultado VARCHAR(20);

IF DATEDIFF(NOW(), pedido_date) > 3 THEN
SET resultado = 'Antiguo';
ELSE
SET resultado = 'Reciente';
END IF;

RETURN resultado;
END
$$

#-------------------------------------------------------------------------------------------------------------------------------------
#													S.P

#ORDENAR LA TABLA USUARIOS
DELIMITER $$
CREATE PROCEDURE ordenarTabla(IN campoOrdenamiento VARCHAR(50), IN orden VARCHAR(4))
BEGIN
    SET @sql = CONCAT('SELECT * FROM usuarios ORDER BY ', campoOrdenamiento, ' ', orden);
    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END
$$

#BUSCAR, ELIMINA Y CREAR 
DELIMITER $$
CREATE PROCEDURE buscarEliminar (in idEliminar integer)
BEGIN
	DELETE FROM usuarios where id = idEliminar;
    
    INSERT INTO usuarios (id, password, email) values
    (idEliminar, "PaswordEliminado", "mailEliminado");
END
$$

#------------------------------------------------------------------------------------------------------------------------------------
#	 							TRIGGERS

DELIMITER $$
CREATE TRIGGER AUDITORIAS_PRODUCTOS_CREATE
AFTER INSERT ON PRODUCTOS
FOR EACH ROW
BEGIN
  INSERT INTO AUDITORIAS_PRODUCTOS (nombre_tabla, tipo_accion, usuario)
  VALUES ('PRODUCTOS', 'insertar', CURRENT_USER());
END;
$$

DELIMITER $$
CREATE TRIGGER AUDITORIAS_PRODUCTOS_UPDATE 
AFTER UPDATE ON PRODUCTOS
FOR EACH ROW
BEGIN
  INSERT INTO AUDITORIAS_PRODUCTOS (nombre_tabla, tipo_accion, usuario)
  VALUES ('PRODUCTOS', 'actualizar', CURRENT_USER());
END;
$$

DELIMITER $$
CREATE TRIGGER AUDITORIAS_PRODUCTOS_DELETE 
BEFORE DELETE ON PRODUCTOS
FOR EACH ROW
BEGIN
  INSERT INTO AUDITORIAS_PRODUCTOS (nombre_tabla, tipo_accion, usuario)
  VALUES ('PRODUCTOS', 'eliminar', CURRENT_USER());
END;
$$

#----------------------------------------------------------------------------------------------------------------------------
#											CREACION DE USUARIOS Y PERMISOS!


# Usuario Carolina
CREATE USER 'Carolina'@'localhost' IDENTIFIED BY 'contraseñaCarolina';

GRANT SELECT, UPDATE ON ecommerce.productos TO 'Carolina'@'localhost';
GRANT SELECT (pais, provincia), UPDATE (pais, provincia) ON ecommerce.usuarios TO 'Carolina'@'localhost';
GRANT SELECT ON ecommerce.pedidos TO 'Carolina'@'localhost';
GRANT SELECT, UPDATE, INSERT ON ecommerce.categorias TO 'Carolina'@'localhost';

# Usuario Nacho (solo lectura)
CREATE USER 'Nacho'@'localhost' IDENTIFIED BY 'contraseñaNacho';

GRANT SELECT ON *.* TO 'Nacho'@'localhost';


#-----------------------------------------------------------------------------------------------------------------------------
#											TCL

#SELECT @@AUTOCOMMIT;
#SET AUTOCOMMIT=0;

#PRIMER TABLA "USUARIOS"
#START TRANSACTION;

#CAMBIO EL PASSWORD DEL ID 1 Y AGREGO UN SAVEPOINT
#UPDATE usuarios
#SET password="CAMBIO 1"
#WHERE id=1;
#SAVEPOINT LOTE1;
#PRUEBO DE CAMBIAR EL PS DEL ID 2 Y AGREGO UN SAVEPOINT
#UPDATE usuarios
#SET password="CAMBIO 2"
#WHERE id=2;
#SAVEPOINT LOTE2;
#*SE DA CUENTA QUE EL SEGUNDO CAMBIO NO VA A NINGUN LADO Y VUELVE AL LOTE 1
#ROLLBACK TO LOTE1;
#CONFIRMA QUE SIRVE Y COMMITEA
#COMMIT;


#SEGUNDA TABLA "PRODUCTOS"
#START TRANSACTION;
#*QUIERE ELIMINAR EL ID 3
#DELETE FROM productos
#WHERE id>3;
#*SE DA CUENTA QUE SE EQUIVOCO Y VUELVE AL PRINCIPIO
#ROLLBACK;
#LO HACE BIEN Y COMMITEA
#DELETE FROM productos
#WHERE id=3;
#COMMIT;
