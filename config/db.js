// ============================================================
// config/db.js
// Datos locales — la plataforma funciona sin conexión externa
// Cuando tengamos el backend listo, estos datos se reemplazan
// con llamadas reales a Neon via API
// ============================================================

const DATOS = {
  estadisticas: {
    total_candidatos: 0,
    total_empresas: 8,
    total_vacantes_activas: 10,
    total_postulaciones: 0,
    empleos_colocados: 0,
    tasa_colocacion: 0
  },

  municipios: [
    {id:1,  nombre:'Medellín',         subregion:'Valle de Aburrá'},
    {id:2,  nombre:'Bello',            subregion:'Valle de Aburrá'},
    {id:3,  nombre:'Itagüí',           subregion:'Valle de Aburrá'},
    {id:4,  nombre:'Envigado',         subregion:'Valle de Aburrá'},
    {id:5,  nombre:'Sabaneta',         subregion:'Valle de Aburrá'},
    {id:6,  nombre:'La Estrella',      subregion:'Valle de Aburrá'},
    {id:7,  nombre:'Copacabana',       subregion:'Valle de Aburrá'},
    {id:8,  nombre:'Girardota',        subregion:'Valle de Aburrá'},
    {id:9,  nombre:'Caldas',           subregion:'Valle de Aburrá'},
    {id:10, nombre:'Barbosa',          subregion:'Valle de Aburrá'},
    {id:11, nombre:'Rionegro',         subregion:'Oriente'},
    {id:12, nombre:'El Carmen de Viboral', subregion:'Oriente'},
    {id:13, nombre:'La Ceja',          subregion:'Oriente'},
    {id:14, nombre:'Marinilla',        subregion:'Oriente'},
    {id:15, nombre:'Guarne',           subregion:'Oriente'},
    {id:21, nombre:'Santa Rosa de Osos',subregion:'Norte'},
    {id:22, nombre:'Yarumal',          subregion:'Norte'},
    {id:31, nombre:'Santa Fe de Antioquia',subregion:'Occidente'},
    {id:41, nombre:'Andes',            subregion:'Suroeste'},
    {id:42, nombre:'Jericó',           subregion:'Suroeste'},
    {id:51, nombre:'Caucasia',         subregion:'Bajo Cauca'},
    {id:61, nombre:'Segovia',          subregion:'Nordeste'},
    {id:71, nombre:'Apartadó',         subregion:'Urabá'},
    {id:72, nombre:'Turbo',            subregion:'Urabá'},
  ],

  vacantes: [
    {id:'1', cargo:'Auxiliar de Bodega',       empresa:'Logística del Valle SAS',   municipio:'Medellín',  salario_min:1300000, salario_max:1500000, tipo_contrato:'termino_fijo',       jornada:'completa',   estado:'activa', total_postulados:12, es_incluyente:false},
    {id:'2', cargo:'Desarrollador Web Jr.',    empresa:'TechCo Colombia',            municipio:'Envigado',  salario_min:2500000, salario_max:3500000, tipo_contrato:'termino_indefinido',  jornada:'completa',   estado:'activa', total_postulados:5,  es_incluyente:false},
    {id:'3', cargo:'Operario de Producción',   empresa:'Manufacturas Bello SA',      municipio:'Bello',     salario_min:1160000, salario_max:1400000, tipo_contrato:'termino_fijo',        jornada:'completa',   estado:'activa', total_postulados:28, es_incluyente:false},
    {id:'4', cargo:'Asesor Comercial',         empresa:'Seguros Andinos Ltda',       municipio:'Itagüí',    salario_min:1800000, salario_max:2500000, tipo_contrato:'termino_indefinido',  jornada:'completa',   estado:'activa', total_postulados:9,  es_incluyente:false},
    {id:'5', cargo:'Técnico de Refrigeración', empresa:'Fríos del Oriente SAS',      municipio:'Rionegro',  salario_min:1800000, salario_max:2200000, tipo_contrato:'termino_fijo',        jornada:'completa',   estado:'activa', total_postulados:3,  es_incluyente:false},
    {id:'6', cargo:'Auxiliar Contable',        empresa:'Contadores Asociados Ltda',  municipio:'Medellín',  salario_min:1400000, salario_max:1700000, tipo_contrato:'termino_fijo',        jornada:'completa',   estado:'activa', total_postulados:17, es_incluyente:false},
    {id:'7', cargo:'Inspector de Calidad',     empresa:'Agrícola Urabá SA',          municipio:'Apartadó',  salario_min:1500000, salario_max:1800000, tipo_contrato:'obra_labor',          jornada:'completa',   estado:'activa', total_postulados:6,  es_incluyente:false},
    {id:'8', cargo:'Auxiliar de Enfermería',   empresa:'Hospital Regional Norte',    municipio:'Santa Rosa de Osos', salario_min:1400000, salario_max:1700000, tipo_contrato:'termino_fijo', jornada:'completa', estado:'activa', total_postulados:14, es_incluyente:true},
    {id:'9', cargo:'Analista de Datos',        empresa:'TechCo Colombia',            municipio:'Envigado',  salario_min:3000000, salario_max:4500000, tipo_contrato:'termino_indefinido',  jornada:'teletrabajo',estado:'activa', total_postulados:8,  es_incluyente:false},
    {id:'10',cargo:'Conductor C2',             empresa:'Logística del Valle SAS',    municipio:'Medellín',  salario_min:1500000, salario_max:1800000, tipo_contrato:'obra_labor',          jornada:'completa',   estado:'activa', total_postulados:21, es_incluyente:false},
  ],

  empresas: [
    {id:'1', nombre:'Logística del Valle SAS',   nit:'900.123.456-1', sector:'Logística y transporte',   estado:'verificada'},
    {id:'2', nombre:'TechCo Colombia',            nit:'900.234.567-2', sector:'Tecnología e informática', estado:'activa'},
    {id:'3', nombre:'Manufacturas Bello SA',      nit:'811.345.678-3', sector:'Manufactura e industria',  estado:'activa'},
    {id:'4', nombre:'Seguros Andinos Ltda',       nit:'890.456.789-4', sector:'Servicios financieros',    estado:'activa'},
    {id:'5', nombre:'Fríos del Oriente SAS',      nit:'900.567.890-5', sector:'Refrigeración y HVAC',     estado:'activa'},
    {id:'6', nombre:'Contadores Asociados Ltda',  nit:'890.678.901-6', sector:'Contabilidad y auditoría', estado:'activa'},
    {id:'7', nombre:'Agrícola Urabá SA',          nit:'900.789.012-7', sector:'Agroindustria',            estado:'activa'},
    {id:'8', nombre:'Hospital Regional Norte',    nit:'800.890.123-8', sector:'Salud y bienestar',        estado:'verificada'},
  ]
};

