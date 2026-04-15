-- ============================================================
-- PLATAFORMA DIGITAL — Agencia de Empleo y Emprendimiento
-- Comfenalco Antioquia
-- Archivo: 01_schema.sql
-- Ejecutar en: Supabase → SQL Editor
-- ============================================================

-- Habilitar extensiones necesarias
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "unaccent";

-- ============================================================
-- ENUM TYPES — Valores controlados
-- ============================================================

CREATE TYPE rol_usuario AS ENUM (
  'candidato',
  'asesor_empresarial',
  'intermediador',
  'empresa',
  'administrador'
);

CREATE TYPE estado_vacante AS ENUM (
  'activa',
  'en_seleccion',
  'cerrada',
  'cubierta',
  'pausada'
);

CREATE TYPE tipo_contrato AS ENUM (
  'termino_fijo',
  'termino_indefinido',
  'prestacion_servicios',
  'aprendizaje',
  'obra_labor',
  'temporal'
);

CREATE TYPE jornada AS ENUM (
  'completa',
  'medio_tiempo',
  'nocturna',
  'fines_de_semana',
  'flexible',
  'teletrabajo'
);

CREATE TYPE nivel_educativo AS ENUM (
  'primaria',
  'secundaria',
  'tecnico',
  'tecnologo',
  'profesional',
  'especializacion',
  'maestria',
  'doctorado'
);

CREATE TYPE estado_educacion AS ENUM (
  'graduado',
  'en_curso',
  'incompleto'
);

CREATE TYPE tipo_experiencia AS ENUM (
  'empleado',
  'independiente',
  'practicante',
  'voluntariado',
  'emprendimiento'
);

CREATE TYPE condicion_especial AS ENUM (
  'ninguna',
  'joven',
  'victima_conflicto',
  'discapacidad',
  'migrante',
  'adulto_mayor',
  'madre_cabeza',
  'lgbtiq'
);

CREATE TYPE estado_postulacion AS ENUM (
  'postulado',
  'en_revision',
  'preseleccionado',
  'entrevistado',
  'enviado_empresa',
  'contratado',
  'descartado'
);

CREATE TYPE estado_empresa AS ENUM (
  'activa',
  'verificada',
  'inactiva',
  'suspendida'
);

CREATE TYPE nivel_idioma AS ENUM (
  'A1', 'A2', 'B1', 'B2', 'C1', 'C2', 'nativo'
);

CREATE TYPE tipo_prueba AS ENUM (
  'psicotecnica',
  'clima_organizacional',
  'diagnostico_liderazgo',
  'necesidades_talento',
  'personalidad'
);

CREATE TYPE estado_prueba AS ENUM (
  'pendiente',
  'en_progreso',
  'completada',
  'vencida'
);

