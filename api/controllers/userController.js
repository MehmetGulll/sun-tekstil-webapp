const express = require("express");
const sql = require("mssql");
const User = require("../helpers/userModels");
const config = require("../config/config");

exports.login = async (req, res) => {
  const { user_name, userPassword } = req.body;
  try {
    const pool = await sql.connect(config);
    const result = await pool
      .request()
      .input("input_param1", sql.VarChar, user_name)
      .input("input_param2", sql.VarChar, userPassword)
      .query(
        "SELECT * FROM kullanici WHERE kullanici_adi = @input_param1 AND sifre = @input_param2"
      );
    if (result.recordset.length > 0) {
      res
        .status(200)
        .send({
          message: "Başarıyla giriş yapıldı.",
          user: result.recordset[0],
        });
    } else {
      res.status(404).send({ message: "Kullanıcı bulunamadı." });
    }
  } catch (error) {
    console.log(error);
    res.status(500).send({ message: "Sunucu hatası." });
  }
};
