import 'dart:typed_data';

class ValuationImage {
  final Uint8List imageFile;
  String latitude;
  String longitude;
  ValuationImage({
    required this.imageFile,
    this.latitude = '',
    this.longitude = '',
  });
}

class ValuationData {
  String nearbyLatitude;
  String nearbyLongitude;

  // Valuer Header Info
  String valuerNameAndQuals;
  String valuerCredentials;
  String valuerAddressLine1;
  String valuerMob;
  String valuerEmail;

  // Header
  String bankName;
  String branchName;

  // General Section
  String caseType;
  DateTime? inspectionDate;
  String applicationNo;
  String titleHolderName;
  String borrowerName;

  // Documents Verified
  String landTaxReceiptNo;
  String possessionCertNo;
  String locationSketchNo;
  String thandaperAbstractNo;
  String approvedLayoutPlanNo;
  String approvedBuildingPlanNo;

  // Physical Details of Land
  String briefDescription;
  String locationAndLandmark;
  String reSyNo;
  String blockNo;
  String village;
  String taluk;
  String district;
  String state;
  String postOffice;
  String pinCode;
  String postalAddress;

  // Boundaries
  String northAsPerSketch;
  String northActual;
  String southAsPerSketch;
  String southActual;
  String eastAsPerSketch;
  String eastActual;
  String westAsPerSketch;
  String westActual;

  // Page 2 Details
  String localAuthority;
  bool isPropertyIdentified;
  String plotDemarcated;
  String natureOfProperty;
  String classOfProperty;
  String topographicalCondition;
  bool chanceOfAcquisition;
  String approvedLandUse;
  String fourWheelerAccessibility;
  String occupiedBy;
  String yearsOfOccupancy;
  String ownerRelationship;

  // Area Details
  String areaOfLand;
  String carpetArea;
  String plinthArea;
  String saleableArea;

  // Detailed Valuation (Land)
  String landExtent;
  String landRatePerCent;
  String landTotalValue;
  String landMarketValue;
  String landRealizableValue;
  String landDistressValue;
  String landFairValue;

  String buildingPlinth;
  String buildingRatePerSqft;
  String buildingTotalValue;
  String buildingMarketValue;
  String buildingRealizableValue;
  String buildingDistressValue;

  // II. PHYSICAL DETAILS OF BUILDING
  String buildingNo;
  String approvingAuthority;
  String stageOfConstruction;
  String typeOfStructure;
  String noOfFloors;
  String livingDiningRooms;
  String bedrooms;
  String toilets;
  String kitchen;
  String typeOfFlooring;
  String ageOfBuilding;
  String residualLife;
  String violationObserved;

  // Grand Total
  String grandTotalMarketValue;
  String grandTotalRealizableValue;
  String grandTotalDistressValue;

  // Declaration
  DateTime? declarationDate;
  String declarationPlace;
  String valuerName;
  String valuerAddress;
  String remarks;
  late List<ValuationImage> images;

  ValuationData({
    this.nearbyLatitude = '',
    this.nearbyLongitude = '',
    this.valuerNameAndQuals = 'Er. Belram S.U. B.Tech, AMIE, AIV',
    this.valuerCredentials =
        'Chartered Engineer (AM 190746-0)\nApproved Valuer Cat 1 (A-29296)\nPanel Valuer of IDBI Bank',
    this.valuerAddressLine1 =
        'Ushas Nivas TC 7/1997-1 Pangode Thirumala PO Thiruvananthapuram Pin Code - 695006',
    this.valuerMob = '+91-8089697914',
    this.valuerEmail = 'belramsu@gmail.com',
    this.buildingPlinth = '',
    this.buildingRatePerSqft = '',
    this.buildingTotalValue = '',
    this.buildingMarketValue = '',
    this.buildingDistressValue = '',
    this.buildingRealizableValue = '',
    this.bankName = 'IDBI Bank',
    this.branchName = 'ULLOOR BRANCH',
    this.caseType = '',
    this.inspectionDate,
    this.applicationNo = '',
    this.titleHolderName = '',
    this.borrowerName = '',
    this.landTaxReceiptNo = '',
    this.possessionCertNo = '',
    this.locationSketchNo = '',
    this.thandaperAbstractNo = '',
    this.approvedLayoutPlanNo = '',
    this.approvedBuildingPlanNo = '',
    this.briefDescription = '',
    this.locationAndLandmark = '',
    this.reSyNo = '',
    this.blockNo = '',
    this.village = '',
    this.taluk = '',
    this.district = '',
    this.state = '',
    this.postOffice = '',
    this.pinCode = '',
    this.postalAddress = '',
    this.northAsPerSketch = '',
    this.northActual = '',
    this.southAsPerSketch = '',
    this.southActual = '',
    this.eastAsPerSketch = '',
    this.eastActual = '',
    this.westAsPerSketch = '',
    this.westActual = '',
    this.localAuthority = '',
    this.isPropertyIdentified = false,
    this.plotDemarcated = '',
    this.natureOfProperty = '',
    this.classOfProperty = '',
    this.topographicalCondition = '',
    this.chanceOfAcquisition = false,
    this.approvedLandUse = '',
    this.fourWheelerAccessibility = '',
    this.occupiedBy = '',
    this.yearsOfOccupancy = '',
    this.ownerRelationship = '',
    this.areaOfLand = '',
    this.carpetArea = '',
    this.plinthArea = '',
    this.saleableArea = '',
    this.landExtent = '',
    this.landRatePerCent = '',
    this.landTotalValue = '',
    this.landMarketValue = '',
    this.landRealizableValue = '',
    this.landDistressValue = '',
    this.landFairValue = '',
    this.grandTotalMarketValue = '',
    this.grandTotalRealizableValue = '',
    this.grandTotalDistressValue = '',
    this.declarationDate,
    this.declarationPlace = '',
    this.valuerName = '',
    this.valuerAddress = '',
    this.buildingNo = '',
    this.approvingAuthority = '',
    this.stageOfConstruction = '',
    this.typeOfStructure = '',
    this.noOfFloors = '',
    this.livingDiningRooms = '',
    this.bedrooms = '',
    this.toilets = '',
    this.kitchen = '',
    this.typeOfFlooring = '',
    this.ageOfBuilding = '',
    this.residualLife = '',
    this.violationObserved = '',
    this.remarks = '',
  });
}
