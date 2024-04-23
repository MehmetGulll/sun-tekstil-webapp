const express = require('express');
const userController = require('../controllers/userController');
const loginMiddleware = require('../middlewares/loginmiddleware');
const router = express.Router();

router.post('/login',userController.login);
router.post('/register', userController.register);
router.post('/logout',userController.logOut);
module.exports = router;