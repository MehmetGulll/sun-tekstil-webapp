const express = require("express");
const router = express.Router();
const Joi = require("joi");
const { Op } = require("sequelize");
const authenticateToken = require("../middlewares/authentication");
const { initializeSequelize } = require("../helpers/sequelize");
const {
  unvan,
  denetim_tipi,
  kullanici,
  unvanDenetimTipiLink,
  kullaniciDenetimTipiLink,
  denetim,
  magaza,
  bolge,
} = require("../helpers/sequelizemodels");
const { sendMail } = require("../helpers/mailer");
const bcrypt = require("bcrypt");

// MAİL YONETIM SAĞ TARAF
// Denetim Tipi ve Unvan ID yi kullanarak  unvanDenetimTipiLink tablosuna denetim_tipi ve unvan tablolarını birleştirir.
router.post("/linkUnvanDenetimTipi", authenticateToken, async (req, res) => {
  try {
    const schema = Joi.object({
      unvan_id: Joi.number().required(),
      denetim_tip_id: Joi.number().required(),
    });

    const { error } = schema.validate(req.body);
    if (error) return res.status(400).send(error.details[0].message);

    const { unvan_id, denetim_tip_id } = req.body;

    const sequelize = await initializeSequelize();
    const unvanDenetimTipiLinkModel = sequelize.define(
      "unvanDenetimTipiLink",
      unvanDenetimTipiLink,
      {
        timestamps: false,
        freezeTableName: true,
      }
    );

    const unvanModel = sequelize.define("unvan", unvan, {
      timestamps: false,
      freezeTableName: true,
    });

    const denetimTipiModel = sequelize.define("denetim_tipi", denetim_tipi, {
      timestamps: false,
      freezeTableName: true,
    });

    const isDenetimTipExist = await denetimTipiModel.findOne({
      where: {
        denetim_tip_id,
      },
    });

    if (!isDenetimTipExist) return res.status(404).send("Denetim tipi bulunamadı.");

    const isUnvanExist = await unvanModel.findOne({
      where: {
        unvan_id,
      },
    });

    if (!isUnvanExist) return res.status(404).send("Ünvan bulunamadı.");

    const isUnvanExistInDenetimTipiLink = await unvanDenetimTipiLinkModel.findOne({
      where: {
        unvan_id,
        denetim_tip_id,
      },
    });

    if (isUnvanExistInDenetimTipiLink) return res.status(400).send("Ünvan zaten bu denetim tipine bağlı.");

    const linkUnvanDenetimTipi = await unvanDenetimTipiLinkModel.create({
      unvan_id,
      denetim_tip_id,
    });

    return res.status(200).send(linkUnvanDenetimTipi);
  } catch (error) {
    console.error("Link Unvan Denetim Tipi Error:", error);
    return res.status;
  }
});

// Delete Unvan Denetim Tipi Link By ID
router.post("/deleteUnvanDenetimTipiLink", authenticateToken, async (req, res) => {
  if (req.user.rol_id !== 1 && req.user.rol_id !== 2) {
    return res.status(403).send("Kullanıcı ekleme yetkiniz yok!");
  }
  try {
    const schema = Joi.object({
      unvan_id: Joi.number().required(),
      denetim_tip_id: Joi.number().required(),
    });

    const { error } = schema.validate(req.body);
    if (error) return res.status(400).send(error.details[0].message);

    const { unvan_id, denetim_tip_id } = req.body;

    try {
      const sequelize = await initializeSequelize();
      const unvanDenetimTipiLinkModel = sequelize.define(
        "unvanDenetimTipiLink",
        unvanDenetimTipiLink,
        {
          timestamps: false,
          freezeTableName: true,
        }
      );
      const findData = await unvanDenetimTipiLinkModel.findOne({
        where: {
          [Op.and]: [{ unvan_id }, { denetim_tip_id }]
        },
      });

      if (!findData) return res.status(404).send("Veri bulunamadı.");

      const deleteUnvanDenetimTipiLink = await unvanDenetimTipiLinkModel.destroy({
        where: {
          id: findData.id,
        },
      });

      if (!deleteUnvanDenetimTipiLink) return res.status(404).send("Veri silinemedi.");

      return res.status(200).send("Başarıyla silindi.");
    } catch (error) {
      console.error("Delete Unvan Denetim Tipi Link Error:", error);
      return res.status(500).send("Sunucu hatası");
    }
  } catch (error) {
    console.error("Validation Error:", error);
    return res.status(500).send("Sunucu hatası");
  }
});


