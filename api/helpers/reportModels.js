class Report {
  constructor(
    inspectionId,
    inspectionTypeId,
    storeId,
    inspectorRole,
    inspectorName,
    pointsReceived,
    inspectionDate,
    inspectionCompletionDate,
    status
  ) {
    this.inspectionId = inspectionId;
    this.inspectionTypeId = inspectionTypeId;
    this.storeId = storeId;
    this.inspectorRole = inspectorRole;
    this.inspectorName = inspectorName;
    this.pointsReceived = pointsReceived;
    this.inspectionDate = inspectionDate;
    this.inspectionCompletionDate = inspectionCompletionDate;
    this.status = status;
  }
}

module.exports = Report;
