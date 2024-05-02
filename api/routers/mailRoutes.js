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
  mail,
  unvanDenetimTipiLink,
  denetim,
  magaza
} = require("../helpers/sequelizemodels");
const { sendMail } = require("../helpers/mailer");

// Unvan ve Denetim Tipi Linkleme
router.post("/linkUnvanDenetimTipi", authenticateToken, async (req, res) => {
  try {
    const schema = Joi.object({
      unvan_id: Joi.number().required(),
      denetim_tip_id: Joi.number().required(),
    });

    const { error } = schema.validate(req.body);
    if (error) return res.status(400).send(error.details[0].message);

    const { unvan_id, denetim_tip_id } = req.body;

    const sequelize = await initializeSequelize();
    const unvanDenetimTipiLinkModel = sequelize.define(
      "unvanDenetimTipiLink",
      unvanDenetimTipiLink,
      {
        timestamps: false,
        freezeTableName: true,
      }
    );

    const linkUnvanDenetimTipi = await unvanDenetimTipiLinkModel.create({
      unvan_id,
      denetim_tip_id,
    });

    return res.status(200).send(linkUnvanDenetimTipi);
  } catch (error) {
    console.error("Link Unvan Denetim Tipi Error:", error);
    return res.status;
  }
});

// Unvan ve Denetim Tipine göre Kullaniciları Listeleme
router.get(
  "/getAllUsersByRelatedUnvan",
  authenticateToken,
  async (req, res) => {
    try {
      const sequelize = await initializeSequelize();
      const mailModel = sequelize.define("mail", mail, {
        timestamps: false,
        freezeTableName: true,
      });

      const unvanModel = sequelize.define("unvan", unvan, {
        timestamps: false,
        freezeTableName: true,
      });

      const denetimTipiModel = sequelize.define("denetim_tipi", denetim_tipi, {
        timestamps: false,
        freezeTableName: true,
      });

      const kullaniciModel = sequelize.define("kullanici", kullanici, {
        timestamps: false,
        freezeTableName: true,
      });

      const unvanDenetimTipiLinkModel = sequelize.define(
        "unvanDenetimTipiLink",
        unvanDenetimTipiLink,
        {
          timestamps: false,
          freezeTableName: true,
        }
      );

      unvanModel.hasMany(unvanDenetimTipiLinkModel, {
        foreignKey: "unvan_id",
      });
      denetimTipiModel.hasMany(unvanDenetimTipiLinkModel, {
        foreignKey: "denetim_tip_id",
      });

      unvanDenetimTipiLinkModel.belongsTo(unvanModel, {
        foreignKey: "unvan_id",
      });
      unvanDenetimTipiLinkModel.belongsTo(denetimTipiModel, {
        foreignKey: "denetim_tip_id",
      });

      mailModel.belongsTo(denetimTipiModel, {
        foreignKey: "denetim_tip_id",
      });

      mailModel.belongsTo(kullaniciModel, {
        foreignKey: "kullanici_id",
      });

      mailModel.belongsTo(kullaniciModel, {
        foreignKey: "ekleyen_id",
      });

      mailModel.belongsTo(kullaniciModel, {
        foreignKey: "guncelleyen_id",
      });

      unvanModel.belongsTo(kullaniciModel, {
        foreignKey: "unvan_id",
      });
      const findDenetimTipiByUnvan = await unvanModel.findAll({
        include: [
          {
            model: unvanDenetimTipiLinkModel,
            include: [
              {
                model: denetimTipiModel,
                attributes: ["denetim_tip_id", "denetim_tipi"],
              },
            ],
          },
        ],
        attributes: ["unvan_id", "unvan_adi"],
      });
      const findAllKullanici = await kullaniciModel.findAll({
        attributes: ["id", "ad", "soyad", "eposta", "unvan_id"],
      });

      const modifiedData = findDenetimTipiByUnvan.map((item) => {
        const denetimTipi = item.unvanDenetimTipiLinks.map((item) => {
          return item.denetim_tipi;
        });
        return {
          unvan_id: item.unvan_id,
          unvan_adi: item.unvan_adi,
          denetim_tipi: denetimTipi,
          kullanici: findAllKullanici.filter(
            (kullanici) => kullanici.unvan_id === item.unvan_id
          ),
        };
      });

      return res.status(200).send(modifiedData);
    } catch (error) {
      console.error("Add Title Error:", error);
      return res.status(500).send(error);
    }
  }
);

