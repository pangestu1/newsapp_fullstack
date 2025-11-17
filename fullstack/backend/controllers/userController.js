const User = require('../models/User');

const getAllUsers = (req, res) => {
  try {
    User.getAll((err, results) => {
      if (err) {
        return res.status(500).json({ message: 'Error fetching users' });
      }
      
      res.json(results);
    });
  } catch (error) {
    res.status(500).json({ message: 'Server error' });
  }
};

const updateUserRole = (req, res) => {
  try {
    const { userId } = req.params;
    const { role } = req.body;
    
    const allowedRoles = ['admin', 'penulis', 'pembaca'];
    if (!allowedRoles.includes(role)) {
      return res.status(400).json({ message: 'Invalid role' });
    }
    
    User.updateRole(userId, role, (err, results) => {
      if (err) {
        return res.status(500).json({ message: 'Error updating user role' });
      }
      
      if (results.affectedRows === 0) {
        return res.status(404).json({ message: 'User not found' });
      }
      
      res.json({ message: 'User role updated successfully' });
    });
  } catch (error) {
    res.status(500).json({ message: 'Server error' });
  }
};

module.exports = {
  getAllUsers,
  updateUserRole
};