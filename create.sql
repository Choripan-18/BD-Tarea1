-- Tablas--

-- Tabla de usuarios
CREATE TABLE usuarios (
    rut VARCHAR(10) PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL
);


-- Tabla de ingenieros
CREATE TABLE ingenieros (
    rut VARCHAR(10) PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL
);


-- Tabla de topicos
CREATE TABLE topicos (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(50) UNIQUE NOT NULL
);


-- Tabla de especialidades de ingenieros
CREATE TABLE ingeniero_especialidad (
    rut_ingeniero VARCHAR(10),
    id_topico INT,
    PRIMARY KEY (rut_ingeniero, id_topico),
    FOREIGN KEY (rut_ingeniero) REFERENCES ingenieros(rut),
    FOREIGN KEY (id_topico) REFERENCES topicos(id)
);


-- Tabla de solicitudes de funcionalidad
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

-- Tabla de criterios de aceptación
CREATE TABLE criterios_aceptacion (
    id SERIAL PRIMARY KEY,
    id_funcionalidad INT NOT NULL,
    criterio VARCHAR(200) NOT NULL,
    FOREIGN KEY (id_funcionalidad) REFERENCES solicitudes_funcionalidad(id)
);

-- Tabla de solicitudes de errores
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

-- Tabla de asignación de ingenieros
CREATE TABLE ingeniero_solicitud (
    id SERIAL PRIMARY KEY,
    rut_ingeniero VARCHAR(10) NOT NULL,
    tipo_solicitud VARCHAR(20) NOT NULL, -- "funcionalidad" o "error"
    id_solicitud INT NOT NULL,
    FOREIGN KEY (rut_ingeniero) REFERENCES ingenieros(rut)
);


-- Triggers --

-- Trigger para limitar 3 ingenieros por solicitud
CREATE OR REPLACE FUNCTION limitar_ingenieros_por_solicitud()
RETURNS TRIGGER AS $$
BEGIN
    IF (
        SELECT COUNT(*) FROM ingeniero_solicitud 
        WHERE tipo_solicitud = NEW.tipo_solicitud
          AND id_solicitud = NEW.id_solicitud
    ) >= 3 THEN
        RAISE EXCEPTION 'No se pueden asignar más de 3 ingenieros a una solicitud';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_limitar_ingenieros_por_solicitud
BEFORE INSERT ON ingeniero_solicitud
FOR EACH ROW EXECUTE FUNCTION limitar_ingenieros_por_solicitud();

-- Trigger para limitar 20 solicitudes por ingeniero
CREATE OR REPLACE FUNCTION limitar_solicitudes_por_ingeniero()
RETURNS TRIGGER AS $$
BEGIN
    IF (
        SELECT COUNT(*) FROM ingeniero_solicitud
        WHERE rut_ingeniero = NEW.rut_ingeniero
    ) >= 20 THEN
        RAISE EXCEPTION 'Un ingeniero no puede estar asignado a más de 20 solicitudes';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_limitar_solicitudes_por_ingeniero
BEFORE INSERT ON ingeniero_solicitud
FOR EACH ROW EXECUTE FUNCTION limitar_solicitudes_por_ingeniero();

-- Trigger para limitar 25 solicitudes de error por usuario por día
CREATE OR REPLACE FUNCTION limitar_errores_por_usuario_por_dia()
RETURNS TRIGGER AS $$
BEGIN
    IF (
        SELECT COUNT(*) FROM solicitudes_error
        WHERE autor_rut = NEW.autor_rut
          AND fecha_publicacion = NEW.fecha_publicacion
    ) >= 25 THEN
        RAISE EXCEPTION 'Un usuario no puede crear más de 25 solicitudes de error por día';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_limitar_errores_por_usuario_por_dia
BEFORE INSERT ON solicitudes_error
FOR EACH ROW EXECUTE FUNCTION limitar_errores_por_usuario_por_dia();

-- Trigger para limitar 25 solicitudes de funcionalidad por usuario por día
CREATE OR REPLACE FUNCTION limitar_funcionalidades_por_usuario_por_dia()
RETURNS TRIGGER AS $$
BEGIN
    IF (
        SELECT COUNT(*) FROM solicitudes_funcionalidad
        WHERE solicitante_rut = NEW.solicitante_rut
          AND fecha_creacion = NEW.fecha_creacion
    ) >= 25 THEN
        RAISE EXCEPTION 'Un usuario no puede crear más de 25 solicitudes de funcionalidad por día';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_limitar_funcionalidades_por_usuario_por_dia
BEFORE INSERT ON solicitudes_funcionalidad
FOR EACH ROW EXECUTE FUNCTION limitar_funcionalidades_por_usuario_por_dia();

