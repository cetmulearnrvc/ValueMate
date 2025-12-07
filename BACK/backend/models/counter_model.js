import mongoose from 'mongoose';

const counterSchema = new mongoose.Schema({
  date: { type: String, required: true, unique: true }, 
  seq: { type: Number, default: 0 }
});

// Use 'export default' instead of 'module.exports'
export default mongoose.model('DailyCounter', counterSchema);