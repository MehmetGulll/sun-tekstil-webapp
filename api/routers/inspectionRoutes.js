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
  magaza,
  kullanici,
  unvan,
  image,
} = require("../helpers/sequelizemodels");
const configureCloudinaryMulter = require("../helpers/cloudinaryMulter");
const { format } = require("path");
const cloudinary = require("cloudinary").v2;
const fs = require("fs");

router.post("/getAllInspectionType", authenticateToken, async (req, res) => {
  try {
    const { error, value } = Joi.object({
      page: Joi.number().optional(),
      perPage: Joi.number().optional(),
      searchTerm: Joi.string().optional(),
    }).validate(req.body);

    if (error) return res.status(400).send(error);

    const { page = 1, perPage = 10, searchTerm } = value;

    const sequelize = await initializeSequelize();
    const denetimTipiModel = sequelize.define("denetim_tipi", denetim_tipi, {
      timestamps: false,
      freezeTableName: true,
    });
    whereObj = {
      status: 1,
    };

    if (searchTerm) {
      whereObj[Op.or] = [
        { denetim_tipi: { [Op.like]: `%${searchTerm}%` } },
        { denetim_tipi_kodu: { [Op.like]: `%${searchTerm}%` } },
        { status: { [Op.like]: `%${searchTerm}%` } },
      ];
    }
    if (req.user.rol_id === 1 || req.user.rol_id === 2) {
      whereObj = {
        [Op.or]: [{ status: 1 }, { status: 0 }],
      };
    } else {
      whereObj = {
        status: 1,
      };
    }

    const allInspectionType = await denetimTipiModel.findAndCountAll({
      where: whereObj,
      limit: perPage,
      offset: (page - 1) * perPage,
      // order: [["denetim_tipi", "ASC"]],
    });

    if (!allInspectionType || allInspectionType.length === 0) {
      return res.status(404).send("Hiç Denetim Tipi Bulunamadı!");
    }

    return res.status(200).send({
      data: allInspectionType.rows,
      count: allInspectionType.count,
      page,
      perPage,
    });
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

    return res.status(201).send(newInspectionType);
  } catch (error) {
    console.error("Get All Inspection Type Error:", error);
    return res.status(500).send(error);
  }
});

// DENETİM TİPİNİ GÜNCELLER
router.post("/updateInspectionType", authenticateToken, async (req, res) => {
  try {
    const schema = Joi.object({
      denetim_tipi_id: Joi.number().required(),
      denetim_tipi: Joi.string().optional(),
      denetim_tipi_kodu: Joi.string().optional(),
      status: Joi.number().optional(),
    });

    const { error, value } = schema.validate(req.body);

    if (error) return res.status(400).send(error.details[0].message);

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

    if (!existingInspectionType) {
      return res.status(404).send("Denetim Tipi Bulunamadı!");
    }

    // Prepare the fields to be updated
    let fieldsToUpdate = {};
    if (
      value.denetim_tipi &&
      value.denetim_tipi !== existingInspectionType.denetim_tipi
    ) {
      fieldsToUpdate.denetim_tipi = value.denetim_tipi;
    }
    if (
      value.denetim_tipi_kodu &&
      value.denetim_tipi_kodu !== existingInspectionType.denetim_tipi_kodu
    ) {
      fieldsToUpdate.denetim_tipi_kodu = value.denetim_tipi_kodu;
    }
    if (
      typeof value.status !== "undefined" &&
      value.status !== existingInspectionType.status
    ) {
      fieldsToUpdate.status = value.status;
    }

    if (Object.keys(fieldsToUpdate).length === 0) {
      return res
        .status(400)
        .send("Güncelleme yapılacak değişiklik bulunamadı!");
    }

    const updatedInspectionType = await denetimTipiModel.update(
      fieldsToUpdate,
      {
        where: {
          denetim_tip_id: value.denetim_tipi_id,
        },
      }
    );

    if (updatedInspectionType[0] === 0) {
      return res.status(404).send("Denetim Tipi Bulunamadı!");
    }

    return res.status(200).send(updatedInspectionType);
  } catch (error) {
    console.error("Update Inspection Type Error:", error);
    return res.status(500).send(error.message);
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
      denetim_tamamlanma_tarihi: null,
      status: 1,
    });

    return res.status(201).send(newInspection);
  } catch (error) {
    console.error("Add Inspection Error:", error);
    return res.status(500).send(error);
  }
});

