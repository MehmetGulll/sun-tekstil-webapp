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
const cloudConfig = {
    cloud_name:process.env.CDN_CLOUD_NAME,
    api_key:process.env.CDN_API_KEY,
    api_secret:process.envCDN_API_SECRET
}

module.exports={config, cloudConfig};