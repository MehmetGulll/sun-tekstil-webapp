class Question{
    constructor(questionId, questionName, questionAnswer, questionPoint, controllerTipId) {
        this.questionId = questionId;
        this.questionName = questionName;
        this.questionAnswer = questionAnswer;
        this.questionPoint = questionPoint;
        this.controllerTipId = controllerTipId;
      }
}
module.exports = Question;