const express = require("express");
const router = express.Router();
const Joi = require("joi");
const jwt = require("jsonwebtoken");
const bcrypt = require("bcrypt");
const { Op } = require("sequelize");
const authenticateToken = require("../middlewares/authentication");
const { initializeSequelize } = require("../helpers/sequelize");
const { kullanici, rol } = require("../helpers/sequelizemodels");
// DENEMEYDİ SİLİNCEK
router.get("/kullanicilar", async (req, res) => {
  try {
    const sequelize = await initializeSequelize();
    const kullaniciModel = sequelize.define("kullanici", kullanici, {
      timestamps: false,
      freezeTableName: true,
    });
    const rolModel = sequelize.define("rol", rol, {
      timestamps: false,
      freezeTableName: true,
    });

    kullaniciModel.belongsTo(rolModel, {
      as: "userRole",
      foreignKey: "rol",
      targetKey: "rol_id",
    });

    const allUsers = await kullaniciModel.findAll({
      include: [
        {
          model: rolModel,
          as: "userRole",
          attributes: ["rol_adi"],
        },
      ],
    });

    const modifiedUsers = allUsers.map((user) => {
      return {
        id: user.id,
        ad: user.ad,
        soyad: user.soyad,
        kullanici_adi: user.kullanici_adi,
        eposta: user.eposta,
        sifre: user.sifre,
        rol_adi: user.userRole ? user.userRole.rol_adi : "default kullanici",
      };
    });

    return res.status(200).send(modifiedUsers);
  } catch (error) {
    console.error("Get All Users Error:", error);
    return res.status(500).send(error);
  }
});

// KULLANICI GİRİŞİ İÇİN
router.post("/login", async (req, res) => {
  try {
    const { error, value } = Joi.object({
      kullanici_adi: Joi.string().required(),
      sifre: Joi.string().min(5).required(),
    }).validate(req.body);

    if (error) {
      return res
        .status(400)
        .send("Kullanici adi ve şifre boş olamaz! Lütfen kontrol ediniz.");
    }

    const { kullanici_adi, sifre } = value;

    const sequelize = await initializeSequelize();
    const kullaniciModel = sequelize.define("kullanici", kullanici, {
      timestamps: false,
      freezeTableName: true,
    });
    const rolModel = sequelize.define("rol", rol, {
      timestamps: false,
      freezeTableName: true,
    });

    kullaniciModel.belongsTo(rolModel, {
      as: "userRole",
      foreignKey: "rol",
      targetKey: "rol_id",
    });

    const user = await kullaniciModel.findOne({
      where: {
        kullanici_adi : kullanici_adi,
      },
      include: [
        {
          model: rolModel,
          as: "userRole",
          attributes: ["rol_adi"],
        },
      ],
    });

    if (user.status === 0) {
      return res.status(400).send("Kullanici hesabi aktif degil!");
    }

    if (!user) {
      return res.status(404).send("Kullanici bulunamadi!");
    }

    const isPasswordCorrect = await bcrypt.compare(sifre, user.sifre);

    if (!isPasswordCorrect) {
      return res.status(401).send("Invalid username or password");
    }

    // Generate JWT token
    const tokenPayload = {
      id: user.id,
      kullanici_adi: user.kullanici_adi,
      ad: user.ad,
      soyad: user.soyad,
      eposta: user.eposta,
      rol: user.rol,
      rol_adi: user.userRole ? user.userRole.rol_adi : "default kullanici",
    };
    const token = jwt.sign(tokenPayload, process.env.JWT_SECRET_KEY);

    return res.status(200).send({ token, user: tokenPayload });
  } catch (error) {
    console.error("Login Error:", error);
    return res.status(500).send(error);
  }
});

