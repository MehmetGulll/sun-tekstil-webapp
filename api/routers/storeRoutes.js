const express = require("express");
const router = express.Router();
const Joi = require("joi");
const { Op } = require("sequelize");
const authenticateToken = require("../middlewares/authentication");
const { initializeSequelize } = require("../helpers/sequelize");
const { magaza } = require("../helpers/sequelizemodels");

// TÜM MAĞAZALARI LİSTELER
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

// YENİ MAĞAZA EKLER
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

// MAĞAZA BİLGİLERİNİ GÜNCELLER
router.post("/updateStore", authenticateToken, async (req, res) => {
  try {
    const { error, value } = Joi.object({
      magaza_id: Joi.number().required(),
      magaza_kodu: Joi.string(),
      magaza_adi: Joi.string(),
      magaza_tipi: Joi.number(),
      bolge_id: Joi.number(),
      sehir: Joi.string(),
      magaza_telefon: Joi.string(),
      magaza_metre: Joi.number(),
      magaza_muduru: Joi.number(),
      acilis_tarihi: Joi.string(),
      status: Joi.number(),
    }).validate(req.body);

    if (error) {
      return res.status(400).send(error.details[0].message);
    }

    const sequelize = await initializeSequelize();
    const magazaModel = sequelize.define("magaza", magaza, {
      timestamps: false,
      freezeTableName: true,
    });

    const store = await magazaModel.findByPk(value.magaza_id);

    if (!store) {
      return res.status(404).send("Mağaza Bulunamadı!");
    }

    if (store.magaza_kodu === value.magaza_kodu) 
      return res.status(400).send("Mağaza Kodu Aynı Girildiği İçin Güncelleme Yapılmadı!");
    
    if (store.magaza_adi === value.magaza_adi)
      return res.status(400).send("Mağaza Adı Aynı Girildiği İçin Güncelleme Yapılmadı!");  
    
    if (store.magaza_tipi === value.magaza_tipi)
      return res.status(400).send("Mağaza Tipi Aynı Girildiği İçin Güncelleme Yapılmadı!");
    
    if (store.bolge_id === value.bolge_id)
      return res.status(400).send("Bölge Aynı Girildiği İçin Güncelleme Yapılmadı!");
    
    if (store.sehir === value.sehir)
      return res.status(400).send("Şehir Aynı Girildiği İçin Güncelleme Yapılmadı!");

    if (store.magaza_telefon === value.magaza_telefon) 
      return res.status(400).send("Mağaza Telefonu Aynı Girildiği İçin Güncelleme Yapılmadı!");
    if (store.magaza_metre === value.magaza_metre)
      return res.status(400).send("Mağaza Metre Aynı Girildiği İçin Güncelleme Yapılmadı!");

    if (store.magaza_muduru === value.magaza_muduru)
      return res.status(400).send("Mağaza Müdürü Aynı Girildiği İçin Güncelleme Yapılmadı!");

    if (store.acilis_tarihi === value.acilis_tarihi)
      return res.status(400).send("Açılış Tarihi Aynı Girildiği İçin Güncelleme Yapılmadı!");  
    if (store.status === value.status)
      return res.status(400).send("Mağaza Durumu Aynı Girildiği İçin Güncelleme Yapılmadı!");
    
      await magazaModel.update(
      {
        ...value,
        ekleyen_id: req.user.id,
      },
      {
        where: {
          magaza_id: value.magaza_id,
        },
      }
    );
    return res.status(200).send("Mağaza bilgileri başarıyla güncellendi.");
  } catch (error) {
    console.error("Mağaza Güncelleme Hatası:", error);
    return res.status(500).send(error);
  }
});

module.exports = router;
