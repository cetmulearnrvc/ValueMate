import express from "express";
const federal_router=express.Router();
// import uploadMiddleware from "../multer/upload.js";
import {  saveFederalData, searchByDate } from "../controller/federal_controller.js";
import upload from "../multer/upload.js";

federal_router.post("/federal/save" ,upload.array("images",10),saveFederalData)

// federal_router.post("/federal/getnearby",getNearbyfederal)

federal_router.post("/federal/getByDate",searchByDate)

export default federal_router;