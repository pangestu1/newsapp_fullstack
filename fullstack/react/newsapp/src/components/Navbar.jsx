import { Link, useNavigate } from "react-router-dom";
import { useAuth } from "../contexts/AuthContext";


export default function Navbar() {
  const { user, logout, canCreate } = useAuth();
  const navigate = useNavigate();

  const handleLogout = () => {
    logout();
    navigate('/login');
  };

  return (
    <nav className="nav">
      <div className="nav-logo">NEWS APP</div>

      <ul className="nav-menu">
        <li><Link to="/">Home</Link></li>
        
{user ? (
  <>
    <li><Link to="/news">Berita</Link></li>
    {canCreate() && (
      <li><Link to="/create">Tambah Berita</Link></li>
    )}
    <li className="user-info">
      <div className="user-greeting">
        <span className="user-name">👋 Halo, {user.name}</span>
        {/* <span className={`user-role role-${user.role}`}>
          {user.role === 'admin' ? '👑 Admin' : 
           user.role === 'penulis' ? '✍️ Penulis' : '👤 Pembaca'}
        </span> */}
      </div>
    </li>
    <li>
      <button onClick={handleLogout} className="btn-logout">
        🚪 Logout
      </button>
    </li>
  </>
) : (
  <>
    <li><Link to="/login" className="btn-login">🔐 Login</Link></li>
    <li><Link to="/register" className="btn-register">📝 Daftar</Link></li>
  </>
)}
      </ul>
    </nav>
  );
}