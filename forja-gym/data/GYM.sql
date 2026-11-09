-- ============================================================
-- BASE DE DATOS: GIMNASIO
-- Sistema de gestión de socios, planes, clases, profesores y pagos
-- Autor: Merlín Ian Cumar Vinci
-- ============================================================




-- ------------------------------------------------------------
-- 1. TABLAS
-- ------------------------------------------------------------
CREATE TABLE socio (
    id_socio SERIAL PRIMARY KEY,
    nombre VARCHAR(40) NOT NULL,
    apellido VARCHAR(40) NOT NULL,
    dni VARCHAR(10) NOT NULL UNIQUE,
    telefono VARCHAR(20),
    fecha_nacimiento DATE,
    fecha_alta DATE NOT NULL DEFAULT CURRENT_DATE
);


CREATE TABLE plan (
    id_plan SERIAL PRIMARY KEY,
    nombre VARCHAR(40) NOT NULL,
    precio NUMERIC(10, 2) NOT NULL,
    duracion_dias INTEGER NOT NULL
);


CREATE TABLE profesor (
    id_profesor SERIAL PRIMARY KEY,
    nombre VARCHAR(40) NOT NULL,
    apellido VARCHAR(40) NOT NULL,
    especialidad VARCHAR(40)
);


CREATE TABLE clase (
    id_clase SERIAL PRIMARY KEY,
    nombre VARCHAR(40) NOT NULL,
    dia VARCHAR(15) NOT NULL,
    horario TIME NOT NULL,
    cupo_maximo INTEGER NOT NULL,
    id_profesor INTEGER NOT NULL,
    FOREIGN KEY (id_profesor) REFERENCES profesor (id_profesor)
);



-- Tabla intermedia del muchos a muchos socio <-> clase.
-- La PK compuesta impide inscribir dos veces al mismo socio en la misma clase.
CREATE TABLE inscripcion_clase (
    id_socio INTEGER NOT NULL,
    id_clase INTEGER NOT NULL,
    fecha_inscripcion DATE NOT NULL DEFAULT CURRENT_DATE,
    PRIMARY KEY (id_socio, id_clase),
    FOREIGN KEY (id_socio) REFERENCES socio (id_socio),
    FOREIGN KEY (id_clase) REFERENCES clase (id_clase)
);


CREATE TABLE pago (
    id_pago SERIAL PRIMARY KEY,
    id_socio INTEGER NOT NULL,
    id_plan INTEGER NOT NULL,
    fecha DATE NOT NULL,
    monto NUMERIC(10, 2) NOT NULL,
    FOREIGN KEY (id_socio) REFERENCES socio (id_socio),
    FOREIGN KEY (id_plan) REFERENCES plan (id_plan)
);





-- ------------------------------------------------------------
-- 2. CARGA DE DATOS
-- ------------------------------------------------------------

-- SOCIO (ids 1 a 8)
INSERT INTO socio (nombre, apellido, dni, telefono, fecha_nacimiento, fecha_alta)
VALUES
 ('Lucas', 'Fernández', '30111222', '3548-111111', '1995-04-12', '2026-01-10'), -- 1
 ('María', 'López', '32333444', '3548-222222', '1998-09-03', '2026-01-15'), -- 2
 ('Tomás', 'Sosa', '28555666', '3548-333333', '1990-12-21', '2026-02-01'), -- 3
 ('Valentina', 'Díaz', '40777888', '3548-444444', '2001-06-30', '2026-02-10'), -- 4
 ('Camila', 'Romero', '35999000', '3548-555555', '1997-03-08', '2026-03-05'), -- 5
 ('Nicolás', 'Torres', '33121314', '3548-666666', '1994-11-17', '2026-03-20'), -- 6
 ('Julieta', 'Álvarez', '41151617', '3548-777777', '2002-01-25', '2026-04-02'), -- 7
 ('Franco', 'Medina', '29181920', '3548-888888', '1989-07-14', '2026-04-18'); -- 8


-- PLAN (ids 1 a 4)
INSERT INTO plan (nombre, precio, duracion_dias)
VALUES
 ('Musculación', 25000, 30), -- 1
 ('Clases grupales', 28000, 30), -- 2
 ('Full', 38000, 30), -- 3
 ('Pase libre trimestral', 100000, 90); -- 4


