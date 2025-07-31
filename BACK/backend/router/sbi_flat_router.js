import express from "express";
const sbi_flat_router = express.Router();
import { saveFlatData } from "../controller/sbi_flat_controller.js"; // Changed from sib to sbi
import uploadMiddleware from "../multer/upload.js";
import { searchByDate } from "../controller/sbi_flat_controller.js"; // Changed from sib to sbi
// import { searchByDate, searchByFileNo } from "../controller/search.controller.js";

sbi_flat_router.post("/sbi/flat/savepdf", uploadMiddleware, saveFlatData);

// sbi_flat_router.post("/flat/getnearby",getNearbyFlat);

sbi_flat_router.post("/sbi/flat/getByDate", searchByDate);

// pvr1_router.post("/pvr1/getByFile",searchByFileNo);

export default sbi_flat_router;