class Question{
    constructor(questionId, questionName, questionAnswer, questionPoint, controllerTipId,status) {
        this.questionId = questionId;
        this.questionName = questionName;
        this.questionAnswer = questionAnswer;
        this.questionPoint = questionPoint;
        this.controllerTipId = controllerTipId;
        this.status = status;
      }
}
module.exports = Question;