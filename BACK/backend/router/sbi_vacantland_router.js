import express from "express";
const sbivacantLandRouter = express.Router();
import { 
  saveVacantLand,
  // getNearbyVacantLands,
  searchByDate
} from "../controller/sbi_vacantland_controller.js";
 import upload from "../multer/upload.js";

// Save vacant land data with images
sbivacantLandRouter.post("/sbi/vacant-land/save", upload.array("images",10), saveVacantLand);

// Get nearby vacant lands (changed to POST to match your example)
// sbivacantLandRouter.post("/sbi/vacant-land/nearby", getNearbyVacantLands);

// Get vacant lands by date (changed to POST to match your example)
sbivacantLandRouter.post("/sbi/vacant-land/by-date", searchByDate);

export default sbivacantLandRouter;