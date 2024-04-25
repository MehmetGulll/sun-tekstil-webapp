const express = require("express");
const sql = require("mssql");
const bcrypt = require("bcrypt");
const jwt = require("jsonwebtoken");
const User = require("../helpers/userModels");
const config = require("../config/config");
const Joi = require("joi");
const { Op } = require("sequelize");
const authenticateToken = require("../middlewares/authentication");
const { initializeSequelize } = require("../helpers/sequelize");
const { kullanici, rol } = require("../helpers/sequelizemodels");

exports.login = async (req, res) => {
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

    const isPasswordCorrect = await bcrypt.compare(sifre, user.sifre);

    if (!isPasswordCorrect) {
      return res.status(401).send("Kullanıcı adı veya şifre hatalı");
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

    return res.status(200).send({ token, user: tokenPayload });
  } catch (error) {
    console.error("Login Error:", error);
    return res.status(500).send(error);
  }
};

exports.register = async (req, res) => {
  const { userName, userSurname, user_name, userEposta, userPassword } =
    req.body;
  const saltRounds = 10;
  try {
    const pool = await sql.connect(config);

    const userCheckResult = await pool
      .request()
      .input("input_param", sql.VarChar, user_name)
      .query("SELECT * FROM kullanici WHERE kullanici_adi = @input_param");

    if (userCheckResult.recordset.length > 0) {
      res.status(400).send({ message: "Bu kullanıcı adı zaten kayıtlı." });
    } else {
      const idResult = await pool
        .request()
        .query("SELECT MAX(id) as maxId FROM kullanici");
      const newId = idResult.recordset[0].maxId + 1;
      const hashedPassword = await bcrypt.hash(userPassword, saltRounds);
      const result = await pool
        .request()
        .input("input_param0", sql.Int, newId)
        .input("input_param1", sql.VarChar, userName)
        .input("input_param2", sql.VarChar, userSurname)
        .input("input_param3", sql.VarChar, user_name)
        .input("input_param4", sql.VarChar, userEposta)
        .input("input_param5", sql.VarChar, hashedPassword)
        .input("input_param6", sql.Int, 1)
        .query(
          "INSERT INTO kullanici (ad,soyad,kullanici_adi,eposta,sifre,rol) VALUES ( @input_param1, @input_param2, @input_param3, @input_param4, @input_param5,@input_param6)"
        );
      res.status(200).send({ message: "Kullanıcı başarıyla kaydedildi" });
    }
  } catch (error) {
    console.log("Error", error);
  }
};

exports.logout = async (req, res) => {
  try {
    res.cookie = ("token", "", { maxAge: 1 });
    res.status(200).send({ message: "Logout success" });
  } catch (error) {
    res.status(500).send({ message: "logout failed", error });
  }
};

exports.changePassword = async (req, res) => {
  try {
    const { kullanici_adi, eski_sifre, yeni_sifre } = req.body;

    const sequelize = await initializeSequelize();
    const kullaniciModel = sequelize.define("kullanici", kullanici, {
      timestamps: false,
      freezeTableName: true,
    });

    const user = await kullaniciModel.findOne({ where: { kullanici_adi } });
    if (!user) {
      return res.status(404).send("Kullanici bulunamadi!");
    }

    const isOldPasswordCorrect = await bcrypt.compare(eski_sifre, user.sifre);
    if (!isOldPasswordCorrect) {
      return res.status(401).send("Eski şifre yanlış");
    }

    const hashedPassword = await bcrypt.hash(yeni_sifre, 10);

    user.sifre = hashedPassword;
    await user.save();

    return res.status(200).send("Şifre başarıyla değiştirildi");
  } catch (error) {
    console.error("Password Change Error:", error);
    return res.status(500).send(error);
  }
};
exports.getOfficalUsers = async (req, res) => {
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
        status: user.status,
      };
    });

    return res.status(200).send(modifiedUsers);
  } catch (error) {
    console.error("Get All Users Error:", error);
    return res.status(500).send(error);
  }
};
exports.updateOfficalUserStatus = async (req, res) => {
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
    console.log("Error", error);
  }
};