// Req.user bilgisi ile kullanıcının denetimlerini listeler
router.post("/getInspections", authenticateToken, async (req, res) => {
  try {
    const { error, value } = Joi.object({
      page: Joi.number().optional(),
      perPage: Joi.number().optional(),
      searchTerm: Joi.string().optional(),
      startDate: Joi.string().optional(),
      endDate: Joi.string().optional(),
    }).validate(req.body);

    if (error) return res.status(400).send(error);

    const { page = 1, perPage = 10, searchTerm, startDate, endDate } = value;

    const sequelize = await initializeSequelize();

    const denetimModel = sequelize.define("denetim", denetim, {
      timestamps: false,
      freezeTableName: true,
    });

    const kullaniciModel = sequelize.define("kullanici", kullanici, {
      timestamps: false,
      freezeTableName: true,
    });
    const denetimTipiModel = sequelize.define("denetim_tipi", denetim_tipi, {
      timestamps: false,
      freezeTableName: true,
    });

    const magazaModel = sequelize.define("magaza", magaza, {
      timestamps: false,
      freezeTableName: true,
    });

    const unvanModel = sequelize.define("unvan", unvan, {
      timestamps: false,
      freezeTableName: true,
    });

    denetimModel.belongsTo(kullaniciModel, {
      foreignKey: "denetci_id",
    });

    kullaniciModel.belongsTo(unvanModel, {
      foreignKey: "unvan_id",
    });

    denetimModel.belongsTo(denetimTipiModel, {
      foreignKey: "denetim_tipi_id",
    });

    denetimModel.belongsTo(magazaModel, {
      foreignKey: "magaza_id",
    });

    const whereObj = {
      denetci_id: req.user.id,
    };

    if (searchTerm) {
      whereObj[Op.or] = [
        { "$kullanici.ad$": { [Op.like]: `%${searchTerm}%` } },
        { "$kullanici.soyad$": { [Op.like]: `%${searchTerm}%` } },
        { "$denetim_tipi.denetim_tipi$": { [Op.like]: `%${searchTerm}%` } },
        { "$magaza.magaza_adi$": { [Op.like]: `%${searchTerm}%` } },
        { "$magaza.sehir$": { [Op.like]: `%${searchTerm}%` } },
      ];
    }

    const formatDate = (date) => {
      const [day, month, year] = date.split(".");
      return `${year}-${month.padStart(2, "0")}-${day.padStart(2, "0")}`;
    };

    if (startDate && endDate) {
      whereObj.denetim_tarihi = {
        [Op.between]: [formatDate(startDate), formatDate(endDate)],
      };
    } else if (startDate) {
      whereObj.denetim_tarihi = { [Op.gte]: formatDate(startDate) };
    } else if (endDate) {
      whereObj.denetim_tarihi = { [Op.lte]: formatDate(endDate) };
    }

    const allInspections = await denetimModel.findAndCountAll({
      where: whereObj,
      include: [
        {
          model: kullaniciModel,
          attributes: ["ad", "soyad", "unvan_id"],
          include: [
            {
              model: unvanModel,
              attributes: ["unvan_adi"],
            },
          ],
        },
        {
          model: denetimTipiModel,
          attributes: ["denetim_tipi"],
        },
        {
          model: magazaModel,
          attributes: ["magaza_adi", "sehir"],
        },
      ],
      limit: perPage,
      offset: (page - 1) * perPage,
      order: [
        ["status", "DESC"],
        ["denetim_tarihi", "DESC"],
      ],
    });

    if (!allInspections || allInspections.length === 0)
      return res.status(404).send("Hiç Denetim Bulunamadı!");

    const modifiedData = allInspections.rows.map((inspection) => {
      return {
        denetim_id: inspection.denetim_id,
        alinan_puan: inspection.alinan_puan
          ? inspection.alinan_puan
          : "Puanlanmadı",
        denetim_tarihi: new Date(
          inspection.denetim_tarihi
        ).toLocaleDateString(),
        denetim_tamamlanma_tarihi: inspection.denetim_tamamlanma_tarihi ? new Date(
          inspection.denetim_tamamlanma_tarihi
        ).toLocaleDateString() : "Denetim Tamamlanmamış",
        status: inspection.status,
        denetim_tipi: inspection.denetim_tipi.denetim_tipi,
        denetim_tip_id: inspection.denetim_tipi_id,
        magaza_adi: inspection.magaza.magaza_adi,
        sehir: inspection.magaza.sehir,
        denetci: inspection.kullanici.ad + " " + inspection.kullanici.soyad,
        unvan: inspection.kullanici.unvan.unvan_adi,
      };
    });

    return res
      .status(200)
      .send({ data: modifiedData, count: allInspections.count, page, perPage });
  } catch (error) {
    console.error("Get Questions By Inspector Id Error:", error);
    return res.status(500).send(error);
  }
});

