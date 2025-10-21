import mongoose from 'mongoose';

// Sub-schema for valuation images
const sbivaluationImageSchema = new mongoose.Schema({
  fileName: {
    type: String,
    required: true
  },
  // filePath: {
  //   type: String,
  //   required: true
  // },
  // latitude: Number,
  // longitude: Number,
}, { _id: false });

// Main schema for Vacant Land Valuation
const sbivacantLandValuationSchema = new mongoose.Schema({
  // Reference fields
  refNo: {
    type: String,
    required: true
  },
  typo: {
    type: String,
    default: 'sbiVacantLand'
  },

  // Document fields
  landTaxReceipt: String,
  titleDeed: String,
  buildingCertificate: String,
  locationSketch: String,
  possessionCertificate: String,
  buildingCompletionPlan: String,
  thandapperDocument: String,
  buildingTaxReceipt: String,

  // Page 1 fields
  purpose: String,
  dateOfInspection: String,
  dateOfValuation: String,
  ownerName: String,
  applicantName: String,
  addressDocument: String,
  addressActual: String,
  deviations: String,
  propertyType: String,
  propertyZone: String,

  // Page 2 fields
  classificationArea: String,
  urbanSemiUrbanRural: String,
  comingUnderCorporation: String,
  coveredUnderStateCentralGovt: String,
  agriculturalLandConversion: String,

  // Boundaries
  boundaryNorthTitle: String,
  boundarySouthTitle: String,
  boundaryEastTitle: String,
  boundaryWestTitle: String,
  boundaryNorthSketch: String,
  boundarySouthSketch: String,
  boundaryEastSketch: String,
  boundaryWestSketch: String,
  boundaryDeviations: String,

  // Dimensions
  dimNorthActuals: String,
  dimSouthActuals: String,
  dimEastActuals: String,
  dimWestActuals: String,
  dimTotalAreaActuals: String,
  dimNorthDocuments: String,
  dimSouthDocuments: String,
  dimEastDocuments: String,
  dimWestDocuments: String,
  dimTotalAreaDocuments: String,
  dimNorthAdopted: String,
  dimSouthAdopted: String,
  dimEastAdopted: String,
  dimWestAdopted: String,
  dimTotalAreaAdopted: String,
  dimDeviations: String,

  // Location
  latitudeLongitude: String,
  typeOfRoad: String,
  widthOfRoad: String,
  isLandLocked: String,

  // Land Valuation
  landAreaDetails: String,
  landAreaGuideline: String,
  landAreaPrevailing: String,
  ratePerSqFtGuideline: String,
  ratePerSqFtPrevailing: String,
  valueInRsGuideline: String,
  valueInRsPrevailing: String,

  // Final Valuation
  presentMarketValue: String,
  realizableValue: String,
  distressValue: String,
  insurableValue: String,

  // Remarks
  remark1: String,
  remark2: String,
  remark3: String,
  remark4: String,

  // Declaration dates
  declarationDateA: String,
  declarationDateC: String,

  // Valuer Comments
  vcBackgroundInfo: String,
  vcPurposeOfValuation: String,
  vcIdentityOfValuer: String,
  vcDisclosureOfInterest: String,
  vcDateOfAppointment: String,
  vcInspectionsUndertaken: String,
  vcNatureAndSources: String,
  vcProceduresAdopted: String,
  vcRestrictionsOnUse: String,
  vcMajorFactors1: String,
  vcMajorFactors2: String,
  vcCaveatsLimitations: String,

  // Images
  images: [sbivaluationImageSchema],

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
sbivacantLandValuationSchema.pre('save', function(next) {
  this.updatedAt = new Date();
  next();
});

// Add indexes for better performance
sbivacantLandValuationSchema.index({ refNo: 1 });
sbivacantLandValuationSchema.index({ createdAt: -1 });
sbivacantLandValuationSchema.index({ 'images.latitude': 1, 'images.longitude': 1 });

const SBIVacantLandValuation = mongoose.model('SBIVacantLandValuation', sbivacantLandValuationSchema);

export default SBIVacantLandValuation;