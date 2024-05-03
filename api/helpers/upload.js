const express = require("express");
const router = express.Router();

const cloudinary = require("cloudinary").v2;
const multer = require("multer");

cloudinary.config({
  cloud_name: "dlxtyba6l",
  api_key: "976265966384412",
  api_secret: "OeKtHjsBrSh3wxlemUWmiUHTUzg",
  secure: true,
});

const upload = multer({ dest: "/" });

router.post("/upload", upload.single("image"), async (req, res) => {
  try {
    const files = req.body.image.map((file) => {
      return file;
    });

    const promises = files.map((file) =>
      cloudinary.uploader.upload(file, {
        folder: "images",
        use_filename: true,
      })
    );

    const results = await Promise.all(promises);
    res.send(results);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: "Bir hata oluştu." });
  }
});

module.exports = router;
