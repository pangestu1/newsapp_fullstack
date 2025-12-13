const mysql = require('mysql2');
require('dotenv').config();

const connection = mysql.createConnection({
  host: process.env.DB_HOST || 'localhost',
  user: process.env.DB_USER || 'root',
  password: process.env.DB_PASSWORD || '',
  database: process.env.DB_NAME || 'newsapp',
  port: process.env.DB_PORT || 3306   // tambahkan port
});

connection.connect((err) => {
  if (err) {
    console.log('❌ Database connection error:', err.message);
  } else {
    console.log('✅ Connected to MySQL database successfully!');
  }
});

module.exports = connection;
