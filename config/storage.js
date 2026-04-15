// ============================================================
// config/storage.js
// Archivos con Cloudinary (fotos HV, certificados PDF)
//
// INSTRUCCIONES:
// 1. Ve a https://cloudinary.com → Sign up (gratis)
// 2. Dashboard → copia "Cloud name"
// 3. Settings → Upload → Upload presets →
//    Add upload preset → Signing Mode: Unsigned
//    Nombre del preset: comfenalco_uploads
//    Folder: comfenalco
//    → Save
// 4. Pega el Cloud name en CLOUDINARY_CLOUD_NAME abajo
// ============================================================

export const CLOUDINARY_CLOUD_NAME  = 'TU_CLOUD_NAME';
export const CLOUDINARY_UPLOAD_PRESET = 'comfenalco_uploads';

const BASE_URL = `https://api.cloudinary.com/v1_1/${CLOUDINARY_CLOUD_NAME}`;

export const Storage = {

  // Subir foto de perfil del candidato
  async subirFoto(archivo) {
    return this._subir(archivo, 'image', 'fotos_candidatos');
  },

  // Subir certificado (PDF o imagen)
  async subirCertificado(archivo) {
    return this._subir(archivo, 'auto', 'certificados');
  },

  // Subir logo de empresa
  async subirLogo(archivo) {
    return this._subir(archivo, 'image', 'logos_empresas');
  },

  // ── Interno ──────────────────────────────────────────────
  async _subir(archivo, resourceType = 'auto', carpeta = 'comfenalco') {
    const formData = new FormData();
    formData.append('file',           archivo);
    formData.append('upload_preset',  CLOUDINARY_UPLOAD_PRESET);
    formData.append('folder',         carpeta);

    try {
      const res  = await fetch(`${BASE_URL}/${resourceType}/upload`, {
        method: 'POST',
        body:   formData
      });
      const data = await res.json();
      if (data.error) throw new Error(data.error.message);
      return {
        url:       data.secure_url,
        publicId:  data.public_id,
        formato:   data.format,
        bytes:     data.bytes,
        error:     null
      };
    } catch (err) {
      return { url: null, error: err.message };
    }
  },

  // Generar URL con transformación (ej: thumbnail 200x200)
  thumbnail(publicId, w = 200, h = 200) {
    return `https://res.cloudinary.com/${CLOUDINARY_CLOUD_NAME}/image/upload/w_${w},h_${h},c_fill,g_face/${publicId}`;
  }
};

export default Storage;
