const mysql = require('mysql2');
require('dotenv').config();

// Buat koneksi database
const connection = mysql.createConnection({
  host: process.env.DB_HOST,
  socketPath: process.env.DB_SOCKET, // gunakan socket
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME
});

// Test koneksi
connection.connect((err) => {
  if (err) {
    console.log('❌ Database connection error:', err.message);
  } else {
    console.log('✅ Connected to MySQL database via socket successfully!');
  }
});

// Export connection
module.exports = connection;