// Tüm Ünvanları listele
router.get("/getAllUnvan", authenticateToken, async (req, res) => {
  try {
    const sequelize = await initializeSequelize();
    const unvanModel = sequelize.define("unvan", unvan, {
      timestamps: false,
      freezeTableName: true,
    });

    const findAllUnvan = await unvanModel.findAll({
      attributes: ["unvan_id", "unvan_adi"],
      where: {status: 1,},
    });

    return res.status(200).send(findAllUnvan);
  } catch (error) {
    console.error("Get All Users Error:", error);
    return res.status(500).send(error);
  }
});  

// MAİL YONETIM SOL TARAF
// Denetim Tipi ve Kullanici ID yi kullanarak kullaniciDenetimTipiLink tablosuna denetim_tipi ve kullanici tablolarını birleştirir.
router.post("/linkKullaniciDenetimTipi", authenticateToken, async (req, res) => {
  try {
    const schema = Joi.object({
      denetim_tip_id: Joi.number().required(),
      kullanici_id: Joi.number().required(),
    });

    const { error } = schema.validate(req.body);
    if (error) return res.status(400).send(error.details[0].message);

    const { denetim_tip_id, kullanici_id } = req.body;

    const sequelize = await initializeSequelize();
    const kullaniciDenetimTipiLinkModel = sequelize.define(
      "kullaniciDenetimTipiLink",
      kullaniciDenetimTipiLink,
      {
        timestamps: false,
        freezeTableName: true,
      }
    );

    const kullaniciModel = sequelize.define("kullanici", kullanici, {
      timestamps: false,
      freezeTableName: true,
    });

    const denetimTipiModel = sequelize.define("denetim_tipi", denetim_tipi, {
      timestamps: false,
      freezeTableName: true,
    });

    const isDenetimTipExist = await denetimTipiModel.findOne({
      where: {
        denetim_tip_id,
      },
    });

    if (!isDenetimTipExist) return res.status(404).send("Denetim tipi bulunamadı.");
   
    const isUserExist = await kullaniciModel.findOne({
      where: {
        id: kullanici_id,
      },
    });

    if (!isUserExist) return res.status(404).send("Kullanıcı bulunamadı.");


    const isUserExistInDenetimTipiLink = await kullaniciDenetimTipiLinkModel.findOne({
      where: {
        denetim_tip_id,
        kullanici_id,
      },
    });

    if (isUserExistInDenetimTipiLink) return res.status(400).send("Kullanıcı zaten bu denetim tipine bağlı mail gönderimine sahip.");

    
    const linkKullaniciDenetimTipi = await kullaniciDenetimTipiLinkModel.create({
      denetim_tip_id,
      kullanici_id,
      ekleyen_id: req.user.id,
      status: 1,
    });

    return res.status(200).send(linkKullaniciDenetimTipi);
  } catch (error) {
    console.error("Link Kullanici Denetim Tipi Error:", error);
    return res.status(500).send(error);
  }
});

