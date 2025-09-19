const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');
const sequelize = require('./config/database');
const authRoutes = require('./routes/auth');
const customerRoutes = require('./routes/customers');
const User = require('./models/user');
const bcrypt = require('bcryptjs');
require('dotenv').config();

const app = express();

app.use(cors());
app.use(bodyParser.json());

app.use('/api/auth', authRoutes);
app.use('/api/customers', customerRoutes);

app.get('/', (req, res) => {
  res.send('CRM Backend Running');
});

// Auto-seed admin user if not exists
const seedAdmin = async () => {
  const adminExists = await User.findOne({ where: { username: 'admin' } });
  if (!adminExists) {
    const hashedPassword = await bcrypt.hash('admin123', 10); // You can change password here
    await User.create({
      username: 'admin',
      password: hashedPassword,
      role: 'admin'
    });
    console.log('Admin user created: admin/admin123');
  } else {
    console.log('Admin user already exists');
  }
};

const start = async () => {
  try {
    console.log('Trying to authenticate to DB...');
    await sequelize.authenticate();
    console.log('Authentication OK. Syncing DB...');
    await sequelize.sync();
    await seedAdmin();
    console.log('Database connected, synced, and admin seeded');
    app.listen(process.env.PORT || 10000, () => {
      console.log('Server started on port ' + (process.env.PORT || 10000));
    });
  } catch (err) {
    console.error('Unable to connect to database:', err);
  }
};

start();
