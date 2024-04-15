const express = require("express");
const router = express.Router();
const { initializeSequelize } = require("../helpers/sequelize");
const { kullanici, rol } = require("../helpers/sequelizemodels");

router.get("/kullanicilar", async (req, res) => {
  try {
    const sequelize = await initializeSequelize();
    const kullaniciModel = sequelize.define("kullanici", kullanici, {
      timestamps: false,
      freezeTableName: true,
    });
    const rolModel = sequelize.define("rol", rol, {
      timestamps: false,
      freezeTableName: true,
    });

    kullaniciModel.belongsTo(rolModel, {
      as: "userRole", 
      foreignKey: "rol",
      targetKey: "rol_id",
    });
         
    const allUsers = await kullaniciModel.findAll({
      include: [
        {
          model: rolModel,
          as: "userRole",
          attributes: ["rol_adi"],
        },
      ],
    });
    
    const modifiedUsers = allUsers.map(user => {
      return {
        id: user.id,
        ad: user.ad,
        soyad: user.soyad,
        kullanici_adi: user.kullanici_adi,
        eposta: user.eposta,
        sifre: user.sifre,
        rol_adi: user.userRole ? user.userRole.rol_adi : "default kullanici",
      };
    });
    
    return res.status(200).send(modifiedUsers);
  } catch (error) {
    console.error("Get All Users Error:", error);
    return res.status(500).send(error);
  }
});


module.exports = router;