// Delete Kullanici Denetim Tipi Link By ID
router.post("/deleteKullaniciDenetimTipiLink", authenticateToken, async (req, res) => {
  if (req.user.rol_id !== 1 && req.user.rol_id !== 2) {
    return res.status(403).send("Kullanıcı ekleme yetkiniz yok!");
  }
  try {
    const schema = Joi.object({
      kullanici_id: Joi.number().required(),
      denetim_tip_id: Joi.number().required(),
    });

    const { error } = schema.validate(req.body);
    if (error) return res.status(400).send(error.details[0].message);

    const { kullanici_id, denetim_tip_id } = req.body;

    const sequelize = await initializeSequelize();
    const kullaniciDenetimTipiLinkModel = sequelize.define(
      "kullaniciDenetimTipiLink",
      kullaniciDenetimTipiLink,
      {
        timestamps: false,
        freezeTableName: true,
      }
    );

    const findData = await kullaniciDenetimTipiLinkModel.findOne({
      where: {
          [Op.and]: [{kullanici_id}, {denetim_tip_id}]
      },
    });


    if (!findData) return res.status(404).send("Veri bulunamadı.");

    const deleteKullaniciDenetimTipiLink = await kullaniciDenetimTipiLinkModel.destroy({
      where: {
        [Op.and]: [{kullanici_id}, {denetim_tip_id}]
      },
    });

    res.status(200).send("Veri başarıyla silindi.");
  } catch (error) {
    console.error("Delete Kullanici Denetim Tipi Link Error:", error);
    return res.status(500).send(error);
  }
});

// Sol taraf kullanıcılarını listeler
router.get("/getLinkKullaniciDenetimTipiKullanicilari", authenticateToken, async (req, res) => {
  try {
    const sequelize = await initializeSequelize();
    const kullaniciModel = sequelize.define("kullanici", kullanici, {
      timestamps: false,
      freezeTableName: true,
    });

    const denetimTipiModel = sequelize.define("denetim_tipi", denetim_tipi, {
      timestamps: false,
      freezeTableName: true,
    });

    const kullaniciDenetimTipiLinkModel = sequelize.define(
      "kullaniciDenetimTipiLink",
      kullaniciDenetimTipiLink,{
        timestamps: false,
        freezeTableName: true,
      }
    );

    denetimTipiModel.hasMany(kullaniciDenetimTipiLinkModel, {
      foreignKey: "denetim_tip_id",
    });

    kullaniciModel.hasMany(kullaniciDenetimTipiLinkModel, {
      foreignKey: "kullanici_id",
    });

    kullaniciDenetimTipiLinkModel.belongsTo(denetimTipiModel, {
      foreignKey: "denetim_tip_id",
    });

    kullaniciDenetimTipiLinkModel.belongsTo(kullaniciModel, {
      foreignKey: "kullanici_id",
    });



    const findAllUsersRelatedDenetimTipi = await kullaniciDenetimTipiLinkModel.findAll({
      where: {
        status: 1,
      },
      attributes: ["id", "denetim_tip_id", "kullanici_id"],
      include: [
        {
          model: denetimTipiModel,
          attributes: ["denetim_tip_id", "denetim_tipi"],
        },
        {
          model: kullaniciModel,
          attributes: ["id", "ad", "soyad", "eposta", "unvan_id"],
        },
      ],
    });

    const modifiedData = findAllUsersRelatedDenetimTipi.map((item) => { 
      return {
        id: item.id,
        kullanici_id: item.kullanici_id,
        kullanici: item.kullanici.ad + " " + item.kullanici.soyad,
        eposta: item.kullanici.eposta,
        denetim_tip_id: item.denetim_tip_id,
        denetim_tipi: item.denetim_tipi.denetim_tipi,
      };
    });

    return res.status(200).send(modifiedData);
  } catch (error) {
    console.error("Get Link Kullanici Denetim Tipi Kullanicilari Error:", error);
    return
  }
});

