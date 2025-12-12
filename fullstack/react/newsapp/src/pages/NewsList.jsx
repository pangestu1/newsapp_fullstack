import { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import { useAuth } from '../contexts/AuthContext';
import { newsService } from '../services/newsService';

export default function NewsList() {
  const [news, setNews] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [success, setSuccess] = useState('');
  
  const { user, canEdit, canDelete, isAdmin } = useAuth();

  useEffect(() => {
    fetchNews();
  }, []);

  const fetchNews = async () => {
    try {
      setLoading(true);
      setError('');
      const data = await newsService.getAllNews();
      setNews(data);
    } catch (err) {
      console.error('Error fetching news:', err);
      setError('Gagal memuat berita. Silakan coba lagi.');
      setNews([]);
    } finally {
      setLoading(false);
    }
  };

  // Fungsi untuk mendapatkan URL gambar lengkap
  const getImageUrl = (imagePath) => {
    if (!imagePath || imagePath === 'null' || imagePath === 'undefined') {
      return null;
    }
    
    if (imagePath.startsWith('http')) {
      return imagePath;
    }
    
    return `http://localhost:5000/uploads/images/${imagePath}`;
  };

  const handleDelete = async (id, authorId) => {
    if (!window.confirm('Apakah Anda yakin ingin menghapus berita ini?')) return;
    
    if (!canDelete(authorId)) {
      setError('Anda tidak memiliki izin untuk menghapus berita ini');
      return;
    }

    try {
      await newsService.deleteNews(id);
      setSuccess('Berita berhasil dihapus');
      fetchNews();
      setTimeout(() => setSuccess(''), 3000);
    } catch (err) {
      console.error('Error deleting news:', err);
      if (err.response?.status === 403) {
        setError('Anda tidak memiliki izin untuk menghapus berita ini');
      } else {
        setError('Gagal menghapus berita');
      }
    }
  };

  const formatDate = (dateString) => {
    const date = new Date(dateString);
    return date.toLocaleDateString('id-ID', {
      day: 'numeric',
      month: 'long',
      year: 'numeric'
    });
  };

  // Handle delete all news (admin only)
  const handleDeleteAll = async () => {
    if (!window.confirm('APAKAH ANDA YAKIN INGIN MENGHAPUS SEMUA BERITA?\nTindakan ini tidak dapat dibatalkan!')) return;
    
    if (!isAdmin()) {
      setError('Hanya admin yang dapat menghapus semua berita');
      return;
    }

    try {
      setLoading(true);
      const deletePromises = news.map(item => 
        newsService.deleteNews(item.id).catch(e => {
          console.error(`Gagal menghapus berita ${item.id}:`, e);
          return null;
        })
      );
      
      await Promise.all(deletePromises);
      setSuccess('Semua berita berhasil dihapus');
      fetchNews();
      setTimeout(() => setSuccess(''), 3000);
    } catch (err) {
      console.error('Error deleting all news:', err);
      setError('Gagal menghapus semua berita');
    } finally {
      setLoading(false);
    }
  };

  if (loading) {
    return (
      <div className="news-container">
        <div className="loading-spinner">Memuat berita...</div>
      </div>
    );
  }

  return (
    <div className="news-container">
      <div className="page-header">
        <h2>📰 Daftar Berita</h2>
        {isAdmin() && news.length > 0 && (
          <button 
            className="btn-delete-all"
            onClick={handleDeleteAll}
            title="Hapus semua berita"
            disabled={loading}
          >
            {loading ? '⏳ Menghapus...' : '🗑️ Hapus Semua'}
          </button>
        )}
      </div>
      
      {success && <div className="success-message">{success}</div>}
      {error && <div className="error-message">{error}</div>}
      
      {news.length === 0 ? (
        <div className="no-news">
          <p>Tidak ada berita tersedia.</p>
          {user && (user.role === 'admin' || user.role === 'penulis') && (
            <Link to="/create" className="btn-create-first">
              ✏️ Buat Berita Pertama
            </Link>
          )}
          {!user && (
            <div className="guest-message">
              <p><Link to="/login">Login</Link> untuk membuat berita baru</p>
            </div>
          )}
        </div>
      ) : (
        <div className="news-list">
          {news.map((item) => {
            const canEditThis = canEdit(item.author_id);
            const canDeleteThis = canDelete(item.author_id);
            const imageUrl = getImageUrl(item.image);
            
            return (
              <div key={item.id} className="news-card">
                {/* Gambar berita */}
                {imageUrl ? (
                  <Link to={`/news/${item.id}`} className="news-image-link">
                    <div className="news-image-container">
                      <img 
                        src={imageUrl} 
                        alt={item.title} 
                        className="news-image"
                        onError={(e) => {
                          e.target.style.display = 'none';
                          e.target.parentElement.innerHTML = `
                            <div class="image-placeholder">
                              <span>📷</span>
                              <p>Gambar tidak tersedia</p>
                            </div>
                          `;
                        }}
                      />
                    </div>
                  </Link>
                ) : (
                  <Link to={`/news/${item.id}`} className="news-image-link">
                    <div className="image-placeholder">
                      <span>📰</span>
                      <p>Tidak ada gambar</p>
                    </div>
                  </Link>
                )}
                
                <div className="news-card-content">
                  <div className="news-card-header">
                    <h3>
                      <Link to={`/news/${item.id}`} className="news-title-link">
                        {item.title}
                      </Link>
                    </h3>
                    <div className="news-meta-small">
                      <span className="author">👤 {item.author_name}</span>
                      <span className="date">📅 {formatDate(item.created_at)}</span>
                    </div>
                  </div>
                  
                  <p className="news-excerpt">
                    {item.content.length > 120 
                      ? `${item.content.substring(0, 120)}...` 
                      : item.content}
                  </p>
                  
                  <div className="news-actions">
                    <Link to={`/news/${item.id}`} className="btn-detail">
                      Baca Selengkapnya →
                    </Link>
                    {canEditThis && (
                      <Link to={`/edit/${item.id}`} className="btn-edit">
                        ✏️ Edit
                      </Link>
                    )}
                    {canDeleteThis && (
                      <button 
                        className="btn-delete" 
                        onClick={() => handleDelete(item.id, item.author_id)}
                        title={isAdmin() ? 'Hapus berita (admin)' : 'Hapus berita milik sendiri'}
                      >
                        🗑️ Hapus
                      </button>
                    )}
                  </div>
                </div>
              </div>
            );
          })}
        </div>
      )}
    </div>
  );
}