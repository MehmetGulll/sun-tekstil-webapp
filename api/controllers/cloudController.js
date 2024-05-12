const fs = require("fs");
const cloudConfig = require("../config/config");
const cloudinary = require("cloudinary").v2;

cloudinary.config(cloudConfig);

exports.sendCloudImage = (req, res) => {
  try {
    if(req.file && req.file.path){
      const file = fs.readFileSync(req.file.path);
      const encodedImage = file.toString("base64");
      cloudinary.uploader.upload(
        `data:${req.file.mimetype};base64,${encodedImage}`,
        (error, result) => {
          if (error) {
            res.status(500).send("Error", error);
          } else {
            res.send("File Upload!");
          }
          fs.unlinkSync(req.file.path);
        }
      );
    }else{
      console.log("Error file is not path");
    }
    
  } catch (error) {
    console.log("Error", error);
  }
};