// linkKullaniciDenetimTipi verilerini güncelleme   SİLİNECEK 
router.post("/updateKullaniciDenetimTipiLink", authenticateToken, async (req, res) => {
  if (req.user.rol_id !== 1 && req.user.rol_id !== 2) {
    return res.status(403).send("Verileri güncelleme yetkiniz yok!");
  }
  try {
    const schema = Joi.object({
      id: Joi.number().required(),
      denetim_tip_id: Joi.number().optional(),
      kullanici_id: Joi.number().optional(),
      status: Joi.number().optional(),
    });

    const { error } = schema.validate(req.body);
    if (error) return res.status(400).send(error.details[0].message);

    const { id, denetim_tip_id, kullanici_id, status } = req.body;

    const sequelize = await initializeSequelize();
    const kullaniciDenetimTipiLinkModel = sequelize.define(
      "kullaniciDenetimTipiLink",
      kullaniciDenetimTipiLink,
      {
        timestamps: false,
        freezeTableName: true,
      }
    );

    const denetimTipiModel = sequelize.define("denetim_tipi", denetim_tipi, {
      timestamps: false,
      freezeTableName: true,
    });

    const kullaniciModel = sequelize.define("kullanici", kullanici, {
      timestamps: false,
      freezeTableName: true,
    });

    const findData = await kullaniciDenetimTipiLinkModel.findOne({
      where: {
        id,
      },
    });

    if (!findData) return res.status(404).send("Veri bulunamadı.");

    if (denetim_tip_id) {
      const isDenetimTipExist = await denetimTipiModel.findOne({
        where: {
          denetim_tip_id,
        },
      });

      if (!isDenetimTipExist) return res.status(404).send("Denetim tipi bulunamadı.");
    }

    if (kullanici_id) {
      const isUserExist = await kullaniciModel.findOne({
        where: {
          id: kullanici_id,
        },
      });

      if (!isUserExist) return res.status(404).send("Kullanıcı bulunamadı.");
    }

    const updateKullaniciDenetimTipiLink = await kullaniciDenetimTipiLinkModel.update(
      {
        denetim_tip_id : denetim_tip_id ? denetim_tip_id : findData.denetim_tip_id,
        kullanici_id : kullanici_id ? kullanici_id : findData.kullanici_id,
        status,
        guncelleyen_id: req.user.id,
      },
      {
        where: {
          id,
        },
      }
    );

    return res.status(200).send("Veri başarıyla güncellendi.");
  } catch (error) {
    console.error("Update Kullanici Denetim Tipi Link Error:", error);
    return res.status(500).send(error);
  }
});

router.get("/getAllUsersByRelatedDenetimTipi",authenticateToken,async (req, res) => {
    try {
      const sequelize = await initializeSequelize();
      const unvanModel = sequelize.define("unvan", unvan, {
        timestamps: false,
        freezeTableName: true,
      });

      const denetimTipiModel = sequelize.define("denetim_tipi", denetim_tipi, {
        timestamps: false,
        freezeTableName: true,
      });

      const kullaniciModel = sequelize.define("kullanici", kullanici, {
        timestamps: false,
        freezeTableName: true,
      });

      const unvanDenetimTipiLinkModel = sequelize.define(
        "unvanDenetimTipiLink",
        unvanDenetimTipiLink,
        {
          timestamps: false,
          freezeTableName: true,
        }
      );

      unvanModel.hasMany(unvanDenetimTipiLinkModel, {
        foreignKey: "unvan_id",
      });
      denetimTipiModel.hasMany(unvanDenetimTipiLinkModel, {
        foreignKey: "denetim_tip_id",
      });

      unvanDenetimTipiLinkModel.belongsTo(unvanModel, {
        foreignKey: "unvan_id",
      });
      unvanDenetimTipiLinkModel.belongsTo(denetimTipiModel, {
        foreignKey: "denetim_tip_id",
      });

      denetimTipiModel.belongsTo(kullaniciModel, {
        foreignKey: "denetim_tip_id",
      });

      unvanModel.belongsTo(kullaniciModel, {
        foreignKey: "unvan_id",
        targetKey: "unvan_id",
      });

      const findAllUsers = await kullaniciModel.findAll({
        attributes: ["id", "ad", "soyad", "eposta", "unvan_id"],
        order: [["unvan_id", "ASC"]],
      });

      const findDenetimTipiByUnvan = await denetimTipiModel.findAll({
        include: [
          {
            model: unvanDenetimTipiLinkModel,
            include: [
              {
                model: unvanModel,
                attributes: ["unvan_id", "unvan_adi"],
              },
            ],
          },
        ],
        attributes: ["denetim_tip_id", "denetim_tipi"],
      });

      const findAllUnvanlar = await unvanModel.findAll({
        attributes: ["unvan_id", "unvan_adi"],
        where: { status: 1 },
      });

      const modifiedData = findDenetimTipiByUnvan.map((item) => {
        const unvanlar = [];
        const addedUnvanIds = []; 
      
        item.unvanDenetimTipiLinks.forEach((link) => {
          const unvan_id = link.unvan.unvan_id;
          
          const existingIndex = addedUnvanIds.indexOf(unvan_id);
          
          if (existingIndex === -1) { 
            addedUnvanIds.push(unvan_id); 
            
            unvanlar.push({
              aktif: 1,
              unvan_id: unvan_id,
              unvan_adi: link.unvan.unvan_adi,
              kullanicilar: findAllUsers.filter((user) => user.unvan_id === unvan_id), 
            });
          } else { 
            if (link.aktif === 1) {
              unvanlar[existingIndex].aktif = 1;
            }
          }
        });
      
        findAllUnvanlar.forEach((unvan) => {
          if (addedUnvanIds.indexOf(unvan.unvan_id) === -1) {
            unvanlar.push({
              aktif: 0,
              unvan_id: unvan.unvan_id,
              unvan_adi: unvan.unvan_adi,
              kullanicilar: findAllUsers.filter((user) => user.unvan_id === unvan.unvan_id),
            });
          }
        });
      
        return {
          denetim_tip_id: item.denetim_tip_id,
          denetim_tipi: item.denetim_tipi,
          unvanlar: unvanlar,
        };
      });
      
      return res.status(200).send(modifiedData);
      
    } catch (error) {
      console.error("Add Title Error:", error);
     return res.status(500).send(error.message);
    }
  }
);

