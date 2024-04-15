const express = require("express");
const router = express.Router();
const Joi = require("joi");
const authenticateToken = require("../middlewares/authentication");
const { initializeSequelize } = require("../helpers/sequelize");
const { magaza } = require("../helpers/sequelizemodels");

router.post("/getAllStore", authenticateToken, async (req, res) => {
  try {
    const paginationSchema = Joi.object({
      page: Joi.number().integer().min(1).default(1),
      perPage: Joi.number().integer().min(1).default(10),
    });

    const { error, value } = paginationSchema.validate(req.body);

    if (error) {
      return res.status(400).send(error.details[0].message);
    }

    let { page, perPage } = value;

    const offset = (page - 1) * perPage;

    const sequelize = await initializeSequelize();
    const magazaModel = sequelize.define("magaza", magaza, {
      timestamps: false,
      freezeTableName: true,
    });
    console.log("page", page);
    console.log("perPage", perPage);

    const { rows: allStore, count } = await magazaModel.findAndCountAll({
      where: {
        status: 1,
      },
      offset: offset,
      limit: perPage,
    });

    if (!allStore || allStore.length === 0) {
      return res.status(404).send("Magaza Bulunamadi!");
    }

    return res
      .status(200)
      .send({ stores: allStore, total: count, page: page, perPage: perPage });
  } catch (error) {
    console.error("Get All Store Error:", error);
    return res.status(500).send(error);
  }
});

router.post("/addStore", authenticateToken, async (req, res) => {
  try {
    const { error, value } = Joi.object({
      magaza_adi: Joi.string().required(),
      magaza_kodu: Joi.string().required(),
      bolge_id: Joi.number().required(),
      sehir: Joi.string().required(),
      adres: Joi.string().required(),
      telefon: Joi.string().required(),
      email: Joi.string().required(),
      magaza_muduru: Joi.number().required(),
      status: Joi.number().required(),
    }).validate(req.body);

    if (error) {
      return res.status(400).send(error.details[0].message);
    }

    const {
      magaza_adi,
      magaza_kodu,
      bolge_id,
      sehir,
      adres,
      telefon,
      email,
      magaza_muduru,
      status,
    } = value;

    const sequelize = await initializeSequelize();
    const magazaModel = sequelize.define("magaza", magaza, {
      timestamps: false,
      freezeTableName: true,
    });

    const store = await magazaModel.findOne({
      where: {
        magaza_kodu,
        status: 1,
      },
    });

    if (store) return res.status(400).send("Bu magaza kodu zaten mevcut!");

    const newStore = await magazaModel.create({
      magaza_adi,
      magaza_kodu,
      bolge_id,
      sehir,
      adres,
      telefon,
      email,
      magaza_muduru,
      status,
    });

    return res.status(201).send(newStore);
  } catch (error) {
    console.error("Add Store Error:", error);
    return res.status(500).send;
  }
});

module.exports = router;
