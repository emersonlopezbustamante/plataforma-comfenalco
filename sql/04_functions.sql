-- ============================================================
-- PLATAFORMA DIGITAL — Comfenalco Antioquia
-- Archivo: 04_functions.sql
-- Funciones PostgreSQL para reportes, búsqueda y estadísticas
-- ============================================================

-- ============================================================
-- FUNCIÓN: estadísticas generales del dashboard
-- ============================================================
CREATE OR REPLACE FUNCTION fn_estadisticas_generales()
RETURNS JSON AS $$
DECLARE
  resultado JSON;
BEGIN
  SELECT json_build_object(
    'total_candidatos',     (SELECT COUNT(*) FROM candidatos WHERE activo = TRUE),
    'total_empresas',       (SELECT COUNT(*) FROM empresas WHERE estado IN ('activa','verificada')),
    'total_vacantes_activas',(SELECT COUNT(*) FROM vacantes WHERE estado = 'activa'),
    'total_postulaciones',  (SELECT COUNT(*) FROM postulaciones),
    'empleos_colocados',    (SELECT COUNT(*) FROM postulaciones WHERE estado = 'contratado'),
    'candidatos_este_mes',  (SELECT COUNT(*) FROM candidatos WHERE created_at >= date_trunc('month', NOW())),
    'vacantes_este_mes',    (SELECT COUNT(*) FROM vacantes WHERE created_at >= date_trunc('month', NOW())),
    'tasa_colocacion',      ROUND(
      CASE WHEN (SELECT COUNT(*) FROM postulaciones) > 0
        THEN (SELECT COUNT(*) FROM postulaciones WHERE estado = 'contratado')::NUMERIC /
             (SELECT COUNT(*) FROM postulaciones)::NUMERIC * 100
        ELSE 0
      END, 2
    )
  ) INTO resultado;
  RETURN resultado;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================
-- FUNCIÓN: vacantes por municipio (para mapa/reportes)
-- ============================================================
CREATE OR REPLACE FUNCTION fn_vacantes_por_municipio()
RETURNS TABLE(municipio TEXT, subregion TEXT, total_vacantes BIGINT, total_postulaciones BIGINT) AS $$
BEGIN
  RETURN QUERY
  SELECT
    m.nombre,
    m.subregion,
    COUNT(DISTINCT v.id)  AS total_vacantes,
    COUNT(DISTINCT p.id)  AS total_postulaciones
  FROM municipios m
  LEFT JOIN vacantes v    ON v.municipio_id = m.id AND v.estado = 'activa'
  LEFT JOIN postulaciones p ON p.vacante_id = v.id
  GROUP BY m.nombre, m.subregion
  ORDER BY total_vacantes DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================
-- FUNCIÓN: candidatos por condición especial
-- ============================================================
CREATE OR REPLACE FUNCTION fn_candidatos_por_condicion()
RETURNS TABLE(condicion TEXT, total BIGINT, porcentaje NUMERIC) AS $$
DECLARE
  total_general BIGINT;
BEGIN
  SELECT COUNT(*) INTO total_general FROM candidatos WHERE activo = TRUE;
  RETURN QUERY
  SELECT
    condicion_especial::TEXT,
    COUNT(*) AS total,
    ROUND(COUNT(*)::NUMERIC / NULLIF(total_general, 0) * 100, 1)
  FROM candidatos
  WHERE activo = TRUE
  GROUP BY condicion_especial
  ORDER BY total DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================
