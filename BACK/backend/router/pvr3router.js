import express from "express";

const router=express.Router();
import upload from "../multer/upload.js";
// import uploadMiddleware from "../multer/upload.js";
import { savePVR3Data, searchByDate } from "../controller/pvr3_controller.js";

router.post("/pvr3/save",upload.array("images",10),savePVR3Data)

router.post("/pvr3/getByDate",searchByDate)

// router.post("/pvr3/getnearby",getNearbyPVR3)

export default router;