const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const User = require('../models/User');

const register = async (req, res) => {
  try {
    const { name, email, password, role } = req.body;
    
    // Check if user exists
    User.findByEmail(email, (err, results) => {
      if (err) {
        return res.status(500).json({ message: 'Database error' });
      }
      
      if (results.length > 0) {
        return res.status(400).json({ message: 'User already exists' });
      }
      
      // Hash password
      const saltRounds = 10;
      bcrypt.hash(password, saltRounds, (err, hashedPassword) => {
        if (err) {
          return res.status(500).json({ message: 'Error hashing password' });
        }
        
        // Create user
        const newUser = {
          name,
          email,
          password: hashedPassword,
          role: role || 'pembaca'
        };
        
        User.create(newUser, (err, results) => {
          if (err) {
            return res.status(500).json({ message: 'Error creating user' });
          }
          
          const token = jwt.sign(
            { id: results.insertId, email, role: newUser.role },
            process.env.JWT_SECRET,
            { expiresIn: '7d' }
          );
          
          res.status(201).json({
            message: 'User created successfully',
            token,
            user: {
              id: results.insertId,
              name,
              email,
              role: newUser.role
            }
          });
        });
      });
    });
  } catch (error) {
    res.status(500).json({ message: 'Server error' });
  }
};

const login = (req, res) => {
  try {
    const { email, password } = req.body;
    
    User.findByEmail(email, (err, results) => {
      if (err) {
        return res.status(500).json({ message: 'Database error' });
      }
      
      if (results.length === 0) {
        return res.status(400).json({ message: 'Invalid credentials' });
      }
      
      const user = results[0];
      
      bcrypt.compare(password, user.password, (err, isMatch) => {
        if (err) {
          return res.status(500).json({ message: 'Error comparing passwords' });
        }
        
        if (!isMatch) {
          return res.status(400).json({ message: 'Invalid credentials' });
        }
        
        const token = jwt.sign(
          { id: user.id, email: user.email, role: user.role },
          process.env.JWT_SECRET,
          { expiresIn: '7d' }
        );
        
        res.json({
          message: 'Login successful',
          token,
          user: {
            id: user.id,
            name: user.name,
            email: user.email,
            role: user.role
          }
        });
      });
    });
  } catch (error) {
    res.status(500).json({ message: 'Server error' });
  }
};

module.exports = { register, login };