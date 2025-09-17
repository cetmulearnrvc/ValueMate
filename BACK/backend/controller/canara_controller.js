import Canara from "../models/canara_model.js";
import crypto from "crypto";
import cloudinary from "../cloudinaryConfig.js";
export const saveCanaraData = async(req,res)=>{

    console.log("A post req received");
    console.log(req.body); 
    
    const CanaraData=req.body;
    CanaraData.typo="Canara"
    if(!CanaraData.ownerName || !CanaraData.propertyAddress )
    {
        return res.status(400).json({success:false,message:"please enter all fields"})
    }

    let imagesMeta = [];
    if(CanaraData.images)
    {
      try {
            imagesMeta = JSON.parse(CanaraData.images);
          } catch (err) {
              return res.status(400).json({
                  success: false,
                  message: "Invalid images metadata format"
              });
          }
    }


     CanaraData.images = [];
    if (req.files && req.files.length > 0) {
      for (let i = 0; i < req.files.length; i++) {
    const meta = imagesMeta[i] || {};
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
      latitude: meta.latitude ? String(meta.latitude) : null,
      longitude: meta.longitude ? String(meta.longitude) : null
    };

    CanaraData.images.push(imageData);
  }
    }

    try{
        const newCanaraData = await Canara.findOneAndUpdate(
          { ownerName: CanaraData.ownerName},
          {$set:CanaraData},
          {
              upsert: true,
              new: true
          }
      );
      res.status(201).json({status:true, data:newCanaraData});
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

    const docs = await Canara.find({
    updatedAt: { $gte: start, $lte: end }
    });

    res.status(200).json(docs)

    
}