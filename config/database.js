const { Sequelize } = require('sequelize');

const sequelize = new Sequelize(
  process.env.DB_NAME,
  process.env.DB_USER,
  process.env.DB_PASSWORD,
  {
    host: process.env.DB_HOST,
    port: parseInt(process.env.DB_PORT, 10),
    dialect: 'postgres',  // Change dialect here from 'mysql' to 'postgres'

    dialectOptions: {
      ssl: {
        require: true,       // Required for most cloud Postgres
        rejectUnauthorized: false
      }
    },

    pool: {
      acquire: 60000        // Increase timeout to 60 seconds
    },

    logging: false
  }
);

module.exports = sequelize;
