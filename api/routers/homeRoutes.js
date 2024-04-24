const express = require("express");
const router = express.Router();
const Joi = require("joi");
const { Op } = require("sequelize");
const authenticateToken = require("../middlewares/authentication");
const { initializeSequelize } = require("../helpers/sequelize");
const { denetim,denetim_tipi,magaza,kullanici } = require("../helpers/sequelizemodels");

// ID'si verilen kullanıcının denetimlerininin 
router.get("/getInspectionCompletionStatus/:id", authenticateToken, async (req, res) => {
    try {
        const { id } = req.params;
        const sequelize = await initializeSequelize();
        const denetimModel = sequelize.define("denetim", denetim, {
            timestamps: false,
            freezeTableName: true,
        });

        const totalCount = await denetimModel.count({
            where: {
                denetci_id: id,
            }
        });

        const completedCount = await denetimModel.count({
            where: {
                denetci_id: id,
                status: 1,
            }
        });

        const completionPercentage = (completedCount / totalCount) * 100;

        return res.status(200).send({ completedCount, totalCount, completionPercentage });
    } catch (error) {
        console.error(error);
        return res.status(500).send(error);
    }
});

// ID'si verilen kullanıcının son 5 denetimini getirir.
router.get("/getLastFiveInspections/:id", authenticateToken, async (req, res) => {
    try {
        const { id } = req.params;
        const sequelize = await initializeSequelize();
        const denetimModel = sequelize.define("denetim", denetim, {
            timestamps: false,
            freezeTableName: true,
        });
        const magazaModel = sequelize.define("magaza", magaza, {
            timestamps: false,
            freezeTableName: true,
        });

        const denetimeTipiModel = sequelize.define("denetim_tipi", denetim_tipi, {
            timestamps: false,
            freezeTableName: true,
        });
        const kullaniciModel = sequelize.define("kullanici", kullanici, {
            timestamps: false,
            freezeTableName: true,
        });

        denetimModel.belongsTo(kullaniciModel, { foreignKey: "denetci_id" });
        denetimModel.belongsTo(magazaModel, { foreignKey: "magaza_id" });
        denetimModel.belongsTo(denetimeTipiModel, { foreignKey: "denetim_tipi_id" });
        
        const lastFiveInspections = await denetimModel.findAll({
            where: {
                denetci_id: id,
            },
            include: [
                {
                    model: kullaniciModel,
                    attributes: ["ad", "soyad"],
                },
                {
                    model: magazaModel,
                    attributes: ["magaza_adi"],
                },
                {
                    model: denetimeTipiModel,
                    attributes: ["denetim_tipi"],
                },
            ],
            order: [["denetim_tarihi", "DESC"]],
            limit: 5,
        });

        if(lastFiveInspections.length === 0)
         return res.status(200).send("Kullanıcıya ait son 5 denetim bulunamadı.");

        const modifiedLastFiveInspections = lastFiveInspections.map((inspection) => {
            return {
                id: inspection.id,
                denetci: inspection.kullanici.ad + " " + inspection.kullanici.soyad,
                magaza: inspection.magaza.magaza_adi,
                denetim_tipi: inspection.denetim_tipi.denetim_tipi,
                denetim_tarihi: inspection.denetim_tarihi,
                status: inspection.status,
                alinan_puan: inspection.alinan_puan ? inspection.alinan_puan : "-",
            };
        });
        

        return res.status(200).send(modifiedLastFiveInspections);
    } catch (error) {
        console.error(error);
        return res.status(500).send(error);
    }
});


module.exports = router;

