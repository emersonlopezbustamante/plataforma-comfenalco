// ============================================================
// config/db.js
// Cliente Neon (PostgreSQL serverless)
// Plataforma Digital — Comfenalco Antioquia
// ============================================================

import { neon } from 'https://esm.sh/@neondatabase/serverless@0.9.3';

const NEON_URL = 'postgresql://neondb_owner:npg_keJWhZi1wc4q@ep-flat-cloud-acl6xz00-pooler.sa-east-1.aws.neon.tech/neondb?sslmode=require&channel_binding=require';

export const sql = neon(NEON_URL);

// ── Helper genérico ─────────────────────────────────────────
export const DB = {

  async query(queryStr, params = []) {
    try {
      const result = await sql(queryStr, params);
      return { data: result, error: null };
    } catch (err) {
      console.error('DB Error:', err.message);
      return { data: null, error: err.message };
    }
  },

  async one(queryStr, params = []) {
    const { data, error } = await this.query(queryStr, params);
    return { data: data?.[0] ?? null, error };
  },

  // Estadísticas generales del dashboard
  async estadisticas() {
    const { data, error } = await this.one('SELECT fn_estadisticas_generales() AS stats');
    return { data: data?.stats ?? null, error };
  },

  // Vacantes para la landing
  async vacantesRecientes(limite = 6) {
    return this.query(
      'SELECT * FROM fn_buscar_vacantes(NULL, NULL, NULL, NULL, NULL, NULL, $1, 0)',
      [limite]
    );
  },

  // Buscar vacantes con filtros
  async buscarVacantes({ texto = null, municipioId = null, limite = 10, offset = 0 } = {}) {
    return this.query(
      'SELECT * FROM fn_buscar_vacantes($1, $2, NULL, NULL, NULL, NULL, $3, $4)',
      [texto, municipioId, limite, offset]
    );
  },

  // Buscar candidatos banco de HV
  async buscarCandidatos({ municipioId = null, areaInteres = null, texto = null, limite = 20, offset = 0 } = {}) {
    return this.query(
      'SELECT * FROM fn_buscar_candidatos($1, NULL, $2, NULL, NULL, NULL, $3, $4, $5)',
      [municipioId, areaInteres, texto, limite, offset]
    );
  },

  // HV completa de un candidato
  async hvCompleta(candidatoId) {
    const { data, error } = await this.one('SELECT fn_hv_completa($1) AS hv', [candidatoId]);
    return { data: data?.hv ?? null, error };
  },

  // Municipios para los selects
  async municipios() {
    return this.query('SELECT id, nombre, subregion FROM municipios ORDER BY nombre');
  },

  // Insertar o actualizar perfil al hacer login con Clerk
  async upsertPerfil({ clerkUserId, nombre, apellidos, correo, rol = 'candidato' }) {
    return this.one(`
      INSERT INTO perfiles (clerk_user_id, nombre, apellidos, correo, rol)
      VALUES ($1, $2, $3, $4, $5)
      ON CONFLICT (clerk_user_id) DO UPDATE
        SET nombre    = EXCLUDED.nombre,
            apellidos = EXCLUDED.apellidos,
            correo    = EXCLUDED.correo,
            updated_at = NOW()
      RETURNING *
    `, [clerkUserId, nombre, apellidos, correo, rol]);
  },

  // Obtener perfil por clerk_user_id
  async perfilPorClerk(clerkUserId) {
    return this.one(
      'SELECT * FROM perfiles WHERE clerk_user_id = $1',
      [clerkUserId]
    );
  },

  // Candidato por perfil_id
  async candidatoPorPerfil(perfilId) {
    return this.one(
      'SELECT * FROM candidatos WHERE perfil_id = $1',
      [perfilId]
    );
  },

  // Indicadores para reportes
  async indicadoresPeriodo(fechaInicio, fechaFin, municipioId = null) {
    const { data, error } = await this.one(
      'SELECT fn_indicadores_periodo($1, $2, $3) AS indicadores',
      [fechaInicio, fechaFin, municipioId]
    );
    return { data: data?.indicadores ?? null, error };
  }
};

export default DB;
