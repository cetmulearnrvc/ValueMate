import express from "express";
const vacantLandRouter = express.Router();
import { 
  saveVacantLand,
  getNearbyVacantLands,
  searchByDate
} from "../controller/sib_vacantland_controller.js";
 import upload from "../multer/upload.js";
 import { handleUpload } from "../middleware/handleUpload.js";

// Save vacant land data with images
vacantLandRouter.post("/vacant-land/save", upload.array("images",10),handleUpload, saveVacantLand);

// Get nearby vacant lands (changed to POST to match your example)
vacantLandRouter.post("/vacant-land/nearby", getNearbyVacantLands);

// Get vacant lands by date (changed to POST to match your example)
vacantLandRouter.post("/vacant-land/by-date", searchByDate);

export default vacantLandRouter;