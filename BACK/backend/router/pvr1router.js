import express from "express";
const pvr1_router=express.Router();
import { savePVR1Data } from "../controller/pvr1_controller.js";
// import uploadMiddleware from "../multer/upload.js";
import upload from "../multer/upload.js";
import { handleUpload } from "../middleware/handleUpload.js";
import { searchByDate, searchByFileNo } from "../controller/search.controller.js";

pvr1_router.post("/pvr1/generatepdf" ,upload.array("images",10),handleUpload,savePVR1Data)

// pvr1_router.post("/pvr1/getnearby",getNearbyPVR1)

pvr1_router.post("/pvr1/getByDate",searchByDate)

pvr1_router.post("/pvr1/getByFile",searchByFileNo);

export default pvr1_router;