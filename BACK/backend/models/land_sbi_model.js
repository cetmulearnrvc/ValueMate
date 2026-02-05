import mongoose from "mongoose";


const advantagesSchema = new mongoose.Schema({
  label: { type: String },
  value: { type: String, default: "" }
});
const SBIValuationLandSchema = new mongoose.Schema({
    // Location coordinates
    refId: {
        type: String,
        required: true
    },

    // Document checks
    landTaxReceipt:String,
    titleDeed:String,
    buildingCertificate:String,
    locationSketch:String,
    possessionCertificate:String,
    buildingCompletionPlan:String,
    thandapperDocument:String,
    buildingTaxReceipt:String,

    // Page 1 fields
    purpose: String,
    dateOfInspection: String,
    dateOfValuation: String,
    ownerName: {
        type: String,
        required: true
    },
    locationOfProperty: String,
    briefdesc:String,
    addressDocument: String,
    addressActual: String,
    postalAddress: String,
    propertyType: String,
    propertyZone: String,
    plotNo:String,
    doorNo:String,
TSNO:String,
wardNo:String,
Mandal:String,

city:String,
residential:String,
commercial:String,
industrial:String,

rich:String,
placetype:String,
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
    dimNorthDocuments: String,
    dimSouthDocuments: String,
    dimEastDocuments: String,
    dimWestDocuments: String,
    dimNorthAdopted: String,
    dimSouthAdopted: String,
    dimEastAdopted: String,
    dimWestAdopted: String,
    dimDeviations: String,

    // Occupancy details
    latitudeLongitude: String,
    extent: String,
    extentConsidered: String,
    occupiedBySelfTenant: String,
    rentReceivedPerMonth: String,
    occupiedByTenantSince: String,


    // Road details
   locality: String,
development: String,
freqFlooding: String,
feasibilityCivic: String,
levelLand: String,
shape: String,
typeOfUse: String,
usageRestriction: String,
townPlanning: String,
corner: String,
roadFacilties: String,
typeOfRoad: String,
widthOfRoad: String,
isLandLocked: String,
waterPotential: String,
undergroundSewerage: String,
powerSupply: String,
advantages : [advantagesSchema],
remarks : [String],

sizeOfPlot: String,
northSouth: String,
eastWest: String,
totalExtent: String,
prevalingMarket: String,

    

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
    totalAbstractExtraItems: String,
    totalAbstractAmenities: String,
    totalAbstractMisc: String,
    totalAbstractService: String,

    

    // Final Valuation
    presentMarketValue: String,
    realizableValue: String,
    distressValue: String,
    place: String,


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


    //Page - 5(New format)
    foundationGround: String,
    foundationOther: String,
    basementGround: String,
    basementOther: String,
    superstructureGround: String,
    superstructureOther: String,
    joineryGround: String,
    joineryOther: String,
    rccWorksGround: String,
    rccWorksOther: String,
    plasteringGround: String,
    plasteringOther: String,
    flooringGround: String,
    flooringOther: String,
    specialFinishGround: String,
    specialFinishOther: String,
    roofingGround: String,
    roofingOther: String,
    drainageGround: String,
    drainageOther: String,
    kitchenGround: String,
    kitchenOther: String,

    //page 5 (second page)
    // --- SECTION 2: COMPOUND WALL ---
compoundWallGround: String,
compoundWallOther:String,
cwHeightGround:String,
cwHeightOther: String,
cwLengthGround: String,
cwLengthOther: String,
cwTypeGround:String,
cwTypeOther: String,

// --- SECTION 3: ELECTRICAL INSTALLATION ---
elecWiringGround:String, 
elecWiringOther:String,
elecFittingsGround:String,
elecFittingsOther: String,
elecLightPointsGround: String,
elecLightPointsOther: String,
elecFanPointsGround: String,
elecFanPointsOther: String,
elecPlugPointsGround: String,
elecPlugPointsOther: String,
elecOtherItemGround: String,
elecOtherItemOther: String,

// --- SECTION 4: PLUMBING INSTALLATION ---
plumClosetsGround: String,
plumClosetsOther:String,
plumBasinsGround: String,
plumBasinsOther: String,
plumUrinalsGround: String,
plumUrinalsOther:String,
plumTubsGround:String,
plumTubsOther: String,
plumWaterMeterGround: String,
plumWaterMeterOther: String,
plumFixturesGround:String,
plumFixturesOther:String,
stageofcontruction:String,


//page - 6(new format)
// --- DETAILS OF VALUATION ---
// Ground Floor (GF)
valPlinthGF:String,
valRoofHeightGF:String,
valAgeGF: String,
valRateGF: String,
valReplaceCostGF: String,
valDepreciationGF: String,
valNetValueGF:String,

// First Floor (FF)
valPlinthFF: String,
valRoofHeightFF: String,
valAgeFF: String,
valRateFF:String,
valReplaceCostFF:String,
valDepreciationFF:String,
valNetValueFF:String,

// Totals
valTotalPlinth:String,
valTotalReplaceCost: String,
valTotalDepreciation:String,
valTotalNetValue:String,


// Part C
extraPortico: String,
extraOrnamentalDoor: String,
extraSitout: String,
extraWaterTank: String,
extraSteelGates: String,
extraTotal: String,

// Part D
amenWardrobes: String,
amenGlazedTiles: String,
amenSinksTubs:String,
amenFlooring: String,
amenDecorations: String,
amenElevation: String,
amenPanelling: String,
amenAluminiumWorks: String,
amenHandRails: String,
amenFalseCeiling: String,
amenTotal: String,

// Part E
miscToiletRoom: String,
miscLumberRoom: String,
miscSump: String,
miscGardening:String,
miscTotal:String,

// Part F
servWaterSupply: String,
servDrainage: String,
servCompoundWall: String,
servDeposits:String,
servPavement: String,
servTotal: String,

    images: [{
        fileName: {
            type:String,
            required:true
        },
        filePath: {
            type:String,
            required:true
        },
        // fileID: {
        //     type:String,
        //     required:true
        // }
    }]
}, {
    timestamps: true
});

const SBIValuationLand = mongoose.model('SBIValuationLand', SBIValuationLandSchema);
export default SBIValuationLand;