export const DB = {

  async estadisticas() {
    return { data: DATOS.estadisticas, error: null };
  },

  async municipios() {
    return { data: DATOS.municipios, error: null };
  },

  async vacantesRecientes(limite = 6) {
    return { data: DATOS.vacantes.slice(0, limite), error: null };
  },

  async buscarVacantes({ texto = null, municipioId = null, limite = 10, offset = 0 } = {}) {
    let lista = [...DATOS.vacantes];
    if (texto) {
      const t = texto.toLowerCase();
      lista = lista.filter(v =>
        v.cargo.toLowerCase().includes(t) ||
        v.empresa.toLowerCase().includes(t)
      );
    }
    if (municipioId) {
      const m = DATOS.municipios.find(x => x.id === parseInt(municipioId));
      if (m) lista = lista.filter(v => v.municipio === m.nombre);
    }
    return { data: lista.slice(offset, offset + limite), error: null };
  },

  async buscarCandidatos({ limite = 20, offset = 0 } = {}) {
    return { data: [], error: null };
  },

  async hvCompleta(candidatoId) {
    return { data: null, error: null };
  },

  async upsertPerfil({ clerkUserId, nombre, apellidos, correo, rol = 'candidato' }) {
    return { data: { clerk_user_id: clerkUserId, nombre, apellidos, correo, rol }, error: null };
  },

  async perfilPorClerk(clerkUserId) {
    return { data: null, error: null };
  },

  async query(sql, params = []) {
    // Para consultas directas usamos los datos locales según la tabla
    if (sql.includes('empresas')) {
      return { data: DATOS.empresas, error: null };
    }
    if (sql.includes('fn_buscar_vacantes')) {
      return this.vacantesRecientes(50);
    }
    return { data: [], error: null };
  },

  async one(sql, params = []) {
    const { data, error } = await this.query(sql, params);
    return { data: Array.isArray(data) ? data[0] ?? null : data, error };
  }
};

export default DB;
