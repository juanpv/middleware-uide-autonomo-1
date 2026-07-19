-- ====================================================================
--  RAÍZ URBANA — Vivero digital de plantas de interior
--  Script de base de datos relacional (modelo normalizado 3FN)
--  Motor de referencia: MySQL 8.x
--  Notas de portabilidad:
--    * SQL Server: reemplazar  AUTO_INCREMENT  por  IDENTITY(1,1)
--                  y  TINYINT(1)  por  BIT ; DATETIME por DATETIME2.
--    * PostgreSQL: reemplazar  INT AUTO_INCREMENT  por  SERIAL
--                  y  TINYINT(1)  por  BOOLEAN.
-- ====================================================================

DROP DATABASE IF EXISTS raiz_urbana;
CREATE DATABASE raiz_urbana CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE raiz_urbana;

-- ====================================================================
--  1. CREACIÓN DE TABLAS (DDL)
-- ====================================================================

-- 1) Categoría de productos --------------------------------------------------
CREATE TABLE categoria (
    id_categoria  INT AUTO_INCREMENT PRIMARY KEY,
    nombre        VARCHAR(60)  NOT NULL UNIQUE,
    descripcion   VARCHAR(200)
);

-- 2) Proveedor ---------------------------------------------------------------
CREATE TABLE proveedor (
    id_proveedor  INT AUTO_INCREMENT PRIMARY KEY,
    nombre        VARCHAR(120) NOT NULL,
    ruc           VARCHAR(13)  UNIQUE,
    telefono      VARCHAR(20),
    email         VARCHAR(120),
    ciudad        VARCHAR(60)
);

-- 3) Producto ----------------------------------------------------------------
CREATE TABLE producto (
    id_producto   INT AUTO_INCREMENT PRIMARY KEY,
    nombre        VARCHAR(120)  NOT NULL,
    descripcion   VARCHAR(300),
    precio        DECIMAL(10,2) NOT NULL,
    stock         INT           NOT NULL DEFAULT 0,
    activo        TINYINT(1)    NOT NULL DEFAULT 1,
    id_categoria  INT           NOT NULL,
    id_proveedor  INT,
    CONSTRAINT fk_producto_categoria FOREIGN KEY (id_categoria) REFERENCES categoria(id_categoria),
    CONSTRAINT fk_producto_proveedor FOREIGN KEY (id_proveedor) REFERENCES proveedor(id_proveedor),
    CONSTRAINT chk_producto_precio  CHECK (precio >= 0),
    CONSTRAINT chk_producto_stock   CHECK (stock  >= 0)
);

-- 4) Cliente -----------------------------------------------------------------
CREATE TABLE cliente (
    id_cliente     INT AUTO_INCREMENT PRIMARY KEY,
    nombre         VARCHAR(80)  NOT NULL,
    apellido       VARCHAR(80)  NOT NULL,
    email          VARCHAR(120) NOT NULL UNIQUE,
    telefono       VARCHAR(20),
    fecha_registro DATE         NOT NULL
);

-- 5) Dirección (un cliente puede tener varias) -------------------------------
CREATE TABLE direccion (
    id_direccion  INT AUTO_INCREMENT PRIMARY KEY,
    id_cliente    INT          NOT NULL,
    calle         VARCHAR(150) NOT NULL,
    ciudad        VARCHAR(60)  NOT NULL,
    referencia    VARCHAR(150),
    es_principal  TINYINT(1)   NOT NULL DEFAULT 0,
    CONSTRAINT fk_direccion_cliente FOREIGN KEY (id_cliente) REFERENCES cliente(id_cliente)
);

-- 6) Empleado ----------------------------------------------------------------
CREATE TABLE empleado (
    id_empleado    INT AUTO_INCREMENT PRIMARY KEY,
    nombre         VARCHAR(80)  NOT NULL,
    apellido       VARCHAR(80)  NOT NULL,
    cargo          VARCHAR(60),
    email          VARCHAR(120) UNIQUE,
    fecha_ingreso  DATE
);

-- 7) Método de pago ----------------------------------------------------------
CREATE TABLE metodo_pago (
    id_metodo  INT AUTO_INCREMENT PRIMARY KEY,
    nombre     VARCHAR(50) NOT NULL UNIQUE
);

