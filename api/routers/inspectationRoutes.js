const express = require("express");
const router = express.Router();
const Joi = require("joi");
const { Op } = require("sequelize");
const authenticateToken = require("../middlewares/authentication");
const { initializeSequelize } = require("../helpers/sequelize");
const { denetim_tipi } = require("../helpers/sequelizemodels");

router.get("/getAllInspectionType", authenticateToken, async (req, res) => {
  try {
    const sequelize = await initializeSequelize();
    const denetimTipiModel = sequelize.define("denetim_tipi", denetim_tipi, {
      timestamps: false,
      freezeTableName: true,
    });

    const allInspectionType = await denetimTipiModel.findAndCountAll({
      where: {
        status: 1,
      },
    });

    if (!allInspectionType || allInspectionType.length === 0) {
      return res.status(404).send("Hiç Denetim Tipi Bulunamadı!");
    }

    return res
      .status(200)
      .send({ data: allInspectionType.rows, count: allInspectionType.count });
  } catch (error) {
    console.error("Get All Inspection Type Error:", error);
    return res.status(500).send(error);
  }
});

router.post("/addInspectionType", authenticateToken, async (req, res) => {
  try {
    const { error, value } = Joi.object({
      denetim_tipi: Joi.string().required(),
      denetim_tipi_kodu: Joi.string().required(),
      status: Joi.number().required(),
    }).validate(req.body);

    if (error) return res.status(400).send(error);

    const sequelize = await initializeSequelize();
    const denetimTipiModel = sequelize.define("denetim_tipi", denetim_tipi, {
      timestamps: false,
      freezeTableName: true,
    });

    const existingInspectionType = await denetimTipiModel.findOne({
        where: {
          [Op.or]: [
            { denetim_tipi: value.denetim_tipi },
            { denetim_tipi_kodu: value.denetim_tipi_kodu },
          ],
        },
      });
  
      if (existingInspectionType) {
        return res.status(400).send("Bu Denetim Tipi veya Kodu Mevcut!");
      }

    const newInspectionType = await denetimTipiModel.create({
      denetim_tipi: value.denetim_tipi,
      denetim_tipi_kodu: value.denetim_tipi_kodu,
      status: value.status,
    });

    return res.status(201).send(`Denetim Tipi Başarıyla Eklendi!`);
  } catch (error) {
    console.error("Get All Inspection Type Error:", error);
    return res.status(500).send(error);
  }
});

router.post("/updateInspectionType/:id",authenticateToken,async (req, res) => {
    try {
      const { error, value } = Joi.object({
        denetim_tipi: Joi.string(),
        denetim_tipi_kodu: Joi.string(),
        status: Joi.number(),
      }).validate(req.body);

      if (error) return res.status(400).send(error);

      const sequelize = await initializeSequelize();
      const denetimTipiModel = sequelize.define("denetim_tipi", denetim_tipi, {
        timestamps: false,
        freezeTableName: true,
      });

      const updatedInspectionType = await denetimTipiModel.update(
        { ...value },
        {
          where: {
            denetim_tip_id: req.params.id,
          },
        }
      );

      if (updatedInspectionType[0] === 0) {
        return res.status(404).send("Denetim Tipi Bulunamadı!");
      }

      return res.status(200).send(`Denetim Tipi Başarıyla Güncellendi!`);
    } catch (error) {
      console.error("Update Inspection Type Error:", error);
      return res.status(500).send(error);
    }
  }
);
module.exports = router;
// bölge müdürü kontrolu haftalık
// bölge müdürü kontrolü aylık
// genel denetim
// görsel denetim
