import mongoose from "mongoose";

const pvr3Schema = new mongoose.Schema({
    // Basic Information
    fileNo: {
        required:true,
        type:String
    },
    valuerName: {
        type: String,
        required: true
    },
    valuerCode: {
        type: String,
        required: true
    },
    appointingAuthority:{
        type: String,
        required: true
    },
    inspectionDate: Date,
    reraNo: String,
    scheme: String,
    applicantName: {
        type: String,
        required: true
    },
    documentPerused: String,
    address: {
        type: String,
        required: true
    },
    
    // Location Details
    locationSketchVerified: Boolean,
    northBoundary: String,
    northDim: String,
    southBoundary: String,
    southDim: String,
    eastBoundary: String,
    eastDim: String,
    westBoundary: String,
    westDim: String,
    extent1: String,
    extent2: String,
    
    // Property Details
    propertyType: String,
    occupantStatus: {
        type: String,
        enum: ['Occupied', 'Vacant', 'UnderConstruction', 'Rented']
    },
    occupantName: String,
    usageOfBuilding: String,
    nearbyLandmark: String,
    surroundingAreaDev: String,
    basicAmenitiesAvailable: Boolean,
    negativesToLocality: String,
    favourableConsiderations: String,
    otherFeatures: String,
    
    // Construction Details
    approvedDrawingAvailable: Boolean,
    approvalNoAndDate: String,
    constructionAsPerPlan: Boolean,
    drawingDeviations: String,
    deviationNature: {
        type: String,
        enum: ['Major', 'Minor', 'None']
    },
    marketability: String,
    buildingAge: String,
    residualLife: String,
    fsiApproved: String,
    fsiActual: String,
    specFoundation: String,
    specRoof: String,
    specFlooring: String,
    qualityOfConstruction: String,
    adheresToSafetySpecs: Boolean,
    highTensionLineImpact: Boolean,
    
    // Valuation Details
    landArea: String,
    landUnitRate: String,
    landGuidelineRate: String,
    amenitiesArea: String,
    amenitiesUnitRate: String,
    amenitiesGuidelineRate: String,
    marketValueSourceHouse: String,
    
    // Flat Details (if applicable)
    flatUndividedShare: String,
    flatBuiltUpArea: String,
    flatCompositeRate: String,
    flatValueUnitRate: String,
    flatValueMarket: String,
    flatValueGuidelineRate: String,
    flatValueGuideline: String,
    marketValueSourceFlat: String,
    flatExtraAmenities: String,
    
    // Improvement Details
    improvementDescription: String,
    improvementAmount: String,
    improvementEstimateReasonable: Boolean,
    improvementReasonableEstimate: String,

    // PROGRESS OF WORKING TO BE IMPLEMENTED AS ARRAY IS MISSING
    
    // Remarks
    remarksBackground: String,
    remarksSources: String,
    remarksProcedures: String,
    remarksMethodology: String,
    remarksFactors: String,

    selectedPropertyType:String,
    
    // Images (if needed)
    images: [{
        fileName: {
        type: String,
        required: true
    },
        fileID: {
        type: String,
        required: true
    },
        latitude: Number,
        longitude: Number
    }]
}, {
    timestamps: true
});

const pvr3 = mongoose.model('pvr3Data', pvr3Schema);
export default pvr3;