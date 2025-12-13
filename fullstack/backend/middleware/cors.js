// Di backend (Node.js/Express)
const cors = require('cors');

app.use(cors({
  origin: 'http://localhost:3000', // URL React development server
  credentials: true
}));