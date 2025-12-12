import { useState } from 'react';
import { useNavigate, Link } from 'react-router-dom';
import { useAuth } from '../contexts/AuthContext';

export default function Login() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);
  
  const { login } = useAuth();
  const navigate = useNavigate();

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError('');
    setLoading(true);

    const result = await login({ email, password });
    
    if (result.success) {
      // Redirect berdasarkan role
      const user = JSON.parse(localStorage.getItem('user'));
      if (user?.role === 'admin') {
        navigate('/news');
      } else if (user?.role === 'penulis') {
        navigate('/news');
      } else {
        navigate('/news');
      }
    } else {
      setError(result.message);
    }
    setLoading(false);
  };

  return (
    <div className="login-container">
      <div className="login-box">
        <div className="login-header">
          <h2>🔐 Login</h2>
          <p>Masuk ke akun Anda</p>
        </div>
        
        {error && <div className="error-message">{error}</div>}
        
        <form onSubmit={handleSubmit}>
          <div className="form-group">
            <label htmlFor="email">Email</label>
            <input 
              type="email" 
              id="email"
              placeholder="contoh@email.com" 
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              required
            />
          </div>
          
          <div className="form-group">
            <label htmlFor="password">Password</label>
            <input 
              type="password" 
              id="password"
              placeholder="Masukkan password" 
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              required
            />
          </div>
          
          <div className="form-options">
            <label className="remember-me">
              <input type="checkbox" /> Ingat saya
            </label>
            <Link to="/forgot-password" className="forgot-password">
              Lupa password?
            </Link>
          </div>
          
          <button type="submit" disabled={loading} className="btn-login-submit">
            {loading ? '⏳ Memproses...' : '🚀 Masuk'}
          </button>
        </form>
        
        <div className="login-divider">
          <span>atau</span>
        </div>
        
        <div className="login-footer">
          <p>
            Belum punya akun? <Link to="/register" className="register-link">Daftar di sini</Link>
          </p>
          
          <div className="role-info">
            <h4>👥 Pilih Role Saat Daftar:</h4>
            <div className="role-badges">
              <span className="role-badge role-pembaca">Pembaca</span>
              <span className="role-badge role-penulis">Penulis</span>
              {/* <span className="role-badge role-admin">Admin</span> */}
            </div>
            <p className="note">
              <small>* Admin hanya dapat dibuat oleh administrator sistem</small>
            </p>
          </div>
        </div>
      </div>
    </div>
  );
}