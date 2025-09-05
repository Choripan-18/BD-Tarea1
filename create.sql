-- Tabla de Usuarios
CREATE TABLE usuarios (
    rut VARCHAR(10) PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL
);

-- Tabla de Ingenieros
CREATE TABLE ingenieros (
    rut VARCHAR(10) PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL
);

-- Tabla de Especialidades de Ingenieros (máximo 2 por ingeniero)
CREATE TABLE ingeniero_especialidad (
    rut_ingeniero VARCHAR(10),
    especialidad VARCHAR(50),
    PRIMARY KEY (rut_ingeniero, especialidad),
    FOREIGN KEY (rut_ingeniero) REFERENCES ingenieros(rut)
);

-- Tabla de Tópicos
CREATE TABLE topicos (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(50) UNIQUE NOT NULL
);

-- Tabla de Solicitudes de Funcionalidad
CREATE TABLE solicitudes_funcionalidad (
    id SERIAL PRIMARY KEY,
    titulo VARCHAR(150) NOT NULL UNIQUE,
    ambiente VARCHAR(10),
    resumen VARCHAR(150) NOT NULL,
    id_topico INT NOT NULL,
    solicitante_rut VARCHAR(10) NOT NULL,
    estado VARCHAR(20) NOT NULL,
    fecha_creacion DATE NOT NULL DEFAULT CURRENT_DATE,
    FOREIGN KEY (id_topico) REFERENCES topicos(id),
    FOREIGN KEY (solicitante_rut) REFERENCES usuarios(rut)
);

-- Tabla de Criterios de Aceptación (mínimo 3 por solicitud)
CREATE TABLE criterios_aceptacion (
    id SERIAL PRIMARY KEY,
    id_funcionalidad INT NOT NULL,
    criterio VARCHAR(200) NOT NULL,
    FOREIGN KEY (id_funcionalidad) REFERENCES solicitudes_funcionalidad(id)
);

-- Tabla de Solicitudes de Errores
CREATE TABLE solicitudes_error (
    id SERIAL PRIMARY KEY,
    titulo VARCHAR(150) NOT NULL UNIQUE,
    descripcion VARCHAR(200) NOT NULL,
    fecha_publicacion DATE NOT NULL,
    id_topico INT NOT NULL,
    autor_rut VARCHAR(10) NOT NULL,
    estado VARCHAR(20) NOT NULL,
    FOREIGN KEY (id_topico) REFERENCES topicos(id),
    FOREIGN KEY (autor_rut) REFERENCES usuarios(rut)
);

-- Tabla de Asignación de Ingenieros a Solicitudes (3 por solicitud)
CREATE TABLE ingeniero_solicitud (
    id SERIAL PRIMARY KEY,
    rut_ingeniero VARCHAR(10) NOT NULL,
    tipo_solicitud VARCHAR(20) NOT NULL, -- 'funcionalidad' o 'error'
    id_solicitud INT NOT NULL,
    FOREIGN KEY (rut_ingeniero) REFERENCES ingenieros(rut),
    -- FK dinámica según tipo_solicitud
    -- Se puede manejar con triggers o validación en la aplicación
);

-- Restricciones adicionales y triggers pueden ser necesarios para:
-- - Limitar 3 ingenieros por solicitud
-- - Limitar 20 solicitudes por ingeniero
-- - Limitar 25 solicitudes por usuario por día
-- - No permitir títulos duplicados del mismo tipo
