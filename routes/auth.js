const express = require('express');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const User = require('../models/user');
const router = express.Router();

router.post('/register', async (req, res) => {
  const { username, password } = req.body;
  console.log('[Register] Incoming:', { username, password });

  try {
    if (!username || !password) {
      console.log('[Register] Missing fields');
      return res.status(400).json({ message: 'Username and password are required.' });
    }
    const existingUser = await User.findOne({ where: { username } });
    if (existingUser) {
      console.log('[Register] User already exists');
      return res.status(400).json({ message: 'User already exists.' });
    }
    const hashedPassword = await bcrypt.hash(password, 10);
    const user = await User.create({ username, password: hashedPassword });
    console.log('[Register] User created:', user.username);

    return res.status(201).json({ message: 'User registered successfully.', userId: user.id });
  } catch (error) {
    console.error('[Register Error]', error);
    return res.status(500).json({ message: 'Server error', error: error.message });
  }
});

router.post('/login', async (req, res) => {
  const { username, password } = req.body;
  try {
    if (!username || !password) {
      return res.status(400).json({ message: 'Username and password are required.' });
    }
    const user = await User.findOne({ where: { username } });
    if (!user) {
      return res.status(400).json({ message: 'Invalid credentials.' });
    }
    const validPassword = await bcrypt.compare(password, user.password);
    if (!validPassword) {
      return res.status(400).json({ message: 'Invalid credentials.' });
    }
    const token = jwt.sign(
      { id: user.id, username: user.username },
      process.env.JWT_SECRET,
      { expiresIn: '1d' }
    );
    return res.status(200).json({ token, username: user.username });
  } catch (error) {
    console.error('[Login Error]', error);
    return res.status(500).json({ message: 'Server error', error: error.message });
  }
});

module.exports = router;