-- FUNCIÓN: indicadores por período para reportes
-- ============================================================
CREATE OR REPLACE FUNCTION fn_indicadores_periodo(
  p_fecha_inicio DATE DEFAULT date_trunc('month', NOW())::DATE,
  p_fecha_fin    DATE DEFAULT NOW()::DATE,
  p_municipio_id INTEGER DEFAULT NULL
)
RETURNS JSON AS $$
BEGIN
  RETURN json_build_object(
    'periodo', json_build_object('inicio', p_fecha_inicio, 'fin', p_fecha_fin),
    'candidatos_nuevos',
      (SELECT COUNT(*) FROM candidatos
       WHERE created_at::DATE BETWEEN p_fecha_inicio AND p_fecha_fin),
    'vacantes_publicadas',
      (SELECT COUNT(*) FROM vacantes
       WHERE fecha_publicacion BETWEEN p_fecha_inicio AND p_fecha_fin
       AND (p_municipio_id IS NULL OR municipio_id = p_municipio_id)),
    'postulaciones',
      (SELECT COUNT(*) FROM postulaciones p
       JOIN vacantes v ON v.id = p.vacante_id
       WHERE p.fecha_postulacion::DATE BETWEEN p_fecha_inicio AND p_fecha_fin
       AND (p_municipio_id IS NULL OR v.municipio_id = p_municipio_id)),
    'empleos_colocados',
      (SELECT COUNT(*) FROM postulaciones p
       JOIN vacantes v ON v.id = p.vacante_id
       WHERE p.estado = 'contratado'
       AND p.updated_at::DATE BETWEEN p_fecha_inicio AND p_fecha_fin
       AND (p_municipio_id IS NULL OR v.municipio_id = p_municipio_id)),
    'tasa_colocacion', ROUND(
      CASE
        WHEN (SELECT COUNT(*) FROM postulaciones p
              JOIN vacantes v ON v.id = p.vacante_id
              WHERE p.fecha_postulacion::DATE BETWEEN p_fecha_inicio AND p_fecha_fin
              AND (p_municipio_id IS NULL OR v.municipio_id = p_municipio_id)) > 0
        THEN
          (SELECT COUNT(*) FROM postulaciones p
           JOIN vacantes v ON v.id = p.vacante_id
           WHERE p.estado = 'contratado'
           AND p.updated_at::DATE BETWEEN p_fecha_inicio AND p_fecha_fin
           AND (p_municipio_id IS NULL OR v.municipio_id = p_municipio_id))::NUMERIC /
          (SELECT COUNT(*) FROM postulaciones p
           JOIN vacantes v ON v.id = p.vacante_id
           WHERE p.fecha_postulacion::DATE BETWEEN p_fecha_inicio AND p_fecha_fin
           AND (p_municipio_id IS NULL OR v.municipio_id = p_municipio_id))::NUMERIC * 100
        ELSE 0
      END, 1
    )
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================
-- FUNCIÓN: búsqueda avanzada de candidatos (banco de HV)
-- ============================================================
CREATE OR REPLACE FUNCTION fn_buscar_candidatos(
  p_municipio_id      INTEGER    DEFAULT NULL,
  p_subregion         TEXT       DEFAULT NULL,
  p_area_interes      TEXT       DEFAULT NULL,
  p_nivel_educativo   nivel_educativo DEFAULT NULL,
  p_condicion         condicion_especial DEFAULT NULL,
  p_salario_max       INTEGER    DEFAULT NULL,
  p_texto             TEXT       DEFAULT NULL,
  p_limite            INTEGER    DEFAULT 20,
  p_offset            INTEGER    DEFAULT 0
)
RETURNS TABLE(
  id UUID, nombres TEXT, apellidos TEXT, numero_documento TEXT,
  municipio TEXT, subregion TEXT, area_interes TEXT,
  pretension_salarial INTEGER, condicion_especial condicion_especial,
  porcentaje_completitud INTEGER, nivel_max_educativo TEXT,
  meses_experiencia INTEGER, created_at TIMESTAMPTZ
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    c.id,
    c.nombres,
    c.apellidos,
    c.numero_documento,
    m.nombre      AS municipio,
    m.subregion,
    c.area_interes,
    c.pretension_salarial,
    c.condicion_especial,
    c.porcentaje_completitud,
    (SELECT e.nivel::TEXT FROM educacion e WHERE e.candidato_id = c.id ORDER BY
      CASE e.nivel
        WHEN 'doctorado' THEN 8 WHEN 'maestria' THEN 7 WHEN 'especializacion' THEN 6
        WHEN 'profesional' THEN 5 WHEN 'tecnologo' THEN 4 WHEN 'tecnico' THEN 3
        WHEN 'secundaria' THEN 2 WHEN 'primaria' THEN 1 ELSE 0 END DESC LIMIT 1
    ) AS nivel_max_educativo,
    (SELECT COALESCE(SUM(
      CASE WHEN el.es_trabajo_actual THEN
        EXTRACT(MONTH FROM AGE(NOW(), el.fecha_inicio))
      ELSE
        EXTRACT(MONTH FROM AGE(COALESCE(el.fecha_fin, NOW()), el.fecha_inicio))
      END
    ), 0)::INTEGER FROM experiencia_laboral el WHERE el.candidato_id = c.id) AS meses_experiencia,
    c.created_at
  FROM candidatos c
  LEFT JOIN municipios m ON m.id = c.municipio_id
  WHERE
    c.activo = TRUE
    AND c.hv_publica = TRUE
    AND (p_municipio_id IS NULL OR c.municipio_id = p_municipio_id)
    AND (p_subregion IS NULL OR m.subregion = p_subregion)
    AND (p_area_interes IS NULL OR c.area_interes ILIKE '%' || p_area_interes || '%')
    AND (p_condicion IS NULL OR c.condicion_especial = p_condicion)
    AND (p_salario_max IS NULL OR c.pretension_salarial <= p_salario_max)
    AND (p_texto IS NULL OR
      to_tsvector('spanish', c.nombres || ' ' || c.apellidos) @@
      plainto_tsquery('spanish', p_texto)
    )
    AND (p_nivel_educativo IS NULL OR EXISTS (
      SELECT 1 FROM educacion e WHERE e.candidato_id = c.id AND e.nivel = p_nivel_educativo
    ))
  ORDER BY c.porcentaje_completitud DESC, c.created_at DESC
  LIMIT p_limite OFFSET p_offset;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================
-- FUNCIÓN: búsqueda de vacantes (landing + módulo vacantes)
-- ============================================================
CREATE OR REPLACE FUNCTION fn_buscar_vacantes(
  p_texto         TEXT    DEFAULT NULL,
  p_municipio_id  INTEGER DEFAULT NULL,
  p_subregion     TEXT    DEFAULT NULL,
  p_contrato      tipo_contrato DEFAULT NULL,
  p_jornada       jornada DEFAULT NULL,
  p_salario_min   INTEGER DEFAULT NULL,
  p_limite        INTEGER DEFAULT 10,
  p_offset        INTEGER DEFAULT 0
)
RETURNS TABLE(
  id UUID, cargo TEXT, empresa TEXT, empresa_logo TEXT,
  municipio TEXT, subregion TEXT,
  salario_min INTEGER, salario_max INTEGER,
  tipo_contrato tipo_contrato, jornada jornada,
  estado estado_vacante, fecha_cierre DATE,
  total_postulados BIGINT, es_incluyente BOOLEAN
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    v.id,
    v.cargo,
    e.nombre      AS empresa,
    e.logo_url    AS empresa_logo,
    m.nombre      AS municipio,
    m.subregion,
    v.salario_min,
    v.salario_max,
    v.tipo_contrato,
    v.jornada,
    v.estado,
    v.fecha_cierre,
    COUNT(p.id)   AS total_postulados,
    v.es_incluyente
  FROM vacantes v
  JOIN empresas e     ON e.id = v.empresa_id
  LEFT JOIN municipios m   ON m.id = v.municipio_id
  LEFT JOIN postulaciones p ON p.vacante_id = v.id
  WHERE
    v.estado = 'activa'
    AND (p_municipio_id IS NULL OR v.municipio_id = p_municipio_id)
    AND (p_subregion IS NULL OR m.subregion = p_subregion)
    AND (p_contrato IS NULL OR v.tipo_contrato = p_contrato)
    AND (p_jornada IS NULL OR v.jornada = p_jornada)
    AND (p_salario_min IS NULL OR v.salario_min >= p_salario_min)
    AND (p_texto IS NULL OR
      to_tsvector('spanish', v.cargo || ' ' || COALESCE(v.descripcion,'') || ' ' || e.nombre) @@
      plainto_tsquery('spanish', p_texto)
    )
    AND (v.fecha_cierre IS NULL OR v.fecha_cierre >= CURRENT_DATE)
  GROUP BY v.id, e.nombre, e.logo_url, m.nombre, m.subregion
  ORDER BY v.fecha_publicacion DESC
  LIMIT p_limite OFFSET p_offset;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================
-- FUNCIÓN: obtener HV completa de un candidato (para PDF)
-- ============================================================
CREATE OR REPLACE FUNCTION fn_hv_completa(p_candidato_id UUID)
RETURNS JSON AS $$
DECLARE
  resultado JSON;
BEGIN
  SELECT json_build_object(
    'candidato', (SELECT row_to_json(c.*) FROM candidatos c WHERE c.id = p_candidato_id),
    'municipio',  (SELECT m.nombre FROM candidatos c JOIN municipios m ON m.id = c.municipio_id WHERE c.id = p_candidato_id),
    'educacion',  (SELECT json_agg(e.* ORDER BY e.anio_fin DESC NULLS LAST) FROM educacion e WHERE e.candidato_id = p_candidato_id),
    'certificados',(SELECT json_agg(ce.* ORDER BY ce.anio DESC NULLS LAST) FROM certificados ce WHERE ce.candidato_id = p_candidato_id),
    'experiencia',(SELECT json_agg(ex.* ORDER BY ex.fecha_inicio DESC) FROM experiencia_laboral ex WHERE ex.candidato_id = p_candidato_id),
    'referencias',(SELECT json_agg(r.*) FROM referencias r WHERE r.candidato_id = p_candidato_id),
    'competencias',(SELECT json_agg(co.*) FROM competencias co WHERE co.candidato_id = p_candidato_id),
    'idiomas',    (SELECT json_agg(i.*) FROM idiomas i WHERE i.candidato_id = p_candidato_id),
    'disponibilidad',(SELECT row_to_json(d.*) FROM disponibilidad_candidato d WHERE d.candidato_id = p_candidato_id)
  ) INTO resultado;
  RETURN resultado;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================
-- VISTA: últimas postulaciones (para dashboard)
-- ============================================================
CREATE OR REPLACE VIEW v_ultimas_postulaciones AS
SELECT
  p.id,
  c.nombres || ' ' || c.apellidos AS candidato,
  v.cargo,
  e.nombre  AS empresa,
  m.nombre  AS municipio,
  p.estado,
  p.fecha_postulacion
FROM postulaciones p
JOIN candidatos c ON c.id = p.candidato_id
JOIN vacantes v   ON v.id = p.vacante_id
JOIN empresas e   ON e.id = v.empresa_id
LEFT JOIN municipios m ON m.id = v.municipio_id
ORDER BY p.fecha_postulacion DESC;

-- ============================================================
-- VISTA: resumen de candidatos para banco de HV
-- ============================================================
CREATE OR REPLACE VIEW v_candidatos_resumen AS
SELECT
  c.id,
  c.nombres,
  c.apellidos,
  c.numero_documento,
  c.correo,
  c.celular,
  m.nombre      AS municipio,
  m.subregion,
  c.area_interes,
  c.pretension_salarial,
  c.condicion_especial,
  c.porcentaje_completitud,
  c.hv_publica,
  c.activo,
  c.created_at,
  (SELECT COUNT(*) FROM postulaciones WHERE candidato_id = c.id) AS total_postulaciones
FROM candidatos c
LEFT JOIN municipios m ON m.id = c.municipio_id;
