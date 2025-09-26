// lib/data_model_sib.dart

import 'dart:typed_data';

class ValuationImage {
  // Using a class to potentially hold more data like lat/long in the future
  final Uint8List imageFile;
  String latitude;
  String longitude;
  ValuationImage({
    required this.imageFile,
    this.latitude = '',
    this.longitude = '',
  });
}

class ValuationDetailItem {
  String description;
  String area;
  String ratePerUnit;
  String estimatedValue;

  ValuationDetailItem({
    this.description = '',
    this.area = '',
    this.ratePerUnit = '',
    this.estimatedValue = '',
  });
}

class SIBValuationData {
  String nearbyLatitude;
  String nearbyLongitude;
  // === Header Info ===
  String valuerName;
  String valuerQualifications;
  String valuerRegInfo;
  String valuerAddress;
  String valuerContact;
  String valuerEmail;

  // === Recipient Info ===
  String refNo;
  String bankName;
  String branchName;
  String branchAddress;

  // === I. PROPERTY DETAILS ===
  String purposeOfValuation;
  DateTime? dateOfInspection;
  DateTime? dateOfValuation;

  // Documents for Persual
  String docLandTaxReceipt;
  String docTitleDeed;
  String docBuildingCertificate;
  String docLocationSketch;
  String docPossessionCertificate;
  String docBuildingCompletionPlan;
  String docThandapperDocument;
  String docBuildingTaxReceipt;

  String nameOfOwner;
  String nameOfApplicant;
  String addressAsPerDocuments;
  String addressAsPerActual;
  String deviations;
  String propertyTypeLeaseholdFreehold;
  String propertyZone;
  String classificationAreaHighMiddlePoor;
  String classificationAreaUrbanSemiRural;
  String comingUnder;
  String coveredUnderGovtEnactments;
  String isAgriculturalLand;

  // === II. APARTMENT BUILDING ===
  String natureOfApartment;
  String yearOfConstruction;
  String numFloorsActuals;
  String numFloorsApproved;
  String numUnitsActuals;
  String numUnitsApproved;
  String deviationsActuals;
  String deviationsApproved;
  String roadWidth;
  String reraNoAndDate;
  String typeOfStructure;
  String ageOfBuilding;
  String residualAge;
  String maintenanceOfBuilding;
  String facilitiesLift;
  String facilitiesWater;
  String facilitiesSewerage;
  String facilitiesCarParking;
  String facilitiesCompoundWall;
  String facilitiesPavement;
  String facilitiesExtraAmenities;

  // === III (FLAT) ===
  String flatFloor;
  String flatDoorNo;
  String specRoof;
  String specFlooring;
  String specDoors;
  String specWindows;
  String specFittings;
  String specFinishing;
  String electricityConnectionNo;
  String meterCardName;
  String flatMaintenance;
  String saleDeedName;
  String undividedLandArea;
  String flatArea; // Supper Built Up / Built Up / Carpet
  String flatClass; // Posh / I class / etc.
  String flatUsage; // Residential / Commercial
  String flatOccupancy; // Owner-occupied / let out
  String flatMonthlyRent;

  // === IV. Rate ===
  String rateComparable;
  String rateNewConstruction;
  String rateGuideline;

  // === Details of Valuation (Table) ===
  List<ValuationDetailItem> valuationDetails;

  // === Consolidated Remarks ===
  String remarks1;
  String remarks2;
  String remarks3;
  String remarks4;

  // === Page 4 - Final Valuation Summary ===
  String valuationApproach;
  String presentMarketValue;
  String realizableValue;
  String distressValue;
  String insurableValue;
  String finalValuationPlace;
  DateTime? finalValuationDate;

  // === Page 7 - Final Table ===
  String p7background;
  String p7purpose;
  String p7identity;
  String p7disclosure;
  String p7dates;
  String p7inspections;
  String p7nature;
  String p7procedures;
  String p7restrictions;
  String p7majorFactors1;
  String p7majorFactors2;
  String p7caveats;
  DateTime? p7reportDate;
  String p7reportPlace;

  List<ValuationImage> images;