-- ============================================================
-- TABLA: perfiles (extiende auth.users de Supabase)
-- ============================================================
CREATE TABLE perfiles (
  id            UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  rol           rol_usuario NOT NULL DEFAULT 'candidato',
  nombre        TEXT NOT NULL,
  apellidos     TEXT,
  correo        TEXT NOT NULL,
  celular       TEXT,
  activo        BOOLEAN DEFAULT TRUE,
  created_at    TIMESTAMPTZ DEFAULT NOW(),
  updated_at    TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- TABLA: municipios (catálogo de Antioquia)
-- ============================================================
CREATE TABLE municipios (
  id          SERIAL PRIMARY KEY,
  nombre      TEXT NOT NULL UNIQUE,
  subregion   TEXT NOT NULL,
  -- Subregiones: Valle de Aburrá, Oriente, Occidente, Norte,
  -- Nordeste, Bajo Cauca, Magdalena Medio, Suroeste, Urabá
  cod_dane    TEXT
);

-- ============================================================
-- TABLA: candidatos
-- ============================================================
CREATE TABLE candidatos (
  id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  perfil_id           UUID REFERENCES perfiles(id) ON DELETE CASCADE,

  -- Datos personales (Paso 2)
  nombres             TEXT NOT NULL,
  apellidos           TEXT NOT NULL,
  tipo_documento      TEXT DEFAULT 'CC',      -- CC, CE, TI, PA
  numero_documento    TEXT UNIQUE NOT NULL,
  fecha_nacimiento    DATE,
  genero              TEXT,                   -- M, F, No binario, Prefiero no decir
  municipio_id        INTEGER REFERENCES municipios(id),
  direccion           TEXT,
  correo              TEXT NOT NULL,
  celular             TEXT,
  area_interes        TEXT,
  pretension_salarial INTEGER,                -- en COP
  perfil_profesional  TEXT,                  -- texto libre
  condicion_especial  condicion_especial DEFAULT 'ninguna',
  foto_url            TEXT,                  -- Supabase Storage

  -- Metadatos HV
  porcentaje_completitud  INTEGER DEFAULT 0,
  hv_publica              BOOLEAN DEFAULT TRUE,
  activo                  BOOLEAN DEFAULT TRUE,
  created_at              TIMESTAMPTZ DEFAULT NOW(),
  updated_at              TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- TABLA: educacion
-- ============================================================
CREATE TABLE educacion (
  id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  candidato_id        UUID NOT NULL REFERENCES candidatos(id) ON DELETE CASCADE,
  nivel               nivel_educativo NOT NULL,
  titulo              TEXT NOT NULL,
  institucion         TEXT NOT NULL,
  municipio           TEXT,
  anio_inicio         INTEGER,
  anio_fin            INTEGER,
  estado              estado_educacion DEFAULT 'graduado',
  promedio            NUMERIC(3,1),
  created_at          TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- TABLA: certificados (cursos, diplomados, talleres)
-- ============================================================
CREATE TABLE certificados (
  id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  candidato_id        UUID NOT NULL REFERENCES candidatos(id) ON DELETE CASCADE,
  nombre              TEXT NOT NULL,
  institucion         TEXT,
  anio                INTEGER,
  horas               INTEGER,
  certificado_url     TEXT,                  -- Supabase Storage
  created_at          TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- TABLA: experiencia_laboral
-- ============================================================
CREATE TABLE experiencia_laboral (
  id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  candidato_id        UUID NOT NULL REFERENCES candidatos(id) ON DELETE CASCADE,
  tipo                tipo_experiencia NOT NULL,
  cargo               TEXT NOT NULL,
  empresa             TEXT,
  ciudad              TEXT,
  sector              TEXT,
  fecha_inicio        DATE NOT NULL,
  fecha_fin           DATE,
  es_trabajo_actual   BOOLEAN DEFAULT FALSE,
  funciones           TEXT,
  logros              TEXT,
  motivo_retiro       TEXT,
  created_at          TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- TABLA: referencias
-- ============================================================
CREATE TABLE referencias (
  id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  candidato_id        UUID NOT NULL REFERENCES candidatos(id) ON DELETE CASCADE,
  tipo                TEXT NOT NULL,          -- laboral, personal, academica
  nombre              TEXT NOT NULL,
  cargo               TEXT,
  empresa             TEXT,
  telefono            TEXT,
  correo              TEXT,
  created_at          TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- TABLA: competencias
-- ============================================================
CREATE TABLE competencias (
  id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  candidato_id        UUID NOT NULL REFERENCES candidatos(id) ON DELETE CASCADE,
  nombre              TEXT NOT NULL,
  tipo                TEXT NOT NULL,          -- blanda, tecnica
  nivel               TEXT,                  -- básico, intermedio, avanzado
  created_at          TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- TABLA: idiomas
-- ============================================================
CREATE TABLE idiomas (
  id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  candidato_id        UUID NOT NULL REFERENCES candidatos(id) ON DELETE CASCADE,
  idioma              TEXT NOT NULL,
  nivel_escucha       nivel_idioma,
  nivel_habla         nivel_idioma,
  nivel_lectura       nivel_idioma,
  nivel_escritura     nivel_idioma,
  created_at          TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- TABLA: disponibilidad (del candidato)
-- ============================================================
CREATE TABLE disponibilidad_candidato (
  id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  candidato_id        UUID NOT NULL REFERENCES candidatos(id) ON DELETE CASCADE UNIQUE,
  disponible_desde    DATE,
  tipo_contrato_pref  tipo_contrato[],
  jornada_pref        jornada[],
  disponible_viajar   BOOLEAN DEFAULT FALSE,
  disponible_cambio   BOOLEAN DEFAULT FALSE,  -- cambio de ciudad
  updated_at          TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- TABLA: empresas
-- ============================================================
CREATE TABLE empresas (
  id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  perfil_id           UUID REFERENCES perfiles(id),          -- usuario empresa (si tiene acceso)
  nombre              TEXT NOT NULL,
  nit                 TEXT UNIQUE,
  sector              TEXT,
  descripcion         TEXT,
  municipio_id        INTEGER REFERENCES municipios(id),
  direccion           TEXT,
  telefono            TEXT,
  correo_contacto     TEXT,
  correo_seleccion    TEXT,                   -- para envío de HVs
  nombre_contacto     TEXT,
  cargo_contacto      TEXT,
  logo_url            TEXT,                  -- Supabase Storage
  estado              estado_empresa DEFAULT 'activa',
  asesor_id           UUID REFERENCES perfiles(id),          -- asesor empresarial asignado
  created_at          TIMESTAMPTZ DEFAULT NOW(),
  updated_at          TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- TABLA: vacantes
-- ============================================================
CREATE TABLE vacantes (
  id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  empresa_id          UUID NOT NULL REFERENCES empresas(id) ON DELETE CASCADE,
  cargo               TEXT NOT NULL,
  descripcion         TEXT,
  requisitos          TEXT,
  municipio_id        INTEGER REFERENCES municipios(id),
  salario_min         INTEGER,
  salario_max         INTEGER,
  tipo_contrato       tipo_contrato,
  jornada             jornada,
  experiencia_min     INTEGER DEFAULT 0,      -- meses
  nivel_educativo_min nivel_educativo,
  es_incluyente       BOOLEAN DEFAULT FALSE,  -- vacante incluyente
  poblacion_objetivo  condicion_especial[],
  fecha_publicacion   DATE DEFAULT CURRENT_DATE,
  fecha_cierre        DATE,
  estado              estado_vacante DEFAULT 'activa',
  num_vacantes        INTEGER DEFAULT 1,
  asesor_id           UUID REFERENCES perfiles(id),
  created_at          TIMESTAMPTZ DEFAULT NOW(),
  updated_at          TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- TABLA: postulaciones
-- ============================================================
CREATE TABLE postulaciones (
  id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  vacante_id          UUID NOT NULL REFERENCES vacantes(id) ON DELETE CASCADE,
  candidato_id        UUID NOT NULL REFERENCES candidatos(id) ON DELETE CASCADE,
  estado              estado_postulacion DEFAULT 'postulado',
  fecha_postulacion   TIMESTAMPTZ DEFAULT NOW(),
  notas_internas      TEXT,                  -- solo visible para intermediador/asesor
  hv_enviada          BOOLEAN DEFAULT FALSE,
  fecha_hv_enviada    TIMESTAMPTZ,
  intermediador_id    UUID REFERENCES perfiles(id),
  updated_at          TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE (vacante_id, candidato_id)
);

-- ============================================================
-- TABLA: pruebas (Fase 2)
-- ============================================================
CREATE TABLE pruebas (
  id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  tipo                tipo_prueba NOT NULL,
  titulo              TEXT NOT NULL,
  descripcion         TEXT,
  tiempo_limite_min   INTEGER,               -- minutos
  preguntas           JSONB,                 -- estructura flexible de preguntas
  activa              BOOLEAN DEFAULT TRUE,
  created_at          TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- TABLA: envios_prueba (Fase 2)
-- ============================================================
CREATE TABLE envios_prueba (
  id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  prueba_id           UUID NOT NULL REFERENCES pruebas(id),
  -- Puede enviarse a candidato O a empresa (no ambos)
  candidato_id        UUID REFERENCES candidatos(id),
  empresa_id          UUID REFERENCES empresas(id),
  token_acceso        TEXT UNIQUE DEFAULT encode(gen_random_bytes(32), 'hex'),
  estado              estado_prueba DEFAULT 'pendiente',
  fecha_envio         TIMESTAMPTZ DEFAULT NOW(),
  fecha_limite        TIMESTAMPTZ,
  fecha_completado    TIMESTAMPTZ,
  respuestas          JSONB,
  resultado_json      JSONB,                 -- puntajes por dimensión
  enviado_por         UUID REFERENCES perfiles(id),
  created_at          TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- TABLA: diagnosticos_organizacionales (Fase 2)
-- ============================================================
CREATE TABLE diagnosticos (
  id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  empresa_id          UUID NOT NULL REFERENCES empresas(id),
  tipo                TEXT NOT NULL,         -- clima, liderazgo, necesidades_talento
  titulo              TEXT NOT NULL,
  fecha_aplicacion    TIMESTAMPTZ,
  participantes       INTEGER,
  resultados_json     JSONB,                 -- dimensiones con puntajes
  informe_url         TEXT,                  -- PDF generado en Storage
  enviado_por         UUID REFERENCES perfiles(id),
  created_at          TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- TABLA: log_actividad (auditoría)
-- ============================================================
CREATE TABLE log_actividad (
  id                  BIGSERIAL PRIMARY KEY,
  usuario_id          UUID REFERENCES perfiles(id),
  accion              TEXT NOT NULL,
  tabla_afectada      TEXT,
  registro_id         TEXT,
  detalle             JSONB,
  ip                  TEXT,
  created_at          TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- ÍNDICES para búsqueda eficiente
-- ============================================================
CREATE INDEX idx_candidatos_municipio   ON candidatos(municipio_id);
CREATE INDEX idx_candidatos_area        ON candidatos(area_interes);
CREATE INDEX idx_candidatos_condicion   ON candidatos(condicion_especial);
CREATE INDEX idx_candidatos_documento   ON candidatos(numero_documento);
CREATE INDEX idx_vacantes_empresa       ON vacantes(empresa_id);
CREATE INDEX idx_vacantes_municipio     ON vacantes(municipio_id);
CREATE INDEX idx_vacantes_estado        ON vacantes(estado);
CREATE INDEX idx_postulaciones_vacante  ON postulaciones(vacante_id);
CREATE INDEX idx_postulaciones_candidato ON postulaciones(candidato_id);
CREATE INDEX idx_postulaciones_estado   ON postulaciones(estado);
CREATE INDEX idx_empresas_municipio     ON empresas(municipio_id);
CREATE INDEX idx_empresas_estado        ON empresas(estado);

-- Búsqueda de texto en candidatos
CREATE INDEX idx_candidatos_nombres_fts ON candidatos
  USING gin(to_tsvector('spanish', nombres || ' ' || apellidos));

-- Búsqueda de texto en vacantes
CREATE INDEX idx_vacantes_cargo_fts ON vacantes
  USING gin(to_tsvector('spanish', cargo || ' ' || COALESCE(descripcion, '')));

-- ============================================================
-- TRIGGERS: updated_at automático
-- ============================================================
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_perfiles_updated       BEFORE UPDATE ON perfiles       FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER trg_candidatos_updated     BEFORE UPDATE ON candidatos     FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER trg_empresas_updated       BEFORE UPDATE ON empresas       FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER trg_vacantes_updated       BEFORE UPDATE ON vacantes       FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER trg_postulaciones_updated  BEFORE UPDATE ON postulaciones  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- ============================================================
-- TRIGGER: calcular completitud de HV automáticamente
-- ============================================================
CREATE OR REPLACE FUNCTION calcular_completitud(p_candidato_id UUID)
RETURNS INTEGER AS $$
DECLARE
  score INTEGER := 0;
  c candidatos%ROWTYPE;
BEGIN
  SELECT * INTO c FROM candidatos WHERE id = p_candidato_id;
  IF c.nombres IS NOT NULL AND c.apellidos IS NOT NULL THEN score := score + 15; END IF;
  IF c.numero_documento IS NOT NULL THEN score := score + 5; END IF;
  IF c.correo IS NOT NULL THEN score := score + 5; END IF;
  IF c.celular IS NOT NULL THEN score := score + 5; END IF;
  IF c.municipio_id IS NOT NULL THEN score := score + 5; END IF;
  IF c.perfil_profesional IS NOT NULL AND length(c.perfil_profesional) > 50 THEN score := score + 10; END IF;
  IF EXISTS (SELECT 1 FROM educacion WHERE candidato_id = p_candidato_id) THEN score := score + 20; END IF;
  IF EXISTS (SELECT 1 FROM experiencia_laboral WHERE candidato_id = p_candidato_id) THEN score := score + 20; END IF;
  IF EXISTS (SELECT 1 FROM competencias WHERE candidato_id = p_candidato_id) THEN score := score + 10; END IF;
  IF EXISTS (SELECT 1 FROM idiomas WHERE candidato_id = p_candidato_id) THEN score := score + 5; END IF;
  RETURN LEAST(score, 100);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION trg_recalcular_completitud()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE candidatos
  SET porcentaje_completitud = calcular_completitud(
    CASE TG_TABLE_NAME
      WHEN 'candidatos' THEN NEW.id
      ELSE NEW.candidato_id
    END
  )
  WHERE id = CASE TG_TABLE_NAME
    WHEN 'candidatos' THEN NEW.id
    ELSE NEW.candidato_id
  END;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_completitud_candidato  AFTER INSERT OR UPDATE ON candidatos        FOR EACH ROW EXECUTE FUNCTION trg_recalcular_completitud();
CREATE TRIGGER trg_completitud_educacion  AFTER INSERT OR UPDATE OR DELETE ON educacion          FOR EACH ROW EXECUTE FUNCTION trg_recalcular_completitud();
CREATE TRIGGER trg_completitud_exp        AFTER INSERT OR UPDATE OR DELETE ON experiencia_laboral FOR EACH ROW EXECUTE FUNCTION trg_recalcular_completitud();
CREATE TRIGGER trg_completitud_comp       AFTER INSERT OR UPDATE OR DELETE ON competencias        FOR EACH ROW EXECUTE FUNCTION trg_recalcular_completitud();
CREATE TRIGGER trg_completitud_idiomas    AFTER INSERT OR UPDATE OR DELETE ON idiomas             FOR EACH ROW EXECUTE FUNCTION trg_recalcular_completitud();
