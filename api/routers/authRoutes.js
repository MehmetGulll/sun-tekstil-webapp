const express = require("express");
const router = express.Router();
const Joi = require("joi");
const jwt = require("jsonwebtoken");
const bcrypt = require("bcrypt");
const { Op } = require("sequelize");
const authenticateToken = require("../middlewares/authentication");
const { initializeSequelize } = require("../helpers/sequelize");
const { kullanici, rol, unvan } = require("../helpers/sequelizemodels");
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
router.post("/panelLogin", async (req, res) => {
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
        kullanici_adi: kullanici_adi,
      },
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

    if (user.status === 0) {
      return res.status(400).send("Kullanici hesabi aktif degil!");
    }

    if (user.rol === 6) {
      return res.status(401).send("Giriş İzniniz Yok!");
    }

    const isPasswordCorrect = await bcrypt.compare(sifre, user.sifre);

    if (!isPasswordCorrect) {
      return res.status(401).send("Yanlış şifre! Lütfen kontrol ediniz.");
    }

    // Generate JWT token
    const tokenPayload = {
      id: user.id,
      kullanici_adi: user.kullanici_adi,
      ad: user.ad,
      soyad: user.soyad,
      eposta: user.eposta,
      rol_id: user.rol,
      rol_adi: user.userRole ? user.userRole.rol_adi : "Default Kullanici",
    };
    const token = jwt.sign(tokenPayload, process.env.JWT_SECRET_KEY);

    console.log("Hoşgeldin ad soyad: ", user.ad, user.soyad);

    return res.status(200).send({ token, user: tokenPayload });
  } catch (error) {
    console.error("Login Error:", error);
    return res.status(500).send(error);
  }
});

