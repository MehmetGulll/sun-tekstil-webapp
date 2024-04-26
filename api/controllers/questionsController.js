const express = require("express");
const sql = require("mssql");
const Question = require("../helpers/questionModels");
const config = require("../config/config");

exports.getQuestions = async (req, res) => {
  try {
    const pool = await sql.connect(config);
    const result = await pool.request().query("SELECT * FROM soru");
    const questions = result.recordset.map(
      (item) =>
        new Question(
          item.soru_id,
          item.soru_adi,
          item.soru_cevap,
          item.soru_puan,
          item.denetim_tip_id,
          item.status
        )
    );
    res.json(questions);
  } catch (error) {
    console.log("Error", error.message);
    res.status(500).send("Server Error" + error.message);
  }
};
exports.filterQuestions = async (req, res) => {
  try {
    const pool = await sql.connect(config);
    const soru_adi = req.query.soru_adi;
    const soru_cevap = req.query.soru_cevap;
    let query = "SELECT * FROM soru WHERE";

    if (soru_adi && soru_cevap) {
      query += ` soru_adi LIKE '%${soru_adi}%' AND soru_cevap LIKE '%${soru_cevap}%'`;
    } else if (soru_adi) {
      query += ` soru_adi LIKE '%${soru_adi}%'`;
    } else if (soru_cevap) {
      query += ` soru_cevap LIKE '%${soru_cevap}%'`;
    } else {
      query = "SELECT * FROM soru";
    }

    const result = await pool.request().query(query);
    const questions = result.recordset.map(
      (item) =>
        new Question(
          item.soru_id,
          item.soru_adi,
          item.soru_cevap,
          item.soru_puan,
          item.denetim_tip_id,
          item.status
        )
    );
    res.json(questions);
  } catch (error) {
    console.log("Error", error);
    res.status(500).send({ message: "Server Error", error });
  }
};
