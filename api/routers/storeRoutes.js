const express = require("express");
const router = express.Router();
const Joi = require("joi");
const { Op } = require("sequelize");
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
      magaza_tipi: Joi.number().required(),
      bolge_id: Joi.number().required(),
      sehir: Joi.string().required(),
      magaza_telefon: Joi.string().required(),
      magaza_metre: Joi.number().required(),
      magaza_muduru: Joi.number().required(),
      acilis_tarihi: Joi.string().required(),
      status: Joi.number().required(),
    }).validate(req.body);

    if (error) {
      return res.status(400).send(error.details[0].message);
    }

    const {
      magaza_adi,
      magaza_kodu,
      magaza_tipi,
      bolge_id,
      sehir,
      magaza_telefon,
      magaza_metre,
      magaza_muduru,
      acilis_tarihi,
      status,
    } = value;

    const sequelize = await initializeSequelize();
    const magazaModel = sequelize.define("magaza", magaza, {
      timestamps: false,
      freezeTableName: true,
    });

    const existingStore = await magazaModel.findOne({
      where: {
        [Op.and]: [
          {
            [Op.or]: [
              { magaza_kodu: magaza_kodu },
              { magaza_telefon: magaza_telefon },
            ],
          },
          { status: 1 },
        ],
      },
    });

    if (existingStore) {
      return res
        .status(400)
        .send(
          "Telefon numarası veya mağaza kodu zaten kullanılmakta! Lütfen farklı bir telefon numarası veya mağaza kodu giriniz."
        );
    }

    const newStore = await magazaModel.create({
      magaza_adi,
      magaza_kodu,
      magaza_tipi,
      bolge_id,
      sehir,
      magaza_telefon,
      magaza_metre,
      magaza_muduru,
      acilis_tarihi,
      status,
      ekleyen_id: req.user.id,
    });

    return res.status(201).send(newStore);
  } catch (error) {
    console.error("Add Store Error:", error);
    return res.status(500).send(error);
  }
});

router.post("/updateStoreStatus", authenticateToken, async (req, res) => {
    try {
      const { error, value } = Joi.object({
        magaza_id: Joi.number().required(),
        status: Joi.number().required(),
      }).validate(req.body);
  
      if (error) {
        return res.status(400).send(error.details[0].message);
      }
  
      const sequelize = await initializeSequelize();
      const magazaModel = sequelize.define("magaza", magaza, {
        timestamps: false,
        freezeTableName: true,
      });
  
      const store = await magazaModel.findOne({
        where: {
          magaza_id: value.magaza_id,
        },
      });
  
      if (!store) {
        return res.status(404).send("Mağaza Bulunamadı!");
      }
      await magazaModel.update(
        { 
          status: value.status,
          ekleyen_id: req.user.id,
        },
        {
          where: {
            magaza_id: value.magaza_id,
          },
        }
      );
  
      const updatedStore = await magazaModel.findOne({
        where: {
          magaza_id: value.magaza_id,
        },
      });
  
      return res.status(200).send(`${updatedStore.magaza_adi} Mağazası ${value.status === 1 ? "Aktif" : "Pasif"} Olarak Güncellendi. ${req.user.ad} ${req.user.soyad} tarafından güncellendi.`);
    } catch (error) {
      console.error("Mağaza Durumu Güncelleme Hatası:", error);
      return res.status(500).send(error);
    }
  });
  

module.exports = router;
