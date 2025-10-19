import express from "express";
const flat_router=express.Router();
import { saveFlatData } from "../controller/sbi_flat_controller.js";
// import uploadMiddleware from "../multer/upload.js";
import { searchByDate } from "../controller/sbi_flat_controller.js";
// import { searchByDate, searchByFileNo } from "../controller/search.controller.js";
import upload from "../multer/upload.js";

flat_router.post("/sbi/flat/savepdf" ,upload.array("images",10),saveFlatData);

// flat_router.post("/flat/getnearby",getNearbyFlat);

flat_router.post("/sbi/flat/getByDate",searchByDate);

// pvr1_router.post("/pvr1/getByFile",searchByFileNo);

export default flat_router;