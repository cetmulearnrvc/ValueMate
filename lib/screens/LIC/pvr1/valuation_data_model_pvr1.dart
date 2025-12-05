// lib/valuation_data_model_pvr1.dart

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

class ValuationDataPVR1 {
  String nearbyLatitude;
  String nearbyLongitude;
  // Header
  final String valuerName, valuerCode;
  final DateTime inspectionDate;

  // A. General
  final String fileNo,
      applicantName,
      ownerName,
      documentsPerused,
      propertyLocation;
  final bool addressTallies, locationSketchVerified;
  final String surroundingDev,
      negativesToLocality,
      favorableConsiderations,
      nearbyLandmark,
      otherFeatures;
  final bool basicAmenitiesAvailable;

  // B. Land
  final String northBoundary, southBoundary, eastBoundary, westBoundary;
  final String northDim, southDim, eastDim, westDim;
  final String totalExtent1, totalExtent2;
  final bool boundariesTally;
  final String natureOfLandUse, existingLandUse, proposedLandUse;
  final bool naPermissionRequired;

  // C. Buildings
  final String approvalNo, validityPeriod, approvalAuthority;
  final bool isValidityExpiredRenewed;
  final String approvedGf, approvedFf, approvedSf;
  final String actualGf, actualFf, actualSf;
  final String estimateCost, costPerSqFt;
  final bool isEstimateReasonable;
  final String marketability, fsi, dwellingUnits;
  final bool isConstructionAsPerPlan;
  final String deviations, deviationNature;
  final bool revisedApprovalNecessary;
  final String worksCompletedPercentage;
  final bool adheresToSafety, highTensionImpact;

  // D. Inspection
  final String plinthApproved, plinthActual;
  final String worksCompletedValue;

  // E. Total Value
  final String landValueApp, landValueGuide, landValueMarket;
  final String buildingStageValueApp,
      buildingStageValueGuide,
      buildingStageValueMarket;
  final String buildingCompletionValueApp,
      buildingCompletionValueGuide,
      buildingCompletionValueMarket;
  final String marketValueSource, buildingUsage;

  // F. Recommendation
  final String recBackground,
      recSources,
      recProcedures,
      recMethodology,
      recFactors;

  // Stage of Construction Table
  final String stageOfConstruction, progressPercentage;

  // G. Certificate
  final DateTime certificateDate;
  final String certificatePlace;

  // Annexure
  final String annexLandArea, annexLandUnitRateMarket, annexLandUnitRateGuide;
  final String annexGfArea, annexGfUnitRateMarket, annexGfUnitRateGuide;
  final String annexFfArea, annexFfUnitRateMarket, annexFfUnitRateGuide;
  final String annexSfArea, annexSfUnitRateMarket, annexSfUnitRateGuide;
  final String annexAmenitiesMarket, annexAmenitiesGuide;
  final String annexYearOfConstruction, annexBuildingAge;

  // Images
  final List<ValuationImage> images;

  ValuationDataPVR1({
    this.buildingCompletionValueApp = '',
    this.buildingCompletionValueGuide = '',
    this.buildingCompletionValueMarket = '',
    this.nearbyLatitude = '',
    this.nearbyLongitude = '',
    required this.worksCompletedValue,
    required this.buildingStageValueGuide,
    required this.buildingStageValueMarket,
    required this.natureOfLandUse,
    required this.valuerName,
    required this.valuerCode,
    required this.inspectionDate,
    required this.fileNo,
    required this.applicantName,
    required this.ownerName,
    required this.documentsPerused,
    required this.propertyLocation,
    required this.addressTallies,
    required this.locationSketchVerified,
    required this.surroundingDev,
    required this.negativesToLocality,
    required this.favorableConsiderations,
    required this.nearbyLandmark,
    required this.otherFeatures,
    required this.basicAmenitiesAvailable,
    required this.northBoundary,
    required this.southBoundary,
    required this.eastBoundary,
    required this.westBoundary,
    required this.northDim,
    required this.southDim,
    required this.eastDim,
    required this.westDim,
    required this.totalExtent1,
    required this.totalExtent2,
    required this.boundariesTally,
    required this.existingLandUse,
    required this.proposedLandUse,
    required this.naPermissionRequired,
    required this.approvalNo,
    required this.validityPeriod,
    required this.approvalAuthority,
    required this.isValidityExpiredRenewed,
    required this.approvedGf,
    required this.approvedFf,
    required this.approvedSf,
    required this.actualGf,
    required this.actualFf,
    required this.actualSf,
    required this.estimateCost,
    required this.costPerSqFt,
    required this.isEstimateReasonable,
    required this.marketability,
    required this.fsi,
    required this.dwellingUnits,
    required this.isConstructionAsPerPlan,
    required this.deviations,
    required this.deviationNature,
    required this.revisedApprovalNecessary,
    required this.worksCompletedPercentage,
    required this.adheresToSafety,
    required this.highTensionImpact,
    required this.plinthApproved,
    required this.plinthActual,
    required this.landValueApp,
    required this.landValueGuide,
    required this.landValueMarket,
    required this.buildingStageValueApp,
    required this.marketValueSource,
    required this.buildingUsage,
    required this.recBackground,
    required this.recSources,
    required this.recProcedures,
    required this.recMethodology,
    required this.recFactors,
    required this.stageOfConstruction,
    required this.progressPercentage,
    required this.certificateDate,
    required this.certificatePlace,
    required this.annexLandArea,
    required this.annexLandUnitRateMarket,
    required this.annexLandUnitRateGuide,
    required this.annexGfArea,
    required this.annexGfUnitRateMarket,
    required this.annexGfUnitRateGuide,
    required this.annexFfArea,
    required this.annexFfUnitRateMarket,
    required this.annexFfUnitRateGuide,
    required this.annexSfArea,
    required this.annexSfUnitRateMarket,
    required this.annexSfUnitRateGuide,
    required this.annexAmenitiesMarket,
    required this.annexAmenitiesGuide,
    required this.annexYearOfConstruction,
    required this.annexBuildingAge,
    required this.images,
  });
}
