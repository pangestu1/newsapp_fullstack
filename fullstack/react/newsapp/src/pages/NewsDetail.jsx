import { useState, useEffect } from 'react';
import { useParams, useNavigate, Link } from 'react-router-dom';
import { newsService } from '../services/newsService';
import { commentService } from '../services/commentService'; // Import baru
import { useAuth } from '../contexts/AuthContext';

export default function NewsDetail() {
  const { id } = useParams();
  const navigate = useNavigate();
  const [news, setNews] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [relatedNews, setRelatedNews] = useState([]);
  
  // State untuk komentar
  const [comments, setComments] = useState([]);
  const [newComment, setNewComment] = useState('');
  const [commentLoading, setCommentLoading] = useState(false);
  const [commentError, setCommentError] = useState('');
  const [commentCount, setCommentCount] = useState(0);
  
  const { user, canEdit, canDelete, isAdmin } = useAuth();

  useEffect(() => {
    fetchNewsDetail();
    fetchRelatedNews();
    fetchComments();
  }, [id]);

  const fetchNewsDetail = async () => {
    try {
      setLoading(true);
      const data = await newsService.getNewsById(id);
      setNews(data);
      setError('');
    } catch (err) {
      console.error('Error fetching news detail:', err);
      setError('Gagal memuat detail berita. Berita tidak ditemukan.');
    } finally {
      setLoading(false);
    }
  };

  const fetchComments = async () => {
    try {
      const commentsData = await commentService.getCommentsByNewsId(id);
      setComments(commentsData);
      setCommentCount(commentsData.length);
    } catch (err) {
      console.error('Error fetching comments:', err);
      setComments([]);
    }
  };

  const fetchRelatedNews = async () => {
    try {
      const data = await newsService.getAllNews();
      const filtered = data.filter(item => item.id !== parseInt(id)).slice(0, 3);
      setRelatedNews(filtered);
    } catch (err) {
      console.error('Error fetching related news:', err);
    }
  };

  // Fungsi untuk menambah komentar baru
  const handleAddComment = async (e) => {
    e.preventDefault();
    
    if (!user) {
      setCommentError('Silakan login untuk menambahkan komentar');
      return;
    }
    
    if (!newComment.trim()) {
      setCommentError('Komentar tidak boleh kosong');
      return;
    }
    
    setCommentLoading(true);
    setCommentError('');
    
    try {
      const commentData = {
        news_id: parseInt(id),
        content: newComment,
        user_id: user.id,
        user_name: user.name,
        user_role: user.role
      };
      
      await commentService.createComment(commentData);
      setNewComment('');
      fetchComments(); // Refresh komentar
    } catch (err) {
      console.error('Error adding comment:', err);
      setCommentError('Gagal menambahkan komentar');
    } finally {
      setCommentLoading(false);
    }
  };

  // Fungsi untuk menghapus komentar
  const handleDeleteComment = async (commentId, commentUserId) => {
    // Cek apakah user boleh menghapus
    if (!user || (!isAdmin() && user.id !== commentUserId)) {
      setCommentError('Anda tidak memiliki izin untuk menghapus komentar ini');
      return;
    }
    
    if (!window.confirm('Apakah Anda yakin ingin menghapus komentar ini?')) {
      return;
    }
    
    try {
      await commentService.deleteComment(commentId);
      fetchComments(); // Refresh komentar
    } catch (err) {
      console.error('Error deleting comment:', err);
      setCommentError('Gagal menghapus komentar');
    }
  };

  const getImageUrl = (imagePath) => {
    if (!imagePath) return null;
    if (imagePath.startsWith('http')) return imagePath;
    return `http://localhost:5000/uploads/images/${imagePath}`;
  };

  const formatDate = (dateString) => {
    const date = new Date(dateString);
    return date.toLocaleDateString('id-ID', {
      weekday: 'long',
      year: 'numeric',
      month: 'long',
      day: 'numeric',
      hour: '2-digit',
      minute: '2-digit'
    });
  };

  if (loading) {
    return (
      <div className="news-detail-container">
        <div className="loading-spinner">Memuat detail berita...</div>
      </div>
    );
  }

  if (error && !news) {
    return (
      <div className="news-detail-container">
        <div className="error-message">{error}</div>
        <button onClick={() => navigate('/news')} className="btn-back">
          ← Kembali ke Daftar Berita
        </button>
      </div>
    );
  }

  const imageUrl = getImageUrl(news?.image);
  const canEditThis = canEdit(news?.author_id);
  const canDeleteThis = canDelete(news?.author_id);

  return (
    <div className="news-detail-container">
      <button onClick={() => navigate('/news')} className="btn-back-detail">
        ← Kembali ke Daftar Berita
      </button>
      
      {error && <div className="error-message">{error}</div>}
      
      <article className="news-detail">
        {/* Header - tambahkan jumlah komentar */}
        <header className="news-detail-header">
          <div className="news-category">
            <span className="category-badge">📰 Berita</span>
            {news?.category && (
              <span className="category-badge">🏷️ {news.category}</span>
            )}
            <span className="category-badge">💬 {commentCount} Komentar</span>
          </div>
          
          <h1 className="news-detail-title">{news?.title}</h1>
          
          <div className="news-detail-meta">
            <div className="author-info">
              <div className="author-avatar">
                {news?.author_name?.charAt(0) || 'A'}
              </div>
              <div className="author-details">
                <span className="author-name">{news?.author_name || 'Tidak diketahui'}</span>
                <span className="publish-date">{formatDate(news?.created_at)}</span>
              </div>
            </div>
            
            <div className="news-actions-top">
              {canEditThis && (
                <Link to={`/edit/${id}`} className="btn-edit-detail">
                  ✏️ Edit Berita
                </Link>
              )}
              {canDeleteThis && (
                <button 
                  className="btn-delete-detail" 
                  onClick={() => {
                    if (window.confirm('Hapus berita ini?')) {
                      newsService.deleteNews(id)
                        .then(() => navigate('/news'))
                        .catch(err => setError('Gagal menghapus berita'));
                    }
                  }}
                >
                  🗑️ Hapus Berita
                </button>
              )}
            </div>
          </div>
        </header>
        
        {/* Gambar utama */}
        {imageUrl && (
          <div className="news-detail-image-container">
            <img 
              src={imageUrl} 
              alt={news?.title} 
              className="news-detail-image"
              onError={(e) => {
                e.target.style.display = 'none';
              }}
            />
            <div className="image-caption">
              Ilustrasi berita: {news?.title}
            </div>
          </div>
        )}
        
        {/* Konten berita */}
        <div className="news-detail-content">
          <div className="news-full-content">
            {news?.content.split('\n').map((paragraph, index) => (
              <p key={index} className="news-paragraph">
                {paragraph}
              </p>
            ))}
          </div>
        </div>
        
        {/* SECTION KOMENTAR */}
        <section className="comments-section">
          <div className="comments-header">
            <h3>💬 Diskusi ({commentCount})</h3>
            <p>Bagikan pendapat Anda tentang berita ini</p>
          </div>
          
          {/* Form tambah komentar */}
          {user ? (
            <form className="comment-form" onSubmit={handleAddComment}>
              <div className="comment-form-header">
                <div className="user-comment-info">
                  <div className="user-avatar-small">
                    {user.name?.charAt(0) || 'U'}
                  </div>
                  <div>
                    <strong>{user.name}</strong>
                    <small className="user-role-small">({user.role})</small>
                  </div>
                </div>
              </div>
              
              <textarea
                className="comment-input"
                placeholder="Tulis komentar Anda di sini..."
                value={newComment}
                onChange={(e) => setNewComment(e.target.value)}
                rows="4"
                required
                disabled={commentLoading}
              />
              
              {commentError && <div className="error-message-small">{commentError}</div>}
              
              <div className="comment-form-actions">
                <button 
                  type="submit" 
                  className="btn-submit-comment"
                  disabled={commentLoading}
                >
                  {commentLoading ? 'Mengirim...' : 'Kirim Komentar'}
                </button>
              </div>
            </form>
          ) : (
            <div className="comment-login-prompt">
              <p>📝 <Link to="/login">Login</Link> untuk menambahkan komentar</p>
            </div>
          )}
          
          {/* Daftar komentar */}
          <div className="comments-list">
            {comments.length === 0 ? (
              <div className="no-comments">
                <p>📭 Belum ada komentar. Jadilah yang pertama berkomentar!</p>
              </div>
            ) : (
              comments.map(comment => (
                <div key={comment.id} className="comment-item">
                  <div className="comment-header">
                    <div className="comment-author">
                      <div className="comment-avatar">
                        {comment.user_name?.charAt(0) || 'U'}
                      </div>
                      <div className="comment-author-info">
                        <div className="comment-author-name">
                          <strong>{comment.user_name}</strong>
                          <span className={`comment-author-role role-${comment.user_role}`}>
                            {comment.user_role}
                          </span>
                        </div>
                        <span className="comment-date">
                          {formatDate(comment.created_at)}
                        </span>
                      </div>
                    </div>
                    
                    {/* Tombol hapus komentar (hanya untuk admin atau pemilik komentar) */}
                    {(isAdmin() || (user && user.id === comment.user_id)) && (
                      <button
                        className="btn-delete-comment"
                        onClick={() => handleDeleteComment(comment.id, comment.user_id)}
                        title="Hapus komentar"
                      >
                        🗑️
                      </button>
                    )}
                  </div>
                  
                  <div className="comment-content">
                    {comment.content}
                  </div>
                  
                  {/* Reply form (opsional untuk masa depan) */}
                  {/* <button className="btn-reply">Balas</button> */}
                </div>
              ))
            )}
          </div>
        </section>
        
        {/* Info tambahan */}
        <div className="news-additional-info">
          <div className="info-box">
            <h4>📊 Informasi Berita</h4>
            <ul className="info-list">
              <li>
                <strong>ID Berita:</strong> #{news?.id}
              </li>
              <li>
                <strong>Penulis:</strong> {news?.author_name}
              </li>
              <li>
                <strong>ID Penulis:</strong> {news?.author_id}
              </li>
              <li>
                <strong>Dibuat:</strong> {formatDate(news?.created_at)}
              </li>
              <li>
                <strong>Diperbarui:</strong> {formatDate(news?.updated_at)}
              </li>
              <li>
                <strong>Status:</strong> <span className="status-published">✅ Dipublikasikan</span>
              </li>
              <li>
                <strong>Jumlah Komentar:</strong> {commentCount}
              </li>
            </ul>
          </div>
        </div>
        
        {/* Footer berita */}
        <footer className="news-detail-footer">
          <div className="tags-container">
            <h4>🏷️ Tag:</h4>
            <div className="tags-list">
              <span className="tag">Berita Terkini</span>
              <span className="tag">Informasi</span>
              <span className="tag">{news?.author_name}</span>
              <span className="tag">{commentCount} Komentar</span>
            </div>
          </div>
          
          <div className="share-container">
            <h4>🔗 Bagikan:</h4>
            <div className="share-buttons">
              <button className="btn-share facebook">f</button>
              <button className="btn-share twitter">t</button>
              <button className="btn-share whatsapp">w</button>
              <button className="btn-share copy" onClick={() => {
                navigator.clipboard.writeText(window.location.href);
                alert('Link berita disalin!');
              }}>
                📋
              </button>
            </div>
          </div>
        </footer>
      </article>
      
      {/* Berita terkait */}
      {relatedNews.length > 0 && (
        <section className="related-news-section">
          <h3>📰 Berita Terkait</h3>
          <div className="related-news-list">
            {relatedNews.map(item => {
              const relatedImageUrl = getImageUrl(item.image);
              return (
                <div key={item.id} className="related-news-card">
                  {relatedImageUrl && (
                    <Link to={`/news/${item.id}`}>
                      <img 
                        src={relatedImageUrl} 
                        alt={item.title} 
                        className="related-news-image"
                      />
                    </Link>
                  )}
                  <div className="related-news-content">
                    <h4>
                      <Link to={`/news/${item.id}`} className="related-news-title">
                        {item.title}
                      </Link>
                    </h4>
                    <p className="related-news-excerpt">
                      {item.content.substring(0, 100)}...
                    </p>
                    <div className="related-news-meta">
                      <span className="related-news-author">{item.author_name}</span>
                      <span className="related-news-date">
                        {new Date(item.created_at).toLocaleDateString('id-ID')}
                      </span>
                    </div>
                  </div>
                </div>
              );
            })}
          </div>
        </section>
      )}
      
      {/* Navigasi */}
      <div className="news-navigation">
        <button onClick={() => navigate('/news')} className="btn-navigation">
          ← Lihat Semua Berita
        </button>
        {canEditThis && (
          <Link to={`/edit/${id}`} className="btn-navigation">
            ✏️ Edit Berita Ini →
          </Link>
        )}
      </div>
    </div>
  );
}