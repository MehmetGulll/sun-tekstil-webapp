const express = require("express");
const router = express.Router();
const Joi = require("joi");
const { Op } = require("sequelize");
const authenticateToken = require("../middlewares/authentication");
const { initializeSequelize } = require("../helpers/sequelize");
const { soru } = require("../helpers/sequelizemodels");

// TÜM SORULARI LİSTELER
router.post("/getAllQuestion", authenticateToken, async (req, res) => {
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
    const soruModel = sequelize.define("soru", soru, {
      timestamps: false,
      freezeTableName: true,
    });
    console.log("page", page);
    console.log("perPage", perPage);

    const { rows: allQuestion, count } = await soruModel.findAndCountAll({
      where: {
        status: 1,
      },
      offset: offset,
      limit: perPage,
    });

    if (!allQuestion || allQuestion.length === 0) {
      return res.status(404).send("Soru Bulunamadi!");
    }

    return res.status(200).send({
      questions: allQuestion,
      total: count,
      page: page,
      perPage: perPage,
    });
  } catch (error) {
    console.error("Get All Question Error:", error);
    return res.status(500).send(error);
  }
});

// YENİ SORU EKLER
router.post("/addQuestion", authenticateToken, async (req, res) => {
  try {
    const questionSchema = Joi.object({
      soru_adi: Joi.string().required(),
      soru_cevap: Joi.number().integer().required(),
      soru_puan: Joi.number().integer().required(),
      denetim_tip_id: Joi.number().integer().required(),
    });

    const { error, value } = questionSchema.validate(req.body);
    const { soru_adi, soru_cevap, soru_puan, denetim_tip_id, status } = value;

    if (error) {
      return res.status(400).send(error.details[0].message);
    }

    const sequelize = await initializeSequelize();
    const soruModel = sequelize.define("soru", soru, {
      timestamps: false,
      freezeTableName: true,
    });

    const calculatedSoruSiraNo = (await soruModel.max("soru_sira_no")) + 1;

    const newQuestion = await soruModel.create({
      soru_adi,
      soru_cevap,
      soru_sira_no: calculatedSoruSiraNo,
      soru_puan,
      denetim_tip_id,
      ekleyen_id: req.user.id,
      status: 1,
    });

    return res.status(201).send(newQuestion);
  } catch (error) {
    console.error("Add Question Error:", error);
    return res.status(500).send(error);
  }
});

// SORU GÜNCELLER
router.post("/updateQuestion", authenticateToken, async (req, res) => {
  try {
    if (req.user.rol_id !== 1 && req.user.rol_id !== 2) {
      return res.status(403).send("Soru güncelleme yetkiniz yok!");
    }

    const questionSchema = Joi.object({
      soru_id: Joi.number().integer().required(),
      soru_adi: Joi.string(),
      soru_cevap: Joi.number().integer(),
      soru_sira_no: Joi.number().integer(),
      soru_puan: Joi.number().integer(),
      denetim_tip_id: Joi.number().integer(),
      status: Joi.number().integer().valid(0, 1),
    });

    const { error, value } = questionSchema.validate(req.body);
    const {
      soru_id,
      soru_adi,
      soru_cevap,
      soru_sira_no,
      soru_puan,
      denetim_tip_id,
      status,
    } = value;

    if (error) {
      return res.status(400).send(error.details[0].message);
    }

    const sequelize = await initializeSequelize();
    const soruModel = sequelize.define("soru", soru, {
      timestamps: false,
      freezeTableName: true,
    });

    const findQuestion = await soruModel.findOne({
      where: {
        soru_id,
      },
    });

    if (!findQuestion) return res.status(404).send("Soru Bulunamadi!");

    if (findQuestion.soru_adi === soru_adi)
      return res.status(400).send("Soru adı aynı olduğu için güncelleme yapılamaz! Lütfen farklı bir değer giriniz!");

    if (findQuestion.soru_cevap === soru_cevap)
      return res.status(400).send("Soru cevap aynı olduğu için güncelleme yapılamaz! Lütfen farklı bir değer giriniz!");

    if (findQuestion.soru_puan === soru_puan)
      return res.status(400).send("Soru puan aynı olduğu için güncelleme yapılamaz! Lütfen farklı bir değer giriniz!");

    if (findQuestion.denetim_tip_id === denetim_tip_id)
      return res.status(400).send("Denetim tip id aynı olduğu için güncelleme yapılamaz! Lütfen farklı bir değer giriniz!");

    if (findQuestion.status === status)
      return res.status(400).send("Status aynı olduğu için güncelleme yapılamaz! Lütfen farklı bir değer giriniz!");

    const oldSoruSiraNo = findQuestion.soru_sira_no;
    const otherQuestions = await soruModel.findAll({
      where: {
        denetim_tip_id: findQuestion.denetim_tip_id,
        status: 1,
      },
    });

    const updatedQuestion = await findQuestion.update({
      soru_adi,
      soru_cevap,
      soru_sira_no,
      soru_puan,
      denetim_tip_id,
      status,
      guncelleyen_id: req.user.id,
    });

    if (soru_sira_no !== oldSoruSiraNo) {
      for (const question of otherQuestions) {
        if (question.soru_id !== updatedQuestion.soru_id) {
          let newSiraNo = question.soru_sira_no;
    
          if (oldSoruSiraNo < soru_sira_no) {
            if (
              question.soru_sira_no > oldSoruSiraNo &&
              question.soru_sira_no <= soru_sira_no
            ) {
              newSiraNo = question.soru_sira_no - 1;
            }
          } else {
            if (
              question.soru_sira_no < oldSoruSiraNo &&
              question.soru_sira_no >= soru_sira_no
            ) {
              newSiraNo = question.soru_sira_no + 1;
            }
          }
    
          await question.update({
            soru_sira_no: newSiraNo,
          });
        }
      }
    }
    
    if (status === 0) {
      for (const question of otherQuestions) {
        if (question.soru_sira_no > oldSoruSiraNo) {
          await question.update({
            soru_sira_no: question.soru_sira_no - 1,
          });
        }
      }
    }
    
    if (status === 1) {
      for (const question of otherQuestions) {
        if (question.soru_sira_no >= oldSoruSiraNo) {
          await question.update({
            soru_sira_no: question.soru_sira_no + 1,
          });
        }
      }
    }
    
    return res.status(200).send(`Soru güncellendi!`);
  } catch (error) {
    console.error("Update Question Error:", error);
    return res.status(500).send(error);
  }
});

//  DENETİM TİPİ SEÇİLEN SORULARI LİSTELER
router.post("/getAllInspectionQuestionsByType", authenticateToken, async (req, res) => {
  try {
    const { error, value } = Joi.object({
      denetim_tip_id: Joi.number().required(),
    }).validate(req.body);

    if (error) return res.status(400).send(error);

    const sequelize = await initializeSequelize();
    const soruModel = sequelize.define("soru", soru, {
      timestamps: false,
      freezeTableName: true,
    });

    const allInspectionQuestions = await soruModel.findAndCountAll({
      where: {
        denetim_tip_id: value.denetim_tip_id,
      },
    });

    if (!allInspectionQuestions || allInspectionQuestions.length === 0) return res.status(404).send("Hiç Soru Bulunamadı!");
    

    return res
      .status(200)
      .send({ data: allInspectionQuestions.rows, count: allInspectionQuestions.count });
  } catch (error) {
    console.error("Get All Inspection Questions Error:", error);
    return res.status(500).send(error);
  }
});

module.exports = router;
