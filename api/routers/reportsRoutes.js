const express = require("express");
const reportsController = require("../controllers/reportsController");
const router = express.Router();

router.get("/getReports", reportsController.getReports);
router.delete("/deleteReport/:inspectionId", reportsController.deleteReport);

module.exports = router;
