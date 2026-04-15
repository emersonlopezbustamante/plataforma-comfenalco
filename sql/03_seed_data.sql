-- ============================================================
-- PLATAFORMA DIGITAL — Comfenalco Antioquia
-- Archivo: 03_seed_data.sql
-- Datos iniciales: municipios de Antioquia + datos de prueba
-- ============================================================

-- ============================================================
-- MUNICIPIOS DE ANTIOQUIA (125 municipios + subregiones)
-- ============================================================
INSERT INTO municipios (nombre, subregion, cod_dane) VALUES
-- Valle de Aburrá
('Medellín',         'Valle de Aburrá', '05001'),
('Bello',            'Valle de Aburrá', '05088'),
('Itagüí',           'Valle de Aburrá', '05360'),
('Envigado',         'Valle de Aburrá', '05266'),
('Sabaneta',         'Valle de Aburrá', '05631'),
('La Estrella',      'Valle de Aburrá', '05380'),
('Copacabana',       'Valle de Aburrá', '05212'),
('Girardota',        'Valle de Aburrá', '05308'),
('Caldas',           'Valle de Aburrá', '05129'),
('Barbosa',          'Valle de Aburrá', '05079'),

-- Oriente
('Rionegro',         'Oriente',         '05615'),
('El Carmen de Viboral', 'Oriente',     '05148'),
('La Ceja',          'Oriente',         '05376'),
('Marinilla',        'Oriente',         '05440'),
('El Retiro',        'Oriente',         '05607'),
('El Santuario',     'Oriente',         '05649'),
('Guarne',           'Oriente',         '05318'),
('San Vicente Ferrer','Oriente',        '05674'),
('Sonsón',           'Oriente',         '05756'),
('Abejorral',        'Oriente',         '05002'),

-- Norte
('Santa Rosa de Osos','Norte',          '05660'),
('Yarumal',          'Norte',           '05887'),
('Donmatías',        'Norte',           '05237'),
('Entrerríos',       'Norte',           '05264'),
('San Pedro de los Milagros','Norte',   '05664'),
('Angostura',        'Norte',           '05040'),
('Campamento',       'Norte',           '05134'),
('Carolina del Príncipe','Norte',       '05150'),
('Gómez Plata',      'Norte',           '05310'),
('Guadalupe',        'Norte',           '05313'),

-- Occidente
('Santa Fe de Antioquia','Occidente',   '05042'),
('Sopetrán',         'Occidente',       '05761'),
('Olaya',            'Occidente',       '05501'),
('San Jerónimo',     'Occidente',       '05628'),
('Ebéjico',          'Occidente',       '05250'),
('Liborina',         'Occidente',       '05390'),
('Anzá',             'Occidente',       '05044'),
('Buriticá',         'Occidente',       '05120'),
('Caicedo',          'Occidente',       '05125'),
('Cañasgordas',      'Occidente',       '05138'),

-- Suroeste
('Andes',            'Suroeste',        '05034'),
('Jericó',           'Suroeste',        '05364'),
('Fredonia',         'Suroeste',        '05282'),
('Salgar',           'Suroeste',        '05642'),
('Jardín',           'Suroeste',        '05361'),
('Ciudad Bolívar',   'Suroeste',        '05101'),
('Bolombolo',        'Suroeste',        '05004'),
('Caramanta',        'Suroeste',        '05145'),
('La Pintada',       'Suroeste',        '05400'),
('Támesis',          'Suroeste',        '05789'),

-- Bajo Cauca
('Caucasia',         'Bajo Cauca',      '05154'),
('El Bagre',         'Bajo Cauca',      '05250'),
('Nechí',            'Bajo Cauca',      '05495'),
('Tarazá',           'Bajo Cauca',      '05790'),
('Zaragoza',         'Bajo Cauca',      '05895'),
('Cáceres',          'Bajo Cauca',      '05120'),

-- Nordeste
('Segovia',          'Nordeste',        '05736'),
('Remedios',         'Nordeste',        '05604'),
('Yalí',             'Nordeste',        '05890'),
('Yolombó',          'Nordeste',        '05893'),
('Anorí',            'Nordeste',        '05038'),
('Amalfi',           'Nordeste',        '05030'),
('Cisneros',         'Nordeste',        '05197'),
('San Roque',        'Nordeste',        '05652'),
('Santo Domingo',    'Nordeste',        '05656'),
('Vegachí',          'Nordeste',        '05858'),

-- Magdalena Medio
('Puerto Berrío',    'Magdalena Medio', '05579'),
('Puerto Nare',      'Magdalena Medio', '05585'),
('Puerto Triunfo',   'Magdalena Medio', '05591'),
('Yondó',            'Magdalena Medio', '05893'),
('Caracolí',         'Magdalena Medio', '05142'),
('Maceo',            'Magdalena Medio', '05425'),

-- Urabá
('Apartadó',         'Urabá',           '05045'),
('Turbo',            'Urabá',           '05837'),
('Carepa',           'Urabá',           '05147'),
('Chigorodó',        'Urabá',           '05172'),
('Mutatá',           'Urabá',           '05480'),
('Necoclí',          'Urabá',           '05490'),
('San Juan de Urabá','Urabá',           '05659'),
('San Pedro de Urabá','Urabá',          '05665'),
('Arboletes',        'Urabá',           '05051'),
('Vigía del Fuerte', 'Urabá',           '05042');

