const express = require('express');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const User = require('../models/user');
const router = express.Router();

router.post('/register', async (req, res) => {
  console.log('Register endpoint called with body:', req.body);
  const { username, password } = req.body;
  try {
    if (!username || !password) {
      console.log('Missing fields');
      return res.status(400).json({ message: 'Username and password are required.' });
    }
    const existingUser = await User.findOne({ where: { username } });
    if (existingUser) {
      console.log('User already exists');
      return res.status(400).json({ message: 'User already exists.' });
    }
    const hashedPassword = await bcrypt.hash(password, 10);
    const user = await User.create({ username, password: hashedPassword });
    console.log('User created:', user.username);
    return res.status(201).json({ message: 'User registered successfully.', userId: user.id });
  } catch (error) {
    console.error('Register error:', error);
    return res.status(500).json({ message: 'Server error', error: error.message });
  }
});

router.post('/login', async (req, res) => {
  console.log('Login attempt with:', req.body);
  const { username, password } = req.body;
  try {
    if (!username || !password) {
      console.log('Missing fields');
      return res.status(400).json({ message: 'Username and password are required.' });
    }
    const user = await User.findOne({ where: { username } });
    if (!user) {
      console.log('User not found');
      return res.status(400).json({ message: 'Invalid credentials.' });
    }
    const validPassword = await bcrypt.compare(password, user.password);
    if (!validPassword) {
      console.log('Invalid password');
      return res.status(400).json({ message: 'Invalid credentials.' });
    }
    const token = jwt.sign({ id: user.id, username: user.username }, process.env.JWT_SECRET, { expiresIn: '1d' });
    return res.status(200).json({ token, username: user.username });
  } catch (error) {
    console.error('Login error:', error);
    return res.status(500).json({ message: 'Server error', error: error.message });
  }
});

module.exports = router;
