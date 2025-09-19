const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');
const sequelize = require('./config/database');
const authRoutes = require('./routes/auth');
const customerRoutes = require('./routes/customers');
require('dotenv').config();

const app = express();

app.use(cors());
app.use(bodyParser.json());

app.use('/api/auth', authRoutes);
app.use('/api/customers', customerRoutes);

app.get('/', (req, res) => {
  res.send('CRM Backend Running');
});

const start = async () => {
  try {
    console.log('Trying to authenticate to DB...');
    await sequelize.authenticate();
    console.log('Authentication OK. Syncing DB...');
    await sequelize.sync();
    console.log('Database connected and synced');
    app.listen(process.env.PORT || 10000, () => {
      console.log('Server started on port ' + (process.env.PORT || 10000));
    });
  } catch (err) {
    console.error('Unable to connect to database:', err);
  }
};

start();
