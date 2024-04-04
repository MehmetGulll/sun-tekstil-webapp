// app.js
const express = require('express');
const sql = require('mssql');
const cors = require('cors');
const path = require('path');
require('dotenv').config({ path: './config/.env' });
const app = express();
app.use(cors());
app.use(express.json());
const port = 5000;

const authRoutes = require('./routers/authRoutes');

app.use(authRoutes);
// Start the server
app.listen(port, () => {
  console.log(`Server is running on port ${port}`);
});

// Root endpoint
app.get('/', (req, res) => {
  res.send('Welcome to the SUN TEKSTIL API!');
});
