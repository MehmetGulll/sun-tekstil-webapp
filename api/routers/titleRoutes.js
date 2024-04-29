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

// TÜM ÜNVANLARI LİSTELE
router.post("/getAllTitles", authenticateToken, async (req, res) => {
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
    const unvanModel = sequelize.define("unvan", unvan, {
      timestamps: false,
      freezeTableName: true,
    });

    const denetimTipiModel = sequelize.define("denetim_tipi", denetim_tipi, {
      timestamps: false,
      freezeTableName: true,
    });

    unvanModel.belongsTo(denetimTipiModel, {
      foreignKey: "denetim_tip_id",
    });

    const { rows: allTitles, count } = await unvanModel.findAndCountAll({
      where: {
        status: 1,
      },
      offset: offset,
      limit: perPage,
    });

    if (!allTitles || allTitles.length === 0) {
      return res.status(404).send("Ünvan Bulunamadi!");
    }

    return res
      .status(200)
      .send({ data: allTitles, total: count, page: page, perPage: perPage });
  } catch (error) {
    console.error("Get All Titles Error:", error);
    return res.status(500).send(error);
  }
});

// YENİ ÜNVAN EKLER
router.post("/addTitle", authenticateToken, async (req, res) => {
  try {
    const { error, value } = Joi.object({
      unvan_adi: Joi.string().required(),
      denetim_tip_id: Joi.number().required(),
    }).validate(req.body);

    if (error) return res.status(400).send(error);
    const { unvan_adi, denetim_tip_id } = value;
    const sequelize = await initializeSequelize();
    const unvanModel = sequelize.define("unvan", unvan, {
      timestamps: false,
      freezeTableName: true,
    });

    const denetimTipiModel = sequelize.define("denetim_tipi", denetim_tipi, {
      timestamps: false,
      freezeTableName: true,
    });

    unvanModel.belongsTo(denetimTipiModel, {
      foreignKey: "denetim_tip_id",
    });

    const existingTitle = await unvanModel.findOne({
      where: ([Op.or] = [
        { unvan_adi: unvan_adi },
        { denetim_tip_id: denetim_tip_id },
        { status: 1 },
      ]),
    });

    if (existingTitle) {
      return res.status(400).send("Bu Ünvan Zaten Mevcut!");
    }

    const newTitle = await unvanModel.create({
      unvan_adi: unvan_adi,
      denetim_tip_id: denetim_tip_id,
      ekleyen_id: req.user.id,
      status: 1,
    });

    return res.status(200).send(newTitle);
  } catch (error) {
    console.error("Add Title Error:", error);
    return res.status(500).send(error);
  }
});

// ÜNVAN GÜNCELLER
router.post("/updateTitle", authenticateToken, async (req, res) => {
  try {
    const { error, value } = Joi.object({
      unvan_id: Joi.number().required(),
      unvan_adi: Joi.string().optional(),
      denetim_tip_id: Joi.number().optional(),
      status: Joi.number().optional(),
    }).validate(req.body);

    if (error) return res.status(400).send(error);
    const { unvan_id, unvan_adi, denetim_tip_id, status } = value;
    const sequelize = await initializeSequelize();

    const unvanModel = sequelize.define("unvan", unvan, {
      timestamps: false,
      freezeTableName: true,
    });

    const denetimTipiModel = sequelize.define("denetim_tipi", denetim_tipi, {
      timestamps: false,
      freezeTableName: true,
    });

    unvanModel.belongsTo(denetimTipiModel, {
      foreignKey: "denetim_tip_id",
    }); 

    const existingTitle = await unvanModel.findOne({
      where: {
        unvan_id: unvan_id,
      },
    });

    if (!existingTitle) {
      return res.status(404).send("Ünvan Bulunamadi!");
    }
    const updatedTitle = await unvanModel.update(
      {
        unvan_adi: unvan_adi ? unvan_adi : existingTitle.unvan_adi,
        denetim_tip_id: denetim_tip_id
          ? denetim_tip_id
          : existingTitle.denetim_tip_id,
        guncelleyen_id: req.user.id
          ? req.user.id
          : existingTitle.guncelleyen_id,
        status: status,
      },
      {
        where: {
          unvan_id: unvan_id,
        },
      }
    );

    return res.status(200).send("Başarıyla Güncellendi!"); 
  } catch (error) {
    console.error("Update Title Error:", error);
    return res.status(500).send(error);
  }
});

module.exports = router;