// YENİ KULLANICI EKLEMEK İÇİN
router.post("/addUser", authenticateToken, async (req, res) => {
  try {
    if (req.user.rol_id !== 1 && req.user.rol_id !== 2) {
      return res.status(403).send("Kullanici ekleme yetkiniz yok!");
    }
    const { error, value } = Joi.object({
      ad: Joi.string().required(),
      soyad: Joi.string().required(),
      kullanici_adi: Joi.string().required(),
      eposta: Joi.string().email().required(),
      sifre: Joi.string().min(5).required(),
      rol: Joi.number().required(),
      unvan_id: Joi.number().required(),
    }).validate(req.body);

    if (error) {
      return res
        .status(400)
        .send("Kullanici bilgileri eksik veya hatali! Lütfen kontrol ediniz.");
    }

    const { ad, soyad, kullanici_adi, eposta, sifre, rol, unvan_id } = value;

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
      unvan_id: unvan_id,
      status: 1,
    });

    return res.status(201).send(newUser);
  } catch (error) {
    console.error("Add User Error:", error);
    return res.status(500).send(error);
  }
});
//  KULLANICI STATUS AKTİF PASİF YAPMAK İÇİN
router.post("/updateUserStatus", authenticateToken, async (req, res) => {
  try {
    const { error, value } = Joi.object({
      id: Joi.number().required(),
      status: Joi.number().required(),
    }).validate(req.body);

    if (error) {
      return res.status(400).send(error.details[0].message);
    }

    const { id, status } = value;

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

    await kullaniciModel.update(
      { status },
      {
        where: {
          id,
        },
      }
    );

    const updatedUser = await kullaniciModel.findOne({
      where: {
        id,
      },
    });

    return res.status(200).send(updatedUser);
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

// Tüm kullanıcıları listeler, searchTerm ile arama yapılabilir , page ve perPage ile sayfalama yapılabilir.
router.post("/users", authenticateToken, async (req, res) => {
  try {
    const { error, value } = Joi.object({
      searchTerm: Joi.string().allow(""),
      page: Joi.number().min(1).default(1),
      perPage: Joi.number().min(1),
    }).validate(req.body);

    if (error) {
      return res.status(400).send(error.details[0].message);
    }

    const { searchTerm = "", page = 1, perPage = 10 } = value;

    const sequelize = await initializeSequelize();
    const kullaniciModel = sequelize.define("kullanici", kullanici, {
      timestamps: false,
      freezeTableName: true,
    });
    const rolModel = sequelize.define("rol", rol, {
      timestamps: false,
      freezeTableName: true,
    });
    const unvanModel = sequelize.define("unvan", unvan, {
      timestamps: false,
      freezeTableName: true,
    });

    kullaniciModel.belongsTo(unvanModel, {
      as: "userUnvan",
      foreignKey: "unvan_id",
      targetKey: "unvan_id",
    });

    kullaniciModel.belongsTo(rolModel, {
      as: "userRole",
      foreignKey: "rol",
      targetKey: "rol_id",
    });
    whereObj = {}

    if(searchTerm){
      whereObj = {
        [Op.or]: [
          { ad: { [Op.like]: `%${searchTerm}%` } },
          { soyad: { [Op.like]: `%${searchTerm}%` } },
          { kullanici_adi: { [Op.like]: `%${searchTerm}%` } },
          { eposta: { [Op.like]: `%${searchTerm}%` } },
        ],
      }
    }



    const allUsers = await kullaniciModel.findAndCountAll({
      where: whereObj,
      include: [
        {
          model: rolModel,
          as: "userRole",
          attributes: ["rol_adi"],
        },
        {
          model: unvanModel,
          as: "userUnvan",
          attributes: ["unvan_adi"],
        },
      ],
      offset: (page - 1) * perPage,
      limit: perPage,
    });

    if (allUsers.count === 0) {
      return res.status(404).send("Kullanici bulunamadi!");
    }

    const modifiedUsers = allUsers.rows.map((user) => {
      return {
        id: user.id,
        ad: user.ad,
        soyad: user.soyad,
        kullanici_adi: user.kullanici_adi,
        eposta: user.eposta,
        rol_adi: user.userRole ? user.userRole.rol_adi : "default kullanici",
        rol_id: user.rol,
        unvan_adi: user.userUnvan ? user.userUnvan.unvan_adi : "default unvan",
        unvan_id: user.unvan_id,
        status: user.status,
      };
    });

    return res.status(200).send({
      total: allUsers.count,
      page,
      perPage,
      data: modifiedUsers,
    });
  } catch (error) {
    console.error("Get All Users Error:", error);
    return res.status(500).send(error);
  }
});

// KULLANICI BİLGİLERİNİ GÜNCELLEMEK İÇİN
router.post("/updateSelectedUser", authenticateToken, async (req, res) => {
  try {
    const { error, value } = Joi.object({
      id: Joi.number().required(),
      ad: Joi.string(),
      soyad: Joi.string(),
      kullanici_adi: Joi.string(),
      eposta: Joi.string().email(),
      sifre: Joi.string().min(5),
      rol: Joi.number(),
      unvan_id: Joi.number(),
      status: Joi.number(),
    }).validate(req.body);

    if (error) {
      return res.status(400).send(error);
    }

    const {
      id,
      ad,
      soyad,
      kullanici_adi,
      eposta,
      sifre,
      rol,
      unvan_id,
      status,
    } = value;

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

    if (ad) updatedFields.ad = ad;
    if (soyad) updatedFields.soyad = soyad;
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
    if (rol) updatedFields.rol = rol;
    if (unvan_id) updatedFields.unvan_id = unvan_id;
    if (status !== undefined) updatedFields.status = status;

    console.log("status", status);
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

    return res.status(200).send(updatedUser);
  } catch (error) {
    console.error("Update User Error:", error);
    return res.status(500).send(error);
  }
});

// All Roles
router.get("/roles", authenticateToken, async (req, res) => {
  try {
    const sequelize = await initializeSequelize();
    const rolModel = sequelize.define("rol", rol, {
      timestamps: false,
      freezeTableName: true,
    });

    const allRoles = await rolModel.findAll();

    return res.status(200).send(allRoles);
  } catch (error) {
    console.error("Get All Roles Error:", error);
    return res.status(500).send(error);
  }
});

// All Unvan
router.get("/unvanlar", authenticateToken, async (req, res) => {
  try {
    const sequelize = await initializeSequelize();
    const unvanModel = sequelize.define("unvan", unvan, {
      timestamps: false,
      freezeTableName: true,
    });

    const allUnvan = await unvanModel.findAll();

    return res.status(200).send(allUnvan);
  } catch (error) {
    console.error("Get All Unvan Error:", error);
    return res.status(500).send(error);
  }
});


// update password from user id with url 
router.post("/updatePassword/:id", async (req, res) => {
  try {
    const { error, value } = Joi.object({
      sifre: Joi.string().min(5).required(),
    }).validate(req.body);

    if (error) {
      return res.status(400).send(error.details[0].message);
    }

    const { sifre } = value;
    const { id } = req.params;

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

    const passwordRegex = /^(?=.*\d)(?=.*[a-z])(?=.*[A-Z]).{6,20}$/;
    if (!passwordRegex.test(sifre)) {
      return res
        .status(400)
        .send(
          "Şifre en az bir büyük harf, bir küçük harf ve bir rakam içermelidir!"
        );
    }

    const hashedPassword = await bcrypt.hash(sifre, 10);

    await kullaniciModel.update(
      { sifre: hashedPassword },
      {
        where: {
          id,
        },
      }
    );

    return res.status(200).send("Şifre başarıyla güncellendi.");
  } catch (error) {
    console.error("Update Password Error:", error);
    return res.status(500).send(error);
  }
} );


module.exports = router;