-- PROFESOR (ids 1 a 3)
INSERT INTO profesor (nombre, apellido, especialidad)
VALUES
 ('Martín', 'Acosta', 'Funcional'), -- 1
 ('Paula', 'Rivas', 'Yoga'), -- 2
 ('Bruno', 'Herrera', 'Spinning'); -- 3


-- CLASE (ids 1 a 5)
INSERT INTO clase (nombre, dia, horario, cupo_maximo, id_profesor)
VALUES
 ('Funcional', 'Lunes', '19:00', 20, 1), -- 1
 ('Funcional', 'Miércoles', '19:00', 20, 1), -- 2
 ('Yoga', 'Martes', '18:00', 15, 2), -- 3
 ('Yoga', 'Jueves', '18:00', 15, 2), -- 4
 ('Spinning', 'Viernes', '20:00', 12, 3); -- 5


-- INSCRIPCION_CLASE (socio, clase, fecha)
INSERT INTO inscripcion_clase (id_socio, id_clase, fecha_inscripcion)
VALUES
 (1, 1, '2026-01-12'),
 (1, 3, '2026-01-12'),
 (2, 1, '2026-01-16'),
 (2, 5, '2026-01-20'),
 (3, 2, '2026-02-02'),
 (4, 3, '2026-02-11'),
 (4, 4, '2026-02-11'),
 (5, 5, '2026-03-06'),
 (6, 1, '2026-03-21'),
 (7, 3, '2026-04-03'),
 (7, 4, '2026-04-03'),
 (8, 2, '2026-04-19');


-- PAGO (socio, plan, fecha, monto)
INSERT INTO pago (id_socio, id_plan, fecha, monto)
VALUES
 (1, 3, '2026-01-10', 38000),
 (1, 3, '2026-02-10', 38000),
 (1, 3, '2026-03-10', 38000),
 (2, 2, '2026-01-15', 28000),
 (2, 2, '2026-02-15', 28000),
 (3, 1, '2026-02-01', 25000),
 (3, 1, '2026-03-01', 25000),
 (4, 3, '2026-02-10', 38000),
 (5, 2, '2026-03-05', 28000),
 (6, 1, '2026-03-20', 25000),
 (7, 4, '2026-04-02', 100000),
 (8, 1, '2026-04-18', 25000);




-- ============================================================
-- 3. CONSULTAS DE PRUEBA
-- ============================================================

-- Ver el contenido de cada tabla
SELECT * FROM socio;
SELECT * FROM plan;
SELECT * FROM profesor;
SELECT * FROM clase;
SELECT * FROM inscripcion_clase;
SELECT * FROM pago;


-- Cada clase con el nombre de su profesor (INNER JOIN)
SELECT clase.nombre, clase.dia, clase.horario, profesor.apellido AS profesor
FROM clase
INNER JOIN profesor ON clase.id_profesor = profesor.id_profesor
ORDER BY clase.dia, clase.horario;


-- Socios inscriptos en cada clase (atraviesa el muchos a muchos)
SELECT socio.apellido, socio.nombre, clase.nombre AS clase, clase.dia
FROM socio
INNER JOIN inscripcion_clase ON socio.id_socio = inscripcion_clase.id_socio
INNER JOIN clase ON inscripcion_clase.id_clase = clase.id_clase
ORDER BY socio.apellido;


-- Total pagado por cada socio (LEFT JOIN: incluye a los que no pagaron)
SELECT socio.apellido, socio.nombre, COALESCE(SUM(pago.monto), 0) AS total_pagado
FROM socio
LEFT JOIN pago ON socio.id_socio = pago.id_socio
GROUP BY socio.apellido, socio.nombre
ORDER BY total_pagado DESC;


-- Clases con más de 1 socio inscripto (HAVING)
SELECT clase.nombre, clase.dia, COUNT(inscripcion_clase.id_socio) AS inscriptos
FROM clase
INNER JOIN inscripcion_clase ON clase.id_clase = inscripcion_clase.id_clase
GROUP BY clase.nombre, clase.dia
HAVING COUNT(inscripcion_clase.id_socio) > 1;




-- ============================================================
-- FIN
-- ============================================================



- Tp4-Modelo Físico Primera entrega
- ------------------------------------------------------------
-- 1. CREACIÓN DE TABLAS
-- ------------------------------------------------------------
DROP TABLE IF EXISTS pago CASCADE;
DROP TABLE IF EXISTS inscripcion_clase CASCADE;
DROP TABLE IF EXISTS clase CASCADE;
DROP TABLE IF EXISTS profesor CASCADE;
DROP TABLE IF EXISTS plan CASCADE;
DROP TABLE IF EXISTS socio CASCADE;

