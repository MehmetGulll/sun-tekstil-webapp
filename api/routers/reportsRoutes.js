const express = require("express");
const reportsController = require("../controllers/reportsController");
const router = express.Router();

router.get("/getReports", reportsController.getReports);
router.put("/updateReport", reportsController.updateReport);

module.exports = router;
