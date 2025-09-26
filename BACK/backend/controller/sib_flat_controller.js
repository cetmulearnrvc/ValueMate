import SIBValuationFlat from "../models/flat_sib_model.js";
import crypto from "crypto";
import mongoose from "mongoose";
import cloudinary from "../cloudinaryConfig.js";

export const saveFlatData = async (req, res) => {
  console.log('A post req received');
  console.log(req.body);

  const flatData = req.body;
  flatData.typo = 'sibFlat';

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

  let imagesMeta = [];
if (flatData.images) {
  try {
    imagesMeta = JSON.parse(flatData.images);
  } catch (err) {
    return res.status(400).json({
      success: false,
      message: "Invalid images metadata format"
    });
  }
}

  // Process uploaded images
  flatData.images = [];
  if (req.files && req.files.length > 0) {
    for (let i = 0; i < req.files.length; i++) {
      const meta = imagesMeta[i] || {};
      const hash = crypto.createHash("sha256").update(req.files[i].buffer).digest("hex");
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
        latitude: meta.latitude ? String(meta.latitude) : null,
        longitude: meta.longitude ? String(meta.longitude) : null
      };
  
      flatData.images.push(imageData);
    }
  }

  try {
    const existingDoc = await SIBValuationFlat.findOne({ refNo: flatData.refNo });

    let savedDoc;
    if (existingDoc) {
      // If document with same refNo exists ➔ Overwrite (Update)
      savedDoc = await SIBValuationFlat.findOneAndUpdate(
        { refNo: flatData.refNo },
        { $set: flatData },
        { new: true }  // Return the updated document
      );
      console.log('Document updated:', savedDoc._id);
      res.status(200).json({ status: true, data: savedDoc, message: "Existing record updated successfully" });

    } else {
      // If not exists ➔ Create new
      const newFlatData = new SIBValuationFlat(flatData);
      savedDoc = await newFlatData.save();
      console.log('New document created:', savedDoc._id);
      res.status(201).json({ status: true, data: savedDoc, message: "New record created successfully" });
    }
  } catch (err) {
    console.error(err);
    res.status(500).json({ status: false, message: "Server error" });
  }
};


// export const getNearbyFlat = async(req,res)=>{

//   console.log("A nearby Search received")
//   const {latitude,longitude} = req.body
//   const lat1=latitude;
//   const lon1=longitude;

//   console.log(lat1,lon1)
//   let dis=100000;
//   const responseData=[];

//   const cursor=SIBValuationFlat.find()

//   for await(const doc of cursor)
//   {   
//       doc.images.forEach((img, index) => {

//   if (img.latitude && img.longitude) {

//     const lat2=parseFloat(img.latitude);
//     const lon2=parseFloat(img.longitude);
    
//     dis=haversineDistance(lat1,lon1,lat2,lon2)
    

//     if (dis <= 100) {
//         responseData.push({
//           distance:dis,
//           latitude:lat2,
//           longitude:lon2,
//           marketValue:doc.presentMarketValue || 0
//         });
//       }
    
//   }
//   }); 
//   }

//   console.log(responseData)

//   return res.status(200).json(responseData)
  
// }

// function toRadians(degrees) {
//   return degrees * (Math.PI / 180);
// }

// function haversineDistance(lat1, lon1, lat2, lon2) {
//   const R = 6371; // Earth's radius in kilometers

//   const dLat = toRadians(lat2 - lat1);
//   const dLon = toRadians(lon2 - lon1);

//   const radLat1 = toRadians(lat1);
//   const radLat2 = toRadians(lat2);

//   const a =
//     Math.sin(dLat / 2) * Math.sin(dLat / 2) +
//     Math.cos(radLat1) * Math.cos(radLat2) *
//     Math.sin(dLon / 2) * Math.sin(dLon / 2);

//   const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));

//   return R * c; // distance in km
// }


export async function searchByDate(req,res){

    const {date}=req.body

    console.log(date)

    const targetDate = new Date(date);

    // Start of day (UTC)
    const start = new Date(targetDate.setUTCHours(0, 0, 0, 0));
    // End of day (UTC)
    const end = new Date(targetDate.setUTCHours(23, 59, 59, 999));

    const docs = await SIBValuationFlat.find({
    updatedAt: { $gte: start, $lte: end }
    });

    res.status(200).json(docs)

    
}