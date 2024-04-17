const express = require("express");
const router = express.Router();
const Joi = require("joi");
const { Op } = require("sequelize");
const authenticateToken = require("../middlewares/authentication");
const { initializeSequelize } = require("../helpers/sequelize");
const { denetim_tipi, denetim } = require("../helpers/sequelizemodels");

// TÜM DENETİM TİPLERİNİ LİSTELER
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

// YENİ DENETİM TİPİ EKLER
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

// DENETİM TİPİNİ GÜNCELLER
router.post("/updateInspectionType", authenticateToken, async (req, res) => {
  try {
    const { error, value } = Joi.object({
      denetim_tipi_id: Joi.number().required(),
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

    const existingInspectionType = await denetimTipiModel.findOne({
      where: {
        denetim_tip_id: value.denetim_tipi_id,
      },
    });

    if (!existingInspectionType) 
      return res.status(404).send("Denetim Tipi Bulunamadı!");
    

    if(existingInspectionType.status === value.status)
      return res.status(400).send("Denetim Tipi Zaten Bu Durumda! Güncelleme Yapılmadı!");
    

    if(existingInspectionType.denetim_tipi === value.denetim_tipi)
      return res.status(400).send("Denetim Tipi Zaten Bu İsimde! Güncelleme Yapılmadı!");
    

    if(existingInspectionType.denetim_tipi_kodu === value.denetim_tipi_kodu)
      return res.status(400).send("Denetim Tipi Zaten Bu Kodda! Güncelleme Yapılmadı!");
    


    const updatedInspectionType = await denetimTipiModel.update(
      { ...value },
      {
        where: {
          denetim_tip_id: value.denetim_tipi_id, 
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
});

module.exports = router;

// DENETİM TİPLERİ LİSTESİ
// bölge müdürü kontrolu haftalık
// bölge müdürü kontrolü aylık
// genel denetim
// görsel denetim