// MAİL GÖNDERME ENDPOINTİ
router.post("/sendEmail", async (req, res) => {
  try {
    const schema = Joi.object({
      denetim_id: Joi.number().required(),
    });

    const { error } = schema.validate(req.body);
    if (error) return res.status(400).send(error.details[0].message);
    const { denetim_id } = req.body;

    const sequelize = await initializeSequelize();

    const kullaniciModel = sequelize.define("kullanici", kullanici, {
      timestamps: false,
      freezeTableName: true,
    });

    const denetimModel = sequelize.define("denetim", denetim, {
      timestamps: false,
      freezeTableName: true,
    });

    const denetimTipiModel = sequelize.define("denetim_tipi", denetim_tipi, {
      timestamps: false,
      freezeTableName: true,
    });

    const magazaModel = sequelize.define("magaza", magaza, {
      timestamps: false,
      freezeTableName: true,
    });

    const unvanDenetimTipiLinkModel = sequelize.define(
      "unvanDenetimTipiLink",
      unvanDenetimTipiLink,
      {
        timestamps: false,
        freezeTableName: true,
      }
    );
    const bolgeModel = sequelize.define("bolge", bolge, {
      timestamps: false,
      freezeTableName: true,
    });

    const kullaniciDenetimTipiLinkModel = sequelize.define( "kullaniciDenetimTipiLink", kullaniciDenetimTipiLink, {
      timestamps: false,
      freezeTableName: true,
    });

    kullaniciDenetimTipiLinkModel.belongsTo(denetimTipiModel, {
      foreignKey: "denetim_tip_id",
    });

    kullaniciDenetimTipiLinkModel.belongsTo(kullaniciModel, {
      foreignKey: "kullanici_id",
    });

    magazaModel.belongsTo(bolgeModel, {
      foreignKey: "bolge_id",
    });

    bolgeModel.belongsTo(kullaniciModel, {
      foreignKey: "bolge_muduru",
      targetKey: "id",
    });

    denetimModel.belongsTo(magazaModel, {
      foreignKey: "magaza_id",
    });

    denetimModel.belongsTo(denetimTipiModel, {
      foreignKey: "denetim_tipi_id",
    });

    denetimModel.belongsTo(kullaniciModel, {
      foreignKey: "denetci_id",
      targetKey: "id",
    });

    magazaModel.belongsTo(kullaniciModel, {
      foreignKey: "magaza_muduru",
      targetKey: "id",
    });

    const getDenetim = await denetimModel.findOne({
      where: {
        denetim_id,
      },
      include: [
        {
          model: kullaniciModel,
          attributes: ["ad", "soyad", "eposta", "unvan_id"],
        },
        {
          model: denetimTipiModel,
          attributes: ["denetim_tip_id", "denetim_tipi"],
        },
        {
          model: magazaModel,
          attributes: [
            "magaza_id",
            "magaza_adi",
            "magaza_tipi",
            "bolge_id",
            "sehir",
            "magaza_telefon",
            "magaza_muduru",
            "magaza_eposta",
          ],
          include: [
            {
              model: bolgeModel,
              attributes: ["bolge_id", "bolge_adi", "bolge_muduru"],
              include: [
                {
                  model: kullaniciModel,
                  attributes: ["ad", "soyad", "eposta", "unvan_id"],
                },
              ],
            },
            {
              model: kullaniciModel,
              attributes: ["ad", "soyad", "eposta", "unvan_id"],
            },
          ],
        },
      ],
    });

    if (!getDenetim) return res.status(404).send("Denetim bulunamadı.");

    const findAllUnvanId = await unvanDenetimTipiLinkModel.findAll({
      where: {
        denetim_tip_id: getDenetim.denetim_tipi_id,
      },
    });
    const findAllMail = findAllUnvanId.map((item) => {
      return item.unvan_id;
    });

    const findAllUsersMailRelatedDenetimTipi = await kullaniciDenetimTipiLinkModel.findAll({
      where: {
        denetim_tip_id: getDenetim.denetim_tipi_id,
        status: 1,
      },
      attributes: ["id", "denetim_tip_id"],
      include: [
        {
          model: kullaniciModel,
          attributes: ["id", "ad", "soyad", "eposta", "unvan_id"],
        },
        {
          model: denetimTipiModel,
          attributes: ["denetim_tip_id", "denetim_tipi"],
        }
      ],
    });

    const modifiedUsersMailRelatedDenetimTipi = findAllUsersMailRelatedDenetimTipi.map((item) => { 
      return {
        id: item.id,
        denetim_tip_id: item.denetim_tip_id,
        kullanici: item.kullanici.ad + " " + item.kullanici.soyad,
        eposta: item.kullanici.eposta,
        denetim_tipi: item.denetim_tipi.denetim_tipi,
      }; 
    });
    

    const findAllUsersRelatedUnvan = await kullaniciModel.findAll({
      where: {
        unvan_id: findAllMail,
        status: 1,
      },
      attributes: ["id", "ad", "soyad", "eposta", "unvan_id"],
      order: [["unvan_id", "ASC"]],
    });

    const textContent = `
      Denetim Bilgilendirme Dökümanı
        
      Merhaba,
        
      İşte denetimle ilgili bilgiler:
        
      - Denetim ID: ${getDenetim.denetim_id}
      - Denetim Tipi: ${getDenetim.denetim_tipi.denetim_tipi}
      - Denetleyen: ${getDenetim.kullanici.ad} ${getDenetim.kullanici.soyad}
      - Magaza Adı: ${getDenetim.magaza.magaza_adi}
      - Magaza Müdürü: ${getDenetim.magaza.kullanici.ad} ${getDenetim.magaza.kullanici.soyad}
      - Magaza Bölgesi: ${getDenetim.magaza.bolge.bolge_adi}
      - Bölge Müdürü: ${getDenetim.magaza.bolge.kullanici.ad} ${getDenetim.magaza.bolge.kullanici.soyad}
      - Magaza Şehir: ${getDenetim.magaza.sehir}
      - Denetim Tarihi: ${getDenetim.denetim_tarihi}
      - Denetim Puanı: ${getDenetim.alinan_puan}

      Denetim dökümanını ekte bulabilirsiniz.

      İyi çalışmalar dileriz.
    `;

    const htmlContent = `
    <!DOCTYPE html>
    <html lang="en">
    
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <!DOCTYPE html>
        <html lang="en">
        
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Denetim Bilgilendirme Dökümanı</title>
            <style>
                body {
                    font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
                    background-color: #f8f9fa;
                    margin: 0;
                    padding: 0;
                }
        
                .container {
                    margin: 50px auto;
                    padding: 20px;
                    background-color: #fff;
                    border-radius: 8px;
                    box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
                }
        
                h2 {
                    color: #333;
                    font-size: 24px;
                    margin: 0 0 20px;
                    padding: 0;
                }
        
                p {
                    color: #666;
                    font-size: 16px;
                    margin: 0 0 10px;
                    padding: 0;
                }
        
                ul {
                    padding-left: 20px;
                    margin: 0 0 20px;
                    list-style-type: none;
                }
        
                ul li {
                    color: #444;
                    font-size: 16px;
                    margin-bottom: 10px;
                    padding-left: 10px;
                    position: relative;
                }
        
                ul li:before {
                    content: "●"; /* Yuvarlak işaret */
                    color: #007bff;
                    font-size: 16px;
                    position: absolute;
                    left: -20px;
                }
            </style>
        </head>
        
        <body>
            <div class="container">
                <h2>Denetim Bilgilendirme Dökümanı</h2>
                <p>Merhaba,</p>
                <p>İşte denetimle ilgili bilgiler:</p>
                <ul>
                    <li><strong>Denetim ID:</strong> ${getDenetim.denetim_id}</li>
                    <li><strong>Denetim Tipi:</strong> ${getDenetim.denetim_tipi.denetim_tipi}</li>
                    <li><strong>Denetleyen:</strong> ${getDenetim.kullanici.ad} ${getDenetim.kullanici.soyad}</li>
                    <li><strong>Magaza Adı:</strong> ${getDenetim.magaza.magaza_adi}</li>
                    <li><strong>Magaza Müdürü:</strong> ${getDenetim.magaza.kullanici.ad} ${getDenetim.magaza.kullanici.soyad}</li>
                    <li><strong>Magaza Bölgesi:</strong> ${getDenetim.magaza.bolge.bolge_adi}</li>
                    <li><strong>Bölge Müdürü:</strong> ${getDenetim.magaza.bolge.kullanici.ad} ${getDenetim.magaza.bolge.kullanici.soyad}</li>
                    <li><strong>Magaza Şehir:</strong> ${getDenetim.magaza.sehir}</li>
                    <li><strong>Denetim Tarihi:</strong> ${getDenetim.denetim_tarihi}</li>
                    <li><strong>Denetim Puanı:</strong> ${getDenetim.alinan_puan}</li>
                </ul>
                <p>Denetim dökümanını ekte bulabilirsiniz.</p>
                <p>İyi çalışmalar dileriz.</p>
            </div>
        </body>
        
        </html>
        
     `;
    const mailOptions = {
      from: {
        name: ` ${getDenetim.denetim_tipi.denetim_tipi}'i Bilgilendirme Dökümanı`,
        address: "sunteks64039@gmail.com",
      },
      to: [
        findAllUsersRelatedUnvan.map((item) => item.eposta).join(","),
        getDenetim.kullanici.eposta, // Denetleyen
        getDenetim.magaza.bolge.kullanici.eposta, // Bölge Müdürü
        getDenetim.magaza.magaza_eposta, // Mağaza e-posta
        getDenetim.magaza.kullanici.eposta, // Mağaza Müdürü
        // Eğer varsa Denetim Tipi'ne bağlı kullanıcılar 
        modifiedUsersMailRelatedDenetimTipi.map((item) => item.eposta).join(","),
      ],
      subject: `${getDenetim.magaza.magaza_adi} Mağazası ${getDenetim.denetim_tipi.denetim_tipi}'i Dökümanı`,
      // text: textContent,
      html: htmlContent,
      // attachments: [
      //   {
      //     filename: "denetim_dokumani.pdf",
      //     path: "https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf",
      //   },
      //   {
      //     filename: "logo.png",
      //     path: "routers/logo.png",
      //   },
      //   {
      //     filename: "test.pdf",
      //     path: "routers/test.pdf",
      //   },
      // ],
    };

    return res.status(200).send(await sendMail(mailOptions));
  } catch (error) {
    console.error("Mail gönderme hatası:", error);
    return res.status(500).send("Mail gönderme hatası!", error.message);
  }
});

