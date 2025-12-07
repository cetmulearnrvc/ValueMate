import express from 'express'; // <--- Change to 'import'
import { generateRefId } from '../controller/ref_controller.js'; // <--- MUST add .js

const routerRef = express.Router();

routerRef.post('/get-ref-id', generateRefId);

export default routerRef;