const express = require("express");
const reportsController = require("../controllers/reportsController");
const router = express.Router();

router.get("/getReports", reportsController.getReports);
router.put("/updateReport", reportsController.updateReport);
router.get("/filteredReport", reportsController.filterReports);
router.get('/detailReport/:denetim_id', reportsController.getReportDetails);
router.get('/getReportsByInspectionType/:inspectionTypeId', reportsController.getReportsByInspectionType);
router.get('/getAverageScoresByInspectionType', reportsController.getAverageScoresByInspectionType);

module.exports = router;
