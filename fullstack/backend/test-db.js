const mysql = require('mysql2');

console.log('Testing MySQL socket connection...');

const connection = mysql.createConnection({
  host: 'localhost',
  socketPath: '/opt/lampp/var/mysql/mysql.sock',
  user: 'root',
  password: '',
  database: 'newsapp' // ganti dengan nama database Anda
});

connection.connect((err) => {
  if (err) {
    console.log('❌ Socket connection error:', err.message);
  } else {
    console.log('✅ Connected via socket successfully!');
    
    // Test query
    connection.query('SELECT 1 + 1 AS solution', (err, results) => {
      if (err) {
        console.log('Query error:', err);
      } else {
        console.log('Query test result:', results[0].solution);
      }
      connection.end();
    });
  }
});