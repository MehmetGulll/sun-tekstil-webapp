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
    console.log("requser", req.user);

    return
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

    return res
      .status(200)
      .send({
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
      status: Joi.number().integer().min(0).max(1).required(),
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

    const calculatedSoruSiraNo = await soruModel.max("soru_sira_no") + 1;
    
    const newQuestion = await soruModel.create({
      soru_adi,
      soru_cevap,
      soru_sira_no: calculatedSoruSiraNo,
      soru_puan,
      denetim_tip_id,
      ekleyen_id: req.user.id,
      status,
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
    if (req.user.rol_id !== 1) {
      return res.status(403).send("Soru güncelleme yetkiniz yok!");
    }

    const questionSchema = Joi.object({
      soru_id: Joi.number().integer().required(),
      soru_adi: Joi.string(),
      soru_cevap: Joi.number().integer(),
      soru_sira_no: Joi.number().integer(),
      soru_puan: Joi.number().integer(),
      denetim_tip_id: Joi.number().integer(),
      status: Joi.number().integer().valid(0, 1)
    });

    const { error, value } = questionSchema.validate(req.body);
    const { soru_id, soru_adi, soru_cevap, soru_sira_no, soru_puan, denetim_tip_id, status } = value;

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

    if (findQuestion.soru_adi === soru_adi) return res.status(400).send("Soru adı aynı olduğu için güncelleme yapılamaz! Lütfen farklı bir değer giriniz!");

    if (findQuestion.soru_cevap === soru_cevap) return res.status(400).send("Soru cevap aynı olduğu için güncelleme yapılamaz! Lütfen farklı bir değer giriniz!");

    if (findQuestion.soru_puan === soru_puan) return res.status(400).send("Soru puan aynı olduğu için güncelleme yapılamaz! Lütfen farklı bir değer giriniz!");

    if (findQuestion.denetim_tip_id === denetim_tip_id) return res.status(400).send("Denetim tip id aynı olduğu için güncelleme yapılamaz! Lütfen farklı bir değer giriniz!");

    if (findQuestion.status === status) return res.status(400).send("Status aynı olduğu için güncelleme yapılamaz! Lütfen farklı bir değer giriniz!");

    // Mevcut denetim_tip_id'ye sahip soruların maksimum soru_sira_no değerini bul
    let maxSoruSiraNo;
    if (denetim_tip_id) {
      maxSoruSiraNo = await soruModel.max('soru_sira_no', {
        where: {
          denetim_tip_id: denetim_tip_id
        }
      });
    }

    // Eğer güncellenen soru_sira_no değeri mevcut denetim_tip_id'ye sahip diğer soruların arasında bulunuyorsa,
    // bu değeri verilen soru_sira_no değeriyle değiştiririz.
    // Daha sonra, verilen soru_sira_no değerinden büyük olan diğer soruların soru_sira_no değerlerini birer birer arttırırız.
    let updatedSoruSiraNo = soru_sira_no;
    if (maxSoruSiraNo !== undefined && soru_sira_no <= maxSoruSiraNo) {
      updatedSoruSiraNo = soru_sira_no;
      await soruModel.update(
        { soru_sira_no: sequelize.literal(`soru_sira_no + 1`) },
        {
          where: {
            denetim_tip_id: denetim_tip_id,
             // soru_sira_no değeri verilen değerden büyük olan soruları seç
            soru_sira_no: { [Op.gt]: soru_sira_no }
          }
        }
      );
    }

    const updatedQuestion = await soruModel.update(
      {
        soru_adi: soru_adi ? soru_adi : findQuestion.soru_adi,
        soru_cevap: soru_cevap ? soru_cevap : findQuestion.soru_cevap,
        soru_sira_no: updatedSoruSiraNo,
        soru_puan: soru_puan ? soru_puan : findQuestion.soru_puan,
        denetim_tip_id: denetim_tip_id ? denetim_tip_id : findQuestion.denetim_tip_id,
        güncelleyen_id: req.user.id ? req.user.id : findQuestion.güncelleyen_id,
        status: status
      },
      {
        where: {
          soru_id,
        },
      }
    );

    if (updatedQuestion > 0) {
      let updatedValues = [];
      if (soru_adi) updatedValues.push(`Soru Adı: ${soru_adi}`);
      if (soru_cevap) updatedValues.push(`Soru Cevap: ${soru_cevap}`);
      if (soru_puan) updatedValues.push(`Soru Puan: ${soru_puan}`);
      if (denetim_tip_id) updatedValues.push(`Denetim Tip Id: ${denetim_tip_id}`);
      if (status !== undefined) updatedValues.push(`Status: ${status}`);

      const updatedMessage = updatedValues.join('\n');

      return res.status(200).send(`Soru güncellendi! Güncellenen değerler:\n${updatedMessage}`);
    }
    return res.status(200).send(`Soru günc ellendi!`);
  } catch (error) {
    console.error("Update Question Error:", error);
    return res.status(500).send
  }
});





module.exports = router;
