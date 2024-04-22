const express = require("express");
const sql = require("mssql");
const config = require("../config/config");
const Report = require("../helpers/reportModels");

exports.getReports = async (req, res) => {
  try {
    const pool = await sql.connect(config);
    const result = await pool.request().query(`
          SELECT d.denetim_id AS inspectionId, dt.denetim_tipi AS inspectionTypeId, m.magaza_adi AS storeId, r.rol_adi AS inspectorRole, k.ad + ' ' + k.soyad AS inspectorName, d.alinan_puan AS pointsReceived, d.denetim_tarihi AS inspectionDate, d.denetim_tamamlanma_tarihi AS inspectionCompletionDate, d.status 
          FROM denetim d 
          INNER JOIN denetim_tipi dt ON d.denetim_tipi_id = dt.denetim_tip_id 
          INNER JOIN magaza m ON d.magaza_id = m.magaza_id 
          INNER JOIN kullanici k ON d.denetci_id = k.id 
          INNER JOIN rol r ON k.rol = r.rol_id
          GROUP BY d.denetim_id, dt.denetim_tipi, m.magaza_adi, r.rol_adi, k.ad, k.soyad, d.alinan_puan, d.denetim_tarihi, d.denetim_tamamlanma_tarihi, d.status`);
    const reports = result.recordset.map(
      (row) =>
        new Report(
          row.inspectionId,
          row.inspectionTypeId,
          row.storeId,
          row.inspectorRole,
          row.inspectorName,
          row.pointsReceived,
          row.inspectionDate,
          row.inspectionCompletionDate,
          row.status
        )
    );
    res.status(200).send(reports);
  } catch (error) {
    console.log("Error", error);
    res.status(500).send({ message: "Server Error", error });
  }
};

exports.deleteReport = async (req, res) => {
  try {
    const pool = await sql.connect(config);
    const { inspectionId } = req.params;
    const result = await pool
      .request()
      .input("inspectionId", sql.Int, inspectionId)
      .query("DELETE FROM denetim WHERE denetim_id = @inspectionId");
    res.status(200).send({ message: "Report deleted successfully.!" });
    console.log(result);
    console.log(inspectionId);
  } catch (error) {
    console.log("Error", error);
    res.status(500).send({ message: "Server Error", error });
  }
};