// DENETİMİ CEVAPLAR VE AKSİYON OLUŞTURUR
router.post(
  "/answerInspection",
  authenticateToken,
  // configureCloudinaryMulter(cloudinary).array("aksiyon_gorsel"),
  async (req, res) => {
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
                    aksiyon_gorsel: Joi.string().optional(),
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

      const denetimTipiModel = sequelize.define("denetim_tipi", denetim_tipi, {
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

      soruModel.belongsTo(denetimTipiModel, {
        foreignKey: "denetim_tip_id",
      });

      const imageModel = sequelize.define("image", image, {
        timestamps: false,
        freezeTableName: true,
      });

      const existingInspection = await denetimModel.findOne({
        where: { denetim_id },
      });

      if (!existingInspection)
        return res.status(404).send("Denetim Bulunamadı!");
      if (existingInspection.status === 0)
        return res.status(400).send("Bu Denetim Zaten Tamamlandı!");

      const sorular = await soruModel.findAll({
        where: {
          denetim_tip_id: existingInspection.dataValues.denetim_tipi_id,
          status: 1,
        },
        include: [
          {
            model: denetimTipiModel,
            attributes: ["denetim_tipi"],
          },
        ],
      });

      const denetimTipiAdi =
        sorular[0].dataValues.denetim_tipi.dataValues.denetim_tipi;

      // Tüm cevaplanan soruları bir kerede denetim_sorulari tablosuna ekler
      const denetimSorular = [];
      let toplamPuan = 0;
      let maxPuan = 0;

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
        // Puan hesaplama
        if (cevap.cevap === soru.dataValues.soru_cevap) {
          toplamPuan += soru.dataValues.soru_puan;
        }
        maxPuan += soru.dataValues.soru_puan;
      }

      const alinanPuan = (toplamPuan / maxPuan) * 100;

      for (let i = 0; i < denetimSorular.length; i++) {
        const ds_id = denetimSorular[i].dataValues.ds_id;
        const cevap = cevaplar[i];
        if (cevap.aksiyon && cevap.aksiyon.length > 0) {
          for (let j = 0; j < cevap.aksiyon.length; j++) {
            const aksiyon = cevap.aksiyon[j];
            await imageModel.update(
              {
                aksiyon_id: aksiyon.aksiyon_id,
              },
              {
                where: {
                  public_id: aksiyon.aksiyon_gorsel,
                },
              }
            );
            const findImage = await imageModel.findOne({
              where: {
                public_id: aksiyon.aksiyon_gorsel,
              },
            });
            await aksiyonModel.create({
              ds_id,
              aksiyon_konu: aksiyon.aksiyon_konu,
              aksiyon_gorsel: findImage.image_id,
              aksiyon_acilis_tarihi: new Date().toISOString().split("T")[0],
              aksiyon_sure: aksiyon.aksiyon_sure,
              aksiyon_oncelik: aksiyon.aksiyon_oncelik,
              aksiyon_olusturan_id: req.user.id,
              status: 1,
            });
          }
        }
      }

      // Denetim puanını hesaplar
      // Eğer tüm sorular doğru ise max puanı alır fakat max puan 100 olmayabilir.
      // Soru cevap ve doğru cevapları karşılaştırarak eğer birbirine denk ise soru_puan eklensin.
      // Max puan tüm soruları doğru yaparsa oluşur fakat soru_puanları farklı olabilir.
      // Yani max puan 20 ise ve alınan puan 10 ise 10/20*100 = 50 olur şeklinde yap.

      // Denetim statusunu günceller
      await denetimModel.update(
        {
          status: 0,
          denetim_tamamlanma_tarihi: new Date().toISOString().split("T")[0],
          alinan_puan: alinanPuan,
        },
        {
          where: {
            denetim_id,
          },
        }
      );

      return res
        .status(201)
        .send(`Denetim Soruları Başarıyla Cevaplandıasdasdaasdasdasdadsd!`);
    } catch (error) {
      console.error("Answer Inspection Error:", error);
      return res
        .status(500)
        .send("Error occurred while answering inspection: " + error.message);
    }
  }
);

