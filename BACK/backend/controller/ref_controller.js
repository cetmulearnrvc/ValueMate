// 1. Use 'import'
import DailyCounter from '../models/counter_model.js'; // Note: You MUST add .js extension

// 2. Use 'export const' instead of 'exports.name ='
export const generateRefId = async (req, res) => {
  try {
    const now = new Date();
    const dateStr = now.toISOString().split('T')[0];

    const counter = await DailyCounter.findOneAndUpdate(
      { date: dateStr },
      { $inc: { seq: 1 } },
      { new: true, upsert: true }
    );

    const currentMonth = now.getMonth(); 
    const currentYear = now.getFullYear();
    
    let startYear = (currentMonth < 3) ? currentYear - 1 : currentYear;
    let endYear = startYear + 1;
    
    const fyString = `${startYear.toString().substr(2)}${endYear.toString().substr(2)}`;
    const month = (currentMonth + 1).toString().padStart(2, '0');
    const day = now.getDate().toString().padStart(2, '0');
    const seqString = counter.seq.toString().padStart(2, '0');

    const finalRefId = `${fyString}${month}${day}${seqString}`;

    res.status(200).json({ success: true, refId: finalRefId });

  } catch (err) {
    console.error(err);
    res.status(500).json({ success: false, message: "Server Error" });
  }
};