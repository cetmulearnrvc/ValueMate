import multer from "multer";
import { google } from 'googleapis';
import { Readable } from 'stream';
import dotenv from 'dotenv';

dotenv.config();

// Initialize OAuth2 Client
const oauth2Client = new google.auth.OAuth2(
  process.env.GOOGLE_API_CLIENT_ID,
  process.env.GOOGLE_API_CLIENT_SECRET,
  process.env.GOOGLE_REDIRECT_URI
);

// Set credentials
try {
  oauth2Client.setCredentials({
    refresh_token: process.env.Refresh_Token
  });
} catch (err) {
  console.error('Failed to set credentials:', err);
}

const driveService = google.drive({ version: 'v3', auth: oauth2Client });

// Multer setup
const upload = multer({ storage: multer.memoryStorage() }).array('images');

const uploadToDrive = async (req, res, next) => {
  if (!req.files?.length) return next();

  try {
    // Refresh access token
    const { credentials } = await oauth2Client.refreshAccessToken();
    oauth2Client.setCredentials(credentials);

    const uploadPromises = req.files.map(async (file) => {
      const fileMetadata = {
        name: `${Date.now()}-${file.originalname}`,
        parents: ['1kYfCWLM-OA8RD5ejglI3VZH7XxNPwl8o'],
        supportsAllDrives: true
      };

      // IMPORTANT: Include 'name' in the fields parameter
      const response = await driveService.files.create({
        resource: fileMetadata,
        media: {
          mimeType: file.mimetype,
          body: Readable.from(file.buffer),
        },
        fields: 'id,name,webViewLink,webContentLink', // Added 'name' here
        supportsAllDrives: true
      });

      return {
        originalName: file.originalname,
        driveId: response.data.id, // The important Drive file ID
        fileName: response.data.name, // Now will be defined
        webViewLink: response.data.webViewLink,
        webContentLink: response.data.webContentLink,
        mimeType: file.mimetype
      };
    });

    req.uploadedFiles = await Promise.all(uploadPromises);
    console.log('Uploaded files:', req.uploadedFiles);
    next();
  } catch (error) {
    console.error('Drive Upload Error:', error.message);
    if (error.response) {
      console.error('Google API Error Details:', error.response.data);
    }
    next(error);
  }
};

export default [upload, uploadToDrive];