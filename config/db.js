// ============================================================
// config/db.js
// Cliente Neon via HTTP — sin bloqueos de navegador
// ============================================================

const NEON_URL = 'postgresql://neondb_owner:npg_keJWhZi1wc4q@ep-flat-cloud-acl6xz00-pooler.sa-east-1.aws.neon.tech/neondb?sslmode=require';
const NEON_HTTP = 'https://ep-flat-cloud-acl6xz00-pooler.sa-east-1.aws.neon.tech/sql';

async function queryHTTP(sql, params = []) {
  try {
    const res = await fetch(NEON_HTTP, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer npg_keJWhZi1wc4q',
        'Neon-Connection-String': NEON_URL
      },
      body: JSON.stringify({ query: sql, params })
    });
    if (!res.ok) {
      const err = await res.text();
      console.error('Neon error:', err);
      return { data: null, error: err };
    }
    const json = await res.json();
    return { data: json.rows ?? [], error: null };
  } catch (err) {
    console.error('DB error:', err.message);
    return { data: null, error: err.message };
  }
}

export const DB = {

  async query(sql, params = []) {
    return queryHTTP(sql, params);
  },

  async one(sql, params = []) {
    const { data, error } = await queryHTTP(sql, params);
    return { data: data?.[0] ?? null, error };
  },

  async estadisticas() {
    const { data, error } = await this.one('SELECT fn_estadisticas_generales() AS stats');
    return { data: data?.stats ?? null, error };
  },

  async vacantesRecientes(limite = 6) {
    return this.query(
      'SELECT * FROM fn_buscar_vacantes(NULL, NULL, NULL, NULL, NULL, NULL, $1, 0)',
      [limite]
    );
  },

  async buscarVacantes({ texto = null, municipioId = null, limite = 10, offset = 0 } = {}) {
    return this.query(
      'SELECT * FROM fn_buscar_vacantes($1, $2, NULL, NULL, NULL, NULL, $3, $4)',
      [texto, municipioId, limite, offset]
    );
  },

  async buscarCandidatos({ municipioId = null, areaInteres = null, texto = null, limite = 20, offset = 0 } = {}) {
    return this.query(
      'SELECT * FROM fn_buscar_candidatos($1, NULL, $2, NULL, NULL, NULL, $3, $4, $5)',
      [municipioId, areaInteres, texto, limite, offset]
    );
  },

  async hvCompleta(candidatoId) {
    const { data, error } = await this.one('SELECT fn_hv_completa($1) AS hv', [candidatoId]);
    return { data: data?.hv ?? null, error };
  },

  async municipios() {
    return this.query('SELECT id, nombre, subregion FROM municipios ORDER BY nombre');
  },

  async upsertPerfil({ clerkUserId, nombre, apellidos, correo, rol = 'candidato' }) {
    return this.one(`
      INSERT INTO perfiles (clerk_user_id, nombre, apellidos, correo, rol)
      VALUES ($1, $2, $3, $4, $5)
      ON CONFLICT (clerk_user_id) DO UPDATE
        SET nombre = EXCLUDED.nombre,
            apellidos = EXCLUDED.apellidos,
            correo = EXCLUDED.correo,
            updated_at = NOW()
      RETURNING *
    `, [clerkUserId, nombre, apellidos, correo, rol]);
  },

  async perfilPorClerk(clerkUserId) {
    return this.one('SELECT * FROM perfiles WHERE clerk_user_id = $1', [clerkUserId]);
  }
};

export default DB;
