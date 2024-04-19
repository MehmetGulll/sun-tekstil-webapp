const express = require('express');
const sql = require('mssql');
const User = require('../helpers/usersModels'); // Assuming you have created a User model
const config = require('../config/config');

exports.getUsers = async (req, res) => {
    try {
        const pool = await sql.connect(config);
        const result = await pool.request().query('SELECT * FROM kullanici');
        const users = result.recordset.map(item => new User(
            item.id,
            item.ad,
            item.soyad,
            item.kullanici_adi,
            item.eposta,
            item.sifre,
            item.rol,
            item.status
        ));
        res.json(users);
    } catch (error) {
        console.log("Error", error.message);
        res.status(500).send('Server Error' + error.message);
    }
}
