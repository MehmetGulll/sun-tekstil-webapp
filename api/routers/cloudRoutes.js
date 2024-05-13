const express = require('express');
const cloudController = require('../controllers/cloudController');
const multer = require('multer');
const upload = multer({ dest: "public/" });

const router = express.Router();
router.post('/upload', upload.single("photo"), cloudController.sendCloudImage);
module.exports = router;