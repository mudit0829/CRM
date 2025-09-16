const { DataTypes } = require('sequelize');
const db = require('../config/database');

const User = db.define('User', {
  email: { type: DataTypes.STRING, allowNull: false, unique: true },
  password_hash: { type: DataTypes.STRING, allowNull: false },
  first_name: { type: DataTypes.STRING, allowNull: false },
  last_name: { type: DataTypes.STRING, allowNull: false },
  role: { type: DataTypes.ENUM('admin','user','manager'), defaultValue: 'user' },
  phone: { type: DataTypes.STRING },
  is_active: { type: DataTypes.BOOLEAN, defaultValue: true }
});

module.exports = User;
