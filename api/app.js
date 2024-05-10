// app.js
const express = require("express");
const sql = require("mssql");
const cors = require("cors");
const path = require("path");
const bodyParser = require('body-parser');
require("dotenv").config({ path: "./config/.env" });
const questionsRoutes = require('./routers/questionsRoutes');
const userRoutes = require('./routers/userRoutes');
const storesRoutes = require('./routers/storesRoutes');
const reportsRoutes = require('./routers/reportsRoutes');
const app = express();
app.use(cors());
app.use(express.json());

// app.use(bodyParser.urlencoded({extended:false}));
// app.use(bodyParser.json());
const port = 5000;

const authRoutes = require("./routers/authRoutes");
const regionRoutes = require("./routers/regionRoutes");
const storeRoutes = require("./routers/storeRoutes");
const inspection = require("./routers/inspectionRoutes");
const actionRoutes = require("./routers/actionRoutes");
const questionRoutes = require("./routers/questionRoutes");
const homeRoutes = require("./routers/homeRoutes");
const titleRoutes = require("./routers/titleRoutes");
const mailRoutes = require("./routers/mailRoutes");

app.use(bodyParser.json({limit: '50mb'}));
app.use(bodyParser.urlencoded({limit: '50mb', extended: true}));

app.use(authRoutes);
app.use(regionRoutes);
// app.use(storeRoutes);
app.use(homeRoutes);
app.use(titleRoutes);
app.use(mailRoutes);
app.use(questionsRoutes);
app.use(userRoutes);
app.use(storesRoutes);
app.use(reportsRoutes);
app.use(inspection);
app.use(actionRoutes);
app.use(questionRoutes);


// Start the server
app.listen(port, () => {
  console.log(`Server is running on port ${port}`);
});

// Root endpoint
app.get("/", (req, res) => {
  res.send("Welcome to the SUN TEKSTIL API!");
});
