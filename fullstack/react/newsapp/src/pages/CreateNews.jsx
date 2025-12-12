import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { useAuth } from '../contexts/AuthContext';
import { newsService } from '../services/newsService';

export default function CreateNews() {
  const [formData, setFormData] = useState({
    title: '',
    content: '',
    image: null
  });
  const [imagePreview, setImagePreview] = useState(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  
  const { user, canCreate } = useAuth();
  const navigate = useNavigate();

  // Cek apakah user boleh membuat berita
  useEffect(() => {
    if (!canCreate()) {
      setError('Anda tidak memiliki izin untuk membuat berita');
      setTimeout(() => navigate('/news'), 3000);
    }
  }, [canCreate, navigate]);

  const handleChange = (e) => {
    const { name, value } = e.target;
    setFormData(prev => ({
      ...prev,
      [name]: value
    }));
  };

  const handleImageChange = (e) => {
    const file = e.target.files[0];
    if (file) {
      // Validasi file
      const validTypes = ['image/jpeg', 'image/png', 'image/gif', 'image/webp'];
      const maxSize = 5 * 1024 * 1024; // 5MB
      
      if (!validTypes.includes(file.type)) {
        setError('File harus berupa gambar (JPEG, PNG, GIF, WebP)');
        return;
      }
      
      if (file.size > maxSize) {
        setError('Ukuran file maksimal 5MB');
        return;
      }
      
      setFormData(prev => ({
        ...prev,
        image: file
      }));
      
      // Buat preview
      const reader = new FileReader();
      reader.onloadend = () => {
        setImagePreview(reader.result);
      };
      reader.readAsDataURL(file);
      setError(''); // Hapus error jika ada
    }
  };

  const removeImage = () => {
    setFormData(prev => ({
      ...prev,
      image: null
    }));
    setImagePreview(null);
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    
    if (!canCreate()) {
      setError('Akses ditolak: Hanya admin dan penulis yang dapat membuat berita');
      return;
    }
    
    if (!formData.title.trim() || !formData.content.trim()) {
      setError('Judul dan isi berita harus diisi');
      return;
    }
    
    setError('');
    setLoading(true);

    try {
      const newsData = {
        title: formData.title,
        content: formData.content,
        image: formData.image
      };
      
      await newsService.createNews(newsData);
      navigate('/news');
    } catch (err) {
      console.error('Create news error:', err);
      setError(err.response?.data?.message || 'Gagal membuat berita.');
    } finally {
      setLoading(false);
    }
  };

  if (!canCreate()) {
    return (
      <div className="create-container">
        <div className="access-denied">
          <h2>⛔ Akses Ditolak</h2>
          <p>Hanya <strong>Admin</strong> dan <strong>Penulis</strong> yang dapat membuat berita.</p>
          <p>Role Anda: <span className={`role-badge role-${user?.role}`}>{user?.role}</span></p>
          <button onClick={() => navigate('/news')} className="btn-back">
            Kembali ke Daftar Berita
          </button>
        </div>
      </div>
    );
  }

  return (
    <div className="create-container">
      <div className="form-header">
        <h2>✏️ Tambah Berita Baru</h2>
        <div className="user-info-form">
          Anda login sebagai: <span className={`role-badge role-${user?.role}`}>{user?.role}</span>
        </div>
      </div>
      
      {error && <div className="error-message">{error}</div>}
      
      <form className="form-box" onSubmit={handleSubmit}>
        <div className="form-group">
          <label htmlFor="title">Judul Berita *</label>
          <input 
            id="title"
            type="text" 
            name="title"
            placeholder="Masukkan judul berita..." 
            value={formData.title}
            onChange={handleChange}
            required
            minLength="5"
          />
        </div>

        <div className="form-group">
          <label htmlFor="content">Isi Berita *</label>
          <textarea 
            id="content"
            name="content"
            rows="8" 
            placeholder="Tulis isi berita di sini..."
            value={formData.content}
            onChange={handleChange}
            required
            minLength="20"
          ></textarea>
        </div>

        <div className="form-group">
          <label htmlFor="image">Gambar Berita (Opsional)</label>
          <div className="file-upload-container">
            <div className="file-upload-box">
              <input 
                type="file"
                id="image"
                name="image"
                accept="image/*"
                onChange={handleImageChange}
                className="file-input"
              />
              <label htmlFor="image" className="file-upload-label">
                <div className="upload-icon">📁</div>
                <div className="upload-text">
                  <p>Klik untuk upload gambar</p>
                  <small>Format: JPEG, PNG, GIF, WebP (max 5MB)</small>
                </div>
              </label>
            </div>
            
            {imagePreview && (
              <div className="image-preview-container">
                <div className="image-preview-header">
                  <span>Preview Gambar:</span>
                  <button 
                    type="button" 
                    onClick={removeImage}
                    className="btn-remove-image"
                  >
                    ❌ Hapus
                  </button>
                </div>
                <div className="image-preview">
                  <img src={imagePreview} alt="Preview" />
                </div>
              </div>
            )}
          </div>
        </div>

        <div className="form-note">
          <small>* Wajib diisi</small>
        </div>

        <div className="form-actions">
          <button 
            type="button" 
            className="btn-cancel"
            onClick={() => navigate('/news')}
          >
            ❌ Batal
          </button>
          <button type="submit" disabled={loading}>
            {loading ? '⏳ Menyimpan...' : '💾 Simpan Berita'}
          </button>
        </div>
      </form>
    </div>
  );
}