CREATE TABLE socio (
    id_socio SERIAL PRIMARY KEY,
    nombre VARCHAR(40) NOT NULL,
    apellido VARCHAR(40) NOT NULL,
    dni VARCHAR(10) NOT NULL UNIQUE,
    telefono VARCHAR(20),
    fecha_nacimiento DATE,
    fecha_alta DATE NOT NULL DEFAULT CURRENT_DATE
);

CREATE TABLE plan (
    id_plan SERIAL PRIMARY KEY,
    nombre VARCHAR(40) NOT NULL,
    precio NUMERIC(10, 2) NOT NULL,
    duracion_dias INTEGER NOT NULL
);

CREATE TABLE profesor (
    id_profesor SERIAL PRIMARY KEY,
    nombre VARCHAR(40) NOT NULL,
    apellido VARCHAR(40) NOT NULL,
    especialidad VARCHAR(40)
);

CREATE TABLE clase (
    id_clase SERIAL PRIMARY KEY,
    nombre VARCHAR(40) NOT NULL,
    dia VARCHAR(15) NOT NULL,
    horario TIME NOT NULL,
    cupo_maximo INTEGER NOT NULL,
    id_profesor INTEGER NOT NULL,
    FOREIGN KEY (id_profesor) REFERENCES profesor (id_profesor)
);

CREATE TABLE inscripcion_clase (
    id_socio INTEGER NOT NULL,
    id_clase INTEGER NOT NULL,
    fecha_inscripcion DATE NOT NULL DEFAULT CURRENT_DATE,
    PRIMARY KEY (id_socio, id_clase),
    FOREIGN KEY (id_socio) REFERENCES socio (id_socio),
    FOREIGN KEY (id_clase) REFERENCES clase (id_clase)
);

CREATE TABLE pago (
    id_pago SERIAL PRIMARY KEY,
    id_socio INTEGER NOT NULL,
    id_plan INTEGER NOT NULL,
    fecha DATE NOT NULL,
    monto NUMERIC(10, 2) NOT NULL,
    FOREIGN KEY (id_socio) REFERENCES socio (id_socio),
    FOREIGN KEY (id_plan) REFERENCES plan (id_plan)
);


-- ------------------------------------------------------------
-- 2. CARGA DE DATOS (Mínimo 15 registros por tabla)
-- ------------------------------------------------------------

-- SOCIO (18 registros)
INSERT INTO socio (nombre, apellido, dni, telefono, fecha_nacimiento, fecha_alta) VALUES
 ('Lucas', 'Fernández', '30111222', '3548-111111', '1995-04-12', '2026-01-10'),
 ('María', 'López', '32333444', '3548-222222', '1998-09-03', '2026-01-15'),
 ('Tomás', 'Sosa', '28555666', '3548-333333', '1990-12-21', '2026-02-01'),
 ('Valentina', 'Díaz', '40777888', '3548-444444', '2001-06-30', '2026-02-10'),
 ('Camila', 'Romero', '35999000', '3548-555555', '1997-03-08', '2026-03-05'),
 ('Nicolás', 'Torres', '33121314', '3548-666666', '1994-11-17', '2026-03-20'),
 ('Julieta', 'Álvarez', '41151617', '3548-777777', '2002-01-25', '2026-04-02'),
 ('Franco', 'Medina', '29181920', '3548-888888', '1989-07-14', '2026-04-18'),
 ('Sofía', 'Gómez', '37222333', '3548-999999', '1996-05-19', '2026-05-01'),
 ('Mateo', 'Benítez', '38444555', '3548-101010', '1999-10-10', '2026-05-12'),
 ('Lucía', 'Pérez', '42666777', '3548-121212', '2003-02-14', '2026-06-01'),
 ('Agustín', 'Ruiz', '31888999', '3548-131313', '1993-08-22', '2026-06-15'),
 ('Martina', 'Castro', '39111333', '3548-141414', '2000-12-05', '2026-07-02'),
 ('Joaquín', 'Silva', '27222444', '3548-151515', '1988-03-29', '2026-07-20'),
 ('Florencia', 'Acosta', '36333555', '3548-161616', '1995-09-11', '2026-08-01'),
 ('Federico', 'Morales', '34444666', '3548-171717', '1992-01-07', '2026-08-15'),
 ('Carla', 'Jiménez', '43555777', '3548-181818', '2004-06-18', '2026-09-01'),
 ('Esteban', 'Navarro', '31666888', '3548-191919', '1991-10-30', '2026-09-10');

