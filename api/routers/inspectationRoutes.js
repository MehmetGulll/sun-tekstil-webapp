const express = require("express");
const router = express.Router();
const Joi = require("joi");
const { Op } = require("sequelize");
const authenticateToken = require("../middlewares/authentication");
const { initializeSequelize } = require("../helpers/sequelize");
const {
  denetim_tipi,
  denetim,
  soru,
  denetim_sorulari,
  aksiyon,
} = require("../helpers/sequelizemodels");

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
    const inspectionType = await denetimTipiModel.findOne({
      where: {
        denetim_tipi: value.denetim_tipi,
      },
    });

    const existingInspectionType = await denetimTipiModel.findOne({
      where: {
        denetim_tip_id: value.denetim_tipi_id,
      },
    });

    if (!existingInspectionType)
      return res.status(404).send("Denetim Tipi Bulunamadı!");

    if (existingInspectionType.status === value.status)
      return res
        .status(400)
        .send("Denetim Tipi Zaten Bu Durumda! Güncelleme Yapılmadı!");

    if (existingInspectionType.denetim_tipi === value.denetim_tipi)
      return res
        .status(400)
        .send("Denetim Tipi Zaten Bu İsimde! Güncelleme Yapılmadı!");

    if (existingInspectionType.denetim_tipi_kodu === value.denetim_tipi_kodu)
      return res
        .status(400)
        .send("Denetim Tipi Zaten Bu Kodda! Güncelleme Yapılmadı!");

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

// YENİ BİR DENETİM OLUŞTUR
router.post("/addInspection", authenticateToken, async (req, res) => {
  try {
    const { error, value } = Joi.object({
      denetim_tipi_id: Joi.number().required(),
      magaza_id: Joi.number().required(),
      denetci_id: Joi.number().required(),
      denetim_tarihi: Joi.string().required(),
    }).validate(req.body);

    if (error) return res.status(400).send(error);

    const { denetim_tipi_id, magaza_id, denetci_id, denetim_tarihi } = value;

    const sequelize = await initializeSequelize();
    const denetimModel = sequelize.define("denetim", denetim, {
      timestamps: false,
      freezeTableName: true,
    });

    const date = new Date(denetim_tarihi);
    const formattedDate = `${date.getFullYear()}-${String(
      date.getMonth() + 1
    ).padStart(2, "0")}-${String(date.getDate()).padStart(2, "0")}`;

    const newInspection = await denetimModel.create({
      denetim_tipi_id,
      magaza_id,
      denetci_id,
      denetim_tarihi: formattedDate,
      status: 1,
    });

    return res.status(201).send(`Denetim Başarıyla Oluşturuldu!`);
  } catch (error) {
    console.error("Add Inspection Error:", error);
    return res.status(500).send(error);
  }
});

router.post("/answerInspection", authenticateToken, async (req, res) => {
  try {
    const { error, value } = Joi.object({
      denetim_id: Joi.number().required(),
      cevaplar: Joi.array()
        .items(
          Joi.object({
            soru_id: Joi.number().required(),
            cevap: Joi.number().required(),
            aksiyon: Joi.array()
              .items(
                Joi.object({
                  aksiyon_konu: Joi.string().required(),
                  aksiyon_gorsel: Joi.string(),
                  aksiyon_bitis_tarihi: Joi.string(),
                  aksiyon_sure: Joi.number().required(),
                  aksiyon_oncelik: Joi.number().required(),
                })
              )
              .optional(),
          })
        )
        .required(),
    }).validate(req.body);
    if (error) return res.status(400).send(error);

    const { denetim_id, cevaplar } = value;

    const sequelize = await initializeSequelize();

    const denetimModel = sequelize.define("denetim", denetim, {
      timestamps: false,
      freezeTableName: true,
    });

    const soruModel = sequelize.define("soru", soru, {
      timestamps: false,
      freezeTableName: true,
    });

    const denetimSorulariModel = sequelize.define(
      "denetim_sorulari",
      denetim_sorulari,
      {
        timestamps: false,
        freezeTableName: true,
      }
    );

    const aksiyonModel = sequelize.define("aksiyon", aksiyon, {
      timestamps: false,
      freezeTableName: true,
    });

    const existingInspection = await denetimModel.findOne({
      where: {
        denetim_id,
      },
    });
    if (!existingInspection) return res.status(404).send("Denetim Bulunamadı!");
    if (existingInspection.status === 0)
      return res.status(400).send("Bu Denetim Zaten Tamamlandı!");

    const sorular = await soruModel.findAll({
      where: {
        denetim_tip_id: existingInspection.dataValues.denetim_tipi_id,
        status: 1,
      },
    });

    // Tüm cevaplanan soruları bir kerede denetim_sorulari tablosuna ekleyelim
    const denetimSorular = [];
    for (let i = 0; i < cevaplar.length; i++) {
      const cevap = cevaplar[i];
      const soru = sorular.find(
        (soru) => soru.dataValues.soru_id === cevap.soru_id
      );
      if (!soru) {
        return res.status(400).send("Soru Bulunamadı!");
      }

      const createDenetimSorular = await denetimSorulariModel.create({
        denetim_id,
        soru_id: cevap.soru_id,
        cevap: cevap.cevap,
        dogru_cevap: soru.dataValues.soru_cevap,
      });
      denetimSorular.push(createDenetimSorular);
    }
    
    // Aksiyonları oluştur
    for (let i = 0; i < denetimSorular.length; i++) {
      const ds_id = denetimSorular[i].dataValues.ds_id;
      const cevap = cevaplar[i];
      if (cevap.aksiyon && cevap.aksiyon.length > 0) {
        for (let j = 0; j < cevap.aksiyon.length; j++) {
          const aksiyon = cevap.aksiyon[j];
          await aksiyonModel.create({
            ds_id : ds_id,
            aksiyon_konu: aksiyon.aksiyon_konu,
            aksiyon_gorsel: aksiyon.aksiyon_gorsel,
            aksiyon_acilis_tarihi: "2024-04-30",
            aksiyon_sure: aksiyon.aksiyon_sure,
            aksiyon_oncelik: aksiyon.aksiyon_oncelik,
            aksiyon_olusturan_id: req.user.id,
            status: 1,
          });
        }
      }
    }

    // Denetim statusunu güncelle
    await denetimModel.update(
      {
        status: 0,
        denetim_tamamlanma_tarihi: new Date().toISOString().split("T")[0],
      },
      {
        where: {
          denetim_id,
        },
      }
    );

    return res.status(201).send(`Denetim Soruları Başarıyla Cevaplandı!`);
  } catch (error) {
    console.error("Answer Inspection Error:", error);
    return res.status(500).send(error);
  }
});



module.exports = router;
