#!/bin/bash
# ============================================================
# SETUP INICIAL — Plataforma Comfenalco
# Ejecutar UNA SOLA VEZ en tu máquina local
# ============================================================

echo "🟢 Configurando repositorio Plataforma Comfenalco..."

# 1. Inicializar git
git init
git add .
git commit -m "feat: estructura base del proyecto y schema SQL"

# 2. Crear ramas de trabajo
git checkout -b dev
git checkout -b feat/dashboard
git checkout dev

echo ""
echo "✅ Listo. Ahora:"
echo ""
echo "  1. Crea el repo en GitHub: https://github.com/new"
echo "     Nombre sugerido: plataforma-comfenalco"
echo "     Visibilidad: Private (recomendado)"
echo ""
echo "  2. Conecta el repo local con GitHub:"
echo "     git remote add origin https://github.com/TU-USUARIO/plataforma-comfenalco.git"
echo "     git push -u origin main"
echo "     git push origin dev"
echo ""
echo "  3. Activa GitHub Pages:"
echo "     Repositorio → Settings → Pages"
echo "     Source: Deploy from a branch → main → / (root)"
echo ""
echo "  4. Configura Supabase:"
echo "     a. Ve a https://supabase.com → New project"
echo "     b. Nombre: plataforma-comfenalco"
echo "     c. Región: South America (São Paulo)"
echo "     d. SQL Editor → ejecuta en orden:"
echo "        sql/01_schema.sql"
echo "        sql/02_rls_policies.sql"
echo "        sql/03_seed_data.sql"
echo "        sql/04_functions.sql"
echo "     e. Copia URL + anon key en config/supabase.js"
echo ""
echo "  5. Crea los buckets en Supabase Storage:"
echo "     Storage → New bucket → 'candidatos' (público)"
echo ""
echo "🚀 ¡A construir los módulos!"
