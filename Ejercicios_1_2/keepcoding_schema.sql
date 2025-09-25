-- =============================================
-- SCRIPT DE CREACIÓN - KEEPCODING ACADEMY
-- Ejercicio 2 - Práctica SQL
-- Autor: Diógenes Lugo
-- =============================================


-- ========================
-- TABLAS BASE
-- ========================

CREATE TABLE niveles (
    nivel_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL UNIQUE,
    descripcion TEXT
);

CREATE TABLE categorias (
    categoria_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL UNIQUE,
    descripcion TEXT
);

CREATE TABLE paises (
    pais_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL UNIQUE,
    codigo_iso VARCHAR(10) NOT NULL UNIQUE
);

CREATE TABLE modulos (
    modulo_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL UNIQUE,
    descripcion TEXT,
    duracion_horas INT CHECK (duracion_horas > 0),
    nivel_id INT NOT NULL REFERENCES niveles(nivel_id) ON DELETE RESTRICT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE bootcamps (
    bootcamp_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre VARCHAR(150) NOT NULL UNIQUE,
    descripcion TEXT,
    modulo_id INT NOT NULL REFERENCES modulos(modulo_id) ON DELETE RESTRICT,
    nivel_id INT NOT NULL REFERENCES niveles(nivel_id) ON DELETE RESTRICT,
    categoria_id INT NOT NULL REFERENCES categorias(categoria_id) ON DELETE RESTRICT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE profesores (
    profesor_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    especialidad VARCHAR(150),
    anios_experiencia INT CHECK (anios_experiencia >= 0),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE alumnos (
    alumno_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    telefono VARCHAR(50),
    fecha_nacimiento DATE CHECK (fecha_nacimiento < CURRENT_DATE),
    pais_id INT REFERENCES paises(pais_id) ON DELETE SET NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ========================
-- TABLAS RELACIONALES
-- ========================

CREATE TABLE ediciones (
    edicion_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    bootcamp_id INT NOT NULL REFERENCES bootcamps(bootcamp_id) ON DELETE CASCADE,
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE CHECK (fecha_fin IS NULL OR fecha_fin > fecha_inicio),
    horario VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE modulo_edicion (
    modulo_edicion_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    edicion_id INT NOT NULL REFERENCES ediciones(edicion_id) ON DELETE CASCADE,
    profesor_id INT NOT NULL REFERENCES profesores(profesor_id) ON DELETE RESTRICT,
    modulo_id INT NOT NULL REFERENCES modulos(modulo_id) ON DELETE RESTRICT,
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE CHECK (fecha_fin IS NULL OR fecha_fin > fecha_inicio),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_modulo_profesor_edicion UNIQUE (edicion_id, profesor_id, modulo_id)
);

CREATE TABLE inscripciones (
    inscripcion_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    alumno_id INT NOT NULL REFERENCES alumnos(alumno_id) ON DELETE CASCADE,
    edicion_id INT NOT NULL REFERENCES ediciones(edicion_id) ON DELETE CASCADE,
    fecha_inscripcion DATE NOT NULL DEFAULT CURRENT_DATE,
    estado VARCHAR(50) NOT NULL CHECK (estado IN ('pendiente','activa','cancelada','finalizada')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_alumno_edicion UNIQUE (alumno_id, edicion_id)
);

CREATE TABLE pagos (
    pago_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    inscripcion_id INT NOT NULL REFERENCES inscripciones(inscripcion_id) ON DELETE CASCADE,
    monto NUMERIC(10,2) NOT NULL CHECK (monto > 0),
    moneda VARCHAR(10) NOT NULL,
    fecha_pago DATE NOT NULL DEFAULT CURRENT_DATE,
    metodo_pago VARCHAR(50),
    estado VARCHAR(50) NOT NULL CHECK (estado IN ('pendiente','pagado','rechazado')),
    referencia_transaccion VARCHAR(150) UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- FIN DEL SCRIPT
-- =====================================================
