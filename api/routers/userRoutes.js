const express = require('express');
const userController = require('../controllers/userController');
const router = express.Router();

router.post('/login',userController.login);
router.post('/register', userController.register);
router.post('/logout', userController.logout);
router.post('/changePassword', userController.changePassword);
router.get('/getUsers',userController.getOfficalUsers);
router.post('/updateUserStatus/:id', userController.updateOfficalUserStatus);
module.exports = router;