const fs = require("fs");
const cloudConfig = require("../config/cloudConfig");
const cloudinary = require("cloudinary").v2;
const Image = require("../helpers/imageModels");
cloudinary.config(cloudConfig);
const sql = require("mssql");
const config = require("../config/config");

exports.sendCloudImage = async (req, res) => {
  try {
    const pool = await sql.connect(config);
    if (req.file && req.file.path) {
      const file = fs.readFileSync(req.file.path);
      const encodedImage = file.toString("base64");
      cloudinary.uploader.upload(
        `data:${req.file.mimetype};base64,${encodedImage}`,
        async (error, uploadResult) => {
          if (error) {
            res.status(500).send("Error", error);
          } else {
            const result = await pool.request().query(`
              INSERT INTO image (public_id)
              VALUES ('${uploadResult.public_id}')
            `);
            res.status(200).send({ public_id: uploadResult.public_id });
          }
          fs.unlinkSync(req.file.path);
        }
      );
    } else {
      console.log("Error: file path is not provided");
    }
  } catch (error) {
    console.log("Error", error);
  }
};
