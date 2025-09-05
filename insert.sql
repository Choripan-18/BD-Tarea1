INSERT INTO topicos (nombre) VALUES
('Backend'), ('Seguridad'), ('UX/UI'), ('Base de Datos'), ('API'), ('Frontend'), ('DevOps'), ('Testing');

-- 50 usuarios
DO $$
BEGIN
  FOR i IN 1..50 LOOP
    INSERT INTO usuarios (rut, nombre, email)
    VALUES (
      LPAD(i::text,8,'0') || '-' || (i%10)::text,
      'Usuario_' || i,
      'usuario' || i || '@mail.com'
    );
  END LOOP;
END;
$$;

-- 50 ingenieros
DO $$
BEGIN
  FOR i IN 1..50 LOOP
    INSERT INTO ingenieros (rut, nombre, email)
    VALUES (
      LPAD((i+100)::text,8,'0') || '-' || (i%10)::text,
      'Ingeniero_' || i,
      'ingeniero' || i || '@mail.com'
    );
  END LOOP;
END;
$$;

-- Cada ingeniero con 1 o 2 especialidades
INSERT INTO ingeniero_especialidad (rut_ingeniero, especialidad)
SELECT rut, (ARRAY['Backend','Seguridad','UX/UI','Base de Datos','API','Frontend','DevOps','Testing'])[floor(random()*8)+1]
FROM ingenieros;

INSERT INTO ingeniero_especialidad (rut_ingeniero, especialidad)
SELECT rut, (ARRAY['Backend','Seguridad','UX/UI','Base de Datos','API','Frontend','DevOps','Testing'])[floor(random()*8)+1]
FROM ingenieros
WHERE random() > 0.5;

DO $$
DECLARE
  topico_id INT;
  autor_rut VARCHAR(10);
BEGIN
  FOR i IN 1..300 LOOP
    SELECT id INTO topico_id FROM topicos ORDER BY random() LIMIT 1;
    SELECT rut INTO autor_rut FROM usuarios ORDER BY random() LIMIT 1;
    INSERT INTO solicitudes_error (titulo, descripcion, fecha_publicacion, id_topico, autor_rut, estado)
    VALUES (
      'Error_' || i,
      'Descripción del error número ' || i,
      (CURRENT_DATE - (i % 1800)),
      topico_id,
      autor_rut,
      (ARRAY['Abierto','En Progreso','Resuelto','Cerrado'])[floor(random()*4)+1]
    );
  END LOOP;
END;
$$;

DO $$
DECLARE
  topico_id INT;
  solicitante_rut VARCHAR(10);
  ambiente VARCHAR(10);
BEGIN
  FOR i IN 1..200 LOOP
    SELECT id INTO topico_id FROM topicos ORDER BY random() LIMIT 1;
    SELECT rut INTO solicitante_rut FROM usuarios ORDER BY random() LIMIT 1;
    ambiente := (ARRAY['Web','Movil',NULL])[floor(random()*3)+1];
    INSERT INTO solicitudes_funcionalidad (titulo, ambiente, resumen, id_topico, solicitante_rut, estado, fecha_creacion)
    VALUES (
      'Funcionalidad_' || i,
      ambiente,
      'Resumen de funcionalidad número ' || i,
      topico_id,
      solicitante_rut,
      (ARRAY['Abierto','En Progreso','Resuelto','Cerrado'])[floor(random()*4)+1],
      (CURRENT_DATE - (i % 1000))
    );
  END LOOP;
END;
$$;

DO $$
DECLARE
  func_id INT;
BEGIN
  FOR func_id IN SELECT id FROM solicitudes_funcionalidad LOOP
    FOR i IN 1..3 LOOP
      INSERT INTO criterios_aceptacion (id_funcionalidad, criterio)
      VALUES (func_id, 'Criterio ' || i || ' para funcionalidad ' || func_id);
    END LOOP;
  END LOOP;
END;
$$;

-- Asignar 3 ingenieros aleatorios a cada solicitud de funcionalidad
DO $$
DECLARE
  func_id INT;
  ing_rut VARCHAR(10);
BEGIN
  FOR func_id IN SELECT id FROM solicitudes_funcionalidad LOOP
    FOR i IN 1..3 LOOP
      SELECT rut INTO ing_rut FROM ingenieros ORDER BY random() LIMIT 1;
      INSERT INTO ingeniero_solicitud (rut_ingeniero, tipo_solicitud, id_solicitud)
      VALUES (ing_rut, 'funcionalidad', func_id);
    END LOOP;
  END LOOP;
END;
$$;

-- Asignar 3 ingenieros aleatorios a cada solicitud de error
DO $$
DECLARE
  err_id INT;
  ing_rut VARCHAR(10);
BEGIN
  FOR err_id IN SELECT id FROM solicitudes_error LOOP
    FOR i IN 1..3 LOOP
      SELECT rut INTO ing_rut FROM ingenieros ORDER BY random() LIMIT 1;
      INSERT INTO ingeniero_solicitud (rut_ingeniero, tipo_solicitud, id_solicitud)
      VALUES (ing_rut, 'error', err_id);
    END LOOP;
  END LOOP;
END;
$$;