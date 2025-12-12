import { useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { useAuth } from '../contexts/AuthContext';

export default function Register() {
  const [formData, setFormData] = useState({
    name: '',
    email: '',
    password: '',
    confirmPassword: '',
    role: 'pembaca' // Default role
  });
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);
  const [termsAccepted, setTermsAccepted] = useState(false);
  
  const { register } = useAuth();
  const navigate = useNavigate();

  const handleChange = (e) => {
    setFormData({
      ...formData,
      [e.target.name]: e.target.value
    });
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    
    // Validasi
    if (!termsAccepted) {
      return setError('Anda harus menyetujui syarat dan ketentuan');
    }
    
    if (formData.password !== formData.confirmPassword) {
      return setError('Password tidak cocok');
    }
    
    if (formData.password.length < 6) {
      return setError('Password minimal 6 karakter');
    }
    
    setError('');
    setLoading(true);

    const result = await register({
      name: formData.name,
      email: formData.email,
      password: formData.password,
      role: formData.role
    });
    
    if (result.success) {
      alert(`Registrasi berhasil sebagai ${formData.role === 'penulis' ? 'Penulis' : 'Pembaca'}! Silakan login.`);
      navigate('/login');
    } else {
      setError(result.message);
    }
    setLoading(false);
  };

  return (
    <div className="register-container">
      <div className="register-box">
        <div className="register-header">
          <h2>📝 Daftar Akun Baru</h2>
          <p>Bergabung dengan komunitas pembaca dan penulis</p>
        </div>
        
        {error && <div className="error-message">{error}</div>}
        
        <form onSubmit={handleSubmit}>
          <div className="form-group">
            <label htmlFor="name">Nama Lengkap *</label>
            <input 
              type="text" 
              id="name"
              name="name"
              placeholder="Masukkan nama lengkap..." 
              value={formData.name}
              onChange={handleChange}
              required
              minLength="3"
            />
          </div>
          
          <div className="form-group">
            <label htmlFor="email">Email *</label>
            <input 
              type="email" 
              id="email"
              name="email"
              placeholder="contoh@email.com" 
              value={formData.email}
              onChange={handleChange}
              required
            />
          </div>
          
          <div className="form-group">
            <label htmlFor="password">Password *</label>
            <input 
              type="password" 
              id="password"
              name="password"
              placeholder="Minimal 6 karakter" 
              value={formData.password}
              onChange={handleChange}
              required
              minLength="6"
            />
          </div>
          
          <div className="form-group">
            <label htmlFor="confirmPassword">Konfirmasi Password *</label>
            <input 
              type="password" 
              id="confirmPassword"
              name="confirmPassword"
              placeholder="Ulangi password" 
              value={formData.confirmPassword}
              onChange={handleChange}
              required
            />
          </div>
          
          {/* Pilihan Role */}
          <div className="form-group">
            <label htmlFor="role">Daftar Sebagai *</label>
            <div className="role-selection">
              <div className={`role-option ${formData.role === 'pembaca' ? 'selected' : ''}`}>
                <label>
                  <input 
                    type="radio"
                    name="role"
                    value="pembaca"
                    checked={formData.role === 'pembaca'}
                    onChange={handleChange}
                  />
                  <div className="role-card">
                    <div className="role-icon">👤</div>
                    <div className="role-info">
                      <h4>Pembaca</h4>
                      <p>Hanya dapat membaca dan mengomentari berita</p>
                      <ul className="role-features">
                        <li>✓ Baca semua berita</li>
                        <li>✓ Beri komentar</li>
                        <li>✗ Tidak bisa membuat berita</li>
                        <li>✗ Tidak bisa mengedit/hapus</li>
                      </ul>
                    </div>
                  </div>
                </label>
              </div>
              
              <div className={`role-option ${formData.role === 'penulis' ? 'selected' : ''}`}>
                <label>
                  <input 
                    type="radio"
                    name="role"
                    value="penulis"
                    checked={formData.role === 'penulis'}
                    onChange={handleChange}
                  />
                  <div className="role-card">
                    <div className="role-icon">✍️</div>
                    <div className="role-info">
                      <h4>Penulis</h4>
                      <p>Dapat membuat dan mengelola berita sendiri</p>
                      <ul className="role-features">
                        <li>✓ Baca semua berita</li>
                        <li>✓ Buat berita baru</li>
                        <li>✓ Edit berita sendiri</li>
                        <li>✓ Hapus berita sendiri</li>
                      </ul>
                    </div>
                  </div>
                </label>
              </div>
            </div>
          </div>
          
          {/* Terms and Conditions */}
          <div className="form-group terms-group">
            <label className="terms-label">
              <input 
                type="checkbox"
                checked={termsAccepted}
                onChange={(e) => setTermsAccepted(e.target.checked)}
                className="terms-checkbox"
              />
              <span className="terms-text">
                Saya menyetujui <Link to="/terms" className="terms-link">Syarat & Ketentuan</Link> dan 
                <Link to="/privacy" className="terms-link"> Kebijakan Privasi</Link>
              </span>
            </label>
          </div>
          
          <button type="submit" disabled={loading} className="btn-register-submit">
            {loading ? '⏳ Mendaftarkan...' : '📝 Daftar Sekarang'}
          </button>
        </form>
        
        <div className="register-footer">
          <p>
            Sudah punya akun? <Link to="/login" className="login-link">Login di sini</Link>
          </p>
          <p className="note">
            <small>* Admin tidak dapat didaftarkan melalui form ini</small>
          </p>
        </div>
      </div>
    </div>
  );
}