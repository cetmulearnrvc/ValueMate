import SBIVacantLandValuation from "../models/vacantland_sbi_model.js";
import crypto from "crypto";
import mongoose from "mongoose";
import cloudinary from "../cloudinaryConfig.js";

// Save vacant land valuation with file uploads
export const saveVacantLand = async (req, res) => {
  try {
    const landData = req.body;
    // landData.typo = "sibVacantLand";

    // // Parse JSON fields if they exist as strings
    // const jsonFields = ['landValuationDetails', 'boundaries', 'dimensions', 'valuerComments'];
    // jsonFields.forEach(field => {
    //   if (landData[field] && typeof landData[field] === 'string') {
    //     landData[field] = JSON.parse(landData[field]);
    //   }
    // });

    // Process uploaded images
    // if (req.files && req.files.length > 0) {
    //   landData.images = req.files.map(file => ({
    //     fileName: file.filename,
    //     filePath: file.path,
    //     latitude: req.body.imageLatitude ? parseFloat(req.body.imageLatitude) : null,
    //     longitude: req.body.imageLongitude ? parseFloat(req.body.imageLongitude) : null
    //   }));
    // } else {
    //   return res.status(400).json({
    //     success: false,
    //     message: "At least one image is required"
    //   });
    // }
    landData.images=[];
    if (req.files && req.files.length > 0) {
          for (let i = 0; i < req.files.length; i++) {
            // const meta = imagesMeta[i] || {};
            const hash = crypto.createHash("sha256").update(req.files[i].buffer).digest("hex");
            // console.log(hash);
            // Upload file buffer to Cloudinary
            const result = await new Promise((resolve, reject) => {
              const stream = cloudinary.uploader.upload_stream(
                { resource_type: "image",
                  type:"authenticated",
                    public_id: hash,    // <-- use hash as unique ID
                    overwrite: false    // <-- prevents overwriting if same hash exists
                 },
                (error, result) => {
                  if (error) reject(error);
                  else resolve(result);
                }
              );
              stream.end(req.files[i].buffer); // << file buffer
            });
        
            const imageData = {
              fileName: result.public_id, // Cloudinary URL
              // latitude: meta.latitude ? String(meta.latitude) : null,
              // longitude: meta.longitude ? String(meta.longitude) : null
            };
        
            landData.images.push(imageData);
          }
        }

    // Check if document exists and update or create new
    const existingDoc = await SBIVacantLandValuation.findOne({ refNo: landData.refNo });
    const savedDoc = existingDoc 
      ? await SBIVacantLandValuation.findOneAndUpdate(
          { refNo: landData.refNo },
          { $set: landData },
          { new: true }
        )
      : await SBIVacantLandValuation.create(landData);

    res.status(existingDoc ? 200 : 201).json({
      success: true,
      message: existingDoc ? "Record updated" : "Record created",
      data: savedDoc
    });

  } catch (error) {
    // console.error("Save error:", error);
    res.status(500).json({
      success: false,
      message: "Server error",
      error: error.message
    });
  }
};

// Get nearby vacant land valuations
export const getNearbyVacantLands = async (req, res) => {
  try {
    const { latitude, longitude, maxDistance = 10 } = req.query; // maxDistance in km

    if (!latitude || !longitude) {
      return res.status(400).json({
        success: false,
        message: "Latitude and longitude are required"
      });
    }

    const lat = parseFloat(latitude);
    const lng = parseFloat(longitude);
    const distance = parseFloat(maxDistance);

    const allLands = await SBIVacantLandValuation.find({
      'images.latitude': { $exists: true, $ne: null },
      'images.longitude': { $exists: true, $ne: null }
    });

    const nearbyLands = allLands.reduce((results, land) => {
      land.images.forEach(image => {
        if (image.latitude && image.longitude) {
          const imgLat = parseFloat(image.latitude);
          const imgLng = parseFloat(image.longitude);
          const dist = calculateDistance(lat, lng, imgLat, imgLng);

          if (dist <= distance) {
            results.push({
              id: land._id,
              refNo: land.refNo,
              distance: dist,
              coordinates: { latitude: imgLat, longitude: imgLng },
              marketValue: land.presentMarketValue,
              address: land.addressAsPerActual,
              imagePath: image.filePath
            });
          }
        }
      });
      return results;
    }, []);

    nearbyLands.sort((a, b) => a.distance - b.distance);

    res.status(200).json({
      success: true,
      count: nearbyLands.length,
      data: nearbyLands
    });

  } catch (error) {
    // console.error("Nearby search error:", error);
    res.status(500).json({
      success: false,
      message: "Failed to find nearby lands",
      error: error.message
    });
  }
};

// Get valuations by date
export const searchByDate = async (req, res) => {
  try {
    const { date } = req.body;

    // if (!date) {
    //   return res.status(400).json({
    //     success: false,
    //     message: "Date parameter is required"
    //   });
    // }

    const targetDate = new Date(date);
    const start = new Date(targetDate.setUTCHours(0, 0, 0, 0));
    const end = new Date(targetDate.setUTCHours(23, 59, 59, 999));

    const lands = await SBIVacantLandValuation.find({
      updatedAt: { $gte: start, $lte: end }
    });

    res.status(200).json(lands);

  } catch (error) {
    // console.error("Date search error:", error);
    res.status(500).json({
      success: false,
      message: "Failed to fetch by date",
      error: error.message
    });
  }
};

// Helper function for distance calculation
function calculateDistance(lat1, lon1, lat2, lon2) {
  const R = 6371; // Earth's radius in km
  const dLat = (lat2 - lat1) * Math.PI / 180;
  const dLon = (lon2 - lon1) * Math.PI / 180;
  const a = 
    Math.sin(dLat/2) * Math.sin(dLat/2) +
    Math.cos(lat1 * Math.PI / 180) * Math.cos(lat2 * Math.PI / 180) * 
    Math.sin(dLon/2) * Math.sin(dLon/2);
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
  return R * c;
}