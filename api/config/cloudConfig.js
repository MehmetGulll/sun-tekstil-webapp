require('dotenv').config();
const cloudConfig = {
    cloud_name:process.env.CDN_CLOUD_NAME,
    api_key:process.env.CDN_API_KEY,
    api_secret:process.env.CDN_API_SECRET
}

module.exports = cloudConfig;