import express from "express";
const canara_router=express.Router();

import { saveCanaraData, searchByDate } from "../controller/canara_controller.js";
import uploadMiddleware from "../multer/upload.js";


canara_router.post("/canara/save", uploadMiddleware ,saveCanaraData)

canara_router.post("/canara/getByDate",searchByDate)



export default canara_router;
