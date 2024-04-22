const express = require('express');
const questionsController = require('../controllers/questionsController');

const router = express.Router();

router.get('/getQuestions',questionsController.getQuestions);
router.delete('/deleteQuestion/:questionId', questionsController.deleteQuestion);

module.exports = router;