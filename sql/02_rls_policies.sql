-- ============================================================
-- PLATAFORMA DIGITAL — Comfenalco Antioquia
-- Archivo: 02_rls_policies.sql
-- Row Level Security: cada rol solo ve lo que le corresponde
-- ============================================================

-- Habilitar RLS en todas las tablas con datos sensibles
ALTER TABLE perfiles              ENABLE ROW LEVEL SECURITY;
ALTER TABLE candidatos            ENABLE ROW LEVEL SECURITY;
ALTER TABLE educacion             ENABLE ROW LEVEL SECURITY;
ALTER TABLE certificados          ENABLE ROW LEVEL SECURITY;
ALTER TABLE experiencia_laboral   ENABLE ROW LEVEL SECURITY;
ALTER TABLE referencias           ENABLE ROW LEVEL SECURITY;
ALTER TABLE competencias          ENABLE ROW LEVEL SECURITY;
ALTER TABLE idiomas               ENABLE ROW LEVEL SECURITY;
ALTER TABLE disponibilidad_candidato ENABLE ROW LEVEL SECURITY;
ALTER TABLE empresas              ENABLE ROW LEVEL SECURITY;
ALTER TABLE vacantes              ENABLE ROW LEVEL SECURITY;
ALTER TABLE postulaciones         ENABLE ROW LEVEL SECURITY;
ALTER TABLE pruebas               ENABLE ROW LEVEL SECURITY;
ALTER TABLE envios_prueba         ENABLE ROW LEVEL SECURITY;
ALTER TABLE diagnosticos          ENABLE ROW LEVEL SECURITY;
ALTER TABLE log_actividad         ENABLE ROW LEVEL SECURITY;

-- Municipios: lectura pública (no contiene datos sensibles)
ALTER TABLE municipios ENABLE ROW LEVEL SECURITY;
CREATE POLICY "municipios_lectura_publica"
  ON municipios FOR SELECT USING (TRUE);

-- ============================================================
-- HELPER: función para obtener el rol del usuario actual
-- ============================================================
CREATE OR REPLACE FUNCTION mi_rol()
RETURNS rol_usuario AS $$
  SELECT rol FROM perfiles WHERE id = auth.uid();
$$ LANGUAGE sql SECURITY DEFINER STABLE;

CREATE OR REPLACE FUNCTION es_admin_o_intermediador()
RETURNS BOOLEAN AS $$
  SELECT mi_rol() IN ('administrador', 'intermediador', 'asesor_empresarial');
$$ LANGUAGE sql SECURITY DEFINER STABLE;

-- ============================================================
-- POLÍTICAS: perfiles
-- ============================================================
CREATE POLICY "perfil_propio_lectura"
  ON perfiles FOR SELECT
  USING (id = auth.uid() OR es_admin_o_intermediador());

CREATE POLICY "perfil_propio_actualizar"
  ON perfiles FOR UPDATE
  USING (id = auth.uid());

-- El perfil se crea automáticamente via trigger en auth.users
CREATE POLICY "perfil_insertar_propio"
  ON perfiles FOR INSERT
  WITH CHECK (id = auth.uid());

-- ============================================================
-- POLÍTICAS: candidatos
-- ============================================================

-- Candidato: ve y edita solo su propio registro
CREATE POLICY "candidato_propio"
  ON candidatos FOR ALL
  USING (
    perfil_id = auth.uid()
    OR es_admin_o_intermediador()
    OR (hv_publica = TRUE AND mi_rol() IN ('empresa'))
  );

-- ============================================================
-- POLÍTICAS: tablas hijas de candidatos (educacion, exp, etc.)
-- ============================================================

-- Función helper para verificar si el candidato_id pertenece al usuario
CREATE OR REPLACE FUNCTION es_mi_candidato(p_candidato_id UUID)
RETURNS BOOLEAN AS $$
  SELECT EXISTS (
    SELECT 1 FROM candidatos
    WHERE id = p_candidato_id
    AND (perfil_id = auth.uid() OR es_admin_o_intermediador())
  );
$$ LANGUAGE sql SECURITY DEFINER STABLE;

CREATE POLICY "educacion_acceso"
  ON educacion FOR ALL USING (es_mi_candidato(candidato_id));

CREATE POLICY "certificados_acceso"
  ON certificados FOR ALL USING (es_mi_candidato(candidato_id));

CREATE POLICY "experiencia_acceso"
  ON experiencia_laboral FOR ALL USING (es_mi_candidato(candidato_id));

CREATE POLICY "referencias_acceso"
  ON referencias FOR ALL USING (es_mi_candidato(candidato_id));

CREATE POLICY "competencias_acceso"
  ON competencias FOR ALL USING (es_mi_candidato(candidato_id));

CREATE POLICY "idiomas_acceso"
  ON idiomas FOR ALL USING (es_mi_candidato(candidato_id));

CREATE POLICY "disponibilidad_acceso"
  ON disponibilidad_candidato FOR ALL USING (es_mi_candidato(candidato_id));

-- ============================================================
-- POLÍTICAS: empresas
-- ============================================================

-- Lectura pública de empresas activas
CREATE POLICY "empresas_lectura_publica"
  ON empresas FOR SELECT
  USING (estado IN ('activa', 'verificada') OR es_admin_o_intermediador());

