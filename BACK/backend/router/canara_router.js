import express from "express";
const canara_router=express.Router();
import upload from "../multer/upload.js";

import { saveCanaraData, searchByDate } from "../controller/canara_controller.js";
import { handleUpload } from "../middleware/handleUpload.js";
// import uploadMiddleware from "../multer/upload.js";


canara_router.post("/canara/save" ,upload.array("images",10),handleUpload,saveCanaraData)

canara_router.post("/canara/getByDate",searchByDate)



export default canara_router;