-- PLAN (15 registros)
INSERT INTO plan (nombre, precio, duracion_dias) VALUES
 ('Musculación Mensual', 25000, 30),
 ('Clases Grupales Mensual', 28000, 30),
 ('Full Mensual', 38000, 30),
 ('Pase Libre Trimestral', 100000, 90),
 ('Pase Anual VIP', 350000, 365),
 ('CrossFit Mensual', 32000, 30),
 ('Pilates Mensual', 30000, 30),
 ('Spinning Mensual', 27000, 30),
 ('Yoga Mensual', 26000, 30),
 ('Zumba Mensual', 25000, 30),
 ('Musculación Quincenal', 15000, 15),
 ('Pase Diario', 3000, 1),
 ('Natación y Musculación', 45000, 30),
 ('Funcional Kids', 20000, 30),
 ('Adultos Mayores Activos', 18000, 30);

-- PROFESOR (15 registros)
INSERT INTO profesor (nombre, apellido, especialidad) VALUES
 ('Martín', 'Acosta', 'Funcional'),
 ('Paula', 'Rivas', 'Yoga'),
 ('Bruno', 'Herrera', 'Spinning'),
 ('Carla', 'Mendoza', 'Pilates'),
 ('Esteban', 'Paz', 'CrossFit'),
 ('Mariana', 'Vera', 'Zumba'),
 ('Diego', 'Soria', 'Musculación'),
 ('Valeria', 'Ledesma', 'Stretching'),
 ('Gonzalo', 'Rojas', 'Natación'),
 ('Lorena', 'Iglesias', 'Aerobico'),
 ('Facundo', 'Nuñez', 'Boxeo'),
 ('Claudia', 'Bustos', 'Localizada'),
 ('Hernán', 'Peralta', 'Calistenia'),
 ('Natalia', 'Cabrera', 'Tai Chi'),
 ('Javier', 'Medina', 'Funcional Advanced');

-- CLASE (15 registros)
INSERT INTO clase (nombre, dia, horario, cupo_maximo, id_profesor) VALUES
 ('Funcional', 'Lunes', '08:00', 20, 1),
 ('Funcional', 'Miércoles', '09:00', 20, 1),
 ('Yoga', 'Martes', '18:00', 15, 2),
 ('Yoga', 'Jueves', '18:00', 15, 2),
 ('Spinning', 'Viernes', '20:00', 12, 3),
 ('Pilates', 'Lunes', '10:00', 10, 4),
 ('CrossFit', 'Miércoles', '20:00', 15, 5),
 ('Zumba', 'Martes', '19:00', 25, 6),
 ('Musculación Guiada', 'Jueves', '17:00', 20, 7),
 ('Stretching', 'Viernes', '09:00', 15, 8),
 ('Natación', 'Sábado', '10:00', 10, 9),
 ('Boxeo', 'Lunes', '21:00', 12, 11),
 ('Localizada', 'Miércoles', '18:00', 15, 12),
 ('Calistenia', 'Martes', '17:00', 15, 13),
 ('Tai Chi', 'Jueves', '08:00', 10, 14);

-- INSCRIPCION_CLASE (18 registros)
INSERT INTO inscripcion_clase (id_socio, id_clase, fecha_inscripcion) VALUES
 (1, 1, '2026-01-12'),
 (1, 3, '2026-01-12'),
 (2, 1, '2026-01-16'),
 (2, 5, '2026-01-20'),
 (3, 2, '2026-02-02'),
 (4, 3, '2026-02-11'),
 (4, 4, '2026-02-11'),
 (5, 5, '2026-03-06'),
 (6, 1, '2026-03-21'),
 (7, 3, '2026-04-03'),
 (7, 4, '2026-04-03'),
 (8, 2, '2026-04-19'),
 (9, 6, '2026-05-02'),
 (10, 7, '2026-05-15'),
 (11, 8, '2026-06-02'),
 (12, 9, '2026-06-16'),
 (13, 10, '2026-07-03'),
 (14, 11, '2026-07-21');

