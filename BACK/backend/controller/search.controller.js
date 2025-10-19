import pvr1 from "../models/pvr1_model.js";

export async function searchByDate(req,res){

    const {date}=req.body

    // console.log(date)

    const targetDate = new Date(date);

    // Start of day (UTC)
    const start = new Date(targetDate.setUTCHours(0, 0, 0, 0));
    // End of day (UTC)
    const end = new Date(targetDate.setUTCHours(23, 59, 59, 999));

    const docs = await pvr1.find({
    updatedAt: { $gte: start, $lte: end }
    });

    res.status(200).json(docs)

    
}

export async function searchByFileNo(req,res){

    let { fileNo }=req.body;
    console.log(fileNo)

    const doc=await pvr1.findOne({fileNo})

    res.status(200).json(doc);
}