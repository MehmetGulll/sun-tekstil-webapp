const express = require("express");
const router = express.Router();
const Joi = require("joi");
const { Op } = require("sequelize");
const authenticateToken = require("../middlewares/authentication");
const { initializeSequelize } = require("../helpers/sequelize");
const { aksiyon } = require("../helpers/sequelizemodels");

// TÜM AKSİYONLARI LİSTELER
router.post("/getAllAction", authenticateToken, async (req, res) => {
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
    const aksiyonModel = sequelize.define("aksiyon", aksiyon, {
      timestamps: false,
      freezeTableName: true,
    });
    console.log("page", page);
    console.log("perPage", perPage);

    const { rows: allAction, count } = await aksiyonModel.findAndCountAll({
      where: {
        status: 1,
      },
      offset: offset,
      limit: perPage,
    });

    if (!allAction || allAction.length === 0) {
      return res.status(404).send("Aksiyon Bulunamadi!");
    }

    return res
      .status(200)
      .send({ data: allAction, total: count, page: page, perPage: perPage });
  } catch (error) {
    console.error("Get All Action Error:", error);
    return res.status(500).send(error);
  }
});

// YENİ BİR AKSİYON OLUŞTURUR
router.post("/createAction", authenticateToken, async (req, res) => {
  try {
    const { error, value } = Joi.object({
      aksiyon_konu: Joi.string().required(),
      aksiyon_gorsel: Joi.string(),
      aksiyon_bitis_tarihi: Joi.string(),
      aksiyon_sure: Joi.number().required(),
      aksiyon_oncelik: Joi.number().required(),
      denetim_tip_id: Joi.number().required(),
      aksiyon_kapatan_id: Joi.number(),
    }).validate(req.body);

    if (error) return res.status(400).send(error);

    const {
      aksiyon_konu,
      aksiyon_gorsel,
      aksiyon_sure,
      aksiyon_oncelik,
      denetim_tip_id,
    } = value;
    const sequelize = await initializeSequelize();
    const aksiyonModel = sequelize.define("aksiyon", aksiyon, {
      timestamps: false,
      freezeTableName: true,
    });

    const today = new Date();
    const formattedDate = today.toISOString().slice(0, 10);

    const newAction = await aksiyonModel.create({
      aksiyon_konu,
      aksiyon_gorsel,
      aksiyon_acilis_tarihi: formattedDate,
      aksiyon_sure,
      aksiyon_oncelik,
      denetim_tip_id,
      aksiyon_olusturan_id: req.user.id,
      status: 1,
    });

    return res.status(201).send(newAction);
  } catch (error) {
    console.error("Add Action Error:", error);
    return res.status(500).send(error);
  }
});

// AKTİF OLAN İDSİ VERİLEN AKSİYONU KAPATIR
router.post("/closeAction", authenticateToken, async (req, res) => {
  try {
    const { error, value } = Joi.object({
      aksiyon_id: Joi.number().required(),
      aksiyon_bitis_tarihi: Joi.string().optional(),
    }).validate(req.body);

    if (error) return res.status(400).send(error);
    const { aksiyon_id, aksiyon_bitis_tarihi } = value;

    const sequelize = await initializeSequelize();
    const aksiyonModel = sequelize.define("aksiyon", aksiyon, {
      timestamps: false,
      freezeTableName: true,
    });

    const isActionExist = await aksiyonModel.findOne({
      where: {
        aksiyon_id: aksiyon_id,
        status: 1,
      },
    });

    if (!isActionExist) return res.status(400).send("Aksiyon Bulunamadı!");

    if (
      isActionExist.aksiyon_olusturan_id !== req.user.id &&
      req.user.rol_id !== 1 &&
      req.user.rol_id !== 2
    )
      return res
        .status(400)
        .send("Aksiyonu Sadece Oluşturan veya Admin Kapatabilir!");

    if (
      new Date(aksiyon_bitis_tarihi) <
      new Date(isActionExist.aksiyon_acilis_tarihi)
    ) {
      return res
        .status(400)
        .send(
          "Aksiyon Bitiş Tarihi Açılış Tarihinden Önce Olamaz! Lütfen Bilgileri Kontrol Ediniz"
        );
    }

    const isActionClosed = await aksiyonModel.findOne({
      where: {
        aksiyon_id: aksiyon_id,
        status: 0,
      },
    });

    if (isActionClosed)
      return res.status(400).send("Aksiyon Zaten Kapatılmış!");

    const updatedAction = await aksiyonModel.update(
      {
        aksiyon_kapatan_id: req.user.id,
        aksiyon_bitis_tarihi: aksiyon_bitis_tarihi
          ? aksiyon_bitis_tarihi
          : new Date().toISOString().slice(0, 10),
        status: 0,
      },
      {
        where: {
          aksiyon_id: aksiyon_id,
        },
      }
    );
    return res.status(200).send("Aksiyon Başarıyla Kapatıldı!");
  } catch (error) {
    console.error("Close Action Error:", error);
    return res.status(500).send(error);
  }
});

module.exports = router;
