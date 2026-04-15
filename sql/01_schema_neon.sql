-- ============================================================
-- PLATAFORMA DIGITAL — Comfenalco Antioquia
-- Archivo: 01_schema_neon.sql
-- Base de datos: Neon (PostgreSQL serverless)
--
-- DIFERENCIA vs Supabase:
-- • No existe auth.users → usamos clerk_user_id (TEXT) directamente
-- • No hay Row Level Security automático → el control es en el frontend
--   con Clerk, o en funciones PostgreSQL con SECURITY DEFINER
-- ============================================================

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "unaccent";

-- ============================================================
-- ENUM TYPES
-- ============================================================
CREATE TYPE rol_usuario AS ENUM (
  'candidato','asesor_empresarial','intermediador','empresa','administrador'
);
CREATE TYPE estado_vacante AS ENUM (
  'activa','en_seleccion','cerrada','cubierta','pausada'
);
CREATE TYPE tipo_contrato AS ENUM (
  'termino_fijo','termino_indefinido','prestacion_servicios',
  'aprendizaje','obra_labor','temporal'
);
CREATE TYPE jornada AS ENUM (
  'completa','medio_tiempo','nocturna','fines_de_semana','flexible','teletrabajo'
);
CREATE TYPE nivel_educativo AS ENUM (
  'primaria','secundaria','tecnico','tecnologo',
  'profesional','especializacion','maestria','doctorado'
);
CREATE TYPE estado_educacion  AS ENUM ('graduado','en_curso','incompleto');
CREATE TYPE tipo_experiencia  AS ENUM ('empleado','independiente','practicante','voluntariado','emprendimiento');
CREATE TYPE condicion_especial AS ENUM (
  'ninguna','joven','victima_conflicto','discapacidad',
  'migrante','adulto_mayor','madre_cabeza','lgbtiq'
);
CREATE TYPE estado_postulacion AS ENUM (
  'postulado','en_revision','preseleccionado','entrevistado',
  'enviado_empresa','contratado','descartado'
);
CREATE TYPE estado_empresa AS ENUM ('activa','verificada','inactiva','suspendida');
CREATE TYPE nivel_idioma   AS ENUM ('A1','A2','B1','B2','C1','C2','nativo');
CREATE TYPE tipo_prueba    AS ENUM ('psicotecnica','clima_organizacional','diagnostico_liderazgo','necesidades_talento','personalidad');
CREATE TYPE estado_prueba  AS ENUM ('pendiente','en_progreso','completada','vencida');

