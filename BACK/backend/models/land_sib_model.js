import mongoose from "mongoose";

const documentChecksSchema = new mongoose.Schema({
    landTaxReceipt: Boolean,
    titleDeed: Boolean,
    buildingCertificate: Boolean,
    locationSketch: Boolean,
    possessionCertificate: Boolean,
    buildingCompletionPlan: Boolean,
    thandapperDocument: Boolean,
    buildingTaxReceipt: Boolean
}, { _id: false });

const SIBValuationLandSchema = new mongoose.Schema({
    // Location coordinates
    refId: {
        type: String,
        required: true
    },

    // Document checks
    documentChecks: documentChecksSchema,

    // Page 1 fields
    purpose: String,
    dateOfInspection: String,
    dateOfValuation: String,
    ownerName: {
        type: String,
        required: true
    },
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

    // Occupancy details
    latitudeLongitude: String,
    occupiedBySelfTenant: String,
    rentReceivedPerMonth: String,
    occupiedByTenantSince: String,

    // Floor details - Ground Floor
    groundFloorOccupancy: String,
    groundFloorNoOfRoom: String,
    groundFloorNoOfKitchen: String,
    groundFloorNoOfBathroom: String,
    groundFloorUsageRemarks: String,

    // Floor details - First Floor
    firstFloorOccupancy: String,
    firstFloorNoOfRoom: String,
    firstFloorNoOfKitchen: String,
    firstFloorNoOfBathroom: String,
    firstFloorUsageRemarks: String,

    // Road details
    typeOfRoad: String,
    widthOfRoad: String,
    isLandLocked: String,

    // Land Valuation Table
    landAreaDetails: String,
    landAreaGuideline: String,
    landAreaPrevailing: String,
    ratePerSqFtGuideline: String,
    ratePerSqFtPrevailing: String,
    valueInRsGuideline: String,
    valueInRsPrevailing: String,

    // Building Valuation Table
    typeOfBuilding: String,
    typeOfConstruction: String,
    ageOfTheBuilding: String,
    residualAgeOfTheBuilding: String,
    approvedMapAuthority: String,
    genuinenessVerified: String,
    otherComments: String,

    // Build up Area - Ground Floor
    groundFloorApprovedPlan: String,
    groundFloorActual: String,
    groundFloorConsideredValuation: String,
    groundFloorReplacementCost: String,
    groundFloorDepreciation: String,
    groundFloorNetValue: String,

    // Build up Area - First Floor
    firstFloorApprovedPlan: String,
    firstFloorActual: String,
    firstFloorConsideredValuation: String,
    firstFloorReplacementCost: String,
    firstFloorDepreciation: String,
    firstFloorNetValue: String,

    // Build up Area - Total
    totalApprovedPlan: String,
    totalActual: String,
    totalConsideredValuation: String,
    totalReplacementCost: String,
    totalDepreciation: String,
    totalNetValue: String,

    // Amenities
    wardrobes: String,
    amenities: String,
    anyOtherAdditional: String,
    amenitiesTotal: String,

    // Total abstract
    totalAbstractLand: String,
    totalAbstractBuilding: String,
    totalAbstractAmenities: String,
    totalAbstractTotal: String,
    totalAbstractSay: String,

    // Consolidated Remarks
    remark1: String,
    remark2: String,
    remark3: String,
    remark4: String,

    // Final Valuation
    presentMarketValue: String,
    realizableValue: String,
    distressValue: String,
    insurableValue: String,

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

    images: [{
        fileName: {
            type:String,
            required:true
        },
        fileID: {
            type:String,
            required:true
        }
    }]
}, {
    timestamps: true
});

const SIBValuationLand = mongoose.model('SIBValuationLand', SIBValuationLandSchema);
export default SIBValuationLand;