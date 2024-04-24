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
