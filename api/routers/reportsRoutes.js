const express = require("express");
const reportsController = require("../controllers/reportsController");
const router = express.Router();

router.get("/getReports", reportsController.getReports);
router.put("/updateReport", reportsController.updateReport);
router.get("/filteredReport", reportsController.filterReports);

module.exports = router;