-- 8) Pedido ------------------------------------------------------------------
CREATE TABLE pedido (
    id_pedido     INT AUTO_INCREMENT PRIMARY KEY,
    id_cliente    INT      NOT NULL,
    id_empleado   INT,
    id_direccion  INT      NOT NULL,
    fecha_pedido  DATETIME NOT NULL,
    estado        VARCHAR(30) NOT NULL DEFAULT 'Pendiente',
    total         DECIMAL(10,2) NOT NULL DEFAULT 0,
    CONSTRAINT fk_pedido_cliente   FOREIGN KEY (id_cliente)   REFERENCES cliente(id_cliente),
    CONSTRAINT fk_pedido_empleado  FOREIGN KEY (id_empleado)  REFERENCES empleado(id_empleado),
    CONSTRAINT fk_pedido_direccion FOREIGN KEY (id_direccion) REFERENCES direccion(id_direccion),
    CONSTRAINT chk_pedido_estado CHECK (estado IN ('Pendiente','Pagado','Enviado','Entregado','Cancelado'))
);

-- 9) Detalle de pedido (resuelve la relación N:M Pedido-Producto) -------------
CREATE TABLE detalle_pedido (
    id_detalle      INT AUTO_INCREMENT PRIMARY KEY,
    id_pedido       INT NOT NULL,
    id_producto     INT NOT NULL,
    cantidad        INT NOT NULL,
    precio_unitario DECIMAL(10,2) NOT NULL,
    CONSTRAINT fk_detalle_pedido   FOREIGN KEY (id_pedido)   REFERENCES pedido(id_pedido),
    CONSTRAINT fk_detalle_producto FOREIGN KEY (id_producto) REFERENCES producto(id_producto),
    CONSTRAINT uq_detalle UNIQUE (id_pedido, id_producto),
    CONSTRAINT chk_detalle_cantidad CHECK (cantidad > 0)
);

-- 10) Pago -------------------------------------------------------------------
CREATE TABLE pago (
    id_pago     INT AUTO_INCREMENT PRIMARY KEY,
    id_pedido   INT NOT NULL UNIQUE,
    id_metodo   INT NOT NULL,
    monto       DECIMAL(10,2) NOT NULL,
    fecha_pago  DATETIME NOT NULL,
    estado      VARCHAR(30) NOT NULL DEFAULT 'Aprobado',
    CONSTRAINT fk_pago_pedido FOREIGN KEY (id_pedido) REFERENCES pedido(id_pedido),
    CONSTRAINT fk_pago_metodo FOREIGN KEY (id_metodo) REFERENCES metodo_pago(id_metodo)
);

-- 11) Envío ------------------------------------------------------------------
CREATE TABLE envio (
    id_envio       INT AUTO_INCREMENT PRIMARY KEY,
    id_pedido      INT NOT NULL UNIQUE,
    transportadora VARCHAR(80),
    guia           VARCHAR(50),
    fecha_envio    DATE,
    fecha_entrega  DATE,
    estado         VARCHAR(30) NOT NULL DEFAULT 'Preparando',
    CONSTRAINT fk_envio_pedido FOREIGN KEY (id_pedido) REFERENCES pedido(id_pedido)
);

-- 12) Reseña -----------------------------------------------------------------
CREATE TABLE resena (
    id_resena     INT AUTO_INCREMENT PRIMARY KEY,
    id_cliente    INT NOT NULL,
    id_producto   INT NOT NULL,
    calificacion  INT NOT NULL,
    comentario    VARCHAR(300),
    fecha         DATE NOT NULL,
    CONSTRAINT fk_resena_cliente  FOREIGN KEY (id_cliente)  REFERENCES cliente(id_cliente),
    CONSTRAINT fk_resena_producto FOREIGN KEY (id_producto) REFERENCES producto(id_producto),
    CONSTRAINT uq_resena UNIQUE (id_cliente, id_producto),
    CONSTRAINT chk_resena_calif CHECK (calificacion BETWEEN 1 AND 5)
);

-- 13) Promoción (oferta del mes) ---------------------------------------------
CREATE TABLE promocion (
    id_promocion  INT AUTO_INCREMENT PRIMARY KEY,
    id_producto   INT NOT NULL,
    titulo        VARCHAR(120) NOT NULL,
    descuento     DECIMAL(5,2) NOT NULL,
    precio_oferta DECIMAL(10,2) NOT NULL,
    fecha_inicio  DATE NOT NULL,
    fecha_fin     DATE NOT NULL,
    CONSTRAINT fk_promocion_producto FOREIGN KEY (id_producto) REFERENCES producto(id_producto),
    CONSTRAINT chk_promocion_fechas CHECK (fecha_fin >= fecha_inicio)
);

-- 14) Noticia ----------------------------------------------------------------
CREATE TABLE noticia (
    id_noticia         INT AUTO_INCREMENT PRIMARY KEY,
    id_empleado        INT,
    titulo             VARCHAR(150) NOT NULL,
    contenido          TEXT,
    fecha_publicacion  DATE NOT NULL,
    CONSTRAINT fk_noticia_empleado FOREIGN KEY (id_empleado) REFERENCES empleado(id_empleado)
);

