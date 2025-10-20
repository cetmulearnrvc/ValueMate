import path from "path";
import crypto from "crypto";
import fs from "fs";


export const handleUpload = (req, res , next) => {
  if (!req.files || req.files.length === 0) {
    return res.status(400).json({ error: "No files uploaded" });
  }

  const results = [];

  req.files.forEach((file) => {
    const buffer = file.buffer;
    const hash = crypto.createHash("sha256").update(buffer).digest("hex");
    const ext = path.extname(file.originalname); 
    const filename = `${hash}${ext}`; 
    /* const filename = `${hash}`; */
    const filePath = path.join("uploads", filename);

    results.push({
        originalname: file.originalname,
        filename,
        path: filePath,
    });

    if (fs.existsSync(filePath)) {
      console.log("Duplicate detected:", filename);
      /* results.push({
        originalname: file.originalname,
        filename,
        path: filePath,
        exists: true,
      }); */
    } else {
      fs.writeFileSync(filePath, buffer);
      /* results.push({
        originalname: file.originalname,
        filename,
        path: filePath,
        exists: false,
      }); */
    }
  });

  req.results=results;
  next();
};
