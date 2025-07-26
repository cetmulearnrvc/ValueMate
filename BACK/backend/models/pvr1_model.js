import mongoose from "mongoose";

const pvr1Schema = new mongoose.Schema({
    // Basic Information (required fields)
    valuerName: {
        type: String,
        required: true
    },
    valuationCode: {
        type: String,
        required: true
    },
    fileNo: {
        type: String,
        required: true
    },
    applicantName: {
        type: String,
        required: true
    },
    ownerName: {
        type: String,
        required: true
    },
    propertyLocation: {
        type: String,
        required: true
    },
    
    // Other basic information
    inspectionDate: Date,
    documentsPerused: String,
    
    // Property Location Details
    addressTallies: Boolean,
    locationSketchVerified: Boolean,
    surroundingDevelopment: String,
    basicAmenitiesAvailable: Boolean,
    negativesToLocality: String,
    favorableConsiderations: String,
    nearbyLandmark: String,
    otherFeatures: String,
    
    // Boundary Details
    northBoundary: String,
    northDimension: String,
    southBoundary: String,
    southDimension: String,
    eastBoundary: String,
    eastDimension: String,
    westBoundary: String,
    westDimension: String,
    totalExtent1: String,
    totalExtent2: String,
    boundariesTally: Boolean,
    
    // Land Use Details
    existingLandUse: String,
    proposedLandUse: String,
    naPermissionRequired: Boolean,
    natureOfLandUse: String,
    
    // Approval Details
    approvalNo: String,
    validityPeriod: String,
    isValidityExpiredRenewed: Boolean,
    approvalAuthority: String,
    
    // Construction Details
    approvedGF: String,
    approvedFF: String,
    approvedSF: String,
    actualGF: String,
    actualFF: String,
    actualSF: String,
    plinthApproved: String,
    plinthActual: String,
    fsi: String,
    dwellingUnits: String,
    isConstructionAsPerPlan: Boolean,
    deviations: String,
    deviationNature: String,
    revisedApprovalNecessary: Boolean,
    stageOfConstruction: String,
    progressPercentage: String,
    worksCompletedPercentage: String,
    worksCompletedValue: String,
    
    // Cost and Valuation
    estimateCost: String,
    costPerSqFt: String,
    isEstimateReasonable: Boolean,
    marketability: String,
    landValueApp: String,
    landValueGuide: String,
    landValueMarket: String,
    buildingStageValueApp: String,
    buildingStageValueGuide: String,
    
    buildingStageValueMarket: String,
    buildingCompletionValue: String,
    marketValueSource: String,
    
    // Safety and Amenities
    adheresToSafety: Boolean,
    highTensionImpact: Boolean,
    buildingUsage: String,
    
    // Recommendation Details
    recBackground: String,
    recSources: String,
    recProcedures: String,
    recMethodology: String,
    recFactors: String,
    
    // Certificate Details
    certificatePlace: String,
    
    // Annexure Details
    annexLandArea: String,
    annexLandUnitRateMarket: String,
    annexLandUnitRateGuide: String,
    annexGFArea: String,
    annexGFUnitRateMarket: String,
    annexGFUnitRateGuide: String,
    annexFFArea: String,
    annexFFUnitRateMarket: String,
    annexFFUnitRateGuide: String,
    annexSFArea: String,
    annexSFUnitRateMarket: String,
    annexSFUnitRateGuide: String,
    annexAmenitiesMarket: String,
    annexAmenitiesGuide: String,
    annexYearOfConstruction: String,
    annexBuildingAge: String,
    
    // Images
    images: [{
        fileName: {
            type:String,
            required:true
        },
        fileID: {
            type:String,
            required:true
        },
        latitude: Number,
        longitude: Number,
    }]
}, {
    timestamps: true
});

const pvr1 = mongoose.model('pvr1Data', pvr1Schema);
export default pvr1;