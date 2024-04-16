// app.js
const express = require("express");
const sql = require("mssql");
const cors = require("cors");
const path = require("path");
require("dotenv").config({ path: "./config/.env" });
const questionsRoutes = require('./routers/questionsRoutes');
const app = express();
app.use(cors());
app.use(express.json());
const port = 5000;

const authRoutes = require("./routers/authRoutes");
const regionRoutes = require("./routers/regionRoutes");
const storeRoutes = require("./routers/storeRoutes");
const inspectationRoutes = require("./routers/inspectationRoutes");

app.use(authRoutes);
app.use(regionRoutes);
app.use(storeRoutes);
app.use(questionsRoutes);
app.use(inspectationRoutes);

// Start the server
app.listen(port, () => {
  console.log(`Server is running on port ${port}`);
});

// Root endpoint
app.get("/", (req, res) => {
  res.send("Welcome to the SUN TEKSTIL API!");
});
