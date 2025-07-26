import mongoose from "mongoose";

// Sub-schema for valuation images
const valuationImageSchema = new mongoose.Schema({
  fileName: {
    type: String,
    required: true
  },
  fileID: {
    type: String,
    required: true
  },
  latitude: Number,
  longitude: Number,
}, { _id: false });

// Sub-schema for boundary details
const boundaryDetailSchema = new mongoose.Schema({
  direction: String,
  titleDeed: String,
  locationSketch: String
}, { _id: false });

// Sub-schema for dimension details
const dimensionDetailSchema = new mongoose.Schema({
  direction: String,
  actual: String,
  document: String,
  adopted: String
}, { _id: false });

// Sub-schema for land valuation details
const landValuationSchema = new mongoose.Schema({
  description: String,
  landArea: String,
  ratePerSqFt: String,
  valueInRs: String
}, { _id: false });

// Sub-schema for valuer comments
const valuerCommentSchema = new mongoose.Schema({
  siNo: String,
  particulars: String,
  comment: String
}, { _id: false });

// Main schema for Vacant Land Valuation
const vacantLandValuationSchema = new mongoose.Schema({
  // Reference ID
  refNo: String,
  
  // Valuer information
  valuerName: String,
  valuerQualifications: String,
  valuerRegInfo: String,
  valuerAddress: String,
  valuerContact: String,
  valuerEmail: String,
  
  // Recipient information
  bankName: String,
  branchName: String,
  branchAddress: String,
  
  // === I. PROPERTY DETAILS ===
  purposeOfValuation: String,
  dateOfInspection: Date,
  dateOfValuation: Date,
  
  // Documents for Persual
  documents: {
    landTaxReceipt: Boolean,
    titleDeed: Boolean,
    buildingCertificate: Boolean,
    locationSketch: Boolean,
    possessionCertificate: Boolean,
    buildingCompletionPlan: Boolean,
    thandapperDocument: Boolean,
    buildingTaxReceipt: Boolean
  },
  
  nameOfOwner: String,
  nameOfApplicant: String,
  addressAsPerDocuments: String,
  addressAsPerActual: String,
  deviations: String,
  propertyType: String, // Leasehold/Freehold
  propertyZone: String, // Residential/Commercial/Industrial/Agricultural
  
  // === II. PROPERTY CLASSIFICATION ===
  classificationArea: String, // High/Middle/Poor
  areaType: String, // Urban/Semi Urban/Rural
  comingUnder: String, // Corporation limit/Village Panchayat/Municipality
  coveredUnderGovtEnactments: String,
  isAgriculturalLand: String,
  agriculturalLandConversion: String,
  
  // === III. BOUNDARIES ===
  boundaries: [boundaryDetailSchema],
  boundaryDeviations: String,
  
  // === IV. DIMENSIONS ===
  dimensions: [dimensionDetailSchema],
  totalAreaActual: String,
  totalAreaDocument: String,
  totalAreaAdopted: String,
  dimensionDeviations: String,
  
  // === V. LOCATION ===
  latitude: String,
  longitude: String,
  coordinates: String,
  
  // === VI. ROAD AND ACCESS ===
  typeOfRoad: String,
  widthOfRoad: String,
  isLandLocked: String,
  typeOfDemarcation: String,
  
  // === VII. LAND VALUATION ===
  landValuationDetails: [landValuationSchema],
  
  // === VIII. FINAL VALUATION ===
  presentMarketValue: String,
  realizableValue: String,
  distressValue: String,
  insurableValue: String,
  
  // === IX. REMARKS ===
  remarks: [String],
  
  // === X. DECLARATION DETAILS ===
  declarationDateA: Date, // Valuation report date
  declarationDateC: Date, // Inspection date
  
  // === XI. VALUER COMMENTS ===
  valuerComments: [valuerCommentSchema],
  
  // Images
  images: [valuationImageSchema],
  
  // Metadata
  createdAt: {
    type: Date,
    default: Date.now
  },
  updatedAt: {
    type: Date,
    default: Date.now
  }
});

// Add pre-save hook to update the updatedAt field
vacantLandValuationSchema.pre('save', function(next) {
  this.updatedAt = new Date();
  next();
});

const VacantLandValuation = mongoose.model('VacantLandValuation', vacantLandValuationSchema);

export default VacantLandValuation;