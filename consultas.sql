-- 1. Ingenieros con más de 5 solicitudes asignadas 
SELECT ing.nombre, COUNT(*) AS total_solicitudes
FROM ingenieros ing
JOIN ingeniero_solicitud ingsol ON ing.rut = ingsol.rut_ingeniero
GROUP BY ing.nombre
HAVING COUNT(*) > 5;

-- 2. Identificar los 10 errores más antiguos que se han reportado.
-- Muestra el título del error, su fecha de publicación y el nombre del autor.
SELECT solErr.titulo, solErr.fecha_publicacion, usuarios.nombre AS autor
FROM solicitudes_error solErr
JOIN usuarios usuarios ON solErr.autor_rut = usuarios.rut
ORDER BY solErr.fecha_publicacion ASC
LIMIT 10;

-- 3. Lista de todas las nuevas funcionalidades solicitadas para el ambiente "Movil"
SELECT sf.titulo, t.nombre AS topico, u.nombre AS solicitante
FROM solicitudes_funcionalidad sf
JOIN topicos t ON sf.id_topico = t.id
JOIN usuarios u ON sf.solicitante_rut = u.rut
WHERE sf.ambiente = 'Movil';

-- 4. Nombres de los tópicos más problemáticos (más de 10 reportes de error)
SELECT t.nombre, COUNT(*) AS total_errores
FROM solicitudes_error se
JOIN topicos t ON se.id_topico = t.id
GROUP BY t.nombre
HAVING COUNT(*) > 10;

-- 5. Solicitudes de funcionalidad donde el solicitante ha reportado al menos un error en el mismo tópico previamente
SELECT sf.*
FROM solicitudes_funcionalidad sf
WHERE EXISTS (
    SELECT 1
    FROM solicitudes_error se
    WHERE se.autor_rut = sf.solicitante_rut
      AND se.id_topico = sf.id_topico
      AND se.fecha_publicacion < sf.fecha_creacion
);

-- 6. Actualizar el estado de todas las funcionalidades que tengan más de 3 años a "Archivado"
UPDATE solicitudes_funcionalidad
SET estado = 'Archivado'
WHERE fecha_creacion < (CURRENT_DATE - INTERVAL '3 years');

-- 7. Lista de todos los ingenieros especialistas en un tópico específico
SELECT i.nombre, it.ingeniero_especialidad
FROM ingenieros i
JOIN ingeniero_especialidad ie ON i.rut = ie.rut_ingeniero
WHERE ie.id_topico = 'Seguridad'; --ejemplo

-- 8. Cantidad total de solicitudes (errores y funcionalidades juntas) creadas por cada usuario
SELECT u.nombre,
       COUNT(DISTINCT se.id) AS errores,
       COUNT(DISTINCT sf.id) AS funcionalidades,
       COUNT(DISTINCT se.id) + COUNT(DISTINCT sf.id) AS total
FROM usuarios u
LEFT JOIN solicitudes_error se ON u.rut = se.autor_rut
LEFT JOIN solicitudes_funcionalidad sf ON u.rut = sf.solicitante_rut
GROUP BY u.nombre;

-- 9. Cantidad de ingenieros especialistas en cada tema
SELECT STRING_AGG(t, ', ') AS resumen
FROM (
    SELECT especialidad || ': ' || COUNT(*) AS t
    FROM ingeniero_especialidad
    GROUP BY id_topico
) sub;

-- 10. Elimina todas las solicitudes de gestión de error que tengan más de 5 años de antigüedad
DELETE FROM solicitudes_error
WHERE fecha_publicacion < (CURRENT_DATE - INTERVAL '5 years');