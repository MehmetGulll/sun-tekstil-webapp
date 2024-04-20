const express = require("express");
const sql = require("mssql");
const bcrypt = require("bcrypt");
const jwt = require('jsonwebtoken');
const User = require("../helpers/userModels");
const config = require("../config/config");

exports.login = async (req, res) => {
  const { user_name, userPassword } = req.body;
  try {
    const pool = await sql.connect(config);
    const result = await pool
      .request()
      .input("input_param1", sql.VarChar, user_name)
      .query("SELECT * FROM kullanici WHERE kullanici_adi = @input_param1");
    if (result.recordset.length > 0) {
      const user = result.recordset[0];
      const match = await bcrypt.compare(userPassword, user.sifre);

      if (match) {
        const token = jwt.sign({id:user.id}, 'yourToken',{expiresIn:'24h'})
        req.session.token =token;
        res.status(200).send({
          message: "Başarıyla giriş yapıldı.",
          user: user,
          token:token
        });
      } else {
        res.status(401).send({ message: "Yanlış şifre." });
      }
    } else {
      res.status(404).send({ message: "Kullanıcı bulunamadı." });
    }
  } catch (error) {
    console.log(error);
    res.status(500).send({ message: "Sunucu hatası." });
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

exports.logOut = async(req,res)=>{
  try {
    req.session.token = null;
    res.status(200).send({message:'Çıkış işlemi başarılı..'});
  } catch (error) {
    console.log("Error",error);
    res.status(500).send({message:'Çıkış sağlanamadı:',error});
  }
}
