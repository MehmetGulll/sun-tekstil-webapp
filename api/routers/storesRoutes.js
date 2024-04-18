const express  = require('express');
const storeController = require('../controllers/storeController');
const router = express.Router();

router.get('/getStores',storeController.getStores);
router.post('/addStore', storeController.addStore);
router.delete('/deleteStore/:id',storeController.deleteStore);

module.exports = router;