-- Solo asesores y administradores pueden crear/editar empresas
CREATE POLICY "empresas_gestion"
  ON empresas FOR INSERT
  WITH CHECK (mi_rol() IN ('asesor_empresarial', 'administrador'));

CREATE POLICY "empresas_actualizar"
  ON empresas FOR UPDATE
  USING (
    asesor_id = auth.uid()
    OR mi_rol() = 'administrador'
  );

-- Una empresa puede ver y editar solo su propio registro
CREATE POLICY "empresa_propio_registro"
  ON empresas FOR UPDATE
  USING (perfil_id = auth.uid());

-- ============================================================
-- POLÍTICAS: vacantes
-- ============================================================

-- Lectura pública de vacantes activas
CREATE POLICY "vacantes_lectura_publica"
  ON vacantes FOR SELECT
  USING (estado = 'activa' OR es_admin_o_intermediador() OR
    EXISTS (SELECT 1 FROM empresas WHERE id = vacantes.empresa_id AND perfil_id = auth.uid())
  );

-- Solo asesores y admins crean vacantes
CREATE POLICY "vacantes_crear"
  ON vacantes FOR INSERT
  WITH CHECK (mi_rol() IN ('asesor_empresarial', 'administrador'));

CREATE POLICY "vacantes_editar"
  ON vacantes FOR UPDATE
  USING (
    asesor_id = auth.uid()
    OR mi_rol() = 'administrador'
    OR EXISTS (SELECT 1 FROM empresas WHERE id = vacantes.empresa_id AND perfil_id = auth.uid())
  );

-- ============================================================
-- POLÍTICAS: postulaciones
-- ============================================================

-- Candidato ve solo sus postulaciones
CREATE POLICY "postulaciones_candidato"
  ON postulaciones FOR SELECT
  USING (
    EXISTS (SELECT 1 FROM candidatos WHERE id = postulaciones.candidato_id AND perfil_id = auth.uid())
    OR es_admin_o_intermediador()
    OR EXISTS (
      SELECT 1 FROM vacantes v
      JOIN empresas e ON e.id = v.empresa_id
      WHERE v.id = postulaciones.vacante_id AND e.perfil_id = auth.uid()
    )
  );

-- Candidato puede crear su propia postulación
CREATE POLICY "postulaciones_crear"
  ON postulaciones FOR INSERT
  WITH CHECK (
    EXISTS (SELECT 1 FROM candidatos WHERE id = postulaciones.candidato_id AND perfil_id = auth.uid())
    OR es_admin_o_intermediador()
  );

-- Solo intermediadores y admins cambian el estado de postulaciones
CREATE POLICY "postulaciones_actualizar"
  ON postulaciones FOR UPDATE
  USING (
    es_admin_o_intermediador()
    OR EXISTS (SELECT 1 FROM candidatos WHERE id = postulaciones.candidato_id AND perfil_id = auth.uid())
  );

-- ============================================================
-- POLÍTICAS: pruebas y envíos (Fase 2)
-- ============================================================

CREATE POLICY "pruebas_lectura_staff"
  ON pruebas FOR SELECT
  USING (es_admin_o_intermediador());

CREATE POLICY "envios_prueba_acceso"
  ON envios_prueba FOR SELECT
  USING (
    -- El candidato puede ver su envío por token (manejo en frontend)
    EXISTS (SELECT 1 FROM candidatos WHERE id = envios_prueba.candidato_id AND perfil_id = auth.uid())
    OR EXISTS (SELECT 1 FROM empresas WHERE id = envios_prueba.empresa_id AND perfil_id = auth.uid())
    OR es_admin_o_intermediador()
  );

CREATE POLICY "envios_prueba_crear"
  ON envios_prueba FOR INSERT
  WITH CHECK (es_admin_o_intermediador());

CREATE POLICY "envios_prueba_actualizar"
  ON envios_prueba FOR UPDATE
  USING (
    -- El candidato puede actualizar respuestas de su envío
    EXISTS (SELECT 1 FROM candidatos WHERE id = envios_prueba.candidato_id AND perfil_id = auth.uid())
    OR es_admin_o_intermediador()
  );

-- ============================================================
-- POLÍTICAS: diagnósticos
-- ============================================================

CREATE POLICY "diagnosticos_acceso"
  ON diagnosticos FOR SELECT
  USING (
    EXISTS (SELECT 1 FROM empresas WHERE id = diagnosticos.empresa_id AND perfil_id = auth.uid())
    OR es_admin_o_intermediador()
  );

CREATE POLICY "diagnosticos_crear"
  ON diagnosticos FOR ALL
  USING (es_admin_o_intermediador());

-- ============================================================
-- POLÍTICAS: log_actividad (solo admins)
-- ============================================================
CREATE POLICY "log_solo_admin"
  ON log_actividad FOR ALL
  USING (mi_rol() = 'administrador');

-- ============================================================
-- TRIGGER: crear perfil automáticamente al registrarse
-- ============================================================
CREATE OR REPLACE FUNCTION crear_perfil_nuevo_usuario()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO perfiles (id, correo, nombre, rol)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'nombre', split_part(NEW.email, '@', 1)),
    COALESCE((NEW.raw_user_meta_data->>'rol')::rol_usuario, 'candidato')
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER trg_crear_perfil
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION crear_perfil_nuevo_usuario();
