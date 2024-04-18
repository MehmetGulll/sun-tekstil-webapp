const express = require("express");
const sql = require("mssql");
const config = require("../config/config");
const Store = require("../helpers/storeModels");

exports.getStores = async (req, res) => {
  try {
    const pool = await sql.connect(config);
    const result = await pool.request().query("SELECT * FROM magaza");
    const stores = result.recordset.map(
      (store) =>
        new Store(
          magaza_id,
          magaza_kodu,
          magaza_adi,
          magaza_tipi,
          bolge_id,
          sehir,
          magaza_telefon,
          magaza_metre,
          magaza_muduru
        )
    );
    res.status(200).send(stores);
  } catch (error) {
    console.log("Error", error);
    res.status(500).send({ message: "Sunucu Hatası" });
  }
};
