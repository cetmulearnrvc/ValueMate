import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:login_screen/ref_id.dart';
import 'package:login_screen/screens/SBI/land_and_building/savedDraftsSBIland.dart';
import 'package:login_screen/screens/nearbyDetails.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart' as pdfLib;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb; // Needed for kIsWeb check
import 'dart:typed_data'; // For Uint8List
import 'dart:io'; // For File class (used conditionally for non-web)
import 'package:geolocator/geolocator.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'config.dart';
import 'package:number_to_indian_words/number_to_indian_words.dart';

// import 'package:login_screen/screens/driveAPIconfig.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Valuation Report Generator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        // Use Inter font if available, otherwise default
        fontFamily: 'Inter',
      ),
      home: const SBIValuationFormPage(propertyData: {}),
    );
  }
}

class SBIValuationFormPage extends StatefulWidget {
  final Map<String, dynamic>? propertyData;
  const SBIValuationFormPage({super.key, this.propertyData});

  @override
  State<SBIValuationFormPage> createState() => _ValuationFormPageState();
}

class _ValuationFormPageState extends State<SBIValuationFormPage> {
  @override
  void initState() {
    super.initState();
    if (widget.propertyData != null) {
      // Use the passed data to initialize your form only if it exists
      //debugPrint('Received property data: ${widget.propertyData}');
      // Example:
      // _fileNoController.text = widget.propertyData!['fileNo'].toString();
    } else {
      //debugPrint('No property data received - creating new valuation');
      // Initialize with empty/default values
    }
    _initializeFormWithPropertyData();
  }

  final TextEditingController _latController = TextEditingController();
  final TextEditingController _lonController = TextEditingController();

  final TextEditingController _latitude = TextEditingController();
  final TextEditingController _longitude = TextEditingController();

  final TextEditingController _refId = TextEditingController();
  final TextEditingController _BriefDescription = TextEditingController();

  // Controllers for text input fields (Page 1)
  final TextEditingController _purposeController = TextEditingController();
  final TextEditingController _dateOfInspectionController =
      TextEditingController();
  final TextEditingController _dateOfValuationController =
      TextEditingController();
  final TextEditingController _ownerNameController = TextEditingController();
  final TextEditingController _LocationOfProperty = TextEditingController();
  final TextEditingController _addressDocController = TextEditingController();
  final TextEditingController _addressActualController =
      TextEditingController();
  final TextEditingController _postalAddress = TextEditingController();
  final TextEditingController _propertyTypeController = TextEditingController();
  final TextEditingController _propertyZoneController = TextEditingController();

  final TextEditingController _city = TextEditingController();
  final TextEditingController _residential = TextEditingController();
  final TextEditingController _commercial = TextEditingController();
  final TextEditingController _industrial = TextEditingController();

  final TextEditingController _typeOfRichness = TextEditingController();
  final TextEditingController _typeOfPlace = TextEditingController();

  final TextEditingController _comingUnderCorporationController =
      TextEditingController();
  final TextEditingController _coveredUnderStateCentralGovtController =
      TextEditingController();
  final TextEditingController _agriculturalLandConversionController =
      TextEditingController();

  // Boundaries of the property controllers
  final TextEditingController _boundaryNorthTitleController =
      TextEditingController();
  final TextEditingController _boundarySouthTitleController =
      TextEditingController();
  final TextEditingController _boundaryEastTitleController =
      TextEditingController();
  final TextEditingController _boundaryWestTitleController =
      TextEditingController();
  final TextEditingController _boundaryNorthSketchController =
      TextEditingController();
  final TextEditingController _boundarySouthSketchController =
      TextEditingController();
  final TextEditingController _boundaryEastSketchController =
      TextEditingController();
  final TextEditingController _boundaryWestSketchController =
      TextEditingController();
  final TextEditingController _boundaryDeviationsController =
      TextEditingController();

  // Dimensions of the site controllers
  final TextEditingController _dimNorthActualsController =
      TextEditingController();
  final TextEditingController _dimSouthActualsController =
      TextEditingController();
  final TextEditingController _dimEastActualsController =
      TextEditingController();
  final TextEditingController _dimWestActualsController =
      TextEditingController();

  final TextEditingController _dimNorthDocumentsController =
      TextEditingController();
  final TextEditingController _dimSouthDocumentsController =
      TextEditingController();
  final TextEditingController _dimEastDocumentsController =
      TextEditingController();
  final TextEditingController _dimWestDocumentsController =
      TextEditingController();

  final TextEditingController _dimNorthAdoptedController =
      TextEditingController();
  final TextEditingController _dimSouthAdoptedController =
      TextEditingController();
  final TextEditingController _dimEastAdoptedController =
      TextEditingController();
  final TextEditingController _dimWestAdoptedController =
      TextEditingController();
  final TextEditingController _dimDeviationsController =
      TextEditingController();

  // Occupancy details controllers
  final TextEditingController _latitudeLongitudeController =
      TextEditingController();
  final TextEditingController _extent = TextEditingController();
  final TextEditingController _extentConsidered = TextEditingController();
  final TextEditingController _occupiedBySelfTenantController =
      TextEditingController();
  final TextEditingController _rentReceivedPerMonthController =
      TextEditingController();
  final TextEditingController _occupiedByTenantSinceController =
      TextEditingController();

  // Floor details controllers (for a fixed number of rows for simplicity)
  final TextEditingController _groundFloorOccupancyController =
      TextEditingController();
  final TextEditingController _groundFloorNoOfRoomController =
      TextEditingController();
  final TextEditingController _groundFloorNoOfKitchenController =
      TextEditingController();
  final TextEditingController _groundFloorNoOfBathroomController =
      TextEditingController();
  final TextEditingController _groundFloorUsageRemarksController =
      TextEditingController();

  final TextEditingController _firstFloorOccupancyController =
      TextEditingController();
  final TextEditingController _firstFloorNoOfRoomController =
      TextEditingController();
  final TextEditingController _firstFloorNoOfKitchenController =
      TextEditingController();
  final TextEditingController _firstFloorNoOfBathroomController =
      TextEditingController();
  final TextEditingController _firstFloorUsageRemarksController =
      TextEditingController();

  final TextEditingController _typeOfRoadController = TextEditingController();
  final TextEditingController _widthOfRoadController = TextEditingController();

  // New controller for the "Land locked" field (Item 21)
  final TextEditingController _isLandLockedController = TextEditingController();

  // Controllers for the new Land Valuation Table
  final TextEditingController _landAreaDetailsController =
      TextEditingController();
  final TextEditingController _landAreaGuidelineController =
      TextEditingController();
  final TextEditingController _landAreaPrevailingController =
      TextEditingController();
  final TextEditingController _ratePerSqFtGuidelineController =
      TextEditingController();
  final TextEditingController _ratePerSqFtPrevailingController =
      TextEditingController();
  final TextEditingController _valueInRsGuidelineController =
      TextEditingController();
  final TextEditingController _valueInRsPrevailingController =
      TextEditingController();

  // Controllers for the new Building Valuation Table (Part B)
  final TextEditingController _typeOfBuildingController =
      TextEditingController();
  final TextEditingController _typeOfConstructionController =
      TextEditingController();
  final TextEditingController _ageOfTheBuildingController =
      TextEditingController();
  final TextEditingController _residualAgeOfTheBuildingController =
      TextEditingController();
  final TextEditingController _approvedMapAuthorityController =
      TextEditingController();
  final TextEditingController _genuinenessVerifiedController =
      TextEditingController();
  final TextEditingController _otherCommentsController =
      TextEditingController();

  // Controllers for the new Build up Area table
  final TextEditingController _groundFloorApprovedPlanController =
      TextEditingController();
  final TextEditingController _groundFloorActualController =
      TextEditingController();
  final TextEditingController _groundFloorConsideredValuationController =
      TextEditingController();
  final TextEditingController _groundFloorReplacementCostController =
      TextEditingController();
  final TextEditingController _groundFloorDepreciationController =
      TextEditingController();
  final TextEditingController _groundFloorNetValueController =
      TextEditingController();

  final TextEditingController _firstFloorApprovedPlanController =
      TextEditingController();
  final TextEditingController _firstFloorActualController =
      TextEditingController();
  final TextEditingController _firstFloorConsideredValuationController =
      TextEditingController();
  final TextEditingController _firstFloorReplacementCostController =
      TextEditingController();
  final TextEditingController _firstFloorDepreciationController =
      TextEditingController();
  final TextEditingController _firstFloorNetValueController =
      TextEditingController();

  final TextEditingController _totalApprovedPlanController =
      TextEditingController();
  final TextEditingController _totalActualController = TextEditingController();
  final TextEditingController _totalConsideredValuationController =
      TextEditingController();
  final TextEditingController _totalReplacementCostController =
      TextEditingController();
  final TextEditingController _totalDepreciationController =
      TextEditingController();
  final TextEditingController _totalNetValueController =
      TextEditingController();

  // NEW: Controllers for Part C - Amenities
  final TextEditingController _wardrobesController = TextEditingController();
  final TextEditingController _amenitiesController = TextEditingController();
  final TextEditingController _anyOtherAdditionalController =
      TextEditingController();
  final TextEditingController _amenitiesTotalController =
      TextEditingController();

  // NEW: Controllers for Total abstract of the entire property
  final TextEditingController _totalAbstractLandController =
      TextEditingController();
  final TextEditingController _totalAbstractBuildingController =
      TextEditingController();
  final TextEditingController _totalAbstractExtraItemsController =
      TextEditingController();
  final TextEditingController _totalAbstractAmenitiesController =
      TextEditingController();
  final TextEditingController _totalAbstractMiscController =
      TextEditingController();
  final TextEditingController _totalAbstractServiceController =
      TextEditingController();

  // NEW: Controllers for Consolidated Remarks/ Observations of the property
  final TextEditingController _remark1Controller = TextEditingController();
  final TextEditingController _remark2Controller = TextEditingController();
  final TextEditingController _remark3Controller = TextEditingController();
  final TextEditingController _remark4Controller = TextEditingController();

  // NEW: Controllers for the Final Valuation Table (Page 5)
  final TextEditingController _presentMarketValueController =
      TextEditingController();
  final TextEditingController _realizableValueController =
      TextEditingController();
  final TextEditingController _distressValueController =
      TextEditingController();
  // NEW: Controllers for editable dates in FORMAT E declaration
  final TextEditingController _declarationDateAController =
      TextEditingController();
  final TextEditingController _declarationDateCController =
      TextEditingController();

  // NEW: Controllers for the Valuer Comments table
  final TextEditingController _vcBackgroundInfoController =
      TextEditingController();
  final TextEditingController _vcPurposeOfValuationController =
      TextEditingController();
  final TextEditingController _vcIdentityOfValuerController =
      TextEditingController();
  final TextEditingController _vcDisclosureOfInterestController =
      TextEditingController();
  final TextEditingController _vcDateOfAppointmentController =
      TextEditingController();
  final TextEditingController _vcInspectionsUndertakenController =
      TextEditingController();
  final TextEditingController _vcNatureAndSourcesController =
      TextEditingController();
  final TextEditingController _vcProceduresAdoptedController =
      TextEditingController();
  final TextEditingController _vcRestrictionsOnUseController =
      TextEditingController();
  final TextEditingController _vcMajorFactors1Controller =
      TextEditingController();
  final TextEditingController _vcMajorFactors2Controller =
      TextEditingController();
  final TextEditingController _vcCaveatsLimitationsController =
      TextEditingController();
  final TextEditingController _PlotNo = TextEditingController();
  final TextEditingController _Mandal = TextEditingController();
  final TextEditingController _DoorNo = TextEditingController();
  final TextEditingController _TSNO = TextEditingController();
  final TextEditingController _Ward = TextEditingController();
  final TextEditingController _LandTaxReceipt = TextEditingController();
  final TextEditingController _TitleDeed = TextEditingController();
  final TextEditingController _BuildingCertificate = TextEditingController();
  final TextEditingController _LocationSketch = TextEditingController();
  final TextEditingController _PossessionCertificate = TextEditingController();
  final TextEditingController _BuildingCompletionPlan = TextEditingController();
  final TextEditingController _ThandapperDocument = TextEditingController();
  final TextEditingController _BuildingTaxReceipt = TextEditingController();
  final TextEditingController _place = TextEditingController();

  // new textediting controllers for page - 5(There were no previously initialized controllers present in this page)
  // 1. Foundation
  final TextEditingController _foundationGroundController =
      TextEditingController();
  final TextEditingController _foundationOtherController =
      TextEditingController();

  // 2. Basement
  final TextEditingController _basementGroundController =
      TextEditingController();
  final TextEditingController _basementOtherController =
      TextEditingController();

  // 3. Superstructure
  final TextEditingController _superstructureGroundController =
      TextEditingController();
  final TextEditingController _superstructureOtherController =
      TextEditingController();

  // 4. Joinery / Doors & Windows
  final TextEditingController _joineryGroundController =
      TextEditingController();
  final TextEditingController _joineryOtherController = TextEditingController();

  // 5. RCC works
  final TextEditingController _rccWorksGroundController =
      TextEditingController();
  final TextEditingController _rccWorksOtherController =
      TextEditingController();

// 6. Plastering
  final TextEditingController _plasteringGroundController =
      TextEditingController();
  final TextEditingController _plasteringOtherController =
      TextEditingController();

// 7. Flooring, Skirting, dadoing
  final TextEditingController _flooringGroundController =
      TextEditingController();
  final TextEditingController _flooringOtherController =
      TextEditingController();

// 8. Special finish (marble, granite, wooden paneling, grills, etc)
  final TextEditingController _specialFinishGroundController =
      TextEditingController();
  final TextEditingController _specialFinishOtherController =
      TextEditingController();

// 9. Roofing including weather proof course
  final TextEditingController _roofingGroundController =
      TextEditingController();
  final TextEditingController _roofingOtherController = TextEditingController();

// 10. Drainage
  final TextEditingController _drainageGroundController =
      TextEditingController();
  final TextEditingController _drainageOtherController =
      TextEditingController();

// 11. No of Kitchen
  final TextEditingController _kitchenGroundController =
      TextEditingController();
  final TextEditingController _kitchenOtherController = TextEditingController();

//Page 5 (second table new format)
// --- SECTION 2: COMPOUND WALL ---
  final TextEditingController _compoundWallGroundController =
      TextEditingController();
  final TextEditingController _compoundWallOtherController =
      TextEditingController();
  final TextEditingController _cwHeightGroundController =
      TextEditingController();
  final TextEditingController _cwHeightOtherController =
      TextEditingController();
  final TextEditingController _cwLengthGroundController =
      TextEditingController();
  final TextEditingController _cwLengthOtherController =
      TextEditingController();
  final TextEditingController _cwTypeGroundController = TextEditingController();
  final TextEditingController _cwTypeOtherController = TextEditingController();

// --- SECTION 3: ELECTRICAL INSTALLATION ---
  final TextEditingController _elecWiringGroundController =
      TextEditingController();
  final TextEditingController _elecWiringOtherController =
      TextEditingController();
  final TextEditingController _elecFittingsGroundController =
      TextEditingController();
  final TextEditingController _elecFittingsOtherController =
      TextEditingController();
  final TextEditingController _elecLightPointsGroundController =
      TextEditingController();
  final TextEditingController _elecLightPointsOtherController =
      TextEditingController();
  final TextEditingController _elecFanPointsGroundController =
      TextEditingController();
  final TextEditingController _elecFanPointsOtherController =
      TextEditingController();
  final TextEditingController _elecPlugPointsGroundController =
      TextEditingController();
  final TextEditingController _elecPlugPointsOtherController =
      TextEditingController();
  final TextEditingController _elecOtherGroundController =
      TextEditingController();
  final TextEditingController _elecOtherOtherController =
      TextEditingController();

// --- SECTION 4: PLUMBING INSTALLATION ---
  final TextEditingController _plumClosetsGroundController =
      TextEditingController();
  final TextEditingController _plumClosetsOtherController =
      TextEditingController();
  final TextEditingController _plumBasinsGroundController =
      TextEditingController();
  final TextEditingController _plumBasinsOtherController =
      TextEditingController();
  final TextEditingController _plumUrinalsGroundController =
      TextEditingController();
  final TextEditingController _plumUrinalsOtherController =
      TextEditingController();
  final TextEditingController _plumTubsGroundController =
      TextEditingController();
  final TextEditingController _plumTubsOtherController =
      TextEditingController();
  final TextEditingController _plumMetersGroundController =
      TextEditingController();
  final TextEditingController _plumMetersOtherController =
      TextEditingController();
  final TextEditingController _plumFixturesGroundController =
      TextEditingController();
  final TextEditingController _plumFixturesOtherController =
      TextEditingController();

  final TextEditingController _stageofcontruction = TextEditingController();

  //page - 6 (new format controller)
  // --- DETAILS OF VALUATION ---
// Ground Floor (GF)
  final TextEditingController _valPlinthGFController = TextEditingController();
  final TextEditingController _valRoofHeightGFController =
      TextEditingController();
  final TextEditingController _valAgeGFController = TextEditingController();
  final TextEditingController _valRateGFController = TextEditingController();
  final TextEditingController _valReplaceCostGFController =
      TextEditingController();
  final TextEditingController _valDepreciationGFController =
      TextEditingController();
  final TextEditingController _valNetValueGFController =
      TextEditingController();

// First Floor (FF)
  final TextEditingController _valPlinthFFController = TextEditingController();
  final TextEditingController _valRoofHeightFFController =
      TextEditingController();
  final TextEditingController _valAgeFFController = TextEditingController();
  final TextEditingController _valRateFFController = TextEditingController();
  final TextEditingController _valReplaceCostFFController =
      TextEditingController();
  final TextEditingController _valDepreciationFFController =
      TextEditingController();
  final TextEditingController _valNetValueFFController =
      TextEditingController();

// Totals
  final TextEditingController _valTotalPlinthController =
      TextEditingController();
  final TextEditingController _valTotalReplaceCostController =
      TextEditingController();
  final TextEditingController _valTotalDepreciationController =
      TextEditingController();
  final TextEditingController _valTotalNetValueController =
      TextEditingController();

  // --- PART C: EXTRA ITEMS ---
  final TextEditingController _extraPorticoController = TextEditingController();
  final TextEditingController _extraOrnamentalDoorController =
      TextEditingController();
  final TextEditingController _extraSitoutController = TextEditingController();
  final TextEditingController _extraWaterTankController =
      TextEditingController();
  final TextEditingController _extraSteelGatesController =
      TextEditingController();
  final TextEditingController _extraTotalController = TextEditingController();

// --- PART D: AMENITIES ---
  final TextEditingController _amenWardrobesController =
      TextEditingController();
  final TextEditingController _amenGlazedTilesController =
      TextEditingController();
  final TextEditingController _amenSinksTubsController =
      TextEditingController();
  final TextEditingController _amenFlooringController = TextEditingController();
  final TextEditingController _amenDecorationsController =
      TextEditingController();
  final TextEditingController _amenElevationController =
      TextEditingController();
  final TextEditingController _amenPanellingController =
      TextEditingController();
  final TextEditingController _amenAluminiumWorksController =
      TextEditingController();
  final TextEditingController _amenHandRailsController =
      TextEditingController();
  final TextEditingController _amenFalseCeilingController =
      TextEditingController();
  final TextEditingController _amenTotalController = TextEditingController();

// --- PART E: MISCELLANEOUS ---
  final TextEditingController _miscToiletRoomController =
      TextEditingController();
  final TextEditingController _miscLumberRoomController =
      TextEditingController();
  final TextEditingController _miscSumpController = TextEditingController();
  final TextEditingController _miscGardeningController =
      TextEditingController();
  final TextEditingController _miscTotalController = TextEditingController();

// --- PART F: SERVICES ---
  final TextEditingController _servWaterSupplyController =
      TextEditingController();
  final TextEditingController _servDrainageController = TextEditingController();
  final TextEditingController _servCompoundWallController =
      TextEditingController();
  final TextEditingController _servDepositsController = TextEditingController();
  final TextEditingController _servPavementController = TextEditingController();
  final TextEditingController _servTotalController = TextEditingController();

  Future<pw.MemoryImage> loadLogoImage() async {
    final Uint8List bytes = await rootBundle
        .load('assets/images/logo.png')
        .then((data) => data.buffer.asUint8List());
    return pw.MemoryImage(bytes);
  }

  // Checkbox states for documents (Page 1)
  // final Map<String, bool> _documentChecks = {
  //   'Land Tax Receipt': false,
  //   'Title Deed': false,
  //   'Building Certificate': false,
  //   'Location Sketch': false,
  //   'Possession Certificate': false,
  //   'Building Completion Plan': false,
  //   'Thandapper Document': false,
  //   'Building Tax Receipt': false,
  // };

  // MODIFIED: List to store uploaded images. Now dynamic to handle both File and Uint8List.
  final List<dynamic> _images = [];

  final _formKey = GlobalKey<FormState>(); // Global key for form validation

