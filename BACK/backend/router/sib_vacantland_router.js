import express from "express";
const vacantLandRouter = express.Router();
import { 
  saveVacantLand,
  getNearbyVacantLands,
  getVacantLandsByDate 
} from "../controller/sib_vacantland_controller.js";
import upload from "../multer/upload.js";

// Save vacant land data with images
vacantLandRouter.post("/vacant-land/save", upload.array("images"), saveVacantLand);

// Get nearby vacant lands (changed to POST to match your example)
vacantLandRouter.post("/vacant-land/nearby", getNearbyVacantLands);

// Get vacant lands by date (changed to POST to match your example)
vacantLandRouter.post("/vacant-land/by-date", getVacantLandsByDate);

export default vacantLandRouter;