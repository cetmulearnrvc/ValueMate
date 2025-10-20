import federal from "../models/federal_model.js";
import cloudinary from "../cloudinaryConfig.js";
import crypto from "crypto";

export const saveFederalData = async(req,res)=>{

    // console.log("A post req received");
    // console.log(req.body); 
    

    
    
    const federalData=req.body;
    if(!federalData.applicantNameAndBranchDetails || !federalData.ownerOfTheProperty)
    {
        return res.status(400).json({success:false,message:"please enter all required fields"})
    }

    


     federalData.images = [];
    if (req.results && req.results.length > 0) {
      for (let i = 0; i < req.results.length; i++) {
          
        const file = req.results[i];

    
        const imageData = {
          fileName: file.filename, 
          filePath:file.path,
        };
      
          federalData.images.push(imageData);
        }
    }

    /* const newfederalData=new federal(federalData); */

    

    try{
        const newfederalData = await federal.findOneAndUpdate(
          { ownerOfTheProperty: federalData.ownerOfTheProperty },
          { 
              $set: federalData
          },
          {
              upsert: true,
              new: true
          }
      );
      res.status(201).json({status:true, data:newfederalData});
    }
    catch(err)
    {
        res.status(500).json({status:false,message:"Server err in creating"})
    }
}

export async function searchByDate(req,res){

    const {date}=req.body

    // console.log(date)

    const targetDate = new Date(date);

    // Start of day (UTC)
    const start = new Date(targetDate.setUTCHours(0, 0, 0, 0));
    // End of day (UTC)
    const end = new Date(targetDate.setUTCHours(23, 59, 59, 999));

    const docs = await federal.find({
    updatedAt: { $gte: start, $lte: end }
    });

    res.status(200).json(docs)    
}

// export const getNearbyfederal = async(req,res)=>{

//   console.log("A nearby Search received")
//   const {latitude,longitude} = req.body
//   const lat1=latitude;
//   const lon1=longitude;

//   console.log(lat1,lon1)
//   let dis=100000;
//   const responseData=[];

//   const cursor=await federal.find()

//   for (const doc of cursor)
//   {  

//   if (doc.latitude && doc.longitude) {

//     const lat2=parseFloat(doc.latitude);
//     const lon2=parseFloat(doc.longitude);
    
//     dis=haversineDistance(lat1,lon1,lat2,lon2)
    

//     if (dis <= 1) {
//         responseData.push({
//           distance:dis,
//           latitude:lat2,
//           longitude:lon2,
//           marketValue:doc.landValue || 0
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
