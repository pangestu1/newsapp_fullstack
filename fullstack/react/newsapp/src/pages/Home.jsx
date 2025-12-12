import { useEffect, useState } from 'react';
import { Link } from 'react-router-dom';
import { useAuth } from '../contexts/AuthContext';
import { newsService } from '../services/newsService';

export default function Home() {
  const [stats, setStats] = useState({
    totalNews: 0,
    latestNews: [],
    loading: true
  });
  const { user } = useAuth();

  useEffect(() => {
    fetchStats();
  }, []);

  const fetchStats = async () => {
    try {
      const news = await newsService.getAllNews();
      setStats({
        totalNews: news.length,
        latestNews: news.slice(0, 3), // Ambil 3 berita terbaru
        loading: false
      });
    } catch (error) {
      console.error('Error fetching stats:', error);
      setStats(prev => ({ ...prev, loading: false }));
    }
  };

  const getGreeting = () => {
    const hour = new Date().getHours();
    if (hour < 12) return 'Selamat Pagi';
    if (hour < 15) return 'Selamat Siang';
    if (hour < 18) return 'Selamat Sore';
    return 'Selamat Malam';
  };

  return (
    <div className="home-container">
      {/* Hero Section */}
      <section className="hero-section">
        <div className="hero-content">
          <h1 className="hero-title">
            {getGreeting()}, {user ? user.name : 'Pengunjung'}! 👋
          </h1>
          <p className="hero-subtitle">
            Selamat datang di <span className="highlight">News App</span> - Portal berita terkini dan terpercaya
          </p>
          <p className="hero-description">
            Temukan berita terbaru, eksplorasi informasi menarik, dan jadilah bagian dari komunitas pembaca kami.
          </p>
          
          <div className="hero-actions">
            <Link to="/news" className="btn-hero-primary">
              📰 Jelajahi Berita
            </Link>
            {!user && (
              <Link to="/register" className="btn-hero-secondary">
                📝 Bergabung Sekarang
              </Link>
            )}
          </div>
        </div>
        
        <div className="hero-image">
          <div className="floating-card">
            <div className="card-icon">📰</div>
            <h3>{stats.totalNews}+</h3>
            <p>Berita Tersedia</p>
          </div>
          <div className="floating-card">
            <div className="card-icon">👥</div>
            <h3>100+</h3>
            <p>Pembaca Aktif</p>
          </div>
          <div className="floating-card">
            <div className="card-icon">✍️</div>
            <h3>20+</h3>
            <p>Penulis Terdaftar</p>
          </div>
        </div>
      </section>

      {/* Features Section */}
      <section className="features-section">
        <h2 className="section-title">✨ Kenapa Memilih News App?</h2>
        <p className="section-subtitle">Platform berita modern dengan berbagai fitur unggulan</p>
        
        <div className="features-grid">
          <div className="feature-card">
            <div className="feature-icon">🚀</div>
            <h3>Berita Terkini</h3>
            <p>Dapatkan update berita terbaru dari berbagai kategori dengan kecepatan real-time</p>
          </div>
          
          <div className="feature-card">
            <div className="feature-icon">🔒</div>
            <h3>Akses Aman</h3>
            <p>Sistem keamanan terenkripsi untuk melindungi data dan privasi Anda</p>
          </div>
          
          <div className="feature-card">
            <div className="feature-icon">📱</div>
            <h3>Responsif</h3>
            <p>Akses dari berbagai perangkat dengan tampilan yang optimal di semua ukuran layar</p>
          </div>
          
          <div className="feature-card">
            <div className="feature-icon">👥</div>
            <h3>Komunitas Aktif</h3>
            <p>Bergabung dengan ribuan pembaca dan penulis dalam diskusi menarik</p>
          </div>
        </div>
      </section>

      {/* Latest News Preview */}
      {stats.latestNews.length > 0 && (
        <section className="news-preview-section">
          <div className="section-header">
            <h2 className="section-title">📢 Berita Terbaru</h2>
            <Link to="/news" className="view-all-link">
              Lihat Semua →
            </Link>
          </div>
          
          <div className="news-preview-grid">
            {stats.latestNews.map(news => (
              <Link to={`/news/${news.id}`} key={news.id} className="news-preview-card">
                <div className="news-preview-image">
                  {news.image ? (
                    <img 
                      src={`http://localhost:5000/uploads/images/${news.image}`} 
                      alt={news.title}
                      onError={(e) => {
                        e.target.style.display = 'none';
                        e.target.parentElement.innerHTML = '<div class="news-placeholder">📰</div>';
                      }}
                    />
                  ) : (
                    <div className="news-placeholder">📰</div>
                  )}
                </div>
                <div className="news-preview-content">
                  <h3>{news.title}</h3>
                  <p className="news-excerpt">
                    {news.content.length > 100 
                      ? `${news.content.substring(0, 100)}...` 
                      : news.content}
                  </p>
                  <div className="news-meta">
                    <span className="author">👤 {news.author_name}</span>
                    <span className="date">
                      📅 {new Date(news.created_at).toLocaleDateString('id-ID')}
                    </span>
                  </div>
                </div>
              </Link>
            ))}
          </div>
        </section>
      )}

      {/* Call to Action */}
      <section className="cta-section">
        <div className="cta-content">
          <h2>🚀 Siap Mulai Membaca?</h2>
          <p>Bergabunglah dengan komunitas pembaca kami dan dapatkan akses ke berita terkini setiap hari</p>
          
          <div className="cta-actions">
            {user ? (
              <Link to="/news" className="btn-cta-primary">
                📚 Lanjutkan Membaca
              </Link>
            ) : (
              <>
                <Link to="/register" className="btn-cta-primary">
                  📝 Daftar Gratis
                </Link>
                <Link to="/login" className="btn-cta-secondary">
                  🔐 Masuk Sekarang
                </Link>
              </>
            )}
          </div>
        </div>
      </section>

      {/* Role Information */}
      <section className="role-section">
        <h2 className="section-title">👥 Pilih Peran Anda</h2>
        <p className="section-subtitle">Bergabung dengan peran yang sesuai dengan kebutuhan Anda</p>
        
        <div className="role-cards">
          <div className="role-card">
            <div className="role-icon">👤</div>
            <h3>Pembaca</h3>
            <p>Nikmati berita tanpa batas</p>
            <ul>
              <li>✓ Akses semua berita</li>
              <li>✓ Beri komentar</li>
              <li>✓ Simpan favorit</li>
              <li>✗ Tidak bisa menulis</li>
            </ul>
            <Link to="/register?role=pembaca" className="btn-role">
              Daftar sebagai Pembaca
            </Link>
          </div>
          
          <div className="role-card featured">
            <div className="role-badge">🔥 Populer</div>
            <div className="role-icon">✍️</div>
            <h3>Penulis</h3>
            <p>Bagikan cerita Anda</p>
            <ul>
              <li>✓ Buat berita</li>
              <li>✓ Edit berita sendiri</li>
              <li>✓ Kelola konten</li>
              <li>✓ Dapatkan pembaca</li>
            </ul>
            <Link to="/register?role=penulis" className="btn-role">
              Daftar sebagai Penulis
            </Link>
          </div>
          
          <div className="role-card">
            <div className="role-icon">👑</div>
            <h3>Admin</h3>
            <p>Kelola seluruh sistem</p>
            <ul>
              <li>✓ Kelola semua berita</li>
              <li>✓ Kelola pengguna</li>
              <li>✓ Pantau aktivitas</li>
              <li>✓ Full kontrol</li>
            </ul>
            <span className="btn-role disabled">
              Hanya oleh undangan
            </span>
          </div>
        </div>
      </section>
    </div>
  );
}