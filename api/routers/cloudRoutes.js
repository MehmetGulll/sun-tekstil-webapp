const express = require('express');
const cloudController = require('../controllers/cloudController');

const router = express.Router();

router.post('/upload', upload.single('photo'), cloudController.sendCloudImage);