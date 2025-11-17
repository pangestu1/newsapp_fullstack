const db = require('../config/database');

const User = {
  create: (userData, callback) => {
    const query = 'INSERT INTO users (name, email, password, role) VALUES (?, ?, ?, ?)';
    db.query(query, [userData.name, userData.email, userData.password, userData.role], callback);
  },
  
  findByEmail: (email, callback) => {
    const query = 'SELECT * FROM users WHERE email = ?';
    db.query(query, [email], callback);
  },
  
  findById: (id, callback) => {
    const query = 'SELECT id, name, email, role FROM users WHERE id = ?';
    db.query(query, [id], callback);
  },
  
  updateRole: (userId, newRole, callback) => {
    const query = 'UPDATE users SET role = ? WHERE id = ?';
    db.query(query, [newRole, userId], callback);
  },
  
  getAll: (callback) => {
    const query = 'SELECT id, name, email, role FROM users';
    db.query(query, callback);
  }
};

module.exports = User;