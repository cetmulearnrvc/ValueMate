import mongoose from "mongoose";


// Sub-schema for valuation details, corresponding to the ValuationDetailItem class
const valuationDetailItemSchema = new mongoose.Schema({
    description: {
        type: String,
        default: ''
    },
    area: {
        type: String,
        default: ''
    },
    ratePerUnit: {
        type: String,
        default: ''
    },
    estimatedValue: {
        type: String,
        default: ''
    }
}, { _id: false }); // _id is not needed for these sub-documents

// Sub-schema for images, corresponding to the ValuationImage class
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

// Main schema for SIB Valuation data, corresponding to the SIBValuationData class
const sibValuationSchemaFlat = new mongoose.Schema({
    
    
    // === Header Info ===
    valuerName: String,
    valuerQualifications: String,
    valuerRegInfo: String,
    valuerAddress: String,
    valuerContact: String,
    valuerEmail: String,

    // === Recipient Info ===
    refNo: String,
    bankName: String,
    branchName: String,
    branchAddress: String,

    // === I. PROPERTY DETAILS ===
    purposeOfValuation: String,
    dateOfInspection: Date,
    dateOfValuation: Date,
    
    // Documents for Persual
    docLandTaxReceipt: String,
    docTitleDeed: String,
    docBuildingCertificate: String,
    docLocationSketch: String,
    docPossessionCertificate: String,
    docBuildingCompletionPlan: String,
    docThandapperDocument: String,
    docBuildingTaxReceipt: String,
    
    nameOfOwner: String,
    nameOfApplicant: String,
    addressAsPerDocuments: String,
    addressAsPerActual: String,
    deviations: String,
    propertyTypeLeaseholdFreehold: String,
    propertyZone: String,
    classificationAreaHighMiddlePoor: String,
    classificationAreaUrbanSemiRural: String,
    comingUnder: String,
    coveredUnderGovtEnactments: String,
    isAgriculturalLand: String,

    // === II. APARTMENT BUILDING ===
    natureOfApartment: String,
    yearOfConstruction: String,
    numFloorsActuals: String,
    numFloorsApproved: String,
    numUnitsActuals: String,
    numUnitsApproved: String,
    deviationsActuals: String,
    deviationsApproved: String,
    roadWidth: String,
    reraNoAndDate: String,
    typeOfStructure: String,
    ageOfBuilding: String,
    residualAge: String,
    maintenanceOfBuilding: String,
    facilitiesLift: String,
    facilitiesWater: String,
    facilitiesSewerage: String,
    facilitiesCarParking: String,
    facilitiesCompoundWall: String,
    facilitiesPavement: String,
    facilitiesExtraAmenities: String,

    // === III (FLAT) ===
    flatFloor: String,
    flatDoorNo: String,
    specRoof: String,
    specFlooring: String,
    specDoors: String,
    specWindows: String,
    specFittings: String,
    specFinishing: String,
    electricityConnectionNo: String,
    meterCardName: String,
    flatMaintenance: String,
    saleDeedName: String,
    undividedLandArea: String,
    flatArea: String,
    flatClass: String,
    flatUsage: String,
    flatOccupancy: String,
    flatMonthlyRent: String,

    // === IV. Rate ===
    rateComparable: String,
    rateNewConstruction: String,
    rateGuideline: String,

    // === Details of Valuation (Table) ===
    valuationDetails: [valuationDetailItemSchema],

    // === Consolidated Remarks ===
    remarks1: String,
    remarks2: String,
    remarks3: String,
    remarks4: String,

    // === Page 4 - Final Valuation Summary ===
    valuationApproach: String,
    presentMarketValue: String,
    realizableValue: String,
    distressValue: String,
    insurableValue: String,
    finalValuationPlace: String,
    finalValuationDate: Date,

    // === Page 7 - Final Table ===
    p7background: String,
    p7purpose: String,
    p7identity: String,
    p7disclosure: String,
    p7dates: String,
    p7inspections: String,
    p7nature: String,
    p7procedures: String,
    p7restrictions: String,
    p7majorFactors1: String,
    p7majorFactors2: String,
    p7caveats: String,
    p7reportDate: Date,
    p7reportPlace: String,
  
    // Images
    images: [valuationImageSchema]
}, {
    timestamps: true // Adds createdAt and updatedAt timestamps
});

const SIBValuationFlat = mongoose.model('SIBValuationData', sibValuationSchemaFlat);
export default SIBValuationFlat;