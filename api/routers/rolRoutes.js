const express = require('express');
const rolController = require('../controllers/rolController'); // Correct import statement

const router = express.Router();

router.get('/getRols', rolController.getRols); // Use rolController instead of questionsController

module.exports = router;
