import { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { useAuth } from '../contexts/AuthContext';
import { newsService } from '../services/newsService';

export default function EditNews() {
  const { id } = useParams();
  const [formData, setFormData] = useState({
    title: '',
    content: '',
    image: null
  });
  const [imagePreview, setImagePreview] = useState(null);
  const [existingImage, setExistingImage] = useState(null);
  const [removeExistingImage, setRemoveExistingImage] = useState(false);
  const [loading, setLoading] = useState(false);
  const [fetching, setFetching] = useState(true);
  const [error, setError] = useState('');
  const [newsItem, setNewsItem] = useState(null);
  
  const { user, canEdit } = useAuth();
  const navigate = useNavigate();

  useEffect(() => {
    const fetchNewsDetail = async () => {
      try {
        const data = await newsService.getNewsById(id);
        setNewsItem(data);
        
        // Cek hak akses
        if (!canEdit(data.author_id)) {
          setError('Anda tidak memiliki izin untuk mengedit berita ini');
          return;
        }
        
        setFormData({
          title: data.title,
          content: data.content,
          image: null // File baru, tidak dari data
        });
        
        // Simpan URL gambar yang sudah ada
        if (data.image) {
          setExistingImage(`http://localhost:5000/uploads/images/${data.image}`);
        }
      } catch (err) {
        console.error('Error fetching news:', err);
        setError('Gagal memuat data berita');
      } finally {
        setFetching(false);
      }
    };
    
    fetchNewsDetail();
  }, [id, canEdit]);

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
      setRemoveExistingImage(false); // Reset hapus gambar
      setError(''); // Hapus error
    }
  };

  const removeImage = () => {
    setFormData(prev => ({
      ...prev,
      image: null
    }));
    setImagePreview(null);
  };

  const handleRemoveExistingImage = () => {
    setRemoveExistingImage(!removeExistingImage);
    if (!removeExistingImage) {
      // Jika ingin menghapus gambar yang ada
      setFormData(prev => ({
        ...prev,
        image: null
      }));
      setImagePreview(null);
    }
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    
    if (!newsItem || !canEdit(newsItem.author_id)) {
      setError('Akses ditolak untuk mengedit berita ini');
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
        image: formData.image,
        removeImage: removeExistingImage
      };
      
      await newsService.updateNews(id, newsData);
      navigate('/news');
    } catch (err) {
      console.error('Edit news error:', err);
      if (err.response?.status === 403) {
        setError('Anda tidak memiliki izin untuk mengedit berita ini');
      } else {
        setError(err.response?.data?.message || 'Gagal mengupdate berita.');
      }
    } finally {
      setLoading(false);
    }
  };

  if (fetching) {
    return (
      <div className="create-container">
        <div className="loading-spinner">Memuat data berita...</div>
      </div>
    );
  }

  if (error && !newsItem) {
    return (
      <div className="create-container">
        <div className="access-denied">
          <h2>⛔ Akses Ditolak</h2>
          <p>{error}</p>
          {newsItem && (
            <div className="news-info">
              <p>Berita ini dibuat oleh: <strong>{newsItem.author_name}</strong> (ID: {newsItem.author_id})</p>
              <p>Role Anda: <span className={`role-badge role-${user?.role}`}>{user?.role}</span></p>
            </div>
          )}
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
        <h2>✏️ Edit Berita</h2>
        <div className="user-info-form">
          <div>
            Anda login sebagai: <span className={`role-badge role-${user?.role}`}>{user?.role}</span>
          </div>
          <div className="news-meta-info">
            Berita ini dibuat oleh: <strong>{newsItem?.author_name}</strong>
          </div>
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
            value={formData.content}
            onChange={handleChange}
            required
            minLength="20"
          ></textarea>
        </div>

        <div className="form-group">
          <label htmlFor="image">Gambar Berita</label>
          
          {/* Tampilkan gambar yang sudah ada */}
          {existingImage && !removeExistingImage && (
            <div className="existing-image-container">
              <div className="existing-image-header">
                <span>Gambar saat ini:</span>
                <button 
                  type="button" 
                  onClick={handleRemoveExistingImage}
                  className="btn-remove-existing"
                >
                  ❌ Hapus Gambar
                </button>
              </div>
              <div className="existing-image">
                <img src={existingImage} alt="Current" />
              </div>
            </div>
          )}
          
          {/* Form upload gambar baru */}
          <div className="file-upload-container">
            <div className="file-upload-box">
              <input 
                type="file"
                id="image"
                name="image"
                accept="image/*"
                onChange={handleImageChange}
                className="file-input"
                disabled={removeExistingImage}
              />
              <label 
                htmlFor="image" 
                className={`file-upload-label ${removeExistingImage ? 'disabled' : ''}`}
              >
                <div className="upload-icon">📁</div>
                <div className="upload-text">
                  <p>Klik untuk upload gambar baru</p>
                  <small>Format: JPEG, PNG, GIF, WebP (max 5MB)</small>
                  {removeExistingImage && <small className="text-warning">Gambar akan dihapus</small>}
                </div>
              </label>
            </div>
            
            {imagePreview && (
              <div className="image-preview-container">
                <div className="image-preview-header">
                  <span>Preview Gambar Baru:</span>
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
          
          {/* Checkbox untuk menghapus gambar */}
          {existingImage && !imagePreview && (
            <div className="remove-image-checkbox">
              <label>
                <input 
                  type="checkbox"
                  checked={removeExistingImage}
                  onChange={handleRemoveExistingImage}
                />
                <span>Hapus gambar yang ada</span>
              </label>
            </div>
          )}
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
            {loading ? '⏳ Menyimpan...' : '💾 Simpan Perubahan'}
          </button>
        </div>
      </form>
    </div>
  );
}