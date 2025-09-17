// secureImageRoute.js
import express from "express";
import { v2 as cloudinary } from "cloudinary";
import requireAuth from "./middleware/authMiddleware.js";

const router = express.Router();

router.get("/secure-url/:publicId", requireAuth, (req, res) => {
  try {
    const { publicId } = req.params;

    // Generate signed URL for private image, expires in 60s
    const signedUrl = cloudinary.url(publicId, {
      resource_type: "image",
      type: "authenticated",   // IMPORTANT: must be authenticated
      sign_url: true,
      expires_at: Math.floor(Date.now() / 1000) + 60, // 60s from now
    });

    // Optional cache-buster so Flutter fetches fresh URL
    // const urlWithCacheBuster = `${signedUrl}&nocache=${Date.now()}`;

    res.json({ signedUrl });
  } catch (error) {
    console.error("Error generating signed URL:", error);
    res.status(500).json({ error: "Could not generate secure URL." });
  }
});

export default router;
