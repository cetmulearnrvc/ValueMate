import express from "express";
const land_router=express.Router();
import uploadMiddleware from "../multer/upload.js";
import {  savelandData, searchByDate } from "../controller/sib_land_controller.js";

// import { searchByDate, searchByFileNo } from "../controller/search.controller.js";

land_router.post("/land/save", uploadMiddleware ,savelandData);

land_router.post("/land/getByDate",searchByDate);

//  land_router.post("/land/getnearby",getNearbySIB);


// pvr1_router.post("/pvr1/getByFile",searchByFileNo);

export default land_router;