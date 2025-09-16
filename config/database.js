const { Sequelize } = require('sequelize');

const sequelize = new Sequelize(
  process.env.DB_NAME,       // Database name from Render env vars
  process.env.DB_USER,       // Username from Render env vars
  process.env.DB_PASSWORD,   // Password from Render env vars
  {
    host: process.env.DB_HOST,               // DB host from Render
    port: parseInt(process.env.DB_PORT, 10) || 5432,  // Postgres default port
    dialect: 'postgres',                      // Use postgres dialect
    dialectOptions: {
      ssl: {
        require: true,                        // Required for Render Postgres
        rejectUnauthorized: false            // Allows self-signed certificates
      }
    },
    pool: {
      max: 10,               // Max DB connections
      min: 0,
      acquire: 60000,        // Wait 60 seconds for connection
      idle: 10000
    },
    logging: false           // Disable SQL logging; set to `console.log` to debug
  }
);

module.exports = sequelize;
