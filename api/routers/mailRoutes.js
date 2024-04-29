const express = require("express");
const router = express.Router();
const Joi = require("joi");
const { Op } = require("sequelize");
const authenticateToken = require("../middlewares/authentication");
const { initializeSequelize } = require("../helpers/sequelize");
const {
  unvan,
  denetim_tipi,
  kullanici,
} = require("../helpers/sequelizemodels");


module.exports = router;