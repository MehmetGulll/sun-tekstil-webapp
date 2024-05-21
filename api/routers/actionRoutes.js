const express = require("express");
const router = express.Router();
const Joi = require("joi");
const { Op } = require("sequelize");
const authenticateToken = require("../middlewares/authentication");
const { initializeSequelize } = require("../helpers/sequelize");
const {
  aksiyon,
  denetim_sorulari,
  denetim,
  magaza,
  kullanici,
  soru,
  image,
} = require("../helpers/sequelizemodels");

// TÜM AKSİYONLARI LİSTELER, KULLANICI ID Sİ MAĞAZA MÜDÜRÜNE AİT OLAN AKSİYONLARI LİSTELER
router.post(
  "/getAllActionStoreManager",
  authenticateToken,
  async (req, res) => {
    try {
      const paginationSchema = Joi.object({
        page: Joi.number().integer().min(1).default(1),
        perPage: Joi.number().integer().min(1).default(10),
        searchTerm: Joi.string().optional(),
        startDate: Joi.string().optional(),
        endDate: Joi.string().optional(),
      });

      const { error, value } = paginationSchema.validate(req.body);

      if (error) {
        return res.status(400).send(error.details[0].message);
      }

      let { page, perPage, searchTerm, startDate, endDate } = value;
      const offset = (page - 1) * perPage;

      const sequelize = await initializeSequelize();

      const aksiyonModel = sequelize.define("aksiyon", aksiyon, {
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

      const denetimModel = sequelize.define("denetim", denetim, {
        timestamps: false,
        freezeTableName: true,
      });

      const magazaModel = sequelize.define("magaza", magaza, {
        timestamps: false,
        freezeTableName: true,
      });

      const kullaniciModel = sequelize.define("kullanici", kullanici, {
        timestamps: false,
        freezeTableName: true,
      });

      const soruModel = sequelize.define("soru", soru, {
        timestamps: false,
        freezeTableName: true,
      });

      const imageModel = sequelize.define("image", image, {
        timestamps: false,
        freezeTableName: true,
      });

      denetimSorulariModel.belongsTo(soruModel, {
        foreignKey: "soru_id",
        as: "soru",
      });

      aksiyonModel.belongsTo(denetimSorulariModel, {
        foreignKey: "ds_id",
        as: "denetim_sorulari",
      });

      denetimSorulariModel.belongsTo(denetimModel, {
        foreignKey: "denetim_id",
        as: "denetim",
      });

      denetimModel.belongsTo(magazaModel, {
        foreignKey: "magaza_id",
        as: "magaza",
      });

      magazaModel.belongsTo(kullaniciModel, {
        foreignKey: "magaza_muduru",
        as: "kullanici",
      });

      aksiyonModel.belongsTo(imageModel, {
        foreignKey: "aksiyon_gorsel",
        as: "image",
      });

      const whereCondition = {};
      const formatDate = (date) => {
        const [day, month, year] = date.split(".");
        return `${year}-${month.padStart(2, "0")}-${day.padStart(2, "0")}`;
      };

      if (searchTerm) {
        whereCondition.aksiyon_konu = { [Op.like]: `%${searchTerm}%` };
      }

      if (startDate && endDate) {
        whereCondition.aksiyon_acilis_tarihi = {
          [Op.between]: [formatDate(startDate), formatDate(endDate)],
        };
      } else if (startDate) {
        whereCondition.aksiyon_acilis_tarihi = {
          [Op.gte]: formatDate(startDate),
        };
      } else if (endDate) {
        whereCondition.aksiyon_acilis_tarihi = {
          [Op.lte]: formatDate(endDate),
        };
      }

      const { rows: allAction, count } = await aksiyonModel.findAndCountAll({
        where: whereCondition,
        include: [
          {
            model: denetimSorulariModel,
            as: "denetim_sorulari",
            include: [
              {
                model: denetimModel,
                as: "denetim",
                include: [
                  {
                    model: magazaModel,
                    as: "magaza",
                    include: [
                      {
                        model: kullaniciModel,
                        as: "kullanici",
                      },
                    ],
                  },
                ],
              },
              {
                model: soruModel,
                as: "soru",
              },
            ],
          },
          {
            model: imageModel,
            as: "image",
          },
        ],
        offset: offset,
        limit: perPage,
        order: [
          ["status", "DESC"],
          ["aksiyon_oncelik", "DESC"],
          ["aksiyon_acilis_tarihi", "ASC"],
        ],
      });

      if (!allAction || allAction.length === 0) {
        return res.status(404).send("Aksiyon Bulunamadi!");
      }

      const convertDate = (date) => {
        const newDate = new Date(date);
        return newDate.toLocaleDateString();
      };


      const modifiedData = await Promise.all(
        allAction
          .filter((item) => {
            return (
              item.denetim_sorulari.denetim.magaza &&
              item.denetim_sorulari.denetim.magaza.magaza_muduru === req.user.id
            );
          })
          .map(async (item) => {
            const user = await kullaniciModel.findOne({
              where: { id: item.aksiyon_olusturan_id },
            });
      
            return {
              aksiyon_id: item.aksiyon_id,
              aksiyon_konu: item.aksiyon_konu,
              aksiyon_acilis_tarihi: convertDate(item.aksiyon_acilis_tarihi),
              aksiyon_bitis_tarihi: item.aksiyon_bitis_tarihi
                ? convertDate(item.aksiyon_bitis_tarihi)
                : null,
              aksiyon_sure: item.aksiyon_sure,
              aksiyon_oncelik: item.aksiyon_oncelik,
              aksiyon_olusturan_id: user
                ? user.ad + " " + user.soyad
                : "Kullanıcı Bulunamadı",
              aksiyon_gorsel: item.image
                ? process.env.CDN_URL + item.image.public_id
                : null,
              aksiyon_kapatan_id: item.aksiyon_kapatan_id
                ? item.aksiyon_kapatan_id
                : "Aksiyon Kapatılmamış",
              denetim_tip_id: item.denetim_sorulari.denetim.denetim_tip_id,
              magaza_id: item.denetim_sorulari.denetim.magaza_id,
              magaza_adi: item.denetim_sorulari.denetim.magaza
                ? item.denetim_sorulari.denetim.magaza.magaza_adi
                : null,
              magaza_muduru:
                item.denetim_sorulari.denetim.magaza &&
                item.denetim_sorulari.denetim.magaza.kullanici
                  ? item.denetim_sorulari.denetim.magaza.kullanici.ad +
                    " " +
                    item.denetim_sorulari.denetim.magaza.kullanici.soyad
                  : null,
              aksiyon_soru_id: item.denetim_sorulari.soru_id,
              aksiyon_sorusu: item.denetim_sorulari.soru.soru_adi,
              soru_dogru_cevap:
                item.denetim_sorulari.dogru_cevap === 1 ? "Evet" : "Hayır",
              soru_verilen_cevap:
                item.denetim_sorulari.cevap === 1 ? "Evet" : "Hayır",
              aksiyon_kapama_konu: item.aksiyon_kapama_konu,
              status: item.status,
            };
          })
      );
      

      return res.status(200).send({
        data: modifiedData,
        count: modifiedData.length,
        page: page,
        perPage: perPage,
      });
    } catch (error) {
      console.error("Get All Action Error:", error);
      return res.status(500).send(error);
    }
  }
);

// Magaza müdürüne aksiyonlarını gösterme
router.post("/viewAllAction", authenticateToken, async (req, res) => {
  try {
    const paginationSchema = Joi.object({
      page: Joi.number().integer().min(1).default(1),
      perPage: Joi.number().integer().min(1).default(10),
      searchTerm: Joi.string().optional(),
      startDate: Joi.string().optional(),
      endDate: Joi.string().optional(),
    });

    const { error, value } = paginationSchema.validate(req.body);

    if (error) {
      return res.status(400).send(error.details[0].message);
    }

    let { page, perPage, searchTerm, startDate, endDate } = value;
    const offset = (page - 1) * perPage;

    const sequelize = await initializeSequelize();

    const aksiyonModel = sequelize.define("aksiyon", aksiyon, {
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

    const denetimModel = sequelize.define("denetim", denetim, {
      timestamps: false,
      freezeTableName: true,
    });

    const magazaModel = sequelize.define("magaza", magaza, {
      timestamps: false,
      freezeTableName: true,
    });

    const kullaniciModel = sequelize.define("kullanici", kullanici, {
      timestamps: false,
      freezeTableName: true,
    });

    const soruModel = sequelize.define("soru", soru, {
      timestamps: false,
      freezeTableName: true,
    });

    const imageModel = sequelize.define("image", image, {
      timestamps: false,
      freezeTableName: true,
    });

    denetimSorulariModel.belongsTo(soruModel, {
      foreignKey: "soru_id",
      as: "soru",
    });

    aksiyonModel.belongsTo(denetimSorulariModel, {
      foreignKey: "ds_id",
      as: "denetim_sorulari",
    });

    denetimSorulariModel.belongsTo(denetimModel, {
      foreignKey: "denetim_id",
      as: "denetim",
    });

    denetimModel.belongsTo(magazaModel, {
      foreignKey: "magaza_id",
      as: "magaza",
    });

    magazaModel.belongsTo(kullaniciModel, {
      foreignKey: "magaza_muduru",
      as: "kullanici",
    });

    aksiyonModel.belongsTo(imageModel, {
      foreignKey: "aksiyon_gorsel",
      as: "image",
    });

    const whereCondition = {};
    const formatDate = (date) => {
      const [day, month, year] = date.split(".");
      return `${year}-${month.padStart(2, "0")}-${day.padStart(2, "0")}`;
    };

    if (searchTerm) {
      whereCondition.aksiyon_konu = {
        [Op.like]: `%${searchTerm}%`,
      };
    }

    if (startDate && endDate) {
      whereCondition.aksiyon_acilis_tarihi = {
        [Op.between]: [formatDate(startDate), formatDate(endDate)],
      };
    } else if (startDate) {
      whereCondition.aksiyon_acilis_tarihi = {
        [Op.gte]: formatDate(startDate),
      };
    } else if (endDate) {
      whereCondition.aksiyon_acilis_tarihi = {
        [Op.lte]: formatDate(endDate),
      };
    }

    const { rows: myAction, count } = await aksiyonModel.findAndCountAll({
      where: whereCondition,
      include: [
        {
          model: denetimSorulariModel,
          as: "denetim_sorulari",
          include: [
            {
              model: denetimModel,
              as: "denetim",
              include: [
                {
                  model: magazaModel,
                  as: "magaza",
                  include: [
                    {
                      model: kullaniciModel,
                      as: "kullanici",
                    },
                  ],
                },
              ],
            },
            {
              model: soruModel,
              as: "soru",
            },
          ],
        },
        {
          model: imageModel,
          as: "image",
        },
      ],
      offset: offset,
      limit: perPage,
      order: [
        ["status", "DESC"],
        ["aksiyon_oncelik", "DESC"],
        ["aksiyon_acilis_tarihi", "ASC"],
      ],
    });

    if (!myAction || myAction.length === 0) {
      return res.status(404).send("Aksiyon Bulunamadi!");
    }

    const convertDate = (date) => {
      const newDate = new Date(date);
      return newDate.toLocaleDateString();
    };

    const modifiedData = await Promise.all(
      myAction.map(async (item) => {
        const user = await kullaniciModel.findOne({
          where: { id: item.aksiyon_olusturan_id },
        });
        const findAllMagaza = await magazaModel.findOne({
          where: {
            magaza_id: item.denetim_sorulari.denetim.magaza_id,
          },
          include: [
            {
              model: kullaniciModel,
              as: "kullanici",
            },
          ],
        });

        return {
          aksiyon_id: item.aksiyon_id,
          aksiyon_konu: item.aksiyon_konu,
          aksiyon_acilis_tarihi: convertDate(item.aksiyon_acilis_tarihi),
          aksiyon_bitis_tarihi: item.aksiyon_bitis_tarihi
            ? convertDate(item.aksiyon_bitis_tarihi)
            : null,
          aksiyon_sure: item.aksiyon_sure,
          aksiyon_oncelik: item.aksiyon_oncelik,
          aksiyon_olusturan_id: user
            ? user.ad + " " + user.soyad
            : "Kullanıcı Bulunamadı",
          aksiyon_gorsel: item.image
            ? process.env.CDN_URL + item.image.public_id
            : null,
          aksiyon_kapatan_id: item.aksiyon_kapatan_id
            ? item.aksiyon_kapatan_id
            : "Aksiyon Kapatılmamış",
          denetim_tip_id: item.denetim_sorulari.denetim.denetim_tip_id,
          magaza_id: item.denetim_sorulari.denetim.magaza_id,
          magaza_adi: findAllMagaza.magaza_adi,
          magaza_muduru:
            findAllMagaza.kullanici.ad + " " + findAllMagaza.kullanici.soyad,
          aksiyon_soru_id: item.denetim_sorulari.soru_id,
          aksiyon_sorusu: item.denetim_sorulari.soru.soru_adi,
          soru_dogru_cevap:
            item.denetim_sorulari.dogru_cevap === 1 ? "Evet" : "Hayır",
          soru_verilen_cevap:
            item.denetim_sorulari.cevap === 1 ? "Evet" : "Hayır",
          aksiyon_kapama_konu: item.aksiyon_kapama_konu,
          status: item.status,
        };
      })
    );

    return res
      .status(200)
      .send({ data: modifiedData, count: count, page: page, perPage: perPage });
  } catch (error) {
    console.error("Get My Action Error:", error);
    return res.status(500).send(error);
  }
});

// Aksiyonu açan kişiye ait aksiyonları listeler
router.post("/getMyCreatedAction", authenticateToken, async (req, res) => {
  try {
    const paginationSchema = Joi.object({
      page: Joi.number().integer().min(1).default(1),
      perPage: Joi.number().integer().min(1).default(10),
      searchTerm: Joi.string().optional(),
      startDate: Joi.string().optional(),
      endDate: Joi.string().optional(),
    });

    const { error, value } = paginationSchema.validate(req.body);

    if (error) return res.status(400).send(error.details[0].message);

    let { page, perPage, searchTerm, startDate, endDate } = value;
    const offset = (page - 1) * perPage;

    const sequelize = await initializeSequelize();

    const aksiyonModel = sequelize.define("aksiyon", aksiyon, {
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

    const denetimModel = sequelize.define("denetim", denetim, {
      timestamps: false,
      freezeTableName: true,
    });

    const magazaModel = sequelize.define("magaza", magaza, {
      timestamps: false,
      freezeTableName: true,
    });

    const kullaniciModel = sequelize.define("kullanici", kullanici, {
      timestamps: false,
      freezeTableName: true,
    });

    const soruModel = sequelize.define("soru", soru, {
      timestamps: false,
      freezeTableName: true,
    });

    const imageModel = sequelize.define("image", image, {
      timestamps: false,
      freezeTableName: true,
    });

    denetimSorulariModel.belongsTo(soruModel, {
      foreignKey: "soru_id",
      as: "soru",
    });

    aksiyonModel.belongsTo(denetimSorulariModel, {
      foreignKey: "ds_id",
      as: "denetim_sorulari",
    });

    denetimSorulariModel.belongsTo(denetimModel, {
      foreignKey: "denetim_id",
      as: "denetim",
    });

    denetimModel.belongsTo(magazaModel, {
      foreignKey: "magaza_id",
      as: "magaza",
    });

    magazaModel.belongsTo(kullaniciModel, {
      foreignKey: "magaza_muduru",
      as: "kullanici",
    });

    aksiyonModel.belongsTo(imageModel, {
      foreignKey: "aksiyon_gorsel",
      as: "image",
    });

    const whereCondition = { aksiyon_olusturan_id: req.user.id };
    const formatDate = (date) => {
      const [day, month, year] = date.split(".");
      return `${year}-${month.padStart(2, "0")}-${day.padStart(2, "0")}`;
    };

    if (searchTerm) {
      whereCondition.aksiyon_konu = {
        [Op.like]: `%${searchTerm}%`,
      };

      whereCondition.aksiyon_olusturan_id = req.user.id;
    }

    if (startDate && endDate) {
      whereCondition.aksiyon_acilis_tarihi = {
        [Op.between]: [formatDate(startDate), formatDate(endDate)],
      };

      whereCondition.aksiyon_olusturan_id = req.user.id;
    } else if (startDate) {
      whereCondition.aksiyon_acilis_tarihi = {
        [Op.gte]: formatDate(startDate),
      };

      whereCondition.aksiyon_olusturan_id = req.user.id;
    } else if (endDate) {
      whereCondition.aksiyon_acilis_tarihi = {
        [Op.lte]: formatDate(endDate),
      };

      whereCondition.aksiyon_olusturan_id = req.user.id;
    }

    const { rows: myAction, count } = await aksiyonModel.findAndCountAll({
      where: whereCondition,
      include: [
        {
          model: denetimSorulariModel,
          as: "denetim_sorulari",
          include: [
            {
              model: denetimModel,
              as: "denetim",
              include: [
                {
                  model: magazaModel,
                  as: "magaza",
                  include: [
                    {
                      model: kullaniciModel,
                      as: "kullanici",
                    },
                  ],
                },
              ],
            },
            {
              model: soruModel,
              as: "soru",
            },
          ],
        },
        {
          model: imageModel,
          as: "image",
        },
      ],
      offset: offset,
      limit: perPage,
      order: [
        ["status", "DESC"],
        ["aksiyon_oncelik", "ASC"],
        ["aksiyon_acilis_tarihi", "ASC"],
      ],
    });

    if (!myAction || myAction.length === 0) {
      return res.status(404).send("Aksiyon Bulunamadi!");
    }

    const convertDate = (date) => {
      const newDate = new Date(date);
      return newDate.toLocaleDateString();
    };

    const modifiedData = await Promise.all(
      myAction.map(async (item) => {
        const user = await kullaniciModel.findOne({
          where: { id: item.aksiyon_olusturan_id },
        });

        return {
          aksiyon_id: item.aksiyon_id,
          aksiyon_konu: item.aksiyon_konu,
          aksiyon_acilis_tarihi: convertDate(item.aksiyon_acilis_tarihi),
          aksiyon_bitis_tarihi: item.aksiyon_bitis_tarihi
            ? convertDate(item.aksiyon_bitis_tarihi)
            : null,
          aksiyon_sure: item.aksiyon_sure,
          aksiyon_oncelik: item.aksiyon_oncelik,
          aksiyon_olusturan_id: user
            ? user.ad + " " + user.soyad
            : "Unknown User",
          aksiyon_gorsel: item.image
            ? process.env.CDN_URL + item.image.public_id
            : null,
          aksiyon_kapatan_id: item.aksiyon_kapatan_id
            ? item.aksiyon_kapatan_id
            : "Aksiyon Kapatılmamış",
          denetim_tip_id: item.denetim_sorulari.denetim.denetim_tip_id,
          magaza_id: item.denetim_sorulari.denetim.magaza_id,
          magaza_adi: item.denetim_sorulari.denetim.magaza.magaza_adi,
          magaza_muduru:
            item.denetim_sorulari.denetim.magaza.kullanici.ad +
            " " +
            item.denetim_sorulari.denetim.magaza.kullanici.soyad,
          aksiyon_soru_id: item.denetim_sorulari.soru_id,
          aksiyon_sorusu: item.denetim_sorulari.soru.soru_adi,
          soru_dogru_cevap:
            item.denetim_sorulari.dogru_cevap === 1 ? "Evet" : "Hayır",
          soru_verilen_cevap:
            item.denetim_sorulari.cevap === 1 ? "Evet" : "Hayır",
          aksiyon_kapama_konu: item.aksiyon_kapama_konu,
          status: item.status,
        };
      })
    );

    return res
      .status(200)
      .send({ data: modifiedData, count: count, page: page, perPage: perPage });
  } catch (error) {
    console.error("Get My Created Action Error:", error);
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
      aksiyon_kapama_konu: Joi.string().required(),
    }).validate(req.body);

    if (error) return res.status(400).send(error);
    const { aksiyon_id, aksiyon_kapama_konu } = value;

    const sequelize = await initializeSequelize();
    const aksiyonModel = sequelize.define("aksiyon", aksiyon, {
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

    const denetimModel = sequelize.define("denetim", denetim, {
      timestamps: false,
      freezeTableName: true,
    });

    const magazaModel = sequelize.define("magaza", magaza, {
      timestamps: false,
      freezeTableName: true,
    });

    const kullaniciModel = sequelize.define("kullanici", kullanici, {
      timestamps: false,
      freezeTableName: true,
    });

    aksiyonModel.belongsTo(denetimSorulariModel, {
      foreignKey: "ds_id",
      as: "denetim_sorulari",
    });

    denetimSorulariModel.belongsTo(denetimModel, {
      foreignKey: "denetim_id",
      as: "denetim",
    });

    denetimModel.belongsTo(magazaModel, {
      foreignKey: "magaza_id",
      as: "magaza",
    });

    magazaModel.belongsTo(kullaniciModel, {
      foreignKey: "magaza_muduru",
      as: "kullanici",
    });

    // aksiyonu açan kişi istek göndermiyor ise aksiyonu kapatamaz
    const isActionCreator = await aksiyonModel.findOne({
      where: {
        aksiyon_id: aksiyon_id,
        aksiyon_olusturan_id: req.user.id,
        status: 1,
      },
    });

    if (!isActionCreator)
      return res.status(400).send("Aksiyonu Sadece Açan Kişi Kapatabilir!");

    const isActionExist = await aksiyonModel.findOne({
      where: {
        aksiyon_id: aksiyon_id,
        status: 1,
      },
      include: [
        {
          model: denetimSorulariModel,
          as: "denetim_sorulari",
          include: [
            {
              model: denetimModel,
              as: "denetim",
              include: [
                {
                  model: magazaModel,
                  as: "magaza",
                  include: [
                    {
                      model: kullaniciModel,
                      as: "kullanici",
                    },
                  ],
                },
              ],
            },
          ],
        },
      ],
    });

    if (!isActionExist) return res.status(400).send("Aksiyon Bulunamadı!");

    // const storeManagerId =
    //   isActionExist.denetim_sorulari.denetim.magaza.kullanici.id;

    // if (req.user.id !== storeManagerId) {
    //   return res.status(400).send("Aksiyonu Sadece Magaza Müdürü Kapatabilir!");
    // }
    
    if(req.user.id !== isActionExist.aksiyon_olusturan_id) {
      return res.status(400).send("Aksiyonu sadece açan kişi kapatabilir!");
    }

    if (isActionExist.status === 0) {
      return res.status(400).send("Aksiyon zaten kapatılmış!");
    }

    // Update action
    const updatedAction = await aksiyonModel.update(
      {
        aksiyon_kapatan_id: req.user.id,
        aksiyon_bitis_tarihi: new Date().toISOString().slice(0, 10),
        aksiyon_kapama_konu: aksiyon_kapama_konu,
        status: 0,
      },
      {
        where: {
          aksiyon_id: aksiyon_id,
        },
      }
    );
    return res.status(200).send(updatedAction);
  } catch (error) {
    console.error("Close Action Error:", error);
    return res.status(500).send(error);
  }
});

module.exports = router;