// YENİ KULLANICI EKLEMEK İÇİN
router.post("/addUser", authenticateToken, async (req, res) => {
  try {
    const { error, value } = Joi.object({
      ad: Joi.string().required(),
      soyad: Joi.string().required(),
      kullanici_adi: Joi.string().required(),
      eposta: Joi.string().email().required(),
      sifre: Joi.string().min(5).required(),
      rol: Joi.number().required(),
    }).validate(req.body);

    if (error) {
      return res
        .status(400)
        .send("Kullanici bilgileri eksik veya hatali! Lütfen kontrol ediniz.");
    }

    const { ad, soyad, kullanici_adi, eposta, sifre, rol } = value;

    const sequelize = await initializeSequelize();
    const kullaniciModel = sequelize.define("kullanici", kullanici, {
      timestamps: false,
      freezeTableName: true,
    });

    const user = await kullaniciModel.findOne({
      where: ([Op.or] = [{ kullanici_adi }, { eposta }]),
    });

    if (user) {
      return res
        .status(400)
        .send(
          "Bu kullanici adi veya eposta zaten kullaniliyor! Lütfen farkli bir kullanici adi veya eposta giriniz."
        );
    }

    const passwordRegex = /^(?=.*\d)(?=.*[a-z])(?=.*[A-Z]).{6,20}$/;
    if (!passwordRegex.test(sifre)) {
      return res
        .status(400)
        .send(
          "Şifre en az bir büyük harf, bir küçük harf ve bir rakam içermelidir!"
        );
    }

    const hashedPassword = await bcrypt.hash(sifre, 10);

    const newUser = await kullaniciModel.create({
      ad,
      soyad,
      kullanici_adi,
      eposta,
      sifre: hashedPassword,
      rol,
    });

    return res.status(201).send(newUser);
  } catch (error) {
    console.error("Add User Error:", error);
    return res.status(500).send(error);
  }
});
//  KULLANICI STATUS AKTİF PASİF YAPMAK İÇİN
router.post("/updateUserStatus/:id", authenticateToken, async (req, res) => {
  try {
    const { id } = req.params;
    const { error, value } = Joi.object({
      status: Joi.number().required(),
    }).validate(req.body);

    if (error) {
      return res.status(400).send(error.details[0].message);
    }

    const { status } = value;

    const sequelize = await initializeSequelize();
    const kullaniciModel = sequelize.define("kullanici", kullanici, {
      timestamps: false,
      freezeTableName: true,
    });

    const user = await kullaniciModel.findOne({
      where: {
        id,
      },
    });

    if (!user) {
      return res.status(404).send("Kullanıcı bulunamadı!");
    }

    await kullaniciModel.update(
      { status },
      {
        where: {
          id,
        },
      }
    );

    return res.status(200).send("Kullanıcı durumu başarıyla güncellendi.");
  } catch (error) {
    console.error("Update User Status Error:", error);
    return res.status(500).send(error);
  }
});

// KULLANICI BİLGİLERİNİ GÖRÜNTÜLEMEK İÇİN
router.get("/user/:id", authenticateToken, async (req, res) => {
  try {
    const { id } = req.params;

    const sequelize = await initializeSequelize();
    const kullaniciModel = sequelize.define("kullanici", kullanici, {
      timestamps: false,
      freezeTableName: true,
    });
    const rolModel = sequelize.define("rol", rol, {
      timestamps: false,
      freezeTableName: true,
    });

    kullaniciModel.belongsTo(rolModel, {
      as: "userRole",
      foreignKey: "rol",
      targetKey: "rol_id",
    });

    const user = await kullaniciModel.findOne({
      where: {
        id,
      },
      attributes: { exclude: ["id"] },
      include: [
        {
          model: rolModel,
          as: "userRole",
          attributes: ["rol_adi"],
        },
      ],
    });

    if (!user) {
      return res.status(404).send("Kullanici bulunamadi!");
    }

    const modifiedUser = {
      id: user.id,
      ad: user.ad,
      soyad: user.soyad,
      kullanici_adi: user.kullanici_adi,
      eposta: user.eposta,
      sifre: user.sifre,
      rol_adi: user.userRole ? user.userRole.rol_adi : "default kullanici",
    };

    return res.status(200).send(modifiedUser);
  } catch (error) {
    console.error("Get User Error:", error);
    return res.status(500).send(error);
  }
});

// KULLANICI KENDİ BİLGİLERİNİ GÜNCELLEYEBİLİR
router.post("/updateUser", authenticateToken, async (req, res) => {
  try {
    const id = req.user.id;
    const { error, value } = Joi.object({
      kullanici_adi: Joi.string(),
      eposta: Joi.string().email(),
      sifre: Joi.string().min(5),
    }).validate(req.body);

    if (error) {
      return res.status(400).send(error);
    }

    const { kullanici_adi, eposta, sifre } = value;

    const sequelize = await initializeSequelize();
    const kullaniciModel = sequelize.define("kullanici", kullanici, {
      timestamps: false,
      freezeTableName: true,
    });

    const user = await kullaniciModel.findOne({
      where: {
        id,
      },
    });

    if (!user) {
      return res.status(404).send("Kullanici bulunamadi!");
    }

    let updatedFields = {};

    if (kullanici_adi) updatedFields.kullanici_adi = kullanici_adi;
    if (eposta) updatedFields.eposta = eposta;
    if (sifre) {
      const passwordRegex = /^(?=.*\d)(?=.*[a-z])(?=.*[A-Z]).{6,20}$/;
      if (!passwordRegex.test(sifre)) {
        return res
          .status(400)
          .send(
            "Şifre en az bir büyük harf, bir küçük harf ve bir rakam içermelidir!"
          );
      }
      updatedFields.sifre = await bcrypt.hash(sifre, 10);
    }

    await kullaniciModel.update(updatedFields, {
      where: {
        id,
      },
    });

    const updatedUser = await kullaniciModel.findOne({
      where: {
        id,
      },
    });

    const updatedFieldsMsg = Object.entries(updatedFields)
      .map(
        ([key, value]) => `${key}:\n  Eski: ${user[key]}\n  Yeni: ${value}\n`
      )
      .join("\n");

    return res
      .status(200)
      .send(
        `Kullanıcı adı ${req.user.kullanici_adi} bilgilerini başarıyla güncelledi.\n\nGüncellenen Alanlar:\n${updatedFieldsMsg}`
      );
  } catch (error) {
    console.error("Update User Error:", error);
    return res.status(500).send(error);
  }
});

module.exports = router;