  SIBValuationData({
    this.nearbyLatitude = '',
    this.nearbyLongitude = '',
    this.valuerName = 'VIGNESH. S',
    this.valuerQualifications = 'Chartered Engineer (AM1920793)',
    this.valuerRegInfo =
        'Registered valuer under section 247 of Companies Act, 2013 (IBBI/RV/01/2020/13411)\nRegistered valuer under section 34AB of Wealth Tax Act, 1957 (I-9AV/CC-TVM/2020-21)\nRegistered valuer under section 77(1) of Black Money Act, 2015 (I-3/AV-BM/PCIT-TVM/2023-24)',
    this.valuerAddress =
        'TC-37/777(1), Big Palla Street, Fort P.O. Thiruvananthapuram-695023',
    this.valuerContact = '+91 89030 42635',
    this.valuerEmail = 'subramonyvignesh@gmail.com',
    this.refNo = '',
    this.bankName = 'The South Indian Bank',
    this.branchName = 'Chakai Branch',
    this.branchAddress = 'Thiruvananthapuram',
    // Set dateOfInspection to DateTime.now() if not provided
    DateTime?
        dateOfInspection, // Make it nullable here to handle the default logic
    DateTime? dateOfValuation,
    DateTime? finalValuationDate,
    DateTime? p7reportDate,
    this.purposeOfValuation = '',
    this.docLandTaxReceipt = '',
    this.docTitleDeed = '',
    this.docBuildingCertificate = '',
    this.docLocationSketch = '',
    this.docPossessionCertificate = '',
    this.docBuildingCompletionPlan = '',
    this.docThandapperDocument = '',
    this.docBuildingTaxReceipt = '',
    this.nameOfOwner = '',
    this.nameOfApplicant = '',
    this.addressAsPerDocuments = '',
    this.addressAsPerActual = '',
    this.deviations = '',
    this.propertyTypeLeaseholdFreehold = '',
    this.propertyZone = '',
    this.classificationAreaHighMiddlePoor = '',
    this.classificationAreaUrbanSemiRural = '',
    this.comingUnder = '',
    this.coveredUnderGovtEnactments = '',
    this.isAgriculturalLand = '',
    this.natureOfApartment = '',
    this.yearOfConstruction = '',
    this.numFloorsActuals = '',
    this.numFloorsApproved = '',
    this.numUnitsActuals = '',
    this.numUnitsApproved = '',
    this.deviationsActuals = '',
    this.deviationsApproved = '',
    this.roadWidth = '',
    this.reraNoAndDate = '',
    this.typeOfStructure = '',
    this.ageOfBuilding = '',
    this.residualAge = '',
    this.maintenanceOfBuilding = '',
    this.facilitiesLift = '',
    this.facilitiesWater = '',
    this.facilitiesSewerage = '',
    this.facilitiesCarParking = '',
    this.facilitiesCompoundWall = '',
    this.facilitiesPavement = '',
    this.facilitiesExtraAmenities = '',
    this.flatFloor = '',
    this.flatDoorNo = '',
    this.specRoof = '',
    this.specFlooring = '',
    this.specDoors = '',
    this.specWindows = '',
    this.specFittings = '',
    this.specFinishing = '',
    this.electricityConnectionNo = '',
    this.meterCardName = '',
    this.flatMaintenance = '',
    this.saleDeedName = '',
    this.undividedLandArea = '',
    this.flatArea = '',
    this.flatClass = 'Medium',
    this.flatUsage = 'Residential',
    this.flatOccupancy = 'Owner-occupied',
    this.flatMonthlyRent = '',
    this.rateComparable = '',
    this.rateNewConstruction = '',
    this.rateGuideline = '',
    List<ValuationDetailItem>? valuationDetails,
    this.remarks1 = '',
    this.remarks2 = '',
    this.remarks3 = '',
    this.remarks4 = '',
    this.valuationApproach = '',
    this.presentMarketValue = '',
    this.realizableValue = '',
    this.distressValue = '',
    this.insurableValue = '',
    this.finalValuationPlace = 'Thiruvananthapuram',
    this.p7background = 'The property is a 1.62 Ares residential building,',
    this.p7purpose =
        'To assess the present fair market value, realizable value, distress value of the property offered as primary security for Mr. Babu',
    this.p7identity = 'Vignesh S',
    this.p7disclosure =
        'The property was not physically measured as the customer was not willing',
    this.p7dates = '02-09-2024, 04-09-2024, 06-09-2024',
    this.p7inspections = 'The property was inspected on 04-09-2024',
    this.p7nature = 'Documents submitted for verification',
    this.p7procedures = 'Comparable Sale Method & Replacement Method',
    this.p7restrictions =
        'This report shall be used to determine the present market value of the property only for the purpose of bank’s security',
    this.p7majorFactors1 =
        'The Land extent considered is as per the revenue records produced for verification, separated using compound wall',
    this.p7majorFactors2 =
        'The building extend considered in this report is as per the measurement taken on the date of site visit',
    this.p7caveats =
        'The value is an estimate considering the local enquiry, this may vary depending on the date and purpose of valuation',
    this.p7reportPlace = 'Thiruvananthapuram',
    List<ValuationImage>? images,
  })  : // Initialize date fields with DateTime.now() if not provided
        dateOfInspection = DateTime.now(),
        dateOfValuation = DateTime.now(),
        finalValuationDate = DateTime.now(),
        p7reportDate = p7reportDate ?? DateTime.now(),
        images = images ?? [],
        valuationDetails = valuationDetails ??
            [
              ValuationDetailItem(description: 'Present value of the flat'),
              ValuationDetailItem(description: 'Car park'),
              ValuationDetailItem(description: 'Wardrobes'),
              ValuationDetailItem(description: 'Any additional'),
            ];
}