-- PAGO (18 registros)
INSERT INTO pago (id_socio, id_plan, fecha, monto) VALUES
 (1, 3, '2026-01-10', 38000),
 (1, 3, '2026-02-10', 38000),
 (1, 3, '2026-03-10', 38000),
 (2, 2, '2026-01-15', 28000),
 (2, 2, '2026-02-15', 28000),
 (3, 1, '2026-02-01', 25000),
 (3, 1, '2026-03-01', 25000),
 (4, 3, '2026-02-10', 38000),
 (5, 2, '2026-03-05', 28000),
 (6, 1, '2026-03-20', 25000),
 (7, 4, '2026-04-02', 100000),
 (8, 1, '2026-04-18', 25000),
 (9, 6, '2026-05-01', 32000),
 (10, 7, '2026-05-12', 30000),
 (11, 8, '2026-06-01', 27000),
 (12, 9, '2026-06-15', 26000),
 (13, 10, '2026-07-02', 25000),
 (14, 13, '2026-07-20', 45000);


-- ------------------------------------------------------------
-- 3. RESOLUCIÓN DE CONSIGNAS (A - F)
-- ------------------------------------------------------------

-- A. Una consulta SELECT por cada tabla creada
SELECT * FROM socio;
SELECT * FROM plan;
SELECT * FROM profesor;
SELECT * FROM clase;
SELECT * FROM inscripcion_clase;
SELECT * FROM pago;


-- B. Un procedimiento almacenado, junto con el código que lo ejecuta
CREATE OR REPLACE FUNCTION sp_registrar_pago(
    p_id_socio INTEGER,
    p_id_plan INTEGER,
    p_monto NUMERIC
)
RETURNS VOID AS $$
BEGIN
    INSERT INTO pago (id_socio, id_plan, fecha, monto)
    VALUES (p_id_socio, p_id_plan, CURRENT_DATE, p_monto);
END;
$$ LANGUAGE plpgsql;

-- Código para ejecutar el procedimiento almacenado:
SELECT sp_registrar_pago(15, 1, 25000.00);


-- C. Tres consultas con INNER JOIN (al menos una uniendo 3 tablas)
-- C1. Consulta 1 (2 tablas): Clases y su profesor asignado
SELECT clase.nombre AS clase, clase.dia, profesor.nombre AS prof_nombre, profesor.apellido AS prof_apellido
FROM clase
INNER JOIN profesor ON clase.id_profesor = profesor.id_profesor;

-- C2. Consulta 2 (3 tablas): Socios inscriptos en clases y detalles de la clase
SELECT s.nombre, s.apellido, c.nombre AS clase, c.dia, c.horario
FROM socio s
INNER JOIN inscripcion_clase ic ON s.id_socio = ic.id_socio
INNER JOIN clase c ON ic.id_clase = c.id_clase;

-- C3. Consulta 3 (3 tablas): Pagos realizados detallando el socio y el plan adquirido
SELECT s.nombre, s.apellido, p.nombre AS plan_comprado, pg.monto, pg.fecha
FROM pago pg
INNER JOIN socio s ON pg.id_socio = s.id_socio
INNER JOIN plan p ON pg.id_plan = p.id_plan;


-- D. Dos consultas con ORDER BY: una ascendente (ASC) y otra descendente (DESC)
-- D1. Orden ascendente por precio de plan
SELECT nombre, precio FROM plan ORDER BY precio ASC;

-- D2. Orden descendente por fecha de alta de los socios
SELECT nombre, apellido, fecha_alta FROM socio ORDER BY fecha_alta DESC;


-- E. Una consulta con GROUP BY y HAVING que use una función de agregación (COUNT, SUM, AVG)
SELECT p.nombre AS plan_nombre, COUNT(pg.id_pago) AS cantidad_pagos, SUM(pg.monto) AS recaudacion_total
FROM pago pg
INNER JOIN plan p ON pg.id_plan = p.id_plan
GROUP BY p.nombre
HAVING SUM(pg.monto) > 25000;


-- F. Al menos una consulta que combine INNER JOIN, WHERE y ORDER BY
SELECT s.nombre, s.apellido, c.nombre AS clase, c.dia
FROM socio s
INNER JOIN inscripcion_clase ic ON s.id_socio = ic.id_socio
INNER JOIN clase c ON ic.id_clase = c.id_clase
WHERE c.dia = 'Lunes'
ORDER BY s.apellido ASC;