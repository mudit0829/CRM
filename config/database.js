const { Sequelize } = require('sequelize');

const sequelize = new Sequelize(
  process.env.DB_NAME,
  process.env.DB_USER,
  process.env.DB_PASSWORD,
  {
    host: process.env.DB_HOST,
    port: process.env.DB_PORT,
    dialect: 'mysql',
    dialectOptions: {
      ssl: {
        rejectUnauthorized: true, // or false if your DB certificate is self-signed
      }
    },
    pool: {
      acquire: 60000 // increase connection acquire timeout to 60 seconds
    },
    logging: false
  }
);

module.exports = sequelize;