  Future<void> _saveToNearbyCollection() async {
    try {
      String fullCoordinates = _latitudeLongitudeController.text;
      String latitude = '';
      String longitude = '';

      if (fullCoordinates.isNotEmpty && fullCoordinates.contains(',')) {
        final parts = fullCoordinates.split(',');
        // Ensure the split resulted in exactly two parts
        if (parts.length == 2) {
          latitude =
              parts[0].trim(); // Get the first part and remove whitespace
          longitude =
              parts[1].trim(); // Get the second part and remove whitespace
        }
      }

      if (latitude.isEmpty || longitude.isEmpty) {
        // debugPrint(
        //   'Latitude or Longitude is missing from the controller. Skipping save to nearby collection.',
        // );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Location data is missing, cannot save to nearby properties.',
            ),
          ),
        );
        return; // Exit the function early if coordinates are not valid.
      }

      final ownerName = _ownerNameController.text ?? '[is null]';
      final marketValue = _presentMarketValueController.text ?? '[is null]';

      // debugPrint('------------------------------------------');
      // debugPrint('DEBUGGING SAVE TO NEARBY COLLECTION:');
      // debugPrint('Owner Name from Controller: "$ownerName"');
      // debugPrint('Market Value from Controller: "$marketValue"');
      // debugPrint('------------------------------------------');
      // --- STEP 3: Build the payload with the correct data ---
      final dataToSave = {
        // Use the coordinates from the image we found
        'refNo': _refId.text ?? '',
        'latitude': latitude,
        'longitude': longitude,

        'landValue': marketValue, // Use the variable we just created
        'nameOfOwner': ownerName,
        'bankName': 'State Bank of India (Land & Building)',
      };

      // --- STEP 4: Send the data to your dedicated server endpoint ---
      final response = await http.post(
        Uri.parse(url5), // Use your dedicated URL for saving this data
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(dataToSave),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        //debugPrint('Successfully saved data to nearby collection.');
      } else {
        // debugPrint(
        //   'Failed to save to nearby collection: ${response.statusCode}',
        // );
        //debugPrint('Response body: ${response.body}');
      }
    } catch (e) {
      //debugPrint('Error in _saveToNearbyCollection: $e');
    }
  }

  //SaveData function
  Future<void> _saveData() async {
    try {
      // Validate required fields
      if (_refId.text.isEmpty) {
        //debugPrint("Not all required fields are filled");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill Reference ID')),
        );
        return;
      }
      if (_latitudeLongitudeController.text.isEmpty) {
        //debugPrint("Not all required fields are filled");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill Latitude, Longitude')),
        );
        return;
      }
      if (_images.isEmpty) {
        //debugPrint("Not all required fields are filled");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please add atleast one image')),
        );
        return;
      }

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      var request = http.MultipartRequest('POST', Uri.parse(url1));

      // Add all text fields from controllers
      request.fields.addAll({
        // Document checks
        "landTaxReceipt": _LandTaxReceipt.text,
        "titleDeed": _TitleDeed.text,
        "buildingCertificate": _BuildingCertificate.text,
        "locationSketch": _LocationSketch.text,
        "possessionCertificate": _PossessionCertificate.text,
        "buildingCompletionPlan": _BuildingCompletionPlan.text,
        "thandapperDocument": _ThandapperDocument.text,
        "buildingTaxReceipt": _BuildingTaxReceipt.text,
        "place": _place.text,
        "plotNo": _PlotNo.text,
        "doorNo": _DoorNo.text,
        "TSNO": _TSNO.text,
        "wardNo": _Ward.text,
        "Mandal": _Mandal.text,
        // Page 1 fields
        "refId": _refId.text,
        "purpose": _purposeController.text,
        "dateOfInspection": _dateOfInspectionController.text,
        "dateOfValuation": _dateOfValuationController.text,
        "ownerName": _ownerNameController.text,
        "briefdesc": _BriefDescription.text,
        "locationOfProperty": _LocationOfProperty.text,
        "addressDocument": _addressDocController.text,
        "addressActual": _addressActualController.text,
        "postalAddress": _postalAddress.text,
        "propertyType": _propertyTypeController.text,
        "propertyZone": _propertyZoneController.text,

        "city": _city.text,
        "residential": _residential.text,
        "commercial": _commercial.text,
        "industrial": _industrial.text,

        "rich": _typeOfRichness.text,
        "placetype": _typeOfPlace.text,
        "comingUnderCorporation": _comingUnderCorporationController.text,
        "coveredUnderStateCentralGovt":
            _coveredUnderStateCentralGovtController.text,
        "agriculturalLandConversion":
            _agriculturalLandConversionController.text,

        // Boundaries
        "boundaryNorthTitle": _boundaryNorthTitleController.text,
        "boundarySouthTitle": _boundarySouthTitleController.text,
        "boundaryEastTitle": _boundaryEastTitleController.text,
        "boundaryWestTitle": _boundaryWestTitleController.text,
        "boundaryNorthSketch": _boundaryNorthSketchController.text,
        "boundarySouthSketch": _boundarySouthSketchController.text,
        "boundaryEastSketch": _boundaryEastSketchController.text,
        "boundaryWestSketch": _boundaryWestSketchController.text,
        "boundaryDeviations": _boundaryDeviationsController.text,

        // Dimensions
        "dimNorthActuals": _dimNorthActualsController.text,
        "dimSouthActuals": _dimSouthActualsController.text,
        "dimEastActuals": _dimEastActualsController.text,
        "dimWestActuals": _dimWestActualsController.text,
        "dimNorthDocuments": _dimNorthDocumentsController.text,
        "dimSouthDocuments": _dimSouthDocumentsController.text,
        "dimEastDocuments": _dimEastDocumentsController.text,
        "dimWestDocuments": _dimWestDocumentsController.text,
        "dimNorthAdopted": _dimNorthAdoptedController.text,
        "dimSouthAdopted": _dimSouthAdoptedController.text,
        "dimEastAdopted": _dimEastAdoptedController.text,
        "dimWestAdopted": _dimWestAdoptedController.text,
        "dimDeviations": _dimDeviationsController.text,

        // Occupancy details
        "latitudeLongitude": _latitudeLongitudeController.text,
        "extent": _extent.text,
        "extentConsidered": _extentConsidered.text,
        "occupiedBySelfTenant": _occupiedBySelfTenantController.text,
        "rentReceivedPerMonth": _rentReceivedPerMonthController.text,
        "occupiedByTenantSince": _occupiedByTenantSinceController.text,

        // Floor details - Ground Floor
        "groundFloorOccupancy": _groundFloorOccupancyController.text,
        "groundFloorNoOfRoom": _groundFloorNoOfRoomController.text,
        "groundFloorNoOfKitchen": _groundFloorNoOfKitchenController.text,
        "groundFloorNoOfBathroom": _groundFloorNoOfBathroomController.text,
        "groundFloorUsageRemarks": _groundFloorUsageRemarksController.text,

        // Floor details - First Floor
        "firstFloorOccupancy": _firstFloorOccupancyController.text,
        "firstFloorNoOfRoom": _firstFloorNoOfRoomController.text,
        "firstFloorNoOfKitchen": _firstFloorNoOfKitchenController.text,
        "firstFloorNoOfBathroom": _firstFloorNoOfBathroomController.text,
        "firstFloorUsageRemarks": _firstFloorUsageRemarksController.text,

        // Road details
        "typeOfRoad": _typeOfRoadController.text,
        "widthOfRoad": _widthOfRoadController.text,
        "isLandLocked": _isLandLockedController.text,

        // Land Valuation Table
        "landAreaDetails": _landAreaDetailsController.text,
        "landAreaGuideline": _landAreaGuidelineController.text,
        "landAreaPrevailing": _landAreaPrevailingController.text,
        "ratePerSqFtGuideline": _ratePerSqFtGuidelineController.text,
        "ratePerSqFtPrevailing": _ratePerSqFtPrevailingController.text,
        "valueInRsGuideline": _valueInRsGuidelineController.text,
        "valueInRsPrevailing": _valueInRsPrevailingController.text,

        // Building Valuation Table
        "typeOfBuilding": _typeOfBuildingController.text,
        "typeOfConstruction": _typeOfConstructionController.text,
        "ageOfTheBuilding": _ageOfTheBuildingController.text,
        "residualAgeOfTheBuilding": _residualAgeOfTheBuildingController.text,
        "approvedMapAuthority": _approvedMapAuthorityController.text,
        "genuinenessVerified": _genuinenessVerifiedController.text,
        "otherComments": _otherCommentsController.text,

        // Build up Area - Ground Floor
        "groundFloorApprovedPlan": _groundFloorApprovedPlanController.text,
        "groundFloorActual": _groundFloorActualController.text,
        "groundFloorConsideredValuation":
            _groundFloorConsideredValuationController.text,
        "groundFloorReplacementCost":
            _groundFloorReplacementCostController.text,
        "groundFloorDepreciation": _groundFloorDepreciationController.text,
        "groundFloorNetValue": _groundFloorNetValueController.text,

        // Build up Area - First Floor
        "firstFloorApprovedPlan": _firstFloorApprovedPlanController.text,
        "firstFloorActual": _firstFloorActualController.text,
        "firstFloorConsideredValuation":
            _firstFloorConsideredValuationController.text,
        "firstFloorReplacementCost": _firstFloorReplacementCostController.text,
        "firstFloorDepreciation": _firstFloorDepreciationController.text,
        "firstFloorNetValue": _firstFloorNetValueController.text,

        // Build up Area - Total
        "totalApprovedPlan": _totalApprovedPlanController.text,
        "totalActual": _totalActualController.text,
        "totalConsideredValuation": _totalConsideredValuationController.text,
        "totalReplacementCost": _totalReplacementCostController.text,
        "totalDepreciation": _totalDepreciationController.text,
        "totalNetValue": _totalNetValueController.text,

        // Amenities
        "wardrobes": _wardrobesController.text,
        "amenities": _amenitiesController.text,
        "anyOtherAdditional": _anyOtherAdditionalController.text,
        "amenitiesTotal": _amenitiesTotalController.text,

        // Total abstract
        "totalAbstractLand": _totalAbstractLandController.text,
        "totalAbstractBuilding": _totalAbstractBuildingController.text,
        "totalAbstractExtraItems": _totalAbstractExtraItemsController.text,
        "totalAbstractAmenities": _totalAbstractAmenitiesController.text,
        "totalAbstractMisc": _totalAbstractMiscController.text,
        "totalAbstractService": _totalAbstractServiceController.text,

        // Consolidated Remarks
        "remark1": _remark1Controller.text,
        "remark2": _remark2Controller.text,
        "remark3": _remark3Controller.text,
        "remark4": _remark4Controller.text,

        // Final Valuation
        "presentMarketValue": _presentMarketValueController.text,
        "realizableValue": _realizableValueController.text,
        "distressValue": _distressValueController.text,

        // Declaration dates
        "declarationDateA": _declarationDateAController.text,
        "declarationDateC": _declarationDateCController.text,

        // Valuer Comments
        "vcBackgroundInfo": _vcBackgroundInfoController.text,
        "vcPurposeOfValuation": _vcPurposeOfValuationController.text,
        "vcIdentityOfValuer": _vcIdentityOfValuerController.text,
        "vcDisclosureOfInterest": _vcDisclosureOfInterestController.text,
        "vcDateOfAppointment": _vcDateOfAppointmentController.text,
        "vcInspectionsUndertaken": _vcInspectionsUndertakenController.text,
        "vcNatureAndSources": _vcNatureAndSourcesController.text,
        "vcProceduresAdopted": _vcProceduresAdoptedController.text,
        "vcRestrictionsOnUse": _vcRestrictionsOnUseController.text,
        "vcMajorFactors1": _vcMajorFactors1Controller.text,
        "vcMajorFactors2": _vcMajorFactors2Controller.text,
        "vcCaveatsLimitations": _vcCaveatsLimitationsController.text,

        //New controllers for page - 5
        "foundationGround": _foundationGroundController.text,
        "foundationOther": _foundationOtherController.text,
        "basementGround": _basementGroundController.text,
        "basementOther": _basementOtherController.text,
        "superstructureGround": _superstructureGroundController.text,
        "superstructureOther": _superstructureOtherController.text,
        "joineryGround": _joineryGroundController.text,
        "joineryOther": _joineryOtherController.text,
        "rccWorksGround": _rccWorksGroundController.text,
        "rccWorksOther": _rccWorksOtherController.text,
        "plasteringGround": _plasteringGroundController.text,
        "plasteringOther": _plasteringOtherController.text,
        "flooringGround": _flooringGroundController.text,
        "flooringOther": _flooringOtherController.text,
        "specialFinishGround": _specialFinishGroundController.text,
        "specialFinishOther": _specialFinishOtherController.text,
        "roofingGround": _roofingGroundController.text,
        "roofingOther": _roofingOtherController.text,
        "drainageGround": _drainageGroundController.text,
        "drainageOther": _drainageOtherController.text,
        "kitchenGround": _kitchenGroundController.text,
        "kitchenOther": _kitchenOtherController.text,

        //page 5 (new format second table)
        // --- Section 2: Compound Wall ---
        "compoundWallGround": _compoundWallGroundController.text,
        "compoundWallOther": _compoundWallOtherController.text,
        "cwHeightGround": _cwHeightGroundController.text,
        "cwHeightOther": _cwHeightOtherController.text,
        "cwLengthGround": _cwLengthGroundController.text,
        "cwLengthOther": _cwLengthOtherController.text,
        "cwTypeGround": _cwTypeGroundController.text,
        "cwTypeOther": _cwTypeOtherController.text,

// --- Section 3: Electrical Installation ---
        "elecWiringGround": _elecWiringGroundController.text,
        "elecWiringOther": _elecWiringOtherController.text,
        "elecFittingsGround": _elecFittingsGroundController.text,
        "elecFittingsOther": _elecFittingsOtherController.text,
        "elecLightPointsGround": _elecLightPointsGroundController.text,
        "elecLightPointsOther": _elecLightPointsOtherController.text,
        "elecFanPointsGround": _elecFanPointsGroundController.text,
        "elecFanPointsOther": _elecFanPointsOtherController.text,
        "elecPlugPointsGround": _elecPlugPointsGroundController.text,
        "elecPlugPointsOther": _elecPlugPointsOtherController.text,
        "elecOtherItemGround": _elecOtherGroundController.text,
        "elecOtherItemOther": _elecOtherOtherController.text,

// --- Section 4: Plumbing Installation ---
        "plumClosetsGround": _plumClosetsGroundController.text,
        "plumClosetsOther": _plumClosetsOtherController.text,
        "plumBasinsGround": _plumBasinsGroundController.text,
        "plumBasinsOther": _plumBasinsOtherController.text,
        "plumUrinalsGround": _plumUrinalsGroundController.text,
        "plumUrinalsOther": _plumUrinalsOtherController.text,
        "plumTubsGround": _plumTubsGroundController.text,
        "plumTubsOther": _plumTubsOtherController.text,
        "plumWaterMeterGround": _plumMetersGroundController.text,
        "plumWaterMeterOther": _plumMetersOtherController.text,
        "plumFixturesGround": _plumFixturesGroundController.text,
        "plumFixturesOther": _plumFixturesOtherController.text,

        "stageofcontruction": _stageofcontruction.text,

        //page - 6 (new format)
        "valPlinthGF": _valPlinthGFController.text,
        "valRoofHeightGF": _valRoofHeightGFController.text,
        "valAgeGF": _valAgeGFController.text,
        "valRateGF": _valRateGFController.text,
        "valReplaceCostGF": _valReplaceCostGFController.text,
        "valDepreciationGF": _valDepreciationGFController.text,
        "valNetValueGF": _valNetValueGFController.text,
        "valPlinthFF": _valPlinthFFController.text,
        "valRoofHeightFF": _valRoofHeightFFController.text,
        "valAgeFF": _valAgeFFController.text,
        "valRateFF": _valRateFFController.text,
        "valReplaceCostFF": _valReplaceCostFFController.text,
        "valDepreciationFF": _valDepreciationFFController.text,
        "valNetValueFF": _valNetValueFFController.text,
        "valTotalPlinth": _valTotalPlinthController.text,
        "valTotalReplaceCost": _valTotalReplaceCostController.text,
        "valTotalDepreciation": _valTotalDepreciationController.text,
        "valTotalNetValue": _valTotalNetValueController.text,

        // Part C
        "extraPortico": _extraPorticoController.text,
        "extraOrnamentalDoor": _extraOrnamentalDoorController.text,
        "extraSitout": _extraSitoutController.text,
        "extraWaterTank": _extraWaterTankController.text,
        "extraSteelGates": _extraSteelGatesController.text,
        "extraTotal": _extraTotalController.text,

// Part D
        "amenWardrobes": _amenWardrobesController.text,
        "amenGlazedTiles": _amenGlazedTilesController.text,
        "amenSinksTubs": _amenSinksTubsController.text,
        "amenFlooring": _amenFlooringController.text,
        "amenDecorations": _amenDecorationsController.text,
        "amenElevation": _amenElevationController.text,
        "amenPanelling": _amenPanellingController.text,
        "amenAluminiumWorks": _amenAluminiumWorksController.text,
        "amenHandRails": _amenHandRailsController.text,
        "amenFalseCeiling": _amenFalseCeilingController.text,
        "amenTotal": _amenTotalController.text,

// Part E
        "miscToiletRoom": _miscToiletRoomController.text,
        "miscLumberRoom": _miscLumberRoomController.text,
        "miscSump": _miscSumpController.text,
        "miscGardening": _miscGardeningController.text,
        "miscTotal": _miscTotalController.text,

// Part F
        "servWaterSupply": _servWaterSupplyController.text,
        "servDrainage": _servDrainageController.text,
        "servCompoundWall": _servCompoundWallController.text,
        "servDeposits": _servDepositsController.text,
        "servPavement": _servPavementController.text,
        "servTotal": _servTotalController.text,
      });

      // Add images if available
      /*   for (int i = 0; i < _images.length; i++) {
          final image = _images[i];
          final imageBytes = await image.readAsBytes();

          request.files.add(http.MultipartFile.fromBytes(
            'images',
            imageBytes,
            filename: 'property_${_refId.text}_$i.jpg',
          ));
        } */

      for (int i = 0; i < _images.length; i++) {
        final imageBytes;
        if (_images[i] is File) {
          // Convert File → Uint8List
          imageBytes = await (_images[i] as File).readAsBytes();
        } else if (_images[i] is Uint8List) {
          // Already Uint8List
          imageBytes = _images[i] as Uint8List;
        } else {
          throw Exception("Unsupported image type: ${_images[i].runtimeType}");
        }
        request.files.add(
          http.MultipartFile.fromBytes(
            'images',
            imageBytes,
            filename: 'property_${_refId.text}_$i.jpg',
          ),
        );
      }

      final response = await request.send();
      //debugPrint("Request sent to backend");

      if (context.mounted) Navigator.of(context).pop();

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Data saved successfully!')),
          );
        }
        await _saveToNearbyCollection();
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Upload failed: ${response.reasonPhrase}')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    }
  }

  // Future<String> _getAccessToken() async {
  //   final response = await http.post(
  //     Uri.parse('https://oauth2.googleapis.com/token'),
  //     headers: {'Content-Type': 'application/x-www-form-urlencoded'},
  //     body: {
  //       'client_id': clientId,
  //       'client_secret': clientSecret,
  //       'refresh_token': refreshToken,
  //       'grant_type': 'refresh_token',
  //     },
  //   );

  //   if (response.statusCode == 200) {
  //     return jsonDecode(response.body)['access_token'] as String;
  //   } else {
  //     throw Exception('Failed to refresh access token');
  //   }
  // }

  // String _getMimeTypeFromExtension(String extension) {
  //   switch (extension) {
  //     case '.jpg':
  //     case '.jpeg':
  //       return 'image/jpeg';
  //     case '.png':
  //       return 'image/png';
  //     case '.gif':
  //       return 'image/gif';
  //     case '.webp':
  //       return 'image/webp';
  //     default:
  //       return 'application/octet-stream';
  //   }
  // }

  // Future<Uint8List> fetchImageFromDrive(String fileId) async {
  //   try {
  //     // Get access token using refresh token
  //     final accessToken = await _getAccessToken();

  //     final response = await http.get(
  //       Uri.parse(
  //         'https://www.googleapis.com/drive/v3/files/$fileId?alt=media',
  //       ),
  //       headers: {'Authorization': 'Bearer $accessToken'},
  //     );

  //     if (response.statusCode == 200) {
  //       return response.bodyBytes;
  //     } else {
  //       throw Exception('Failed to load image: ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     throw Exception('Error fetching image from Drive: $e');
  //   }
  // }

  Future<String> fetchSignedUrl(String imagePublicId) async {
    // --- YOU MUST CUSTOMIZE THESE VALUES ---
    const String apiKey =
        "db74f0da81338f1ad24d0be8298f90f4e6be5f0df5b53aca2f95ead470665641";
    const String apiBaseUrl = 'http://localhost:3000'; // For Android emulator
    // -----------------------------------------

    final url = Uri.parse('$apiBaseUrl/api/images/secure-url/$imagePublicId');

    final response = await http.get(
      url,
      headers: {'x-api-key': apiKey},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['signedUrl'];
    } else {
      throw Exception(
          'Failed to load signed URL. Status code: ${response.statusCode}');
    }
  }

  Future<Uint8List> fetchImageBytes(String url) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return response.bodyBytes; // this is Uint8List
    } else {
      throw Exception('Failed to load image');
    }
  }

  void _initializeFormWithPropertyData() async {
    if (widget.propertyData != null) {
      final data = widget.propertyData!;

      // Set coordinates and refId
      _refId.text = data['refId']?.toString() ?? '';

      // Set document checks
      _LandTaxReceipt.text = data['landTaxReceipt'];
      _TitleDeed.text = data['titleDeed'];
      _BuildingCertificate.text = data['buildingCertificate'];
      _LocationSketch.text = data['locationSketch'];
      _PossessionCertificate.text = data['possessionCertificate'];
      _BuildingCompletionPlan.text = data['buildingCompletionPlan'];
      _ThandapperDocument.text = data['thandapperDocument'];
      _BuildingTaxReceipt.text = data['buildingTaxReceipt'];
      _place.text = data['place'];
      // Page 1 fields
      _purposeController.text = data['purpose']?.toString() ?? '';
      _dateOfInspectionController.text =
          data['dateOfInspection']?.toString() ?? '';
      _dateOfValuationController.text =
          data['dateOfValuation']?.toString() ?? '';
      _ownerNameController.text = data['ownerName']?.toString() ?? '';
      _BriefDescription.text = data['briefdesc']?.toString() ?? '';
      _PlotNo.text = data['plotNo']?.toString() ?? '';
      _DoorNo.text = data['doorNo']?.toString() ?? '';
      _TSNO.text = data['TSNO']?.toString() ?? '';
      _Ward.text = data['wardNo']?.toString() ?? '';
      _Mandal.text = data['Mandal']?.toString() ?? '';
      _LocationOfProperty.text = data['locationOfProperty']?.toString() ?? '';
      _addressDocController.text = data['addressDocument']?.toString() ?? '';
      _addressActualController.text = data['addressActual']?.toString() ?? '';
      _postalAddress.text = data['postalAddress']?.toString() ?? '';
      _propertyTypeController.text = data['propertyType']?.toString() ?? '';
      _propertyZoneController.text = data['propertyZone']?.toString() ?? '';

      _city.text = data['city']?.toString() ?? '';
      _residential.text = data['residential']?.toString() ?? '';
      _commercial.text = data['commercial']?.toString() ?? '';
      _industrial.text = data['industrial']?.toString() ?? '';
      _typeOfRichness.text = data['rich']?.toString() ?? '';
      _typeOfPlace.text = data['placetype']?.toString() ?? '';

      _comingUnderCorporationController.text =
          data['comingUnderCorporation']?.toString() ?? '';
      _coveredUnderStateCentralGovtController.text =
          data['coveredUnderStateCentralGovt']?.toString() ?? '';
      _agriculturalLandConversionController.text =
          data['agriculturalLandConversion']?.toString() ?? '';

      // Boundaries
      _boundaryNorthTitleController.text =
          data['boundaryNorthTitle']?.toString() ?? '';
      _boundarySouthTitleController.text =
          data['boundarySouthTitle']?.toString() ?? '';
      _boundaryEastTitleController.text =
          data['boundaryEastTitle']?.toString() ?? '';
      _boundaryWestTitleController.text =
          data['boundaryWestTitle']?.toString() ?? '';
      _boundaryNorthSketchController.text =
          data['boundaryNorthSketch']?.toString() ?? '';
      _boundarySouthSketchController.text =
          data['boundarySouthSketch']?.toString() ?? '';
      _boundaryEastSketchController.text =
          data['boundaryEastSketch']?.toString() ?? '';
      _boundaryWestSketchController.text =
          data['boundaryWestSketch']?.toString() ?? '';
      _boundaryDeviationsController.text =
          data['boundaryDeviations']?.toString() ?? '';

      // Dimensions
      _dimNorthActualsController.text =
          data['dimNorthActuals']?.toString() ?? '';
      _dimSouthActualsController.text =
          data['dimSouthActuals']?.toString() ?? '';
      _dimEastActualsController.text = data['dimEastActuals']?.toString() ?? '';
      _dimWestActualsController.text = data['dimWestActuals']?.toString() ?? '';
      _dimNorthDocumentsController.text =
          data['dimNorthDocuments']?.toString() ?? '';
      _dimSouthDocumentsController.text =
          data['dimSouthDocuments']?.toString() ?? '';
      _dimEastDocumentsController.text =
          data['dimEastDocuments']?.toString() ?? '';
      _dimWestDocumentsController.text =
          data['dimWestDocuments']?.toString() ?? '';
      _dimNorthAdoptedController.text =
          data['dimNorthAdopted']?.toString() ?? '';
      _dimSouthAdoptedController.text =
          data['dimSouthAdopted']?.toString() ?? '';
      _dimEastAdoptedController.text = data['dimEastAdopted']?.toString() ?? '';
      _dimWestAdoptedController.text = data['dimWestAdopted']?.toString() ?? '';
      _dimDeviationsController.text = data['dimDeviations']?.toString() ?? '';

      // Occupancy details
      _latitudeLongitudeController.text =
          data['latitudeLongitude']?.toString() ?? '';
      _extent.text = data['extent']?.toString() ?? '';
      _extentConsidered.text = data['extentConsidered']?.toString() ?? '';
      _occupiedBySelfTenantController.text =
          data['occupiedBySelfTenant']?.toString() ?? '';
      _rentReceivedPerMonthController.text =
          data['rentReceivedPerMonth']?.toString() ?? '';
      _occupiedByTenantSinceController.text =
          data['occupiedByTenantSince']?.toString() ?? '';

      // Floor details - Ground Floor
      _groundFloorOccupancyController.text =
          data['groundFloorOccupancy']?.toString() ?? '';
      _groundFloorNoOfRoomController.text =
          data['groundFloorNoOfRoom']?.toString() ?? '';
      _groundFloorNoOfKitchenController.text =
          data['groundFloorNoOfKitchen']?.toString() ?? '';
      _groundFloorNoOfBathroomController.text =
          data['groundFloorNoOfBathroom']?.toString() ?? '';
      _groundFloorUsageRemarksController.text =
          data['groundFloorUsageRemarks']?.toString() ?? '';

      // Floor details - First Floor
      _firstFloorOccupancyController.text =
          data['firstFloorOccupancy']?.toString() ?? '';
      _firstFloorNoOfRoomController.text =
          data['firstFloorNoOfRoom']?.toString() ?? '';
      _firstFloorNoOfKitchenController.text =
          data['firstFloorNoOfKitchen']?.toString() ?? '';
      _firstFloorNoOfBathroomController.text =
          data['firstFloorNoOfBathroom']?.toString() ?? '';
      _firstFloorUsageRemarksController.text =
          data['firstFloorUsageRemarks']?.toString() ?? '';

      // Road details
      _typeOfRoadController.text = data['typeOfRoad']?.toString() ?? '';
      _widthOfRoadController.text = data['widthOfRoad']?.toString() ?? '';
      _isLandLockedController.text = data['isLandLocked']?.toString() ?? '';

      // Land Valuation Table
      _landAreaDetailsController.text =
          data['landAreaDetails']?.toString() ?? '';
      _landAreaGuidelineController.text =
          data['landAreaGuideline']?.toString() ?? '';
      _landAreaPrevailingController.text =
          data['landAreaPrevailing']?.toString() ?? '';
      _ratePerSqFtGuidelineController.text =
          data['ratePerSqFtGuideline']?.toString() ?? '';
      _ratePerSqFtPrevailingController.text =
          data['ratePerSqFtPrevailing']?.toString() ?? '';
      _valueInRsGuidelineController.text =
          data['valueInRsGuideline']?.toString() ?? '';
      _valueInRsPrevailingController.text =
          data['valueInRsPrevailing']?.toString() ?? '';

      // Building Valuation Table
      _typeOfBuildingController.text = data['typeOfBuilding']?.toString() ?? '';
      _typeOfConstructionController.text =
          data['typeOfConstruction']?.toString() ?? '';
      _ageOfTheBuildingController.text =
          data['ageOfTheBuilding']?.toString() ?? '';
      _residualAgeOfTheBuildingController.text =
          data['residualAgeOfTheBuilding']?.toString() ?? '';
      _approvedMapAuthorityController.text =
          data['approvedMapAuthority']?.toString() ?? '';
      _genuinenessVerifiedController.text =
          data['genuinenessVerified']?.toString() ?? '';
      _otherCommentsController.text = data['otherComments']?.toString() ?? '';

      // Build up Area - Ground Floor
      _groundFloorApprovedPlanController.text =
          data['groundFloorApprovedPlan']?.toString() ?? '';
      _groundFloorActualController.text =
          data['groundFloorActual']?.toString() ?? '';
      _groundFloorConsideredValuationController.text =
          data['groundFloorConsideredValuation']?.toString() ?? '';
      _groundFloorReplacementCostController.text =
          data['groundFloorReplacementCost']?.toString() ?? '';
      _groundFloorDepreciationController.text =
          data['groundFloorDepreciation']?.toString() ?? '';
      _groundFloorNetValueController.text =
          data['groundFloorNetValue']?.toString() ?? '';

      // Build up Area - First Floor
      _firstFloorApprovedPlanController.text =
          data['firstFloorApprovedPlan']?.toString() ?? '';
      _firstFloorActualController.text =
          data['firstFloorActual']?.toString() ?? '';
      _firstFloorConsideredValuationController.text =
          data['firstFloorConsideredValuation']?.toString() ?? '';
      _firstFloorReplacementCostController.text =
          data['firstFloorReplacementCost']?.toString() ?? '';
      _firstFloorDepreciationController.text =
          data['firstFloorDepreciation']?.toString() ?? '';
      _firstFloorNetValueController.text =
          data['firstFloorNetValue']?.toString() ?? '';

      // Build up Area - Total
      _totalApprovedPlanController.text =
          data['totalApprovedPlan']?.toString() ?? '';
      _totalActualController.text = data['totalActual']?.toString() ?? '';
      _totalConsideredValuationController.text =
          data['totalConsideredValuation']?.toString() ?? '';
      _totalReplacementCostController.text =
          data['totalReplacementCost']?.toString() ?? '';
      _totalDepreciationController.text =
          data['totalDepreciation']?.toString() ?? '';
      _totalNetValueController.text = data['totalNetValue']?.toString() ?? '';

      // Amenities
      _wardrobesController.text = data['wardrobes']?.toString() ?? '';
      _amenitiesController.text = data['amenities']?.toString() ?? '';
      _anyOtherAdditionalController.text =
          data['anyOtherAdditional']?.toString() ?? '';
      _amenitiesTotalController.text = data['amenitiesTotal']?.toString() ?? '';

      // Total abstract
      _totalAbstractLandController.text =
          data['totalAbstractLand']?.toString() ?? '';
      _totalAbstractBuildingController.text =
          data['totalAbstractBuilding']?.toString() ?? '';
      _totalAbstractAmenitiesController.text =
          data['totalAbstractExtraItems']?.toString() ?? '';
      _totalAbstractAmenitiesController.text =
          data['totalAbstractAmenities']?.toString() ?? '';
      _totalAbstractMiscController.text =
          data['totalAbstractMisc']?.toString() ?? '';
      _totalAbstractServiceController.text =
          data['totalAbstractService']?.toString() ?? '';

      // Consolidated Remarks
      _remark1Controller.text = data['remark1']?.toString() ?? '';
      _remark2Controller.text = data['remark2']?.toString() ?? '';
      _remark3Controller.text = data['remark3']?.toString() ?? '';
      _remark4Controller.text = data['remark4']?.toString() ?? '';

      // Final Valuation
      _presentMarketValueController.text =
          data['presentMarketValue']?.toString() ?? '';
      _realizableValueController.text =
          data['realizableValue']?.toString() ?? '';
      _distressValueController.text = data['distressValue']?.toString() ?? '';

      // Declaration dates
      _declarationDateAController.text =
          data['declarationDateA']?.toString() ?? '';
      _declarationDateCController.text =
          data['declarationDateC']?.toString() ?? '';

      // Valuer Comments
      _vcBackgroundInfoController.text =
          data['vcBackgroundInfo']?.toString() ?? '';
      _vcPurposeOfValuationController.text =
          data['vcPurposeOfValuation']?.toString() ?? '';
      _vcIdentityOfValuerController.text =
          data['vcIdentityOfValuer']?.toString() ?? '';
      _vcDisclosureOfInterestController.text =
          data['vcDisclosureOfInterest']?.toString() ?? '';
      _vcDateOfAppointmentController.text =
          data['vcDateOfAppointment']?.toString() ?? '';
      _vcInspectionsUndertakenController.text =
          data['vcInspectionsUndertaken']?.toString() ?? '';
      _vcNatureAndSourcesController.text =
          data['vcNatureAndSources']?.toString() ?? '';
      _vcProceduresAdoptedController.text =
          data['vcProceduresAdopted']?.toString() ?? '';
      _vcRestrictionsOnUseController.text =
          data['vcRestrictionsOnUse']?.toString() ?? '';
      _vcMajorFactors1Controller.text =
          data['vcMajorFactors1']?.toString() ?? '';
      _vcMajorFactors2Controller.text =
          data['vcMajorFactors2']?.toString() ?? '';
      _vcCaveatsLimitationsController.text =
          data['vcCaveatsLimitations']?.toString() ?? '';

      //page - 5 controllers
      _foundationGroundController.text =
          data['foundationGround']?.toString() ?? '';
      _foundationOtherController.text =
          data['foundationOther']?.toString() ?? '';
      _basementGroundController.text = data['basementGround']?.toString() ?? '';
      _basementOtherController.text = data['basementOther']?.toString() ?? '';
      _superstructureGroundController.text =
          data['superstructureGround']?.toString() ?? '';
      _superstructureOtherController.text =
          data['superstructureOther']?.toString() ?? '';
      _joineryGroundController.text = data['joineryGround']?.toString() ?? '';
      _joineryOtherController.text = data['joineryOther']?.toString() ?? '';
      _rccWorksGroundController.text = data['rccWorksGround']?.toString() ?? '';
      _rccWorksOtherController.text = data['rccWorksOther']?.toString() ?? '';
      _plasteringGroundController.text =
          data['plasteringGround']?.toString() ?? '';
      _plasteringOtherController.text =
          data['plasteringOther']?.toString() ?? '';
      _flooringGroundController.text = data['flooringGround']?.toString() ?? '';
      _flooringOtherController.text = data['flooringOther']?.toString() ?? '';
      _specialFinishGroundController.text =
          data['specialFinishGround']?.toString() ?? '';
      _specialFinishOtherController.text =
          data['specialFinishOther']?.toString() ?? '';
      _roofingGroundController.text = data['roofingGround']?.toString() ?? '';
      _roofingOtherController.text = data['roofingOther']?.toString() ?? '';
      _drainageGroundController.text = data['drainageGround']?.toString() ?? '';
      _drainageOtherController.text = data['drainageOther']?.toString() ?? '';
      _kitchenGroundController.text = data['kitchenGround']?.toString() ?? '';
      _kitchenOtherController.text = data['kitchenOther']?.toString() ?? '';

      //page 5 (second table)
      // --- SECTION 2: COMPOUND WALL ---
      _compoundWallGroundController.text =
          data['compoundWallGround']?.toString() ?? '';
      _compoundWallOtherController.text =
          data['compoundWallOther']?.toString() ?? '';
      _cwHeightGroundController.text = data['cwHeightGround']?.toString() ?? '';
      _cwHeightOtherController.text = data['cwHeightOther']?.toString() ?? '';
      _cwLengthGroundController.text = data['cwLengthGround']?.toString() ?? '';
      _cwLengthOtherController.text = data['cwLengthOther']?.toString() ?? '';
      _cwTypeGroundController.text = data['cwTypeGround']?.toString() ?? '';
      _cwTypeOtherController.text = data['cwTypeOther']?.toString() ?? '';

// --- SECTION 3: ELECTRICAL INSTALLATION ---
      _elecWiringGroundController.text =
          data['elecWiringGround']?.toString() ?? '';
      _elecWiringOtherController.text =
          data['elecWiringOther']?.toString() ?? '';
      _elecFittingsGroundController.text =
          data['elecFittingsGround']?.toString() ?? '';
      _elecFittingsOtherController.text =
          data['elecFittingsOther']?.toString() ?? '';
      _elecLightPointsGroundController.text =
          data['elecLightPointsGround']?.toString() ?? '';
      _elecLightPointsOtherController.text =
          data['elecLightPointsOther']?.toString() ?? '';
      _elecFanPointsGroundController.text =
          data['elecFanPointsGround']?.toString() ?? '';
      _elecFanPointsOtherController.text =
          data['elecFanPointsOther']?.toString() ?? '';
      _elecPlugPointsGroundController.text =
          data['elecPlugPointsGround']?.toString() ?? '';
      _elecPlugPointsOtherController.text =
          data['elecPlugPointsOther']?.toString() ?? '';
      _elecOtherGroundController.text =
          data['elecOtherItemGround']?.toString() ?? '';
      _elecOtherOtherController.text =
          data['elecOtherItemOther']?.toString() ?? '';

// --- SECTION 4: PLUMBING INSTALLATION ---
      _plumClosetsGroundController.text =
          data['plumClosetsGround']?.toString() ?? '';
      _plumClosetsOtherController.text =
          data['plumClosetsOther']?.toString() ?? '';
      _plumBasinsGroundController.text =
          data['plumBasinsGround']?.toString() ?? '';
      _plumBasinsOtherController.text =
          data['plumBasinsOther']?.toString() ?? '';
      _plumUrinalsGroundController.text =
          data['plumUrinalsGround']?.toString() ?? '';
      _plumUrinalsOtherController.text =
          data['plumUrinalsOther']?.toString() ?? '';
      _plumTubsGroundController.text = data['plumTubsGround']?.toString() ?? '';
      _plumTubsOtherController.text = data['plumTubsOther']?.toString() ?? '';
      _plumMetersGroundController.text =
          data['plumWaterMeterGround']?.toString() ?? '';
      _plumMetersOtherController.text =
          data['plumWaterMeterOther']?.toString() ?? '';
      _plumFixturesGroundController.text =
          data['plumFixturesGround']?.toString() ?? '';
      _plumFixturesOtherController.text =
          data['plumFixturesOther']?.toString() ?? '';

      _stageofcontruction.text = data['stageofcontruction']?.toString() ?? '';

      //page - 6(new format)
      // Ground Floor
      _valPlinthGFController.text = data['valPlinthGF']?.toString() ?? '';
      _valRoofHeightGFController.text =
          data['valRoofHeightGF']?.toString() ?? '';
      _valAgeGFController.text = data['valAgeGF']?.toString() ?? '';
      _valRateGFController.text = data['valRateGF']?.toString() ?? '';
      _valReplaceCostGFController.text =
          data['valReplaceCostGF']?.toString() ?? '';
      _valDepreciationGFController.text =
          data['valDepreciationGF']?.toString() ?? '';
      _valNetValueGFController.text = data['valNetValueGF']?.toString() ?? '';

// First Floor
      _valPlinthFFController.text = data['valPlinthFF']?.toString() ?? '';
      _valRoofHeightFFController.text =
          data['valRoofHeightFF']?.toString() ?? '';
      _valAgeFFController.text = data['valAgeFF']?.toString() ?? '';
      _valRateFFController.text = data['valRateFF']?.toString() ?? '';
      _valReplaceCostFFController.text =
          data['valReplaceCostFF']?.toString() ?? '';
      _valDepreciationFFController.text =
          data['valDepreciationFF']?.toString() ?? '';
      _valNetValueFFController.text = data['valNetValueFF']?.toString() ?? '';

// Totals
      _valTotalPlinthController.text = data['valTotalPlinth']?.toString() ?? '';
      _valTotalReplaceCostController.text =
          data['valTotalReplaceCost']?.toString() ?? '';
      _valTotalDepreciationController.text =
          data['valTotalDepreciation']?.toString() ?? '';
      _valTotalNetValueController.text =
          data['valTotalNetValue']?.toString() ?? '';

      // --- PART C: EXTRA ITEMS ---
      _extraPorticoController.text = data['extraPortico']?.toString() ?? '';
      _extraOrnamentalDoorController.text =
          data['extraOrnamentalDoor']?.toString() ?? '';
      _extraSitoutController.text = data['extraSitout']?.toString() ?? '';
      _extraWaterTankController.text = data['extraWaterTank']?.toString() ?? '';
      _extraSteelGatesController.text =
          data['extraSteelGates']?.toString() ?? '';
      _extraTotalController.text = data['extraTotal']?.toString() ?? '';

// --- PART D: AMENITIES ---
      _amenWardrobesController.text = data['amenWardrobes']?.toString() ?? '';
      _amenGlazedTilesController.text =
          data['amenGlazedTiles']?.toString() ?? '';
      _amenSinksTubsController.text = data['amenSinksTubs']?.toString() ?? '';
      _amenFlooringController.text = data['amenFlooring']?.toString() ?? '';
      _amenDecorationsController.text =
          data['amenDecorations']?.toString() ?? '';
      _amenElevationController.text = data['amenElevation']?.toString() ?? '';
      _amenPanellingController.text = data['amenPanelling']?.toString() ?? '';
      _amenAluminiumWorksController.text =
          data['amenAluminiumWorks']?.toString() ?? '';
      _amenHandRailsController.text = data['amenHandRails']?.toString() ?? '';
      _amenFalseCeilingController.text =
          data['amenFalseCeiling']?.toString() ?? '';
      _amenTotalController.text = data['amenTotal']?.toString() ?? '';

// --- PART E: MISCELLANEOUS ---
      _miscToiletRoomController.text = data['miscToiletRoom']?.toString() ?? '';
      _miscLumberRoomController.text = data['miscLumberRoom']?.toString() ?? '';
      _miscSumpController.text = data['miscSump']?.toString() ?? '';
      _miscGardeningController.text = data['miscGardening']?.toString() ?? '';
      _miscTotalController.text = data['miscTotal']?.toString() ?? '';

// --- PART F: SERVICES ---
      _servWaterSupplyController.text =
          data['servWaterSupply']?.toString() ?? '';
      _servDrainageController.text = data['servDrainage']?.toString() ?? '';
      _servCompoundWallController.text =
          data['servCompoundWall']?.toString() ?? '';
      _servDepositsController.text = data['servDeposits']?.toString() ?? '';
      _servPavementController.text = data['servPavement']?.toString() ?? '';
      _servTotalController.text = data['servTotal']?.toString() ?? '';

      // Load images if available
      try {
        if (data['images'] != null && data['images'] is List) {
          final List<dynamic> imagesData = data['images'];

          for (var imgData in imagesData) {
            try {
              // The backend returned something like "uploads/abc123.png"
              final String filePath = imgData['filePath'];

              // Build the full URL (e.g., http://your-server.com/uploads/abc123.png)
              final String imageUrl = '$baseUrl/$filePath';

              // Fetch image bytes
              final response = await http.get(Uri.parse(imageUrl));

              if (response.statusCode == 200) {
                Uint8List imageBytes = response.bodyBytes;

                _images.add(imageBytes);
              } else {
                debugPrint('Failed to load image: ${response.statusCode}');
              }
            } catch (e) {
              debugPrint('Error loading image from uploads: $e');
            }
          }
        }
      } catch (e) {
        debugPrint('Error in fetchImagesFromUploads: $e');
      }

      if (mounted) setState(() {});

      //debugPrint('SBI Land form initialized with property data');
    } else {
      //debugPrint('No property data - SBI Land form will use default values');
    }
  }

  Future<void> _getNearbyProperty() async {
    final latitude = _latitude.text.trim();
    final longitude = _longitude.text.trim();

    //debugPrint(latitude);

    if (latitude.isEmpty || longitude.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter both latitude and longitude'),
        ),
      );
      return;
    }

    try {
      final url = Uri.parse(url2);
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'latitude': latitude, 'longitude': longitude}),
      );

      if (response.statusCode == 200) {
        // Decode the JSON response (assuming it's an array)
        final List<dynamic> responseData = jsonDecode(response.body);

        // Debug print the array
        //debugPrint('Response Data (Array):');
        for (var item in responseData) {
          //debugPrint(item.toString()); // Print each item in the array
        }

        if (context.mounted) {
          // Navigator.of(context).push(
          //   MaterialPageRoute(
          //     builder: (ctx) => Nearbydetails(responseData: responseData),
          //   ),
          // );
          showModalBottomSheet(
            context: context,
            builder: (ctx) {
              return Nearbydetails(responseData: responseData);
            },
          );
        }
      }

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Nearby properties fetched successfully'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  // Function to build a text input field
  Widget _buildTextField({
    required TextEditingController controller,
    String? labelText, // Made nullable
    String? hintText,
    bool isDate = false,
    int? maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        // Changed from TextFormField to TextField
        controller: controller,
        readOnly: isDate, // Make date fields read-only to use date picker
        onTap: isDate ? () => _selectDate(context, controller) : null,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(20),
            ), // Applied new styling
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 12.0,
          ),
        ),
      ),
    );
  }

  // Function to select a date
  Future<void> _selectDate(
    BuildContext context,
    TextEditingController controller,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        controller.text = DateFormat(
          'dd-MM-yyyy',
        ).format(picked); // Formatted date
      });
    }
  }

  Future<void> _getNearbyLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users to enable the location services.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Location services are disabled. Please enable them.'),
        ),
      );
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // a dialog should be shown to the user explaining why permission is needed)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permissions are denied.')),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Location permissions are permanently denied, we cannot request permissions.',
          ),
        ),
      );
      return;
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        // _latitudeLongitudeController.text =
        //     '${position.latitude}, ${position.longitude}';
        _latitude.text = '${position.latitude}';
        _longitude.text = '${position.longitude}';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location fetched successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error fetching location: $e')));
    }
  }

  // Function to get current location using geolocator package
  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users to enable the location services.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Location services are disabled. Please enable them.'),
        ),
      );
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // a dialog should be shown to the user explaining why permission is needed)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permissions are denied.')),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Location permissions are permanently denied, we cannot request permissions.',
          ),
        ),
      );
      return;
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _latitudeLongitudeController.text =
            '${position.latitude}, ${position.longitude}';
        _latController.text = '${position.latitude}';
        _lonController.text = '${position.longitude}';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location fetched successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error fetching location: $e')));
    }
  }

  // MODIFIED: Function to pick an image from gallery with platform-aware handling
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      if (kIsWeb) {
        // For web, read the image as bytes
        final bytes = await image.readAsBytes();
        setState(() {
          _images.add(bytes); // Store Uint8List for web
        });
      } else {
        // For mobile and desktop, use the File class
        setState(() {
          _images.add(File(image.path)); // Store File for non-web
        });
      }
    }
  }

  // Function to remove an image
  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }

  // Helper function to convert int to Roman numeral for document list
  String _toRoman(int number) {
    if (number < 1 || number > 3999) return number.toString(); // Basic range
    final Map<int, String> romanMap = {
      1000: 'M',
      900: 'CM',
      500: 'D',
      400: 'CD',
      100: 'C',
      90: 'XC',
      50: 'L',
      40: 'XL',
      10: 'X',
      9: 'IX',
      5: 'V',
      4: 'IV',
      1: 'I',
    };
    String result = '';
    for (final entry in romanMap.entries) {
      while (number >= entry.key) {
        result += entry.value;
        number -= entry.key;
      }
    }
    return result;
  }

  // Helper function to get table rows for Page 1 (Items 1-9)
  List<pw.TableRow> _getPage1TableRows() {
    const pw.TextStyle contentTextStyle = pw.TextStyle(fontSize: 10.5);
    const pw.EdgeInsets cellPadding = pw.EdgeInsets.all(3);

    List<pw.TableRow> rows = [];

    rows.add(
      pw.TableRow(
        children: [
          pw.Container(
            padding: cellPadding,
            child: pw.Text('1.', style: contentTextStyle),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text(
              'Purpose for which the valuation is made',
              style: contentTextStyle,
            ),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text(':', style: contentTextStyle),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text(_purposeController.text, style: contentTextStyle),
          ),
        ],
      ),
    );
    rows.add(
      pw.TableRow(
        children: [
          pw.Container(
            padding: cellPadding,
            child: pw.Text('2.', style: contentTextStyle),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text('a) Date of inspection', style: contentTextStyle),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text(':', style: contentTextStyle),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text(
              _dateOfInspectionController.text,
              style: contentTextStyle,
            ),
          ),
        ],
      ),
    );
    rows.add(
      pw.TableRow(
        children: [
          pw.Container(padding: cellPadding, child: pw.Text('')),
          pw.Container(
            padding: cellPadding,
            child: pw.Text(
              'b) Date on which the valuation is made',
              style: contentTextStyle,
            ),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text(':', style: contentTextStyle),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text(
              _dateOfValuationController.text,
              style: contentTextStyle,
            ),
          ),
        ],
      ),
    );
    rows.add(
      pw.TableRow(
        children: [
          pw.Container(
            padding: cellPadding,
            child: pw.Text('3.', style: contentTextStyle),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text(
              'List of documents produced for perusal',
              style: contentTextStyle,
            ),
          ),
          pw.Container(padding: cellPadding, child: pw.Text('')),
          pw.Container(padding: cellPadding, child: pw.Text('')),
        ],
      ),
    );

    rows.add(
      pw.TableRow(
        children: [
          pw.Container(
            padding: cellPadding,
            child: pw.Text('', style: contentTextStyle),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text('i) Land Tax Receipt (${_LandTaxReceipt.text})',
                style: contentTextStyle),
          ),
        ],
      ),
    );

    rows.add(
      pw.TableRow(
        children: [
          pw.Container(
            padding: cellPadding,
            child: pw.Text('', style: contentTextStyle),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text('ii) Location Plan (${_TitleDeed.text})',
                style: contentTextStyle),
          ),
        ],
      ),
    );

    rows.add(
      pw.TableRow(
        children: [
          pw.Container(
            padding: cellPadding,
            child: pw.Text('', style: contentTextStyle),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text(
                'iii) Legal Scrutiny Report dated (${_BuildingCertificate.text})',
                style: contentTextStyle),
          ),
        ],
      ),
    );

    // rows.add(
    //   pw.TableRow(
    //     children: [
    //       pw.Container(
    //         padding: cellPadding,
    //         child: pw.Text('', style: contentTextStyle),
    //       ),
    //       pw.Container(
    //         padding: cellPadding,
    //         child: pw.Text('iv) Location Sketch (${_LocationSketch.text})',
    //             style: contentTextStyle),
    //       ),
    //     ],
    //   ),
    // );

    // rows.add(
    //   pw.TableRow(
    //     children: [
    //       pw.Container(
    //         padding: cellPadding,
    //         child: pw.Text('', style: contentTextStyle),
    //       ),
    //       pw.Container(
    //         padding: cellPadding,
    //         child: pw.Text(
    //             'v) Possession Certificate (${_PossessionCertificate.text})',
    //             style: contentTextStyle),
    //       ),
    //     ],
    //   ),
    // );

    // rows.add(
    //   pw.TableRow(
    //     children: [
    //       pw.Container(
    //         padding: cellPadding,
    //         child: pw.Text('', style: contentTextStyle),
    //       ),
    //       pw.Container(
    //         padding: cellPadding,
    //         child: pw.Text(
    //             'vi) Building Completion Plan (${_BuildingCompletionPlan.text})',
    //             style: contentTextStyle),
    //       ),
    //     ],
    //   ),
    // );

    // rows.add(
    //   pw.TableRow(
    //     children: [
    //       pw.Container(
    //         padding: cellPadding,
    //         child: pw.Text('', style: contentTextStyle),
    //       ),
    //       pw.Container(
    //         padding: cellPadding,
    //         child: pw.Text(
    //             'vii) Thandapper Document (${_ThandapperDocument.text})',
    //             style: contentTextStyle),
    //       ),
    //     ],
    //   ),
    // );

    // rows.add(
    //   pw.TableRow(
    //     children: [
    //       pw.Container(
    //         padding: cellPadding,
    //         child: pw.Text('', style: contentTextStyle),
    //       ),
    //       pw.Container(
    //         padding: cellPadding,
    //         child: pw.Text(
    //             'viii) Building Tax Receipt (${_BuildingTaxReceipt.text})',
    //             style: contentTextStyle),
    //       ),
    //     ],
    //   ),
    // );

    rows.add(
      pw.TableRow(
        children: [
          pw.Container(
            padding: cellPadding,
            child: pw.Text('4.', style: contentTextStyle),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text(
                'Name of the owner(s) and his / their address (es) with Phone no. (details of share of each owner in case of joint ownership)',
                style: contentTextStyle),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text(':', style: contentTextStyle),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text(_ownerNameController.text, style: contentTextStyle),
          ),
        ],
      ),
    );
    rows.add(
      pw.TableRow(
        children: [
          pw.Container(
            padding: cellPadding,
            child: pw.Text('5.', style: contentTextStyle),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text(
                'Brief description of the property (Including leasehold / freehold etc)',
                style: contentTextStyle),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text(':', style: contentTextStyle),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text(
              _BriefDescription.text,
              style: contentTextStyle,
            ),
          ),
        ],
      ),
    );
    rows.add(
      pw.TableRow(
        children: [
          pw.Container(
            padding: cellPadding,
            child: pw.Text('6.', style: contentTextStyle),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text(
              'Location of property',
              style: contentTextStyle,
            ),
          ),
          pw.Container(padding: cellPadding, child: pw.Text(':')),
          pw.Container(
            padding: cellPadding,
            child: pw.Text(
              _LocationOfProperty.text,
              style: contentTextStyle,
            ),
          ),
        ],
      ),
    );
    rows.add(
      pw.TableRow(
        children: [
          pw.Container(
              padding: cellPadding,
              child: pw.Text('        a', style: contentTextStyle)),
          pw.Container(
            padding: cellPadding,
            child:
                pw.Text(' Plot No. /Re. Survey No.', style: contentTextStyle),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text(':', style: contentTextStyle),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text(_PlotNo.text, style: contentTextStyle),
          ),
        ],
      ),
    );
    rows.add(
      pw.TableRow(
        children: [
          pw.Container(
              padding: cellPadding,
              child: pw.Text('        b', style: contentTextStyle)),
          pw.Container(
            padding: cellPadding,
            child: pw.Text(' Door No. ', style: contentTextStyle),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text(':', style: contentTextStyle),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text(_DoorNo.text, style: contentTextStyle),
          ),
        ],
      ),
    );
    rows.add(
      pw.TableRow(
        children: [
          pw.Container(
              padding: cellPadding,
              child: pw.Text('        c', style: contentTextStyle)),
          pw.Container(
            padding: cellPadding,
            child: pw.Text(' T. S. No. / Village ', style: contentTextStyle),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text(':', style: contentTextStyle),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text(_TSNO.text, style: contentTextStyle),
          ),
        ],
      ),
    );
    rows.add(
      pw.TableRow(
        children: [
          pw.Container(
              padding: cellPadding,
              child: pw.Text('        d', style: contentTextStyle)),
          pw.Container(
            padding: cellPadding,
            child: pw.Text('  Ward / Taluk ', style: contentTextStyle),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text(':', style: contentTextStyle),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text(
              _Ward.text,
              style: contentTextStyle,
            ),
          ),
        ],
      ),
    );
    rows.add(
      pw.TableRow(
        children: [
          pw.Container(
              padding: cellPadding,
              child: pw.Text('        e', style: contentTextStyle)),
          pw.Container(
            padding: cellPadding,
            child: pw.Text('  Mandal / District  ', style: contentTextStyle),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text(':', style: contentTextStyle),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text(
              _Mandal.text,
              style: contentTextStyle,
            ),
          ),
        ],
      ),
    );

    return rows;
  }

  List<pw.TableRow> _getPage2Table1Rows() {
    const pw.TextStyle contentTextStyle = pw.TextStyle(
      fontSize: 11,
    ); // Increased font size to 10
    const pw.EdgeInsets cellPadding = pw.EdgeInsets.all(3);

    List<pw.TableRow> rows = [];
    rows.add(
      pw.TableRow(
        children: [
          pw.Container(
            padding: cellPadding,
            child: pw.Text('7.', style: contentTextStyle),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text('Postal address of the property ',
                style: contentTextStyle),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text(':', style: contentTextStyle),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text(
              _postalAddress
                  .text, // Ensure this string has "\n" characters inside it
              style: contentTextStyle,
            ),
          ),
        ],
      ),
    );
    rows.add(
      pw.TableRow(
        children: [
          pw.Container(
            padding: cellPadding,
            child: pw.Text('8.', style: contentTextStyle),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text(
              'City / Town',
              style: contentTextStyle,
            ),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text(':', style: contentTextStyle),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text(
              _city.text,
              style: contentTextStyle,
            ),
          ),
        ],
      ),
    );
    rows.add(
      pw.TableRow(
        children: [
          pw.Container(
            padding: cellPadding,
            child: pw.Text('', style: contentTextStyle),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text(
              'Residential Area',
              style: contentTextStyle,
            ),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text(':', style: contentTextStyle),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text(
              _residential.text,
              style: contentTextStyle,
            ),
          ),
        ],
      ),
    );
    rows.add(
      pw.TableRow(
        children: [
          pw.Container(
            padding: cellPadding,
            child: pw.Text('', style: contentTextStyle),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text(
              'Commercial Area ',
              style: contentTextStyle,
            ),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text(':', style: contentTextStyle),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text(
              _commercial.text,
              style: contentTextStyle,
            ),
          ),
        ],
      ),
    );
    rows.add(
      pw.TableRow(
        children: [
          pw.Container(
            padding: cellPadding,
            child: pw.Text('', style: contentTextStyle),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text(
              'Industrial Area',
              style: contentTextStyle,
            ),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text(':', style: contentTextStyle),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text(
              _industrial.text,
              style: contentTextStyle,
            ),
          ),
        ],
      ),
    );
    rows.add(
      pw.TableRow(
        children: [
          pw.Container(
            padding: cellPadding,
            child: pw.Text('9.', style: contentTextStyle),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text(
              'Classification of the area',
              style: contentTextStyle,
            ),
          ),
          // pw.Container(
          //   padding: cellPadding,
          //   child: pw.Text(':', style: contentTextStyle),
          // ),
          // pw.Container(
          //   padding: cellPadding,
          //   child: pw.Text(
          //     _propertyZoneController.text,
          //     style: contentTextStyle,
          //   ),
          // ),
        ],
      ),
    );
    rows.add(
      pw.TableRow(
        children: [
          pw.Container(
            padding: cellPadding,
            child: pw.Text('i) ', style: contentTextStyle),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text(
              'High / Middle / Poor',
              style: contentTextStyle,
            ),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text(':', style: contentTextStyle),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text(
              _typeOfRichness.text,
              style: contentTextStyle,
            ),
          ),
        ],
      ),
    );
    rows.add(
      pw.TableRow(
        children: [
          pw.Container(
            padding: cellPadding,
            child: pw.Text('ii) ', style: contentTextStyle),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text(
              'Urban / Semi Urban / Rural',
              style: contentTextStyle,
            ),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text(':', style: contentTextStyle),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text(
              _typeOfPlace.text,
              style: contentTextStyle,
            ),
          ),
        ],
      ),
    );
    rows.add(
      pw.TableRow(
        children: [
          pw.Container(
            padding: cellPadding,
            child: pw.Text('10.', style: contentTextStyle),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text(
              'Coming under Corporation limit / Village Panchayat / Municipality',
              style: contentTextStyle,
            ),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text(':', style: contentTextStyle),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text(
              _comingUnderCorporationController.text,
              style: contentTextStyle,
            ),
          ),
        ],
      ),
    );
    rows.add(
      pw.TableRow(
        children: [
          pw.Container(
            padding: cellPadding,
            child: pw.Text('11.', style: contentTextStyle),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text(
              'Whether covered under any State / Central Govt. enactments (e.g. Urban Land Ceiling Act) or notified under agency area / scheduled area',
              style: contentTextStyle,
            ),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text(':', style: contentTextStyle),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text(
              _coveredUnderStateCentralGovtController.text,
              style: contentTextStyle,
            ),
          ),
        ],
      ),
    );
    rows.add(
      pw.TableRow(
        children: [
          pw.Container(
            padding: cellPadding,
            child: pw.Text('12.', style: contentTextStyle),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text(
              'In case it is an agricultural land, any conversion to house site plots is contemplated',
              style: contentTextStyle,
            ),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text(':', style: contentTextStyle),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text(
              _agriculturalLandConversionController.text,
              style: contentTextStyle,
            ),
          ),
        ],
      ),
    );
    return rows;
  }

  List<pw.TableRow> _getPage2Table2RowsHeading() {
    const pw.TextStyle contentTextStyle = pw.TextStyle(
      fontSize: 11,
    ); // Increased font size to 10
    const pw.EdgeInsets cellPadding = pw.EdgeInsets.all(3);

    List<pw.TableRow> rows = [];

    // rows.add(
    //   pw.TableRow(
    //     children: [
    //       pw.Container(
    //         padding: cellPadding,
    //         child: pw.Text('14.', style: contentTextStyle),
    //       ),
    //       pw.Container(
    //         padding: cellPadding,
    //         child: pw.Text(
    //           'Boundaries of the property:',
    //           style: contentTextStyle,
    //         ),
    //       ), // empty
    //     ],
    //   ),
    // );

    return rows;
  }

  // Helper function to get table rows for Page 2 - Table 2 (Item 15)
  List<pw.TableRow> _getPage2Table2Rows() {
    const pw.TextStyle contentTextStyle = pw.TextStyle(
      fontSize: 11,
    ); // Increased font size to 10
    const pw.EdgeInsets cellPadding = pw.EdgeInsets.all(3);

    List<pw.TableRow> rows = [];
    rows.add(
      pw.TableRow(
        children: [
          pw.Container(
            padding: cellPadding,
            child: pw.Text('13.', textScaleFactor: 0.9),
          ),
          pw.Container(
            padding: cellPadding,
            child:
                pw.Text('Boundaries of the property', style: contentTextStyle),
            alignment: pw.Alignment.center,
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text(':', style: contentTextStyle),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text('As per Location Sketch', style: contentTextStyle),
            alignment: pw.Alignment.center,
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text('Actual', style: contentTextStyle),
            alignment: pw.Alignment.center,
          ),
        ],
      ),
    );
    rows.add(
      pw.TableRow(
        children: [
          pw.Container(padding: cellPadding, child: pw.Text('')),
          pw.Container(
            padding: cellPadding,
            child: pw.Text('North', style: contentTextStyle),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text(':', style: contentTextStyle),
          ), // colon added for consistency
          pw.Container(
            padding: cellPadding,
            child: pw.Text(
              _boundaryNorthTitleController.text,
              style: contentTextStyle,
            ),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text(
              _boundaryNorthSketchController.text,
              style: contentTextStyle,
            ),
          ),
        ],
      ),
    );
    rows.add(
      pw.TableRow(
        children: [
          pw.Container(padding: cellPadding, child: pw.Text('')),
          pw.Container(
            padding: cellPadding,
            child: pw.Text('South', style: contentTextStyle),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text(':', style: contentTextStyle),
          ), // colon added for consistency
          pw.Container(
            padding: cellPadding,
            child: pw.Text(
              _boundarySouthTitleController.text,
              style: contentTextStyle,
            ),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text(
              _boundarySouthSketchController.text,
              style: contentTextStyle,
            ),
          ),
        ],
      ),
    );
    rows.add(
      pw.TableRow(
        children: [
          pw.Container(padding: cellPadding, child: pw.Text('')),
          pw.Container(
            padding: cellPadding,
            child: pw.Text('East', style: contentTextStyle),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text(':', style: contentTextStyle),
          ), // colon added for consistency
          pw.Container(
            padding: cellPadding,
            child: pw.Text(
              _boundaryEastTitleController.text,
              style: contentTextStyle,
            ),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text(
              _boundaryEastSketchController.text,
              style: contentTextStyle,
            ),
          ),
        ],
      ),
    );
    rows.add(
      pw.TableRow(
        children: [
          pw.Container(padding: cellPadding, child: pw.Text('')),
          pw.Container(
            padding: cellPadding,
            child: pw.Text('West', style: contentTextStyle),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text(':', style: contentTextStyle),
          ), // colon added for consistency
          pw.Container(
            padding: cellPadding,
            child: pw.Text(
              _boundaryWestTitleController.text,
              style: contentTextStyle,
            ),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text(
              _boundaryWestSketchController.text,
              style: contentTextStyle,
            ),
          ),
        ],
      ),
    );
    // rows.add(
    //   pw.TableRow(
    //     children: [
    //       pw.Container(padding: cellPadding, child: pw.Text('')),
    //       pw.Container(
    //         padding: cellPadding,
    //         child: pw.Text('Deviations if any :', style: contentTextStyle),
    //       ),
    //       pw.Container(
    //         padding: cellPadding,
    //         child: pw.Text(''),
    //       ), // Empty cell for colon column
    //       pw.Container(
    //         padding: cellPadding,
    //         child: pw.Text(
    //           _boundaryDeviationsController.text,
    //           style: contentTextStyle,
    //         ),
    //       ),
    //       pw.Container(
    //         padding: cellPadding,
    //         child: pw.Text(''),
    //       ), // Empty cell for 5th column
    //     ],
    //   ),
    // );

    return rows;
  }

  List<pw.TableRow> _getPage2Table2RowsPart2Heading() {
    const pw.TextStyle contentTextStyle = pw.TextStyle(
      fontSize: 11,
    ); // Increased font size to 10
    const pw.EdgeInsets cellPadding = pw.EdgeInsets.all(3);

    List<pw.TableRow> rows = [];

    // Item 15. Dimensions of the site (main header, 4-column like before)
    // rows.add(
    //   pw.TableRow(
    //     children: [
    //       pw.Container(
    //         padding: cellPadding,
    //         child: pw.Text('14.1', style: contentTextStyle),
    //       ),
    //       pw.Container(
    //         padding: cellPadding,
    //         child: pw.Text('Dimensions of the site', style: contentTextStyle),
    //       ),
    //     ],
    //   ),
    // );

    return rows;
  }

  List<pw.TableRow> _getPage2Table2RowsPart2() {
    const pw.TextStyle contentTextStyle = pw.TextStyle(
      fontSize: 11,
    ); // Increased font size to 10
    const pw.EdgeInsets cellPadding = pw.EdgeInsets.all(3);

    List<pw.TableRow> rows = [];

    // Item 15. Dimensions of the site (sub-header, now 5 columns)
    rows.add(
      pw.TableRow(
        children: [
          // 1. S.No column
          pw.Container(
            padding: cellPadding,
            child: pw.Text('14.1', textScaleFactor: 0.8),
          ),
          // 2. Dimensions column
          pw.Container(
            padding: cellPadding,
            child: pw.Text('Dimensions of the site (SITE PLAN)',
                style: contentTextStyle),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text(':', style: contentTextStyle),
          ),
          pw.Container(
            padding: const pw.EdgeInsets.all(0),
            child: pw.Column(
              children: [
                pw.Container(
                  width: double
                      .infinity, // Ensure it stretches the full width of the column
                  padding: cellPadding, // Apply the padding here instead
                  decoration: const pw.BoxDecoration(
                    border: pw.Border(
                      bottom: pw.BorderSide(
                        width: 0.5, // Adjust width to match your table's border
                      ),
                    ),
                  ),
                  child: pw.Text('A', style: contentTextStyle),
                  alignment: pw.Alignment.center,
                ),
                // BOTTOM ROW: "As per deed"
                pw.Container(
                  width: double.infinity,
                  padding: cellPadding, // Apply the padding here instead
                  child: pw.Text('As per deed', style: contentTextStyle),
                  alignment: pw.Alignment.center,
                ),
              ],
            ),
          ),
          pw.Container(
            padding: const pw.EdgeInsets.all(0),
            child: pw.Column(
              children: [
                pw.Container(
                  width: double
                      .infinity, // Ensure it stretches the full width of the column
                  padding: cellPadding, // Apply the padding here instead
                  decoration: const pw.BoxDecoration(
                    border: pw.Border(
                      bottom: pw.BorderSide(
                        width: 0.5, // Adjust width to match your table's border
                      ),
                    ),
                  ),
                  child: pw.Text('B', style: contentTextStyle),
                  alignment: pw.Alignment.center,
                ),
                // BOTTOM ROW: "As per deed"
                pw.Container(
                  width: double.infinity,
                  padding: cellPadding, // Apply the padding here instead
                  child: pw.Text('ACTUAL', style: contentTextStyle),
                  alignment: pw.Alignment.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
    rows.add(
      pw.TableRow(
        children: [
          pw.Container(padding: cellPadding, child: pw.Text('')),
          pw.Container(
            padding: cellPadding,
            child: pw.Text('North', style: contentTextStyle),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text(':', style: contentTextStyle),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text(
              _dimNorthActualsController.text,
              style: contentTextStyle,
            ),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text(
              _dimNorthDocumentsController.text,
              style: contentTextStyle,
            ),
          ),
        ],
      ),
    );
    rows.add(
      pw.TableRow(
        children: [
          pw.Container(padding: cellPadding, child: pw.Text('')),
          pw.Container(
            padding: cellPadding,
            child: pw.Text('South', style: contentTextStyle),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text(':', style: contentTextStyle),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text(
              _dimSouthActualsController.text,
              style: contentTextStyle,
            ),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text(
              _dimSouthDocumentsController.text,
              style: contentTextStyle,
            ),
          ),
        ],
      ),
    );
    rows.add(
      pw.TableRow(
        children: [
          pw.Container(padding: cellPadding, child: pw.Text('')),
          pw.Container(
            padding: cellPadding,
            child: pw.Text('East', style: contentTextStyle),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text(':', style: contentTextStyle),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text(
              _dimEastActualsController.text,
              style: contentTextStyle,
            ),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text(
              _dimEastDocumentsController.text,
              style: contentTextStyle,
            ),
          ),
        ],
      ),
    );
    rows.add(
      pw.TableRow(
        children: [
          pw.Container(padding: cellPadding, child: pw.Text('')),
          pw.Container(
            padding: cellPadding,
            child: pw.Text('West', style: contentTextStyle),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text(':', style: contentTextStyle),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text(
              _dimWestActualsController.text,
              style: contentTextStyle,
            ),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text(
              _dimWestDocumentsController.text,
              style: contentTextStyle,
            ),
          ),
        ],
      ),
    );
    // rows.add(
    //   pw.TableRow(
    //     children: [
    //       pw.Container(padding: cellPadding, child: pw.Text('')),
    //       pw.Container(
    //         padding: cellPadding,
    //         child: pw.Text('Total Area', style: contentTextStyle),
    //       ),
    //       pw.Container(
    //         padding: cellPadding,
    //         child: pw.Text(
    //           _dimTotalAreaActualsController.text,
    //           style: contentTextStyle,
    //         ),
    //       ),
    //       pw.Container(
    //         padding: cellPadding,
    //         child: pw.Text(
    //           _dimTotalAreaDocumentsController.text,
    //           style: contentTextStyle,
    //         ),
    //       ),
    //       pw.Container(
    //         padding: cellPadding,
    //         child: pw.Text(
    //           _dimTotalAreaAdoptedController.text,
    //           style: contentTextStyle,
    //         ),
    //       ),
    //     ],
    //   ),
    // );
    // rows.add(
    //   pw.TableRow(
    //     children: [
    //       pw.Container(padding: cellPadding, child: pw.Text('')),
    //       pw.Container(
    //         padding: cellPadding,
    //         child: pw.Text('Deviations if any :', style: contentTextStyle),
    //       ),
    //     ],
    //   ),
    // );

    return rows;
  }

  // Helper function to get table rows for Page 2 - Table 3 (Items 16-17)
  List<pw.TableRow> _getPage2Table3Rows() {
    const pw.TextStyle contentTextStyle = pw.TextStyle(
      fontSize: 11,
    ); // Increased font size to 10
    const pw.EdgeInsets cellPadding = pw.EdgeInsets.all(3);

    List<pw.TableRow> rows = [];

    // Item 16
    rows.add(
      pw.TableRow(
        children: [
          pw.Container(
            padding: cellPadding,
            child: pw.Text('14.2', style: contentTextStyle),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text(
              'Latitude, Longitude and Coordinates of the site',
              style: contentTextStyle,
            ),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text(':', style: contentTextStyle),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text(
              _latitudeLongitudeController.text,
              style: contentTextStyle,
            ),
          ),
        ],
      ),
    );

    rows.add(
      pw.TableRow(
        children: [
          pw.Container(
            padding: cellPadding,
            child: pw.Text('15', style: contentTextStyle),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text(
              'Extent of the site',
              style: contentTextStyle,
            ),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text(':', style: contentTextStyle),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text(
              _extent.text,
              style: contentTextStyle,
            ),
          ),
        ],
      ),
    );
    rows.add(
      pw.TableRow(
        children: [
          pw.Container(
            padding: cellPadding,
            child: pw.Text('16', style: contentTextStyle),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text(
              'Extent of the site considered for valuation (least of 14 A & 14 B) ',
              style: contentTextStyle,
            ),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text(':', style: contentTextStyle),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text(
              _extentConsidered.text,
              style: contentTextStyle,
            ),
          ),
        ],
      ),
    );
    return rows;
  }

  // Helper function to get table rows for new section 18
  List<pw.TableRow> _getPage2Table4Rows() {
    const pw.TextStyle contentTextStyle = pw.TextStyle(
      fontSize: 11,
    ); // Increased font size to 10
    const pw.EdgeInsets cellPadding = pw.EdgeInsets.all(3);

    List<pw.TableRow> rows = [];

    rows.add(
      pw.TableRow(
        children: [
          pw.Container(
            padding: cellPadding,
            child: pw.Text('18.', style: contentTextStyle),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text('Details /Floors', style: contentTextStyle),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text('Occupancy\n(Self/Rented)', style: contentTextStyle),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text('No. Of Room', style: contentTextStyle),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text('No. Of Kitchen', style: contentTextStyle),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text('No. of Bathroom', style: contentTextStyle),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text(
              'Usage Remarks\n(Resi/Comm)',
              style: contentTextStyle,
            ),
          ),
        ],
      ),
    );

    // Ground Floor Row
    rows.add(
      pw.TableRow(
        children: [
          pw.Container(
            padding: cellPadding,
            child: pw.Text(''),
          ), // Empty for S.No.
          pw.Container(
            padding: cellPadding,
            child: pw.Text('Ground', style: contentTextStyle),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text(
              _groundFloorOccupancyController.text,
              style: contentTextStyle,
            ),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text(
              _groundFloorNoOfRoomController.text,
              style: contentTextStyle,
            ),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text(
              _groundFloorNoOfKitchenController.text,
              style: contentTextStyle,
            ),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text(
              _groundFloorNoOfBathroomController.text,
              style: contentTextStyle,
            ),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text(
              _groundFloorUsageRemarksController.text,
              style: contentTextStyle,
            ),
          ),
        ],
      ),
    );

    // First Floor Row
    rows.add(
      pw.TableRow(
        children: [
          pw.Container(
            padding: cellPadding,
            child: pw.Text(''),
          ), // Empty for S.No.
          pw.Container(
            padding: cellPadding,
            child: pw.Text('First', style: contentTextStyle),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text(
              _firstFloorOccupancyController.text,
              style: contentTextStyle,
            ),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text(
              _firstFloorNoOfRoomController.text,
              style: contentTextStyle,
            ),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text(
              _firstFloorNoOfKitchenController.text,
              style: contentTextStyle,
            ),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text(
              _firstFloorNoOfBathroomController.text,
              style: contentTextStyle,
            ),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text(
              _firstFloorUsageRemarksController.text,
              style: contentTextStyle,
            ),
          ),
        ],
      ),
    );

    // Note: "Add Row" functionality implies dynamic addition which is not implemented here.
    // You would typically manage a list of floor data models to dynamically generate rows.

    return rows;
  }

  // Helper function to get table rows for new section (Items 19-20)
  List<pw.TableRow> _getPage2Table5Rows() {
    const pw.TextStyle contentTextStyle = pw.TextStyle(
      fontSize: 11,
    ); // Increased font size to 10
    const pw.EdgeInsets cellPadding = pw.EdgeInsets.all(3);

    List<pw.TableRow> rows = [];

    rows.add(
      pw.TableRow(
        children: [
          pw.Container(
            padding: cellPadding,
            child: pw.Text('19.', style: contentTextStyle),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text(
              'Type of road available at present :\n(Bitumen/Mud/CC/Private)',
              style: contentTextStyle,
            ),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text(':', style: contentTextStyle),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text(_typeOfRoadController.text, style: contentTextStyle),
          ),
        ],
      ),
    );
    rows.add(
      pw.TableRow(
        children: [
          pw.Container(
            padding: cellPadding,
            child: pw.Text('20.', style: contentTextStyle),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text('Width of road - in feet', style: contentTextStyle),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text(':', style: contentTextStyle),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text(
              _widthOfRoadController.text,
              style: contentTextStyle,
            ),
          ),
        ],
      ),
    );

    return rows;
  }

  // Helper function to get table rows for Page 3 (Item 21)
  List<pw.TableRow> _getPage3TableRows() {
    const pw.TextStyle contentTextStyle = pw.TextStyle(fontSize: 11);
    const pw.EdgeInsets cellPadding = pw.EdgeInsets.all(3);

    List<pw.TableRow> rows = [];
    rows.add(
      pw.TableRow(
        children: [
          pw.Container(
            padding: cellPadding,
            child: pw.Text('17.', style: contentTextStyle),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text(
              'Whether occupied by the Self /tenant? If occupied by tenant, since how long? Rent received per month.',
              style: contentTextStyle,
            ),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text(':', style: contentTextStyle),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text(
              '${_occupiedBySelfTenantController.text}${_occupiedBySelfTenantController.text.toLowerCase() == 'tenant' && _occupiedByTenantSinceController.text.isNotEmpty ? ', since ${_occupiedByTenantSinceController.text}' : ''}${_rentReceivedPerMonthController.text.isNotEmpty ? '. Rent: ${_rentReceivedPerMonthController.text}' : ''}',
              style: contentTextStyle,
            ),
          ),
        ],
      ),
    );

    rows.add(
      pw.TableRow(
        children: [
          pw.Container(
            padding: cellPadding,
            child: pw.Text('21.', style: contentTextStyle),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text(
              'Is it a land - locked land?',
              style: contentTextStyle,
            ),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text(':', style: contentTextStyle),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text(
              _isLandLockedController.text,
              style: contentTextStyle,
            ),
          ),
        ],
      ),
    );

    return rows;
  }

  List<pw.TableRow> _getLandValuationTableRowsHeading() {
    const pw.EdgeInsets cellPadding = pw.EdgeInsets.all(3);
    List<pw.TableRow> rows = [];

    rows.add(
      pw.TableRow(
        children: [
          pw.Container(
            padding: cellPadding,
            alignment: pw.Alignment.centerLeft,
            child: pw.Text(
              'Part - A (Valuation of land)',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12),
            ),
          ),
        ],
      ),
    );

    return rows;
  }

  // NEW: Helper function to get table rows for "Part - A (Valuation of land)"
  List<pw.TableRow> _getLandValuationTableRows() {
    final pw.TextStyle headerTextStyle = pw.TextStyle(
      fontWeight: pw.FontWeight.bold,
      fontSize: 11,
    );
    const pw.TextStyle contentTextStyle = pw.TextStyle(fontSize: 11);
    const pw.EdgeInsets cellPadding = pw.EdgeInsets.all(3);

    List<pw.TableRow> rows = [];

    // Headers Row
    rows.add(
      pw.TableRow(
        children: [
          pw.Container(
            padding: cellPadding,
            child: pw.Text('1', style: contentTextStyle),
          ),
          pw.Container(
            padding: cellPadding,
            alignment: pw.Alignment.center,
            child: pw.Text('Details', style: headerTextStyle),
          ),
          pw.Container(
            padding: cellPadding,
            alignment: pw.Alignment.center,
            child: pw.Text('Land area in\nSq Ft', style: headerTextStyle),
          ),
          pw.Container(
            padding: cellPadding,
            alignment: pw.Alignment.center,
            child: pw.Text('Rate per Sq ft', style: headerTextStyle),
          ),
          pw.Container(
            padding: cellPadding,
            alignment: pw.Alignment.center,
            child: pw.Text('Value in Rs.', style: headerTextStyle),
          ),
        ],
      ),
    );

    // Row 2: Guideline rate
    rows.add(
      pw.TableRow(
        children: [
          pw.Container(
            padding: cellPadding,
            child: pw.Text('2.', style: contentTextStyle),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text(
              'Guideline rate obtained from the Registrar\'s Office (an evidence thereof to be enclosed)',
              style: contentTextStyle,
            ),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text(
              _landAreaGuidelineController.text,
              style: contentTextStyle,
            ),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text(
              _ratePerSqFtGuidelineController.text,
              style: contentTextStyle,
            ),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text(
              _valueInRsGuidelineController.text,
              style: contentTextStyle,
            ),
          ),
        ],
      ),
    );

    // Row 3: Prevailing market value
    rows.add(
      pw.TableRow(
        children: [
          pw.Container(
            padding: cellPadding,
            child: pw.Text('3.', style: contentTextStyle),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text(
              'Prevailing market value of the land',
              style: contentTextStyle,
            ),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text(
              _landAreaPrevailingController.text,
              style: contentTextStyle,
            ),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text(
              _ratePerSqFtPrevailingController.text,
              style: contentTextStyle,
            ),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text(
              _valueInRsPrevailingController.text,
              style: contentTextStyle,
            ),
          ),
        ],
      ),
    );

    return rows;
  }

  // NEW: Helper function to get table rows for "Part - B (Valuation of Building)"

  List<pw.TableRow> _getBuildingValuationTableRowsHeading() {
    const pw.EdgeInsets cellPadding = pw.EdgeInsets.all(3);

    List<pw.TableRow> rows = [];

    // Main Header
    rows.add(
      pw.TableRow(
        children: [
          pw.Container(
            padding: cellPadding,
            alignment: pw.Alignment.centerLeft,
            child: pw.Text(
              'Part - B (Valuation of Building)',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12),
            ),
          ),
        ],
      ),
    );

    return rows;
  }

  List<pw.TableRow> _getBuildingValuationTableRowsSubHeading() {
    const pw.EdgeInsets cellPadding = pw.EdgeInsets.all(3);
    final pw.TextStyle headerTextStyle = pw.TextStyle(
      fontWeight: pw.FontWeight.bold,
      fontSize: 11,
    );
    const pw.TextStyle contentTextStyle = pw.TextStyle(fontSize: 11);

    List<pw.TableRow> rows = [];

    rows.add(
      pw.TableRow(
        children: [
          pw.Container(
            padding: cellPadding,
            child: pw.Text('1.', style: contentTextStyle),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text(
              'Technical details of the building',
              style: headerTextStyle,
            ),
          ),
        ],
      ),
    );

    return rows;
  }

  List<pw.TableRow> _getBuildingValuationTableRows() {
    const pw.TextStyle contentTextStyle = pw.TextStyle(fontSize: 11);
    const pw.EdgeInsets cellPadding = pw.EdgeInsets.all(3);

    List<pw.TableRow> rows = [];

    // Rows for technical details
    rows.add(
      pw.TableRow(
        children: [
          pw.Container(padding: cellPadding, child: pw.Text('')),
          pw.Container(
            padding: cellPadding,
            child: pw.Text('a', style: contentTextStyle),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text(
              'Type of Building (Residential / Commercial / Industrial)',
              style: contentTextStyle,
            ),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text(
              _typeOfBuildingController.text,
              style: contentTextStyle,
            ),
          ),
        ],
      ),
    );
    rows.add(
      pw.TableRow(
        children: [
          pw.Container(padding: cellPadding, child: pw.Text('')),
          pw.Container(
            padding: cellPadding,
            child: pw.Text('b', style: contentTextStyle),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text(
              'Type of construction (Load bearing / RCC / Steel Framed)',
              style: contentTextStyle,
            ),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text(
              _typeOfConstructionController.text,
              style: contentTextStyle,
            ),
          ),
        ],
      ),
    );
    rows.add(
      pw.TableRow(
        children: [
          pw.Container(padding: cellPadding, child: pw.Text('')),
          pw.Container(
            padding: cellPadding,
            child: pw.Text('c', style: contentTextStyle),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text('Age of the building', style: contentTextStyle),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text(
              _ageOfTheBuildingController.text,
              style: contentTextStyle,
            ),
          ),
        ],
      ),
    );
    rows.add(
      pw.TableRow(
        children: [
          pw.Container(padding: cellPadding, child: pw.Text('')),
          pw.Container(
            padding: cellPadding,
            child: pw.Text('d', style: contentTextStyle),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text(
              'Residual age of the building',
              style: contentTextStyle,
            ),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text(
              _residualAgeOfTheBuildingController.text,
              style: contentTextStyle,
            ),
          ),
        ],
      ),
    );
    rows.add(
      pw.TableRow(
        children: [
          pw.Container(padding: cellPadding, child: pw.Text('')),
          pw.Container(
            padding: cellPadding,
            child: pw.Text('e', style: contentTextStyle),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text(
              'Approved map / plan issuing authority',
              style: contentTextStyle,
            ),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text(
              _approvedMapAuthorityController.text,
              style: contentTextStyle,
            ),
          ),
        ],
      ),
    );
    rows.add(
      pw.TableRow(
        children: [
          pw.Container(padding: cellPadding, child: pw.Text('')),
          pw.Container(
            padding: cellPadding,
            child: pw.Text('f', style: contentTextStyle),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text(
              'Whether genuineness or authenticity of approved map / plan is verified',
              style: contentTextStyle,
            ),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text(
              _genuinenessVerifiedController.text,
              style: contentTextStyle,
            ),
          ),
        ],
      ),
    );
    rows.add(
      pw.TableRow(
        children: [
          pw.Container(padding: cellPadding, child: pw.Text('')),
          pw.Container(
            padding: cellPadding,
            child: pw.Text('g', style: contentTextStyle),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text(
              'Any other comments by our empanelled valuers on authentic of approved plan',
              style: contentTextStyle,
            ),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text(
              _otherCommentsController.text,
              style: contentTextStyle,
            ),
          ),
        ],
      ),
    );

    return rows;
  }

  // NEW: Helper function to get table rows for "Build up Area"
  List<pw.TableRow> _getBuildUpAreaTableRows() {
    final pw.TextStyle headerTextStyle = pw.TextStyle(
      fontWeight: pw.FontWeight.bold,
      fontSize: 11,
    );
    const pw.TextStyle contentTextStyle = pw.TextStyle(fontSize: 11);
    const pw.EdgeInsets cellPadding = pw.EdgeInsets.all(3);

    List<pw.TableRow> rows = [];

    // First header row
    rows.add(
      pw.TableRow(
        children: [
          pw.Container(
            padding: cellPadding,
            alignment: pw.Alignment.center,
            child: pw.Text('S n', style: headerTextStyle),
          ),
          pw.Container(
            padding: cellPadding,
            alignment: pw.Alignment.center,
            child: pw.Text('Particular of item', style: headerTextStyle),
          ),
          // "Build up Area" header - placed in the first of the three columns it spans
          pw.Container(
            padding: cellPadding,
            alignment: pw.Alignment.center,
            child: pw.Text('Build up Area', style: headerTextStyle),
          ),
          pw.Container(), // Empty cell for the second column of "Build up Area" span
          pw.Container(), // Empty cell for the third column of "Build up Area" span
          pw.Container(
            padding: cellPadding,
            alignment: pw.Alignment.center,
            child: pw.Text('Replacement\nCost in Rs.', style: headerTextStyle),
          ),
          pw.Container(
            padding: cellPadding,
            alignment: pw.Alignment.center,
            child: pw.Text('Depreciation\nin Rs.', style: headerTextStyle),
          ),
          pw.Container(
            padding: cellPadding,
            alignment: pw.Alignment.center,
            child: pw.Text(
              'Net value\nafter\nDepreciations Rs.',
              style: headerTextStyle,
            ),
          ),
        ],
      ),
    );

    // Second header row (sub-headers for "Build up Area")
    rows.add(
      pw.TableRow(
        children: [
          pw.Container(
            padding: cellPadding,
            child: pw.Text(''),
          ), // Empty for S n
          pw.Container(
            padding: cellPadding,
            child: pw.Text(''),
          ), // Empty for Particular of item
          pw.Container(
            padding: cellPadding,
            alignment: pw.Alignment.center,
            child: pw.Text('As per approved\nPlan/FSI', style: headerTextStyle),
          ),
          pw.Container(
            padding: cellPadding,
            alignment: pw.Alignment.center,
            child: pw.Text('As per\nActual', style: headerTextStyle),
          ),
          pw.Container(
            padding: cellPadding,
            alignment: pw.Alignment.center,
            child: pw.Text(
              'Area\nConsidered\nfor the\nValuation',
              style: headerTextStyle,
            ),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text(''),
          ), // Empty for Replacement Cost
          pw.Container(
            padding: cellPadding,
            child: pw.Text(''),
          ), // Empty for Depreciation
          pw.Container(
            padding: cellPadding,
            child: pw.Text(''),
          ), // Empty for Net value
        ],
      ),
    );

    // Ground floor row
    rows.add(
      pw.TableRow(
        children: [
          pw.Container(
            padding: cellPadding,
            child: pw.Text('', style: contentTextStyle),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text('Ground\nfloor', style: contentTextStyle),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text(
              _groundFloorApprovedPlanController.text,
              style: contentTextStyle,
            ),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text(
              _groundFloorActualController.text,
              style: contentTextStyle,
            ),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text(
              _groundFloorConsideredValuationController.text,
              style: contentTextStyle,
            ),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text(
              _groundFloorReplacementCostController.text,
              style: contentTextStyle,
            ),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text(
              _groundFloorDepreciationController.text,
              style: contentTextStyle,
            ),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text(
              _groundFloorNetValueController.text,
              style: contentTextStyle,
            ),
          ),
        ],
      ),
    );

    // First floor row
    rows.add(
      pw.TableRow(
        children: [
          pw.Container(
            padding: cellPadding,
            child: pw.Text('', style: contentTextStyle),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text('First\nfloor', style: contentTextStyle),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text(
              _firstFloorApprovedPlanController.text,
              style: contentTextStyle,
            ),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text(
              _firstFloorActualController.text,
              style: contentTextStyle,
            ),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text(
              _firstFloorConsideredValuationController.text,
              style: contentTextStyle,
            ),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text(
              _firstFloorReplacementCostController.text,
              style: contentTextStyle,
            ),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text(
              _firstFloorDepreciationController.text,
              style: contentTextStyle,
            ),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text(
              _firstFloorNetValueController.text,
              style: contentTextStyle,
            ),
          ),
        ],
      ),
    );

    // Total row
    rows.add(
      pw.TableRow(
        children: [
          pw.Container(
            padding: cellPadding,
            child: pw.Text('', style: contentTextStyle),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text('Total', style: headerTextStyle),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text(
              _totalApprovedPlanController.text,
              style: contentTextStyle,
            ),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text(
              _totalActualController.text,
              style: contentTextStyle,
            ),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text(
              _totalConsideredValuationController.text,
              style: contentTextStyle,
            ),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text(
              _totalReplacementCostController.text,
              style: contentTextStyle,
            ),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text(
              _totalDepreciationController.text,
              style: contentTextStyle,
            ),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text(
              _totalNetValueController.text,
              style: contentTextStyle,
            ),
          ),
        ],
      ),
    );

    return rows;
  }

  // NEW: Helper function to get table rows for "Part C - Amenities"
  List<pw.TableRow> _getAmenitiesTableRows() {
    final pw.TextStyle headerTextStyle = pw.TextStyle(
      fontWeight: pw.FontWeight.bold,
      fontSize: 11,
    );
    const pw.TextStyle contentTextStyle = pw.TextStyle(fontSize: 11);
    const pw.EdgeInsets cellPadding = pw.EdgeInsets.all(3);

    List<pw.TableRow> rows = [];

    rows.add(
      pw.TableRow(
        children: [
          pw.Container(
            padding: cellPadding,
            child: pw.Text('1.', style: contentTextStyle),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text('Wardrobes', style: contentTextStyle),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text(':', style: contentTextStyle),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text(_wardrobesController.text, style: contentTextStyle),
          ),
        ],
      ),
    );
    rows.add(
      pw.TableRow(
        children: [
          pw.Container(
            padding: cellPadding,
            child: pw.Text('2.', style: contentTextStyle),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text('Amenities', style: contentTextStyle),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text(':', style: contentTextStyle),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text(_amenitiesController.text, style: contentTextStyle),
          ),
        ],
      ),
    );
    rows.add(
      pw.TableRow(
        children: [
          pw.Container(
            padding: cellPadding,
            child: pw.Text('3.', style: contentTextStyle),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text('Any other Additional', style: contentTextStyle),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text(':', style: contentTextStyle),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text(
              _anyOtherAdditionalController.text,
              style: contentTextStyle,
            ),
          ),
        ],
      ),
    );
    rows.add(
      pw.TableRow(
        children: [
          pw.Container(
            padding: cellPadding,
            child: pw.Text('4.', style: contentTextStyle),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text('', style: contentTextStyle),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text(':', style: contentTextStyle),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text('', style: contentTextStyle),
          ),
        ],
      ),
    );
    rows.add(
      pw.TableRow(
        children: [
          pw.Container(
            padding: cellPadding,
            child: pw.Text('5.', style: contentTextStyle),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text('', style: contentTextStyle),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text(':', style: contentTextStyle),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text('', style: contentTextStyle),
          ),
        ],
      ),
    );
    rows.add(
      pw.TableRow(
        children: [
          pw.Container(padding: cellPadding, child: pw.Text('')),
          pw.Container(
            padding: cellPadding,
            child: pw.Text('Total', style: headerTextStyle),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text(':', style: headerTextStyle),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text(
              _amenitiesTotalController.text,
              style: contentTextStyle,
            ),
          ),
        ],
      ),
    );

    return rows;
  }

  // page - 5 (new format)(Specifications of construction (floor-wise) in respect of)

  List<pw.TableRow> _getSpecificationsTableRows() {
    final pw.TextStyle headerTextStyle = pw.TextStyle(
      fontWeight: pw.FontWeight.bold,
      fontSize: 11,
    );
    const pw.TextStyle contentTextStyle = pw.TextStyle(fontSize: 11);
    const pw.EdgeInsets cellPadding = pw.EdgeInsets.all(3);

    List<pw.TableRow> rows = [];

    // Table Header Row
    rows.add(
      pw.TableRow(
        children: [
          pw.Container(
              padding: cellPadding,
              child: pw.Text('S. No.', style: headerTextStyle)),
          pw.Container(
              padding: cellPadding,
              child: pw.Text('Description', style: headerTextStyle)),
          pw.Container(
              padding: cellPadding,
              child: pw.Text('Ground floor', style: headerTextStyle)),
          pw.Container(
              padding: cellPadding,
              child: pw.Text('Other floors', style: headerTextStyle)),
        ],
      ),
    );

    // 1. Foundation
    rows.add(
      pw.TableRow(
        children: [
          pw.Container(
              padding: cellPadding,
              child: pw.Text('1.', style: contentTextStyle)),
          pw.Container(
              padding: cellPadding,
              child: pw.Text('Foundation', style: contentTextStyle)),
          pw.Container(
              padding: cellPadding,
              child: pw.Text(_foundationGroundController.text,
                  style: contentTextStyle)),
          pw.Container(
              padding: cellPadding,
              child: pw.Text(_foundationOtherController.text,
                  style: contentTextStyle)),
        ],
      ),
    );

    // 2. Basement
    rows.add(
      pw.TableRow(
        children: [
          pw.Container(
              padding: cellPadding,
              child: pw.Text('2.', style: contentTextStyle)),
          pw.Container(
              padding: cellPadding,
              child: pw.Text('Basement', style: contentTextStyle)),
          pw.Container(
              padding: cellPadding,
              child: pw.Text(_basementGroundController.text,
                  style: contentTextStyle)),
          pw.Container(
              padding: cellPadding,
              child: pw.Text(_basementOtherController.text,
                  style: contentTextStyle)),
        ],
      ),
    );

    // 3. Superstructure
    rows.add(
      pw.TableRow(
        children: [
          pw.Container(
              padding: cellPadding,
              child: pw.Text('3.', style: contentTextStyle)),
          pw.Container(
              padding: cellPadding,
              child: pw.Text('Superstructure', style: contentTextStyle)),
          pw.Container(
              padding: cellPadding,
              child: pw.Text(_superstructureGroundController.text,
                  style: contentTextStyle)),
          pw.Container(
              padding: cellPadding,
              child: pw.Text(_superstructureOtherController.text,
                  style: contentTextStyle)),
        ],
      ),
    );

    // 4. Joinery/Doors & Windows
    rows.add(
      pw.TableRow(
        children: [
          pw.Container(
              padding: cellPadding,
              child: pw.Text('4.', style: contentTextStyle)),
          pw.Container(
            padding: cellPadding,
            child: pw.Text(
              'Joinery/Doors & Windows (please furnish details about size of frames, shutters, glazing, fitting etc. and specify the species of timber)',
              style: contentTextStyle,
            ),
          ),
          pw.Container(
              padding: cellPadding,
              child: pw.Text(_joineryGroundController.text,
                  style: contentTextStyle)),
          pw.Container(
              padding: cellPadding,
              child: pw.Text(_joineryOtherController.text,
                  style: contentTextStyle)),
        ],
      ),
    );

    // 5. RCC works
    rows.add(
      pw.TableRow(
        children: [
          pw.Container(
              padding: cellPadding,
              child: pw.Text('5.', style: contentTextStyle)),
          pw.Container(
              padding: cellPadding,
              child: pw.Text('RCC works', style: contentTextStyle)),
          pw.Container(
              padding: cellPadding,
              child: pw.Text(_rccWorksGroundController.text,
                  style: contentTextStyle)),
          pw.Container(
              padding: cellPadding,
              child: pw.Text(_rccWorksOtherController.text,
                  style: contentTextStyle)),
        ],
      ),
    );

    // 6. Plastering
    rows.add(
      pw.TableRow(
        children: [
          pw.Container(
              padding: cellPadding,
              child: pw.Text('6.', style: contentTextStyle)),
          pw.Container(
              padding: cellPadding,
              child: pw.Text('Plastering', style: contentTextStyle)),
          pw.Container(
              padding: cellPadding,
              child: pw.Text(_plasteringGroundController.text,
                  style: contentTextStyle)),
          pw.Container(
              padding: cellPadding,
              child: pw.Text(_plasteringOtherController.text,
                  style: contentTextStyle)),
        ],
      ),
    );

    // 7. Flooring, Skirting, dadoing
    rows.add(
      pw.TableRow(
        children: [
          pw.Container(
              padding: cellPadding,
              child: pw.Text('7.', style: contentTextStyle)),
          pw.Container(
              padding: cellPadding,
              child: pw.Text('Flooring, Skirting, dadoing',
                  style: contentTextStyle)),
          pw.Container(
              padding: cellPadding,
              child: pw.Text(_flooringGroundController.text,
                  style: contentTextStyle)),
          pw.Container(
              padding: cellPadding,
              child: pw.Text(_flooringOtherController.text,
                  style: contentTextStyle)),
        ],
      ),
    );

    // 8. Special finish
    rows.add(
      pw.TableRow(
        children: [
          pw.Container(
              padding: cellPadding,
              child: pw.Text('8.', style: contentTextStyle)),
          pw.Container(
            padding: cellPadding,
            child: pw.Text(
              'Special finish as marble, granite, wooden paneling, grills, etc',
              style: contentTextStyle,
            ),
          ),
          pw.Container(
              padding: cellPadding,
              child: pw.Text(_specialFinishGroundController.text,
                  style: contentTextStyle)),
          pw.Container(
              padding: cellPadding,
              child: pw.Text(_specialFinishOtherController.text,
                  style: contentTextStyle)),
        ],
      ),
    );

    // 9. Roofing including weather proof course
    rows.add(
      pw.TableRow(
        children: [
          pw.Container(
              padding: cellPadding,
              child: pw.Text('9.', style: contentTextStyle)),
          pw.Container(
              padding: cellPadding,
              child: pw.Text('Roofing including weather proof course',
                  style: contentTextStyle)),
          pw.Container(
              padding: cellPadding,
              child: pw.Text(_roofingGroundController.text,
                  style: contentTextStyle)),
          pw.Container(
              padding: cellPadding,
              child: pw.Text(_roofingOtherController.text,
                  style: contentTextStyle)),
        ],
      ),
    );

    // 10. Drainage
    rows.add(
      pw.TableRow(
        children: [
          pw.Container(
              padding: cellPadding,
              child: pw.Text('10.', style: contentTextStyle)),
          pw.Container(
              padding: cellPadding,
              child: pw.Text('Drainage', style: contentTextStyle)),
          pw.Container(
              padding: cellPadding,
              child: pw.Text(_drainageGroundController.text,
                  style: contentTextStyle)),
          pw.Container(
              padding: cellPadding,
              child: pw.Text(_drainageOtherController.text,
                  style: contentTextStyle)),
        ],
      ),
    );

    // 11. No of Kitchen
    rows.add(
      pw.TableRow(
        children: [
          pw.Container(
              padding: cellPadding,
              child: pw.Text('11.', style: contentTextStyle)),
          pw.Container(
              padding: cellPadding,
              child: pw.Text('No of Kitchen', style: contentTextStyle)),
          pw.Container(
              padding: cellPadding,
              child: pw.Text(_kitchenGroundController.text,
                  style: contentTextStyle)),
          pw.Container(
              padding: cellPadding,
              child: pw.Text(_kitchenOtherController.text,
                  style: contentTextStyle)),
        ],
      ),
    );

    return rows;
  }

  //page 5 (second table)
  List<pw.TableRow> _getAdditionalSpecificationsTableRows() {
    final pw.TextStyle headerTextStyle = pw.TextStyle(
      fontWeight: pw.FontWeight.bold,
      fontSize: 11,
    );
    const pw.TextStyle contentTextStyle = pw.TextStyle(fontSize: 11);
    const pw.EdgeInsets cellPadding = pw.EdgeInsets.all(3);

    List<pw.TableRow> rows = [];

    // Table Header Row
    rows.add(
      pw.TableRow(
        children: [
          pw.Container(
              padding: cellPadding,
              child: pw.Text('S. No.', style: headerTextStyle)),
          pw.Container(
              padding: cellPadding,
              child: pw.Text('Description', style: headerTextStyle)),
          pw.Container(
              padding: cellPadding,
              child: pw.Text('Ground floor', style: headerTextStyle)),
          pw.Container(
              padding: cellPadding,
              child: pw.Text('Other floors', style: headerTextStyle)),
        ],
      ),
    );

    // 2. Compound Wall
    rows.add(
      pw.TableRow(
        children: [
          pw.Container(
              padding: cellPadding,
              child: pw.Text('2.', style: contentTextStyle)),
          pw.Container(
              padding: cellPadding,
              child: pw.Text('Compound wall', style: contentTextStyle)),
          pw.Container(
              padding: cellPadding,
              child: pw.Text(_compoundWallGroundController.text,
                  style: contentTextStyle)),
          pw.Container(
              padding: cellPadding,
              child: pw.Text(_compoundWallOtherController.text,
                  style: contentTextStyle)),
        ],
      ),
    );
    rows.add(
      pw.TableRow(
        children: [
          pw.Container(
              padding: cellPadding,
              child: pw.Text(':', style: contentTextStyle)),
          pw.Container(
              padding: cellPadding,
              child: pw.Text('Height', style: contentTextStyle)),
          pw.Container(
              padding: cellPadding,
              child: pw.Text(_cwHeightGroundController.text,
                  style: contentTextStyle)),
          pw.Container(
              padding: cellPadding,
              child: pw.Text(_cwHeightOtherController.text,
                  style: contentTextStyle)),
        ],
      ),
    );
    rows.add(
      pw.TableRow(
        children: [
          pw.Container(
              padding: cellPadding,
              child: pw.Text(':', style: contentTextStyle)),
          pw.Container(
              padding: cellPadding,
              child: pw.Text('Length', style: contentTextStyle)),
          pw.Container(
              padding: cellPadding,
              child: pw.Text(_cwLengthGroundController.text,
                  style: contentTextStyle)),
          pw.Container(
              padding: cellPadding,
              child: pw.Text(_cwLengthOtherController.text,
                  style: contentTextStyle)),
        ],
      ),
    );
    rows.add(
      pw.TableRow(
        children: [
          pw.Container(
              padding: cellPadding,
              child: pw.Text('', style: contentTextStyle)),
          pw.Container(
              padding: cellPadding,
              child: pw.Text('Type of construction', style: contentTextStyle)),
          pw.Container(
              padding: cellPadding,
              child: pw.Text(_cwTypeGroundController.text,
                  style: contentTextStyle)),
          pw.Container(
              padding: cellPadding,
              child: pw.Text(_cwTypeOtherController.text,
                  style: contentTextStyle)),
        ],
      ),
    );

    // 3. Electrical Installation
    rows.add(
      pw.TableRow(
        children: [
          pw.Container(
              padding: cellPadding,
              child: pw.Text('3.', style: contentTextStyle)),
          pw.Container(
              padding: cellPadding,
              child:
                  pw.Text('Electrical installation', style: contentTextStyle)),
          pw.Container(
              padding: cellPadding,
              child: pw.Text('', style: contentTextStyle)),
          pw.Container(
              padding: cellPadding,
              child: pw.Text('', style: contentTextStyle)),
        ],
      ),
    );
    rows.add(
      pw.TableRow(
        children: [
          pw.Container(
              padding: cellPadding,
              child: pw.Text(':', style: contentTextStyle)),
          pw.Container(
              padding: cellPadding,
              child: pw.Text('Type of wiring', style: contentTextStyle)),
          pw.Container(
              padding: cellPadding,
              child: pw.Text(_elecWiringGroundController.text,
                  style: contentTextStyle)),
          pw.Container(
              padding: cellPadding,
              child: pw.Text(_elecWiringOtherController.text,
                  style: contentTextStyle)),
        ],
      ),
    );
    rows.add(
      pw.TableRow(
        children: [
          pw.Container(
              padding: cellPadding,
              child: pw.Text(':', style: contentTextStyle)),
          pw.Container(
              padding: cellPadding,
              child: pw.Text('Class of fittings (superior / ordinary / poor)',
                  style: contentTextStyle)),
          pw.Container(
              padding: cellPadding,
              child: pw.Text(_elecFittingsGroundController.text,
                  style: contentTextStyle)),
          pw.Container(
              padding: cellPadding,
              child: pw.Text(_elecFittingsOtherController.text,
                  style: contentTextStyle)),
        ],
      ),
    );
    rows.add(
      pw.TableRow(
        children: [
          pw.Container(
              padding: cellPadding,
              child: pw.Text(':', style: contentTextStyle)),
          pw.Container(
              padding: cellPadding,
              child:
                  pw.Text('Number of light points', style: contentTextStyle)),
          pw.Container(
              padding: cellPadding,
              child: pw.Text(_elecLightPointsGroundController.text,
                  style: contentTextStyle)),
          pw.Container(
              padding: cellPadding,
              child: pw.Text(_elecLightPointsOtherController.text,
                  style: contentTextStyle)),
        ],
      ),
    );
    rows.add(
      pw.TableRow(
        children: [
          pw.Container(
              padding: cellPadding,
              child: pw.Text(':', style: contentTextStyle)),
          pw.Container(
              padding: cellPadding,
              child: pw.Text('Fan points', style: contentTextStyle)),
          pw.Container(
              padding: cellPadding,
              child: pw.Text(_elecFanPointsGroundController.text,
                  style: contentTextStyle)),
          pw.Container(
              padding: cellPadding,
              child: pw.Text(_elecFanPointsOtherController.text,
                  style: contentTextStyle)),
        ],
      ),
    );
    rows.add(
      pw.TableRow(
        children: [
          pw.Container(
              padding: cellPadding,
              child: pw.Text(':', style: contentTextStyle)),
          pw.Container(
              padding: cellPadding,
              child: pw.Text('Spare plug points', style: contentTextStyle)),
          pw.Container(
              padding: cellPadding,
              child: pw.Text(_elecPlugPointsGroundController.text,
                  style: contentTextStyle)),
          pw.Container(
              padding: cellPadding,
              child: pw.Text(_elecPlugPointsOtherController.text,
                  style: contentTextStyle)),
        ],
      ),
    );
    rows.add(
      pw.TableRow(
        children: [
          pw.Container(
              padding: cellPadding,
              child: pw.Text('', style: contentTextStyle)),
          pw.Container(
              padding: cellPadding,
              child: pw.Text('Any other item.', style: contentTextStyle)),
          pw.Container(
              padding: cellPadding,
              child: pw.Text(_elecOtherGroundController.text,
                  style: contentTextStyle)),
          pw.Container(
              padding: cellPadding,
              child: pw.Text(_elecOtherOtherController.text,
                  style: contentTextStyle)),
        ],
      ),
    );

    // 4. Plumbing Installation
    rows.add(
      pw.TableRow(
        children: [
          pw.Container(
              padding: cellPadding,
              child: pw.Text('4.', style: contentTextStyle)),
          pw.Container(
              padding: cellPadding,
              child: pw.Text('Plumbing installation', style: contentTextStyle)),
          pw.Container(
              padding: cellPadding,
              child: pw.Text('', style: contentTextStyle)),
          pw.Container(
              padding: cellPadding,
              child: pw.Text('', style: contentTextStyle)),
        ],
      ),
    );
    rows.add(
      pw.TableRow(
        children: [
          pw.Container(
              padding: cellPadding,
              child: pw.Text('a)', style: contentTextStyle)),
          pw.Container(
              padding: cellPadding,
              child: pw.Text('No. of water closets and their type',
                  style: contentTextStyle)),
          pw.Container(
              padding: cellPadding,
              child: pw.Text(_plumClosetsGroundController.text,
                  style: contentTextStyle)),
          pw.Container(
              padding: cellPadding,
              child: pw.Text(_plumClosetsOtherController.text,
                  style: contentTextStyle)),
        ],
      ),
    );
    rows.add(
      pw.TableRow(
        children: [
          pw.Container(
              padding: cellPadding,
              child: pw.Text('b)', style: contentTextStyle)),
          pw.Container(
              padding: cellPadding,
              child: pw.Text('No. of wash basins', style: contentTextStyle)),
          pw.Container(
              padding: cellPadding,
              child: pw.Text(_plumBasinsGroundController.text,
                  style: contentTextStyle)),
          pw.Container(
              padding: cellPadding,
              child: pw.Text(_plumBasinsOtherController.text,
                  style: contentTextStyle)),
        ],
      ),
    );
    rows.add(
      pw.TableRow(
        children: [
          pw.Container(
              padding: cellPadding,
              child: pw.Text('c)', style: contentTextStyle)),
          pw.Container(
              padding: cellPadding,
              child: pw.Text('No. of urinals', style: contentTextStyle)),
          pw.Container(
              padding: cellPadding,
              child: pw.Text(_plumUrinalsGroundController.text,
                  style: contentTextStyle)),
          pw.Container(
              padding: cellPadding,
              child: pw.Text(_plumUrinalsOtherController.text,
                  style: contentTextStyle)),
        ],
      ),
    );
    rows.add(
      pw.TableRow(
        children: [
          pw.Container(
              padding: cellPadding,
              child: pw.Text('d)', style: contentTextStyle)),
          pw.Container(
              padding: cellPadding,
              child: pw.Text('No. of bath tubs', style: contentTextStyle)),
          pw.Container(
              padding: cellPadding,
              child: pw.Text(_plumTubsGroundController.text,
                  style: contentTextStyle)),
          pw.Container(
              padding: cellPadding,
              child: pw.Text(_plumTubsOtherController.text,
                  style: contentTextStyle)),
        ],
      ),
    );
    rows.add(
      pw.TableRow(
        children: [
          pw.Container(
              padding: cellPadding,
              child: pw.Text('e)', style: contentTextStyle)),
          pw.Container(
              padding: cellPadding,
              child:
                  pw.Text('Water meter, taps, etc.', style: contentTextStyle)),
          pw.Container(
              padding: cellPadding,
              child: pw.Text(_plumMetersGroundController.text,
                  style: contentTextStyle)),
          pw.Container(
              padding: cellPadding,
              child: pw.Text(_plumMetersOtherController.text,
                  style: contentTextStyle)),
        ],
      ),
    );
    rows.add(
      pw.TableRow(
        children: [
          pw.Container(
              padding: cellPadding,
              child: pw.Text('f)', style: contentTextStyle)),
          pw.Container(
              padding: cellPadding,
              child: pw.Text('Any other fixtures', style: contentTextStyle)),
          pw.Container(
              padding: cellPadding,
              child: pw.Text(_plumFixturesGroundController.text,
                  style: contentTextStyle)),
          pw.Container(
              padding: cellPadding,
              child: pw.Text(_plumFixturesOtherController.text,
                  style: contentTextStyle)),
        ],
      ),
    );

    return rows;
  }

  //page - 6(table - 1 new format)
  List<pw.TableRow> _getValuationTableRows() {
    final pw.TextStyle headerTextStyle =
        pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9);
    const pw.TextStyle contentTextStyle = pw.TextStyle(fontSize: 9);
    const pw.EdgeInsets cellPadding = pw.EdgeInsets.all(3);

    return [
      // Table Header
      pw.TableRow(
        children: [
          pw.Container(
              padding: cellPadding,
              child: pw.Text('Sr. no.', style: headerTextStyle)),
          pw.Container(
              padding: cellPadding,
              child: pw.Text('Particulars of item', style: headerTextStyle)),
          pw.Container(
              padding: cellPadding,
              child: pw.Text('Plinth area (Sqft)', style: headerTextStyle)),
          pw.Container(
              padding: cellPadding,
              child: pw.Text('Roof height', style: headerTextStyle)),
          pw.Container(
              padding: cellPadding,
              child: pw.Text('Age of building', style: headerTextStyle)),
          pw.Container(
              padding: cellPadding,
              child: pw.Text('Estimated replacement rate per sqft',
                  style: headerTextStyle)),
          pw.Container(
              padding: cellPadding,
              child: pw.Text('Replacement cost Rs.', style: headerTextStyle)),
          pw.Container(
              padding: cellPadding,
              child: pw.Text('Depreciation Rs.', style: headerTextStyle)),
          pw.Container(
              padding: cellPadding,
              child: pw.Text('Net value after depreciation',
                  style: headerTextStyle)),
        ],
      ),
      // Row 1: GF
      pw.TableRow(
        children: [
          pw.Container(
              padding: cellPadding,
              child: pw.Text('1', style: contentTextStyle)),
          pw.Container(
              padding: cellPadding,
              child: pw.Text('GF', style: contentTextStyle)),
          pw.Container(
              padding: cellPadding,
              child: pw.Text(_valPlinthGFController.text,
                  style: contentTextStyle)),
          pw.Container(
              padding: cellPadding,
              child: pw.Text(_valRoofHeightGFController.text,
                  style: contentTextStyle)),
          pw.Container(
              padding: cellPadding,
              child:
                  pw.Text(_valAgeGFController.text, style: contentTextStyle)),
          pw.Container(
              padding: cellPadding,
              child:
                  pw.Text(_valRateGFController.text, style: contentTextStyle)),
          pw.Container(
              padding: cellPadding,
              child: pw.Text(_valReplaceCostGFController.text,
                  style: contentTextStyle)),
          pw.Container(
              padding: cellPadding,
              child: pw.Text(_valDepreciationGFController.text,
                  style: contentTextStyle)),
          pw.Container(
              padding: cellPadding,
              child: pw.Text(_valNetValueGFController.text,
                  style: contentTextStyle)),
        ],
      ),
      // Row 2: FF
      pw.TableRow(
        children: [
          pw.Container(
              padding: cellPadding,
              child: pw.Text('2', style: contentTextStyle)),
          pw.Container(
              padding: cellPadding,
              child: pw.Text('FF', style: contentTextStyle)),
          pw.Container(
              padding: cellPadding,
              child: pw.Text(_valPlinthFFController.text,
                  style: contentTextStyle)),
          pw.Container(
              padding: cellPadding,
              child: pw.Text(_valRoofHeightFFController.text,
                  style: contentTextStyle)),
          pw.Container(
              padding: cellPadding,
              child:
                  pw.Text(_valAgeFFController.text, style: contentTextStyle)),
          pw.Container(
              padding: cellPadding,
              child:
                  pw.Text(_valRateFFController.text, style: contentTextStyle)),
          pw.Container(
              padding: cellPadding,
              child: pw.Text(_valReplaceCostFFController.text,
                  style: contentTextStyle)),
          pw.Container(
              padding: cellPadding,
              child: pw.Text(_valDepreciationFFController.text,
                  style: contentTextStyle)),
          pw.Container(
              padding: cellPadding,
              child: pw.Text(_valNetValueFFController.text,
                  style: contentTextStyle)),
        ],
      ),
      // Total Row
      pw.TableRow(
        children: [
          pw.Container(
              padding: cellPadding,
              child: pw.Text('', style: contentTextStyle)),
          pw.Container(
              padding: cellPadding,
              child: pw.Text('Total', style: headerTextStyle)),
          pw.Container(
              padding: cellPadding,
              child: pw.Text(_valTotalPlinthController.text,
                  style: contentTextStyle)),
          pw.Container(
              padding: cellPadding,
              child: pw.Text('', style: contentTextStyle)),
          pw.Container(
              padding: cellPadding,
              child: pw.Text('', style: contentTextStyle)),
          pw.Container(
              padding: cellPadding,
              child: pw.Text('', style: contentTextStyle)),
          pw.Container(
              padding: cellPadding,
              child: pw.Text(_valTotalReplaceCostController.text,
                  style: contentTextStyle)),
          pw.Container(
              padding: cellPadding,
              child: pw.Text(_valTotalDepreciationController.text,
                  style: contentTextStyle)),
          pw.Container(
              padding: cellPadding,
              child: pw.Text(_valTotalNetValueController.text,
                  style: contentTextStyle)),
        ],
      ),
    ];
  }

  List<pw.TableRow> _getExtraItemsTableRows() {
    final pw.TextStyle headerTextStyle =
        pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9);
    const pw.TextStyle contentTextStyle = pw.TextStyle(fontSize: 9);
    const pw.EdgeInsets cellPadding = pw.EdgeInsets.all(3);

    return [
      pw.TableRow(children: [
        pw.Padding(
            padding: cellPadding,
            child: pw.Text('1.', style: contentTextStyle)),
        pw.Padding(
            padding: cellPadding,
            child: pw.Text('Portico', style: contentTextStyle)),
        pw.Padding(
            padding: cellPadding, child: pw.Text(':', style: contentTextStyle)),
        pw.Padding(
            padding: cellPadding,
            child:
                pw.Text(_extraPorticoController.text, style: contentTextStyle)),
      ]),
      pw.TableRow(children: [
        pw.Padding(
            padding: cellPadding,
            child: pw.Text('2.', style: contentTextStyle)),
        pw.Padding(
            padding: cellPadding,
            child: pw.Text('Ornamental front door', style: contentTextStyle)),
        pw.Padding(
            padding: cellPadding, child: pw.Text(':', style: contentTextStyle)),
        pw.Padding(
            padding: cellPadding,
            child: pw.Text(_extraOrnamentalDoorController.text,
                style: contentTextStyle)),
      ]),
      pw.TableRow(children: [
        pw.Padding(
            padding: cellPadding,
            child: pw.Text('3.', style: contentTextStyle)),
        pw.Padding(
            padding: cellPadding,
            child: pw.Text('Sit out/ Verandah with steel grills',
                style: contentTextStyle)),
        pw.Padding(
            padding: cellPadding, child: pw.Text(':', style: contentTextStyle)),
        pw.Padding(
            padding: cellPadding,
            child:
                pw.Text(_extraSitoutController.text, style: contentTextStyle)),
      ]),
      pw.TableRow(children: [
        pw.Padding(
            padding: cellPadding,
            child: pw.Text('4.', style: contentTextStyle)),
        pw.Padding(
            padding: cellPadding,
            child: pw.Text('Overhead water tank', style: contentTextStyle)),
        pw.Padding(
            padding: cellPadding, child: pw.Text(':', style: contentTextStyle)),
        pw.Padding(
            padding: cellPadding,
            child: pw.Text(_extraWaterTankController.text,
                style: contentTextStyle)),
      ]),
      pw.TableRow(children: [
        pw.Padding(
            padding: cellPadding,
            child: pw.Text('5.', style: contentTextStyle)),
        pw.Padding(
            padding: cellPadding,
            child: pw.Text('Extra steel/ collapsible gates',
                style: contentTextStyle)),
        pw.Padding(
            padding: cellPadding, child: pw.Text(':', style: contentTextStyle)),
        pw.Padding(
            padding: cellPadding,
            child: pw.Text(_extraSteelGatesController.text,
                style: contentTextStyle)),
      ]),
      pw.TableRow(children: [
        pw.Padding(
            padding: cellPadding, child: pw.Text('', style: contentTextStyle)),
        pw.Padding(
            padding: cellPadding,
            child: pw.Text('Total', style: headerTextStyle)),
        pw.Padding(
            padding: cellPadding, child: pw.Text(':', style: headerTextStyle)),
        pw.Padding(
            padding: cellPadding,
            child: pw.Text(_extraTotalController.text, style: headerTextStyle)),
      ]),
    ];
  }

  List<pw.TableRow> _getAmenitiesTableRows2() {
    final pw.TextStyle headerTextStyle =
        pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9);
    const pw.TextStyle contentTextStyle = pw.TextStyle(fontSize: 9);
    const pw.EdgeInsets cellPadding = pw.EdgeInsets.all(3);

    final List<List<String>> items = [
      ['1.', 'Wardrobes', _amenWardrobesController.text],
      ['2.', 'Glazed tiles', _amenGlazedTilesController.text],
      ['3.', 'Extra sinks and bath tub', _amenSinksTubsController.text],
      ['4.', 'Marble / Ceramic tiles flooring', _amenFlooringController.text],
      ['5.', 'Interior decorations', _amenDecorationsController.text],
      ['6.', 'Architectural elevation works', _amenElevationController.text],
      ['7.', 'Panelling works', _amenPanellingController.text],
      ['8.', 'Aluminium works', _amenAluminiumWorksController.text],
      ['9.', 'Aluminium hand rails', _amenHandRailsController.text],
      ['10.', 'False ceiling', _amenFalseCeilingController.text],
    ];

    return [
      ...items.map((item) => pw.TableRow(children: [
            pw.Padding(
                padding: cellPadding,
                child: pw.Text(item[0], style: contentTextStyle)),
            pw.Padding(
                padding: cellPadding,
                child: pw.Text(item[1], style: contentTextStyle)),
            pw.Padding(
                padding: cellPadding,
                child: pw.Text(':', style: contentTextStyle)),
            pw.Padding(
                padding: cellPadding,
                child: pw.Text(item[2], style: contentTextStyle)),
          ])),
      pw.TableRow(children: [
        pw.Padding(
            padding: cellPadding, child: pw.Text('', style: contentTextStyle)),
        pw.Padding(
            padding: cellPadding,
            child: pw.Text('Total', style: headerTextStyle)),
        pw.Padding(
            padding: cellPadding, child: pw.Text(':', style: headerTextStyle)),
        pw.Padding(
            padding: cellPadding,
            child: pw.Text(_amenTotalController.text, style: headerTextStyle)),
      ]),
    ];
  }

  List<pw.TableRow> _getMiscTableRows() {
    final pw.TextStyle headerTextStyle =
        pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9);
    const pw.TextStyle contentTextStyle = pw.TextStyle(fontSize: 9);
    const pw.EdgeInsets cellPadding = pw.EdgeInsets.all(3);

    return [
      pw.TableRow(children: [
        pw.Padding(
            padding: cellPadding,
            child: pw.Text('1.', style: contentTextStyle)),
        pw.Padding(
            padding: cellPadding,
            child: pw.Text('Separate toilet room', style: contentTextStyle)),
        pw.Padding(
            padding: cellPadding, child: pw.Text(':', style: contentTextStyle)),
        pw.Padding(
            padding: cellPadding,
            child: pw.Text(_miscToiletRoomController.text,
                style: contentTextStyle)),
      ]),
      pw.TableRow(children: [
        pw.Padding(
            padding: cellPadding,
            child: pw.Text('2.', style: contentTextStyle)),
        pw.Padding(
            padding: cellPadding,
            child: pw.Text('Separate lumber room', style: contentTextStyle)),
        pw.Padding(
            padding: cellPadding, child: pw.Text(':', style: contentTextStyle)),
        pw.Padding(
            padding: cellPadding,
            child: pw.Text(_miscLumberRoomController.text,
                style: contentTextStyle)),
      ]),
      pw.TableRow(children: [
        pw.Padding(
            padding: cellPadding,
            child: pw.Text('3.', style: contentTextStyle)),
        pw.Padding(
            padding: cellPadding,
            child:
                pw.Text('Separate water tank/ sump', style: contentTextStyle)),
        pw.Padding(
            padding: cellPadding, child: pw.Text(':', style: contentTextStyle)),
        pw.Padding(
            padding: cellPadding,
            child: pw.Text(_miscSumpController.text, style: contentTextStyle)),
      ]),
      pw.TableRow(children: [
        pw.Padding(
            padding: cellPadding,
            child: pw.Text('4.', style: contentTextStyle)),
        pw.Padding(
            padding: cellPadding,
            child: pw.Text('Trees, gardening', style: contentTextStyle)),
        pw.Padding(
            padding: cellPadding, child: pw.Text(':', style: contentTextStyle)),
        pw.Padding(
            padding: cellPadding,
            child: pw.Text(_miscGardeningController.text,
                style: contentTextStyle)),
      ]),
      pw.TableRow(children: [
        pw.Padding(
            padding: cellPadding, child: pw.Text('', style: contentTextStyle)),
        pw.Padding(
            padding: cellPadding,
            child: pw.Text('Total', style: headerTextStyle)),
        pw.Padding(
            padding: cellPadding, child: pw.Text(':', style: headerTextStyle)),
        pw.Padding(
            padding: cellPadding,
            child: pw.Text(_miscTotalController.text, style: headerTextStyle)),
      ]),
    ];
  }

  List<pw.TableRow> _getServicesTableRows() {
    final pw.TextStyle headerTextStyle =
        pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9);
    const pw.TextStyle contentTextStyle = pw.TextStyle(fontSize: 9);
    const pw.EdgeInsets cellPadding = pw.EdgeInsets.all(3);

    return [
      pw.TableRow(children: [
        pw.Padding(
            padding: cellPadding,
            child: pw.Text('1.', style: contentTextStyle)),
        pw.Padding(
            padding: cellPadding,
            child:
                pw.Text('Water supply arrangements', style: contentTextStyle)),
        pw.Padding(
            padding: cellPadding, child: pw.Text(':', style: contentTextStyle)),
        pw.Padding(
            padding: cellPadding,
            child: pw.Text(_servWaterSupplyController.text,
                style: contentTextStyle)),
      ]),
      pw.TableRow(children: [
        pw.Padding(
            padding: cellPadding,
            child: pw.Text('2.', style: contentTextStyle)),
        pw.Padding(
            padding: cellPadding,
            child: pw.Text('Drainage arrangements', style: contentTextStyle)),
        pw.Padding(
            padding: cellPadding, child: pw.Text(':', style: contentTextStyle)),
        pw.Padding(
            padding: cellPadding,
            child:
                pw.Text(_servDrainageController.text, style: contentTextStyle)),
      ]),
      pw.TableRow(children: [
        pw.Padding(
            padding: cellPadding,
            child: pw.Text('3.', style: contentTextStyle)),
        pw.Padding(
            padding: cellPadding,
            child: pw.Text('Compound wall', style: contentTextStyle)),
        pw.Padding(
            padding: cellPadding, child: pw.Text(':', style: contentTextStyle)),
        pw.Padding(
            padding: cellPadding,
            child: pw.Text(_servCompoundWallController.text,
                style: contentTextStyle)),
      ]),
      pw.TableRow(children: [
        pw.Padding(
            padding: cellPadding,
            child: pw.Text('4.', style: contentTextStyle)),
        pw.Padding(
            padding: cellPadding,
            child: pw.Text('C. B. deposits, fittings etc.',
                style: contentTextStyle)),
        pw.Padding(
            padding: cellPadding, child: pw.Text(':', style: contentTextStyle)),
        pw.Padding(
            padding: cellPadding,
            child:
                pw.Text(_servDepositsController.text, style: contentTextStyle)),
      ]),
      pw.TableRow(children: [
        pw.Padding(
            padding: cellPadding,
            child: pw.Text('5.', style: contentTextStyle)),
        pw.Padding(
            padding: cellPadding,
            child: pw.Text('Pavement', style: contentTextStyle)),
        pw.Padding(
            padding: cellPadding, child: pw.Text(':', style: contentTextStyle)),
        pw.Padding(
            padding: cellPadding,
            child:
                pw.Text(_servPavementController.text, style: contentTextStyle)),
      ]),
      pw.TableRow(children: [
        pw.Padding(
            padding: cellPadding, child: pw.Text('', style: contentTextStyle)),
        pw.Padding(
            padding: cellPadding,
            child: pw.Text('Total', style: headerTextStyle)),
        pw.Padding(
            padding: cellPadding, child: pw.Text(':', style: headerTextStyle)),
        pw.Padding(
            padding: cellPadding,
            child: pw.Text(_servTotalController.text, style: headerTextStyle)),
      ]),
    ];
  }

  // NEW: Helper function to get table rows for "Total abstract of the entire property"
  List<pw.TableRow> _page7() {
    final pw.TextStyle headerTextStyle = pw.TextStyle(
      fontWeight: pw.FontWeight.bold,
      fontSize: 11,
    );
    const pw.TextStyle contentTextStyle = pw.TextStyle(fontSize: 11);
    const pw.EdgeInsets cellPadding = pw.EdgeInsets.all(3);

    List<pw.TableRow> rows = [];

    rows.add(
      pw.TableRow(
        children: [
          pw.Container(
            padding: cellPadding,
            child: pw.Text('Part- A', style: contentTextStyle),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text('Land', style: contentTextStyle),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text(':', style: contentTextStyle),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text(
              'Rs ${_totalAbstractLandController.text}',
              style: contentTextStyle,
            ),
          ),
        ],
      ),
    );
    rows.add(
      pw.TableRow(
        children: [
          pw.Container(
            padding: cellPadding,
            child: pw.Text('Part- B', style: contentTextStyle),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text('Building', style: contentTextStyle),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text(':', style: contentTextStyle),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text(
              'Rs ${_totalAbstractBuildingController.text}',
              style: contentTextStyle,
            ),
          ),
        ],
      ),
    );
    rows.add(
      pw.TableRow(
        children: [
          pw.Container(
            padding: cellPadding,
            child: pw.Text('Part- C', style: contentTextStyle),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text('Extra Items', style: contentTextStyle),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text(':', style: contentTextStyle),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text(
              'Rs ${_totalAbstractExtraItemsController.text}',
              style: contentTextStyle,
            ),
          ),
        ],
      ),
    );
    rows.add(
      pw.TableRow(
        children: [
          pw.Container(
            padding: cellPadding,
            child: pw.Text('Part- D', style: contentTextStyle),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text('Amenities', style: contentTextStyle),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text(':', style: contentTextStyle),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text(
              'Rs ${_totalAbstractAmenitiesController.text}',
              style: contentTextStyle,
            ),
          ),
        ],
      ),
    );
    rows.add(
      pw.TableRow(
        children: [
          pw.Container(
            padding: cellPadding,
            child: pw.Text('Part- E', style: contentTextStyle),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text('Miscellaneous', style: contentTextStyle),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text(':', style: contentTextStyle),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text(
              'Rs ${_totalAbstractMiscController.text}',
              style: contentTextStyle,
            ),
          ),
        ],
      ),
    );
    rows.add(
      pw.TableRow(
        children: [
          pw.Container(
            padding: cellPadding,
            child: pw.Text('Part- F', style: contentTextStyle),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text('Services', style: contentTextStyle),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text(':', style: contentTextStyle),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text(
              'Rs ${_totalAbstractServiceController.text}',
              style: contentTextStyle,
            ),
          ),
        ],
      ),
    );

    return rows;
  }

  // NEW: Helper function to get table rows for the final valuation table
  List<pw.TableRow> _getFinalValuationTableRows() {
    const pw.TextStyle contentTextStyle = pw.TextStyle(fontSize: 11);
    const pw.EdgeInsets cellPadding = pw.EdgeInsets.all(3);

    List<pw.TableRow> rows = [];

    rows.add(
      pw.TableRow(
        children: [
          pw.Container(
            padding: cellPadding,
            child: pw.Text(
              'Present Market Value of The Property',
              style: contentTextStyle,
            ),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text(
              'Rs. ${_presentMarketValueController.text}',
              style: contentTextStyle,
            ),
          ),
        ],
      ),
    );
    rows.add(
      pw.TableRow(
        children: [
          pw.Container(
            padding: cellPadding,
            child: pw.Text(
              'Realizable Value of the Property',
              style: contentTextStyle,
            ),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text(
              'Rs. ${_realizableValueController.text}',
              style: contentTextStyle,
            ),
          ),
        ],
      ),
    );
    rows.add(
      pw.TableRow(
        children: [
          pw.Container(
            padding: cellPadding,
            child: pw.Text(
              'Distress Value of the Property',
              style: contentTextStyle,
            ),
          ),
          pw.Container(
            padding: cellPadding,
            child: pw.Text(
              'Rs. ${_distressValueController.text}',
              style: contentTextStyle,
            ),
          ),
        ],
      ),
    );
    // rows.add(
    //   pw.TableRow(
    //     children: [
    //       pw.Container(
    //         padding: cellPadding,
    //         child: pw.Text(
    //           'Insurable Value of the property',
    //           style: contentTextStyle,
    //         ),
    //       ),
    //       pw.Container(
    //         padding: cellPadding,
    //         child: pw.Text(
    //           _insurableValueController.text,
    //           style: contentTextStyle,
    //         ),
    //       ),
    //     ],
    //   ),
    // );

    return rows;
  }

  // NEW: Helper function to get table rows for the Valuer Comments table
  List<pw.TableRow> _getValuerCommentsTableRows() {
    final pw.TextStyle headerTextStyle = pw.TextStyle(
      fontWeight: pw.FontWeight.bold,
      fontSize: 12,
    );
    const pw.TextStyle contentTextStyle = pw.TextStyle(
      fontSize: 10.8,
    ); // Slightly smaller font for content
    const pw.EdgeInsets cellPadding = pw.EdgeInsets.all(3);

    List<Map<String, dynamic>> data = [
      {
        'siNo': '1',
        'particulars': 'background information of the asset being valued;',
        'controller': _vcBackgroundInfoController,
      },
      {
        'siNo': '2',
        'particulars': 'purpose of valuation and appointing authority',
        'controller': _vcPurposeOfValuationController,
      },
      {
        'siNo': '3',
        'particulars':
            'identity of the valuer and any other experts involved in the valuation;',
        'controller': _vcIdentityOfValuerController,
      },
      {
        'siNo': '4',
        'particulars': 'disclosure of valuer interest or conflict, if any;',
        'controller': _vcDisclosureOfInterestController,
      },
      {
        'siNo': '5',
        'particulars':
            'date of appointment, valuation date and date of report;',
        'controller': _vcDateOfAppointmentController,
      },
      {
        'siNo': '6',
        'particulars': 'inspections and/or investigations undertaken;',
        'controller': _vcInspectionsUndertakenController,
      },
      {
        'siNo': '7',
        'particulars':
            'nature and sources of the information used or relied upon;',
        'controller': _vcNatureAndSourcesController,
      },
      {
        'siNo': '8',
        'particulars':
            'procedures adopted in carrying out the valuation and valuation standards followed;',
        'controller': _vcProceduresAdoptedController,
      },
      {
        'siNo': '9',
        'particulars': 'restrictions on use of the report, if any;',
        'controller': _vcRestrictionsOnUseController,
      },
      {
        'siNo': '10',
        'particulars':
            'major factors that were taken into account during the valuation;',
        'controller': _vcMajorFactors1Controller,
      },
      {
        'siNo': '11',
        'particulars':
            'major factors that were taken into account during the valuation;',
        'controller': _vcMajorFactors2Controller,
      },
      {
        'siNo': '12',
        'particulars':
            'Caveats, limitations and disclaimers to the extent they explain or elucidate the limitations faced by valuer, which shall not be for the purpose of limiting his responsibility for the valuation report.',
        'controller': _vcCaveatsLimitationsController,
      },
    ];

    List<pw.TableRow> rows = [];

    // Table Header
    rows.add(
      pw.TableRow(
        children: [
          pw.Container(
            padding: cellPadding,
            alignment: pw.Alignment.center,
            child: pw.Text('SI No.', style: headerTextStyle),
          ),
          pw.Container(
            padding: cellPadding,
            alignment: pw.Alignment.center,
            child: pw.Text('Particulars', style: headerTextStyle),
          ),
          pw.Container(
            padding: cellPadding,
            alignment: pw.Alignment.center,
            child: pw.Text('Valuer comment', style: headerTextStyle),
          ),
        ],
      ),
    );

    // Data Rows
    for (var item in data) {
      rows.add(
        pw.TableRow(
          children: [
            pw.Container(
              padding: cellPadding,
              child: pw.Text(item['siNo'], style: contentTextStyle),
            ),
            pw.Container(
              padding: cellPadding,
              child: pw.Text(item['particulars'], style: contentTextStyle),
            ),
            pw.Container(
              padding: cellPadding,
              child: pw.Text(item['controller'].text, style: contentTextStyle),
            ),
          ],
        ),
      );
    }
    return rows;
  }

  // Function to generate the PDF
  Future<void> _generatePdf() async {
    final pdf = pw.Document();

    // Get selected documents

    // Get table rows for each section
    final List<pw.TableRow> page1Rows = _getPage1TableRows();
    final List<pw.TableRow> page2Table1Rows = _getPage2Table1Rows();
    final List<pw.TableRow> page2Table2Rows = _getPage2Table2Rows();
    final List<pw.TableRow> page2Table2RowsHeading =
        _getPage2Table2RowsHeading();
    final List<pw.TableRow> page2Table2RowsPart2Heading =
        _getPage2Table2RowsPart2Heading();
    final List<pw.TableRow> page2Table2RowsPart2 = _getPage2Table2RowsPart2();
    final List<pw.TableRow> page2Table3Rows = _getPage2Table3Rows();
    final List<pw.TableRow> page2Table4Rows =
        _getPage2Table4Rows(); // Get rows for section 18
    final List<pw.TableRow> page2Table5Rows =
        _getPage2Table5Rows(); // Get rows for sections 19-20
    final List<pw.TableRow> page3Rows = _getPage3TableRows();
    final List<pw.TableRow> landValuationRowsHeading =
        _getLandValuationTableRowsHeading(); // Get rows for page 3
    final List<pw.TableRow> landValuationRows =
        _getLandValuationTableRows(); // NEW: Get rows for land valuation
    final List<pw.TableRow> buildingValuationRowsHeading =
        _getBuildingValuationTableRowsHeading(); // NEW: Get rows for building valuation
    final List<pw.TableRow> buildingValuationTableRowsSubHeading =
        _getBuildingValuationTableRowsSubHeading(); // NEW: Get rows for building valuation
    final List<pw.TableRow> buildingValuationRows =
        _getBuildingValuationTableRows(); // NEW: Get rows for building valuation
    final List<pw.TableRow> buildUpAreaRows =
        _getBuildUpAreaTableRows(); // NEW: Get rows for build up area table
    final List<pw.TableRow> amenitiesTableRows =
        _getAmenitiesTableRows(); // NEW: Get rows for amenities table
    // NEW: Get rows for total abstract table
    final List<pw.TableRow> finalValuationTableRows =
        _getFinalValuationTableRows(); // NEW: Get rows for final valuation table
    final List<pw.TableRow> valuerCommentsTableRows =
        _getValuerCommentsTableRows(); // NEW: Get rows for valuer comments table

    final List<pw.TableRow> page7 = _page7();

    // page - 5(new format)
    final List<pw.TableRow> getSpecificationsTableRows =
        _getSpecificationsTableRows();
    final List<pw.TableRow> getAdditionalSpecificationsTableRows =
        _getAdditionalSpecificationsTableRows();
    final List<pw.TableRow> getValuationTableRows = _getValuationTableRows();

    final List<pw.TableRow> getExtraItemsTableRows = _getExtraItemsTableRows();
    final List<pw.TableRow> getAmenitiesTableRows2 = _getAmenitiesTableRows2();
    final List<pw.TableRow> getMiscTableRows = _getMiscTableRows();
    final List<pw.TableRow> getServicesTableRows = _getServicesTableRows();

    final logoImage = await loadLogoImage();
    // Page 1
    pdf.addPage(
      pw.MultiPage(
        pageFormat: pdfLib.PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Container(
                  height: 80,
                  width: 80,
                  child: pw.Image(
                    logoImage,
                  ), // logoImage = pw.MemoryImage or pw.ImageProvider
                ),

                // Right side text
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                      'VIGNESH. S',
                      style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                        color: pdfLib.PdfColors.indigo,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'Chartered Engineer (AM1920793)',
                      style: const pw.TextStyle(
                        fontSize: 12,
                        color: pdfLib.PdfColors.indigo,
                      ),
                    ),
                    pw.Text(
                      'Registered valuer under section 247 of Companies Act, 2013',
                      style: const pw.TextStyle(
                        fontSize: 12,
                        color: pdfLib.PdfColors.indigo,
                      ),
                    ),
                    pw.Text(
                      '(IBBI/RV/01/2020/13411)',
                      style: const pw.TextStyle(
                        fontSize: 12,
                        color: pdfLib.PdfColors.indigo,
                      ),
                    ),
                    pw.Text(
                      'Registered valuer under section 34AB of Wealth Tax Act, 1957',
                      style: const pw.TextStyle(
                        fontSize: 12,
                        color: pdfLib.PdfColors.indigo,
                      ),
                    ),
                    pw.Text(
                      '(I-9AV/CC-TVM/2020-21)',
                      style: const pw.TextStyle(
                        fontSize: 12,
                        color: pdfLib.PdfColors.indigo,
                      ),
                    ),
                    pw.Text(
                      'Registered valuer under section 77(1) of Black Money Act, 2015',
                      style: const pw.TextStyle(
                        fontSize: 12,
                        color: pdfLib.PdfColors.indigo,
                      ),
                    ),
                    pw.Text(
                      '(I-3/AV-BM/PCIT-TVM/2023-24)',
                      style: const pw.TextStyle(
                        fontSize: 12,
                        color: pdfLib.PdfColors.indigo,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            pw.SizedBox(height: 10),

            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Top background strip with address
                pw.Container(
                  color: pdfLib.PdfColor.fromHex(
                    '#8a9b8e',
                  ), // Approx background color
                  padding: const pw.EdgeInsets.all(6),
                  width: double.infinity,
                  child: pw.Text(
                    'TC-37/777(1), Big Palla Street, Fort P.O. Thiruvananthapuram-695023',
                    style: pw.TextStyle(
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                      color: pdfLib.PdfColors.black,
                    ),
                    textAlign: pw.TextAlign.center,
                  ),
                ),

                pw.SizedBox(height: 4),

                // Contact Row
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // Empty space or backtick (`) placeholder
                    pw.Text('`', style: const pw.TextStyle(fontSize: 14)),

                    // Phone
                    pw.Row(
                      children: [
                        pw.Text(
                          'Phone: +91 89030 42635',
                          style: const pw.TextStyle(fontSize: 12),
                        ),
                      ],
                    ),

                    // Email
                    pw.Row(
                      children: [
                        pw.Text(
                          'Email: subramonyvignesh@gmail.com',
                          style: const pw.TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),

                pw.SizedBox(height: 20),

                // Addressed To & Ref No.
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'To,',
                          style: pw.TextStyle(
                            fontSize: 12,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.Text(
                          'The State Bank of India',
                          style: const pw.TextStyle(fontSize: 12),
                        ),
                        pw.Text(
                          'Chakai Branch',
                          style: const pw.TextStyle(fontSize: 12),
                        ),
                        pw.Text(
                          'Thiruvananthapuram',
                          style: const pw.TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                    pw.Text(
                      'Ref No.: ${_refId.text}',
                      style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            pw.SizedBox(height: 30),
            // Keep original page 1 headings
            pw.Center(
              child: pw.Text(
                'FORMAT - A',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ), // Slightly reduced font size
              ),
            ),
            pw.SizedBox(height: 8), // Reduced SizedBox height
            pw.Center(
              child: pw.Text(
                'VALUATION REPORT (IN RESPECT OF LAND / SITE AND BUILDING)',
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                ), // Slightly reduced font size
                textAlign: pw.TextAlign.center,
              ),
            ),
            pw.SizedBox(height: 15), // Reduced SizedBox height

            pw.Table(
              border: pw.TableBorder.all(
                color: pdfLib.PdfColors.black,
                width: 0.5,
              ),
              columnWidths: {
                0: const pw.FlexColumnWidth(0.5), // S.No
                1: const pw.FlexColumnWidth(
                  3,
                ), // PROPERTY DETAILS (Description)
                2: const pw.FlexColumnWidth(0.2), // Colon (:)
                3: const pw.FlexColumnWidth(3.8), // Value/Details
              },
              children: [
                // Table Headers
                pw.TableRow(
                  children: [
                    pw.Container(
                      alignment: pw.Alignment.center,
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Text(
                        'S.No',
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 7,
                        ),
                      ), // Reduced font size
                      // decoration: pw.BoxDecoration(
                      //   border: pw.Border.all(
                      //     color: pdfLib.PdfColors.black,
                      //     width: 0.5,
                      //   ),
                      // ),
                    ),
                    pw.Container(
                      alignment: pw.Alignment.center,
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Text(
                        'GENERAL',
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 9,
                        ),
                      ), // Reduced font size
                      // decoration: pw.BoxDecoration(
                      //   border: pw.Border.all(
                      //     color: pdfLib.PdfColors.black,
                      //     width: 0.5,
                      //   ),
                      // ),
                    ),
                    pw.Container(
                      alignment: pw.Alignment.center,
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Text(
                        '',
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 9,
                        ),
                      ), // Colon column header
                      // decoration: pw.BoxDecoration(
                      //   border: pw.Border.all(
                      //     color: pdfLib.PdfColors.black,
                      //     width: 0.5,
                      //   ),
                      // ),
                    ),
                    pw.Container(
                      alignment: pw.Alignment.center,
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Text(
                        '',
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 9,
                        ),
                      ), // Value column header (empty as per request)
                      //   decoration: pw.BoxDecoration(
                      //     border: pw.Border.all(
                      //       color: pdfLib.PdfColors.black,
                      //       width: 0.5,
                      //     ),
                      //   ),
                    ),
                  ],
                ),
                ...page1Rows, // Add rows for page 1
              ],
            ),
          ];
        },
      ),
    );

    // Page 2 - Contains three separate tables
    pdf.addPage(
      pw.MultiPage(
        pageFormat: pdfLib.PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            // First table on Page 2 (Items 10-14)
            pw.Table(
              border: pw.TableBorder.all(
                color: pdfLib.PdfColors.black,
                width: 0.5,
              ),
              columnWidths: {
                0: const pw.FlexColumnWidth(0.6), // S.No
                1: const pw.FlexColumnWidth(5.0), // Description
                2: const pw.FlexColumnWidth(0.2), // Colon (very small width)
                3: const pw.FlexColumnWidth(4.3),
              },
              children: [
                ...page2Table1Rows, // Add rows for the first table on page 2
              ],
            ),

            // Removed pw.SizedBox(height: 15) between table 14 and 15.

            // Second table on Page 2 (Item 15)
            pw.Table(
              border: pw.TableBorder.all(
                color: pdfLib.PdfColors.black,
                width: 0.5,
              ),
              columnWidths: {
                0: const pw.FlexColumnWidth(0.05), // S.No
                1: const pw.FlexColumnWidth(1.5), // Directions
              },
              children: [
                ...page2Table2RowsHeading, // Add rows for the second table on page 2
              ],
            ),

            pw.Table(
              border: pw.TableBorder.all(
                color: pdfLib.PdfColors.black,
                width: 0.5,
              ),
              columnWidths: {
                0: const pw.FlexColumnWidth(0.4), // S.No
                1: const pw.FlexColumnWidth(1.5), // Directions
                2: const pw.FlexColumnWidth(0.1), // As per Actuals
                3: const pw.FlexColumnWidth(
                  2.0,
                ), // As per Documents (slightly wider for text)
                4: const pw.FlexColumnWidth(
                  2.0,
                ), // Adopted area in Sft (wider to accommodate text)
              },
              children: [
                ...page2Table2Rows, // Add rows for the second table on page 2
              ],
            ),

            pw.Table(
              border: pw.TableBorder.all(
                color: pdfLib.PdfColors.black,
                width: 0.5,
              ),
              columnWidths: {
                0: const pw.FlexColumnWidth(0.05), // S.No
                1: const pw.FlexColumnWidth(1.5), // Directions
              },
              children: [
                ...page2Table2RowsPart2Heading, // Add rows for the second table on page 2
              ],
            ),

            pw.Table(
              border: pw.TableBorder.all(
                color: pdfLib.PdfColors.black,
                width: 0.5,
              ),
              columnWidths: {
                0: const pw.FlexColumnWidth(0.4), // S.No
                1: const pw.FlexColumnWidth(1.5), // Directions
                2: const pw.FlexColumnWidth(0.1), // As per Actuals
                3: const pw.FlexColumnWidth(
                  2.0,
                ), // As per Documents (slightly wider for text)
                4: const pw.FlexColumnWidth(
                  2.0,
                ), // Adopted area in Sft (wider to accommodate text)
              },
              children: [
                ...page2Table2RowsPart2, // Add rows for the second table on page 2
              ],
            ),

            // Third table on Page 2 (Items 16-17)
            pw.Table(
              border: pw.TableBorder.all(
                color: pdfLib.PdfColors.black,
                width: 0.5,
              ),
              columnWidths: {
                0: const pw.FlexColumnWidth(0.6), // S.No
                1: const pw.FlexColumnWidth(5.0), // Description
                2: const pw.FlexColumnWidth(0.2), // Colon (very small width)
                3: const pw.FlexColumnWidth(4.3), // Value
              },
              children: [
                ...page2Table3Rows, // Add rows for the third table on page 2
              ],
            ),
            // No SizedBox before the new table as requested.

            // New Table for Item 18 (Floor Details) and Items 19-20 (Road Details)
          ];
        },
      ),
    );

    // Page 3 - New page for Item 21 and Land Valuation Table
    pdf.addPage(
      pw.MultiPage(
        pageFormat: pdfLib.PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            pw.Table(
              border: pw.TableBorder.all(
                color: pdfLib.PdfColors.black,
                width: 0.5,
              ),
              columnWidths: {
                0: const pw.FlexColumnWidth(0.5), // S.No
                1: const pw.FlexColumnWidth(5.0), // Description
                2: const pw.FlexColumnWidth(0.2), // Colon (very small width)
                3: const pw.FlexColumnWidth(4.3), // Value
              },
              children: [
                ...page3Rows, // Add rows for page 3 (Item 21)
              ],
            ),

            pw.Table(
              border: pw.TableBorder.all(
                color: pdfLib.PdfColors.black,
                width: 0.5,
              ),
              columnWidths: {
                0: const pw.FlexColumnWidth(0.5), // Value in Rs.
              },
              children: [
                ...landValuationRowsHeading, // Add rows for the new land valuation table
              ],
            ),
            pw.Table(
              border: pw.TableBorder.all(
                color: pdfLib.PdfColors.black,
                width: 0.5,
              ),
              columnWidths: {
                0: const pw.FlexColumnWidth(0.5), // S.No
                1: const pw.FlexColumnWidth(2.5), // Details
                2: const pw.FlexColumnWidth(2.0), // Land area in Sq Ft
                3: const pw.FlexColumnWidth(2.0), // Rate per Sq ft
                4: const pw.FlexColumnWidth(2.0), // Value in Rs.
              },
              children: [
                ...landValuationRows, // Add rows for the new land valuation table
              ],
            ),

            // NEW: Building Valuation Table (Part B)
            pw.Table(
              border: pw.TableBorder.all(
                color: pdfLib.PdfColors.black,
                width: 0.5,
              ),
              columnWidths: {
                0: const pw.FlexColumnWidth(0.5), // Value in Rs.
              },
              children: [
                ...buildingValuationRowsHeading, // Add rows for the new land valuation table
              ],
            ),

            pw.Table(
              border: pw.TableBorder.all(
                color: pdfLib.PdfColors.black,
                width: 0.5,
              ),
              columnWidths: {
                0: const pw.FlexColumnWidth(0.25), // S.No
                1: const pw.FlexColumnWidth(5.0),
              },
              children: [
                ...buildingValuationTableRowsSubHeading, // Add rows for the new building valuation table
              ],
            ),

            pw.Table(
              border: pw.TableBorder.all(
                color: pdfLib.PdfColors.black,
                width: 0.5,
              ),
              columnWidths: {
                0: const pw.FlexColumnWidth(0.5), // S.No
                1: const pw.FlexColumnWidth(0.5), // Sub-item (a, b, c...)
                2: const pw.FlexColumnWidth(5.0), // Description
                3: const pw.FlexColumnWidth(4.0), // Value
              },
              children: [
                ...buildingValuationRows, // Add rows for the new building valuation table
              ],
            ),
            pw.SizedBox(height: 15), // Add some space between tables
            // NEW: Build up Area Table
            pw.Table(
              border: pw.TableBorder.all(
                color: pdfLib.PdfColors.black,
                width: 0.5,
              ),
              columnWidths: {
                0: const pw.FlexColumnWidth(0.5), // S n
                1: const pw.FlexColumnWidth(1.5), // Particular of item
                2: const pw.FlexColumnWidth(1.5), // As per approved Plan/FSI
                3: const pw.FlexColumnWidth(1.5), // As per Actual
                4: const pw.FlexColumnWidth(
                  1.5,
                ), // Area Considered for the Valuation
                5: const pw.FlexColumnWidth(1.5), // Replacement Cost in Rs.
                6: const pw.FlexColumnWidth(1.5), // Depreciation in Rs.
                7: const pw.FlexColumnWidth(
                  1.5,
                ), // Net value after Depreciations Rs.
              },
              children: [
                ...buildUpAreaRows, // Add rows for the new build up area table
              ],
            ),
          ];
        },
      ),
    );

    // Page 4 - New page for Amenities, Total Abstract, and Remarks
    pdf.addPage(
      pw.MultiPage(
        pageFormat: pdfLib.PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            pw.Table(
              border: pw.TableBorder.all(
                color: pdfLib.PdfColors.black,
                width: 0.5,
              ),
              columnWidths: {
                0: const pw.FlexColumnWidth(0.5), // S.No.
                1: const pw.FlexColumnWidth(
                  1.5,
                ), // Details /Floors / Description
                2: const pw.FlexColumnWidth(
                  1.5,
                ), // Occupancy (Self/Rented) / Colon
                3: const pw.FlexColumnWidth(1.0), // No. Of Room / Value
                4: const pw.FlexColumnWidth(1.0), // No. Of Kitchen
                5: const pw.FlexColumnWidth(1.0), // No. of Bathroom
                6: const pw.FlexColumnWidth(2.0), // Usage Remarks (Resi/Comm)
              },
              children: [
                ...page2Table4Rows, // Add rows for the floor details
              ],
            ),
            pw.Table(
              border: pw.TableBorder.all(
                color: pdfLib.PdfColors.black,
                width: 0.5,
              ),
              columnWidths: {
                0: const pw.FlexColumnWidth(0.5), // S.No
                1: const pw.FlexColumnWidth(5.0), // Description
                2: const pw.FlexColumnWidth(0.2), // Colon (very small width)
                3: const pw.FlexColumnWidth(4.3), // Value
              },
              children: [
                ...page2Table5Rows, // Add rows for the second table on page 2
              ],
            ),
            pw.Center(
              child: pw.Text(
                'Details of Valuation',
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 12,
                ),
                textAlign: pw.TextAlign.center,
              ),
            ),
            pw.SizedBox(height: 30),

            pw.Center(
              child: pw.Text(
                'Part C- Amenities                                            (Amount in Rs.)',
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 12,
                ),
                textAlign: pw.TextAlign.center,
              ),
            ),

            pw.SizedBox(height: 10),
            pw.Table(
              border: pw.TableBorder.all(
                color: pdfLib.PdfColors.black,
                width: 0.5,
              ),
              columnWidths: {
                0: const pw.FlexColumnWidth(0.5), // S.No
                1: const pw.FlexColumnWidth(3.0), // Item
                2: const pw.FlexColumnWidth(0.2), // Colon
                3: const pw.FlexColumnWidth(2.0), // Amount
              },
              children: [
                ...amenitiesTableRows, // Add rows for amenities table
              ],
            ),
            pw.SizedBox(height: 30),

            pw.SizedBox(height: 30),
            // NEW: Consolidated Remarks/ Observations of the property
            pw.Text(
              'Consolidated Remarks/ Observations of the property:',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12),
            ),
            pw.SizedBox(height: 30),
            pw.Text(
              '1. ${_remark1Controller.text}',
              style: const pw.TextStyle(fontSize: 11),
            ),
            pw.Text(
              '2. ${_remark2Controller.text}',
              style: const pw.TextStyle(fontSize: 11),
            ),
            pw.Text(
              '3. ${_remark3Controller.text}',
              style: const pw.TextStyle(fontSize: 11),
            ),
            pw.Text(
              '4. ${_remark4Controller.text}',
              style: const pw.TextStyle(fontSize: 11),
            ),
          ];
        },
      ),
    );

    // Page 5 - (New format)
    pdf.addPage(
      pw.MultiPage(
        pageFormat: pdfLib.PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            pw.Center(
              child: pw.Text(
                'Specifications of construction (floor-wise) in respect of',
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 12,
                ),
                textAlign: pw.TextAlign.center,
              ),
            ),
            pw.SizedBox(height: 10),
            pw.Table(
              border: pw.TableBorder.all(
                color: pdfLib.PdfColors.black,
                width: 0.5,
              ),
              columnWidths: {
                0: const pw.FixedColumnWidth(30), // S. No.
                1: const pw.FlexColumnWidth(3.5), // Description
                2: const pw.FlexColumnWidth(1.5), // Ground floor
                3: const pw.FlexColumnWidth(1.5), // Other floors
              },
              children: [
                // Section 1: Rows 1 through 11 (Foundation to Kitchen)
                ..._getSpecificationsTableRows(),

                // Section 2: Rows for Compound Wall, Electrical, and Plumbing
                // Note: Ensure the second function does not re-add the Header row
                // if you want one continuous table without a mid-break header.
                ..._getAdditionalSpecificationsTableRows(),
              ],
            ),
            pw.Text(
              'Stage of contruction: ${_stageofcontruction.text}',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            )
          ];
        },
      ),
    );

    pdf.addPage(
      pw.MultiPage(
        pageFormat: pdfLib.PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          // Helper for Part Title Headers
          pw.Widget buildPartHeader(String title, String amountLabel) {
            return pw.Padding(
              padding: const pw.EdgeInsets.only(top: 15, bottom: 5),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(title,
                      style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold, fontSize: 10)),
                  pw.Text(amountLabel, style: pw.TextStyle(fontSize: 9)),
                ],
              ),
            );
          }

          // Standard Column Widths for Parts C, D, E, F
          final partColumnWidths = {
            0: const pw.FixedColumnWidth(25), // S.No
            1: const pw.FlexColumnWidth(4), // Description
            2: const pw.FixedColumnWidth(20), // Colon
            3: const pw.FlexColumnWidth(2), // Amount
          };

          return [
            pw.Center(
              child: pw.Text(
                'Details of valuation',
                style:
                    pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12),
              ),
            ),
            pw.SizedBox(height: 10),

            // Main Valuation Table
            pw.Table(
              border:
                  pw.TableBorder.all(color: pdfLib.PdfColors.black, width: 0.5),
              columnWidths: {
                0: const pw.FixedColumnWidth(25),
                1: const pw.FlexColumnWidth(1.5),
                2: const pw.FlexColumnWidth(1.2),
                3: const pw.FlexColumnWidth(1.0),
                4: const pw.FlexColumnWidth(1.0),
                5: const pw.FlexColumnWidth(1.5),
                6: const pw.FlexColumnWidth(1.2),
                7: const pw.FlexColumnWidth(1.2),
                8: const pw.FlexColumnWidth(1.2),
              },
              children: [..._getValuationTableRows()],
            ),

            // --- PART C ---
            buildPartHeader('Part C- (Extra Items)', '(Amount in Rs.)'),
            pw.Table(
              border:
                  pw.TableBorder.all(color: pdfLib.PdfColors.black, width: 0.5),
              columnWidths: partColumnWidths,
              children: [..._getExtraItemsTableRows()],
            ),

            // --- PART D ---
            buildPartHeader('Part D- (Amenities)', '(Amount in Rs.)'),
            pw.Table(
              border:
                  pw.TableBorder.all(color: pdfLib.PdfColors.black, width: 0.5),
              columnWidths: partColumnWidths,
              children: [..._getAmenitiesTableRows2()],
            ),

            // --- PART E ---
            buildPartHeader('Part E- (Miscellaneous)', '(Amount in Rs.)'),
            pw.Table(
              border:
                  pw.TableBorder.all(color: pdfLib.PdfColors.black, width: 0.5),
              columnWidths: partColumnWidths,
              children: [..._getMiscTableRows()],
            ),

            // --- PART F ---
            buildPartHeader('Part F- (Services)', '(Amount in Rs.)'),
            pw.Table(
              border:
                  pw.TableBorder.all(color: pdfLib.PdfColors.black, width: 0.5),
              columnWidths: partColumnWidths,
              children: [..._getServicesTableRows()],
            ),
          ];
        },
      ),
    );

    pdf.addPage(
      pw.MultiPage(
        pageFormat: pdfLib.PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            pw.Center(
              child: pw.Text(
                'Total abstract of the entire property',
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 12,
                ),
                textAlign: pw.TextAlign.center,
              ),
            ),
            pw.Table(
              border: pw.TableBorder.all(
                color: pdfLib.PdfColors.black,
                width: 0.5,
              ),
              columnWidths: {
                0: const pw.FlexColumnWidth(0.5), // Part
                1: const pw.FlexColumnWidth(2.0), // Description
                2: const pw.FlexColumnWidth(0.1), // Colon
                3: const pw.FlexColumnWidth(2.0), // Amount
              },
              children: [
                ...page7, // Add rows for total abstract table
              ],
            ),
            pw.SizedBox(height: 5),
            pw.Table(
              border: pw.TableBorder.all(
                color: pdfLib.PdfColors.black,
                width: 0.5,
              ),
              columnWidths: {
                0: const pw.FlexColumnWidth(3.0), // Description
                1: const pw.FlexColumnWidth(2.0), // Value
              },
              children: [
                ...finalValuationTableRows, // Add rows for the new final valuation table
              ],
            ),
            pw.SizedBox(height: 5),
            pw.Text('Note:-'),
            pw.SizedBox(height: 5),
            pw.RichText(
              text: pw.TextSpan(
                // Global style for the paragraph
                style: pw.TextStyle(fontSize: 11),
                children: [
                  const pw.TextSpan(
                      text:
                          'As a result of my appraisal and analysis, it is my considered opinion that the realizable value of the above property in the prevailing condition with aforesaid specifications is ',
                      style: pw.TextStyle(fontSize: 11)),
                  pw.TextSpan(
                    // The Bold Part
                    text:
                        'Rs. ${_realizableValueController.text} (${NumToWords.convertNumberToIndianWords(int.tryParse(_realizableValueController.text) ?? 0)})',
                    style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold, fontSize: 11),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Text(
              'Place: ${_place.text}',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 10),
            pw.Text(
              'Date: ${_dateOfValuationController.text}',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 10),
            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Column(
                children: [
                  pw.Text(
                    'Signature',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  pw.SizedBox(height: 10),
                  pw.Text(
                    '(Name and Official seal of',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  pw.Text(
                    '   the Approved Valuer)',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 10),
            pw.Text(
                'The undersigned has inspected the property detailed in the Valuation Report dated on _____________. We are satisfied that the fair and reasonable market value of the property is Rs. ________ (Rupees __________________________________________________ only). ',
                style: pw.TextStyle(fontSize: 11)),
            pw.SizedBox(height: 42),
            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Column(
                children: [
                  pw.Text(
                    'Signature',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  pw.SizedBox(height: 10),
                  pw.Text(
                    '(Name of the Branch Manager with Official seal)',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 10),
            pw.Text('Date : ${_dateOfValuationController.text}',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
            pw.Text(
                'Encl:\n \t\tTO BE OBTAINED FROM VALUERS ALONGWITH THE VALUATION REPORT\n\t\t\t[ ] Declaration-cum-undertaking from the valuer (Annexure-I)\n\t\t\t[ ] Model code of conduct for valuer (Annexure II )',
                style: pw.TextStyle(fontSize: 11)),
          ];
        },
      ),
    );
    if (_images.isNotEmpty) {
      // 1. Define Standard Layout Constants
      final double pageWidth =
          pdfLib.PdfPageFormat.a4.width - (2 * 22); // A4 Width - Margins
      // Standard photo aspect ratio (4:3) is better than splitting page height by 2
      const double imageAspectRatio = 4 / 3;
      const int crossAxisCount = 2; // Standard: 2 photos per row
      const double spacing = 15; // Space between photos

      // 2. Calculate Exact Width for each photo
      final double targetImageWidth =
          (pageWidth - (spacing * (crossAxisCount - 1))) / crossAxisCount;
      // Calculate Height based on aspect ratio (keeps photos uniform)
      final double targetImageHeight = targetImageWidth / imageAspectRatio;

      // 3. Loop through images in batches of 6 (2 columns x 3 rows = 6 per page)
      for (int i = 0; i < _images.length; i += 6) {
        final List<pw.Widget> pageImages = [];

        for (int j = 0; j < 6 && (i + j) < _images.length; j++) {
          final imageItem = _images[i + j];

          try {
            pw.MemoryImage pwImage;
            if (imageItem is File) {
              pwImage = pw.MemoryImage(await imageItem.readAsBytes());
            } else if (imageItem is Uint8List) {
              pwImage = pw.MemoryImage(imageItem);
            } else {
              continue;
            }

            pageImages.add(
              pw.Container(
                width: targetImageWidth,
                height: targetImageHeight,
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(width: 0.5), // Optional: Add border
                ),
                child: pw.Image(
                  pwImage,
                  fit: pw.BoxFit.contain, // Ensures the whole photo is visible
                ),
              ),
            );
          } catch (e) {
            print('Error loading image: $e');
          }
        }

        // 4. Build Rows for the PDF
        List<pw.Widget> rows = [];
        for (int k = 0; k < pageImages.length; k += crossAxisCount) {
          List<pw.Widget> rowChildren = [];
          for (int l = 0; l < crossAxisCount; l++) {
            if (k + l < pageImages.length) {
              rowChildren.add(pageImages[k + l]);
            } else {
              // Add invisible spacer for empty slots to keep alignment
              rowChildren.add(pw.SizedBox(
                  width: targetImageWidth, height: targetImageHeight));
            }

            // Add spacing between columns (but not after the last one)
            if (l < crossAxisCount - 1) {
              rowChildren.add(pw.SizedBox(width: spacing));
            }
          }

          rows.add(
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.start, // Align left
              children: rowChildren,
            ),
          );

          // Add spacing between rows
          if (k + crossAxisCount < pageImages.length) {
            rows.add(pw.SizedBox(height: spacing));
          }
        }

        // 5. Add the Page
        pdf.addPage(
          pw.MultiPage(
            pageFormat: pdfLib.PdfPageFormat.a4,
            margin: const pw.EdgeInsets.all(22),
            build: (context) => [
              pw.Center(
                child: pw.Text(
                  'PHOTO REPORT',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Column(children: rows),
            ],
          ),
        );
      }
    }
    pdf.addPage(
      pw.MultiPage(
        pageFormat: pdfLib.PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32), // Standard document margin
        build: (context) => [
          // --- HEADER SECTION ---
          pw.Center(
            child: pw.Text(
              'Annexure-I',
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.SizedBox(height: 5),
          pw.Center(
            child: pw.Text(
              'Format of undertaking to be submitted by Individuals/ proprietor/ partners/ directors DECLARATION- CUM- UNDERTAKING',
              textAlign: pw.TextAlign.center,
              style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.SizedBox(height: 20),

          // --- INTRODUCTORY SENTENCE ---
          // Replace "Vignesh S..." with your variables: ${nameController.text}
          pw.Text(
            'I, Vignesh S, S/o S Subramania Iyer do hereby solemnly affirm and state that:',
            style: pw.TextStyle(fontSize: 12),
          ),
          pw.SizedBox(height: 10),

          // --- BULLET POINTS (Images 1 & 2) ---
          _buildBulletPoint('I am a citizen of India'),
          pw.SizedBox(height: 5),

          _buildBulletPoint(
              'I will not undertake valuation of any assets in which I have a direct or indirect interest or become so interested at any time during a period of three years prior to my appointment as valuer or three years after the valuation of assets was conducted by me'),
          pw.SizedBox(height: 5),

          _buildBulletPoint(
              'The information furnished in my valuation report dated 17.11.2025 is true and correct to the best of my knowledge and belief and I have made an impartial and true valuation of the property.'),
          pw.SizedBox(height: 5),

          _buildBulletPoint(
              'I have personally inspected the property on 17.11.2025. The work is not subcontracted to any other valuer and carried out by myself.'),
          pw.SizedBox(height: 5),

          _buildBulletPoint(
              'Valuation report is submitted in the format as prescribed by the Bank.'),
          pw.SizedBox(height: 5),

          _buildBulletPoint(
              'I have not been depanelled/ delisted by any other bank and in case any such depanelment by other banks during my empanelment with you, I will inform you within 3 days of such depanelment.'),
          pw.SizedBox(height: 5),

          _buildBulletPoint(
              'I have not been removed/dismissed from service/employment earlier'),
          pw.SizedBox(height: 5),

          _buildBulletPoint(
              'I have not been convicted of any offence and sentenced to a term of imprisonment'),
          pw.SizedBox(height: 5),

          _buildBulletPoint(
              'I have not been found guilty of misconduct in professional capacity'),
          pw.SizedBox(height: 5),

          _buildBulletPoint('I have not been declared to be unsound mind'),
          pw.SizedBox(height: 5),

          _buildBulletPoint(
              'I am not an undischarged bankrupt, or has not applied to be adjudicated as a bankrupt;'),
          pw.SizedBox(height: 5),

          _buildBulletPoint('I am not an undischarged insolvent'),
          pw.SizedBox(height: 5),

          _buildBulletPoint(
              'I have not been levied a penalty under section 271J of Income-tax Act, 1961 (43 of 1961) and time limit for filing appeal before Commissioner of Incometax (Appeals) or Income-tax Appellate Tribunal, as the case may be has expired, or such penalty has been confirmed by Income-tax Appellate Tribunal, and five years have not elapsed after levy of such penalty'),
          pw.SizedBox(height: 5),

          _buildBulletPoint(
              'I have not been convicted of an offence connected with any proceeding under the Income Tax Act 1961, Wealth Tax Act 1957 or Gift Tax Act 1958 and'),
          pw.SizedBox(height: 5),

          _buildBulletPoint(
              'My PAN Card number/Service Tax number as applicable is AAAPE4881H.'), // Replace with variable if needed
          pw.SizedBox(height: 5),

          _buildBulletPoint(
              'I undertake to keep you informed of any events or happenings which would make me ineligible for empanelment as a valuer'),
          pw.SizedBox(height: 5),

          _buildBulletPoint(
              'I have not concealed or suppressed any material information, facts and records and I have made a complete and full disclosure'),
          pw.SizedBox(height: 5),

          _buildBulletPoint(
              'I have read the Handbook on Policy, Standards and procedure for Real Estate Valuation, 2011 of the IBA and this report is in conformity to the "Standards" enshrined for valuation in the Part-B of the above handbook to the best of my ability'),
          pw.SizedBox(height: 5),

          _buildBulletPoint(
              'I have read the International Valuation Standards (IVS) and the report submitted to the Bank for the respective asset class is in conformity to the "Standards" as enshrined for valuation in the IVS in "General Standards" and "Asset Standards" as applicable'),
          pw.SizedBox(height: 5),
        ],
      ),
    );
    pdf.addPage(
      pw.MultiPage(
        pageFormat: pdfLib.PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32), // Standard document margin
        build: (context) => [
          _buildBulletPoint(
              'I abide by the Model Code of Conduct for empanelment of valuer in the Bank. (Annexure V- A signed copy of same to be taken and kept along with this declaration)'),
          pw.SizedBox(height: 5),
          _buildBulletPoint(
              'I am registered under Section 34 AB of the Wealth Tax Act, 1957. (Strike off, if not applicable)'),
          pw.SizedBox(height: 5),
          _buildBulletPoint(
              'I am valuer registered with Insolvency & Bankruptcy Board of India (IBBI) (Strike off, if not applicable)'),
          pw.SizedBox(height: 5),
          _buildBulletPoint(
              'My CIBIL Score and credit worthiness is as per Bank\'s guidelines.'),
          pw.SizedBox(height: 5),
          _buildBulletPoint(
              'I am the proprietor / partner / authorized official of the firm / company, who is competent to sign this valuation report.'),
          pw.SizedBox(height: 5),
          _buildBulletPoint(
              'I will undertake the valuation work on receipt of Letter of Engagement generated from the system (i.e. LLMS/LOS) only.'),
          pw.SizedBox(height: 5),
          _buildBulletPoint(
              'Further, I hereby provide the following information.'),
        ],
      ),
    );

    pdf.addPage(
      pw.MultiPage(
        pageFormat: pdfLib.PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(50),
        build: (context) => [
          pw.Center(
            child: pw.Text(
              'VALUER COMMENTS / OBSERVATIONS',
              style: pw.TextStyle(
                fontSize: 12,
                fontWeight: pw.FontWeight.bold,
              ),
              textAlign: pw.TextAlign.center,
            ),
          ),
          pw.SizedBox(height: 20),
          pw.Table(
            border: pw.TableBorder.all(
              color: pdfLib.PdfColors.black,
              width: 0.5,
            ),
            columnWidths: {
              0: const pw.FlexColumnWidth(0.5), // SI No.
              1: const pw.FlexColumnWidth(3.0), // Particulars
              2: const pw.FlexColumnWidth(4.0), // Valuer comment
            },
            children: valuerCommentsTableRows, // Use the generated rows
          ),
          pw.SizedBox(height: 10),
          pw.Text(
            'Date: ${_dateOfValuationController.text}',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 10),
          pw.Text(
            'Place: ${_place.text}',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 10),
          pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Column(
              children: [
                pw.Text(
                  'Signature',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  'Vignesh S',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    pdf.addPage(
      pw.MultiPage(
        pageFormat: pdfLib.PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 40, vertical: 30),
        build: (context) => [
          // Main Header
          pw.Align(
            alignment: pw.Alignment.topRight,
            child: pw.Text('(Annexure-II)',
                style:
                    pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
          ),
          pw.SizedBox(height: 10),
          pw.Center(
            child: pw.Text(
              'MODEL CODE OF CONDUCT FOR VALUERS',
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.SizedBox(height: 20),

          // 1. Integrity and Fairness
          _buildSectionHeader('Integrity and Fairness'),
          _buildBulletPoint(
              'A valuer shall, in the conduct of his/its business, follow high standards of integrity and fairness in all his/its dealings with his/its clients and other valuers.'),
          _buildBulletPoint(
              'A valuer shall maintain integrity by being honest, straightforward, and forthright in all professional relationships.'),
          _buildBulletPoint(
              'A valuer shall endeavour to ensure that he/it provides true and adequate information and shall not misrepresent any facts or situations.'),
          _buildBulletPoint(
              'A valuer shall refrain from being involved in any action that would bring disrepute to the profession.'),
          _buildBulletPoint(
              'A valuer shall keep public interest foremost while delivering his services.'),

          // 2. Professional Competence and Due Care
          _buildSectionHeader('Professional Competence and Due Care'),
          _buildBulletPoint(
              'A valuer shall render at all times high standards of service, exercise due diligence, ensure proper care and exercise independent professional judgment.'),
          _buildBulletPoint(
              'A valuer shall carry out professional services in accordance with the relevant technical and professional standards that may be specified from time to time'),
          _buildBulletPoint(
              'A valuer shall continuously maintain professional knowledge and skill to provide competent professional service based on up-to-date developments in practice, prevailing regulations/guidelines and techniques.'),
          _buildBulletPoint(
              'In the preparation of a valuation report, the valuer shall not disclaim liability for his/its expertise or deny his/its duty of care, except to the extent that the assumptions are based on statements of fact provided by the company or its auditors or consultants or information available in public domain and not generated by the valuer.'),
          _buildBulletPoint(
              'A valuer shall not carry out any instruction of the client insofar as they are incompatible with the requirements of integrity, objectivity and independence.'),
          _buildBulletPoint(
              'A valuer shall clearly state to his client the services that he would be competent to provide and the services for which he would be relying on other valuers or professionals or for which the client can have a separate arrangement with other valuers.'),

          // 3. Independence (Start) - Matching Image 2
          _buildSectionHeader('Independence and Disclosure of Interest'),
          _buildBulletPoint(
              'A valuer shall act with objectivity in his/its professional dealings by ensuring that his/its decisions are made without the presence of any bias, conflict of interest, coercion, or undue influence of any party, whether directly connected to the valuation assignment or not.'),
          _buildBulletPoint(
              'A valuer shall not take up an assignment if he/it or any of his/its relatives or associates is not independent in terms of association to the company.'),
        ],
      ),
    );

// --- PAGE 2: Independence (Cont), Confidentiality, Info Management ---
    pdf.addPage(
      pw.MultiPage(
        pageFormat: pdfLib.PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 40, vertical: 30),
        build: (context) => [
          // 3. Independence (Continued from Image 3)
          _buildBulletPoint(
              'A valuer shall maintain complete independence in his/its professional relationships and shall conduct the valuation independent of external influences.'),
          _buildBulletPoint(
              'A valuer shall wherever necessary disclose to the clients, possible sources of conflicts of duties and interests, while providing unbiased services.'),
          _buildBulletPoint(
              'A valuer shall not deal in securities of any subject company after any time when he/it first becomes aware of the possibility of his/its association with the valuation, and in accordance with the Securities and Exchange Board of India (Prohibition of Insider Trading) Regulations, 2015 or till the time the valuation report becomes public, whichever is earlier.'),
          _buildBulletPoint(
              'A valuer shall not indulge in "mandate snatching" or offering "convenience valuations" in order to cater to a company or client\'s needs.'),
          _buildBulletPoint(
              'As an independent valuer, the valuer shall not charge success fee.'),
          _buildBulletPoint(
              'In any fairness opinion or independent expert opinion submitted by a valuer, if there has been a prior engagement in an unconnected transaction, the valuer shall declare the association with the company during the last five years.'),

          // 4. Confidentiality
          _buildSectionHeader('Confidentiality'),
          _buildBulletPoint(
              'A valuer shall not use or divulge to other clients or any other party any confidential information about the subject company, which has come to his/its knowledge without proper and specific authority or unless there is a legal or professional right or duty to disclose.'),

          // 5. Information Management
          _buildSectionHeader('Information Management'),
          _buildBulletPoint(
              'A valuer shall ensure that he/ it maintains written contemporaneous records for any decision taken, the reasons for taking the decision, and the information and evidence in support of such decision. This shall be maintained so as to sufficiently enable a reasonable person to take a view on the appropriateness of his/its decisions and actions.'),
          _buildBulletPoint(
              'A valuer shall appear, co-operate and be available for inspections and investigations carried out by the authority, any person authorised by the authority, the registered valuers organisation with which he/it is registered or any other statutory regulatory body.'),
          _buildBulletPoint(
              'A valuer shall provide all information and records as may be required by the authority, the Tribunal, Appellate Tribunal, the registered valuers organisation with which he/it is registered, or any other statutory regulatory body.'),
          _buildBulletPoint(
              'A valuer while respecting the confidentiality of information acquired during the course of performing professional services, shall maintain proper working papers for a period of three years or such longer period as required in its contract for a specific valuation, for production before a regulatory authority or for a peer review. In the event of a pending case before the Tribunal or Appellate Tribunal, the record shall be maintained till the disposal of the case.'),
        ],
      ),
    );

// --- PAGE 3: Gifts, Remuneration, Occupation, Misc ---
    pdf.addPage(
      pw.MultiPage(
        pageFormat: pdfLib.PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 40, vertical: 30),
        build: (context) => [
          // 6. Gifts and Hospitality
          _buildSectionHeader('Gifts and hospitality.'),
          _buildBulletPoint(
              'A valuer or his/its relative shall not accept gifts or hospitality which undermines or affects his independence as a valuer.\nExplanation: For the purposes of this code the term \'relative\' shall have the same meaning as defined in clause (77) of Section 2 of the Companies Act, 2013 (18 of 2013).'),
          _buildBulletPoint(
              'A valuer shall not offer gifts or hospitality or a financial or any other advantage to a public servant or any other person with a view to obtain or retain work for himself/ itself, or to obtain or retain an advantage in the conduct of profession for himself/ itself.'),

          // 7. Remuneration and Costs
          _buildSectionHeader('Remuneration and Costs.'),
          _buildBulletPoint(
              'A valuer shall provide services for remuneration which is charged in a transparent manner, is a reasonable reflection of the work necessarily and properly undertaken, and is not inconsistent with the applicable rules.'),
          _buildBulletPoint(
              'A valuer shall not accept any fees or charges other than those which are disclosed in a written contract with the person to whom he would be rendering service.'),

          // 8. Occupation etc.
          _buildSectionHeader('Occupation, employability and restrictions.'),
          _buildBulletPoint(
              'A valuer shall refrain from accepting too many assignments, if he/it is unlikely to be able to devote adequate time to each of his/ its assignments.'),
          _buildBulletPoint(
              'A valuer shall not conduct business which in the opinion of the authority or the registered valuer organisation discredits the profession.'),

          // 9. Miscellaneous
          _buildSectionHeader('Miscellaneous'),
          _buildBulletPoint(
              'A valuer shall refrain from undertaking to review the work of another valuer of the same client except under written orders from the bank or housing finance institutions and with knowledge of the concerned valuer.'),
          _buildBulletPoint(
              'A valuer shall follow this code as amended or revised from time to time'),
          pw.SizedBox(height: 15),
          pw.Text(
            'Date: ${_dateOfValuationController.text}',
            // style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 10),
          pw.Text(
            'Place: ${_place.text}',
            // style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 10),
          pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Column(
              children: [
                pw.Text(
                  'Signature',
                  // style: pw.TextStyle(
                  //   fontWeight: pw.FontWeight.bold,
                  // ),
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                    'Vignesh S\nTC - 37/777(1)\nBig Palla Street, Fort P.O.\nThiruvananthapuram - 695023\nPh:- +91 8903042635',
                    style: pw.TextStyle(),
                    textAlign: pw.TextAlign.center),
              ],
            ),
          ),
        ],
      ),
    );

    // Open the printing preview page instead of sharing/downloading directly
    await Printing.layoutPdf(
      onLayout: (pdfLib.PdfPageFormat format) async => pdf.save(),
    );
  }

// Helper for Bold Section Headers
  pw.Widget _buildSectionHeader(String text) {
    return pw.Header(
      level: 1,
      child: pw.Text(
        text,
        style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
      ),
      padding: const pw.EdgeInsets.only(top: 10, bottom: 5),
      decoration: const pw.BoxDecoration(), // Removes default underline
    );
  }

  pw.Widget _buildBulletPoint(String text) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(width: 15),
        pw.Text('* ',
            style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(width: 5),
        pw.Expanded(
          child: pw.Text(
            text,
            textAlign: pw.TextAlign.justify,
            style: pw.TextStyle(fontSize: 12),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Valuation Report Details'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Search for Nearby Property",
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _latitude,
                        decoration: const InputDecoration(
                          labelText: 'Latitude',
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _longitude,
                        decoration: const InputDecoration(
                          labelText: 'Longitude',
                        ),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed:
                                        _getNearbyLocation, // Call our new method
                                    icon: const Icon(Icons.my_location),
                                    label: const Text('Get Location'),
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: /* () {
                                  Navigator.of(context)
                                      .push(MaterialPageRoute(builder: (ctx) {
                                    return Nearbydetails(
                                        latitude: _nearbyLatitude.text,
                                        longitude: _nearbyLongitude.text);
                                  }));
                                } */
                                        _getNearbyProperty,
                                    label: const Text('Search'),
                                    icon: const Icon(Icons.search),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Center(
                child: Padding(
                  padding: const EdgeInsets.only(
                    right: 50,
                    left: 50,
                    top: 10,
                    bottom: 10,
                  ),
                  child: FloatingActionButton.extended(
                    icon: const Icon(Icons.search),
                    label: const Text('Search Saved Drafts'),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (ctx) {
                            return const SavedDraftsSBILand();
                          },
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),

              TextField(
                decoration: const InputDecoration(
                  hintText: "Reference ID",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                  ),
                ),
                controller: _refId,
              ),
              const SizedBox(
                height: 10,
              ),
              Center(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 172, 208, 237),
                      foregroundColor: Colors.black),
                  icon: Icon(Icons.autorenew),
                  onPressed: () async {
                    bool shouldGenerate = true;
                    if (_refId.text.isNotEmpty ?? false) {
                      shouldGenerate = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text("Confirm"),
                              content: const Text(
                                "Generate a new ID?",
                                style: TextStyle(fontWeight: FontWeight.w100),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context, true);
                                  },
                                  child: const Text("YES"),
                                ),
                                TextButton(
                                  onPressed: () {
                                    // FIX 4: Close dialog and pass 'false' back
                                    Navigator.pop(context, false);
                                  },
                                  child: const Text("NO"),
                                ),
                              ],
                            ),
                          ) ??
                          false; // If they click outside the box, default to false
                    }

                    // Now this only runs if they said YES (or if the field was empty)
                    if (shouldGenerate) {
                      String refID = await RefIdService.generateUniqueId();
                      setState(() {
                        _refId.text = refID;
                      });
                    }
                  },
                  label: const Text('Generate New ID',
                      style: TextStyle(fontWeight: FontWeight.w300)),
                ),
              ),
              const SizedBox(height: 20),
              // Collapsible Section: I. PROPERTY DETAILS
              ExpansionTile(
                title: const Text(
                  'I. GENERAL',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                initiallyExpanded:
                    false, // You can set this to false to start collapsed
                children: <Widget>[
                  const Divider(),
                  const SizedBox(height: 13),
                  TextField(
                    // Changed from _buildTextField
                    controller: _purposeController,
                    decoration: const InputDecoration(
                      labelText: '1. Purpose for which the valuation is made',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 13),
                  TextField(
                    // Changed from _buildTextField
                    controller: _dateOfInspectionController,
                    readOnly: true,
                    onTap: () =>
                        _selectDate(context, _dateOfInspectionController),
                    decoration: const InputDecoration(
                      labelText: '2. a) Date of inspection',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 13),
                  TextField(
                    // Changed from _buildTextField
                    controller: _dateOfValuationController,
                    readOnly: true,
                    onTap: () =>
                        _selectDate(context, _dateOfValuationController),
                    decoration: const InputDecoration(
                      labelText: '2. b) Date on which the valuation is made',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '3. List of documents produced for perusal',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    // Changed from _buildTextField
                    controller: _LandTaxReceipt,
                    decoration: const InputDecoration(
                      labelText: 'Land Tax Receipt',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 13),
                  TextField(
                    // Changed from _buildTextField
                    controller: _TitleDeed,
                    decoration: const InputDecoration(
                      labelText: 'Location Plan',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 13),
                  TextField(
                    // Changed from _buildTextField
                    controller: _BuildingCertificate,
                    decoration: const InputDecoration(
                      labelText: 'Legal Scrutiny Report dated',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 13),
                  // TextField(
                  //   // Changed from _buildTextField
                  //   controller: _LocationSketch,
                  //   decoration: const InputDecoration(
                  //     labelText: 'Location Sketch',
                  //     border: OutlineInputBorder(
                  //       borderRadius: BorderRadius.all(Radius.circular(20)),
                  //     ),
                  //   ),
                  // ),
                  // const SizedBox(height: 13),
                  // TextField(
                  //   // Changed from _buildTextField
                  //   controller: _PossessionCertificate,
                  //   decoration: const InputDecoration(
                  //     labelText: 'Possession Certificate',
                  //     border: OutlineInputBorder(
                  //       borderRadius: BorderRadius.all(Radius.circular(20)),
                  //     ),
                  //   ),
                  // ),
                  // const SizedBox(height: 13),
                  // TextField(
                  //   // Changed from _buildTextField
                  //   controller: _BuildingCompletionPlan,
                  //   decoration: const InputDecoration(
                  //     labelText: 'Building Completion Plan',
                  //     border: OutlineInputBorder(
                  //       borderRadius: BorderRadius.all(Radius.circular(20)),
                  //     ),
                  //   ),
                  // ),
                  // const SizedBox(height: 13),
                  // TextField(
                  //   // Changed from _buildTextField
                  //   controller: _ThandapperDocument,
                  //   decoration: const InputDecoration(
                  //     labelText: 'Thandapper Document',
                  //     border: OutlineInputBorder(
                  //       borderRadius: BorderRadius.all(Radius.circular(20)),
                  //     ),
                  //   ),
                  // ),
                  // const SizedBox(height: 13),
                  // TextField(
                  //   // Changed from _buildTextField
                  //   controller: _BuildingTaxReceipt,
                  //   decoration: const InputDecoration(
                  //     labelText: 'Building Tax Receipt',
                  //     border: OutlineInputBorder(
                  //       borderRadius: BorderRadius.all(Radius.circular(20)),
                  //     ),
                  //   ),
                  // ),
                  const SizedBox(height: 40),
                  TextField(
                    // Changed from _buildTextField
                    controller: _ownerNameController,
                    decoration: const InputDecoration(
                      labelText:
                          '4. Name of the owner(s) and his / their address (es) with Phone no.',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 13),
                  TextField(
                    // Changed from _buildTextField
                    controller: _BriefDescription,
                    decoration: const InputDecoration(
                      labelText:
                          '5. Brief description of the property (Including leasehold / freehold etc)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    // Changed from _buildTextField
                    controller: _LocationOfProperty,
                    decoration: const InputDecoration(
                      labelText: '6. Location of property',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 13),
                  TextField(
                    // Changed from _buildTextField
                    controller: _PlotNo,
                    decoration: const InputDecoration(
                      labelText: '6 a) Plot No. /Re. Survey No',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 13),
                  TextField(
                    // Changed from _buildTextField
                    controller: _DoorNo,
                    decoration: const InputDecoration(
                      labelText: '6 b) Door No.',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 13),
                  TextField(
                    // Changed from _buildTextField
                    controller: _TSNO,
                    decoration: const InputDecoration(
                      labelText: '6 c) T. S. No. / Village ',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 13),
                  TextField(
                    // Changed from _buildTextField
                    controller: _Ward,
                    decoration: const InputDecoration(
                      labelText: '6 d) Ward / Taluk ',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 13),
                  TextField(
                    // Changed from _buildTextField
                    controller: _Mandal,
                    decoration: const InputDecoration(
                      labelText: '6 e) Mandal / District',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 13),
                  TextField(
                    controller: _postalAddress,

                    // --- ADD THESE TWO LINES ---
                    maxLines:
                        null, // Allows the box to grow/accept multiple lines
                    keyboardType: TextInputType
                        .multiline, // Makes the "Enter" key create a new line
                    // ---------------------------

                    decoration: const InputDecoration(
                      labelText: '7. Postal address of the property ',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 13),
                  TextField(
                    // Changed from _buildTextField
                    controller: _city,
                    decoration: const InputDecoration(
                      labelText: '8. City / Town',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 13),
                  TextField(
                    // Changed from _buildTextField
                    controller: _residential,
                    decoration: const InputDecoration(
                      labelText: 'Residential Area',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 13),
                  TextField(
                    // Changed from _buildTextField
                    controller: _commercial,
                    decoration: const InputDecoration(
                      labelText: 'Commercial Area',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 13),
                  TextField(
                    // Changed from _buildTextField
                    controller: _industrial,
                    decoration: const InputDecoration(
                      labelText: 'Industrial Area',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
              ExpansionTile(
                title: const Text(
                  'Additional Property Details',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                initiallyExpanded: false,
                children: <Widget>[
                  const Divider(),
                  const SizedBox(height: 13),
                  TextField(
                    // Changed from _buildTextField
                    controller: _typeOfRichness,
                    decoration: const InputDecoration(
                      labelText: '9 i) High / Middle / Poor ',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 13),
                  TextField(
                    // Changed from _buildTextField
                    controller: _typeOfPlace,
                    decoration: const InputDecoration(
                      labelText: '9. ii) Urban / Semi Urban / Rural',
                      hintText: 'e.g., Urban',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 13),
                  TextField(
                    // Changed from _buildTextField
                    controller: _comingUnderCorporationController,
                    decoration: const InputDecoration(
                      labelText:
                          '10. Coming under Corporation limit / Village Panchayat / Municipality',
                      hintText: 'e.g., Corporation limit',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 13),
                  TextField(
                    // Changed from _buildTextField
                    controller: _coveredUnderStateCentralGovtController,
                    decoration: const InputDecoration(
                      labelText:
                          '11. Whether covered under any State / Central Govt. enactments',
                      hintText: 'e.g., No',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 13),
                  TextField(
                    // Changed from _buildTextField
                    controller: _agriculturalLandConversionController,
                    decoration: const InputDecoration(
                      labelText:
                          '12. In case it is an agricultural land, any conversion to house site plots is contemplated',
                      hintText: 'e.g., Not applicable / Yes / No',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    '13. Boundaries of the property',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: Column(
                      children: [
                        const Row(
                          children: [
                            Expanded(flex: 2, child: Text('Directions')),
                            Expanded(flex: 1, child: Text(':')),
                            Expanded(
                                flex: 3,
                                child: Text(
                                  'As per Location Sketch',
                                  textAlign: TextAlign.center,
                                )),
                            Expanded(
                              flex: 3,
                              child: Text(
                                'As per Actual',
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                        _buildBoundaryRow(
                          'North',
                          _boundaryNorthTitleController,
                          _boundaryNorthSketchController,
                        ),
                        _buildBoundaryRow(
                          'South',
                          _boundarySouthTitleController,
                          _boundarySouthSketchController,
                        ),
                        _buildBoundaryRow(
                          'East',
                          _boundaryEastTitleController,
                          _boundaryEastSketchController,
                        ),
                        _buildBoundaryRow(
                          'West',
                          _boundaryWestTitleController,
                          _boundaryWestSketchController,
                        ),
                      ],
                    ),
                  ),
                  // const SizedBox(height: 13),
                  // TextField(
                  //   // Changed from _buildTextField
                  //   controller: _boundaryDeviationsController,
                  //   decoration: const InputDecoration(
                  //     labelText: 'Deviations if any',
                  //     hintText: 'Enter any deviations (e.g., "None")',
                  //     border: OutlineInputBorder(
                  //       borderRadius: BorderRadius.all(Radius.circular(20)),
                  //     ),
                  //   ),
                  // ),
                  const Divider(),

                  const SizedBox(height: 30),
                  const Text(
                    '14.1. Dimensions of the site',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: Column(
                      children: [
                        const Row(
                          children: [
                            Expanded(flex: 3, child: Text('Directions')),
                            Expanded(flex: 2, child: Text('As per deed')),
                            Expanded(flex: 2, child: Text('Actual')),
                            // Expanded(
                            //   flex: 3,
                            //   child: Text('   Adopted area in   Sft'),
                            // ),
                          ],
                        ),
                        _buildDimensionsRow(
                          'North',
                          _dimNorthActualsController,
                          _dimNorthDocumentsController,
                          // _dimNorthAdoptedController,
                        ),
                        _buildDimensionsRow(
                          'South',
                          _dimSouthActualsController,
                          _dimSouthDocumentsController,
                          // _dimSouthAdoptedController,
                        ),
                        _buildDimensionsRow(
                          'East',
                          _dimEastActualsController,
                          _dimEastDocumentsController,
                          // _dimEastAdoptedController,
                        ),
                        _buildDimensionsRow(
                          'West',
                          _dimWestActualsController,
                          _dimWestDocumentsController,
                          // _dimWestAdoptedController,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Collapsible Section: Further Property Details
              ExpansionTile(
                title: const Text(
                  'Further Property Details',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                initiallyExpanded: false,
                children: <Widget>[
                  const Divider(),
                  TextField(
                    // Changed from _buildTextField
                    controller: _latitudeLongitudeController,
                    decoration: const InputDecoration(
                      labelText:
                          '14.2. Latitude, Longitude and Coordinates of the site',
                      hintText: 'e.g., 9.1234, 76.5678',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 13),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: ElevatedButton.icon(
                      onPressed: _getCurrentLocation,
                      icon: const Icon(Icons.location_on),
                      label: const Text('Get Current Location'),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 13),
                  TextField(
                    // Changed from _buildTextField
                    controller: _extent,
                    decoration: const InputDecoration(
                      labelText: '15. Extent of the site',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 13),
                  TextField(
                    // Changed from _buildTextField
                    controller: _extentConsidered,
                    decoration: const InputDecoration(
                      labelText:
                          '16. Extent of the site considered for valuation (least of 14 A & 14 B) ',
                      hintText: 'e.g., Self or Tenant',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 13),
                  TextField(
                    // Changed from _buildTextField
                    controller: _occupiedBySelfTenantController,
                    decoration: const InputDecoration(
                      labelText:
                          '17. Whether occupied by the owner / tenant? If occupied by tenant, since how long? Rent received per month. ',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 13),
                  TextField(
                    // Changed from _buildTextField
                    controller: _occupiedByTenantSinceController,
                    decoration: const InputDecoration(
                      labelText: '  If occupied by tenant, since how long?',
                      hintText: 'e.g., 5 years (leave blank if Self occupied)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 13),
                  TextField(
                    // Changed from _buildTextField
                    controller: _rentReceivedPerMonthController,
                    decoration: const InputDecoration(
                      labelText: '  Rent received per month',
                      hintText: 'e.g., 10000 (leave blank if Self occupied)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    '18. Floor Details',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 13),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '18. Floor Details',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 13),

                      // Ground Floor Details
                      const Text(
                        'Ground Floor',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _groundFloorOccupancyController,
                        decoration: const InputDecoration(
                          labelText: 'Occupancy (Self/Rented)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _groundFloorNoOfRoomController,
                        decoration: const InputDecoration(
                          labelText: 'No. of Rooms',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _groundFloorNoOfKitchenController,
                        decoration: const InputDecoration(
                          labelText: 'No. of Kitchens',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _groundFloorNoOfBathroomController,
                        decoration: const InputDecoration(
                          labelText: 'No. of Bathrooms',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _groundFloorUsageRemarksController,
                        decoration: const InputDecoration(
                          labelText: 'Usage Remarks (Resi/Comm)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),

                      // First Floor Details
                      const Text(
                        'First Floor',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _firstFloorOccupancyController,
                        decoration: const InputDecoration(
                          labelText: 'Occupancy (Self/Rented)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _firstFloorNoOfRoomController,
                        decoration: const InputDecoration(
                          labelText: 'No. of Rooms',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _firstFloorNoOfKitchenController,
                        decoration: const InputDecoration(
                          labelText: 'No. of Kitchens',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _firstFloorNoOfBathroomController,
                        decoration: const InputDecoration(
                          labelText: 'No. of Bathrooms',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _firstFloorUsageRemarksController,
                        decoration: const InputDecoration(
                          labelText: 'Usage Remarks (Resi/Comm)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),

                  // Column(
                  //   crossAxisAlignment: CrossAxisAlignment.start,
                  //   children: [
                  //     const Padding(
                  //       padding: EdgeInsets.symmetric(vertical: 8.0),
                  //       child: Row(
                  //         children: [
                  //           Expanded(
                  //             flex: 2,
                  //             child: Text(
                  //               'Details /Floors',
                  //               style: TextStyle(fontWeight: FontWeight.bold),
                  //             ),
                  //           ),
                  //           Expanded(
                  //             flex: 2,
                  //             child: Text(
                  //               'Occupancy\n(Self/Rented)',
                  //               style: TextStyle(fontWeight: FontWeight.bold),
                  //             ),
                  //           ),
                  //           Expanded(
                  //             flex: 1,
                  //             child: Text(
                  //               'No. Of Room',
                  //               style: TextStyle(fontWeight: FontWeight.bold),
                  //             ),
                  //           ),
                  //           Expanded(
                  //             flex: 1,
                  //             child: Text(
                  //               'No. Of Kitchen',
                  //               style: TextStyle(fontWeight: FontWeight.bold),
                  //             ),
                  //           ),
                  //           Expanded(
                  //             flex: 1,
                  //             child: Text(
                  //               'No. of Bathroom',
                  //               style: TextStyle(fontWeight: FontWeight.bold),
                  //             ),
                  //           ),
                  //           Expanded(
                  //             flex: 2,
                  //             child: Text(
                  //               'Usage Remarks\n(Resi/Comm)',
                  //               style: TextStyle(fontWeight: FontWeight.bold),
                  //             ),
                  //           ),
                  //         ],
                  //       ),
                  //     ),
                  //     _buildFloorDetailRow(
                  //       'Ground',
                  //       _groundFloorOccupancyController,
                  //       _groundFloorNoOfRoomController,
                  //       _groundFloorNoOfKitchenController,
                  //       _groundFloorNoOfBathroomController,
                  //       _groundFloorUsageRemarksController,
                  //     ),
                  //     _buildFloorDetailRow(
                  //       'First',
                  //       _firstFloorOccupancyController,
                  //       _firstFloorNoOfRoomController,
                  //       _firstFloorNoOfKitchenController,
                  //       _firstFloorNoOfBathroomController,
                  //       _firstFloorUsageRemarksController,
                  //     ),
                  //   ],
                  // ),
                ],
              ),
              const SizedBox(height: 20),

              // Collapsible Section: Road Details
              ExpansionTile(
                title: const Text(
                  'Road Details',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                initiallyExpanded: false,
                children: <Widget>[
                  const Divider(),
                  TextField(
                    // Changed from _buildTextField
                    controller: _typeOfRoadController,
                    decoration: const InputDecoration(
                      labelText:
                          '19. Type of road available at present (Bitumen/Mud/CC/Private)',
                      hintText: 'e.g., Bitumen',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 13),
                  TextField(
                    // Changed from _buildTextField
                    controller: _widthOfRoadController,
                    decoration: const InputDecoration(
                      labelText: '20. Width of road - in feet',
                      hintText: 'e.g., 20',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Collapsible Section: Land Details
              ExpansionTile(
                title: const Text(
                  'Land Details',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                initiallyExpanded: false,
                children: <Widget>[
                  const Divider(),
                  TextField(
                    // Changed from _buildTextField
                    controller: _isLandLockedController,
                    decoration: const InputDecoration(
                      labelText: '21. Is it a land - locked land?',
                      hintText: 'Yes/No',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Collapsible Section: Part - A (Valuation of land)
              ExpansionTile(
                title: const Text(
                  'Part - A (Valuation of land)',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                initiallyExpanded: false,
                children: <Widget>[
                  const Divider(),
                  TextField(
                    // Changed from _buildTextField
                    controller: _landAreaDetailsController,
                    decoration: const InputDecoration(
                      labelText: '1. Land area in Sq Ft (Details)',
                      hintText: 'e.g., 1500',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 13),
                  TextField(
                    // Changed from _buildTextField
                    controller: _landAreaGuidelineController,
                    decoration: const InputDecoration(
                      labelText: '2. Guideline rate (Land area in Sq Ft)',
                      hintText: 'e.g., 1400',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 13),
                  TextField(
                    // Changed from _buildTextField
                    controller: _ratePerSqFtGuidelineController,
                    decoration: const InputDecoration(
                      labelText: '   Guideline rate (Rate per Sq ft)',
                      hintText: 'e.g., 2000',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 13),
                  TextField(
                    // Changed from _buildTextField
                    controller: _valueInRsGuidelineController,
                    decoration: const InputDecoration(
                      labelText: '   Guideline rate (Value in Rs.)',
                      hintText: 'e.g., 2800000',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 13),
                  TextField(
                    // Changed from _buildTextField
                    controller: _landAreaPrevailingController,
                    decoration: const InputDecoration(
                      labelText:
                          '3. Prevailing market value (Land area in Sq Ft)',
                      hintText: 'e.g., 1500',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 13),
                  TextField(
                    // Changed from _buildTextField
                    controller: _ratePerSqFtPrevailingController,
                    decoration: const InputDecoration(
                      labelText: '   Prevailing market value (Rate per Sq ft)',
                      hintText: 'e.g., 2500',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 13),
                  TextField(
                    // Changed from _buildTextField
                    controller: _valueInRsPrevailingController,
                    decoration: const InputDecoration(
                      labelText: '   Prevailing market value (Value in Rs.)',
                      hintText: 'e.g., 3750000',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Collapsible Section: Part - B (Valuation of Building)
              ExpansionTile(
                title: const Text(
                  'Part - B (Valuation of Building)',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                initiallyExpanded: false,
                children: <Widget>[
                  const Divider(),
                  TextField(
                    // Changed from _buildTextField
                    controller: _typeOfBuildingController,
                    decoration: const InputDecoration(
                      labelText:
                          '1. a) Type of Building (Residential / Commercial / Industrial)',
                      hintText: 'e.g., Residential',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 13),
                  TextField(
                    // Changed from _buildTextField
                    controller: _typeOfConstructionController,
                    decoration: const InputDecoration(
                      labelText:
                          '   b) Type of construction (Load bearing / RCC / Steel Framed)',
                      hintText: 'e.g., RCC',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 13),
                  TextField(
                    // Changed from _buildTextField
                    controller: _ageOfTheBuildingController,
                    decoration: const InputDecoration(
                      labelText: '   c) Age of the building',
                      hintText: 'e.g., 10 years',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 13),
                  TextField(
                    // Changed from _buildTextField
                    controller: _residualAgeOfTheBuildingController,
                    decoration: const InputDecoration(
                      labelText: '   d) Residual age of the building',
                      hintText: 'e.g., 40 years',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 13),
                  TextField(
                    // Changed from _buildTextField
                    controller: _approvedMapAuthorityController,
                    decoration: const InputDecoration(
                      labelText: '   e) Approved map / plan issuing authority',
                      hintText: 'e.g., Local Municipality',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 13),
                  TextField(
                    // Changed from _buildTextField
                    controller: _genuinenessVerifiedController,
                    decoration: const InputDecoration(
                      labelText:
                          '   f) Whether genuineness or authenticity of approved map / plan is verified',
                      hintText: 'YES / NO',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 13),
                  TextField(
                    // Changed from _buildTextField
                    controller: _otherCommentsController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText:
                          '   g) Any other comments by our empanelled valuers on authentic of approved plan',
                      hintText: 'e.g., None',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Collapsible Section: Build up Area Details
              ExpansionTile(
                title: const Text(
                  'Build up Area Details',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                initiallyExpanded: false,
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Divider(),
                      const Text(
                        'Build-Up Area Details',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),

                      // Ground Floor Section
                      const Text(
                        'Ground Floor',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _groundFloorApprovedPlanController,
                        decoration: const InputDecoration(
                          labelText: 'As per approved Plan/FSI',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _groundFloorActualController,
                        decoration: const InputDecoration(
                          labelText: 'As per Actual',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _groundFloorConsideredValuationController,
                        decoration: const InputDecoration(
                          labelText: 'Area Considered for the Valuation',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _groundFloorReplacementCostController,
                        decoration: const InputDecoration(
                          labelText: 'Replacement Cost in Rs.',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _groundFloorDepreciationController,
                        decoration: const InputDecoration(
                          labelText: 'Depreciation in Rs.',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _groundFloorNetValueController,
                        decoration: const InputDecoration(
                          labelText: 'Net value after Depreciation in Rs.',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      // First Floor Section
                      const Text(
                        'First Floor',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _firstFloorApprovedPlanController,
                        decoration: const InputDecoration(
                          labelText: 'As per approved Plan/FSI',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _firstFloorActualController,
                        decoration: const InputDecoration(
                          labelText: 'As per Actual',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _firstFloorConsideredValuationController,
                        decoration: const InputDecoration(
                          labelText: 'Area Considered for the Valuation',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _firstFloorReplacementCostController,
                        decoration: const InputDecoration(
                          labelText: 'Replacement Cost in Rs.',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _firstFloorDepreciationController,
                        decoration: const InputDecoration(
                          labelText: 'Depreciation in Rs.',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _firstFloorNetValueController,
                        decoration: const InputDecoration(
                          labelText: 'Net value after Depreciation in Rs.',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      // Total Section
                      const Text(
                        'Total',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _totalApprovedPlanController,
                        decoration: const InputDecoration(
                          labelText: 'As per approved Plan/FSI',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _totalActualController,
                        decoration: const InputDecoration(
                          labelText: 'As per Actual',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _totalConsideredValuationController,
                        decoration: const InputDecoration(
                          labelText: 'Area Considered for the Valuation',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _totalReplacementCostController,
                        decoration: const InputDecoration(
                          labelText: 'Replacement Cost in Rs.',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _totalDepreciationController,
                        decoration: const InputDecoration(
                          labelText: 'Depreciation in Rs.',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _totalNetValueController,
                        decoration: const InputDecoration(
                          labelText: 'Net value after Depreciation in Rs.',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Collapsible Section: Part C - Amenities
              ExpansionTile(
                title: const Text(
                  'Part C - Amenities',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                initiallyExpanded: false,
                children: <Widget>[
                  const Divider(),
                  TextField(
                    // Changed from _buildTextField
                    controller: _wardrobesController,
                    decoration: const InputDecoration(
                      labelText: '1. Wardrobes (Amount in Rs.)',
                      hintText: 'e.g., 50000',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 13),
                  TextField(
                    // Changed from _buildTextField
                    controller: _amenitiesController,
                    decoration: const InputDecoration(
                      labelText: '2. Amenities (Amount in Rs.)',
                      hintText: 'e.g., 20000',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 13),
                  TextField(
                    // Changed from _buildTextField
                    controller: _anyOtherAdditionalController,
                    decoration: const InputDecoration(
                      labelText: '3. Any other Additional (Amount in Rs.)',
                      hintText: 'e.g., 10000',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 13),
                  TextField(
                    // Changed from _buildTextField
                    controller: _amenitiesTotalController,
                    decoration: const InputDecoration(
                      labelText: 'Total Amenities (Amount in Rs.)',
                      hintText: 'e.g., 80000',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              //Page 5 (New format)
              ExpansionTile(
                title: const Text(
                  'Construction Specifications (Floor-wise)',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                initiallyExpanded: false,
                children: <Widget>[
                  const Divider(),

                  // 1. Foundation
                  const Padding(
                    padding:
                        EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                    child: Text("1. Foundation",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  Row(
                    children: [
                      Flexible(
                          child: _buildSpecificationField(
                              _foundationGroundController, 'Ground Floor')),
                      const SizedBox(width: 10),
                      Flexible(
                          child: _buildSpecificationField(
                              _foundationOtherController, 'Other Floors')),
                    ],
                  ),
                  const SizedBox(height: 15),

                  // 2. Basement
                  const Padding(
                    padding:
                        EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                    child: Text("2. Basement",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  Row(
                    children: [
                      Flexible(
                          child: _buildSpecificationField(
                              _basementGroundController, 'Ground Floor')),
                      const SizedBox(width: 10),
                      Flexible(
                          child: _buildSpecificationField(
                              _basementOtherController, 'Other Floors')),
                    ],
                  ),
                  const SizedBox(height: 15),

                  // 3. Superstructure
                  const Padding(
                    padding:
                        EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                    child: Text("3. Superstructure",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  Row(
                    children: [
                      Flexible(
                          child: _buildSpecificationField(
                              _superstructureGroundController, 'Ground Floor')),
                      const SizedBox(width: 10),
                      Flexible(
                          child: _buildSpecificationField(
                              _superstructureOtherController, 'Other Floors')),
                    ],
                  ),
                  const SizedBox(height: 15),

                  // 4. Joinery / Doors & Windows
                  const Padding(
                    padding:
                        EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                    child: Text(
                        "4. Joinery / Doors & Windows (size, shutters, timber species etc.)",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  _buildSpecificationField(
                      _joineryGroundController, 'Ground Floor (Details)',
                      maxLines: 3),
                  const SizedBox(height: 10),
                  _buildSpecificationField(
                      _joineryOtherController, 'Other Floors (Details)',
                      maxLines: 3),
                  const SizedBox(height: 15),

                  // 5. RCC works
                  const Padding(
                    padding:
                        EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                    child: Text("5. RCC works",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  Row(
                    children: [
                      Flexible(
                          child: _buildSpecificationField(
                              _rccWorksGroundController, 'Ground Floor')),
                      const SizedBox(width: 10),
                      Flexible(
                          child: _buildSpecificationField(
                              _rccWorksOtherController, 'Other Floors')),
                    ],
                  ),
                  const SizedBox(height: 15),

                  // 6. Plastering
                  const Padding(
                    padding:
                        EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                    child: Text("6. Plastering",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  Row(
                    children: [
                      Flexible(
                          child: _buildSpecificationField(
                              _plasteringGroundController, 'Ground Floor')),
                      const SizedBox(width: 10),
                      Flexible(
                          child: _buildSpecificationField(
                              _plasteringOtherController, 'Other Floors')),
                    ],
                  ),
                  const SizedBox(height: 15),

                  // 7. Flooring, Skirting, dadoing
                  const Padding(
                    padding:
                        EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                    child: Text("7. Flooring, Skirting, dadoing",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  Row(
                    children: [
                      Flexible(
                          child: _buildSpecificationField(
                              _flooringGroundController, 'Ground Floor')),
                      const SizedBox(width: 10),
                      Flexible(
                          child: _buildSpecificationField(
                              _flooringOtherController, 'Other Floors')),
                    ],
                  ),
                  const SizedBox(height: 15),

                  // 8. Special finish
                  const Padding(
                    padding:
                        EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                    child: Text(
                        "8. Special finish (marble, granite, wooden paneling, grills, etc)",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  _buildSpecificationField(
                      _specialFinishGroundController, 'Ground Floor (Details)',
                      maxLines: 2),
                  const SizedBox(height: 10),
                  _buildSpecificationField(
                      _specialFinishOtherController, 'Other Floors (Details)',
                      maxLines: 2),
                  const SizedBox(height: 15),

                  // 9. Roofing
                  const Padding(
                    padding:
                        EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                    child: Text("9. Roofing including weather proof course",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  Row(
                    children: [
                      Flexible(
                          child: _buildSpecificationField(
                              _roofingGroundController, 'Ground Floor')),
                      const SizedBox(width: 10),
                      Flexible(
                          child: _buildSpecificationField(
                              _roofingOtherController, 'Other Floors')),
                    ],
                  ),
                  const SizedBox(height: 15),

                  // 10. Drainage
                  const Padding(
                    padding:
                        EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                    child: Text("10. Drainage",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  Row(
                    children: [
                      Flexible(
                          child: _buildSpecificationField(
                              _drainageGroundController, 'Ground Floor')),
                      const SizedBox(width: 10),
                      Flexible(
                          child: _buildSpecificationField(
                              _drainageOtherController, 'Other Floors')),
                    ],
                  ),

                  const SizedBox(height: 15),

                  //11. No of Kitchen
                  const Padding(
                    padding:
                        EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                    child: Text("11. No of Kitchen",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  Row(
                    children: [
                      Flexible(
                          child: _buildSpecificationField(
                              _kitchenGroundController, 'Ground Floor')),
                      const SizedBox(width: 10),
                      Flexible(
                          child: _buildSpecificationField(
                              _kitchenOtherController, 'Other Floors')),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
              const SizedBox(height: 20),
              //page 5(second table)
              ExpansionTile(
                title: const Text(
                  'Additional Construction Specifications (Floor-wise)',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                initiallyExpanded: false,
                children: <Widget>[
                  const Divider(),

                  // ... (Your existing items 1 - 11 here) ...

                  // 2. Compound wall
                  const Padding(
                    padding:
                        EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                    child: Text("2. Compound wall",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  // Row(
                  //   children: [
                  //     Flexible(
                  //         child: _buildSpecificationField(
                  //             _compoundWallGroundController, 'Ground Floor')),
                  //     const SizedBox(width: 10),
                  //     Flexible(
                  //         child: _buildSpecificationField(
                  //             _compoundWallOtherController, 'Other Floors')),
                  //   ],
                  // ),
                  _buildSubLabel("Height"),
                  Row(
                    children: [
                      Flexible(
                          child: _buildSpecificationField(
                              _cwHeightGroundController, 'Ground Floor')),
                      const SizedBox(width: 10),
                      Flexible(
                          child: _buildSpecificationField(
                              _cwHeightOtherController, 'Other Floors')),
                    ],
                  ),
                  _buildSubLabel("Length"),
                  Row(
                    children: [
                      Flexible(
                          child: _buildSpecificationField(
                              _cwLengthGroundController, 'Ground Floor')),
                      const SizedBox(width: 10),
                      Flexible(
                          child: _buildSpecificationField(
                              _cwLengthOtherController, 'Other Floors')),
                    ],
                  ),
                  _buildSubLabel("Type of construction"),
                  Row(
                    children: [
                      Flexible(
                          child: _buildSpecificationField(
                              _cwTypeGroundController, 'Ground Floor')),
                      const SizedBox(width: 10),
                      Flexible(
                          child: _buildSpecificationField(
                              _cwTypeOtherController, 'Other Floors')),
                    ],
                  ),
                  const SizedBox(height: 15),

                  // 3. Electrical installation
                  const Padding(
                    padding:
                        EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                    child: Text("3. Electrical installation",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  _buildSubLabel("Type of wiring"),
                  Row(
                    children: [
                      Flexible(
                          child: _buildSpecificationField(
                              _elecWiringGroundController, 'Ground Floor')),
                      const SizedBox(width: 10),
                      Flexible(
                          child: _buildSpecificationField(
                              _elecWiringOtherController, 'Other Floors')),
                    ],
                  ),
                  _buildSubLabel("Class of fittings (superior/ordinary/poor)"),
                  Row(
                    children: [
                      Flexible(
                          child: _buildSpecificationField(
                              _elecFittingsGroundController, 'Ground Floor')),
                      const SizedBox(width: 10),
                      Flexible(
                          child: _buildSpecificationField(
                              _elecFittingsOtherController, 'Other Floors')),
                    ],
                  ),
                  _buildSubLabel("Number of light points"),
                  Row(
                    children: [
                      Flexible(
                          child: _buildSpecificationField(
                              _elecLightPointsGroundController,
                              'Ground Floor')),
                      const SizedBox(width: 10),
                      Flexible(
                          child: _buildSpecificationField(
                              _elecLightPointsOtherController, 'Other Floors')),
                    ],
                  ),
                  _buildSubLabel("Fan points"),
                  Row(
                    children: [
                      Flexible(
                          child: _buildSpecificationField(
                              _elecFanPointsGroundController, 'Ground Floor')),
                      const SizedBox(width: 10),
                      Flexible(
                          child: _buildSpecificationField(
                              _elecFanPointsOtherController, 'Other Floors')),
                    ],
                  ),
                  _buildSubLabel("Spare plug points"),
                  Row(
                    children: [
                      Flexible(
                          child: _buildSpecificationField(
                              _elecPlugPointsGroundController, 'Ground Floor')),
                      const SizedBox(width: 10),
                      Flexible(
                          child: _buildSpecificationField(
                              _elecPlugPointsOtherController, 'Other Floors')),
                    ],
                  ),
                  _buildSubLabel("Any other item"),
                  Row(
                    children: [
                      Flexible(
                          child: _buildSpecificationField(
                              _elecOtherGroundController, 'Ground Floor')),
                      const SizedBox(width: 10),
                      Flexible(
                          child: _buildSpecificationField(
                              _elecOtherOtherController, 'Other Floors')),
                    ],
                  ),
                  const SizedBox(height: 15),

                  // 4. Plumbing installation
                  const Padding(
                    padding:
                        EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                    child: Text("4. Plumbing installation",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  _buildSubLabel("a) No. of water closets and their type"),
                  Row(
                    children: [
                      Flexible(
                          child: _buildSpecificationField(
                              _plumClosetsGroundController, 'Ground Floor')),
                      const SizedBox(width: 10),
                      Flexible(
                          child: _buildSpecificationField(
                              _plumClosetsOtherController, 'Other Floors')),
                    ],
                  ),
                  _buildSubLabel("b) No. of wash basins"),
                  Row(
                    children: [
                      Flexible(
                          child: _buildSpecificationField(
                              _plumBasinsGroundController, 'Ground Floor')),
                      const SizedBox(width: 10),
                      Flexible(
                          child: _buildSpecificationField(
                              _plumBasinsOtherController, 'Other Floors')),
                    ],
                  ),
                  _buildSubLabel("c) No. of urinals"),
                  Row(
                    children: [
                      Flexible(
                          child: _buildSpecificationField(
                              _plumUrinalsGroundController, 'Ground Floor')),
                      const SizedBox(width: 10),
                      Flexible(
                          child: _buildSpecificationField(
                              _plumUrinalsOtherController, 'Other Floors')),
                    ],
                  ),
                  _buildSubLabel("d) No. of bath tubs"),
                  Row(
                    children: [
                      Flexible(
                          child: _buildSpecificationField(
                              _plumTubsGroundController, 'Ground Floor')),
                      const SizedBox(width: 10),
                      Flexible(
                          child: _buildSpecificationField(
                              _plumTubsOtherController, 'Other Floors')),
                    ],
                  ),
                  _buildSubLabel("e) Water meter, taps, etc."),
                  Row(
                    children: [
                      Flexible(
                          child: _buildSpecificationField(
                              _plumMetersGroundController, 'Ground Floor')),
                      const SizedBox(width: 10),
                      Flexible(
                          child: _buildSpecificationField(
                              _plumMetersOtherController, 'Other Floors')),
                    ],
                  ),
                  _buildSubLabel("f) Any other fixtures"),
                  Row(
                    children: [
                      Flexible(
                          child: _buildSpecificationField(
                              _plumFixturesGroundController, 'Ground Floor')),
                      const SizedBox(width: 10),
                      Flexible(
                          child: _buildSpecificationField(
                              _plumFixturesOtherController, 'Other Floors')),
                    ],
                  ),

                  const SizedBox(height: 15),

                  TextFormField(
                    controller: _stageofcontruction,
                    decoration: InputDecoration(
                      labelText: 'Stage of Construction',
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
              const SizedBox(height: 20),
              //page 6 (new format)
              ExpansionTile(
                title: const Text(
                  'Details of Valuation',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                initiallyExpanded: false,
                children: <Widget>[
                  const Divider(),

                  // --- 1. Ground Floor (GF) ---
                  const Padding(
                    padding:
                        EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                    child: Text("1. Ground Floor (GF)",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.blue)),
                  ),
                  Row(
                    children: [
                      Flexible(
                          child: _buildSpecificationField(
                              _valPlinthGFController, 'Plinth area (Sqft)')),
                      const SizedBox(width: 10),
                      Flexible(
                          child: _buildSpecificationField(
                              _valRoofHeightGFController, 'Roof height')),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Flexible(
                          child: _buildSpecificationField(
                              _valAgeGFController, 'Age of building')),
                      const SizedBox(width: 10),
                      Flexible(
                          child: _buildSpecificationField(
                              _valRateGFController, 'Replacement rate/sqft')),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Flexible(
                          child: _buildSpecificationField(
                              _valReplaceCostGFController,
                              'Replacement cost Rs.')),
                      const SizedBox(width: 10),
                      Flexible(
                          child: _buildSpecificationField(
                              _valDepreciationGFController,
                              'Depreciation Rs.')),
                    ],
                  ),
                  _buildSubLabel("Net value after depreciation"),
                  _buildSpecificationField(
                      _valNetValueGFController, 'Net Value (GF)'),

                  const SizedBox(height: 15),
                  const Divider(),

                  // --- 2. First Floor (FF) ---
                  const Padding(
                    padding:
                        EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                    child: Text("2. First Floor (FF)",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.blue)),
                  ),
                  Row(
                    children: [
                      Flexible(
                          child: _buildSpecificationField(
                              _valPlinthFFController, 'Plinth area (Sqft)')),
                      const SizedBox(width: 10),
                      Flexible(
                          child: _buildSpecificationField(
                              _valRoofHeightFFController, 'Roof height')),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Flexible(
                          child: _buildSpecificationField(
                              _valAgeFFController, 'Age of building')),
                      const SizedBox(width: 10),
                      Flexible(
                          child: _buildSpecificationField(
                              _valRateFFController, 'Replacement rate/sqft')),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Flexible(
                          child: _buildSpecificationField(
                              _valReplaceCostFFController,
                              'Replacement cost Rs.')),
                      const SizedBox(width: 10),
                      Flexible(
                          child: _buildSpecificationField(
                              _valDepreciationFFController,
                              'Depreciation Rs.')),
                    ],
                  ),
                  _buildSubLabel("Net value after depreciation"),
                  _buildSpecificationField(
                      _valNetValueFFController, 'Net Value (FF)'),

                  const SizedBox(height: 15),
                  const Divider(),

                  // --- 3. Totals ---
                  const Padding(
                    padding:
                        EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                    child: Text("Summary / Totals",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  Row(
                    children: [
                      Flexible(
                          child: _buildSpecificationField(
                              _valTotalPlinthController, 'Total Plinth Area')),
                      const SizedBox(width: 10),
                      Flexible(
                          child: _buildSpecificationField(
                              _valTotalReplaceCostController,
                              'Total Replace Cost')),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Flexible(
                          child: _buildSpecificationField(
                              _valTotalDepreciationController,
                              'Total Depreciation')),
                      const SizedBox(width: 10),
                      Flexible(
                          child: _buildSpecificationField(
                              _valTotalNetValueController, 'Total Net Value')),
                    ],
                  ),

                  const SizedBox(height: 20),
                ],
              ),

              const SizedBox(height: 20),
              ExpansionTile(
                title: const Text(
                  'Extra Items, Amenities & Services',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                initiallyExpanded: false,
                children: <Widget>[
                  const Divider(),

                  // --- PART C: EXTRA ITEMS ---
                  const Padding(
                    padding:
                        EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                    child: Text("Part C - Extra Items",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.blue)),
                  ),
                  _buildSpecificationField(
                      _extraPorticoController, '1. Portico'),
                  const SizedBox(height: 12),
                  _buildSpecificationField(_extraOrnamentalDoorController,
                      '2. Ornamental front door'),
                  const SizedBox(height: 12),
                  _buildSpecificationField(_extraSitoutController,
                      '3. Sit out/ Verandah with steel grills'),
                  const SizedBox(height: 12),
                  _buildSpecificationField(
                      _extraWaterTankController, '4. Overhead water tank'),
                  const SizedBox(height: 12),
                  _buildSpecificationField(_extraSteelGatesController,
                      '5. Extra steel/ collapsible gates'),
                  const SizedBox(height: 12),
                  _buildSpecificationField(
                      _extraTotalController, 'Total (Part C)'),

                  const Divider(
                      height:
                          32), // Added height to the divider for extra separation

                  // --- PART D: AMENITIES ---
                  const Padding(
                    padding:
                        EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                    child: Text("Part D - Amenities",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.blue)),
                  ),
                  Row(
                    children: [
                      Flexible(
                          child: _buildSpecificationField(
                              _amenWardrobesController, '1. Wardrobes')),
                      const SizedBox(width: 10),
                      Flexible(
                          child: _buildSpecificationField(
                              _amenGlazedTilesController, '2. Glazed tiles')),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Flexible(
                          child: _buildSpecificationField(
                              _amenSinksTubsController,
                              '3. Extra sinks/bath tub')),
                      const SizedBox(width: 10),
                      Flexible(
                          child: _buildSpecificationField(
                              _amenFlooringController,
                              '4. Marble/Ceramic flooring')),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildSpecificationField(
                      _amenDecorationsController, '5. Interior decorations'),
                  const SizedBox(height: 12),
                  _buildSpecificationField(_amenElevationController,
                      '6. Architectural elevation works'),
                  const SizedBox(height: 12),
                  _buildSpecificationField(
                      _amenPanellingController, '7. Panelling works'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Flexible(
                          child: _buildSpecificationField(
                              _amenAluminiumWorksController,
                              '8. Aluminium works')),
                      const SizedBox(width: 10),
                      Flexible(
                          child: _buildSpecificationField(
                              _amenHandRailsController,
                              '9. Aluminium hand rails')),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildSpecificationField(
                      _amenFalseCeilingController, '10. False ceiling'),
                  const SizedBox(height: 12),
                  _buildSpecificationField(
                      _amenTotalController, 'Total (Part D)'),

                  const Divider(height: 32),

                  // --- PART E: MISCELLANEOUS ---
                  const Padding(
                    padding:
                        EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                    child: Text("Part E - Miscellaneous",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.blue)),
                  ),
                  _buildSpecificationField(
                      _miscToiletRoomController, '1. Separate toilet room'),
                  const SizedBox(height: 12),
                  _buildSpecificationField(
                      _miscLumberRoomController, '2. Separate lumber room'),
                  const SizedBox(height: 12),
                  _buildSpecificationField(
                      _miscSumpController, '3. Separate water tank/ sump'),
                  const SizedBox(height: 12),
                  _buildSpecificationField(
                      _miscGardeningController, '4. Trees, gardening'),
                  const SizedBox(height: 12),
                  _buildSpecificationField(
                      _miscTotalController, 'Total (Part E)'),

                  const Divider(height: 32),

                  // --- PART F: SERVICES ---
                  const Padding(
                    padding:
                        EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                    child: Text("Part F - Services",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.blue)),
                  ),
                  _buildSpecificationField(_servWaterSupplyController,
                      '1. Water supply arrangements'),
                  const SizedBox(height: 12),
                  _buildSpecificationField(
                      _servDrainageController, '2. Drainage arrangements'),
                  const SizedBox(height: 12),
                  _buildSpecificationField(
                      _servCompoundWallController, '3. Compound wall'),
                  const SizedBox(height: 12),
                  _buildSpecificationField(_servDepositsController,
                      '4. C. B. deposits, fittings etc.'),
                  const SizedBox(height: 12),
                  _buildSpecificationField(
                      _servPavementController, '5. Pavement'),
                  const SizedBox(height: 12),
                  _buildSpecificationField(
                      _servTotalController, 'Total (Part F)'),

                  const SizedBox(height: 20),
                ],
              ),

              // Collapsible Section: Total abstract of the entire property
              ExpansionTile(
                title: const Text(
                  'Total abstract of the entire property',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                initiallyExpanded: false,
                children: <Widget>[
                  const Divider(),
                  TextField(
                    // Changed from _buildTextField
                    controller: _totalAbstractLandController,
                    decoration: const InputDecoration(
                      labelText: 'Part- A Land (Amount in Rs.)',
                      hintText: 'e.g., 3750000',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 13),
                  TextField(
                    // Changed from _buildTextField
                    controller: _totalAbstractBuildingController,
                    decoration: const InputDecoration(
                      labelText: 'Part- B Building (Amount in Rs.)',
                      hintText: 'e.g., 2500000',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 13),
                  TextField(
                    // Changed from _buildTextField
                    controller: _totalAbstractExtraItemsController,
                    decoration: const InputDecoration(
                      labelText: 'Part- C Extra Items (Amount in Rs.)',
                      hintText: 'e.g., 80000',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 13,
                  ),
                  TextField(
                    // Changed from _buildTextField
                    controller: _totalAbstractAmenitiesController,
                    decoration: const InputDecoration(
                      labelText: 'Part- D Amenities (Amount in Rs.)',
                      hintText: 'e.g., 80000',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 13),
                  TextField(
                    // Changed from _buildTextField
                    controller: _totalAbstractMiscController,
                    decoration: const InputDecoration(
                      labelText: 'Part- E Miscellaneous (Amount in Rs.)',
                      hintText: 'e.g., 6330000',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 13),
                  TextField(
                    // Changed from _buildTextField
                    controller: _totalAbstractServiceController,
                    decoration: const InputDecoration(
                      labelText: 'Part- F Services (Amount in Rs.)',
                      hintText: 'e.g., 6330000',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Collapsible Section: Consolidated Remarks/ Observations of the property
              ExpansionTile(
                title: const Text(
                  'Consolidated Remarks/ Observations of the property:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                initiallyExpanded: false,
                children: <Widget>[
                  const Divider(),
                  TextField(
                    // Changed from _buildTextField
                    controller: _remark1Controller,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: '1.',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 13),
                  TextField(
                    // Changed from _buildTextField
                    controller: _remark2Controller,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: '2.',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 13),
                  TextField(
                    // Changed from _buildTextField
                    controller: _remark3Controller,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: '3.',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 13),
                  TextField(
                    // Changed from _buildTextField
                    controller: _remark4Controller,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: '4.',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // NEW: Collapsible Section: Final Valuation
              ExpansionTile(
                title: const Text(
                  'Final Valuation',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                initiallyExpanded: false,
                children: <Widget>[
                  const Divider(),
                  TextField(
                    // Changed from _buildTextField
                    controller: _presentMarketValueController,
                    decoration: const InputDecoration(
                      labelText: 'Present Market Value of The Property',
                      hintText: 'Enter value',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 13),
                  TextField(
                    // Changed from _buildTextField
                    controller: _realizableValueController,
                    decoration: const InputDecoration(
                      labelText: 'Realizable Value of the Property',
                      hintText: 'Enter value',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 13),
                  TextField(
                    // Changed from _buildTextField
                    controller: _distressValueController,
                    decoration: const InputDecoration(
                      labelText: 'Distress Value of the Property',
                      hintText: 'Enter value',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 13),
                  TextField(
                    // Changed from _buildTextField
                    controller: _place,
                    decoration: const InputDecoration(
                      labelText: 'Place',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // NEW: Collapsible Section: Declaration Details (for FORMAT E dates)
              ExpansionTile(
                title: const Text(
                  'Declaration Details (FORMAT E)',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                initiallyExpanded: false,
                children: <Widget>[
                  const Divider(),
                  TextField(
                    // Changed from _buildTextField
                    controller: _declarationDateAController,
                    readOnly: true,
                    onTap: () =>
                        _selectDate(context, _declarationDateAController),
                    decoration: const InputDecoration(
                      labelText:
                          'Valuation report date in Declaration (FORMAT E)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 13),
                  TextField(
                    // Changed from _buildTextField
                    controller: _declarationDateCController,
                    readOnly: true,
                    onTap: () =>
                        _selectDate(context, _declarationDateCController),
                    decoration: const InputDecoration(
                      labelText:
                          'Property inspection date in Declaration (FORMAT E)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // NEW: Collapsible Section: Valuer Comments
              ExpansionTile(
                title: const Text(
                  'Valuer Comments / Observations',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                initiallyExpanded: false,
                children: <Widget>[
                  const Divider(),
                  _buildValuerCommentRow(
                    '1',
                    'background information of the asset being valued;',
                    _vcBackgroundInfoController,
                    hintText:
                        'e.g., The property is a 1.62 Ares residential building',
                  ),
                  _buildValuerCommentRow(
                    '2',
                    'purpose of valuation and appointing authority',
                    _vcPurposeOfValuationController,
                    hintText:
                        'e.g., To assess the present fair market value...',
                  ),
                  _buildValuerCommentRow(
                    '3',
                    'identity of the valuer and any other experts involved in the valuation;',
                    _vcIdentityOfValuerController,
                    hintText: 'e.g., Vignesh S',
                  ),
                  _buildValuerCommentRow(
                    '4',
                    'disclosure of valuer interest or conflict, if any;',
                    _vcDisclosureOfInterestController,
                    hintText:
                        'e.g., The property was not physically measured...',
                  ),
                  _buildValuerCommentRow(
                    '5',
                    'date of appointment, valuation date and date of report;',
                    _vcDateOfAppointmentController,
                    hintText: 'e.g., 02-09-2024, 04-09-2024, 06-09-2024',
                  ),
                  _buildValuerCommentRow(
                    '6',
                    'inspections and/or investigations undertaken;',
                    _vcInspectionsUndertakenController,
                    hintText: 'e.g., The property was inspected on 04-09-2024',
                  ),
                  _buildValuerCommentRow(
                    '7',
                    'nature and sources of the information used or relied upon;',
                    _vcNatureAndSourcesController,
                    hintText: 'e.g., Documents submitted for verification',
                  ),
                  _buildValuerCommentRow(
                    '8',
                    'procedures adopted in carrying out the valuation and valuation standards followed;',
                    _vcProceduresAdoptedController,
                    hintText:
                        'e.g., Comparable Sale Method & Replacement Method',
                  ),
                  _buildValuerCommentRow(
                    '9',
                    'restrictions on use of the report, if any;',
                    _vcRestrictionsOnUseController,
                    hintText:
                        'e.g., This report shall be used to determine the present market value...',
                  ),
                  _buildValuerCommentRow(
                    '10',
                    'major factors that were taken into account during the valuation;',
                    _vcMajorFactors1Controller,
                    hintText:
                        'e.g., The Land extent considered is as per the revenue records...',
                  ),
                  _buildValuerCommentRow(
                    '11',
                    'major factors that were taken into account during the valuation;',
                    _vcMajorFactors2Controller,
                    hintText:
                        'e.g., The building extent considered in this report is as per the measurement...',
                  ),
                  _buildValuerCommentRow(
                    '12',
                    'Caveats, limitations and disclaimers to the extent they explain or elucidate the limitations faced by valuer, which shall not be for the purpose of limiting his responsibility for the valuation report.',
                    _vcCaveatsLimitationsController,
                    hintText:
                        'e.g., The value is an estimate considering the local enquiry...',
                    maxLines: 3, // Allow more lines for this longer text
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // NEW: Collapsible Section: Photos
              ExpansionTile(
                title: const Text(
                  'Photos',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                initiallyExpanded: false,
                children: <Widget>[
                  const Divider(),
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.add_a_photo),
                      label: const Text('Add Photo'),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.blueAccent,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _images.isEmpty
                      ? const Center(child: Text('No photos uploaded yet.'))
                      : GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 1.0, // Make images square
                          ),
                          itemCount: _images.length,
                          itemBuilder: (context, index) {
                            final imageItem = _images[index];
                            Widget imageWidget;

                            // MODIFIED: Conditionally render Image.file or Image.memory
                            if (imageItem is Uint8List) {
                              imageWidget = Image.memory(
                                imageItem,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                              );
                            } else if (imageItem is File) {
                              imageWidget = Image.file(
                                imageItem,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                              );
                            } else {
                              // Fallback for unexpected types (shouldn't happen with current logic)
                              imageWidget = Center(
                                child: Text(
                                  'Invalid image type: ${imageItem.runtimeType}',
                                ),
                              );
                            }

                            return Stack(
                              children: [
                                imageWidget,
                                Positioned(
                                  top: 5,
                                  right: 5,
                                  child: GestureDetector(
                                    onTap: () => _removeImage(index),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.red.withOpacity(0.7),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      padding: const EdgeInsets.all(4),
                                      child: const Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                ],
              ),
              const SizedBox(height: 20),

              Center(
                child: ElevatedButton.icon(
                  onPressed: _generatePdf,
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text(
                    'Generate PDF Report',
                    style: TextStyle(fontSize: 18),
                  ),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.blue, // Text color
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 15,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 5,
                    shadowColor: Colors.blueAccent.withOpacity(0.5),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _saveData();
        },
        icon: const Icon(Icons.save),
        label: const Text('Save'),
      ),
    );
  }

  // Helper widget for boundary rows
  Widget _buildBoundaryRow(
    String direction,
    TextEditingController titleController,
    TextEditingController sketchController,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(direction)),
          const Expanded(flex: 1, child: Text(':')), // Separated colon
          Expanded(
            flex: 3,
            child: TextField(
              // Changed from _buildTextField
              controller: titleController,
              decoration: const InputDecoration(
                labelText: '', // No label for internal table fields
                hintText: 'As per Title Deed',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ), // Applied new styling
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 3,
            child: TextField(
              // Changed from _buildTextField
              controller: sketchController,
              decoration: const InputDecoration(
                labelText: '', // No label for internal table fields
                hintText: 'As per Location Sketch',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ), // Applied new styling
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper widget for dimensions rows
  Widget _buildDimensionsRow(
    String direction,
    TextEditingController actualsController,
    TextEditingController documentsController, {
    bool isTotalArea = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(direction)),
          Expanded(
            flex: 3,
            child: TextField(
              // Changed from _buildTextField
              controller: actualsController,
              decoration: const InputDecoration(
                labelText: '',
                hintText: 'As per Actuals',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ), // Applied new styling
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 3,
            child: TextField(
              // Changed from _buildTextField
              controller: documentsController,
              decoration: const InputDecoration(
                labelText: '',
                hintText: 'As per Documents',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ), // Applied new styling
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Expanded(
          //   flex: 3,
          //   child: TextField(
          //     // Changed from _buildTextField
          //     controller: adoptedController,
          //     decoration: const InputDecoration(
          //       labelText: '',
          //       hintText: 'Adopted area in Sft',
          //       border: OutlineInputBorder(
          //         borderRadius: BorderRadius.all(Radius.circular(20)),
          //       ), // Applied new styling
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }

  // New Helper widget for floor detail rows (for UI)
  Widget _buildFloorDetailRow(
    String floorName,
    TextEditingController occupancyController,
    TextEditingController roomController,
    TextEditingController kitchenController,
    TextEditingController bathroomController,
    TextEditingController remarksController,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.only(
                top: 12.0,
              ), // Align text vertically
              child: Text(floorName),
            ),
          ),
          Expanded(
            flex: 2,
            child: TextField(
              // Changed from _buildTextField
              controller: occupancyController,
              decoration: const InputDecoration(
                labelText: '',
                hintText: 'Self/Rented',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ), // Applied new styling
              ),
            ),
          ),
          const SizedBox(width: 5),
          Expanded(
            flex: 1,
            child: TextField(
              // Changed from _buildTextField
              controller: roomController,
              decoration: const InputDecoration(
                labelText: '',
                hintText: '#Rooms',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ), // Applied new styling
              ),
            ),
          ),
          const SizedBox(width: 5),
          Expanded(
            flex: 1,
            child: TextField(
              // Changed from _buildTextField
              controller: kitchenController,
              decoration: const InputDecoration(
                labelText: '',
                hintText: '#Kitchen',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ), // Applied new styling
              ),
            ),
          ),
          const SizedBox(width: 5),
          Expanded(
            flex: 1,
            child: TextField(
              // Changed from _buildTextField
              controller: bathroomController,
              decoration: const InputDecoration(
                labelText: '',
                hintText: '#Bathroom',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ), // Applied new styling
              ),
            ),
          ),
          const SizedBox(width: 5),
          Expanded(
            flex: 2,
            child: TextField(
              // Changed from _buildTextField
              controller: remarksController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: '',
                hintText: 'Resi/Comm Remarks',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ), // Applied new styling
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper widget for Build up Area rows
  Widget _buildBuildUpAreaRow(
    String particularOfItem,
    TextEditingController approvedPlanController,
    TextEditingController actualController,
    TextEditingController consideredValuationController,
    TextEditingController replacementCostController,
    TextEditingController depreciationController,
    TextEditingController netValueController, {
    bool isTotal = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.only(
                top: 12.0,
              ), // Align text vertically
              child: Text(
                isTotal ? '' : '',
              ), // Empty for S n for non-total rows
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.only(
                top: 12.0,
              ), // Align text vertically
              child: Text(
                particularOfItem,
                style: TextStyle(
                  fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: TextField(
              // Changed from _buildTextField
              controller: approvedPlanController,
              decoration: InputDecoration(
                labelText: '',
                hintText: isTotal ? 'Total Approved' : 'Approved Plan/FSI',
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ), // Applied new styling
              ),
            ),
          ),
          const SizedBox(width: 5),
          Expanded(
            flex: 2,
            child: TextField(
              // Changed from _buildTextField
              controller: actualController,
              decoration: InputDecoration(
                labelText: '',
                hintText: isTotal ? 'Total Actual' : 'Actual',
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ), // Applied new styling
              ),
            ),
          ),
          const SizedBox(width: 5),
          Expanded(
            flex: 2,
            child: TextField(
              // Changed from _buildTextField
              controller: consideredValuationController,
              decoration: InputDecoration(
                labelText: '',
                hintText:
                    isTotal ? 'Total Considered' : 'Considered for Valuation',
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ), // Applied new styling
              ),
            ),
          ),
          const SizedBox(width: 5),
          Expanded(
            flex: 2,
            child: TextField(
              // Changed from _buildTextField
              controller: replacementCostController,
              decoration: InputDecoration(
                labelText: '',
                hintText: isTotal ? 'Total Replacement' : 'Replacement Cost',
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ), // Applied new styling
              ),
            ),
          ),
          const SizedBox(width: 5),
          Expanded(
            flex: 2,
            child: TextField(
              // Changed from _buildTextField
              controller: depreciationController,
              decoration: InputDecoration(
                labelText: '',
                hintText: isTotal ? 'Total Depreciation' : 'Depreciation',
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ), // Applied new styling
              ),
            ),
          ),
          const SizedBox(width: 5),
          Expanded(
            flex: 2,
            child: TextField(
              // Changed from _buildTextField
              controller: netValueController,
              decoration: InputDecoration(
                labelText: '',
                hintText: isTotal ? 'Total Net Value' : 'Net Value',
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ), // Applied new styling
              ),
            ),
          ),
        ],
      ),
    );
  }

  // NEW: Helper widget for Valuer Comments table rows (for UI)
  Widget _buildValuerCommentRow(
    String siNo,
    String particulars,
    TextEditingController controller, {
    String? hintText,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child: Text(siNo),
            ),
          ),
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child: Text(particulars),
            ),
          ),
          Expanded(
            flex: 4,
            child: TextField(
              // Changed from _buildTextField
              controller: controller,
              maxLines: maxLines,
              decoration: InputDecoration(
                labelText: '',
                hintText: hintText,
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ), // Applied new styling
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Page 5 (New format)
  Widget _buildSpecificationField(
      TextEditingController controller, String label,
      {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
      ),
    );
  }

  Widget _buildSubLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 12.0, top: 8.0, bottom: 4.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          label,
          style: const TextStyle(
              fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}
