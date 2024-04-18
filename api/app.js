// app.js
const express = require("express");
const sql = require("mssql");
const cors = require("cors");
const path = require("path");
const bodyParser = require('body-parser');
require("dotenv").config({ path: "./config/.env" });
const questionsRoutes = require('./routers/questionsRoutes');
const userRoutes = require('./routers/userRoutes');
const app = express();
app.use(cors());
app.use(express.json());

app.use(bodyParser.urlencoded({extended:false}));
app.use(bodyParser.json());
const port = 5000;

const authRoutes = require("./routers/authRoutes");
const regionRoutes = require("./routers/regionRoutes");
const storeRoutes = require("./routers/storeRoutes");

// app.use(authRoutes);
app.use(regionRoutes);
// app.use(storeRoutes);



app.use(questionsRoutes);
app.use(userRoutes);

// Start the server
app.listen(port, () => {
  console.log(`Server is running on port ${port}`);
});

// Root endpoint
app.get("/", (req, res) => {
  res.send("Welcome to the SUN TEKSTIL API!");
});
