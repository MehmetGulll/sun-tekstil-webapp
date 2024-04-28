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
exports.updateReport = async (req, res) => {
  try {
    const pool = await sql.connect(config);
    const { inspectionId, status } = req.body;
    const result = await pool
      .request()
      .input("inspectionId", sql.Int, inspectionId)
      .input("status", sql.Int, status)
      .query(
        `UPDATE denetim SET status = @status WHERE denetim_id = @inspectionId`
      );
    if (result.rowsAffected[0] > 0) {
      res.status(200).send({ message: "Report status updated success" });
    } else {
      res.status(404).send({ message: "Report is not found" });
    }
  } catch (error) {
    console.log("Error", error);
    res.status(500).send({ message: "Server error", error });
  }
};
exports.filterReports = async (req, res) => {
  try {
    const pool = await sql.connect(config);
    const inspectionTypeId = req.query.inspectionTypeId;
    const storeId = req.query.storeId;
    const inspectorRole = req.query.inspectorRole;
    const inspectorName = req.query.inspectorName;
    const inspectionDate = req.query.inspectionDate;
    const inspectionCompletionDate = req.query.inspectionCompletionDate;
    let query =
      "SELECT d.denetim_id AS inspectionId, dt.denetim_tipi AS inspectionTypeId, m.magaza_adi AS storeId, r.rol_adi AS inspectorRole, k.ad + ' ' + k.soyad AS inspectorName, d.alinan_puan AS pointsReceived, d.denetim_tarihi AS inspectionDate, d.denetim_tamamlanma_tarihi AS inspectionCompletionDate, d.status FROM denetim d INNER JOIN denetim_tipi dt ON d.denetim_tipi_id = dt.denetim_tip_id INNER JOIN magaza m ON d.magaza_id = m.magaza_id INNER JOIN kullanici k ON d.denetci_id = k.id INNER JOIN rol r ON k.rol = r.rol_id WHERE ";

    if (
      inspectionTypeId &&
      storeId &&
      inspectorRole &&
      inspectorName &&
      inspectionDate &&
      inspectionCompletionDate
    ) {
      query += `d.denetim_tipi_id LIKE '%${inspectionTypeId}%' AND m.magaza_id LIKE '%${storeId}%' AND r.rol_id LIKE '%${inspectorRole}%' AND (k.ad + ' ' + k.soyad) LIKE '%${inspectorName}%' AND d.denetim_tarihi LIKE '%${inspectionDate}%' AND d.denetim_tamamlanma_tarihi LIKE '%${inspectionCompletionDate}%' `;
    } else if (inspectionTypeId) {
      query += `d.denetim_tipi_id LIKE '%${inspectionTypeId}%' `;
    } else if (storeId) {
      query += `m.magaza_id LIKE '%${storeId}%' `;
    } else if (inspectorRole) {
      query += `r.rol_id LIKE '%${inspectorRole}%' `;
    } else if (inspectorName) {
      query += `(k.ad + ' ' + k.soyad) LIKE '%${inspectorName}%' `;
    } else if (inspectionDate) {
      query += `d.denetim_tarihi LIKE '%${inspectionDate}%' `;
    } else if (inspectionCompletionDate) {
      query += `d.denetim_tamamlanma_tarihi LIKE '%${inspectionCompletionDate}%' `;
    } else {
      query =
        "SELECT d.denetim_id AS inspectionId, dt.denetim_tip_id AS inspectionTypeId, m.magaza_id AS storeId, r.rol_adi AS inspectorRole, k.ad + ' ' + k.soyad AS inspectorName, d.alinan_puan AS pointsReceived, d.denetim_tarihi AS inspectionDate, d.denetim_tamamlanma_tarihi AS inspectionCompletionDate, d.status FROM denetim d INNER JOIN denetim_tipi dt ON d.denetim_tipi_id = dt.denetim_tip_id INNER JOIN magaza m ON d.magaza_id = m.magaza_id INNER JOIN kullanici k ON d.denetci_id = k.id INNER JOIN rol r ON k.rol = r.rol_id";
    }

    const result = await pool.request().query(query);
    const reports = result.recordset.map(
      (item) =>
        new Report(
          item.inspectionId,
          item.inspectionTypeId,
          item.storeId,
          item.inspectorRole,
          item.inspectorName,
          item.pointsReceived,
          item.inspectionDate,
          item.inspectionCompletionDate,
          item.status
        )
    );
    res.json(reports);
  } catch (error) {
    console.log("Error", error);
    res.status(500).send({ message: "Server error", error });
  }
};
