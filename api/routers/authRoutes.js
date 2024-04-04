// authRoutes.js
const express = require('express');
const router = express.Router();
const { initializeSequelize } = require('../helpers/sequelize');
const { users } = require("../helpers/sequelizemodels");

router.get('/getAllUsers', async (req, res) => {
    try {
        const sequelize = await initializeSequelize();
        const usersModel = sequelize.define('users', users, {
            timestamps: false,
            freezeTableName: true,
        });

        const allUsers = await usersModel.findAll();
        return res.status(200).send({ users: allUsers });

    } catch (error) {
        console.error('Get All Users Error:', error);
        return res.status(500).send(error);
    }
});

module.exports = router;
