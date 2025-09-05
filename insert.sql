-- Poblacion de datos --

-- 8 Topicos
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

-- Solicitudes de error 
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
      (CURRENT_DATE - (floor(random()*3000)::INT)),
      topico_id,
      autor_rut,
      (ARRAY['Abierto','En Progreso','Resuelto','Cerrado'])[floor(random()*4)+1]
    );
  END LOOP;
END;
$$;


-- Solicitudes de funcionalidad
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
      (CURRENT_DATE - (floor(random()*3000)::INT)
      ));
  END LOOP;
END;
$$;


-- Criterios de aceptación
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

-- 50 ingenieros -> 99 para manejar mas solicitudes
DO $$
BEGIN
  FOR i IN 1..99 LOOP
    INSERT INTO ingenieros (rut, nombre, email)
    VALUES (
      LPAD((i+100)::text,8,'0') || '-' || (i%10)::text,
      'Ingeniero_' || i,
      'ingeniero' || i || '@mail.com'
    );
  END LOOP;
END;
$$;

--Especialidades ingenieros
DO $$
DECLARE
  ing RECORD;
  topico1 INT;
  topico2 INT;
BEGIN
  FOR ing IN SELECT rut FROM ingenieros LOOP
    SELECT id INTO topico1 FROM topicos ORDER BY random() LIMIT 1;
    INSERT INTO ingeniero_especialidad (rut_ingeniero, id_topico) VALUES (ing.rut, topico1);
    IF random() > 0.5 THEN
      LOOP
        SELECT id INTO topico2 FROM topicos ORDER BY random() LIMIT 1;
        EXIT WHEN topico2 <> topico1;
      END LOOP;
      INSERT INTO ingeniero_especialidad (rut_ingeniero, id_topico) VALUES (ing.rut, topico2);
    END IF;
  END LOOP;
END;
$$;

-- Asignar ingenieros a funcionalidad 
DO $$
DECLARE
  func_id INT;
  topico_id INT;
  ing_rut VARCHAR(10);
  intentos INT;
BEGIN
  FOR func_id IN SELECT id FROM solicitudes_funcionalidad LOOP
  SELECT id_topico INTO topico_id FROM solicitudes_funcionalidad WHERE id = func_id;
    FOR i IN 1..3 LOOP
      intentos := 0;
      LOOP
        SELECT rut_ingeniero INTO ing_rut FROM ingeniero_especialidad
        WHERE id_topico = topico_id
          AND (
          SELECT COUNT(*) FROM ingeniero_solicitud
          WHERE rut_ingeniero = ingeniero_especialidad.rut_ingeniero
          ) < 20
        ORDER BY random() LIMIT 1;
        -- Si no hay ingeniero disponible, salir del loop
        IF ing_rut IS NULL THEN
          EXIT;
        END IF;
        -- Verifica que el ingeniero no esté ya asignado a esta solicitud
        IF NOT EXISTS (
          SELECT 1 FROM ingeniero_solicitud
          WHERE rut_ingeniero = ing_rut
            AND tipo_solicitud = 'funcionalidad'
            AND id_solicitud = func_id
        ) THEN
          INSERT INTO ingeniero_solicitud (rut_ingeniero, tipo_solicitud, id_solicitud)
          VALUES (ing_rut, 'funcionalidad', func_id);
          EXIT;
        END IF;
        intentos := intentos + 1;
        IF intentos > 10 THEN
          EXIT; -- Evita loops infinitos si no hay ingenieros disponibles
        END IF;
      END LOOP;
    END LOOP;
  END LOOP;
END;
$$;
-- Asignar ingenieros a errores
DO $$
DECLARE
  err_id INT;
  topico_id INT;
  ing_rut VARCHAR(10);
  intentos INT;
BEGIN
  FOR err_id IN SELECT id FROM solicitudes_error LOOP
  SELECT id_topico INTO topico_id FROM solicitudes_error WHERE id = err_id;
    FOR i IN 1..3 LOOP
      intentos := 0;
      LOOP
        SELECT rut_ingeniero INTO ing_rut FROM ingeniero_especialidad
        WHERE id_topico = topico_id
          AND (
          SELECT COUNT(*) FROM ingeniero_solicitud
          WHERE rut_ingeniero = ingeniero_especialidad.rut_ingeniero
          ) < 20
        ORDER BY random() LIMIT 1;
        -- Si no hay ingeniero disponible, salir del loop
        IF ing_rut IS NULL THEN
          EXIT;
        END IF;
        -- Verifica que el ingeniero no esté ya asignado a esta solicitud
        IF NOT EXISTS (
          SELECT 1 FROM ingeniero_solicitud
          WHERE rut_ingeniero = ing_rut
            AND tipo_solicitud = 'error'
            AND id_solicitud = err_id
        ) THEN
          INSERT INTO ingeniero_solicitud (rut_ingeniero, tipo_solicitud, id_solicitud)
          VALUES (ing_rut, 'error', err_id);
          EXIT;
        END IF;
        intentos := intentos + 1;
        IF intentos > 10 THEN
          EXIT; -- Evita loops infinitos si no hay ingenieros disponibles
        END IF;
      END LOOP;
    END LOOP;
  END LOOP;
END;
$$;