router.get(
  "/getAllUsersByRelatedDenetimTipi",
  authenticateToken,
  async (req, res) => {
    try {
      const sequelize = await initializeSequelize();
      const mailModel = sequelize.define("mail", mail, {
        timestamps: false,
        freezeTableName: true,
      });

      const unvanModel = sequelize.define("unvan", unvan, {
        timestamps: false,
        freezeTableName: true,
      });

      const denetimTipiModel = sequelize.define("denetim_tipi", denetim_tipi, {
        timestamps: false,
        freezeTableName: true,
      });

      const kullaniciModel = sequelize.define("kullanici", kullanici, {
        timestamps: false,
        freezeTableName: true,
      });

      const unvanDenetimTipiLinkModel = sequelize.define(
        "unvanDenetimTipiLink",
        unvanDenetimTipiLink,
        {
          timestamps: false,
          freezeTableName: true,
        }
      );

      unvanModel.hasMany(unvanDenetimTipiLinkModel, {
        foreignKey: "unvan_id",
      });
      denetimTipiModel.hasMany(unvanDenetimTipiLinkModel, {
        foreignKey: "denetim_tip_id",
      });

      unvanDenetimTipiLinkModel.belongsTo(unvanModel, {
        foreignKey: "unvan_id",
      });
      unvanDenetimTipiLinkModel.belongsTo(denetimTipiModel, {
        foreignKey: "denetim_tip_id",
      });

      mailModel.belongsTo(denetimTipiModel, {
        foreignKey: "denetim_tip_id",
      });

      mailModel.belongsTo(kullaniciModel, {
        foreignKey: "kullanici_id",
      });

      mailModel.belongsTo(kullaniciModel, {
        foreignKey: "ekleyen_id",
      });

      mailModel.belongsTo(kullaniciModel, {
        foreignKey: "guncelleyen_id",
      });

      denetimTipiModel.belongsTo(kullaniciModel, {
        foreignKey: "denetim_tip_id",
      });

      const findDenetimTipiByUnvan = await denetimTipiModel.findAll({
        include: [
          {
            model: unvanDenetimTipiLinkModel,
            include: [
              {
                model: unvanModel,
                attributes: ["unvan_id", "unvan_adi"],
              },
            ],
          },
        ],
        attributes: ["denetim_tip_id", "denetim_tipi"],
      });
      const findAllKullanici = await kullaniciModel.findAll({
        attributes: ["id", "ad", "soyad", "eposta", "unvan_id"],
      });

      const modifiedData = findDenetimTipiByUnvan.map((item) => {
        const unvan = item.unvanDenetimTipiLinks.map((item) => {
          return item.unvan;
        });
        return {
          denetim_tip_id: item.denetim_tip_id,
          denetim_tipi: item.denetim_tipi,
          unvan: unvan,
          kullanici: findAllKullanici.filter(
            (kullanici) => kullanici.unvan_id === item.denetim_tip_id
          ),
        };
      });

      return res.status(200).send(modifiedData);
    } catch (error) {
      console.error("Add Title Error:", error);
      return res.status.send(error);
    }
  }
);

// Denetim Tipine Göre Mail Ayarlarını Listeleme
router.post(
  "/mailSetingsByDenetimTipi",
  authenticateToken,
  async (req, res) => {
    try {
      const schema = Joi.object({
        denetim_tip_id: Joi.number().required(),
        kullanici_id: Joi.number().required(),
      });

      const { error } = schema.validate(req.body);
      if (error) return res.status(400).send(error.details[0].message);

      const { denetim_tip_id, kullanici_id } = req.body;

      const sequelize = await initializeSequelize();
      const mailModel = sequelize.define("mail", mail, {
        timestamps: false,
        freezeTableName: true,
      });
      const mailSettings = await mailModel.create({
        denetim_tip_id,
        kullanici_id,
        ekleyen_id: req.user.id,
        status: 1,
      });

      return res.status(200).send(mailSettings);
    } catch (error) {
      console.error("Mail Settings Error:", error);
      return res.status(500).send(error);
    }
  }
);

// MAİL GÖNDERME ENDPOINTİ
router.post("/sendEmail", async (req, res) => {
  try {
    const schema = Joi.object({
      denetim_id: Joi.number().required(),
    });

    const { error } = schema.validate(req.body);
    if (error) return res.status(400).send(error.details[0].message);
    const { denetim_id } = req.body;

    const sequelize = await initializeSequelize();

    const kullaniciModel = sequelize.define("kullanici", kullanici, {
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

    const magazaModel = sequelize.define("magaza", magaza, {
      timestamps: false,
      freezeTableName: true,
    });

    const unvanDenetimTipiLinkModel = sequelize.define(
      "unvanDenetimTipiLink",
      unvanDenetimTipiLink,
      {
        timestamps: false,
        freezeTableName: true,
      }
    );

    denetimModel.belongsTo(magazaModel, {
      foreignKey: "magaza_id",
    });

    denetimModel.belongsTo(denetimTipiModel, {
      foreignKey: "denetim_tipi_id",
    });


    const getDenetim = await denetimModel.findOne({
      where: {
        denetim_id,
      },
    });

    if (!getDenetim) return res.status(404).send("Denetim bulunamadı.");

    const findAllUnvanId = await unvanDenetimTipiLinkModel.findAll({
      where: {
        denetim_tip_id: getDenetim.denetim_tipi_id,
      },
    });

    const findAllMail = findAllUnvanId.map((item) => {
      return item.unvan_id;
    });

    const findAllUsersRelatedUnvan = await kullaniciModel.findAll({
      where: {
        unvan_id: findAllMail,
        status:1
      },
      attributes: ["id", "ad", "soyad", "eposta","unvan_id"],
      order: [["unvan_id", "ASC"]],
    });

    const findMagaza = await magazaModel.findOne({
      where: {
        magaza_id: getDenetim.magaza_id
      }
    });

    const storeManagerMail = await kullaniciModel.findOne({
      where: {
        id: findMagaza.magaza_muduru,
      },
      attributes: ["eposta"],
    });
    console.log("storeManagerMail", storeManagerMail.eposta);
    return

    const mailOptions = {
      from: {
        name: "Denetim Bilgilendirme",
        address: "sunteks64039@gmail.com"
      },
      to: [findAllUsersRelatedUnvan.map((item) => item.eposta).join(",")],
      subject: "Denetim Bilgilendirme",
      text: `Merhaba, ${getDenetim.denetim_tipi_id} tipinde bir denetim yapılmıştır.`,
      // attachments: [
      //   {
      //     filename: "denetim.pdf",
      //     path: "http://localhost:3000/denetim.pdf",
      //     contentType: "application/pdf",
      //   },
      // ], 
    };


    return res.status(200).send(await sendMail(mailOptions));
  } catch (error) {
    console.error("Mail gönderme hatası:", error);
    return res.status(500).send("Mail gönderme hatası.");
  }
});

module.exports = router;
