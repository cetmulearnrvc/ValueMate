import express from "express";
const sbi_land_router = express.Router();
// import uploadMiddleware from "../multer/upload.js";
import { savelandData, searchByDate } from "../controller/sbi_land_controller.js"; // Changed from sib to sbi

// import { searchByDate, searchByFileNo } from "../controller/search.controller.js";

sbi_land_router.post("/sbi/land/save", savelandData);

sbi_land_router.post("/sbi/land/getByDate", searchByDate);

// sbi_land_router.post("/land/getnearby",getNearbySBI); // Changed SIB to SBI in comment

// pvr1_router.post("/pvr1/getByFile",searchByFileNo);

export default sbi_land_router;