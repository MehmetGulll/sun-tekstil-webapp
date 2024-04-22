const express = require('express');
const userController = require('../controllers/userController');
const loginMiddleware = require('../middlewares/loginmiddleware');
const router = express.Router();

router.post('/login',loginMiddleware,userController.login);
router.post('/register', userController.register);
module.exports = router;