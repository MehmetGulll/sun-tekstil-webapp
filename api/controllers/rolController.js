const express  = require('express');
const sql = require('mssql');
const Question = require('../helpers/rolModels');
const config = require('../config/config');

exports.getRols = async(req,res)=>{
    try {
        const pool = await sql.connect(config);
        const result = await pool.request().query('SELECT * FROM rol');
        const questions = result.recordset.map(item => new Question(item.rol_id, item.rol_adi, item.yetki_id));
        res.json(questions);
    } catch (error) {
        console.log("Error",error.message);
        res.status(500).send('Server Error' + error.message);
    }
}
