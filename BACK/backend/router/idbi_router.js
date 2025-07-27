import express from "express";
const idbi_router = express.Router();
import {
    saveIDBIValuation,
    getNearbyIDBIValuations,
    getValuationByApplicationNo,
    searchByDate
} from "../controller/idbi_controller.js";

import uploadMiddleware from "../multer/upload.js";



idbi_router.post("/idbi/save", uploadMiddleware , saveIDBIValuation);

idbi_router.post("/idbi/getByDate", searchByDate);

idbi_router.post("/idbi/nearby", getNearbyIDBIValuations);

idbi_router.get("/idbi/application/:applicationNo", getValuationByApplicationNo);

export default idbi_router;