-- ====================================================================
--  2. CARGA DE DATOS DE EJEMPLO (DML - INSERT)
-- ====================================================================

INSERT INTO categoria (nombre, descripcion) VALUES
 ('Plantas',    'Plantas de interior y exterior'),
 ('Macetas',    'Macetas de diseño en distintos materiales'),
 ('Accesorios', 'Sustratos, herramientas y complementos de jardinería');

INSERT INTO proveedor (nombre, ruc, telefono, email, ciudad) VALUES
 ('Vivero Los Andes',    '1790011223001', '022345678', 'ventas@losandes.ec',   'Quito'),
 ('Cerámicas del Valle', '1790099887001', '022998877', 'info@ceramicasv.ec',   'Cuenca'),
 ('AgroInsumos EC',      '1790055443001', '042556677', 'contacto@agroinsumos.ec','Guayaquil');

INSERT INTO producto (nombre, descripcion, precio, stock, id_categoria, id_proveedor) VALUES
 ('Monstera Deliciosa',   'Hojas amplias y tropicales.',            24.90, 40, 1, 1),
 ('Pothos Dorado',        'Enredadera resistente que purifica.',    12.50, 65, 1, 1),
 ('Cactus San Pedro',     'Cactus columnar de bajo mantenimiento.',  9.90, 50, 1, 1),
 ('Suculenta Echeveria',  'Roseta compacta y decorativa.',           6.50, 80, 1, 1),
 ('Ficus Lyrata',         'La famosa hoja de violin.',              34.00, 25, 1, 1),
 ('Sansevieria',          'Lengua de suegra, casi indestructible.', 15.90, 45, 1, 1),
 ('Kokedama Colgante',    'Arte japones en musgo.',                 16.00, 30, 1, 1),
 ('Maceta Ceramica',      'Maceta artesanal de terracota.',         11.00, 70, 2, 2),
 ('Sustrato Universal 5L','Mezcla equilibrada para plantas.',        7.90,100, 3, 3),
 ('Regadera Vintage',     'Regadera metalica de diseno retro.',     18.50, 35, 3, 3);

INSERT INTO cliente (nombre, apellido, email, telefono, fecha_registro) VALUES
 ('Ana',    'Mora',      'ana.mora@correo.com',    '0991112233', '2026-01-15'),
 ('Luis',   'Paredes',   'luis.paredes@correo.com','0982223344', '2026-02-20'),
 ('Carla',  'Suárez',    'carla.suarez@correo.com','0973334455', '2026-03-05'),
 ('Diego',  'Torres',    'diego.torres@correo.com','0964445566', '2026-04-10');

INSERT INTO direccion (id_cliente, calle, ciudad, referencia, es_principal) VALUES
 (1, 'Av. Amazonas N34-120', 'Quito', 'Frente al parque', 1),
 (1, 'Calle Los Pinos 45',   'Quito', 'Casa esquinera',   0),
 (2, 'Av. 6 de Diciembre 88','Quito', 'Edificio Azul',    1),
 (3, 'Cdla. Kennedy Mz 5',   'Guayaquil','Villa 12',      1),
 (4, 'Av. Solano 3-40',      'Cuenca','Departamento 2B',  1);

INSERT INTO empleado (nombre, apellido, cargo, email, fecha_ingreso) VALUES
 ('María',  'Vega',   'Gerente',       'maria.vega@raizurbana.ec',  '2024-01-10'),
 ('Jorge',  'Loor',   'Vendedor',      'jorge.loor@raizurbana.ec',  '2024-03-15'),
 ('Sofía',  'Ramírez','Community Manager','sofia.r@raizurbana.ec',  '2024-06-01');

INSERT INTO metodo_pago (nombre) VALUES
 ('Tarjeta de crédito'), ('Transferencia'), ('Efectivo'), ('PayPal');

INSERT INTO pedido (id_cliente, id_empleado, id_direccion, fecha_pedido, estado, total) VALUES
 (1, 2, 1, '2026-07-01 10:30:00', 'Entregado', 61.30),
 (2, 2, 3, '2026-07-05 15:10:00', 'Enviado',   34.00),
 (3, 1, 4, '2026-07-10 09:45:00', 'Pagado',    24.40);

INSERT INTO detalle_pedido (id_pedido, id_producto, cantidad, precio_unitario) VALUES
 (1, 1, 1, 24.90),
 (1, 8, 2, 11.00),
 (1, 4, 2,  6.50),
 (2, 5, 1, 34.00),
 (3, 6, 1, 15.90),
 (3, 9, 1,  7.90);

