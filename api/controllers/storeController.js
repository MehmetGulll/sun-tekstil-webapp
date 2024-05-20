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
          store.magaza_id,
          store.magaza_kodu,
          store.magaza_adi,
          store.magaza_tipi,
          store.bolge_id,
          store.sehir,
          store.magaza_telefon,
          store.magaza_metre,
          store.magaza_muduru,
          store.status
        )
    );
    res.status(200).send(stores);
  } catch (error) {
    console.log("Error", error);
    res.status(500).send({ message: "Sunucu Hatası" });
  }
};
exports.addStore = async (req, res) => {
  try {
    const pool = await sql.connect(config);
    const {
      storeCode,
      storeName,
      storeType,
      city,
      storePhone,
      storeWidth,
      storeManager,
      addId,
      storeEmail
    } = req.body;
    const today = new Date();
    const formattedDate =
      ("0" + today.getDate()).slice(-2) +
      "." +
      ("0" + (today.getMonth() + 1)).slice(-2) +
      "." +
      today.getFullYear();

    const result = await pool
      .request()
      .input("storeCode", sql.NVarChar, storeCode)
      .input("storeName", sql.NVarChar, storeName)
      .input("storeType", sql.Int, storeType)
      .input("city", sql.NVarChar, city)
      .input("regionId", sql.NVarChar, "1")
      .input("storePhone", sql.NVarChar, storePhone)
      .input("storeWidth", sql.Int, storeWidth)
      .input("storeManager", sql.Int, 1)
      .input("openingDate", sql.NVarChar, formattedDate)
      .input("status", sql.Int, 1)
      .input("addId", sql.Int, addId)
      .input("storeEmail",sql.NVarChar,storeEmail)
      .query(
        `INSERT INTO magaza (magaza_kodu, magaza_adi, magaza_tipi,bolge_id, sehir, magaza_telefon, magaza_metre, magaza_muduru,acilis_tarihi,status,ekleyen_id, magaza_eposta) VALUES (@storeCode, @storeName, @storeType,@regionId ,@city, @storePhone, @storeWidth, @storeManager,@openingDate,@status,@addId,@storeEmail)`
      );
    res.status(200).send({ message: "Mağaza başarıyla eklendi" });
  } catch (error) {
    console.log("Error", error);
    res.status(500).send({ message: "Sunucu Hatası", error });
  }
};
exports.deleteStore = async (req, res) => {
  try {
    const pool = await sql.connect(config);
    const result = await pool
      .request()
      .input("storeId", sql.Int, req.params.storeId)
      .query("DELETE FROM magaza WHERE magaza_id = @storeId");
    res.status(200).send({ message: "Mağaza başarıyla silindi" });
  } catch (error) {
    console.log("Error", error);
    res.status(500).send({ message: "Sunucu hatası" });
  }
};
exports.updateStore = async (req, res) => {
  try {
    const pool = await sql.connect(config);
    const result = await pool
      .request()
      .input("storeId", sql.Int, req.body.storeId)
      .input("storeCode", sql.NVarChar, req.body.storeCode)
      .input("storeName", sql.NVarChar, req.body.storeName)
      .input("storeType", sql.NVarChar, req.body.storeType)
      .input("city", sql.NVarChar, req.body.city)
      .input("storePhone", sql.NVarChar, req.body.storePhone)
      .input("status", sql.Int, req.body.status)
      .query(
        "UPDATE magaza SET magaza_kodu = @storeCode, magaza_adi = @storeName, magaza_tipi = @storeType, sehir = @city, magaza_telefon = @storePhone, status = @status WHERE magaza_id =@storeId "
      );
    console.log(result);
    console.log(req.body.storeId);
    console.log(req.body.storeCode);
    console.log(req.body.storeName);
    console.log(req.body.storeType);
    console.log(req.body.city);
    console.log(req.body.storePhone);
    res.status(200).send({ message: "Mağaza başarıyla güncellendi" });
  } catch (error) {
    console.log("Error", error);
    res.status(500).send({ message: "Sunucu hatası:", error });
  }
};

exports.filterStores = async (req, res) => {
  try {
    const pool = await sql.connect(config);
    const magaza_adi = req.query.magaza_adi;
    const sehir = req.query.sehir;
    const magaza_tipi = req.query.magaza_tipi;
    let query = "SELECT * FROM magaza WHERE ";

    if (magaza_adi && sehir && magaza_tipi) {
      query += `magaza_adi LIKE '%${magaza_adi}%' AND sehir LIKE '%${sehir}%' AND magaza_tipi = ${magaza_tipi} `;
    } else if (magaza_adi) {
      query += `magaza_adi LIKE '%${magaza_adi}%' `;
    } else if (sehir && magaza_tipi) {
      query += `sehir LIKE '%${sehir}%' AND magaza_tipi = ${magaza_tipi} `;
    } else if (magaza_tipi) {
      query += `magaza_tipi = ${magaza_tipi} `;
    } else if (sehir) {
      query += `sehir LIKE '%${sehir}%'`;
    } else {
      query = "SELECT * FROM magaza";
    }

    const result = await pool.request().query(query);
    const stores = result.recordset.map(
      (store) =>
        new Store(
          store.magaza_id,
          store.magaza_kodu,
          store.magaza_adi,
          store.magaza_tipi,
          store.bolge_id,
          store.sehir,
          store.magaza_telefon,
          store.magaza_metre,
          store.magaza_muduru,
          store.status
        )
    );
    res.json(stores);
  } catch (error) {
    console.log("Error", error);
    res.status(500).send({ message: "Server Error", error });
  }
};
