const express = require('express');
const questionsController = require('../controllers/questionsController');

const router = express.Router();

router.get('/getQuestions',questionsController.getQuestions);
router.get('/filteredQuestion', questionsController.filterQuestions);

module.exports = router;