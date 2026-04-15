// ============================================================
// config/auth.js
// Autenticación con Clerk
//
// INSTRUCCIONES:
// 1. Ve a https://clerk.com → Sign up (gratis con GitHub)
// 2. Create application → nombre: plataforma-comfenalco
// 3. Activa los métodos de login que quieras:
//    ✅ Email + Password (recomendado para candidatos)
//    ✅ Google (opcional, muy cómodo)
// 4. Dashboard → API Keys → copia "Publishable key"
//    Empieza con: pk_test_...
// 5. Pégala en CLERK_PUBLISHABLE_KEY abajo
// ============================================================

export const CLERK_PUBLISHABLE_KEY = 'pk_test_TU_CLAVE_AQUI';

// ── Inicializar Clerk ────────────────────────────────────────
// En index.html ya cargamos el SDK de Clerk via CDN (ver abajo)
// Aquí solo exportamos helpers para usar en los módulos

export const Auth = {

  // Obtener el usuario actual (null si no está logueado)
  usuario() {
    return window.Clerk?.user ?? null;
  },

  // Verificar si hay sesión activa
  estaLogueado() {
    return !!window.Clerk?.user;
  },

  // Obtener el rol del usuario (guardado en publicMetadata)
  rol() {
    return window.Clerk?.user?.publicMetadata?.rol ?? 'candidato';
  },

  // Verificar si tiene uno de los roles dados
  tieneRol(...roles) {
    return roles.includes(this.rol());
  },

  // Abrir modal de login
  login() {
    window.Clerk?.openSignIn({
      afterSignInUrl: window.location.href,
      afterSignUpUrl: window.location.href
    });
  },

  // Abrir modal de registro
  registro() {
    window.Clerk?.openSignUp({
      afterSignUpUrl: window.location.href
    });
  },

  // Cerrar sesión
  async cerrarSesion() {
    await window.Clerk?.signOut();
    window.location.reload();
  },

  // Escuchar cambios de sesión
  onCambio(callback) {
    // Clerk dispara este evento al inicializar y al cambiar sesión
    window.addEventListener('clerk:loaded', () => callback(this.usuario()));
    // También cuando cambia
    if (window.Clerk) {
      window.Clerk.addListener(({ user }) => callback(user));
    }
  },

  // Obtener token JWT para enviar a Neon (si usas Row-Level Security por token)
  async token() {
    return await window.Clerk?.session?.getToken() ?? null;
  },

  // Datos básicos del usuario para mostrar en el topbar
  datosTopbar() {
    const u = this.usuario();
    if (!u) return { nombre: 'Invitado', rol: '', iniciales: '?' };
    const nombre    = `${u.firstName ?? ''} ${u.lastName ?? ''}`.trim() || u.emailAddresses?.[0]?.emailAddress;
    const iniciales = (u.firstName?.[0] ?? '') + (u.lastName?.[0] ?? '') || nombre[0].toUpperCase();
    return {
      nombre,
      rol:      this.rol(),
      iniciales: iniciales.toUpperCase(),
      foto:     u.imageUrl
    };
  }
};

// ── Roles disponibles en el sistema ─────────────────────────
export const ROLES = {
  CANDIDATO:          'candidato',
  ASESOR_EMPRESARIAL: 'asesor_empresarial',
  INTERMEDIADOR:      'intermediador',
  EMPRESA:            'empresa',
  ADMINISTRADOR:      'administrador'
};

export default Auth;
