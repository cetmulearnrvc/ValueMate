import SIBValuationLand from "../models/land_sib_model.js";
import crypto from "crypto";
import mongoose from "mongoose";
import cloudinary from "../cloudinaryConfig.js";

export const savelandData = async(req,res)=>{

    console.log("A post req received for sib land");
    console.log(req.body); 
    

    
    
    const landData=req.body;
    if(!landData.refId || !landData.ownerName)
    {
        return res.status(400).json({success:false,message:"please enter all required fields"})
    }

    


     landData.images = [];
    if (req.files && req.files.length > 0) {
      for (let i = 0; i < req.files.length; i++) {
        // const meta = imagesMeta[i] || {};
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
          
        };
    
        landData.images.push(imageData);
      }
    }

    /* const newlandData=new SIBValuationLand(landData); */

    

    try{
        const newlandData = await SIBValuationLand.findOneAndUpdate(
          { refId: landData.refId },
          { 
              $set:landData
          },
          {
              upsert: true,
              new: true
          }
      );
      res.status(201).json({status:true, data:newlandData});
    }
    catch(err)
    {
        res.status(500).json({status:false,message:"Server err in creating"})
    }
}

export async function searchByDate(req,res){

    const {date}=req.body

    console.log(date)

    const targetDate = new Date(date);

    // Start of day (UTC)
    const start = new Date(targetDate.setUTCHours(0, 0, 0, 0));
    // End of day (UTC)
    const end = new Date(targetDate.setUTCHours(23, 59, 59, 999));

    const docs = await SIBValuationLand.find({
    updatedAt: { $gte: start, $lte: end }
    });

    res.status(200).json(docs)    
}


// export const getNearbySIB = async(req,res)=>{

//   console.log("A nearby Search received")
//   const {latitude,longitude} = req.body
//   const lat1=parseFloat(latitude);
//   const lon1=parseFloat(longitude);

//   console.log(lat1,lon1)
//   let dis=100000;
//   const responseData=[];

//   const cursor=await SIBValuationLand.find()

//   for (const doc of cursor)
//   {  

//   if (doc.latitudeLongitude) {

//     const [latitude, longitude] = doc.latitudeLongitude.split(',').map(coord => coord.trim());
//     let lat2= parseFloat(latitude)
//     let lon2= parseFloat(longitude)
    
//     dis=haversineDistance(lat1,lon1,lat2,lon2)
    

//     if (dis <= 1) {
//         responseData.push({
//           distance:dis,
//           latitude:lat2,
//           longitude:lon2,
//           marketValue:doc.presentMarketValue || 0
//         });
//       }
    
//   }
//   }; 

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
