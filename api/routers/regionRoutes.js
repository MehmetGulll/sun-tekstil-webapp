const express = require("express");
const router = express.Router();
const Joi = require("joi");
const authenticateToken = require("../middlewares/authentication");
const { initializeSequelize } = require("../helpers/sequelize");
const { bolge, kullanici } = require("../helpers/sequelizemodels");
const { Op } = require("sequelize");

// TÜM MAĞAZA BÖLGE LİSTESİNİ LİSTELER
router.post("/getAllRegion", authenticateToken, async (req, res) => {
  try {
    const { error, value } = Joi.object({
      page: Joi.number().optional(),
      perPage: Joi.number().optional().allow(null, ""),
      searchTerm: Joi.string().optional(),
    }).validate(req.body);

    if (error) return res.status(400).send(error);
    const { page = 1, perPage = 10, searchTerm } = value;

    const sequelize = await initializeSequelize();
    const bolgeModel = sequelize.define("bolge", bolge, {
      timestamps: false,
      freezeTableName: true,
    });

    const kullaniciModel = sequelize.define("kullanici", kullanici, {
      timestamps: false,
      freezeTableName: true,
    });

    bolgeModel.belongsTo(kullaniciModel, {
      as: "bolgeMuduru",
      foreignKey: "bolge_muduru",
      targetKey: "id",
    });
    const whereObj = {};

    if (searchTerm) {
      whereObj.bolge_adi = {
        [Op.like]: `%${searchTerm}%`,
      };
    }
    if (searchTerm === "" || searchTerm === null) {
      delete whereObj.bolge_adi;
    }

    const allRegion = await bolgeModel.findAndCountAll({
      where: whereObj,
      include: [
        {
          model: kullaniciModel,
          as: "bolgeMuduru",
          attributes: ["id","ad", "soyad"],
        },
      ],
      limit: perPage,
      offset: (page - 1) * perPage,
    });

    if (!allRegion || allRegion.length === 0) {
      return res.status(404).send("No Region Found");
    }
    return res
      .status(200)
      .send({ allRegion, total: allRegion.count, page, perPage });
  } catch (error) {
    console.error("Get All Inspections Error:", error);
    return res.status(500).send(error);
  }
});

// YENİ BÖLGE EKLER
router.post("/addRegion", authenticateToken, async (req, res) => {
  try {
    const { error, value } = Joi.object({
      bolge_adi: Joi.string().required(),
      bolge_kodu: Joi.string().required(),
      bolge_muduru: Joi.number().required(),
    }).validate(req.body);

    if (error) {
      return res.status(400).send(error);
    }

    const sequelize = await initializeSequelize();
    const bolgeModel = sequelize.define("bolge", bolge, {
      timestamps: false,
      freezeTableName: true,
    });

    const kullaniciModel = sequelize.define("kullanici", kullanici, {
      timestamps: false,
      freezeTableName: true,
    });

    const isUserExist = await kullaniciModel.findOne({
      where: {
        id: value.bolge_muduru,
        status: 1,
      },
    });

    if (!isUserExist) return res.status(404).send("Kullanıcı Bulunamadı!");

    const region = await bolgeModel.findOne({
      where: {
        bolge_kodu: value.bolge_kodu,
        status: 1,
      },
    });



    if (region) {
      return res
        .status(400)
        .send("Aynı bölge kodu ile kayıtlı bölge bulunmaktadır.");
    }

    const newRegion = await bolgeModel.create({
      bolge_adi: value.bolge_adi,
      bolge_muduru: value.bolge_muduru,
      bolge_kodu: value.bolge_kodu,
      status: 1,
    });

    return res.status(201).send(newRegion);
  } catch (error) {
    console.error("Add Region Error:", error);
    return res.status(500).send(error);
  }
});

// BÖLGE BİLGİLERİNİ GÜNCELLER
router.post("/updateRegion", authenticateToken, async (req, res) => {
  try {
    const { error, value } = Joi.object({
      bolge_id: Joi.number().required(),
      bolge_adi: Joi.string().optional(),
      bolge_muduru: Joi.number().optional(),
      bolge_kodu: Joi.string().optional(),
      status: Joi.number().optional(),
    }).validate(req.body);

    if (error) {
      return res.status(400).send(error);
    }

    const { bolge_id, bolge_adi, bolge_muduru, bolge_kodu, status } = value;

    const sequelize = await initializeSequelize();
    const bolgeModel = sequelize.define("bolge", bolge, {
      timestamps: false,
      freezeTableName: true,
    });

    const region = await bolgeModel.findOne({
      where: {
        bolge_id: bolge_id,
      },
    });

    if (!region) {
      return res.status(404).send("Bölge Bulunamadı!");
    }

    const updatedRegion = await region.update(
      {
        bolge_adi: bolge_adi || region.bolge_adi,
        bolge_muduru: bolge_muduru || region.bolge_muduru,
        bolge_kodu: bolge_kodu || region.bolge_kodu,
        status: status !== undefined ? status : region.status, 
      },
      {
        where: {
          bolge_id: bolge_id,
        },
      }
    );

    return res.status(200).send(updatedRegion);
  } catch (error) {
    console.error("Update Region Status Error:", error);
    return res.status(500).send(error);
  }
});


module.exports = router;
