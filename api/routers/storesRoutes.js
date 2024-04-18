const express  = require('express');
const storeController = require('../controllers/storeController');
const router = express.Router();

router.get('/getStores',storeController.getStores);
router.post('/addStore', storeController.addStore);

module.exports = router;