INSERT INTO pago (id_pedido, id_metodo, monto, fecha_pago, estado) VALUES
 (1, 1, 61.30, '2026-07-01 10:32:00', 'Aprobado'),
 (2, 2, 34.00, '2026-07-05 15:12:00', 'Aprobado'),
 (3, 4, 24.40, '2026-07-10 09:47:00', 'Aprobado');

INSERT INTO envio (id_pedido, transportadora, guia, fecha_envio, fecha_entrega, estado) VALUES
 (1, 'Servientrega', 'SE0012345', '2026-07-01', '2026-07-03', 'Entregado'),
 (2, 'Laar Courier', 'LC0098765', '2026-07-06', NULL,         'En tránsito');

INSERT INTO resena (id_cliente, id_producto, calificacion, comentario, fecha) VALUES
 (1, 1, 5, 'La Monstera llegó preciosa y saludable.', '2026-07-04'),
 (1, 8, 4, 'Buena maceta, colores lindos.',            '2026-07-04'),
 (2, 5, 5, 'El Ficus es enorme, súper feliz.',         '2026-07-08');

INSERT INTO promocion (id_producto, titulo, descuento, precio_oferta, fecha_inicio, fecha_fin) VALUES
 (5, 'Oferta del mes: Ficus Lyrata -33%', 33.00, 22.90, '2026-07-01', '2026-07-31');

INSERT INTO noticia (id_empleado, titulo, contenido, fecha_publicacion) VALUES
 (3, 'Abrimos nuestra segunda tienda en Cumbayá', 'Raíz Urbana llega a Cumbayá con más de 300 especies.', '2026-07-10'),
 (3, 'Taller gratuito: plantas que purifican el aire', 'Cupos limitados, inscríbete en tienda.', '2026-06-28');

-- ====================================================================
--  3. OPERACIONES CRUD
--     (Create · Read · Update · Delete)
-- ====================================================================

-- ---------- C R E A T E  (INSERT) -----------------------------------
-- Registrar un nuevo cliente
INSERT INTO cliente (nombre, apellido, email, telefono, fecha_registro)
VALUES ('Paula', 'Andrade', 'paula.andrade@correo.com', '0955556677', '2026-07-15');

-- Registrar un nuevo producto en el catálogo
INSERT INTO producto (nombre, descripcion, precio, stock, id_categoria, id_proveedor)
VALUES ('Calathea Orbifolia', 'Follaje decorativo de rayas plateadas.', 21.00, 20, 1, 1);

-- ---------- R E A D  (SELECT) ---------------------------------------
-- a) Listar el catálogo con su categoría y proveedor
SELECT p.id_producto, p.nombre, c.nombre AS categoria,
       pr.nombre AS proveedor, p.precio, p.stock
FROM producto p
JOIN categoria  c  ON c.id_categoria  = p.id_categoria
LEFT JOIN proveedor pr ON pr.id_proveedor = p.id_proveedor
ORDER BY c.nombre, p.nombre;

-- b) Detalle completo de un pedido con su total calculado
SELECT ped.id_pedido,
       CONCAT(cli.nombre, ' ', cli.apellido) AS cliente,
       pro.nombre AS producto,
       dp.cantidad,
       dp.precio_unitario,
       (dp.cantidad * dp.precio_unitario) AS subtotal
FROM pedido ped
JOIN cliente cli        ON cli.id_cliente  = ped.id_cliente
JOIN detalle_pedido dp  ON dp.id_pedido    = ped.id_pedido
JOIN producto pro       ON pro.id_producto = dp.id_producto
WHERE ped.id_pedido = 1;

-- c) Calificación promedio por producto
SELECT pr.nombre, ROUND(AVG(r.calificacion),2) AS promedio, COUNT(*) AS n_resenas
FROM resena r
JOIN producto pr ON pr.id_producto = r.id_producto
GROUP BY pr.nombre
ORDER BY promedio DESC;

-- ---------- U P D A T E ---------------------------------------------
-- Aplicar el precio de oferta al producto en promoción
UPDATE producto
SET precio = 22.90
WHERE id_producto = 5;

-- Cambiar el estado de un pedido a "Entregado"
UPDATE pedido
SET estado = 'Entregado'
WHERE id_pedido = 2;

-- Descontar stock tras una venta
UPDATE producto
SET stock = stock - 1
WHERE id_producto = 6 AND stock > 0;

-- ---------- D E L E T E ---------------------------------------------
-- Eliminar una reseña específica
DELETE FROM resena
WHERE id_resena = 2;

-- Eliminar una dirección secundaria de un cliente
DELETE FROM direccion
WHERE id_direccion = 2 AND es_principal = 0;

-- ====================================================================
--  FIN DEL SCRIPT
-- ====================================================================
