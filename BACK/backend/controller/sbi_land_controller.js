// sbi_land_controller.js

import SBIValuationLand from "../models/land_sbi_model.js";

export const savelandData = async(req,res)=>{

    console.log("A post req received for sbi land"); // Updated log message
    console.log(req.body); 
    
    const landData=req.body;
    if(!landData.refId || !landData.ownerName)
    {
        return res.status(400).json({success:false,message:"please enter all required fields"})
    }

    landData.images = [];
    if (req.files && req.files.length > 0) {
      for (let i = 0; i < req.files.length; i++) {
        const imageData = {
          fileName: req.uploadedFiles[i].fileName,
          fileID:req.uploadedFiles[i].driveId,
        };

        landData.images.push(imageData);
      }
    }

    try{
        const newlandData = await SBIValuationLand.findOneAndUpdate( // Updated model name
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

    const docs = await SBIValuationLand.find({ // Updated model name
    updatedAt: { $gte: start, $lte: end }
    });

    res.status(200).json(docs)    
}

// Commented out nearby search functionality - if needed, update SIBValuationLand to SBIValuationLand
/*
export const getNearbySBI = async(req,res)=>{ // Updated function name if uncommented
  // ... same code but use SBIValuationLand instead of SIBValuationLand
}
*/