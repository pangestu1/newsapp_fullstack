const express = require('express');
const { getAllUsers, updateUserRole } = require('../controllers/userController');
const auth = require('../middleware/auth');
const router = express.Router();

router.get('/', auth(['admin']), getAllUsers);
router.put('/:userId/role', auth(['admin']), updateUserRole);

module.exports = router;