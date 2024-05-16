require('dotenv').config();
const config={
    user:process.env.DB_USER,
    password:process.env.DB_PASSWORD,
    server:process.env.DB_HOST,
    database:process.env.DB_NAME,
    options:{
        trustServerCertificate:true
    }
}


module.exports=config;