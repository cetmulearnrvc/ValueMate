import SBIValuationFlat from "../models/flat_sbi_model.js";

import mongoose from "mongoose";

export const saveFlatData = async (req, res) => {
  console.log('A post req received');
  console.log(req.body);

  const flatData = req.body;
  flatData.typo = 'sbiFlat'; // Changed from 'sibFlat'

  if (flatData.valuationDetails) {
    try {
      flatData.valuationDetails = JSON.parse(flatData.valuationDetails);
      console.log('Parsed valuationDetails:', flatData.valuationDetails);
    } catch (err) {
      console.error('Failed to parse valuationDetails:', err);
      return res.status(400).json({
        success: false,
        message: "Invalid valuationDetails format"
      });
    }
  }

  // Validate images metadata
  let imagesMeta = [];
  try {
    imagesMeta = JSON.parse(flatData.images);
  } catch (err) {
    return res.status(400).json({
      success: false,
      message: "Invalid images metadata format"
    });
  }

  // Process uploaded images
  flatData.images = [];
  if (req.files && req.files.length > 0) {
    for (let i = 0; i < req.files.length; i++) {
      const meta = imagesMeta[i] || {};

      const imageData = {
        fileName: req.uploadedFiles[i].fileName,
        fileID: req.uploadedFiles[i].driveId,
        latitude: meta.latitude ? parseFloat(meta.latitude) : null,
        longitude: meta.longitude ? parseFloat(meta.longitude) : null
      };

      flatData.images.push(imageData);
    }
  } else {
    return res.status(400).json({
      success: false,
      message: "Please add at least one image"
    });
  }

  try {
    const existingDoc = await SBIValuationFlat.findOne({ refNo: flatData.refNo });

    let savedDoc;
    if (existingDoc) {
      // If document with same refNo exists ➔ Overwrite (Update)
      savedDoc = await SBIValuationFlat.findOneAndUpdate(
        { refNo: flatData.refNo },
        { $set: flatData },
        { new: true }  // Return the updated document
      );
      console.log('Document updated:', savedDoc._id);
      res.status(200).json({ status: true, data: savedDoc, message: "Existing record updated successfully" });

    } else {
      // If not exists ➔ Create new
      const newFlatData = new SBIValuationFlat(flatData);
      savedDoc = await newFlatData.save();
      console.log('New document created:', savedDoc._id);
      res.status(201).json({ status: true, data: savedDoc, message: "New record created successfully" });
    }
  } catch (err) {
    console.error(err);
    res.status(500).json({ status: false, message: "Server error" });
  }
};

export async function searchByDate(req, res) {
    const {date} = req.body;

    console.log(date);

    const targetDate = new Date(date);

    // Start of day (UTC)
    const start = new Date(targetDate.setUTCHours(0, 0, 0, 0));
    // End of day (UTC)
    const end = new Date(targetDate.setUTCHours(23, 59, 59, 999));

    const docs = await SBIValuationFlat.find({
        updatedAt: { $gte: start, $lte: end }
    });

    res.status(200).json(docs);
}

// Commented out nearby search functionality remains the same, just update model name if uncommented
/*
export const getNearbyFlat = async(req,res)=>{
  // ... same code but use SBIValuationFlat instead of SIBValuationFlat
}
*/