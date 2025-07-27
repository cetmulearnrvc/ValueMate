import mongoose from "mongoose";

const valuationImageSchema = new mongoose.Schema({
  fileName: {
    type: String,
    required: true
  },
  fileID:{
    type: String,
    required: true
  },
  latitude: String,
  longitude: String
});

const idbiValuationSchema = new mongoose.Schema({

  // Valuer Information
  valuerNameAndQuals: {
    type: String,
    
  },
  valuerCredentials: {
    type: String,
    
  },
  valuerAddressLine1: {
    type: String,
    
  },
  valuerMob: {
    type: String,
    
  },
  valuerEmail: {
    type: String,
    
  },

  // Bank Information
  bankName: {
    type: String,
    
  },
  branchName: {
    type: String,
    
  },

  // General Information
  caseType: {
    type: String,
    required:true,
  },
  inspectionDate: Date,
  applicationNo: {
    type: String,
    required:true,
  },
  titleHolderName: {
    type: String,
    
  },
  borrowerName: {
    type: String,
    
  },

  // Documents Verified
  landTaxReceiptNo: {
    type: String,
    
  },
  possessionCertNo: {
    type: String,
  },
  locationSketchNo: {
    type: String,
  },
  thandaperAbstractNo: {
    type: String,
  },
  approvedLayoutPlanNo: {
    type: String,
  },
  approvedBuildingPlanNo: {
    type: String,
  },

  // Property Description
  briefDescription: {
    type: String,
    
  },
  locationAndLandmark: {
    type: String,
    
  },

  // Property Location Details
  reSyNo: {
    type: String,
  },
  blockNo: {
    type: String,
  },
  village: {
    type: String,
  },
  taluk: {
    type: String,
  },
  district: {
    type: String,
    
  },
  state: {
    type: String,
  },
  postOffice: {
    type: String,
  },
  pinCode: {
    type: String,
  },
  postalAddress: {
    type: String,
    
  },

  // Boundary Details
  northAsPerSketch: {
    type: String,
  },
  northActual: {
    type: String,
  },
  southAsPerSketch: {
    type: String,
  },
  southActual: {
    type: String,
  },
  eastAsPerSketch: {
    type: String,
    
  },
  eastActual: {
    type: String,
    
  },
  westAsPerSketch: {
    type: String,
  },
  westActual: {
    type: String,
  },

  // Property Characteristics
  localAuthority: {
    type: String,
  },
  isPropertyIdentified: {
    type: Boolean,
  },
  plotDemarcated: {
    type: String,
  },
  natureOfProperty: {
    type: String,
  },
  classOfProperty: {
    type: String,
  },
  topographicalCondition: {
    type: String,
  },
  chanceOfAcquisition: {
    type: Boolean,
  },
  approvedLandUse: {
    type: String,
  },
  fourWheelerAccessibility: {
    type: String,
  },
  occupiedBy: {
    type: String,
  },
  yearsOfOccupancy: {
    type: String,
  },
  ownerRelationship: {
    type: String,
  },

  // Area Details
  areaOfLand: {
    type: String,
  },
  saleableArea: {
    type: String,
  },

  // Land Valuation
  landExtent: {
    type: String,
  },
  landRatePerCent: {
    type: String,
  },
  landTotalValue: {
    type: String,
  },
  landMarketValue: {
    type: String,
  },
  landRealizableValue: {
    type: String,
  },
  landDistressValue: {
    type: String,
  },
  landFairValue: {
    type: String,
  },

  // Building Valuation
  buildingPlinth: {
    type: String,
  },
  buildingRatePerSqft: {
    type: String,
  },
  buildingTotalValue: {
    type: String,
  },
  buildingMarketValue: {
    type: String,
  },
  buildingRealizableValue: {
    type: String,
  },
  buildingDistressValue: {
    type: String,
  },

  // Building Physical Details
  buildingNo: {
    type: String,
  },
  approvingAuthority: {
    type: String,
  },
  stageOfConstruction: {
    type: String,
  },
  typeOfStructure: {
    type: String,
  },
  noOfFloors: {
    type: String,
  },
  livingDiningRooms: {
    type: String,
  },
  bedrooms: {
    type: String,
  },
  toilets: {
    type: String,
  },
  kitchen: {
    type: String,
  },
  typeOfFlooring: {
    type: String,
  },
  ageOfBuilding: {
    type: String,
  },
  residualLife: {
    type: String,
  },
  violationObserved: {
    type: String,
  },

  // Grand Totals
  grandTotalMarketValue: {
    type: String,
  },
  grandTotalRealizableValue: {
    type: String,
  },
  grandTotalDistressValue: {
    type: String,
  },

  // Declaration
  declarationDate: Date,
  declarationPlace: {
    type: String,
    
  },
  valuerName: {
    type: String,
    
  },
  valuerAddress: {
    type: String,
    
  },

  // Images
  images: [valuationImageSchema]
}, {
  timestamps: true
});

const IDBIValuation = mongoose.model('IDBIValuation', idbiValuationSchema);
export default IDBIValuation;
