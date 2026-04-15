# 🟢 Plataforma Digital — Agencia de Empleo y Emprendimiento
### Comfenalco Antioquia

> Plataforma para gestión de candidatos, empresas, vacantes, intermediación laboral, pruebas psicotécnicas y diagnósticos.

---

## 🚀 Demo en vivo
**URL:** `https://<tu-usuario>.github.io/plataforma-comfenalco/`

---

## 🛠️ Stack tecnológico

| Capa | Tecnología | Costo | Por qué |
|------|-----------|-------|---------|
| Frontend | HTML5 + CSS3 + JS OOP | Gratis | Sin frameworks, fácil migrar |
| Base de datos | **Neon** (PostgreSQL) | **Gratis · Proyectos ilimitados** | PostgreSQL puro, no se pausa |
| Autenticación | **Clerk** | **Gratis hasta 10.000 usuarios** | Auth lista, roles incluidos |
| Archivos/Fotos | **Cloudinary** | **Gratis 25 GB** | Transformaciones de imagen |
| Hosting | GitHub Pages | Gratis | Deploy automático |

---

## 🏗️ Estructura del proyecto

```
plataforma-comfenalco/
├── index.html              ← Shell principal + Landing
├── config/
│   ├── db.js               ← Cliente Neon (PostgreSQL)
│   ├── auth.js             ← Cliente Clerk (autenticación)
│   └── storage.js          ← Cliente Cloudinary (archivos)
├── modules/                ← Un JS por módulo
├── pages/                  ← HTML de cada página
├── assets/
│   ├── img/
│   │   ├── logo_comfenalco.png
│   │   └── logo_spe.png
│   └── css/
└── sql/
    ├── 01_schema_neon.sql  ← Tablas (sin dependencia Supabase)
    ├── 03_seed_data.sql    ← Municipios + datos prueba
    └── 04_functions.sql    ← Funciones PostgreSQL
```

---

## ⚙️ Configuración paso a paso

### PASO 1 — Neon (base de datos)
1. Ve a **https://neon.tech** → Sign up con GitHub
2. **New Project** → nombre: `plataforma-comfenalco`
3. Dashboard → **Connection string** → copia la URL
4. Pégala en `config/db.js` → `NEON_URL`
5. SQL Editor → ejecuta `sql/01_schema_neon.sql`
6. SQL Editor → ejecuta `sql/03_seed_data.sql`
7. SQL Editor → ejecuta `sql/04_functions.sql`

### PASO 2 — Clerk (autenticación)
1. Ve a **https://clerk.com** → Sign up
2. **Create application** → nombre: `plataforma-comfenalco`
3. Activa: ✅ Email/Password ✅ Google (opcional)
4. Dashboard → **API Keys** → copia `Publishable key` (pk_test_...)
5. Pégala en `index.html` → `data-clerk-publishable-key`
6. También en `config/auth.js` → `CLERK_PUBLISHABLE_KEY`

### PASO 3 — Cloudinary (archivos)
1. Ve a **https://cloudinary.com** → Sign up
2. Dashboard → copia **Cloud name**
3. Settings → Upload → **Add upload preset**
   - Signing Mode: **Unsigned**
   - Nombre: `comfenalco_uploads`
4. Pega el Cloud name en `config/storage.js`

### PASO 4 — GitHub + GitHub Pages
```bash
git init
git add .
git commit -m "feat: plataforma base Neon + Clerk"
git remote add origin https://github.com/TU-USUARIO/plataforma-comfenalco.git
git push -u origin main
```
- Repositorio → **Settings** → **Pages** → Branch: main → / (root)

---

## 📦 Módulos y fases

| # | Módulo | Fase | Estado |
|---|--------|------|--------|
| 0 | Landing + buscador | 1 | ✅ Listo |
| 1 | Dashboard | 1 | 🔄 Siguiente |
| 2 | Candidatos / HV (6 pasos) | 1 | ⏳ Pendiente |
| 3 | Empresas | 1 | ⏳ Pendiente |
| 4 | Vacantes | 1 | ⏳ Pendiente |
| 5 | Intermediación | 1 | ⏳ Pendiente |
| 6 | Banco de HV | 1 | ⏳ Pendiente |
| 7 | Reportes | 1 | ⏳ Pendiente |
| 8 | Pruebas psicotécnicas | 2 | 🔮 Futuro |
| 9 | Diagnósticos | 2 | 🔮 Futuro |
| 10 | Fusión portal Comfenalco | 4 | 🔮 Futuro |

---

## 🌿 Ramas Git

```
main     ← Producción (GitHub Pages)
dev      ← Integración
  └── feat/dashboard
  └── feat/candidatos
  └── feat/empresas
```

## 📄 Licencia
Uso interno — Comfenalco Antioquia © 2025
