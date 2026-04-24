/**
 * ================================================================
 * API SUPABASE — Agencia de Empleo y Emprendimiento
 * Comfenalco Antioquia
 * ================================================================
 * Incluir en todos los HTML antes del script principal:
 *   <script src="api.js"></script>
 *
 * Uso:
 *   const { data } = await API.candidatos.listar({ municipio: 'Medellín' });
 *   await API.vacantes.guardar({ titulo: 'Auxiliar bodega', ... });
 * ================================================================
 */

const SUPA_URL = "https://mhiwvjermmmicuxwdghn.supabase.co";
const SUPA_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1oaXd2amVybW1taWN1eHdkZ2huIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzYwMTQ3MzUsImV4cCI6MjA5MTU5MDczNX0.nIrq4t-GQPMbpsS8KSaPI5J6NDNLmuQnk5van8dlg78";

const API = (function() {

  const HEADERS = {
    'Content-Type':  'application/json',
    'apikey':        SUPA_KEY,
    'Authorization': 'Bearer ' + SUPA_KEY,
    'Prefer':        'return=representation'
  };

  // ── REST helpers ───────────────────────────────────────────────
  async function supa(method, tabla, body, qs) {
    const url = new URL(SUPA_URL + '/rest/v1/' + tabla);
    if (qs) Object.entries(qs).forEach(([k,v]) => v !== undefined && v !== '' && url.searchParams.set(k, v));
    const opts = { method, headers: { ...HEADERS } };
    if (body) opts.body = JSON.stringify(body);
    const res = await fetch(url.toString(), opts);
    if (!res.ok) {
      const e = await res.json().catch(() => ({}));
      throw new Error(e.message || e.error || 'Error Supabase ' + res.status);
    }
    const text = await res.text();
    return text ? JSON.parse(text) : [];
  }

  // GET con filtros PostgREST
  function GET(tabla, filtros, select, order, limit) {
    const qs = { select: select || '*' };
    if (order) qs.order = order;
    if (limit) qs.limit = limit;
    // Filtros: { municipio: 'Medellín' } → municipio=eq.Medellín
    if (filtros) {
      Object.entries(filtros).forEach(([k, v]) => {
        if (v !== undefined && v !== '') qs[k] = 'eq.' + v;
      });
    }
    return supa('GET', tabla, null, qs);
  }

  // GET con búsqueda de texto (ilike)
  function SEARCH(tabla, campo, texto, extrafiltros, select) {
    const qs = { select: select || '*' };
    if (texto) qs[campo] = 'ilike.*' + texto + '*';
    if (extrafiltros) {
      Object.entries(extrafiltros).forEach(([k,v]) => {
        if (v !== undefined && v !== '') qs[k] = 'eq.' + v;
      });
    }
    qs.order = 'fecha_creacion.desc';
    qs.limit = 500;
    return supa('GET', tabla, null, qs);
  }

  // INSERT
  function POST(tabla, body) {
    return supa('POST', tabla, body);
  }

  // UPSERT (insert or update)
  function UPSERT(tabla, body, onConflict) {
    const url = new URL(SUPA_URL + '/rest/v1/' + tabla);
    if (onConflict) url.searchParams.set('on_conflict', onConflict);
    return fetch(url.toString(), {
      method: 'POST',
      headers: { ...HEADERS, 'Prefer': 'resolution=merge-duplicates,return=representation' },
      body: JSON.stringify(body)
    }).then(async r => {
      if (!r.ok) { const e = await r.json().catch(()=>({})); throw new Error(e.message||'Error upsert'); }
      return r.json();
    });
  }

  // PATCH
  function PATCH(tabla, filtros, body) {
    const qs = {};
    if (filtros) Object.entries(filtros).forEach(([k,v]) => { qs[k] = 'eq.' + v; });
    return supa('PATCH', tabla, body, qs);
  }

  // DELETE
  function DELETE(tabla, filtros) {
    const qs = {};
    if (filtros) Object.entries(filtros).forEach(([k,v]) => { qs[k] = 'eq.' + v; });
    return supa('DELETE', tabla, null, qs);
  }

  // Cargue masivo en lotes de 200
  async function BULK(tabla, rows, onConflict) {
    const LOTE = 200;
    let insertados = 0, errores = 0;
    for (let i = 0; i < rows.length; i += LOTE) {
      const lote = rows.slice(i, i + LOTE);
      try {
        await UPSERT(tabla, lote, onConflict);
        insertados += lote.length;
      } catch(e) {
        // Si falla el lote, intentar uno a uno
        for (const row of lote) {
          try { await UPSERT(tabla, row, onConflict); insertados++; }
          catch(e2) { errores++; console.warn('Fila error:', row, e2.message); }
        }
      }
    }
    return { insertados, errores, total: rows.length };
  }

  // ── STATS (via múltiples SELECTs) ─────────────────────────────
  async function getStats() {
    const [cands, emps, vacs, posts, diags, cursosList, parts] = await Promise.all([
      supa('GET', 'candidatos',    null, { select: 'id', activo: 'eq.true',  limit: 1, 'count': 'exact' }),
      supa('GET', 'empresas',      null, { select: 'id', activo: 'eq.true',  limit: 1 }),
      supa('GET', 'vacantes',      null, { select: 'id,sector,municipio', estado: 'eq.Activa', limit: 500 }),
      supa('GET', 'postulaciones', null, { select: 'estado', limit: 1000 }),
      supa('GET', 'diagnosticos_empresariales', null, { select: 'id', limit: 1 }),
      supa('GET', 'cursos',        null, { select: 'id', limit: 1 }),
      supa('GET', 'participantes_cap', null, { select: 'estado', limit: 1000 })
    ]);

    const colocados = posts.filter(p => p.estado === 'colocado').length;
    const remitidos = posts.filter(p => p.estado === 'remitido').length;

    // Agrupar vacantes por sector y municipio
    const porSector = {}, porMuni = {};
    vacs.forEach(v => {
      if (v.sector) porSector[v.sector] = (porSector[v.sector]||0) + 1;
      if (v.municipio) porMuni[v.municipio] = (porMuni[v.municipio]||0) + 1;
    });

    return {
      candidatos:    Array.isArray(cands) ? cands.length : 0,
      empresas:      Array.isArray(emps)  ? emps.length  : 0,
      vacantes:      vacs.length,
      colocados,
      remitidos,
      diagnosticos:  Array.isArray(diags) ? diags.length : 0,
      cursos:        Array.isArray(cursosList) ? cursosList.length : 0,
      cap_terminados:parts.filter(p => p.estado === 'terminado').length,
      vacantes_sector: Object.entries(porSector)
        .map(([s,n]) => ({s,n})).sort((a,b)=>b.n-a.n).slice(0,7),
      colocados_region: Object.entries(porMuni)
        .map(([r,n]) => ({r,n})).sort((a,b)=>b.n-a.n).slice(0,9)
    };
  }

  // ── INTERFAZ PÚBLICA ──────────────────────────────────────────
  return {

    candidatos: {
      listar:  (f)   => SEARCH('candidatos', 'nombres', f && f.q, f && {municipio:f.municipio, nivel_estudio:f.nivel}),
      obtener: (doc) => GET('candidatos', {documento: doc}),
      guardar: (d)   => UPSERT('candidatos', d, 'documento'),
      bulk:    (rows)=> BULK('candidatos', rows, 'documento'),
      eliminar:(doc) => PATCH('candidatos', {documento:doc}, {activo:false}),
    },

    empresas: {
      listar:    (f)      => SEARCH('empresas','razon_social', f&&f.q, f&&{ciudad:f.ciudad,afiliada:f.afiliada}),
      obtener:   (nit)    => GET('empresas', {nit}),
      guardar:   (d)      => UPSERT('empresas', d, 'nit'),
      bulk:      (rows)   => BULK('empresas', rows, 'nit'),
      actualizar:(nit, d) => PATCH('empresas', {nit}, d),
    },

    vacantes: {
      listar:    (f)      => SEARCH('vacantes','titulo', f&&f.q, f&&{sector:f.sector,estado:f.estado,municipio:f.municipio}),
      obtener:   (id)     => GET('vacantes', {id}),
      guardar:   (d)      => POST('vacantes', d),
      actualizar:(id, d)  => PATCH('vacantes', {id}, d),
      cerrar:    (id)     => PATCH('vacantes', {id}, {estado:'Cancelada'}),
    },

    postulaciones: {
      listar:    (f)      => GET('postulaciones', f, '*, candidatos(nombres,apellidos,municipio), vacantes(titulo,empresa_nombre)', 'fecha_postulacion.desc', 500),
      guardar:   (d)      => UPSERT('postulaciones', d, 'candidato_doc,vacante_id'),
      actualizar:(id, d)  => PATCH('postulaciones', {id}, {...d, fecha_actualizacion: new Date().toISOString()}),
    },

    diagnosticos: {
      listar:         (empresa) => empresa
        ? supa('GET','diagnosticos_empresariales',null,{nombre_empresa:'eq.'+empresa,'order':'fecha.desc'})
        : supa('GET','diagnosticos_empresariales',null,{'order':'fecha.desc','limit':'500'}),
      listarEmpresas: ()  => supa('GET','diagnosticos_empresariales',null,{select:'nombre_empresa','order':'nombre_empresa.asc'}),
      guardar:        (d) => POST('diagnosticos_empresariales', d),
      eliminar:       (id)=> DELETE('diagnosticos_empresariales', {id}),
      eliminarEmpresa:(nombre)=> DELETE('diagnosticos_empresariales', {nombre_empresa: nombre}),
    },

    cursos: {
      listar:    ()       => supa('GET','cursos',null,{'order':'fecha_creacion.desc'}),
      guardar:   (d)      => POST('cursos', d),
      actualizar:(id, d)  => PATCH('cursos', {id}, d),
    },

    participantes: {
      listar:    (f)      => GET('participantes_cap', f, '*, cursos(nombre,costo)', 'fecha_prereg.desc', 1000),
      guardar:   (d)      => UPSERT('participantes_cap', d, 'curso_id,documento'),
      actualizar:(id, d)  => PATCH('participantes_cap', {id}, d),
    },

    orientaciones: {
      listar:  (f) => GET('orientaciones', f, '*', 'fecha.desc', 500),
      guardar: (d) => POST('orientaciones', d),
      actualizar:(id,d) => PATCH('orientaciones',{id},d),
    },

    pruebas: {
      listar:  (doc) => GET('pruebas_lab', {candidato_doc:doc}, '*', 'fecha.desc'),
      guardar: (d)   => POST('pruebas_lab', d),
    },

    eventos: {
      listar:  (f) => SEARCH('eventos','nombre', f&&f.q, f&&{municipio:f.municipio,estado:f.estado}),
      guardar: (d) => POST('eventos', d),
      actualizar:(id,d) => PATCH('eventos',{id},d),
    },

    stats: getStats,

    // Verificar conexión
    health: () => supa('GET','candidatos',null,{select:'id',limit:'1'})
      .then(()=>({ok:true, url:SUPA_URL}))
  };

})();

// Verificar conexión al cargar
if (typeof window !== 'undefined') {
  API.health()
    .then(() => console.log('%c✅ Supabase conectado — Agencia Comfenalco', 'color:#094a4b;font-weight:bold'))
    .catch(e  => console.warn('%c⚠️ Supabase no disponible:', 'color:#e67e22;font-weight:bold', e.message));
}
