import express from "express";
const land_router=express.Router();
// import uploadMiddleware from "../multer/upload.js";
import {  savelandData, searchByDate } from "../controller/sbi_land_controller.js";
import upload from "../multer/upload.js";
import { handleUpload } from "../middleware/handleUpload.js";

// import { searchByDate, searchByFileNo } from "../controller/search.controller.js";

land_router.post("/sbi/land/save" ,upload.array("images",10),handleUpload,savelandData);

land_router.post("/sbi/land/getByDate",searchByDate);

//  land_router.post("/land/getnearby",getNearbySIB);


// pvr1_router.post("/pvr1/getByFile",searchByFileNo);

export default land_router;