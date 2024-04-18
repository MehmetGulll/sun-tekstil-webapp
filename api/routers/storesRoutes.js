const express  = require('express');
const storeController = require('../controllers/storeController');
const router = express.Router();

router.get('/getStores',storeController.getStores);

module.exports = router;