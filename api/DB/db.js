const sql = require('mssql');
const config={
    user:process.env.DB_USER,
    password:process.env.DB_PASSWORD,
    server:process.env.DB_HOST,
    database:process.env.DB_NAME,
    options:{
        trustServerCertificate:true
    }
}

let pool;
async function getPool() {
    if (!pool) {
      pool = await sql.connect(config);
    }
    return pool;
  }
  
  module.exports = {
    getPool,
  };