import pvr3 from "../models/pvr3_model.js";

export const savePVR3Data = async(req,res)=>{

    console.log("A post req received in pvr3");
    console.log(req.body); 
    

    
    
    const pvr3Data=req.body;
    pvr3Data.typo="pvr3"
    if(!pvr3Data.valuerName || !pvr3Data.valuerCode || !pvr3Data.fileNo || !pvr3Data.appointingAuthority || !pvr3Data.applicantName || !pvr3Data.address )
    {
        
        return res.status(400).json({success:false,message:"please enter all required fields"})
    }

    let imagesMeta = [];
        try {
            imagesMeta = JSON.parse(pvr3Data.images);
        } catch (err) {
            return res.status(400).json({
                success: false,
                message: "Invalid images metadata format"
            });
        }


     pvr3Data.images = [];
    if (req.files && req.files.length > 0) {
      for (let i = 0; i < req.files.length; i++) {
        const meta = imagesMeta[i] || {};
        

        const imageData = {
          fileName: req.uploadedFiles[i].fileName,
          fileID:req.uploadedFiles[i].driveId,
          latitude: meta.latitude ? parseFloat(meta.latitude) : null,
          longitude: meta.longitude ? parseFloat(meta.longitude) : null
        };

        console.log(imageData.latitude)
        pvr3Data.images.push(imageData);
      }
    } else {
      return res.status(400).json({ 
        success: false, 
        message: "Please add at least one image" 
      });
    }

    /* const newPVR3Data=new pvr3(pvr3Data); */

    

    try{
        const newPVR3Data=await pvr3.findOneAndUpdate({fileNo:pvr3Data.fileNo},
          { $set: pvr3Data }, 
          {
            upsert:true,
            new:true
          }
        )
        res.status(201).json({status:true,data:newPVR3Data})
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

    const docs = await pvr3.find({
    updatedAt: { $gte: start, $lte: end }
    });

    res.status(200).json(docs)

    
}

// export const getNearbyPVR3 = async(req,res)=>{

//   console.log("A nearby Search received")
//   const {latitude,longitude} = req.body
//   const lat1=latitude;
//   const lon1=longitude;

//   console.log(lat1,lon1)
//   let dis=100000;
//   const responseData=[];

//   const cursor=pvr3.find()

//   for await(const doc of cursor)
//   {   
//       doc.images.forEach((img, index) => {

//   if (img.latitude && img.longitude) {

//     const lat2=parseFloat(img.latitude);
//     const lon2=parseFloat(img.longitude);
    
//     dis=haversineDistance(lat1,lon1,lat2,lon2)
    

//     if (dis <= 1) {
//         responseData.push({
//           distance:dis,
//           latitude:lat2,
//           longitude:lon2,
//           marketValue:doc.landUnitRate || 0
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