// update inspection status
router.post("/updateInspectionStatus", authenticateToken, async (req, res) => {
  try {
    const { error, value } = Joi.object({
      denetim_id: Joi.number().required(),
      status: Joi.number().required(),
    }).validate(req.body);

    if (error) return res.status(400).send(error);

    const { denetim_id, status } = value;

    const sequelize = await initializeSequelize();
    const denetimModel = sequelize.define("denetim", denetim, {
      timestamps: false,
      freezeTableName: true,
    });

    const existingInspection = await denetimModel.findOne({
      where: { denetim_id },
    });

    if (!existingInspection) return res.status(404).send("Denetim Bulunamadı!");

    if (existingInspection.status === status)
      return res
        .status(400)
        .send("Denetim Zaten Bu Durumda! Güncelleme Yapılmadı!");

    const updatedInspection = await denetimModel.update(
      { status },
      {
        where: {
          denetim_id,
        },
      }
    );

    if (updatedInspection[0] === 0) {
      return res.status(404).send("Denetim Bulunamadı!");
    }

    return res.status(200).send(`Denetim Başarıyla Güncellendi!`);
  } catch (error) {
    console.error("Update Inspection Status Error:", error);
    return res.status(500).send(error);
  }
});

// get inspection question from denetim_sorulari table by denetim_id
router.post("/getInspectionQuestions", authenticateToken, async (req, res) => {
  try {
    const { error, value } = Joi.object({
      denetim_id: Joi.number().required(),
    }).validate(req.body);

    if (error) return res.status(400).send(error);

    const { denetim_id } = value;

    const sequelize = await initializeSequelize();
    const denetimSorulariModel = sequelize.define(
      "denetim_sorulari",
      denetim_sorulari,
      {
        timestamps: false,
        freezeTableName: true,
      }
    );

    const soruModel = sequelize.define("soru", soru, {
      timestamps: false,
      freezeTableName: true,
    });

    const denetimModel = sequelize.define("denetim", denetim, {
      timestamps: false,
      freezeTableName: true,
    });

    const denetimTipiModel = sequelize.define("denetim_tipi", denetim_tipi, {
      timestamps: false,
      freezeTableName: true,
    });

    denetimSorulariModel.belongsTo(soruModel, {
      foreignKey: "soru_id",
      targetKey: "soru_id",
      as: "soru",
    });

    const findDenetim = await denetimModel.findOne({
      where: {
        denetim_id,
      },
    });

    if (!findDenetim) return res.status(404).send("Denetim Bulunamadı!");

    const inspectionQuestions = await denetimSorulariModel.findAndCountAll({
      where: {
        denetim_id,
      },
      include: [
        {
          model: soruModel,
          as: "soru",
        },
      ],
    });

    if (!inspectionQuestions || inspectionQuestions.length === 0) {
      return res.status(404).send("Denetim Soruları Bulunamadı!");
    }

    const modifiedData = inspectionQuestions.rows.map((question) => {
      return {
        ds_id: question.ds_id,
        denetim_id: question.denetim_id,
        soru_id: question.soru_id,
        soru: question.soru.soru_adi,
        verilen_cevap: question.cevap,
        dogru_cevap: question.soru.soru_cevap,
        soru_puan: question.soru.soru_puan,
      };
    });

    return res.status(200).send(modifiedData);
  } catch (error) {
    console.error("Get Inspection Questions Error:", error);
    return res.status(500).send(error);
  }
});

module.exports = router;