// Tüm Denetim Tiplerini Listeler
router.get("/getAllDenetimTipi", authenticateToken, async (req, res) => {
  try {
    const sequelize = await initializeSequelize();
    const denetimTipiModel = sequelize.define("denetim_tipi", denetim_tipi, {
      timestamps: false,
      freezeTableName: true,
    });

    const findAllDenetimTipi = await denetimTipiModel.findAll({
      attributes: ["denetim_tip_id", "denetim_tipi"],
    });

    return res.status(200).send(findAllDenetimTipi);
  } catch (error) {
    console.error("Get All Denetim Tipi Error:", error);
    return res.status(500).send(error);
  }
});

// Tüm Kullanıcıları Listeler
router.get("/getAllUsers", authenticateToken, async (req, res) => {
  try {
    const sequelize = await initializeSequelize();
    const kullaniciModel = sequelize.define("kullanici", kullanici, {
      timestamps: false,
      freezeTableName: true,
    });

    const findAllUsers = await kullaniciModel.findAll({
      attributes: ["id", "ad", "soyad", "eposta", "unvan_id"],
    });

    return res.status(200).send(findAllUsers);
  } catch (error) {
    console.error("Get All Users Error:", error);
    return res.status(500).send(error);
  }
});


// send mail for forgot password to the user with check username and email match and find that user in the database and send mail to the user with a link to reset password 
router.post("/forgotPassword", async (req, res) => {
  try {
    const schema = Joi.object({
      kullanici_adi: Joi.string().required(),
      eposta: Joi.string().email().required()
    });

    const { error } = schema.validate(req.body);
    if (error) return res.status(400).send(error.details[0].message);

    const { kullanici_adi, eposta } = req.body;

    const sequelize = await initializeSequelize();
    const kullaniciModel = sequelize.define("kullanici", kullanici, {
      timestamps: false,
      freezeTableName: true,
    });

    const findUser = await kullaniciModel.findOne({
      where: {
        kullanici_adi: kullanici_adi,
        eposta: eposta,
      },
    });

    if (!findUser) return res.status(404).send("Kullanıcı bulunamadı.");
    // random password with uppercase and lowercase letters and numbers
    const randomPassword = Math.random().toString(36).slice(-8);
    const hashedPassword = await bcrypt.hash(randomPassword, 10);

    // update the user password and send it to the user with mail
    const updatePassword = await kullaniciModel.update(
      {
        sifre: hashedPassword,
      },
      {
        where: {
          id: findUser.id,
        },
      }
    );      

    const textContent = `
      <h1>Şifre Sıfırlama</h1>
      <p>Merhaba ${findUser.ad} ${findUser.soyad},</p>
      <>Yeni şifreniz aşağıdaki gibidir:</p>
      <p>Şifreniz: ${randomPassword}</p>

      <p>İyi çalışmalar dileriz. Şifrenizi kimselerle paylaşmayınız.</p>
  `;


    const mailOptions = {
      from: {
        name: "Şifre Sıfırlama",
        address: "sunteks64039@gmail.com",
      },
      to: findUser.eposta,
      subject: "Şifre Sıfırlama",
      html: textContent, 
    };

    return res.status(200).send(await sendMail(mailOptions));
  } catch (error) {
    console.error("Forgot Password Error:", error);
    return res.status(500).send(error);
  } 
}
);

module.exports = router;