-- ============================================================
-- TABLA: perfiles
-- clerk_user_id = el "sub" que Clerk le asigna a cada usuario
-- ============================================================
CREATE TABLE perfiles (
  id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  clerk_user_id   TEXT UNIQUE NOT NULL,   -- viene de Clerk (user.id)
  rol             rol_usuario NOT NULL DEFAULT 'candidato',
  nombre          TEXT NOT NULL,
  apellidos       TEXT,
  correo          TEXT NOT NULL,
  celular         TEXT,
  activo          BOOLEAN DEFAULT TRUE,
  created_at      TIMESTAMPTZ DEFAULT NOW(),
  updated_at      TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- TABLA: municipios
-- ============================================================
CREATE TABLE municipios (
  id        SERIAL PRIMARY KEY,
  nombre    TEXT NOT NULL UNIQUE,
  subregion TEXT NOT NULL,
  cod_dane  TEXT
);

-- ============================================================
-- TABLA: candidatos
-- ============================================================
CREATE TABLE candidatos (
  id                   UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  perfil_id            UUID REFERENCES perfiles(id) ON DELETE CASCADE,
  nombres              TEXT NOT NULL,
  apellidos            TEXT NOT NULL,
  tipo_documento       TEXT DEFAULT 'CC',
  numero_documento     TEXT UNIQUE NOT NULL,
  fecha_nacimiento     DATE,
  genero               TEXT,
  municipio_id         INTEGER REFERENCES municipios(id),
  direccion            TEXT,
  correo               TEXT NOT NULL,
  celular              TEXT,
  area_interes         TEXT,
  pretension_salarial  INTEGER,
  perfil_profesional   TEXT,
  condicion_especial   condicion_especial DEFAULT 'ninguna',
  foto_url             TEXT,
  porcentaje_completitud INTEGER DEFAULT 0,
  hv_publica           BOOLEAN DEFAULT TRUE,
  activo               BOOLEAN DEFAULT TRUE,
  created_at           TIMESTAMPTZ DEFAULT NOW(),
  updated_at           TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- TABLAS HIJAS DE CANDIDATOS
-- ============================================================
CREATE TABLE educacion (
  id           UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  candidato_id UUID NOT NULL REFERENCES candidatos(id) ON DELETE CASCADE,
  nivel        nivel_educativo NOT NULL,
  titulo       TEXT NOT NULL,
  institucion  TEXT NOT NULL,
  municipio    TEXT,
  anio_inicio  INTEGER,
  anio_fin     INTEGER,
  estado       estado_educacion DEFAULT 'graduado',
  promedio     NUMERIC(3,1),
  created_at   TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE certificados (
  id               UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  candidato_id     UUID NOT NULL REFERENCES candidatos(id) ON DELETE CASCADE,
  nombre           TEXT NOT NULL,
  institucion      TEXT,
  anio             INTEGER,
  horas            INTEGER,
  certificado_url  TEXT,
  created_at       TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE experiencia_laboral (
  id                UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  candidato_id      UUID NOT NULL REFERENCES candidatos(id) ON DELETE CASCADE,
  tipo              tipo_experiencia NOT NULL,
  cargo             TEXT NOT NULL,
  empresa           TEXT,
  ciudad            TEXT,
  sector            TEXT,
  fecha_inicio      DATE NOT NULL,
  fecha_fin         DATE,
  es_trabajo_actual BOOLEAN DEFAULT FALSE,
  funciones         TEXT,
  logros            TEXT,
  motivo_retiro     TEXT,
  created_at        TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE referencias (
  id           UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  candidato_id UUID NOT NULL REFERENCES candidatos(id) ON DELETE CASCADE,
  tipo         TEXT NOT NULL,
  nombre       TEXT NOT NULL,
  cargo        TEXT,
  empresa      TEXT,
  telefono     TEXT,
  correo       TEXT,
  created_at   TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE competencias (
  id           UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  candidato_id UUID NOT NULL REFERENCES candidatos(id) ON DELETE CASCADE,
  nombre       TEXT NOT NULL,
  tipo         TEXT NOT NULL,
  nivel        TEXT,
  created_at   TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE idiomas (
  id               UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  candidato_id     UUID NOT NULL REFERENCES candidatos(id) ON DELETE CASCADE,
  idioma           TEXT NOT NULL,
  nivel_escucha    nivel_idioma,
  nivel_habla      nivel_idioma,
  nivel_lectura    nivel_idioma,
  nivel_escritura  nivel_idioma,
  created_at       TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE disponibilidad_candidato (
  id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  candidato_id        UUID NOT NULL REFERENCES candidatos(id) ON DELETE CASCADE UNIQUE,
  disponible_desde    DATE,
  tipo_contrato_pref  tipo_contrato[],
  jornada_pref        jornada[],
  disponible_viajar   BOOLEAN DEFAULT FALSE,
  disponible_cambio   BOOLEAN DEFAULT FALSE,
  updated_at          TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- TABLA: empresas
-- ============================================================
CREATE TABLE empresas (
  id                UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  perfil_id         UUID REFERENCES perfiles(id),
  nombre            TEXT NOT NULL,
  nit               TEXT UNIQUE,
  sector            TEXT,
  descripcion       TEXT,
  municipio_id      INTEGER REFERENCES municipios(id),
  direccion         TEXT,
  telefono          TEXT,
  correo_contacto   TEXT,
  correo_seleccion  TEXT,
  nombre_contacto   TEXT,
  cargo_contacto    TEXT,
  logo_url          TEXT,
  estado            estado_empresa DEFAULT 'activa',
  asesor_id         UUID REFERENCES perfiles(id),
  created_at        TIMESTAMPTZ DEFAULT NOW(),
  updated_at        TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- TABLA: vacantes
-- ============================================================
CREATE TABLE vacantes (
  id                    UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  empresa_id            UUID NOT NULL REFERENCES empresas(id) ON DELETE CASCADE,
  cargo                 TEXT NOT NULL,
  descripcion           TEXT,
  requisitos            TEXT,
  municipio_id          INTEGER REFERENCES municipios(id),
  salario_min           INTEGER,
  salario_max           INTEGER,
  tipo_contrato         tipo_contrato,
  jornada               jornada,
  experiencia_min       INTEGER DEFAULT 0,
  nivel_educativo_min   nivel_educativo,
  es_incluyente         BOOLEAN DEFAULT FALSE,
  poblacion_objetivo    condicion_especial[],
  fecha_publicacion     DATE DEFAULT CURRENT_DATE,
  fecha_cierre          DATE,
  estado                estado_vacante DEFAULT 'activa',
  num_vacantes          INTEGER DEFAULT 1,
  asesor_id             UUID REFERENCES perfiles(id),
  created_at            TIMESTAMPTZ DEFAULT NOW(),
  updated_at            TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- TABLA: postulaciones
-- ============================================================
CREATE TABLE postulaciones (
  id                UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  vacante_id        UUID NOT NULL REFERENCES vacantes(id) ON DELETE CASCADE,
  candidato_id      UUID NOT NULL REFERENCES candidatos(id) ON DELETE CASCADE,
  estado            estado_postulacion DEFAULT 'postulado',
  fecha_postulacion TIMESTAMPTZ DEFAULT NOW(),
  notas_internas    TEXT,
  hv_enviada        BOOLEAN DEFAULT FALSE,
  fecha_hv_enviada  TIMESTAMPTZ,
  intermediador_id  UUID REFERENCES perfiles(id),
  updated_at        TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE (vacante_id, candidato_id)
);

-- ============================================================
-- TABLAS FASE 2
-- ============================================================
CREATE TABLE pruebas (
  id               UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  tipo             tipo_prueba NOT NULL,
  titulo           TEXT NOT NULL,
  descripcion      TEXT,
  tiempo_limite_min INTEGER,
  preguntas        JSONB,
  activa           BOOLEAN DEFAULT TRUE,
  created_at       TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE envios_prueba (
  id               UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  prueba_id        UUID NOT NULL REFERENCES pruebas(id),
  candidato_id     UUID REFERENCES candidatos(id),
  empresa_id       UUID REFERENCES empresas(id),
  token_acceso     TEXT UNIQUE DEFAULT encode(gen_random_bytes(32), 'hex'),
  estado           estado_prueba DEFAULT 'pendiente',
  fecha_envio      TIMESTAMPTZ DEFAULT NOW(),
  fecha_limite     TIMESTAMPTZ,
  fecha_completado TIMESTAMPTZ,
  respuestas       JSONB,
  resultado_json   JSONB,
  enviado_por      UUID REFERENCES perfiles(id),
  created_at       TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE diagnosticos (
  id               UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  empresa_id       UUID NOT NULL REFERENCES empresas(id),
  tipo             TEXT NOT NULL,
  titulo           TEXT NOT NULL,
  fecha_aplicacion TIMESTAMPTZ,
  participantes    INTEGER,
  resultados_json  JSONB,
  informe_url      TEXT,
  enviado_por      UUID REFERENCES perfiles(id),
  created_at       TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE log_actividad (
  id             BIGSERIAL PRIMARY KEY,
  clerk_user_id  TEXT,
  accion         TEXT NOT NULL,
  tabla_afectada TEXT,
  registro_id    TEXT,
  detalle        JSONB,
  created_at     TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- ÍNDICES
-- ============================================================
CREATE INDEX idx_perfiles_clerk      ON perfiles(clerk_user_id);
CREATE INDEX idx_candidatos_municipio ON candidatos(municipio_id);
CREATE INDEX idx_candidatos_area      ON candidatos(area_interes);
CREATE INDEX idx_candidatos_condicion ON candidatos(condicion_especial);
CREATE INDEX idx_candidatos_documento ON candidatos(numero_documento);
CREATE INDEX idx_vacantes_empresa     ON vacantes(empresa_id);
CREATE INDEX idx_vacantes_municipio   ON vacantes(municipio_id);
CREATE INDEX idx_vacantes_estado      ON vacantes(estado);
CREATE INDEX idx_postulaciones_vacante  ON postulaciones(vacante_id);
CREATE INDEX idx_postulaciones_candidato ON postulaciones(candidato_id);
CREATE INDEX idx_empresas_municipio   ON empresas(municipio_id);

CREATE INDEX idx_candidatos_fts ON candidatos
  USING gin(to_tsvector('spanish', nombres || ' ' || apellidos));
CREATE INDEX idx_vacantes_fts ON vacantes
  USING gin(to_tsvector('spanish', cargo || ' ' || COALESCE(descripcion, '')));

-- ============================================================
-- TRIGGERS updated_at
-- ============================================================
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN NEW.updated_at = NOW(); RETURN NEW; END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_perfiles_upd      BEFORE UPDATE ON perfiles      FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER trg_candidatos_upd    BEFORE UPDATE ON candidatos    FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER trg_empresas_upd      BEFORE UPDATE ON empresas      FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER trg_vacantes_upd      BEFORE UPDATE ON vacantes      FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER trg_postulaciones_upd BEFORE UPDATE ON postulaciones FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- ============================================================
-- TRIGGER: completitud de HV
-- ============================================================
CREATE OR REPLACE FUNCTION calcular_completitud(p_id UUID)
RETURNS INTEGER AS $$
DECLARE score INTEGER := 0; c candidatos%ROWTYPE;
BEGIN
  SELECT * INTO c FROM candidatos WHERE id = p_id;
  IF c.nombres IS NOT NULL AND c.apellidos IS NOT NULL THEN score := score + 15; END IF;
  IF c.numero_documento IS NOT NULL THEN score := score + 5; END IF;
  IF c.correo IS NOT NULL THEN score := score + 5; END IF;
  IF c.celular IS NOT NULL THEN score := score + 5; END IF;
  IF c.municipio_id IS NOT NULL THEN score := score + 5; END IF;
  IF c.perfil_profesional IS NOT NULL AND length(c.perfil_profesional) > 50 THEN score := score + 10; END IF;
  IF EXISTS (SELECT 1 FROM educacion WHERE candidato_id = p_id) THEN score := score + 20; END IF;
  IF EXISTS (SELECT 1 FROM experiencia_laboral WHERE candidato_id = p_id) THEN score := score + 20; END IF;
  IF EXISTS (SELECT 1 FROM competencias WHERE candidato_id = p_id) THEN score := score + 10; END IF;
  IF EXISTS (SELECT 1 FROM idiomas WHERE candidato_id = p_id) THEN score := score + 5; END IF;
  RETURN LEAST(score, 100);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION trg_recalcular_completitud()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE candidatos SET porcentaje_completitud = calcular_completitud(
    CASE TG_TABLE_NAME WHEN 'candidatos' THEN NEW.id ELSE NEW.candidato_id END
  ) WHERE id = CASE TG_TABLE_NAME WHEN 'candidatos' THEN NEW.id ELSE NEW.candidato_id END;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_comp_candidato AFTER INSERT OR UPDATE ON candidatos        FOR EACH ROW EXECUTE FUNCTION trg_recalcular_completitud();
CREATE TRIGGER trg_comp_edu       AFTER INSERT OR UPDATE OR DELETE ON educacion          FOR EACH ROW EXECUTE FUNCTION trg_recalcular_completitud();
CREATE TRIGGER trg_comp_exp       AFTER INSERT OR UPDATE OR DELETE ON experiencia_laboral FOR EACH ROW EXECUTE FUNCTION trg_recalcular_completitud();
CREATE TRIGGER trg_comp_comp      AFTER INSERT OR UPDATE OR DELETE ON competencias        FOR EACH ROW EXECUTE FUNCTION trg_recalcular_completitud();
CREATE TRIGGER trg_comp_idiomas   AFTER INSERT OR UPDATE OR DELETE ON idiomas             FOR EACH ROW EXECUTE FUNCTION trg_recalcular_completitud();
