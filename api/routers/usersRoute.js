const express = require('express');
const usersController = require('../controllers/usersController'); // Assuming you have a usersController

const router = express.Router();

router.get('/getUsers', usersController.getUsers); // Assuming you have a getUsers function in your usersController

module.exports = router;
