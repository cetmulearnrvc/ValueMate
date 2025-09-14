import IDBIValuation from "../models/idbi_model.js";
import crypto from "crypto";
import mongoose from "mongoose";
import cloudinary from "../cloudinaryConfig.js";

export const saveIDBIValuation = async (req, res) => {
    console.log("Received IDBI Valuation submission");
    
    const valuationData = req.body;
    
    // Validate required fields
    if (!valuationData.applicationNo) {
        return res.status(400).json({
            success: false,
            message: "Application number is required"
        });
    }

    // Process images if present
    let imagesMeta = [];
    if (valuationData.images) {
        try {
            imagesMeta = JSON.parse(valuationData.images);
        } catch (err) {
            return res.status(400).json({
                success: false,
                message: "Invalid images metadata format"
            });
        }
    }

    // Prepare images data
    valuationData.images = [];
    if (req.files && req.files.length > 0) {
  for (let i = 0; i < req.files.length; i++) {
    const meta = imagesMeta[i] || {};
    const hash = crypto.createHash("sha256").update(req.files[i].buffer).digest("hex");
    // console.log(hash);
    // Upload file buffer to Cloudinary
    const result = await new Promise((resolve, reject) => {
      const stream = cloudinary.uploader.upload_stream(
        { resource_type: "image",
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
      fileName: result.secure_url, // Cloudinary URL
      latitude: meta.latitude ? String(meta.latitude) : null,
      longitude: meta.longitude ? String(meta.longitude) : null
    };

    valuationData.images.push(imageData);
  }
}


    try {
        // Upsert based on application number
        const savedValuation = await IDBIValuation.findOneAndUpdate(
            { applicationNo: valuationData.applicationNo },
            {$set:valuationData},
            {
                upsert: true,
                new: true,
            }
        );
        
        res.status(201).json({
            success: true,
            data: savedValuation
        });
    } catch (err) {
        console.error("Error saving IDBI valuation:", err);
        res.status(500).json({
            success: false,
            message: "Server error while saving valuation",
            error: err.message
        });
    }
};

export const getNearbyIDBIValuations = async (req, res) => {
    console.log("Received nearby IDBI valuations request");
    
    const { latitude, longitude, maxDistance = 1 } = req.body; // Default 1km radius
    
    // Validate coordinates
    if (!latitude || !longitude) {
        return res.status(400).json({
            success: false,
            message: "Latitude and longitude are required"
        });
    }

    try {
        const lat = parseFloat(latitude);
        const lng = parseFloat(longitude);
        
        // Validate coordinate ranges
        if (isNaN(lat) || lat < -90 || lat > 90 || 
            isNaN(lng) || lng < -180 || lng > 180) {
            return res.status(400).json({
                success: false,
                message: "Invalid coordinates provided"
            });
        }

        // Find valuations with nearby coordinates
        const valuations = await IDBIValuation.find({
            $or: [
                { nearbyLatitude: { $exists: true }, nearbyLongitude: { $exists: true } },
                { "images.latitude": { $exists: true }, "images.longitude": { $exists: true } }
            ]
        });

        // Filter and calculate distances
        const nearbyValuations = [];
        for (const valuation of valuations) {
            // Check main coordinates
            if (valuation.nearbyLatitude && valuation.nearbyLongitude) {
                const distance = haversineDistance(
                    lat, lng,
                    parseFloat(valuation.nearbyLatitude),
                    parseFloat(valuation.nearbyLongitude)
                );
                
                if (distance <= maxDistance) {
                    nearbyValuations.push({
                        distance,
                        applicationNo: valuation.applicationNo,
                        propertyLocation: valuation.postalAddress,
                        marketValue: valuation.grandTotalMarketValue,
                        coordinates: {
                            latitude: valuation.nearbyLatitude,
                            longitude: valuation.nearbyLongitude
                        },
                        source: "property"
                    });
                }
            }

            // Check image coordinates
            for (const image of valuation.images) {
                if (image.latitude && image.longitude) {
                    const distance = haversineDistance(
                        lat, lng,
                        parseFloat(image.latitude),
                        parseFloat(image.longitude)
                    );
                    
                    if (distance <= maxDistance) {
                        nearbyValuations.push({
                            distance,
                            applicationNo: valuation.applicationNo,
                            propertyLocation: valuation.postalAddress,
                            marketValue: valuation.grandTotalMarketValue,
                            coordinates: {
                                latitude: image.latitude,
                                longitude: image.longitude
                            },
                            source: "image"
                        });
                    }
                }
            }
        }

        // Sort by distance
        nearbyValuations.sort((a, b) => a.distance - b.distance);

        res.status(200).json({
            success: true,
            count: nearbyValuations.length,
            data: nearbyValuations
        });
    } catch (err) {
        console.error("Error fetching nearby valuations:", err);
        res.status(500).json({
            success: false,
            message: "Server error while fetching nearby valuations",
            error: err.message
        });
    }
};

export const getValuationByApplicationNo = async (req, res) => {
    const { applicationNo } = req.params;
    
    if (!applicationNo) {
        return res.status(400).json({
            success: false,
            message: "Application number is required"
        });
    }

    try {
        const valuation = await IDBIValuation.findOne({ applicationNo });
        
        if (!valuation) {
            return res.status(404).json({
                success: false,
                message: "Valuation not found"
            });
        }

        res.status(200).json({
            success: true,
            data: valuation
        });
    } catch (err) {
        console.error("Error fetching valuation:", err);
        res.status(500).json({
            success: false,
            message: "Server error while fetching valuation",
            error: err.message
        });
    }
};

// Haversine distance calculation (same as in pvr1_controller)
function toRadians(degrees) {
    return degrees * (Math.PI / 180);
}

function haversineDistance(lat1, lon1, lat2, lon2) {
    const R = 6371; // Earth's radius in kilometers

    const dLat = toRadians(lat2 - lat1);
    const dLon = toRadians(lon2 - lon1);

    const radLat1 = toRadians(lat1);
    const radLat2 = toRadians(lat2);

    const a =
        Math.sin(dLat / 2) * Math.sin(dLat / 2) +
        Math.cos(radLat1) * Math.cos(radLat2) *
        Math.sin(dLon / 2) * Math.sin(dLon / 2);

    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));

    return R * c; // distance in km
}

export async function searchByDate(req,res){

    const {date}=req.body

    console.log(date)

    const targetDate = new Date(date);

    // Start of day (UTC)
    const start = new Date(targetDate.setUTCHours(0, 0, 0, 0));
    // End of day (UTC)
    const end = new Date(targetDate.setUTCHours(23, 59, 59, 999));

    const docs = await IDBIValuation.find({
    updatedAt: { $gte: start, $lte: end }
    });

    res.status(200).json(docs)    
}