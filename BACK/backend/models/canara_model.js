import mongoose from "mongoose";

const canaraSchema = new mongoose.Schema({
    // Basic Information
    referenceNo:String,
    Date:String,
    purpose: String,
    inspectionDate: String,
    valuationDate: String,
    ownerName: {
        type: String,
        required: true
    },
    ownerAddress: String,
    documents: String,
    propertyDescription: String,
    scope: String,
    bank: String,

    // Description of Property
    propertyAddress: {
        type: String,
        required: true
    },
    cityTown: String,
    residentialArea: String,
    classification: String,
    urbanClassification: String,
    localAuthority: String,
    govtActs: String,
    agriculturalConversion: String,
    blockNo: String,
    resurveyNo: String,
    surveyNo: String,
    thandapperNo: String,
    wardNo: String,
    doorNo: String,
    tsNo: String,
    taluk: String,
    district: String,
    northBoundary: String,
    southBoundary: String,
    eastBoundary: String,
    westBoundary: String,
    northBoundaryActual: String,
    southBoundaryActual: String,
    eastBoundaryActual: String,
    westBoundaryActual: String,
    latitudelongitude: String,
    taxPeriod: String,
    buildingId: String,
    assessmentNo: String,
    taxAmount: String,
    taxReceiptName: String,
    consumerNo: String,
    electricityName: String,
    otherDetails: String,
    occupancyStatus: String,
    tenatedRent: String,
    monthlyRent: String,
    advanceAmount: String,
    fsi: String,
    plotCoverage: String,

    // Land Details
    northDeed: String,
    southDeed: String,
    eastDeed: String,
    westDeed: String,
    extentDeed: String,
    northActual: String,
    southActual: String,
    eastActual: String,
    westActual: String,
    extentActual: String,
    extentConsidered: String,
    plotSizeNS: String,
    plotSizeEW: String,
    totalExtent: String,
    localityCharacter: String,
    localityClassification: String,
    surroundingDevelopment: String,
    flooding: String,
    amenities: String,
    landLevel: String,
    landShape: String,
    landUse: String,
    usageRestriction: String,
    townPlanning: String,
    plotType: String,
    roadFacilities: String,
    roadType: String,
    roadWidth: String,
    landLocked: String,
    waterPotential: String,
    sewerage: String,
    powerSupply: String,
    siteAdvantages: String,
    specialRemarks: String,
    glrRate: String,
    glrValue: String,
    pmrRate: String,
    pmrAdopted: String,
    pmrAdoptedValue: String,
    pmrValue: String,

    // Building Details
    buildingType: String,
    constructionType: String,
    constructionQuality: String,
    appearance: String,
    exteriorCondition: String,
    interiorCondition: String,
    plinthArea: String,
    floors: String,
    gfYear: String,
    gfRoof: String,
    gfArea: String,
    gfCantilever: String,
    gfTotal: String,
    ffYear: String,
    ffRoof: String,
    ffArea: String,
    ffCantilever: String,
    ffTotal: String,
    terraceYear: String,
    terraceRoof: String,
    terraceArea: String,
    terraceTotal: String,
    totalArea: String,
    approvedPlanNo: String,
    approvedPlanAuthority: String,
    planVerified: String,
    gfSpecification: String,
    gfFloorFinish: String,
    gfSuperStructure: String,
    gfRoofType: String,
    gfDoors: String,
    gfWindows: String,
    gfWeathering: String,
    gfConstructionYear: String,
    gfAge: String,
    gfRemainingLife: String,
    gfDepreciation: String,
    gfReplacementRate: String,
    ffSpecification: String,
    ffFloorFinish: String,
    ffSuperStructure: String,
    ffRoofType: String,
    ffDoors: String,
    ffWindows: String,
    ffWeathering: String,
    ffConstructionYear: String,
    ffAge: String,
    ffRemainingLife: String,
    ffDepreciation: String,
    ffReplacementRate: String,
    presentValue: String,

    // Valuer details
    valuerName: String,
    valuerAddress: String,
    valuerPhone: String,
    valuerEmail: String,
    valuerRegNo: String,
    valuerIBBIReg: String,
    valuerWealthTaxReg: String,
    valuerBlackMoneyReg: String,

    // Amenities & Extra Items (Main 1-20)
    amenityPortico: String,
    amenityOrnamentalDoor: String,
    amenitySitoutGrills: String,
    amenitySteelGates: String,
    amenityOpenStaircase: String,
    amenityWardrobes: String,
    amenityGlazedTiles: String,
    amenityExtraSinks: String,
    amenityMarbleTiles: String,
    amenityInteriorDecor: String,
    amenityElevationWorks: String,
    amenityFalseCeiling: String,
    amenityPanelingWorks: String,
    amenityAluminumWorks: String,
    amenityAluminumHandrails: String,
    amenityLumberRoom: String,
    amenityToiletRoom: String,
    amenityWaterTankSump: String,
    amenityGardening: String,
    amenityAnyOther: String,

    // Water supply arrangements
    amenityOpenWell: String,
    amenityDeepBore: String,
    amenityHandPump: String,
    amenityCorporationTap: String,
    amenityUndergroundSump: String,
    amenityOverheadWaterTank: String,

    // Drainage arrangements
    amenitySepticTank: String,
    amenityUndergroundSewerage: String,

    // Compound wall, pavements, steel gate
    amenityCompoundWall: String,
    amenityCompoundWallHeight: String,
    amenityCompoundWallLength: String,
    amenityCompoundWallType: String,
    amenityPavements: String,
    amenitySteelGateRm: String,

    // Deposits
    amenityEBDeposits: String,
    amenityWaterDeposits: String,
    amenityDrainageDeposits: String,

    // Electrical fittings & others
    amenityWiringType: String,
    amenityFittingsClass: String,
    amenityLightPoints: String,
    amenityFanPoints: String,
    amenityPlugPoints: String,
    amenityElectricalOther: String,

    // Plumbing installation
    amenityNoOfClosets: String,
    amenityClosetsType: String,
    amenityNoOfWashBasins: String,
    amenityNoOfBathTubs: String,
    amenityWaterMeterTaps: String,
    amenityPlumbingOtherFixtures: String,

    // Any other & Total
    amenityAnyOtherItem: String,
    amenityTotal: String,

    // Abstract fields
    absLandGlr: String,
    absLandPmr: String,
    absBuildingGlr: String,
    absBuildingPmr: String,
    absExtraGlr: String,
    absExtraPmr: String,
    absAmenitiesGlr: String,
    absAmenitiesPmr: String,
    absTotalGlr: String,
    absTotalPmr: String,
    absSayGlr: String,
    absSayPmr: String,

    // Commercial and industrial
    commercialArea: String,
    industrialArea: String,

    // Image handling (if needed)
    // pickedImages: [Buffer], // Uncomment if you want to store images as Buffer

    // Lat/long
    nearByLat: String,
    nearByLong: String,

    images: [{
        fileName: {
            type:String,
            required:true
        },
        filePath: {
            type:String,
            required:true
        },
        /* fileID: {
            type:String,
            required:true
        }, */
        latitude: Number,
        longitude: Number,
    }]
}, {
    timestamps: true
});

const Canara = mongoose.model('Canara', canaraSchema);
export default Canara;