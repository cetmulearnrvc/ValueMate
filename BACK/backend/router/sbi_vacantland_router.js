import express from "express";
const vacantLandRouter = express.Router();
import { 
  saveVacantLand,
  getNearbyVacantLands,
  getVacantLandsByDate 
} from "../controller/sbi_vacantland_controller.js"; // Changed from sib to sbi
import uploadMiddleware from "../multer/upload.js";

// Save vacant land data with images
vacantLandRouter.post("/vacant-land/save", uploadMiddleware, saveVacantLand);

// Get nearby vacant lands (changed to POST to match your example)
vacantLandRouter.post("/vacant-land/nearby", getNearbyVacantLands);

// Get vacant lands by date (changed to POST to match your example)  
vacantLandRouter.post("/vacant-land/by-date", getVacantLandsByDate);

export default vacantLandRouter;