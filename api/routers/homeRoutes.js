const express = require("express");
const router = express.Router();
const Joi = require("joi");
const { Op } = require("sequelize");
const authenticateToken = require("../middlewares/authentication");
const { initializeSequelize } = require("../helpers/sequelize");
const {
  denetim,
  denetim_tipi,
  magaza,
  kullanici,
  denetim_sorulari,
  soru,
} = require("../helpers/sequelizemodels");

// ID'si verilen kullanıcının denetimlerininin
router.get(
  "/getInspectionCompletionStatus/:id",
  authenticateToken,
  async (req, res) => {
    try {
      const { id } = req.params;
      const sequelize = await initializeSequelize();
      const denetimModel = sequelize.define("denetim", denetim, {
        timestamps: false,
        freezeTableName: true,
      });

      const totalCount = await denetimModel.count({
        where: {
          denetci_id: id,
        },
      });

      const completedCount = await denetimModel.count({
        where: {
          denetci_id: id,
          status: 0,
        },
      });

      const completionPercentage = ((completedCount / totalCount) * 100).toFixed( 2 );


      return res
        .status(200)
        .send({ completedCount, totalCount, completionPercentage });
    } catch (error) {
      console.error(error);
      return res.status(500).send(error);
    }
  }
);

// ID'si verilen kullanıcının son 3 denetimini getirir.
router.get(
  "/getLastThreeInspections/:id",
  authenticateToken,
  async (req, res) => {
    try {
      const { id } = req.params;
      const sequelize = await initializeSequelize();
      const denetimModel = sequelize.define("denetim", denetim, {
        timestamps: false,
        freezeTableName: true,
      });
      const magazaModel = sequelize.define("magaza", magaza, {
        timestamps: false,
        freezeTableName: true,
      });

      const denetimeTipiModel = sequelize.define("denetim_tipi", denetim_tipi, {
        timestamps: false,
        freezeTableName: true,
      });
      const kullaniciModel = sequelize.define("kullanici", kullanici, {
        timestamps: false,
        freezeTableName: true,
      });

      denetimModel.belongsTo(kullaniciModel, { foreignKey: "denetci_id" });
      denetimModel.belongsTo(magazaModel, { foreignKey: "magaza_id" });
      denetimModel.belongsTo(denetimeTipiModel, {
        foreignKey: "denetim_tipi_id",
      });

      const lastFiveInspections = await denetimModel.findAll({
        where: {
          denetci_id: id,
        },
        include: [
          {
            model: kullaniciModel,
            attributes: ["ad", "soyad"],
          },
          {
            model: magazaModel,
            attributes: ["magaza_adi"],
          },
          {
            model: denetimeTipiModel,
            attributes: ["denetim_tipi"],
          },
        ],
        order: [["denetim_tarihi", "DESC"]],
        limit: 3,
      });

      if (lastFiveInspections.length === 0)
        return res
          .status(200)
          .send([]);

      const modifiedLastFiveInspections = lastFiveInspections.map(
        (inspection) => {
          return {
            id: inspection.id,
            denetci: inspection.kullanici.ad + " " + inspection.kullanici.soyad,
            magaza: inspection.magaza.magaza_adi,
            denetim_tipi: inspection.denetim_tipi.denetim_tipi,
            denetim_tarihi: inspection.denetim_tarihi,
            status: inspection.status,
            alinan_puan: inspection.alinan_puan ? inspection.alinan_puan : "-",
          };
        }
      );

      return res.status(200).send(modifiedLastFiveInspections);
    } catch (error) {
      console.error(error);
      return res.status(500).send(error);
    }
  }
);

// 3 ve 3den FAZLA YANLIŞ YAPILAN SORULARI LİSTELER
router.get(
  "/getFrequentlyWrongQuestions",
  authenticateToken,
  async (req, res) => {
    try {
      const sequelize = await initializeSequelize();

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

      const denetimTipiModel = sequelize.define("denetim_tipi", denetim_tipi, {
        timestamps: false,
        freezeTableName: true,
      });

      denetimSorulariModel.belongsTo(soruModel, {
        foreignKey: "soru_id",
        targetKey: "soru_id",
      });

      soruModel.hasMany(denetimSorulariModel, {
        foreignKey: "soru_id",
        sourceKey: "soru_id",
      });
      soruModel.belongsTo(denetimTipiModel, {
        foreignKey: "denetim_tip_id",
        targetKey: "denetim_tip_id",
      });

      const frequentlyWrongQuestions = await denetimSorulariModel.findAll({
        attributes: [
          "soru_id",
          [sequelize.fn("COUNT", sequelize.col("soru_id")), "question_count"],
        ],
        where: {
          cevap: {
            [Op.ne]: sequelize.col("dogru_cevap"),
          },
        },
        group: ["soru_id"],
        having: sequelize.where(sequelize.literal("COUNT(soru_id)"), ">", 2),
        order: [[sequelize.literal("question_count"), "DESC"]],
      });

      if (!frequentlyWrongQuestions || frequentlyWrongQuestions.length === 0)
        return res.status(404).send("Kronik yanlış soru bulunamadı.");

      const frequentlyWrongQuestionsWithNames = await Promise.all(
        frequentlyWrongQuestions.map(async (question) => {
          const soru = await soruModel.findOne({
            where: {
              soru_id: question.soru_id,
            },
            attributes: ["soru_adi", "denetim_tip_id"],
            include: [
              {
                model: denetimTipiModel,
                attributes: ["denetim_tipi"],
              },
            ],
          });
          return {
            soru_id: question.soru_id,
            soru_adi: soru.soru_adi,
            question_count: question.dataValues.question_count,
            denetim_tip_id: soru.denetim_tip_id,
            denetim_tipi: soru.denetim_tipi.denetim_tipi,
          };
        })
      );
      const groupedQuestions = frequentlyWrongQuestionsWithNames.reduce(
        (acc, question) => {
          if (acc.hasOwnProperty(question.denetim_tip_id)) {
            acc[question.denetim_tip_id].push(question);
          } else {
            acc[question.denetim_tip_id] = [question];
          }
          return acc;
        },
        {}
      );

      // Şimdi ise bu gruplanmış veriyi istediğiniz formatta bir array'e dönüştürelim.
      const groupedQuestionsArray = Object.keys(groupedQuestions).map(
        (denetim_tip_id) => {
          return {
            denetim_tipi: groupedQuestions[denetim_tip_id][0].denetim_tipi, // İlk öğeden alıyoruz, diğerleri aynı olacak zaten.
            questions: groupedQuestions[denetim_tip_id],
          };
        }
      );

      // Şimdi bu gruplanmış veriyi döndürebiliriz.
      return res.status(200).send(groupedQuestionsArray);
    } catch (error) {
      console.error("Get Frequently Wrong Questions Error:", error);
      return res.status(500).send(error);
    }
  }
);

//  Mağaza Sayılarını (aktif pasif total) Sayısını Getirir
router.get("/getAllStoreCount", authenticateToken, async (req, res) => {
  try {
    const sequelize = await initializeSequelize();
    const magazaModel = sequelize.define("magaza", magaza, {
      timestamps: false,
      freezeTableName: true,
    });

    const activStoreCount = await magazaModel.count({
      where: {
        status: 1,
      },
    });
    const inactiveStoreCount = await magazaModel.count({
      where: {
        status: 0,
      },
    });

    const totalStoreCount = await magazaModel.count();

    return res
      .status(200)
      .send({ activStoreCount, inactiveStoreCount, totalStoreCount });
  } catch (error) {
    console.error("Get Active Store Count Error:", error);
    return res.status(500).send(error);
  }
});




module.exports = router;
