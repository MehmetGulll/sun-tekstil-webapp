const multer = require("multer");

function configureCloudinaryMulter(cloudinary) {
  cloudinary.config({
    cloud_name: process.env.CDN_CLOUD_NAME,
    api_key: process.env.CDN_API_KEY,
    api_secret: process.env.CDN_API_SECRET,
    secure: true,
  });

  const upload = multer({
    storage: multer.memoryStorage(),
    limits: {
      fileSize: 50 * 1024 * 1024,
    },
  });

  return upload;
}

module.exports = configureCloudinaryMulter;