-- ============================================================
-- DATOS DE PRUEBA (solo entorno de desarrollo)
-- Comentar o eliminar en producción
-- ============================================================

-- Nota: Los usuarios se crean desde Supabase Auth o el formulario de registro.
-- Aquí insertamos datos de prueba directamente en las tablas (sin auth).

-- Empresas de prueba
INSERT INTO empresas (nombre, nit, sector, municipio_id, correo_contacto, correo_seleccion, nombre_contacto, estado)
VALUES
  ('Logística del Valle SAS',    '900.123.456-1', 'Logística y transporte',  1, 'info@logvalle.com',   'seleccion@logvalle.com',   'María Orozco',    'verificada'),
  ('TechCo Colombia',            '900.234.567-2', 'Tecnología e informática',4, 'rrhh@techco.co',      'ofertas@techco.co',         'Jorge Salazar',   'activa'),
  ('Manufacturas Bello SA',      '811.345.678-3', 'Manufactura e industria', 2, 'talento@mfgbello.com','empleo@mfgbello.com',       'Claudia Reyes',   'activa'),
  ('Seguros Andinos Ltda',       '890.456.789-4', 'Servicios financieros',   3, 'rh@segurosandinos.co','vacantes@segurosandinos.co','Pedro Montoya',   'activa'),
  ('Fríos del Oriente SAS',      '900.567.890-5', 'Refrigeración y HVAC',    11,'operaciones@frios.co','empleos@frios.co',          'Luisa Fernández', 'activa'),
  ('Contadores Asociados Ltda',  '890.678.901-6', 'Contabilidad y auditoría',1, 'admin@contadores.co', 'hv@contadores.co',          'Andrés Gómez',    'activa'),
  ('Agrícola Urabá SA',          '900.789.012-7', 'Agroindustria',           71,'contacto@agurab.com', 'empleos@agurab.com',        'Carlos Arango',   'activa'),
  ('Hospital Regional Norte',    '800.890.123-8', 'Salud y bienestar',       21,'rrhh@hospitaln.co',  'vacantes@hospitaln.co',     'Ana Bermúdez',    'verificada');

-- Vacantes de prueba
INSERT INTO vacantes (empresa_id, cargo, descripcion, municipio_id, salario_min, salario_max, tipo_contrato, jornada, experiencia_min, nivel_educativo_min, estado, fecha_cierre)
SELECT
  e.id,
  v.cargo,
  v.descripcion,
  v.municipio_id,
  v.salario_min,
  v.salario_max,
  v.tipo_contrato::tipo_contrato,
  v.jornada::jornada,
  v.experiencia_min,
  v.nivel_min::nivel_educativo,
  'activa'::estado_vacante,
  CURRENT_DATE + INTERVAL '30 days'
FROM (VALUES
  ('Logística del Valle SAS',   'Auxiliar de Bodega',        'Apoyo en recepción y despacho de mercancía',      1,  1300000, 1500000, 'termino_fijo',      'completa',    6,  'secundaria'),
  ('TechCo Colombia',           'Desarrollador Web Jr.',     'Desarrollo de aplicaciones con React y Node.js', 4,  2500000, 3500000, 'termino_indefinido','completa',    12, 'tecnologo'),
  ('Manufacturas Bello SA',     'Operario de Producción',    'Manejo de maquinaria en línea de producción',     2,  1160000, 1400000, 'termino_fijo',      'completa',    0,  'secundaria'),
  ('Seguros Andinos Ltda',      'Asesor Comercial',          'Venta de seguros con portafolio asignado',        3,  1800000, 2500000, 'termino_indefinido','completa',    6,  'tecnico'),
  ('Fríos del Oriente SAS',     'Técnico de Refrigeración',  'Mantenimiento de equipos de frío industrial',     11, 1800000, 2200000, 'termino_fijo',      'completa',    12, 'tecnico'),
  ('Contadores Asociados Ltda', 'Auxiliar Contable',         'Registro y conciliación de cuentas',              1,  1400000, 1700000, 'termino_fijo',      'completa',    6,  'tecnologo'),
  ('Agrícola Urabá SA',         'Inspector de Calidad',      'Control de calidad en proceso agroindustrial',    71, 1500000, 1800000, 'obra_labor',        'completa',    12, 'tecnico'),
  ('Hospital Regional Norte',   'Auxiliar de Enfermería',    'Apoyo en atención al paciente hospitalizado',     21, 1400000, 1700000, 'termino_fijo',      'completa',    6,  'tecnico'),
  ('TechCo Colombia',           'Analista de Datos',         'Análisis con Python y Power BI',                 4,  3000000, 4500000, 'termino_indefinido','teletrabajo', 24, 'profesional'),
  ('Logística del Valle SAS',   'Conductor C2',              'Transporte urbano de mercancía',                  1,  1500000, 1800000, 'obra_labor',        'completa',    12, 'secundaria')
) AS v(empresa_nombre, cargo, descripcion, municipio_id, salario_min, salario_max, tipo_contrato, jornada, experiencia_min, nivel_min)
JOIN empresas e ON e.nombre = v.empresa_nombre;
