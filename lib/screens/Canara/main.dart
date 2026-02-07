import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:login_screen/ref_id.dart';
import 'package:login_screen/screens/Canara/savedDraftsCanara.dart';
import 'package:login_screen/screens/nearbyDetails.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';
import 'package:printing/printing.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'config.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';
import 'package:http/http.dart' as http;

// Add this class definition inside your state class
class ImageWithLocation {
  final Uint8List imageBytes;
  final double? latitude;
  final double? longitude;
  final DateTime timestamp;
  final String? description;

  ImageWithLocation({
    required this.imageBytes,
    this.latitude,
    this.longitude,
    String? description,
    DateTime? timestamp,
  })  : timestamp = timestamp ?? DateTime.now(),
        description = description ?? 'Property Image'; // Simplified description

  String get locationString {
    if (latitude != null && longitude != null) {
      return '${latitude!.toStringAsFixed(6)}, ${longitude!.toStringAsFixed(6)}';
    }
    return 'Location not available';
  }

  ImageWithLocation copyWith({
    Uint8List? imageBytes,
    double? latitude,
    double? longitude,
    DateTime? timestamp,
    String? description,
  }) {
    return ImageWithLocation(
      imageBytes: imageBytes ?? this.imageBytes,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      timestamp: timestamp ?? this.timestamp,
      description: description ?? this.description,
    );
  }
}

class PropertyValuationReportPage extends StatefulWidget {
  final Map<String, dynamic>? propertyData;
  const PropertyValuationReportPage({super.key, this.propertyData});

  @override
  _PropertyValuationReportPageState createState() =>
      _PropertyValuationReportPageState();
}

class _PropertyValuationReportPageState
    extends State<PropertyValuationReportPage> {
  @override
  void initState() {
    super.initState();
    if (widget.propertyData != null) {
      // Use the passed data to initialize your form if it exists
    } else {
      debugPrint('No property data received - creating new valuation');
    }
    _initializeFormWithPropertyData();
    _setupCalculations();
  }

  void _setupCalculations() {
    final areaControllers = [
      _gfAreaController,
      _gfCantileverController,
      _ffAreaController,
      _ffCantileverController,
      _terraceAreaController,
    ];
    for (var c in areaControllers) {
      c.addListener(_calculateTotals);
    }

    final amenityControllers = [
      _amenityPorticoController,
      _amenityOrnamentalDoorController,
      _amenitySitoutGrillsController,
      _amenitySteelGatesController,
      _amenityOpenStaircaseController,
      _amenityWardrobesController,
      _amenityGlazedTilesController,
      _amenityExtraSinksController,
      _amenityMarbleTilesController,
      _amenityInteriorDecorController,
      _amenityElevationWorksController,
      _amenityFalseCeilingController,
      _amenityPanelingWorksController,
      _amenityAluminumWorksController,
      _amenityAluminumHandrailsController,
      _amenityLumberRoomController,
      _amenityToiletRoomController,
      _amenityWaterTankSumpController,
      _amenityGardeningController,
      _amenityAnyOtherController,
      _amenityOpenWellController,
      _amenityDeepBoreController,
      _amenityHandPumpController,
      _amenityCorporationTapController,
      _amenityUndergroundSumpController,
      _amenityOverheadWaterTankController,
      _amenitySepticTankController,
      _amenityUndergroundSewerageController,
      _amenityCompoundWallController,
      _amenityPavementsController,
      _amenitySteelGateRmController,
      _amenityEBDepositsController,
      _amenityWaterDepositsController,
      _amenityDrainageDepositsController,
      _amenityAnyOtherItemController,
    ];
    for (var c in amenityControllers) {
      c.addListener(_calculateTotals);
    }

    final abstractControllers = [
      absLandGlrController,
      absLandPmrController,
      absBuildingGlrController,
      absBuildingPmrController,
      absExtraGlrController,
      absExtraPmrController,
      absAmenitiesGlrController,
      absAmenitiesPmrController,
    ];
    for (var c in abstractControllers) {
      c.addListener(_calculateTotals);
    }
  }

  void _calculateTotals() {
    double p(String s) => double.tryParse(s.replaceAll(',', '')) ?? 0.0;

    // 1. Area calculation
    double gfArea = p(_gfAreaController.text);
    double gfCant = p(_gfCantileverController.text);
    double gfTotal = gfArea + gfCant;
    if (_gfTotalController.text != (gfTotal > 0 ? gfTotal.toStringAsFixed(2) : '')) {
      _gfTotalController.text = gfTotal > 0 ? gfTotal.toStringAsFixed(2) : '';
    }

    double ffArea = p(_ffAreaController.text);
    double ffCant = p(_ffCantileverController.text);
    double ffTotal = ffArea + ffCant;
    if (_ffTotalController.text != (ffTotal > 0 ? ffTotal.toStringAsFixed(2) : '')) {
      _ffTotalController.text = ffTotal > 0 ? ffTotal.toStringAsFixed(2) : '';
    }

    double terraceArea = p(_terraceAreaController.text);
    if (_terraceTotalController.text != (terraceArea > 0 ? terraceArea.toStringAsFixed(2) : '')) {
      _terraceTotalController.text = terraceArea > 0 ? terraceArea.toStringAsFixed(2) : '';
    }

    double totalArea = gfTotal + ffTotal + terraceArea;
    if (_totalAreaController.text != (totalArea > 0 ? totalArea.toStringAsFixed(2) : '')) {
      _totalAreaController.text = totalArea > 0 ? totalArea.toStringAsFixed(2) : '';
    }

    // 2. Amenities Total
    double amenTotal = 0;
    final amCtrls = [
      _amenityPorticoController, _amenityOrnamentalDoorController, _amenitySitoutGrillsController,
      _amenitySteelGatesController, _amenityOpenStaircaseController, _amenityWardrobesController,
      _amenityGlazedTilesController, _amenityExtraSinksController, _amenityMarbleTilesController,
      _amenityInteriorDecorController, _amenityElevationWorksController, _amenityFalseCeilingController,
      _amenityPanelingWorksController, _amenityAluminumWorksController, _amenityAluminumHandrailsController,
      _amenityLumberRoomController, _amenityToiletRoomController, _amenityWaterTankSumpController,
      _amenityGardeningController, _amenityAnyOtherController, _amenityOpenWellController,
      _amenityDeepBoreController, _amenityHandPumpController, _amenityCorporationTapController,
      _amenityUndergroundSumpController, _amenityOverheadWaterTankController, _amenitySepticTankController,
      _amenityUndergroundSewerageController, _amenityCompoundWallController, _amenityPavementsController,
      _amenitySteelGateRmController, _amenityEBDepositsController, _amenityWaterDepositsController,
      _amenityDrainageDepositsController, _amenityAnyOtherItemController,
    ];
    for (var c in amCtrls) {
      amenTotal += p(c.text);
    }
    if (_amenityTotalController.text != (amenTotal > 0 ? amenTotal.toStringAsFixed(2) : '')) {
      _amenityTotalController.text = amenTotal > 0 ? amenTotal.toStringAsFixed(2) : '';
    }

    // 3. Abstract Total
    double totalGlr = p(absLandGlrController.text) + p(absBuildingGlrController.text) +
                      p(absExtraGlrController.text) + p(absAmenitiesGlrController.text);
    if (absTotalGlrController.text != (totalGlr > 0 ? totalGlr.toStringAsFixed(2) : '')) {
      absTotalGlrController.text = totalGlr > 0 ? totalGlr.toStringAsFixed(2) : '';
    }
    if (absSayGlrController.text != (totalGlr > 0 ? totalGlr.round().toString() : '')) {
      absSayGlrController.text = totalGlr > 0 ? totalGlr.round().toString() : '';
    }

    double totalPmr = p(absLandPmrController.text) + p(absBuildingPmrController.text) +
                      p(absExtraPmrController.text) + p(absAmenitiesPmrController.text);
    if (absTotalPmrController.text != (totalPmr > 0 ? totalPmr.toStringAsFixed(2) : '')) {
      absTotalPmrController.text = totalPmr > 0 ? totalPmr.toStringAsFixed(2) : '';
    }
    if (absSayPmrController.text != (totalPmr > 0 ? totalPmr.round().toString() : '')) {
      absSayPmrController.text = totalPmr > 0 ? totalPmr.round().toString() : '';
    }
  }

  double? _latitude;
  double? _longitude;
  String? _locationError;
  // Add these with your other state variables
  final List<ImageWithLocation> _imagesWithLocation = [];
  final ImagePicker _picker = ImagePicker();
  bool _isLoadingImages = false;
  Widget buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Please enter \$label';
          }
          return null;
        },
      ),
    );
  }

  // Future<void> _pickImages() async {
  //   setState(() => _isLoadingImages = true);
  //   try {
  //     if (!kIsWeb) {
  //       await _requestPermissions();
  //     }

  //     // This now correctly fetches and SETS the location state
  //     await _getCurrentLocation();

  //     // Only proceed to pick images if location was fetched successfully or user wants to proceed without it
  //     final List<XFile> pickedFiles = await _picker.pickMultiImage();
  //     for (var file in pickedFiles) {
  //       final bytes = await file.readAsBytes();
  //       setState(() {
  //         _imagesWithLocation.add(ImageWithLocation(
  //           imageBytes: bytes,
  //           latitude: _latitude,
  //           longitude: _longitude,
  //         ));
  //       });
  //     }
  //       } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Error picking images: ${e.toString()}')),
  //     );
  //   } finally {
  //     setState(() => _isLoadingImages = false);
  //   }
  // }
  Future<void> _pickImages(ImageSource source) async {
    setState(() => _isLoadingImages = true);
    try {
      // Get current location ONCE before picking images (you can move this inside the loop for per-image locations)
      // await _getCurrentLocation();

      List<XFile> pickedFiles = [];
      if (source == ImageSource.gallery) {
        pickedFiles = await _picker.pickMultiImage();
      } else {
        final photo = await _picker.pickImage(source: source, imageQuality: 80);
        if (photo != null) pickedFiles = [photo];
      }

      if (pickedFiles.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No images selected')),
          );
        }
        return;
      }

      for (var file in pickedFiles) {
        final bytes = await file.readAsBytes();
        setState(() {
          _imagesWithLocation.add(ImageWithLocation(
            imageBytes: bytes,
            latitude: _latitude,
            longitude: _longitude,
            timestamp: DateTime.now(),
            description: 'Property Photo',
          ));
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking images: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoadingImages = false);
    }
  }

  Future<void> _takePhoto() async {
    setState(() => _isLoadingImages = true);
    try {
      if (!kIsWeb) {
        await _requestPermissions();
      }

      // This now correctly fetches and SETS the location state
      // await _getCurrentLocation();

      final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
      if (photo != null) {
        final bytes = await photo.readAsBytes();
        setState(() {
          _imagesWithLocation.add(ImageWithLocation(
            imageBytes: bytes,
            latitude: _latitude,
            longitude: _longitude,
            description: 'Property Photo',
          ));
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error taking photo: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoadingImages = false);
    }
  }

  Future<void> _requestPermissions() async {
    var cameraStatus = await Permission.camera.status;
    if (!cameraStatus.isGranted) {
      cameraStatus = await Permission.camera.request();
      if (!cameraStatus.isGranted) {
        throw Exception('Camera permission denied');
      }
    }

    var locationStatus = await Permission.location.status;
    if (!locationStatus.isGranted) {
      locationStatus = await Permission.location.request();
      if (!locationStatus.isGranted) {
        throw Exception('Location permission denied');
      }
    }
  }

  final _formKey = GlobalKey<FormState>();

  // Part A - Basic Data
  final _referenceNoController = TextEditingController();
  final _reportDateController = TextEditingController();
  final _purposeController = TextEditingController();
  final _inspectionDateController = TextEditingController();
  final _valuationDateController = TextEditingController();
  final _ownerNameController = TextEditingController();
  final _ownerAddressController = TextEditingController();
  final _documentsController = TextEditingController();
  final _propertyDescriptionController = TextEditingController();
  final _scopeController = TextEditingController();
  final _bankController = TextEditingController();

  // Part II - Description of Property
  final _propertyAddressController = TextEditingController();
  final _cityTownController = TextEditingController();
  final _residentialAreaController = TextEditingController();
  final _classificationController = TextEditingController();
  final _urbanClassificationController = TextEditingController();
  final _localAuthorityController = TextEditingController();
  final _govtActsController = TextEditingController();
  final _agriculturalConversionController = TextEditingController();
  final _blockNoController = TextEditingController();
  final _resurveyNoController = TextEditingController();
  final _surveyNoController = TextEditingController();
  final _thandapperNoController = TextEditingController();
  final _wardNoController = TextEditingController();
  final _doorNoController = TextEditingController();
  final _tsNoController = TextEditingController();
  final _talukController = TextEditingController();
  final _districtController = TextEditingController();
  final _northBoundaryController = TextEditingController();
  final _southBoundaryController = TextEditingController();
  final _eastBoundaryController = TextEditingController();
  final _westBoundaryController = TextEditingController();
  final _northBoundaryActualController = TextEditingController();
  final _southBoundaryActualController = TextEditingController();
  final _eastBoundaryActualController = TextEditingController();
  final _westBoundaryActualController = TextEditingController();
  final _latitudelongitudeController = TextEditingController();
  // final _longitudeController = TextEditingController();
  final _taxPeriodController = TextEditingController();
  final _buildingIdController = TextEditingController();
  final _assessmentNoController = TextEditingController();
  final _taxAmountController = TextEditingController();
  final _taxReceiptNameController = TextEditingController();
  final _consumerNoController = TextEditingController();
  final _electricityNameController = TextEditingController();
  final _otherDetailsController = TextEditingController();
  final _occupancyStatusController = TextEditingController();
  final _tenatedRentController = TextEditingController();
  final _monthlyRentController = TextEditingController();
  final _advanceAmountController = TextEditingController();
  final _fsiController = TextEditingController();
  final _plotCoverageController = TextEditingController();
  // Part B - Land
  final _northDeedController = TextEditingController();
  final _southDeedController = TextEditingController();
  final _eastDeedController = TextEditingController();
  final _westDeedController = TextEditingController();
  final _extentDeedController = TextEditingController();
  final _northActualController = TextEditingController();
  final _southActualController = TextEditingController();
  final _eastActualController = TextEditingController();
  final _westActualController = TextEditingController();
  final _extentActualController = TextEditingController();
  final _extentConsideredController = TextEditingController();
  final _plotSizeNSController = TextEditingController();
  final _plotSizeEWController = TextEditingController();
  final _totalExtentController = TextEditingController();
  final _localityCharacterController = TextEditingController();
  final _localityClassificationController = TextEditingController();
  final _surroundingDevelopmentController = TextEditingController();
  final _floodingController = TextEditingController();
  final _amenitiesController = TextEditingController();
  final _landLevelController = TextEditingController();
  final _landShapeController = TextEditingController();
  final _landUseController = TextEditingController();
  final _usageRestrictionController = TextEditingController();
  final _townPlanningController = TextEditingController();
  final _plotTypeController = TextEditingController();
  final _roadFacilitiesController = TextEditingController();
  final _roadTypeController = TextEditingController();
  final _roadWidthController = TextEditingController();
  final _landLockedController = TextEditingController();
  final _waterPotentialController = TextEditingController();
  final _sewerageController = TextEditingController();
  final _powerSupplyController = TextEditingController();
  final _siteAdvantagesController = TextEditingController();
  final _specialRemarksController = TextEditingController();
  final _glrRateController = TextEditingController();
  final _glrValueController = TextEditingController();
  final _pmrRateController = TextEditingController();
  final _pmrAdoptedController = TextEditingController();
  final _pmrAdoptedValueController = TextEditingController();
  final _pmrValueController = TextEditingController();
  // Part C - Buildings
  final _buildingTypeController = TextEditingController();
  final _constructionTypeController = TextEditingController();
  final _constructionQualityController = TextEditingController();
  final _appearanceController = TextEditingController();
  final _exteriorConditionController = TextEditingController();
  final _interiorConditionController = TextEditingController();
  final _plinthAreaController = TextEditingController();
  final _floorsController = TextEditingController();
  final _gfYearController = TextEditingController();
  final _gfRoofController = TextEditingController();
  final _gfAreaController = TextEditingController();
  final _gfCantileverController = TextEditingController();
  final _gfTotalController = TextEditingController();
  final _ffYearController = TextEditingController();
  final _ffRoofController = TextEditingController();
  final _ffAreaController = TextEditingController();
  final _ffCantileverController = TextEditingController();
  final _ffTotalController = TextEditingController();
  final _terraceYearController = TextEditingController();
  final _terraceRoofController = TextEditingController();
  final _terraceAreaController = TextEditingController();
  final _terraceTotalController = TextEditingController();
  final _totalAreaController = TextEditingController();
  final _approvedPlanNoController = TextEditingController();
  final _approvedPlanAuthorityController = TextEditingController();
  final _planVerifiedController = TextEditingController();
  final _gfSpecificationController = TextEditingController();
  final _gfFloorFinishController = TextEditingController();
  final _gfSuperStructureController = TextEditingController();
  final _gfRoofTypeController = TextEditingController();
  final _gfDoorsController = TextEditingController();
  final _gfWindowsController = TextEditingController();
  final _gfWeatheringController = TextEditingController();
  final _gfConstructionYearController = TextEditingController();
  final _gfAgeController = TextEditingController();
  final _gfRemainingLifeController = TextEditingController();
  final _gfDepreciationController = TextEditingController();
  final _gfReplacementRateController = TextEditingController();
  final _ffSpecificationController = TextEditingController();
  final _ffFloorFinishController = TextEditingController();
  final _ffSuperStructureController = TextEditingController();
  final _ffRoofTypeController = TextEditingController();
  final _ffDoorsController = TextEditingController();
  final _ffWindowsController = TextEditingController();
  final _ffWeatheringController = TextEditingController();
  final _ffConstructionYearController = TextEditingController();
  final _ffAgeController = TextEditingController();
  final _ffRemainingLifeController = TextEditingController();
  final _ffDepreciationController = TextEditingController();
  final _ffReplacementRateController = TextEditingController();
  final _presentValueController = TextEditingController();

  // Valuer details
  final _valuerNameController = TextEditingController();
  final _valuerAddressController = TextEditingController();
  final _valuerPhoneController = TextEditingController();
  final _valuerEmailController = TextEditingController();
  final _valuerRegNoController = TextEditingController();
  final _valuerIBBIRegController = TextEditingController();
  final _valuerWealthTaxRegController = TextEditingController();
  final _valuerBlackMoneyRegController = TextEditingController();

  //Part D-Amenities
  // Controllers for Part D - Amenities & Extra Items (including all sub-fields)

// Main items 1-20
  final _amenityPorticoController = TextEditingController();
  final _amenityOrnamentalDoorController = TextEditingController();
  final _amenitySitoutGrillsController = TextEditingController();
  final _amenitySteelGatesController = TextEditingController();
  final _amenityOpenStaircaseController = TextEditingController();
  final _amenityWardrobesController = TextEditingController();
  final _amenityGlazedTilesController = TextEditingController();
  final _amenityExtraSinksController = TextEditingController();
  final _amenityMarbleTilesController = TextEditingController();
  final _amenityInteriorDecorController = TextEditingController();
  final _amenityElevationWorksController = TextEditingController();
  final _amenityFalseCeilingController = TextEditingController();
  final _amenityPanelingWorksController = TextEditingController();
  final _amenityAluminumWorksController = TextEditingController();
  final _amenityAluminumHandrailsController = TextEditingController();
  final _amenityLumberRoomController = TextEditingController();
  final _amenityToiletRoomController = TextEditingController();
  final _amenityWaterTankSumpController = TextEditingController();
  final _amenityGardeningController = TextEditingController();
  final _amenityAnyOtherController = TextEditingController();

// Water supply arrangements
  final _amenityOpenWellController = TextEditingController();
  final _amenityDeepBoreController = TextEditingController();
  final _amenityHandPumpController = TextEditingController();
  final _amenityCorporationTapController = TextEditingController();
  final _amenityUndergroundSumpController = TextEditingController();
  final _amenityOverheadWaterTankController = TextEditingController();

// Drainage arrangements
  final _amenitySepticTankController = TextEditingController();
  final _amenityUndergroundSewerageController = TextEditingController();

// Compound wall, pavements, steel gate
  final _amenityCompoundWallController = TextEditingController();
  final _amenityCompoundWallHeightController = TextEditingController();
  final _amenityCompoundWallLengthController = TextEditingController();
  final _amenityCompoundWallTypeController = TextEditingController();

  final _amenityPavementsController = TextEditingController();

  final _amenitySteelGateRmController = TextEditingController();

// Deposits
  final _amenityEBDepositsController = TextEditingController();
  final _amenityWaterDepositsController = TextEditingController();
  final _amenityDrainageDepositsController = TextEditingController();

// Electrical fittings & others
  final _amenityWiringTypeController = TextEditingController();
  final _amenityFittingsClassController = TextEditingController();
  final _amenityLightPointsController = TextEditingController();
  final _amenityFanPointsController = TextEditingController();
  final _amenityPlugPointsController = TextEditingController();
  final _amenityElectricalOtherController = TextEditingController();

// Plumbing installation
  final _amenityNoOfClosetsController = TextEditingController();
  final _amenityClosetsTypeController = TextEditingController();
  final _amenityNoOfWashBasinsController = TextEditingController();
  final _amenityNoOfBathTubsController = TextEditingController();
  final _amenityWaterMeterTapsController = TextEditingController();
  final _amenityPlumbingOtherFixturesController = TextEditingController();

// Any other & Total
  final _amenityAnyOtherItemController = TextEditingController();
  final _amenityTotalController = TextEditingController();
// Place these in your _PropertyValuationReportPageState class with other controllers

  final TextEditingController absLandGlrController = TextEditingController();
  final TextEditingController absLandPmrController = TextEditingController();
  final TextEditingController absBuildingGlrController =
      TextEditingController();
  final TextEditingController absBuildingPmrController =
      TextEditingController();
  final TextEditingController absExtraGlrController = TextEditingController();
  final TextEditingController absExtraPmrController = TextEditingController();
  final TextEditingController absAmenitiesGlrController =
      TextEditingController();
  final TextEditingController absAmenitiesPmrController =
      TextEditingController();
  final TextEditingController absTotalGlrController = TextEditingController();
  final TextEditingController absTotalPmrController = TextEditingController();
  final TextEditingController absSayGlrController = TextEditingController();
  final TextEditingController absSayPmrController = TextEditingController();
  // Add with other controllers
  final _commercialAreaController = TextEditingController();
  final _industrialAreaController = TextEditingController();
  // List<Uint8List> _pickedImages = [];
  bool _isGenerating = false;
  final _nearByLat = TextEditingController();
  final _nearByLong = TextEditingController();
  final _lat = TextEditingController();
  final _long = TextEditingController();
  bool _isNotValidState = false;

  Future<void> _getNearbyProperty() async {
    final latitude = _lat.text.trim();
    final longitude = _long.text.trim();

    // debugPrint(latitude);

    if (latitude.isEmpty || longitude.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please enter both latitude and longitude')),
      );
      return;
    }

    try {
      final url = Uri.parse(url2);
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'latitude': latitude,
          'longitude': longitude,
        }),
      );

      if (response.statusCode == 200) {
        // Decode the JSON response (assuming it's an array)
        final List<dynamic> responseData = jsonDecode(response.body);

        // Debug print the array
        // debugPrint('Response Data (Array):');
        // for (var item in responseData) {
        //   debugPrint(item.toString()); // Print each item in the array
        // }

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
              });
        }
      }

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Nearby properties fetched successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _saveToNearbyCollection() async {
    try {
      String fullCoordinates = _latitudelongitudeController.text;
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
        debugPrint(
            'Latitude or Longitude is missing from the controller. Skipping save to nearby collection.');

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'Location data is missing, cannot save to nearby properties.')),
        );
        return; // Exit the function early if coordinates are not valid.
      }

      final ownerName = _ownerNameController.text ?? '[is null]';
      final marketValue = _presentValueController.text ?? '[is null]';

      // debugPrint('------------------------------------------');
      // debugPrint('DEBUGGING SAVE TO NEARBY COLLECTION:');
      // debugPrint('Owner Name from Controller: "$ownerName"');
      // debugPrint('Market Value from Controller: "$marketValue"');
      // debugPrint('------------------------------------------');
      // --- STEP 3: Build the payload with the correct data ---
      final dataToSave = {
        // Use the coordinates from the image we found
        'refNo': _referenceNoController.text ?? '',
        'latitude': latitude,
        'longitude': longitude,

        'landValue': marketValue, // Use the variable we just created
        'nameOfOwner': ownerName,
        'bankName': 'Canara Bank',
      };

      // --- STEP 4: Send the data to your dedicated server endpoint ---
      final response = await http.post(
        Uri.parse(url5), // Use your dedicated URL for saving this data
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(dataToSave),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        debugPrint('Successfully saved data to nearby collection.');
      } else {
        debugPrint(
            'Failed to save to nearby collection: ${response.statusCode}');
        // debugPrint('Response body: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error in _saveToNearbyCollection: $e');
    }
  }

  Future<void> _saveData() async {
    try {
      // Validate required fields (adjust as needed)
      if (_referenceNoController.text.isEmpty) {
        debugPrint("Not all required fields available");
        // setState(() => _isNotValidState = true);
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please add reference number')));
        return;
      }

      // Example: Image validation (adjust as needed)
      if (_imagesWithLocation.isEmpty) {
        debugPrint("not all imgs available");
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please add at least one image')));
        return;
      }

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      var request = http.MultipartRequest('POST', Uri.parse(url1));

      // Add text fields from controllers
      request.fields.addAll({
        "referenceNo": _referenceNoController.text,
        "Date": DateFormat('yyyy-MM-dd').format(DateTime.now()),
        "purpose": _purposeController.text,
        "inspectionDate": _inspectionDateController.text,
        "valuationDate": _valuationDateController.text,
        "ownerName": _ownerNameController.text,
        "ownerAddress": _ownerAddressController.text,
        "documents": _documentsController.text,
        "propertyDescription": _propertyDescriptionController.text,
        "scope": _scopeController.text,
        "bank": _bankController.text,
        "propertyAddress": _propertyAddressController.text,
        "cityTown": _cityTownController.text,
        "residentialArea": _residentialAreaController.text,
        "classification": _classificationController.text,
        "urbanClassification": _urbanClassificationController.text,
        "localAuthority": _localAuthorityController.text,
        "govtActs": _govtActsController.text,
        "agriculturalConversion": _agriculturalConversionController.text,
        "blockNo": _blockNoController.text,
        "resurveyNo": _resurveyNoController.text,
        "surveyNo": _surveyNoController.text,
        "thandapperNo": _thandapperNoController.text,
        "wardNo": _wardNoController.text,
        "doorNo": _doorNoController.text,
        "tsNo": _tsNoController.text,
        "taluk": _talukController.text,
        "district": _districtController.text,
        "northBoundary": _northBoundaryController.text,
        "southBoundary": _southBoundaryController.text,
        "eastBoundary": _eastBoundaryController.text,
        "westBoundary": _westBoundaryController.text,
        "northBoundaryActual": _northBoundaryActualController.text,
        "southBoundaryActual": _southBoundaryActualController.text,
        "eastBoundaryActual": _eastBoundaryActualController.text,
        "westBoundaryActual": _westBoundaryActualController.text,
        "latitudelongitude": _latitudelongitudeController.text,
        "taxPeriod": _taxPeriodController.text,
        "buildingId": _buildingIdController.text,
        "assessmentNo": _assessmentNoController.text,
        "taxAmount": _taxAmountController.text,
        "taxReceiptName": _taxReceiptNameController.text,
        "consumerNo": _consumerNoController.text,
        "electricityName": _electricityNameController.text,
        "otherDetails": _otherDetailsController.text,
        "occupancyStatus": _occupancyStatusController.text,
        "tenatedRent": _tenatedRentController.text,
        "monthlyRent": _monthlyRentController.text,
        "advanceAmount": _advanceAmountController.text,
        "fsi": _fsiController.text,
        "plotCoverage": _plotCoverageController.text,
        "northDeed": _northDeedController.text,
        "southDeed": _southDeedController.text,
        "eastDeed": _eastDeedController.text,
        "westDeed": _westDeedController.text,
        "extentDeed": _extentDeedController.text,
        "northActual": _northActualController.text,
        "southActual": _southActualController.text,
        "eastActual": _eastActualController.text,
        "westActual": _westActualController.text,
        "extentActual": _extentActualController.text,
        "extentConsidered": _extentConsideredController.text,
        "plotSizeNS": _plotSizeNSController.text,
        "plotSizeEW": _plotSizeEWController.text,
        "totalExtent": _totalExtentController.text,
        "localityCharacter": _localityCharacterController.text,
        "localityClassification": _localityClassificationController.text,
        "surroundingDevelopment": _surroundingDevelopmentController.text,
        "flooding": _floodingController.text,
        "amenities": _amenitiesController.text,
        "landLevel": _landLevelController.text,
        "landShape": _landShapeController.text,
        "landUse": _landUseController.text,
        "usageRestriction": _usageRestrictionController.text,
        "townPlanning": _townPlanningController.text,
        "plotType": _plotTypeController.text,
        "roadFacilities": _roadFacilitiesController.text,
        "roadType": _roadTypeController.text,
        "roadWidth": _roadWidthController.text,
        "landLocked": _landLockedController.text,
        "waterPotential": _waterPotentialController.text,
        "sewerage": _sewerageController.text,
        "powerSupply": _powerSupplyController.text,
        "siteAdvantages": _siteAdvantagesController.text,
        "specialRemarks": _specialRemarksController.text,
        "glrRate": _glrRateController.text,
        "glrValue": _glrValueController.text,
        "pmrRate": _pmrRateController.text,
        "pmrAdopted": _pmrAdoptedController.text,
        "pmrAdoptedValue": _pmrAdoptedValueController.text,
        "pmrValue": _pmrValueController.text,
        "buildingType": _buildingTypeController.text,
        "constructionType": _constructionTypeController.text,
        "constructionQuality": _constructionQualityController.text,
        "appearance": _appearanceController.text,
        "exteriorCondition": _exteriorConditionController.text,
        "interiorCondition": _interiorConditionController.text,
        "plinthArea": _plinthAreaController.text,
        "floors": _floorsController.text,
        "gfYear": _gfYearController.text,
        "gfRoof": _gfRoofController.text,
        "gfArea": _gfAreaController.text,
        "gfCantilever": _gfCantileverController.text,
        "gfTotal": _gfTotalController.text,
        "ffYear": _ffYearController.text,
        "ffRoof": _ffRoofController.text,
        "ffArea": _ffAreaController.text,
        "ffCantilever": _ffCantileverController.text,
        "ffTotal": _ffTotalController.text,
        "terraceYear": _terraceYearController.text,
        "terraceRoof": _terraceRoofController.text,
        "terraceArea": _terraceAreaController.text,
        "terraceTotal": _terraceTotalController.text,
        "totalArea": _totalAreaController.text,
        "approvedPlanNo": _approvedPlanNoController.text,
        "approvedPlanAuthority": _approvedPlanAuthorityController.text,
        "planVerified": _planVerifiedController.text,
        "gfSpecification": _gfSpecificationController.text,
        "gfFloorFinish": _gfFloorFinishController.text,
        "gfSuperStructure": _gfSuperStructureController.text,
        "gfRoofType": _gfRoofTypeController.text,
        "gfDoors": _gfDoorsController.text,
        "gfWindows": _gfWindowsController.text,
        "gfWeathering": _gfWeatheringController.text,
        "gfConstructionYear": _gfConstructionYearController.text,
        "gfAge": _gfAgeController.text,
        "gfRemainingLife": _gfRemainingLifeController.text,
        "gfDepreciation": _gfDepreciationController.text,
        "gfReplacementRate": _gfReplacementRateController.text,
        "ffSpecification": _ffSpecificationController.text,
        "ffFloorFinish": _ffFloorFinishController.text,
        "ffSuperStructure": _ffSuperStructureController.text,
        "ffRoofType": _ffRoofTypeController.text,
        "ffDoors": _ffDoorsController.text,
        "ffWindows": _ffWindowsController.text,
        "ffWeathering": _ffWeatheringController.text,
        "ffConstructionYear": _ffConstructionYearController.text,
        "ffAge": _ffAgeController.text,
        "ffRemainingLife": _ffRemainingLifeController.text,
        "ffDepreciation": _ffDepreciationController.text,
        "ffReplacementRate": _ffReplacementRateController.text,
        "presentValue": _presentValueController.text,
        // Valuer details
        "valuerName": _valuerNameController.text,
        "valuerAddress": _valuerAddressController.text,
        "valuerPhone": _valuerPhoneController.text,
        "valuerEmail": _valuerEmailController.text,
        "valuerRegNo": _valuerRegNoController.text,
        "valuerIBBIReg": _valuerIBBIRegController.text,
        "valuerWealthTaxReg": _valuerWealthTaxRegController.text,
        "valuerBlackMoneyReg": _valuerBlackMoneyRegController.text,
        // Amenities (1-20)
        "amenityPortico": _amenityPorticoController.text,
        "amenityOrnamentalDoor": _amenityOrnamentalDoorController.text,
        "amenitySitoutGrills": _amenitySitoutGrillsController.text,
        "amenitySteelGates": _amenitySteelGatesController.text,
        "amenityOpenStaircase": _amenityOpenStaircaseController.text,
        "amenityWardrobes": _amenityWardrobesController.text,
        "amenityGlazedTiles": _amenityGlazedTilesController.text,
        "amenityExtraSinks": _amenityExtraSinksController.text,
        "amenityMarbleTiles": _amenityMarbleTilesController.text,
        "amenityInteriorDecor": _amenityInteriorDecorController.text,
        "amenityElevationWorks": _amenityElevationWorksController.text,
        "amenityFalseCeiling": _amenityFalseCeilingController.text,
        "amenityPanelingWorks": _amenityPanelingWorksController.text,
        "amenityAluminumWorks": _amenityAluminumWorksController.text,
        "amenityAluminumHandrails": _amenityAluminumHandrailsController.text,
        "amenityLumberRoom": _amenityLumberRoomController.text,
        "amenityToiletRoom": _amenityToiletRoomController.text,
        "amenityWaterTankSump": _amenityWaterTankSumpController.text,
        "amenityGardening": _amenityGardeningController.text,
        "amenityAnyOther": _amenityAnyOtherController.text,
        // Water supply arrangements
        "amenityOpenWell": _amenityOpenWellController.text,
        "amenityDeepBore": _amenityDeepBoreController.text,
        "amenityHandPump": _amenityHandPumpController.text,
        "amenityCorporationTap": _amenityCorporationTapController.text,
        "amenityUndergroundSump": _amenityUndergroundSumpController.text,
        "amenityOverheadWaterTank": _amenityOverheadWaterTankController.text,
        // Drainage arrangements
        "amenitySepticTank": _amenitySepticTankController.text,
        "amenityUndergroundSewerage":
            _amenityUndergroundSewerageController.text,
        // Compound wall etc
        "amenityCompoundWall": _amenityCompoundWallController.text,
        "amenityCompoundWallHeight": _amenityCompoundWallHeightController.text,
        "amenityCompoundWallLength": _amenityCompoundWallLengthController.text,
        "amenityCompoundWallType": _amenityCompoundWallTypeController.text,
        "amenityPavements": _amenityPavementsController.text,
        "amenitySteelGateRm": _amenitySteelGateRmController.text,
        // Deposits
        "amenityEBDeposits": _amenityEBDepositsController.text,
        "amenityWaterDeposits": _amenityWaterDepositsController.text,
        "amenityDrainageDeposits": _amenityDrainageDepositsController.text,
        // Electrical fittings
        "amenityWiringType": _amenityWiringTypeController.text,
        "amenityFittingsClass": _amenityFittingsClassController.text,
        "amenityLightPoints": _amenityLightPointsController.text,
        "amenityFanPoints": _amenityFanPointsController.text,
        "amenityPlugPoints": _amenityPlugPointsController.text,
        "amenityElectricalOther": _amenityElectricalOtherController.text,
        // Plumbing installation
        "amenityNoOfClosets": _amenityNoOfClosetsController.text,
        "amenityClosetsType": _amenityClosetsTypeController.text,
        "amenityNoOfWashBasins": _amenityNoOfWashBasinsController.text,
        "amenityNoOfBathTubs": _amenityNoOfBathTubsController.text,
        "amenityWaterMeterTaps": _amenityWaterMeterTapsController.text,
        "amenityPlumbingOtherFixtures":
            _amenityPlumbingOtherFixturesController.text,
        // Any other & Total
        "amenityAnyOtherItem": _amenityAnyOtherItemController.text,
        "amenityTotal": _amenityTotalController.text,
        // Abstract fields
        "absLandGlr": absLandGlrController.text,
        "absLandPmr": absLandPmrController.text,
        "absBuildingGlr": absBuildingGlrController.text,
        "absBuildingPmr": absBuildingPmrController.text,
        "absExtraGlr": absExtraGlrController.text,
        "absExtraPmr": absExtraPmrController.text,
        "absAmenitiesGlr": absAmenitiesGlrController.text,
        "absAmenitiesPmr": absAmenitiesPmrController.text,
        "absTotalGlr": absTotalGlrController.text,
        "absTotalPmr": absTotalPmrController.text,
        "absSayGlr": absSayGlrController.text,
        "absSayPmr": absSayPmrController.text,
        // Commercial/Industrial
        "commercialArea": _commercialAreaController.text,
        "industrialArea": _industrialAreaController.text,
        // Lat/Long
      });

      // Handle images
      // List<Map<String, String>> imageMetadata = [];
      // for (int i = 0; i < _imagesWithLocation.length; i++) {
      //   final image = _imagesWithLocation[i];
      //   final imageBytes = image.imageBytes is File
      //       ? await (image.imageBytes as File).readAsBytes()
      //       : image.imageBytes;

      //   request.files.add(http.MultipartFile.fromBytes(
      //     'images',
      //     imageBytes,
      //     filename: 'property_${_ownerNameController.text}_$i.jpg',
      //   ));

      //   imageMetadata.add({
      //     "latitude": image.latitude.toString(),
      //     "longitude": image.longitude.toString(),
      //   });

      //   request.fields['images'] = jsonEncode(imageMetadata);
      // }
      List<Map<String, String>> imageMetadata = [];
      for (int i = 0; i < _imagesWithLocation.length; i++) {
        final image = _imagesWithLocation[i];
        final imageBytes = image.imageBytes;
        request.files.add(http.MultipartFile.fromBytes(
          'images',
          imageBytes,
          filename: 'property_${_ownerNameController.text}_$i.jpg',
        ));
        imageMetadata.add({
          "latitude": image.latitude?.toString() ?? "",
          "longitude": image.longitude?.toString() ?? "",
        });
      }
// Only set field ONCE here:
      request.fields['images'] = jsonEncode(imageMetadata);

      final response = await request.send();
      debugPrint("send req to back");

      if (context.mounted) Navigator.of(context).pop();

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Data saved successfully!')));
        }
        await _saveToNearbyCollection();
        // Add any additional save actions here if needed
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content:
                  Text('Upload failed: ${response.reasonPhrase} $response')));
        }
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    }
  }

// Helper function to determine MIME type from extension
  /* String _getMimeTypeFromExtension(String extension) {
    switch (extension) {
      case '.jpg':
      case '.jpeg':
        return 'image/jpeg';
      case '.png':
        return 'image/png';
      case '.gif':
        return 'image/gif';
      case '.webp':
        return 'image/webp';
      default:
        return 'application/octet-stream';
    }
  } */
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

      // Basic information
      _referenceNoController.text = data['referenceNo']?.toString() ?? '';
      _reportDateController.text = data['Date']?.toString() ?? '';
      _purposeController.text = data['purpose']?.toString() ?? '';
      _inspectionDateController.text = data['inspectionDate']?.toString() ?? '';
      _valuationDateController.text = data['valuationDate']?.toString() ?? '';
      _ownerNameController.text = data['ownerName']?.toString() ?? '';
      _ownerAddressController.text = data['ownerAddress']?.toString() ?? '';
      _documentsController.text = data['documents']?.toString() ?? '';
      _propertyDescriptionController.text =
          data['propertyDescription']?.toString() ?? '';
      _scopeController.text = data['scope']?.toString() ?? '';
      _bankController.text = data['bank']?.toString() ?? '';
      _propertyAddressController.text =
          data['propertyAddress']?.toString() ?? '';
      _cityTownController.text = data['cityTown']?.toString() ?? '';
      _residentialAreaController.text =
          data['residentialArea']?.toString() ?? '';
      _classificationController.text = data['classification']?.toString() ?? '';
      _urbanClassificationController.text =
          data['urbanClassification']?.toString() ?? '';
      _localAuthorityController.text = data['localAuthority']?.toString() ?? '';
      _govtActsController.text = data['govtActs']?.toString() ?? '';
      _agriculturalConversionController.text =
          data['agriculturalConversion']?.toString() ?? '';

      // Property identification
      _blockNoController.text = data['blockNo']?.toString() ?? '';
      _resurveyNoController.text = data['resurveyNo']?.toString() ?? '';
      _surveyNoController.text = data['surveyNo']?.toString() ?? '';
      _thandapperNoController.text = data['thandapperNo']?.toString() ?? '';
      _wardNoController.text = data['wardNo']?.toString() ?? '';
      _doorNoController.text = data['doorNo']?.toString() ?? '';
      _tsNoController.text = data['tsNo']?.toString() ?? '';
      _talukController.text = data['taluk']?.toString() ?? '';
      _districtController.text = data['district']?.toString() ?? '';

      // Boundaries
      _northBoundaryController.text = data['northBoundary']?.toString() ?? '';
      _southBoundaryController.text = data['southBoundary']?.toString() ?? '';
      _eastBoundaryController.text = data['eastBoundary']?.toString() ?? '';
      _westBoundaryController.text = data['westBoundary']?.toString() ?? '';
      _northBoundaryActualController.text =
          data['northBoundaryActual']?.toString() ?? '';
      _southBoundaryActualController.text =
          data['southBoundaryActual']?.toString() ?? '';
      _eastBoundaryActualController.text =
          data['eastBoundaryActual']?.toString() ?? '';
      _westBoundaryActualController.text =
          data['westBoundaryActual']?.toString() ?? '';
      _latitudelongitudeController.text =
          data['latitudelongitude']?.toString() ?? '';

      // Tax and utility information
      _taxPeriodController.text = data['taxPeriod']?.toString() ?? '';
      _buildingIdController.text = data['buildingId']?.toString() ?? '';
      _assessmentNoController.text = data['assessmentNo']?.toString() ?? '';
      _taxAmountController.text = data['taxAmount']?.toString() ?? '';
      _taxReceiptNameController.text = data['taxReceiptName']?.toString() ?? '';
      _consumerNoController.text = data['consumerNo']?.toString() ?? '';
      _electricityNameController.text =
          data['electricityName']?.toString() ?? '';
      _otherDetailsController.text = data['otherDetails']?.toString() ?? '';

      // Occupancy details
      _occupancyStatusController.text =
          data['occupancyStatus']?.toString() ?? '';
      _tenatedRentController.text = data['tenatedRent']?.toString() ?? '';
      _monthlyRentController.text = data['monthlyRent']?.toString() ?? '';
      _advanceAmountController.text = data['advanceAmount']?.toString() ?? '';

      // FSI and plot coverage
      _fsiController.text = data['fsi']?.toString() ?? '';
      _plotCoverageController.text = data['plotCoverage']?.toString() ?? '';

      // Deed and actual measurements
      _northDeedController.text = data['northDeed']?.toString() ?? '';
      _southDeedController.text = data['southDeed']?.toString() ?? '';
      _eastDeedController.text = data['eastDeed']?.toString() ?? '';
      _westDeedController.text = data['westDeed']?.toString() ?? '';
      _extentDeedController.text = data['extentDeed']?.toString() ?? '';
      _northActualController.text = data['northActual']?.toString() ?? '';
      _southActualController.text = data['southActual']?.toString() ?? '';
      _eastActualController.text = data['eastActual']?.toString() ?? '';
      _westActualController.text = data['westActual']?.toString() ?? '';
      _extentActualController.text = data['extentActual']?.toString() ?? '';
      _extentConsideredController.text =
          data['extentConsidered']?.toString() ?? '';
      _plotSizeNSController.text = data['plotSizeNS']?.toString() ?? '';
      _plotSizeEWController.text = data['plotSizeEW']?.toString() ?? '';
      _totalExtentController.text = data['totalExtent']?.toString() ?? '';

      // Locality details
      _localityCharacterController.text =
          data['localityCharacter']?.toString() ?? '';
      _localityClassificationController.text =
          data['localityClassification']?.toString() ?? '';
      _surroundingDevelopmentController.text =
          data['surroundingDevelopment']?.toString() ?? '';
      _floodingController.text = data['flooding']?.toString() ?? '';
      _amenitiesController.text = data['amenities']?.toString() ?? '';
      _landLevelController.text = data['landLevel']?.toString() ?? '';
      _landShapeController.text = data['landShape']?.toString() ?? '';
      _landUseController.text = data['landUse']?.toString() ?? '';
      _usageRestrictionController.text =
          data['usageRestriction']?.toString() ?? '';
      _townPlanningController.text = data['townPlanning']?.toString() ?? '';
      _plotTypeController.text = data['plotType']?.toString() ?? '';
      _roadFacilitiesController.text = data['roadFacilities']?.toString() ?? '';
      _roadTypeController.text = data['roadType']?.toString() ?? '';
      _roadWidthController.text = data['roadWidth']?.toString() ?? '';
      _landLockedController.text = data['landLocked']?.toString() ?? '';
      _waterPotentialController.text = data['waterPotential']?.toString() ?? '';
      _sewerageController.text = data['sewerage']?.toString() ?? '';
      _powerSupplyController.text = data['powerSupply']?.toString() ?? '';
      _siteAdvantagesController.text = data['siteAdvantages']?.toString() ?? '';
      _specialRemarksController.text = data['specialRemarks']?.toString() ?? '';

      // Valuation rates
      _glrRateController.text = data['glrRate']?.toString() ?? '';
      _glrValueController.text = data['glrValue']?.toString() ?? '';
      _pmrRateController.text = data['pmrRate']?.toString() ?? '';
      _pmrAdoptedController.text = data['pmrAdopted']?.toString() ?? '';
      _pmrAdoptedValueController.text =
          data['pmrAdoptedValue']?.toString() ?? '';
      _pmrValueController.text = data['pmrValue']?.toString() ?? '';

      // Building details
      _buildingTypeController.text = data['buildingType']?.toString() ?? '';
      _constructionTypeController.text =
          data['constructionType']?.toString() ?? '';
      _constructionQualityController.text =
          data['constructionQuality']?.toString() ?? '';
      _appearanceController.text = data['appearance']?.toString() ?? '';
      _exteriorConditionController.text =
          data['exteriorCondition']?.toString() ?? '';
      _interiorConditionController.text =
          data['interiorCondition']?.toString() ?? '';
      _plinthAreaController.text = data['plinthArea']?.toString() ?? '';
      _floorsController.text = data['floors']?.toString() ?? '';

      // Ground floor details
      _gfYearController.text = data['gfYear']?.toString() ?? '';
      _gfRoofController.text = data['gfRoof']?.toString() ?? '';
      _gfAreaController.text = data['gfArea']?.toString() ?? '';
      _gfCantileverController.text = data['gfCantilever']?.toString() ?? '';
      _gfTotalController.text = data['gfTotal']?.toString() ?? '';

      // First floor details
      _ffYearController.text = data['ffYear']?.toString() ?? '';
      _ffRoofController.text = data['ffRoof']?.toString() ?? '';
      _ffAreaController.text = data['ffArea']?.toString() ?? '';
      _ffCantileverController.text = data['ffCantilever']?.toString() ?? '';
      _ffTotalController.text = data['ffTotal']?.toString() ?? '';

      // Terrace details
      _terraceYearController.text = data['terraceYear']?.toString() ?? '';
      _terraceRoofController.text = data['terraceRoof']?.toString() ?? '';
      _terraceAreaController.text = data['terraceArea']?.toString() ?? '';
      _terraceTotalController.text = data['terraceTotal']?.toString() ?? '';

      // Total area
      _totalAreaController.text = data['totalArea']?.toString() ?? '';

      // Approved plan details
      _approvedPlanNoController.text = data['approvedPlanNo']?.toString() ?? '';
      _approvedPlanAuthorityController.text =
          data['approvedPlanAuthority']?.toString() ?? '';
      _planVerifiedController.text = data['planVerified']?.toString() ?? '';

      // Ground floor specifications
      _gfSpecificationController.text =
          data['gfSpecification']?.toString() ?? '';
      _gfFloorFinishController.text = data['gfFloorFinish']?.toString() ?? '';
      _gfSuperStructureController.text =
          data['gfSuperStructure']?.toString() ?? '';
      _gfRoofTypeController.text = data['gfRoofType']?.toString() ?? '';
      _gfDoorsController.text = data['gfDoors']?.toString() ?? '';
      _gfWindowsController.text = data['gfWindows']?.toString() ?? '';
      _gfWeatheringController.text = data['gfWeathering']?.toString() ?? '';
      _gfConstructionYearController.text =
          data['gfConstructionYear']?.toString() ?? '';
      _gfAgeController.text = data['gfAge']?.toString() ?? '';
      _gfRemainingLifeController.text =
          data['gfRemainingLife']?.toString() ?? '';
      _gfDepreciationController.text = data['gfDepreciation']?.toString() ?? '';
      _gfReplacementRateController.text =
          data['gfReplacementRate']?.toString() ?? '';

      // First floor specifications
      _ffSpecificationController.text =
          data['ffSpecification']?.toString() ?? '';
      _ffFloorFinishController.text = data['ffFloorFinish']?.toString() ?? '';
      _ffSuperStructureController.text =
          data['ffSuperStructure']?.toString() ?? '';
      _ffRoofTypeController.text = data['ffRoofType']?.toString() ?? '';
      _ffDoorsController.text = data['ffDoors']?.toString() ?? '';
      _ffWindowsController.text = data['ffWindows']?.toString() ?? '';
      _ffWeatheringController.text = data['ffWeathering']?.toString() ?? '';
      _ffConstructionYearController.text =
          data['ffConstructionYear']?.toString() ?? '';
      _ffAgeController.text = data['ffAge']?.toString() ?? '';
      _ffRemainingLifeController.text =
          data['ffRemainingLife']?.toString() ?? '';
      _ffDepreciationController.text = data['ffDepreciation']?.toString() ?? '';
      _ffReplacementRateController.text =
          data['ffReplacementRate']?.toString() ?? '';

      // Present value
      _presentValueController.text = data['presentValue']?.toString() ?? '';

      // Valuer details
      _valuerNameController.text = data['valuerName']?.toString() ?? '';
      _valuerAddressController.text = data['valuerAddress']?.toString() ?? '';
      _valuerPhoneController.text = data['valuerPhone']?.toString() ?? '';
      _valuerEmailController.text = data['valuerEmail']?.toString() ?? '';
      _valuerRegNoController.text = data['valuerRegNo']?.toString() ?? '';
      _valuerIBBIRegController.text = data['valuerIBBIReg']?.toString() ?? '';
      _valuerWealthTaxRegController.text =
          data['valuerWealthTaxReg']?.toString() ?? '';
      _valuerBlackMoneyRegController.text =
          data['valuerBlackMoneyReg']?.toString() ?? '';

      // Amenities (1-20)
      _amenityPorticoController.text = data['amenityPortico']?.toString() ?? '';
      _amenityOrnamentalDoorController.text =
          data['amenityOrnamentalDoor']?.toString() ?? '';
      _amenitySitoutGrillsController.text =
          data['amenitySitoutGrills']?.toString() ?? '';
      _amenitySteelGatesController.text =
          data['amenitySteelGates']?.toString() ?? '';
      _amenityOpenStaircaseController.text =
          data['amenityOpenStaircase']?.toString() ?? '';
      _amenityWardrobesController.text =
          data['amenityWardrobes']?.toString() ?? '';
      _amenityGlazedTilesController.text =
          data['amenityGlazedTiles']?.toString() ?? '';
      _amenityExtraSinksController.text =
          data['amenityExtraSinks']?.toString() ?? '';
      _amenityMarbleTilesController.text =
          data['amenityMarbleTiles']?.toString() ?? '';
      _amenityInteriorDecorController.text =
          data['amenityInteriorDecor']?.toString() ?? '';
      _amenityElevationWorksController.text =
          data['amenityElevationWorks']?.toString() ?? '';
      _amenityFalseCeilingController.text =
          data['amenityFalseCeiling']?.toString() ?? '';
      _amenityPanelingWorksController.text =
          data['amenityPanelingWorks']?.toString() ?? '';
      _amenityAluminumWorksController.text =
          data['amenityAluminumWorks']?.toString() ?? '';
      _amenityAluminumHandrailsController.text =
          data['amenityAluminumHandrails']?.toString() ?? '';
      _amenityLumberRoomController.text =
          data['amenityLumberRoom']?.toString() ?? '';
      _amenityToiletRoomController.text =
          data['amenityToiletRoom']?.toString() ?? '';
      _amenityWaterTankSumpController.text =
          data['amenityWaterTankSump']?.toString() ?? '';
      _amenityGardeningController.text =
          data['amenityGardening']?.toString() ?? '';
      _amenityAnyOtherController.text =
          data['amenityAnyOther']?.toString() ?? '';

      // Water supply arrangements
      _amenityOpenWellController.text =
          data['amenityOpenWell']?.toString() ?? '';
      _amenityDeepBoreController.text =
          data['amenityDeepBore']?.toString() ?? '';
      _amenityHandPumpController.text =
          data['amenityHandPump']?.toString() ?? '';
      _amenityCorporationTapController.text =
          data['amenityCorporationTap']?.toString() ?? '';
      _amenityUndergroundSumpController.text =
          data['amenityUndergroundSump']?.toString() ?? '';
      _amenityOverheadWaterTankController.text =
          data['amenityOverheadWaterTank']?.toString() ?? '';

      // Drainage arrangements
      _amenitySepticTankController.text =
          data['amenitySepticTank']?.toString() ?? '';
      _amenityUndergroundSewerageController.text =
          data['amenityUndergroundSewerage']?.toString() ?? '';

      // Compound wall etc
      _amenityCompoundWallController.text =
          data['amenityCompoundWall']?.toString() ?? '';
      _amenityCompoundWallHeightController.text =
          data['amenityCompoundWallHeight']?.toString() ?? '';
      _amenityCompoundWallLengthController.text =
          data['amenityCompoundWallLength']?.toString() ?? '';
      _amenityCompoundWallTypeController.text =
          data['amenityCompoundWallType']?.toString() ?? '';
      _amenityPavementsController.text =
          data['amenityPavements']?.toString() ?? '';
      _amenitySteelGateRmController.text =
          data['amenitySteelGateRm']?.toString() ?? '';

      // Deposits
      _amenityEBDepositsController.text =
          data['amenityEBDeposits']?.toString() ?? '';
      _amenityWaterDepositsController.text =
          data['amenityWaterDeposits']?.toString() ?? '';
      _amenityDrainageDepositsController.text =
          data['amenityDrainageDeposits']?.toString() ?? '';

      // Electrical fittings
      _amenityWiringTypeController.text =
          data['amenityWiringType']?.toString() ?? '';
      _amenityFittingsClassController.text =
          data['amenityFittingsClass']?.toString() ?? '';
      _amenityLightPointsController.text =
          data['amenityLightPoints']?.toString() ?? '';
      _amenityFanPointsController.text =
          data['amenityFanPoints']?.toString() ?? '';
      _amenityPlugPointsController.text =
          data['amenityPlugPoints']?.toString() ?? '';
      _amenityElectricalOtherController.text =
          data['amenityElectricalOther']?.toString() ?? '';

      // Plumbing installation
      _amenityNoOfClosetsController.text =
          data['amenityNoOfClosets']?.toString() ?? '';
      _amenityClosetsTypeController.text =
          data['amenityClosetsType']?.toString() ?? '';
      _amenityNoOfWashBasinsController.text =
          data['amenityNoOfWashBasins']?.toString() ?? '';
      _amenityNoOfBathTubsController.text =
          data['amenityNoOfBathTubs']?.toString() ?? '';
      _amenityWaterMeterTapsController.text =
          data['amenityWaterMeterTaps']?.toString() ?? '';
      _amenityPlumbingOtherFixturesController.text =
          data['amenityPlumbingOtherFixtures']?.toString() ?? '';

      // Any other & Total
      _amenityAnyOtherItemController.text =
          data['amenityAnyOtherItem']?.toString() ?? '';
      _amenityTotalController.text = data['amenityTotal']?.toString() ?? '';

      // Abstract fields
      absLandGlrController.text = data['absLandGlr']?.toString() ?? '';
      absLandPmrController.text = data['absLandPmr']?.toString() ?? '';
      absBuildingGlrController.text = data['absBuildingGlr']?.toString() ?? '';
      absBuildingPmrController.text = data['absBuildingPmr']?.toString() ?? '';
      absExtraGlrController.text = data['absExtraGlr']?.toString() ?? '';
      absExtraPmrController.text = data['absExtraPmr']?.toString() ?? '';
      absAmenitiesGlrController.text =
          data['absAmenitiesGlr']?.toString() ?? '';
      absAmenitiesPmrController.text =
          data['absAmenitiesPmr']?.toString() ?? '';
      absTotalGlrController.text = data['absTotalGlr']?.toString() ?? '';
      absTotalPmrController.text = data['absTotalPmr']?.toString() ?? '';
      absSayGlrController.text = data['absSayGlr']?.toString() ?? '';
      absSayPmrController.text = data['absSayPmr']?.toString() ?? '';

      // Commercial/Industrial
      _commercialAreaController.text = data['commercialArea']?.toString() ?? '';
      _industrialAreaController.text = data['industrialArea']?.toString() ?? '';

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

                _imagesWithLocation.add(ImageWithLocation(
                  imageBytes: imageBytes,
                  latitude: imgData['latitude'],
                  longitude: imgData['longitude'],
                ));
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

      debugPrint('Form initialized with property data');
    } else {
      debugPrint('No property data - form will use default values');
    }
  }

  @override
  void dispose() {
    // Dispose all controllers
    _referenceNoController.dispose();
    _reportDateController.dispose();
    _purposeController.dispose();
    _inspectionDateController.dispose();
    _valuationDateController.dispose();
    _ownerNameController.dispose();
    _ownerAddressController.dispose();
    _documentsController.dispose();
    _propertyDescriptionController.dispose();
    _scopeController.dispose();
    _bankController.dispose();
    _propertyAddressController.dispose();
    _cityTownController.dispose();
    _residentialAreaController.dispose();
    _classificationController.dispose();
    _urbanClassificationController.dispose();
    _localAuthorityController.dispose();
    _govtActsController.dispose();
    _agriculturalConversionController.dispose();
    _blockNoController.dispose();
    _resurveyNoController.dispose();
    _surveyNoController.dispose();
    _thandapperNoController.dispose();
    _wardNoController.dispose();
    _doorNoController.dispose();
    _tsNoController.dispose();
    _talukController.dispose();
    _districtController.dispose();
    _northBoundaryController.dispose();
    _southBoundaryController.dispose();
    _eastBoundaryController.dispose();
    _westBoundaryController.dispose();
    _northBoundaryActualController.dispose();
    _southBoundaryActualController.dispose();
    _eastBoundaryActualController.dispose();
    _westBoundaryActualController.dispose();
    _latitudelongitudeController.dispose();
    // _longitudeController.dispose();
    _taxPeriodController.dispose();
    _buildingIdController.dispose();
    _assessmentNoController.dispose();
    _taxAmountController.dispose();
    _taxReceiptNameController.dispose();
    _consumerNoController.dispose();
    _electricityNameController.dispose();
    _occupancyStatusController.dispose();
    _otherDetailsController.dispose();
    _tenatedRentController.dispose();
    _monthlyRentController.dispose();
    _advanceAmountController.dispose();
    _fsiController.dispose();
    _plotCoverageController.dispose();
    _northDeedController.dispose();
    _southDeedController.dispose();
    _eastDeedController.dispose();
    _westDeedController.dispose();
    _extentDeedController.dispose();
    _northActualController.dispose();
    _southActualController.dispose();
    _eastActualController.dispose();
    _westActualController.dispose();
    _extentActualController.dispose();
    _extentConsideredController.dispose();
    _plotSizeNSController.dispose();
    _plotSizeEWController.dispose();
    _totalExtentController.dispose();
    _localityCharacterController.dispose();
    _localityClassificationController.dispose();
    _surroundingDevelopmentController.dispose();
    _floodingController.dispose();
    _amenitiesController.dispose();
    _landLevelController.dispose();
    _landShapeController.dispose();
    _landUseController.dispose();
    _usageRestrictionController.dispose();
    _townPlanningController.dispose();
    _plotTypeController.dispose();
    _roadFacilitiesController.dispose();
    _roadTypeController.dispose();
    _roadWidthController.dispose();
    _landLockedController.dispose();
    _waterPotentialController.dispose();
    _sewerageController.dispose();
    _powerSupplyController.dispose();
    _siteAdvantagesController.dispose();
    _specialRemarksController.dispose();
    _glrRateController.dispose();
    _glrValueController.dispose();
    _pmrRateController.dispose();
    _pmrAdoptedController.dispose();
    _pmrAdoptedValueController.dispose();
    _buildingTypeController.dispose();
    _constructionTypeController.dispose();
    _constructionQualityController.dispose();
    _appearanceController.dispose();
    _exteriorConditionController.dispose();
    _interiorConditionController.dispose();
    _plinthAreaController.dispose();
    _floorsController.dispose();
    _gfYearController.dispose();
    _gfRoofController.dispose();
    _gfAreaController.dispose();
    _gfCantileverController.dispose();
    _gfTotalController.dispose();
    _ffYearController.dispose();
    _ffRoofController.dispose();
    _ffAreaController.dispose();
    _ffCantileverController.dispose();
    _ffTotalController.dispose();
    _terraceYearController.dispose();
    _terraceRoofController.dispose();
    _terraceAreaController.dispose();
    _terraceTotalController.dispose();
    _totalAreaController.dispose();
    _approvedPlanNoController.dispose();
    _approvedPlanAuthorityController.dispose();
    _planVerifiedController.dispose();
    _gfSpecificationController.dispose();
    _gfFloorFinishController.dispose();
    _gfSuperStructureController.dispose();
    _gfRoofTypeController.dispose();
    _gfDoorsController.dispose();
    _gfWindowsController.dispose();
    _gfWeatheringController.dispose();
    _gfConstructionYearController.dispose();
    _gfAgeController.dispose();
    _gfRemainingLifeController.dispose();
    _gfDepreciationController.dispose();
    _gfReplacementRateController.dispose();
    _ffSpecificationController.dispose();
    _ffFloorFinishController.dispose();
    _ffSuperStructureController.dispose();
    _ffRoofTypeController.dispose();
    _ffDoorsController.dispose();
    _ffWindowsController.dispose();
    _ffWeatheringController.dispose();
    _ffConstructionYearController.dispose();
    _ffAgeController.dispose();
    _ffRemainingLifeController.dispose();
    _ffDepreciationController.dispose();
    _ffReplacementRateController.dispose();
    _presentValueController.dispose();
    _valuerNameController.dispose();
    _valuerAddressController.dispose();
    _valuerPhoneController.dispose();
    _valuerEmailController.dispose();
    _valuerRegNoController.dispose();
    _valuerIBBIRegController.dispose();
    _valuerWealthTaxRegController.dispose();
    _valuerBlackMoneyRegController.dispose();
    _amenityPorticoController.dispose();
    _amenityOrnamentalDoorController.dispose();
    _amenitySitoutGrillsController.dispose();
    _amenitySteelGatesController.dispose();
    _amenityOpenStaircaseController.dispose();
    _amenityWardrobesController.dispose();
    _amenityGlazedTilesController.dispose();
    _amenityExtraSinksController.dispose();
    _amenityMarbleTilesController.dispose();
    _amenityInteriorDecorController.dispose();
    _amenityElevationWorksController.dispose();
    _amenityFalseCeilingController.dispose();
    _amenityPanelingWorksController.dispose();
    _amenityAluminumWorksController.dispose();
    _amenityAluminumHandrailsController.dispose();
    _amenityLumberRoomController.dispose();
    _amenityToiletRoomController.dispose();
    _amenityWaterTankSumpController.dispose();
    _amenityGardeningController.dispose();
    _amenityAnyOtherController.dispose();
    _amenityOpenWellController.dispose();
    _amenityDeepBoreController.dispose();
    _amenityHandPumpController.dispose();
    _amenityCorporationTapController.dispose();
    _amenityUndergroundSumpController.dispose();
    _amenityOverheadWaterTankController.dispose();
    _amenitySepticTankController.dispose();
    _amenityUndergroundSewerageController.dispose();
    _amenityCompoundWallController.dispose();
    _amenityCompoundWallHeightController.dispose();
    _amenityCompoundWallLengthController.dispose();
    _amenityCompoundWallTypeController.dispose();
    _amenityPavementsController.dispose();
    _amenitySteelGateRmController.dispose();
    _amenityEBDepositsController.dispose();
    _amenityWaterDepositsController.dispose();
    _amenityDrainageDepositsController.dispose();
    _amenityWiringTypeController.dispose();
    _amenityFittingsClassController.dispose();
    _amenityLightPointsController.dispose();
    _amenityFanPointsController.dispose();
    _amenityPlugPointsController.dispose();
    _amenityElectricalOtherController.dispose();
    _amenityNoOfClosetsController.dispose();
    _amenityClosetsTypeController.dispose();
    _amenityNoOfWashBasinsController.dispose();
    _amenityNoOfBathTubsController.dispose();
    _amenityWaterMeterTapsController.dispose();
    _amenityPlumbingOtherFixturesController.dispose();
    _amenityAnyOtherItemController.dispose();
    _amenityTotalController.dispose();
    absLandGlrController.dispose();
    absLandPmrController.dispose();
    absBuildingGlrController.dispose();
    absBuildingPmrController.dispose();
    absExtraGlrController.dispose();
    absExtraPmrController.dispose();
    absAmenitiesGlrController.dispose();
    absAmenitiesPmrController.dispose();
    absTotalGlrController.dispose();
    absTotalPmrController.dispose();
    absSayGlrController.dispose();
    absSayPmrController.dispose();
    _commercialAreaController.dispose();
    _industrialAreaController.dispose();
    _pmrValueController.dispose();
    _nearByLat.dispose();
    _nearByLong.dispose();
    super.dispose();
  }

  pw.TableRow tableRow3(String sn, String desc, String value) {
    return pw.TableRow(
      children: [
        pw.Container(
          alignment: pw.Alignment.topCenter,
          padding: const pw.EdgeInsets.all(5),
          child: pw.Text(sn),
        ),
        pw.Container(
          alignment: pw.Alignment.topLeft,
          padding: const pw.EdgeInsets.all(5),
          child: pw.Text(desc),
        ),
        pw.Container(
          alignment: pw.Alignment.topCenter,
          padding: const pw.EdgeInsets.all(5),
          child: pw.Text(":"),
        ),
        pw.Container(
          alignment: pw.Alignment.topLeft,
          padding: const pw.EdgeInsets.all(5),
          child: pw.Text(value),
        ),
      ],
    );
  }

  // Place at the top of your generatePropertyValuationReport function, before the widgets list.
  pw.TableRow tableRowDesc(String sn, String desc, String value) {
    return pw.TableRow(
      children: [
        pw.Container(
          alignment: pw.Alignment.topLeft,
          padding: const pw.EdgeInsets.all(5),
          child: pw.Text(sn),
        ),
        pw.Container(
          alignment: pw.Alignment.topLeft,
          padding: const pw.EdgeInsets.all(5),
          child: pw.Text(desc),
        ),
        pw.Container(
          alignment: pw.Alignment.topLeft,
          padding: const pw.EdgeInsets.all(5),
          child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(": "),
                pw.Expanded(child: pw.Text(value)),
              ]),
        ),
      ],
    );
  }

  pw.TableRow tableRow2(String left, String right) {
    return pw.TableRow(
      children: [
        pw.Container(
          alignment: pw.Alignment.centerLeft,
          padding: const pw.EdgeInsets.all(4),
          child: pw.Text(left),
        ),
        pw.Container(
          alignment: pw.Alignment.centerLeft,
          padding: const pw.EdgeInsets.all(4),
          child: pw.Text(right),
        ),
      ],
    );
  }

// Helper for 2-col rows
  pw.TableRow tableRow2C(String left, String right) {
    return pw.TableRow(
      children: [
        pw.Container(
          alignment: pw.Alignment.centerLeft,
          padding: const pw.EdgeInsets.all(4),
          child: pw.Text(left),
        ),
        pw.Container(
          alignment: pw.Alignment.centerLeft,
          padding: const pw.EdgeInsets.all(4),
          child: pw.Text(right),
        ),
      ],
    );
  }

// Helper for 3-col rows (for GF/FF comparison table)
  pw.TableRow tableRow3C(String desc, String gf, String ff) {
    return pw.TableRow(
      children: [
        pw.Container(
          alignment: pw.Alignment.centerLeft,
          padding: const pw.EdgeInsets.all(4),
          child: pw.Text(desc),
        ),
        pw.Container(
          alignment: pw.Alignment.centerLeft,
          padding: const pw.EdgeInsets.all(4),
          child: pw.Text(gf),
        ),
        pw.Container(
          alignment: pw.Alignment.centerLeft,
          padding: const pw.EdgeInsets.all(4),
          child: pw.Text(ff),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Annexure-8: Property Valuation'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Search for Nearby Property",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _lat,
                decoration: const InputDecoration(labelText: 'Latitude'),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _long,
                decoration: const InputDecoration(labelText: 'Longitude'),
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
                          onPressed: _getLocation, // Call our new method
                          icon: const Icon(Icons.my_location),
                          label: const Text('Get Location'),
                        ),
                      ),
                      const SizedBox(
                        width: 4,
                      ),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _getNearbyProperty,
                          label: const Text('Search'),
                          icon: const Icon(Icons.search),
                        ),
                      )
                    ],
                  ),
                ],
              )),
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(
                      right: 50, left: 50, top: 10, bottom: 10),
                  child: FloatingActionButton.extended(
                    heroTag: "f2",
                    icon: const Icon(Icons.search),
                    label: const Text('Search Saved Drafts'),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SavedDraftsCanara(),
                        ),
                      );
                    },
                  ),
                ),
              ),

              // Part A - Basic Data

              _buildSection(title: 'A. BASIC DATA', children: [
                TextFormField(
                  controller: _referenceNoController,
                  decoration: const InputDecoration(
                    labelText: 'Reference Number',
                    border: OutlineInputBorder(),
                  ),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 172, 208, 237),
                      foregroundColor: Colors.black),
                  icon: Icon(Icons.autorenew),
                  onPressed: () async {
                    bool shouldGenerate = true;
                    if (_referenceNoController.text.isNotEmpty ?? false) {
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
                        _referenceNoController.text = refID;
                      });
                    }
                  },
                  label: const Text('Generate New ID',
                      style: TextStyle(fontWeight: FontWeight.w300)),
                ),
                TextFormField(
                  controller: _reportDateController,
                  decoration: const InputDecoration(
                    labelText: 'Date of report',
                    border: OutlineInputBorder(),
                  ),
                ),
                TextFormField(
                  controller: _purposeController,
                  decoration: const InputDecoration(
                    labelText: 'Purpose of valuation',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _inspectionDateController,
                  decoration: const InputDecoration(
                    labelText: 'Date of inspection',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _valuationDateController,
                  decoration: const InputDecoration(
                    labelText: 'Date on which valuation is made',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _ownerNameController,
                  decoration: const InputDecoration(
                    labelText: 'Name of the reported owner with phone number',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _ownerAddressController,
                  decoration: const InputDecoration(
                    labelText: 'Owner address',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _documentsController,
                  decoration: const InputDecoration(
                    labelText: 'Documents produced',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 8,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _propertyDescriptionController,
                  decoration: const InputDecoration(
                    labelText:
                        'Brief description of the property (Including leasehold/freehold etc.)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 5,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _scopeController,
                  decoration: const InputDecoration(
                    labelText: 'Scope of valuation',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _bankController,
                  decoration: const InputDecoration(
                    labelText:
                        'If this report is to be used for any bank purpose, state the name of the bank and branch, if known',
                    border: OutlineInputBorder(),
                  ),
                )
              ]),
              // Part II - Description of Property
              _buildSection(
                  title: "Part II - Description of Property",
                  children: [
                    TextFormField(
                      controller: _propertyAddressController,
                      decoration: const InputDecoration(
                        labelText:
                            'Postal address of the property with Pin code',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _cityTownController,
                      decoration: const InputDecoration(
                        labelText: 'City/Town',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _residentialAreaController,
                      decoration: const InputDecoration(
                        labelText: 'Residential Area',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _commercialAreaController,
                      decoration: const InputDecoration(
                        labelText: 'Commercial Area',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _industrialAreaController,
                      decoration: const InputDecoration(
                        labelText: 'Industrial Area',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _classificationController,
                      decoration: const InputDecoration(
                        labelText: 'Classification (High/Middle/Poor)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _urbanClassificationController,
                      decoration: const InputDecoration(
                        labelText: 'Urban/Semi Urban/Rural',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _localAuthorityController,
                      decoration: const InputDecoration(
                        labelText:
                            'Coming under Corporation limit / Village Panchayat / Municipality ',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _govtActsController,
                      decoration: const InputDecoration(
                        labelText:
                            'Whether covered under any State / Central Govt. enactments (e.g. Urban Land Ceiling Act) or notified under agency area / scheduled area / cantonment area',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _agriculturalConversionController,
                      decoration: const InputDecoration(
                        labelText:
                            'In case it is an agricultural land, any conversion to house site plots is contemplated',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _blockNoController,
                      decoration: const InputDecoration(
                        labelText: 'Block No.',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _resurveyNoController,
                      decoration: const InputDecoration(
                        labelText: 'Re-Survey No.',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _surveyNoController,
                      decoration: const InputDecoration(
                        labelText: 'Survey No.',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _thandapperNoController,
                      decoration: const InputDecoration(
                        labelText: 'Thandapper No.',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _wardNoController,
                      decoration: const InputDecoration(
                        labelText: 'Ward No. & Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _doorNoController,
                      decoration: const InputDecoration(
                        labelText: 'Door No.',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _tsNoController,
                      decoration: const InputDecoration(
                        labelText: 'T.S. No./Village',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _talukController,
                      decoration: const InputDecoration(
                        labelText: 'Ward/Taluka',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _districtController,
                      decoration: const InputDecoration(
                        labelText: 'Mandal/District',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('Boundaries of the property(As per title deed)'),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _northBoundaryController,
                            decoration: const InputDecoration(
                              labelText: 'North',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            controller: _southBoundaryController,
                            decoration: const InputDecoration(
                              labelText: 'South',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _eastBoundaryController,
                            decoration: const InputDecoration(
                              labelText: 'East',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            controller: _westBoundaryController,
                            decoration: const InputDecoration(
                              labelText: 'West',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                        'Boundaries of the property(As per Actuals & Location Sketch)'),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _northBoundaryActualController,
                            decoration: const InputDecoration(
                              labelText: 'North',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            controller: _southBoundaryActualController,
                            decoration: const InputDecoration(
                              labelText: 'South',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _eastBoundaryActualController,
                            decoration: const InputDecoration(
                              labelText: 'East',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            controller: _westBoundaryActualController,
                            decoration: const InputDecoration(
                              labelText: 'West',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _latitudelongitudeController,
                      decoration: const InputDecoration(
                        labelText:
                            'Latitude, Longitude and Coordinates of the site',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _taxPeriodController,
                      decoration: const InputDecoration(
                        labelText: 'Tax Period',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _buildingIdController,
                      decoration: const InputDecoration(
                        labelText: 'Building ID',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _assessmentNoController,
                      decoration: const InputDecoration(
                        labelText: 'Assessment No.',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _taxAmountController,
                      decoration: const InputDecoration(
                        labelText: 'Tax Amount',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _taxReceiptNameController,
                      decoration: const InputDecoration(
                        labelText: 'Receipt in the name of',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _consumerNoController,
                      decoration: const InputDecoration(
                        labelText: 'Electricity Consumer No.',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _electricityNameController,
                      decoration: const InputDecoration(
                        labelText: 'Electricity Service in the name of',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _otherDetailsController,
                      decoration: const InputDecoration(
                        labelText: 'Other details, if any',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _occupancyStatusController,
                      decoration: const InputDecoration(
                        labelText: 'Occupancy Status',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _tenatedRentController,
                      decoration: const InputDecoration(
                        labelText:
                            'If tenanted fully, what is the gross monthly rent',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _monthlyRentController,
                      decoration: const InputDecoration(
                        labelText: 'Probable Monthly Rent',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _advanceAmountController,
                      decoration: const InputDecoration(
                        labelText: 'Advance Amount',
                        border: OutlineInputBorder(),
                      ),
                    )
                  ]),
              //   'PART III - DESCRIPTION OF PROPERTY',
              _buildSection(
                  title: 'Part III - Description of Property',
                  children: [
                    TextFormField(
                      controller: _fsiController,
                      decoration: const InputDecoration(
                        labelText: 'FSI',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _plotCoverageController,
                      decoration: const InputDecoration(
                        labelText: 'Plot Coverage',
                        border: OutlineInputBorder(),
                      ),
                    )
                  ]),
              // Part B - Land
              _buildSection(title: 'Part B - Land', children: [
                const Text('Dimensions of the site (As per title deed)'),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _northDeedController,
                        decoration: const InputDecoration(
                          labelText: 'North',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        controller: _southDeedController,
                        decoration: const InputDecoration(
                          labelText: 'South',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _eastDeedController,
                        decoration: const InputDecoration(
                          labelText: 'East',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        controller: _westDeedController,
                        decoration: const InputDecoration(
                          labelText: 'West',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _extentDeedController,
                  decoration: const InputDecoration(
                    labelText: 'Extent',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Dimensions of the site (Actuals)'),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _northActualController,
                        decoration: const InputDecoration(
                          labelText: 'North',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        controller: _southActualController,
                        decoration: const InputDecoration(
                          labelText: 'South',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _eastActualController,
                        decoration: const InputDecoration(
                          labelText: 'East',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        controller: _westActualController,
                        decoration: const InputDecoration(
                          labelText: 'West',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _extentActualController,
                  decoration: const InputDecoration(
                    labelText: 'Extent',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _extentConsideredController,
                  decoration: const InputDecoration(
                    labelText: 'Extent of site (least of deed & actuals)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _plotSizeNSController,
                        decoration: const InputDecoration(
                          labelText: 'North-South size',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        controller: _plotSizeEWController,
                        decoration: const InputDecoration(
                          labelText: 'East-West size',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _totalExtentController,
                  decoration: const InputDecoration(
                    labelText: 'Total extent of plot',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _localityCharacterController,
                  decoration: const InputDecoration(
                    labelText: 'Character of locality',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _localityClassificationController,
                  decoration: const InputDecoration(
                    labelText: 'Classification of locality',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _surroundingDevelopmentController,
                  decoration: const InputDecoration(
                    labelText: 'Development of surrounding areas',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _floodingController,
                  decoration: const InputDecoration(
                    labelText: 'Possibility of frequent flooding/sub merging',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _amenitiesController,
                  decoration: const InputDecoration(
                    labelText:
                        'Feasibility to the Civic amenities like school, hospital, bus stop, market etc.',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _landLevelController,
                  decoration: const InputDecoration(
                    labelText: 'Level of land with topographical conditions',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _landShapeController,
                  decoration: const InputDecoration(
                    labelText: 'Shape of land',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _landUseController,
                  decoration: const InputDecoration(
                    labelText: 'Type of use to which it can be put',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _usageRestrictionController,
                  decoration: const InputDecoration(
                    labelText: 'Any usage restriction',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _townPlanningController,
                  decoration: const InputDecoration(
                    labelText: 'Is plot in town planning approved layout?',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _plotTypeController,
                  decoration: const InputDecoration(
                    labelText: 'Corner or intermittent plot?',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _roadFacilitiesController,
                  decoration: const InputDecoration(
                    labelText: 'Road facilities available?',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _roadTypeController,
                  decoration: const InputDecoration(
                    labelText: 'Type of road available',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _roadWidthController,
                  decoration: const InputDecoration(
                    labelText:
                        'Width of road – is it below 20 ft. or more than 20 ft.',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _landLockedController,
                  decoration: const InputDecoration(
                    labelText: 'Is it a land-locked land?',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _waterPotentialController,
                  decoration: const InputDecoration(
                    labelText: 'Water potentiality',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _sewerageController,
                  decoration: const InputDecoration(
                    labelText: 'Underground sewerage system',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _powerSupplyController,
                  decoration: const InputDecoration(
                    labelText: 'Is power supply available at the site?',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _siteAdvantagesController,
                  decoration: const InputDecoration(
                    labelText: 'Advantages of the site',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _specialRemarksController,
                  decoration: const InputDecoration(
                    labelText:
                        'Special remarks, if any, like threat of acquisition of land for public service purposes, road widening or applicability of CRZ provisions etc. (Distance from seacoast / tidal level must be incorporated)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _glrRateController,
                  decoration: const InputDecoration(
                    labelText:
                        'Guideline rate as obtained from the Registrar’s office (an evidence thereof to be enclosed)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _glrValueController,
                  decoration: const InputDecoration(
                    labelText: 'Value of the land by adopting GLR',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _pmrRateController,
                  decoration: const InputDecoration(
                    labelText:
                        'Prevailing market rate (Along with details/reference of at least two latest deals/transactions with respect to adjacent properties in the areas)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _pmrAdoptedController,
                  decoration: const InputDecoration(
                    labelText:
                        'Unit rate adopted in this valuation after considering the characteristics of the subject plot',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _pmrAdoptedValueController,
                  decoration: const InputDecoration(
                    labelText: 'Value of land by adopting PMR ',
                    border: OutlineInputBorder(),
                  ),
                )
              ]),
              // Part C - Buildings
              _buildSection(title: 'Part C - Buildings', children: [
                TextFormField(
                  controller: _buildingTypeController,
                  decoration: const InputDecoration(
                    labelText: 'Type of Building',
                    hintText: 'Residential/Commercial/Industrial',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _constructionTypeController,
                  decoration: const InputDecoration(
                    labelText: 'Type of construction',
                    hintText: 'Load bearing / RCC / Steel Framed',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _constructionQualityController,
                  decoration: const InputDecoration(
                    labelText: 'Quality of construction',
                    hintText: 'Superior/ Class I/ Class II',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _appearanceController,
                  decoration: const InputDecoration(
                    labelText: 'Appearance of Building',
                    hintText: 'Common/Attractive/Aesthetic',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _exteriorConditionController,
                  decoration: const InputDecoration(
                    labelText: 'Exterior condition',
                    hintText: 'Excellent, Good, Normal, Average, Poor',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _interiorConditionController,
                  decoration: const InputDecoration(
                    labelText: 'Interior condition',
                    hintText: 'Excellent, Good, Normal, Average, Poor',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _plinthAreaController,
                  decoration: const InputDecoration(
                    labelText: 'Plinth Area',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _floorsController,
                  decoration: const InputDecoration(
                    labelText:
                        'Number of floors and height of each floor including basement, if any',
                    border: OutlineInputBorder(),
                  ),
                )
              ]),

              // Ground Floor Details
              _buildSection(title: 'Ground Floor Details', children: [
                TextFormField(
                  controller: _gfYearController,
                  decoration: const InputDecoration(
                    labelText: 'Year of Construction',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _gfRoofController,
                  decoration: const InputDecoration(
                    labelText: 'Roof Type',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _gfAreaController,
                  decoration: const InputDecoration(
                    labelText: 'Main Portion Area (Sqft)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _gfCantileverController,
                  decoration: const InputDecoration(
                    labelText: 'Cantilevered Portion Area (Sqft)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _gfTotalController,
                  decoration: const InputDecoration(
                    labelText: 'Total Area (Sqft)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _gfSpecificationController,
                  decoration: const InputDecoration(
                    labelText: 'Specification',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _gfFloorFinishController,
                  decoration: const InputDecoration(
                    labelText: 'Floor Finish',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _gfSuperStructureController,
                  decoration: const InputDecoration(
                    labelText: 'Super structure',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _gfRoofTypeController,
                  decoration: const InputDecoration(
                    labelText: 'Roof',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _gfDoorsController,
                  decoration: const InputDecoration(
                    labelText: 'Doors',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _gfWindowsController,
                  decoration: const InputDecoration(
                    labelText: 'Windows',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _gfWeatheringController,
                  decoration: const InputDecoration(
                    labelText: 'Weathering Course',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _gfConstructionYearController,
                  decoration: const InputDecoration(
                    labelText: 'Year of Construction (Approx)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _gfAgeController,
                  decoration: const InputDecoration(
                    labelText: 'Age of the building',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _gfRemainingLifeController,
                  decoration: const InputDecoration(
                    labelText: 'Expected further life',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _gfDepreciationController,
                  decoration: const InputDecoration(
                    labelText: 'Depreciation Percentage',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _gfReplacementRateController,
                  decoration: const InputDecoration(
                    labelText: 'Replacement rate of construction',
                    border: OutlineInputBorder(),
                  ),
                )
              ]),

              // First Floor Details
              _buildSection(title: 'First Floor Details', children: [
                TextFormField(
                  controller: _ffYearController,
                  decoration: const InputDecoration(
                    labelText: 'Year of Construction',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _ffRoofController,
                  decoration: const InputDecoration(
                    labelText: 'Roof Type',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _ffAreaController,
                  decoration: const InputDecoration(
                    labelText: 'Main Portion Area (Sqft)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _ffCantileverController,
                  decoration: const InputDecoration(
                    labelText: 'Cantilevered Portion Area (Sqft)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _ffTotalController,
                  decoration: const InputDecoration(
                    labelText: 'Total Area (Sqft)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _ffSpecificationController,
                  decoration: const InputDecoration(
                    labelText: 'Specification',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _ffFloorFinishController,
                  decoration: const InputDecoration(
                    labelText: 'Floor Finish',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _ffSuperStructureController,
                  decoration: const InputDecoration(
                    labelText: 'Super structure',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _ffRoofTypeController,
                  decoration: const InputDecoration(
                    labelText: 'Roof',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _ffDoorsController,
                  decoration: const InputDecoration(
                    labelText: 'Doors',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _ffWindowsController,
                  decoration: const InputDecoration(
                    labelText: 'Windows',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _ffWeatheringController,
                  decoration: const InputDecoration(
                    labelText: 'Weathering Course',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _ffConstructionYearController,
                  decoration: const InputDecoration(
                    labelText: 'Year of Construction (Approx)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _ffAgeController,
                  decoration: const InputDecoration(
                    labelText: 'Age of the building',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _ffRemainingLifeController,
                  decoration: const InputDecoration(
                    labelText: 'Expected further life',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _ffDepreciationController,
                  decoration: const InputDecoration(
                    labelText: 'Depreciation Percentage',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _ffReplacementRateController,
                  decoration: const InputDecoration(
                    labelText: 'Replacement rate of construction',
                    border: OutlineInputBorder(),
                  ),
                )
              ]),

              // Terrace Details
              _buildSection(title: 'Terrace Details', children: [
                TextFormField(
                  controller: _terraceYearController,
                  decoration: const InputDecoration(
                    labelText: 'Year of Construction',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _terraceRoofController,
                  decoration: const InputDecoration(
                    labelText: 'Roof Type',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _terraceAreaController,
                  decoration: const InputDecoration(
                    labelText: 'Area (Sqft)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _terraceTotalController,
                  decoration: const InputDecoration(
                    labelText: 'Total Area (Sqft)',
                    border: OutlineInputBorder(),
                  ),
                )
              ]),

              // Approved Plan Details
              _buildSection(title: 'Approved Plan Details', children: [
                TextFormField(
                  controller: _approvedPlanNoController,
                  decoration: const InputDecoration(
                    labelText: 'Plan No.',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _approvedPlanAuthorityController,
                  decoration: const InputDecoration(
                    labelText: 'Issuing Authority',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _planVerifiedController,
                  decoration: const InputDecoration(
                    labelText: 'Plan Verified?',
                    border: OutlineInputBorder(),
                  ),
                ),

                // Total Value
                const SizedBox(height: 24),
                TextFormField(
                  controller: _presentValueController,
                  decoration: const InputDecoration(
                    labelText: 'Present Value of Land & Building',
                    border: OutlineInputBorder(),
                  ),
                )
              ]),

              // Valuer Details

              _buildSection(title: 'Valuer Details', children: [
                TextFormField(
                  controller: _valuerNameController,
                  decoration: const InputDecoration(
                    labelText: 'Valuer Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _valuerAddressController,
                  decoration: const InputDecoration(
                    labelText: 'Valuer Address',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _valuerPhoneController,
                  decoration: const InputDecoration(
                    labelText: 'Valuer Phone',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _valuerEmailController,
                  decoration: const InputDecoration(
                    labelText: 'Valuer Email',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _valuerRegNoController,
                  decoration: const InputDecoration(
                    labelText: 'Chartered Engineer Reg. No.',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _valuerIBBIRegController,
                  decoration: const InputDecoration(
                    labelText: 'IBBI Registration No.',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _valuerWealthTaxRegController,
                  decoration: const InputDecoration(
                    labelText: 'Wealth Tax Registration No.',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _valuerBlackMoneyRegController,
                  decoration: const InputDecoration(
                    labelText: 'Black Money Act Registration No.',
                    border: OutlineInputBorder(),
                  ),
                )
              ]),
              //   'PART D - AMENITIES & EXTRA ITEMS',
              _buildSection(
                  title:
                      'PART D - Amenities & Extra Items(Value after Depreciation)',
                  children: [
                    TextFormField(
                      controller: _amenityPorticoController,
                      decoration: const InputDecoration(
                        labelText: '1. Portico',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _amenityOrnamentalDoorController,
                      decoration: const InputDecoration(
                        labelText: '2. Ornamental Front / Pooja door',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _amenitySitoutGrillsController,
                      decoration: const InputDecoration(
                        labelText: '3. Sitout/Verandah with Steel grills',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _amenitySteelGatesController,
                      decoration: const InputDecoration(
                        labelText: '4. Extra Steel/collapsible gates',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _amenityOpenStaircaseController,
                      decoration: const InputDecoration(
                        labelText: '5. Open staircase',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _amenityWardrobesController,
                      decoration: const InputDecoration(
                        labelText: '6. Wardrobes, showcases, wooden cupboards',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _amenityGlazedTilesController,
                      decoration: const InputDecoration(
                        labelText: '7. Glazed tiles',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _amenityExtraSinksController,
                      decoration: const InputDecoration(
                        labelText: '8. Extra sinks and bath tub',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _amenityMarbleTilesController,
                      decoration: const InputDecoration(
                        labelText: '9. Marble/ceramic tiles flooring',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _amenityInteriorDecorController,
                      decoration: const InputDecoration(
                        labelText: '10. Interior decorations',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _amenityElevationWorksController,
                      decoration: const InputDecoration(
                        labelText: '11. Architectural Elevation works',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _amenityFalseCeilingController,
                      decoration: const InputDecoration(
                        labelText: '12. False ceiling works',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _amenityPanelingWorksController,
                      decoration: const InputDecoration(
                        labelText: '13. Paneling works',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _amenityAluminumWorksController,
                      decoration: const InputDecoration(
                        labelText: '14. Aluminum works',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _amenityAluminumHandrailsController,
                      decoration: const InputDecoration(
                        labelText: '15. Aluminum handrails',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _amenityLumberRoomController,
                      decoration: const InputDecoration(
                        labelText: '16. Separate Lumber Room',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _amenityToiletRoomController,
                      decoration: const InputDecoration(
                        labelText: '17. Separate Toilet Room',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _amenityWaterTankSumpController,
                      decoration: const InputDecoration(
                        labelText: '18. Separate water tank/sump',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _amenityGardeningController,
                      decoration: const InputDecoration(
                        labelText: '19. Trees, gardening',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _amenityAnyOtherController,
                      decoration: const InputDecoration(
                        labelText: '20. Any other',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text('Water supply arrangements',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _amenityOpenWellController,
                      decoration: const InputDecoration(
                        labelText: 'Open Well',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _amenityDeepBoreController,
                      decoration: const InputDecoration(
                        labelText: 'Deep bore',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _amenityHandPumpController,
                      decoration: const InputDecoration(
                        labelText: 'Hand pump',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _amenityCorporationTapController,
                      decoration: const InputDecoration(
                        labelText: 'Corporation Tap',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _amenityUndergroundSumpController,
                      decoration: const InputDecoration(
                        labelText: 'Underground level sump',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _amenityOverheadWaterTankController,
                      decoration: const InputDecoration(
                        labelText: 'Overhead water tank',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text('Drainage arrangements',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _amenitySepticTankController,
                      decoration: const InputDecoration(
                        labelText: 'Septic Tank',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _amenityUndergroundSewerageController,
                      decoration: const InputDecoration(
                        labelText: 'Underground sewerage',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text('Compound Wall, Pavements, Steel Gate',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _amenityCompoundWallController,
                      decoration: const InputDecoration(
                        labelText: 'Compound Wall (Rm. @ Rs. .../m²)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _amenityCompoundWallHeightController,
                      decoration: const InputDecoration(
                        labelText: 'Compound Wall Height',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _amenityCompoundWallLengthController,
                      decoration: const InputDecoration(
                        labelText: 'Compound Wall Length',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _amenityCompoundWallTypeController,
                      decoration: const InputDecoration(
                        labelText: 'Type of construction',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _amenityPavementsController,
                      decoration: const InputDecoration(
                        labelText: 'Pavements ...... Rm. @ Rs. .../m²',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _amenitySteelGateRmController,
                      decoration: const InputDecoration(
                        labelText: 'Steel gate ...... Rm. @ Rs. .../m²',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text('Deposits',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _amenityEBDepositsController,
                      decoration: const InputDecoration(
                        labelText: 'E.B Deposits',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _amenityWaterDepositsController,
                      decoration: const InputDecoration(
                        labelText: 'Water deposits',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _amenityDrainageDepositsController,
                      decoration: const InputDecoration(
                        labelText: 'Drainage deposits',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text('Electrical fittings & others',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _amenityWiringTypeController,
                      decoration: const InputDecoration(
                        labelText: 'Type of wiring',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _amenityFittingsClassController,
                      decoration: const InputDecoration(
                        labelText: 'Class of fittings (superior/Ordinary/Poor)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _amenityLightPointsController,
                      decoration: const InputDecoration(
                        labelText: 'Number of light Points',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _amenityFanPointsController,
                      decoration: const InputDecoration(
                        labelText: 'Fan Points',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _amenityPlugPointsController,
                      decoration: const InputDecoration(
                        labelText: 'Spare Plug Points',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _amenityElectricalOtherController,
                      decoration: const InputDecoration(
                        labelText: 'Any other item',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text('Plumbing installation',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _amenityNoOfClosetsController,
                      decoration: const InputDecoration(
                        labelText: 'No. of water closets',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _amenityClosetsTypeController,
                      decoration: const InputDecoration(
                        labelText: 'Closets Type',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _amenityNoOfWashBasinsController,
                      decoration: const InputDecoration(
                        labelText: 'No. of wash basins',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _amenityNoOfBathTubsController,
                      decoration: const InputDecoration(
                        labelText: 'No. of bath tubs',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _amenityWaterMeterTapsController,
                      decoration: const InputDecoration(
                        labelText: 'Water meter, taps etc',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _amenityPlumbingOtherFixturesController,
                      decoration: const InputDecoration(
                        labelText: 'Any other fixtures - Terrace Roof',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _amenityAnyOtherItemController,
                      decoration: const InputDecoration(
                        labelText: 'Any other',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _amenityTotalController,
                      decoration: const InputDecoration(
                        labelText: 'Total',
                        border: OutlineInputBorder(),
                      ),
                    )
                  ]),
              const SizedBox(height: 24),
              const Text(
                "Total abstract of the entire property",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Table(
                border: TableBorder.all(),
                columnWidths: const {
                  0: FlexColumnWidth(2.5),
                  1: FlexColumnWidth(0.7),
                  2: FlexColumnWidth(2.2),
                  3: FlexColumnWidth(2.2),
                },
                children: [
                  const TableRow(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(6),
                        child: Text("Description",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      Padding(
                        padding: EdgeInsets.all(6),
                        child: Text(":",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      Padding(
                        padding: EdgeInsets.all(6),
                        child: Text("Value adopting\nGLR",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      Padding(
                        padding: EdgeInsets.all(6),
                        child: Text("PMR",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  TableRow(
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(6),
                        child: Text("Part- B   Land"),
                      ),
                      const Padding(
                        padding: EdgeInsets.all(6),
                        child: Text(":"),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(4),
                        child: TextFormField(
                          controller: absLandGlrController,
                          decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: "\u20B9  29,04,000"),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(4),
                        child: TextFormField(
                          controller: absLandPmrController,
                          decoration:
                              const InputDecoration(border: InputBorder.none),
                        ),
                      ),
                    ],
                  ),
                  TableRow(
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(6),
                        child: Text("Part- C   Building"),
                      ),
                      const Padding(
                        padding: EdgeInsets.all(6),
                        child: Text(":"),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(4),
                        child: TextFormField(
                          controller: absBuildingGlrController,
                          decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: "\u20B9  59,62,270"),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(4),
                        child: TextFormField(
                          controller: absBuildingPmrController,
                          decoration:
                              const InputDecoration(border: InputBorder.none),
                        ),
                      ),
                    ],
                  ),
                  TableRow(
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(6),
                        child: Text("Part- D   Extra Items"),
                      ),
                      const Padding(
                        padding: EdgeInsets.all(6),
                        child: Text(":"),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(4),
                        child: TextFormField(
                          controller: absExtraGlrController,
                          decoration:
                              const InputDecoration(border: InputBorder.none),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(4),
                        child: TextFormField(
                          controller: absExtraPmrController,
                          decoration:
                              const InputDecoration(border: InputBorder.none),
                        ),
                      ),
                    ],
                  ),
                  TableRow(
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(6),
                        child: Text("Part- E   Amenities"),
                      ),
                      const Padding(
                        padding: EdgeInsets.all(6),
                        child: Text(":"),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(4),
                        child: TextFormField(
                          controller: absAmenitiesGlrController,
                          decoration:
                              const InputDecoration(border: InputBorder.none),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(4),
                        child: TextFormField(
                          controller: absAmenitiesPmrController,
                          decoration:
                              const InputDecoration(border: InputBorder.none),
                        ),
                      ),
                    ],
                  ),
                  TableRow(
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(6),
                        child: Text("Total",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      const Padding(
                        padding: EdgeInsets.all(6),
                        child: Text(":",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(4),
                        child: TextFormField(
                          controller: absTotalGlrController,
                          decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: "\u20B9  88,66,270"),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(4),
                        child: TextFormField(
                          controller: absTotalPmrController,
                          decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: "\u20B9  2,31,71,000"),
                        ),
                      ),
                    ],
                  ),
                  TableRow(
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(6),
                        child: Text("Say",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      const Padding(
                        padding: EdgeInsets.all(6),
                        child: Text(":",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(4),
                        child: TextFormField(
                          controller: absSayGlrController,
                          decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: "\u20B9  88,66,270"),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(4),
                        child: TextFormField(
                          controller: absSayPmrController,
                          decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: "\u20B9  2,30,00,000"),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              // Replace your current image/location section with this
              const SizedBox(height: 24),
              const Text(
                'Property Images with Location',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

// Image action buttons
              Row(
                children: [
                  ElevatedButton(
                    onPressed: _isLoadingImages
                        ? null
                        : () => _pickImages(ImageSource.gallery),
                    child: const Text('Upload Images'),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _isLoadingImages
                        ? null
                        : () => _pickImages(ImageSource.camera),
                    child: const Text('Take Photo'),
                  ),
                ],
              ),

              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _isLoadingImages ? null : _getCurrentLocation,
                child: const Text('Update Location'),
              ),

              if (_isLoadingImages)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: CircularProgressIndicator(),
                ),

              if (_latitude != null && _longitude != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                      'Current Location: ${_latitude!.toStringAsFixed(6)}, ${_longitude!.toStringAsFixed(6)}'),
                ),

              if (_locationError != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(_locationError!,
                      style: const TextStyle(color: Colors.red)),
                ),

// Display captured images with location
              if (_imagesWithLocation.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text(
                  'Captured Images:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ..._imagesWithLocation.map((imageData) {
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Image.memory(
                          imageData.imageBytes,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Location: ${imageData.locationString}',
                                style: const TextStyle(fontSize: 12),
                              ),
                              Text(
                                'Date: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(imageData.timestamp)}',
                                style: const TextStyle(fontSize: 12),
                              ),
                              if (imageData.description != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: Text(
                                    imageData.description!,
                                    style: const TextStyle(
                                        fontSize: 12,
                                        fontStyle: FontStyle.italic),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        // Align the delete button to the right
                        Align(
                          alignment: Alignment.centerRight,
                          child: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                _imagesWithLocation.remove(imageData);
                              });
                            },
                          ),
                        ),
                        // Add Button to update location for this specific image
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: ElevatedButton.icon(
                            onPressed: _isLoadingImages 
                                ? null 
                                : () => _updateImageLocation(imageData),
                            icon: const Icon(Icons.location_on),
                            label: const Text('Update Location'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade50,
                              foregroundColor: Colors.blue.shade700,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  );
                }),
              ],

              // REMOVED old image and location widgets as they are now replaced by the new section above

              // Generate Report Button
              const SizedBox(height: 24),
              Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: _isGenerating
                          ? null
                          : () async {
                              if (_formKey.currentState!.validate()) {
                                setState(() => _isGenerating = true);
                                try {
                                  final pdf =
                                      await generatePropertyValuationReport();
                                  await Printing.layoutPdf(
                                    onLayout: (PdfPageFormat format) async =>
                                        pdf.save(),
                                  );
                                } catch (e) {
                                  print("PDF Generation Error: $e");
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content:
                                            Text("Failed to generate PDF: $e")),
                                  );
                                } finally {
                                  setState(() => _isGenerating = false);
                                }
                              }
                            },
                      child: const Text('Generate Report'),
                    ),
                    if (_isGenerating)
                      const Positioned(
                        child: CircularProgressIndicator(),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
          heroTag: "f1",
          icon: const Icon(Icons.save),
          label: const Text('Save data'),
          onPressed: () {
            _saveData();
          }),
    );
  }

  Future<void> pickImages() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,
      withData: true,
    );
    if (result != null) {
      setState(() {
        _imagesWithLocation.addAll(result.files.map((f) => ImageWithLocation(
              imageBytes: f.bytes!,
              latitude: _latitude,
              longitude: _longitude,
            )));
      });
    }
  }

  Future<void> _getLocation() async {
    // Set loading state at the beginning
    setState(() {
      _isLoadingImages = true; // Using the existing loading flag
      _locationError = null;
    });

    try {
      // 1. Check if location services are enabled.
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // If not, throw an error to be caught by the catch block.
        throw Exception('Location services are disabled.');
      }

      // 2. Check for permissions.
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          // If denied, throw an error.
          throw Exception('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        // If permanently denied, throw an error.
        throw Exception(
            'Location permissions are permanently denied, we cannot request permissions.');
      }

      // 3. When we reach here, permissions are granted. Fetch position.
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      // 4. Update the state with the new location data.
      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
        // Also update the controller to display the coordinates in the text field

        _lat.text = _latitude!.toStringAsFixed(6);
        _long.text = _longitude!.toStringAsFixed(6);
        // Assuming you have a controller for the lat-long text field
        _latitude = null; // Clear outdated location data on error
        _longitude = null;
        // _latitudelongitudeController.text =
        //     '${_latitude!.toStringAsFixed(6)}, ${_longitude!.toStringAsFixed(6)}';
        _locationError = null; // Clear any previous error
      });
    } catch (e) {
      // If any error occurs, update the state to show the error.
      setState(() {
        _locationError = e.toString();
        _latitude = null; // Clear outdated location data on error
        _longitude = null;
      });
    } finally {
      // Always turn off the loading indicator at the end.
      setState(() {
        _isLoadingImages = false;
      });
    }
  }

  // Helper method to fetch location and update a specific image
  Future<void> _updateImageLocation(ImageWithLocation imageToUpdate) async {
    setState(() => _isLoadingImages = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) throw Exception('Location services are disabled.');

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) throw Exception('Location permissions denied');
      }
      if (permission == LocationPermission.deniedForever) throw Exception('Location permissions permanently denied');

      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

      setState(() {
        // Find the index of the image to update
        final index = _imagesWithLocation.indexOf(imageToUpdate);
        if (index != -1) {
          // Replace with a new instance containing the updated location
          _imagesWithLocation[index] = imageToUpdate.copyWith(
            latitude: position.latitude,
            longitude: position.longitude,
          );
        }
      });
      
      if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image location updated successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating image location: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoadingImages = false);
    }
  }

  Future<pw.MemoryImage> loadLogoImage() async {
    final ByteData data = await rootBundle.load('assets/images/logo.png');
    final Uint8List bytes = data.buffer.asUint8List();
    return pw.MemoryImage(bytes);
  }

  /// Fetches the current device's location and updates the state.
  Future<void> _getCurrentLocation() async {
    // Set loading state at the beginning
    setState(() {
      _isLoadingImages = true; // Using the existing loading flag
      _locationError = null;
    });

    try {
      // 1. Check if location services are enabled.
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // If not, throw an error to be caught by the catch block.
        throw Exception('Location services are disabled.');
      }

      // 2. Check for permissions.
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          // If denied, throw an error.
          throw Exception('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        // If permanently denied, throw an error.
        throw Exception(
            'Location permissions are permanently denied, we cannot request permissions.');
      }

      // 3. When we reach here, permissions are granted. Fetch position.
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      // 4. Update the state with the new location data.
      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
        // Also update the controller to display the coordinates in the text field

        // _nearByLat.text = _latitude!.toStringAsFixed(6);
        // _nearByLong.text = _longitude!.toStringAsFixed(6);
        // Assuming you have a controller for the lat-long text field

        _latitudelongitudeController.text =
            '${_latitude!.toStringAsFixed(6)}, ${_longitude!.toStringAsFixed(6)}';
        _locationError = null; // Clear any previous error
      });
    } catch (e) {
      // If any error occurs, update the state to show the error.
      setState(() {
        _locationError = e.toString();
        _latitude = null; // Clear outdated location data on error
        _longitude = null;
      });
    } finally {
      // Always turn off the loading indicator at the end.
      setState(() {
        _isLoadingImages = false;
      });
    }
  }
// ========== END: FIX ==========

  Future<pw.Document> generatePropertyValuationReport() async {
    final pdf = pw.Document();

    // Load a font
    final fontData = await rootBundle.load("assets/fonts/OpenSans-Regular.ttf");
    final ttf = pw.Font.ttf(fontData);
    final boldFontData =
        await rootBundle.load("assets/fonts/OpenSans-Bold.ttf");
    final boldTtf = pw.Font.ttf(boldFontData);

    final defaultTextStyle = pw.TextStyle(font: ttf, fontSize: 9);
    final boldTextStyle = pw.TextStyle(font: boldTtf, fontSize: 9);

    final logoImage = await loadLogoImage(); // Load logo

    // Building calculation helpers
    double pRow(String s) => double.tryParse(s.replaceAll(',', '')) ?? 0.0;
    
    double gfAreaVal = pRow(_gfAreaController.text);
    double gfRateVal = pRow(_gfReplacementRateController.text);
    double gfReplCostVal = gfAreaVal * gfRateVal;
    double gfDepPercentVal = pRow(_gfDepreciationController.text);
    if (gfDepPercentVal == 0 && gfRateVal > 0) gfDepPercentVal = 11.11; 
    double gfDepValVal = gfReplCostVal * (gfDepPercentVal / 100);
    double gfNetVal = gfReplCostVal - gfDepValVal;

    double ffAreaVal = pRow(_ffAreaController.text);
    double ffRateVal = pRow(_ffReplacementRateController.text);
    double ffReplCostVal = ffAreaVal * ffRateVal;
    double ffDepPercentVal = pRow(_ffDepreciationController.text);
    if (ffDepPercentVal == 0 && ffRateVal > 0) ffDepPercentVal = 11.11;
    double ffDepValVal = ffReplCostVal * (ffDepPercentVal / 100);
    double ffNetVal = ffReplCostVal - ffDepValVal;

    double terraceAreaValRow = pRow(_terraceAreaController.text);
    // Assume terrace rate is 50% of GF rate if not specified
    double terraceRateValRow = gfRateVal * 0.5;
    double terraceReplCostVal = terraceAreaValRow * terraceRateValRow;
    double terraceNetVal = terraceReplCostVal;

    double totalPlinthValPdf = gfAreaVal + ffAreaVal + terraceAreaValRow;
    double totalReplCostValPdf = gfReplCostVal + ffReplCostVal + terraceReplCostVal;
    double totalDepValPdf = gfDepValVal + ffDepValVal;
    double totalNetValPdf = gfNetVal + ffNetVal + terraceNetVal;

    final widgets = <pw.Widget>[
      // SBI-Style Header
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            height: 80,
            width: 80,
            child: pw.Image(logoImage),
          ),
          // Right side text (Valuer Details)
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                'VIGNESH. S',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.indigo,
                  font: boldTtf,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                'Chartered Engineer (AM1920793)',
                style: pw.TextStyle(
                  fontSize: 12,
                  color: PdfColors.indigo,
                  font: ttf,
                ),
              ),
              pw.Text(
                'Registered valuer under section 247 of Companies Act, 2013',
                style: pw.TextStyle(
                  fontSize: 12,
                  color: PdfColors.indigo,
                  font: ttf,
                ),
              ),
              pw.Text(
                '(IBBI/RV/01/2020/13411)',
                style: pw.TextStyle(
                  fontSize: 12,
                  color: PdfColors.indigo,
                  font: ttf,
                ),
              ),
              pw.Text(
                'Registered valuer under section 34AB of Wealth Tax Act, 1957',
                style: pw.TextStyle(
                  fontSize: 12,
                  color: PdfColors.indigo,
                  font: ttf,
                ),
              ),
              pw.Text(
                '(I-9AV/CC-TVM/2020-21)',
                style: pw.TextStyle(
                  fontSize: 12,
                  color: PdfColors.indigo,
                  font: ttf,
                ),
              ),
              pw.Text(
                'Registered valuer under section 77(1) of Black Money Act, 2015',
                style: pw.TextStyle(
                  fontSize: 12,
                  color: PdfColors.indigo,
                  font: ttf,
                ),
              ),
              pw.Text(
                '(I-3/AV-BM/PCIT-TVM/2023-24)',
                style: pw.TextStyle(
                  fontSize: 12,
                  color: PdfColors.indigo,
                  font: ttf,
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
            color: PdfColor.fromHex('#8a9b8e'), // Approx background color
            padding: const pw.EdgeInsets.all(6),
            width: double.infinity,
            child: pw.Text(
              'TC-37/777(1), Big Palla Street, Fort P.O. Thiruvananthapuram-695023',
              style: pw.TextStyle(
                fontSize: 12,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.black,
                font: boldTtf,
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
               // Empty space or placeholder as per SBI design
               pw.Text('`', style: pw.TextStyle(fontSize: 14, font: ttf)),

              // Phone
              pw.Row(
                children: [
                  pw.Text(
                    'Phone: +91 89030 42635',
                    style: pw.TextStyle(fontSize: 12, font: ttf),
                  ),
                ],
              ),

              // Email
              pw.Row(
                children: [
                  pw.Text(
                    'Email: subramonyvignesh@gmail.com',
                    style: pw.TextStyle(fontSize: 12, font: ttf),
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
                      font: boldTtf,
                    ),
                  ),
                  pw.Text(
                    'The Canara Bank', // Adapted to Canara Bank
                    style: pw.TextStyle(fontSize: 12, font: ttf),
                  ),
                   // You might want to add specific Branch details if available in controllers
                ],
              ),
              pw.Text(
                'Ref No.: ${_referenceNoController.text.isNotEmpty ? _referenceNoController.text : "______"}',
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                  font: boldTtf,
                ),
              ),
            ],
          ),
        ],
      ),

      pw.SizedBox(height: 30),
      
      // Titles
      pw.Center(
        child: pw.Text(
          'FORMAT', // Adjusted to match SBI style roughly but specific title might differ
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
            font: boldTtf,
          ), 
        ),
      ),
      pw.SizedBox(height: 8), 
      pw.Center(
        child: pw.Text(
          'VALUATION REPORT (IN RESPECT OF LAND / SITE AND BUILDING)',
          style: pw.TextStyle(
            fontSize: 12,
            fontWeight: pw.FontWeight.bold,
             font: boldTtf,
          ), 
          textAlign: pw.TextAlign.center,
        ),
      ),
      pw.SizedBox(height: 15),
      

      pw.SizedBox(height: 8),

      // Part A - Basic Data
      pw.Table(
        border: pw.TableBorder.all(width: 0.5, color: PdfColors.black),
        columnWidths: {
          0: const pw.FlexColumnWidth(0.5), // S.No
          1: const pw.FlexColumnWidth(3), // Description
          2: const pw.FlexColumnWidth(0.2), // Colon
          3: const pw.FlexColumnWidth(3.8), // Value
        },
        defaultVerticalAlignment: pw.TableCellVerticalAlignment.middle,
        children: [
          // Section Header
          pw.TableRow(
            children: [
              pw.Container(
                alignment: pw.Alignment.center,
                padding: const pw.EdgeInsets.all(6),
                child: pw.Text('I.', style: pw.TextStyle(font: boldTtf)),
              ),
              pw.Container(
                alignment: pw.Alignment.centerLeft,
                padding: const pw.EdgeInsets.all(6),
                child: pw.Text('GENERAL', style: pw.TextStyle(font: boldTtf)),
              ),
               pw.Container(
                alignment: pw.Alignment.center,
                padding: const pw.EdgeInsets.all(6),
                child: pw.Text('', style: pw.TextStyle(font: boldTtf)),
              ),
              pw.Container(),
            ],
          ),
          // 1. Purpose of valuation
          tableRow3('1.', 'Purpose of valuation', _purposeController.text),
          // 2. a) Date of inspection
          tableRow3(
              '2.', 'a) Date of inspection', _inspectionDateController.text),
          // 2. b) Date on which the valuation is made
          tableRow3('', 'b) Date on which the valuation is made',
              _valuationDateController.text),
          // 3. Name of the reported owner with present address and phone number
          tableRow3(
              '3.',
              'Name of the reported owner with present address and phone number',
              '${_ownerNameController.text}\n${_ownerAddressController.text}'),
          // 4. Documents produced for perusal (main row)
          // 4. Documents produced for perusal (main row)
          pw.TableRow(
            children: [
              pw.Container(
                alignment: pw.Alignment.topCenter,
                padding: const pw.EdgeInsets.all(5),
                child: pw.Text('4.'),
              ),
              pw.Container(
                alignment: pw.Alignment.topLeft,
                padding: const pw.EdgeInsets.all(5),
                child: pw.Text('Documents produced for perusal:'),
              ),
               pw.Container(
                alignment: pw.Alignment.topCenter,
                padding: const pw.EdgeInsets.all(5),
                child: pw.Text(':'),
              ),
              pw.Container(
                alignment: pw.Alignment.topLeft,
                padding: const pw.EdgeInsets.all(5),
                // Display each document on a new line, no numbering
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: _documentsController.text
                      .split('\n')
                      .where((e) => e.trim().isNotEmpty)
                      .map((doc) => pw.Text(doc))
                      .toList(),
                ),
              ),
            ],
          ),
          // 5. Brief description
          tableRow3(
              '5.',
              'Brief description of the property (including leasehold/freehold etc.)',
              _propertyDescriptionController.text),
          // 6. Scope of valuation
          tableRow3('6.', 'Scope of valuation', _scopeController.text),
          // 7. Bank details
          tableRow3(
              '7.',
              'If this report is to be used for any bank purpose, state the name of the bank and branch, if known',
              _bankController.text),
        ],
      ),

      // Part II - Description of Property
      pw.Text('II. DESCRIPTION OF THE PROPERTY:',
          style: pw.TextStyle(font: boldTtf)),
      pw.Table(
        border: pw.TableBorder.all(),
        columnWidths: {
          0: const pw.FixedColumnWidth(28), // S.No.
          1: const pw.FixedColumnWidth(200), // Description
          2: const pw.FixedColumnWidth(307), // Value/Content
        },
        defaultVerticalAlignment: pw.TableCellVerticalAlignment.middle,
        children: [
          // 1. Postal address
          tableRowDesc('1.', 'Postal address of the property with Pin code',
              _propertyAddressController.text),
          // 2. City / Town, Residential, Commercial, Industrial Area
          tableRowDesc('2.', 'City / Town', _cityTownController.text),
          tableRowDesc('', 'Residential Area', _residentialAreaController.text),
          tableRowDesc('', 'Commercial Area', _commercialAreaController.text),
          tableRowDesc('', 'Industrial Area', _industrialAreaController.text),
          // 3. Classification of the area
          tableRowDesc('3.', 'Classification of the area', ''),
          tableRowDesc(
              '', 'i) High / Middle / Poor', _classificationController.text),
          tableRowDesc('', 'ii) Urban / Semi Urban / Rural',
              _urbanClassificationController.text),
          // 4. Corporation or Panchayat
          tableRowDesc(
              '4.',
              'Coming under Corporation limit / Village Panchayat / Municipality',
              _localAuthorityController.text),
          // 5. Govt enactments
          tableRowDesc(
              '5.',
              'Whether covered under any State / Central Govt. enactments (e.g. Urban Land Ceiling Act) or notified under agency area / scheduled area / cantonment area',
              _govtActsController.text),
          // 6. Agricultural conversion
          tableRowDesc(
              '6.',
              'In case it is an agricultural land, any conversion to house site plots is contemplated',
              _agriculturalConversionController.text),
          // 7. Location of the property
          tableRowDesc('7.', 'Location of the property', ''),
          tableRowDesc('', 'a. Block No.', _blockNoController.text),
          tableRowDesc('', 'b. Re-Survey No.', _resurveyNoController.text),
          tableRowDesc('', 'c. Survey No.', _surveyNoController.text),
          tableRowDesc('', 'd. Thandapper No.', _thandapperNoController.text),
          tableRowDesc(
              '', 'e. Ward No. & Name of Ward', _wardNoController.text),
          tableRowDesc('', 'f. Door No.', _doorNoController.text),
          tableRowDesc('', 'g. T. S. No. / Village', _tsNoController.text),
          tableRowDesc('', 'h. Ward / Taluka', _talukController.text),
          tableRowDesc('', 'i. Mandal / District', _districtController.text),
          // 8. Boundaries
          pw.TableRow(
            children: [
              pw.Container(
                alignment: pw.Alignment.topLeft,
                padding: const pw.EdgeInsets.all(5),
                child: pw.Text('8.'),
              ),
              pw.Container(
                alignment: pw.Alignment.topLeft,
                padding: const pw.EdgeInsets.all(5),
                child: pw.Text('Boundaries of the property'),
              ),
              pw.Container(
                padding: const pw.EdgeInsets.all(0),
                child: pw.Table(
                  border:
                      pw.TableBorder.all(width: 0.8, color: PdfColors.grey700),
                  columnWidths: {
                    0: const pw.FixedColumnWidth(110),
                    1: const pw.FixedColumnWidth(98),
                    2: const pw.FixedColumnWidth(99),
                  },
                  children: [
                    pw.TableRow(
                      children: [
                        pw.Container(),
                        pw.Container(
                          alignment: pw.Alignment.center,
                          padding: const pw.EdgeInsets.all(3),
                          child: pw.Text('As per title deed',
                              style: pw.TextStyle(font: boldTtf, fontSize: 9)),
                        ),
                        pw.Container(
                          alignment: pw.Alignment.center,
                          padding: const pw.EdgeInsets.all(3),
                          child: pw.Text('As per Actuals & Location Sketch',
                              style: pw.TextStyle(font: boldTtf, fontSize: 9)),
                        ),
                      ],
                    ),
                    pw.TableRow(
                      children: [
                        pw.Container(
                          alignment: pw.Alignment.centerLeft,
                          padding: const pw.EdgeInsets.all(3),
                          child: pw.Text('North'),
                        ),
                        pw.Container(
                          padding: const pw.EdgeInsets.all(3),
                          child: pw.Text(_northBoundaryController.text),
                        ),
                        pw.Container(
                          padding: const pw.EdgeInsets.all(3),
                          child: pw.Text(_northBoundaryActualController.text),
                        ),
                      ],
                    ),
                    pw.TableRow(
                      children: [
                        pw.Container(
                          alignment: pw.Alignment.centerLeft,
                          padding: const pw.EdgeInsets.all(3),
                          child: pw.Text('South'),
                        ),
                        pw.Container(
                          padding: const pw.EdgeInsets.all(3),
                          child: pw.Text(_southBoundaryController.text),
                        ),
                        pw.Container(
                          padding: const pw.EdgeInsets.all(3),
                          child: pw.Text(_southBoundaryActualController.text),
                        ),
                      ],
                    ),
                    pw.TableRow(
                      children: [
                        pw.Container(
                          alignment: pw.Alignment.centerLeft,
                          padding: const pw.EdgeInsets.all(3),
                          child: pw.Text('East'),
                        ),
                        pw.Container(
                          padding: const pw.EdgeInsets.all(3),
                          child: pw.Text(_eastBoundaryController.text),
                        ),
                        pw.Container(
                          padding: const pw.EdgeInsets.all(3),
                          child: pw.Text(_eastBoundaryActualController.text),
                        ),
                      ],
                    ),
                    pw.TableRow(
                      children: [
                        pw.Container(
                          alignment: pw.Alignment.centerLeft,
                          padding: const pw.EdgeInsets.all(3),
                          child: pw.Text('West'),
                        ),
                        pw.Container(
                          padding: const pw.EdgeInsets.all(3),
                          child: pw.Text(_westBoundaryController.text),
                        ),
                        pw.Container(
                          padding: const pw.EdgeInsets.all(3),
                          child: pw.Text(_westBoundaryActualController.text),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          // 9. Latitude, Longitude and Coordinates
          tableRowDesc('9.', 'Latitude, Longitude and Coordinates of the site',
              _latitudelongitudeController.text),
          // 10. Property Tax Referred
          pw.TableRow(
            children: [
              pw.Container(
                alignment: pw.Alignment.topLeft,
                padding: const pw.EdgeInsets.all(5),
                child: pw.Text('10.'),
              ),
              pw.Container(
                alignment: pw.Alignment.topLeft,
                padding: const pw.EdgeInsets.all(5),
                child: pw.Text('Property Tax Referred'),
              ),
              pw.Container(), // Empty to match the grid structure
            ],
          ),
          pw.TableRow(
            children: [
              pw.Container(),
              pw.Container(
                decoration: const pw.BoxDecoration(
                  border: pw.Border(
                    top: pw.BorderSide(width: 1, color: PdfColors.black),
                    right: pw.BorderSide(width: 1, color: PdfColors.black),
                  ),
                ),
                padding:
                    const pw.EdgeInsets.symmetric(vertical: 3, horizontal: 5),
                child: pw.Text('Period'),
              ),
              pw.Container(
                decoration: const pw.BoxDecoration(
                  border: pw.Border(
                    top: pw.BorderSide(width: 1, color: PdfColors.black),
                  ),
                ),
                child: pw.Row(
                  children: [
                    pw.Container(
                      width: 20,
                      alignment: pw.Alignment.centerLeft,
                      // child: pw.Text(':'),
                    ),
                    pw.Expanded(
                      child: pw.Container(
                        padding: const pw.EdgeInsets.symmetric(
                            vertical: 3, horizontal: 5),
                        child: pw.Text(_taxPeriodController.text),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          pw.TableRow(
            children: [
              pw.Container(),
              pw.Container(
                decoration: const pw.BoxDecoration(
                  border: pw.Border(
                    right: pw.BorderSide(width: 1, color: PdfColors.black),
                  ),
                ),
                padding:
                    const pw.EdgeInsets.symmetric(vertical: 3, horizontal: 5),
                child: pw.Text('Building ID'),
              ),
              pw.Container(
                child: pw.Row(
                  children: [
                    pw.Container(
                      width: 20,
                      alignment: pw.Alignment.centerLeft,
                      // child: pw.Text(':'),
                    ),
                    pw.Expanded(
                      child: pw.Container(
                        padding: const pw.EdgeInsets.symmetric(
                            vertical: 3, horizontal: 5),
                        child: pw.Text(_buildingIdController.text),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          pw.TableRow(
            children: [
              pw.Container(),
              pw.Container(
                decoration: const pw.BoxDecoration(
                  border: pw.Border(
                    right: pw.BorderSide(width: 1, color: PdfColors.black),
                  ),
                ),
                padding:
                    const pw.EdgeInsets.symmetric(vertical: 3, horizontal: 5),
                child: pw.Text('Assessment No.'),
              ),
              pw.Container(
                child: pw.Row(
                  children: [
                    pw.Container(
                      width: 20,
                      alignment: pw.Alignment.centerLeft,
                      // child: pw.Text(':'),
                    ),
                    pw.Expanded(
                      child: pw.Container(
                        padding: const pw.EdgeInsets.symmetric(
                            vertical: 3, horizontal: 5),
                        child: pw.Text(_assessmentNoController.text),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          pw.TableRow(
            children: [
              pw.Container(),
              pw.Container(
                decoration: const pw.BoxDecoration(
                  border: pw.Border(
                    right: pw.BorderSide(width: 1, color: PdfColors.black),
                  ),
                ),
                padding:
                    const pw.EdgeInsets.symmetric(vertical: 3, horizontal: 5),
                child: pw.Text('Tax Amount'),
              ),
              pw.Container(
                child: pw.Row(
                  children: [
                    pw.Container(
                      width: 20,
                      alignment: pw.Alignment.centerLeft,
                      // child: pw.Text(':'),
                    ),
                    pw.Expanded(
                      child: pw.Container(
                        padding: const pw.EdgeInsets.symmetric(
                            vertical: 3, horizontal: 5),
                        child: pw.Text(_taxAmountController.text),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          pw.TableRow(
            children: [
              pw.Container(),
              pw.Container(
                decoration: const pw.BoxDecoration(
                  border: pw.Border(
                    right: pw.BorderSide(width: 1, color: PdfColors.black),
                    bottom: pw.BorderSide(width: 1, color: PdfColors.black),
                  ),
                ),
                padding:
                    const pw.EdgeInsets.symmetric(vertical: 3, horizontal: 5),
                child: pw.Text('Receipt in the name of'),
              ),
              pw.Container(
                decoration: const pw.BoxDecoration(
                  border: pw.Border(
                    bottom: pw.BorderSide(width: 1, color: PdfColors.black),
                  ),
                ),
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Container(
                      width: 20,
                      alignment: pw.Alignment.topLeft,
                      // child: pw.Text(':'),
                    ),
                    pw.Expanded(
                      child: pw.Container(
                        padding: const pw.EdgeInsets.symmetric(
                            vertical: 3, horizontal: 5),
                        child: pw.Text(_taxReceiptNameController.text),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // 11. Electricity Service Connection
          pw.TableRow(
            children: [
              pw.Container(
                alignment: pw.Alignment.topLeft,
                padding: const pw.EdgeInsets.all(5),
                child: pw.Text('11.'),
              ),
              pw.Container(
                alignment: pw.Alignment.topLeft,
                padding: const pw.EdgeInsets.all(5),
                child: pw.Text('Electricity Service Connection'),
              ),
              pw.Container(
                alignment: pw.Alignment.topLeft,
                padding: const pw.EdgeInsets.all(2),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Row(
                      children: [
                        pw.Container(width: 80, child: pw.Text('Consumer No')),
                        pw.Text(': ${_consumerNoController.text}'),
                      ],
                    ),
                    pw.Row(
                      children: [
                        pw.Container(
                            width: 80, child: pw.Text('In the name of')),
                        pw.Text(': ${_electricityNameController.text}'),
                      ],
                    ),
                    pw.Row(
                      children: [
                        pw.Container(
                            width: 80, child: pw.Text('Other details, if any')),
                        pw.Text(': ${_otherDetailsController.text}'),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          // 12. Property is currently occupied by
          tableRowDesc('12.', 'Property is currently occupied by',
              _occupancyStatusController.text),
          // 13. If tenanted fully, what is the gross monthly rent
          tableRowDesc(
              '13.',
              'If tenanted fully, what is the gross monthly rent',
              _tenatedRentController.text),
          // 14. Probable monthly rent and advance amount
          pw.TableRow(
            children: [
              pw.Container(
                alignment: pw.Alignment.topLeft,
                padding: const pw.EdgeInsets.all(5),
                child: pw.Text('14.'),
              ),
              pw.Container(
                alignment: pw.Alignment.topLeft,
                padding: const pw.EdgeInsets.all(5),
                child: pw.Text(
                    'If occupied by both, by assuming the entire building is let out'),
              ),
              pw.Container(
                alignment: pw.Alignment.topLeft,
                padding: const pw.EdgeInsets.all(2),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Row(
                      children: [
                        pw.Container(
                            width: 140,
                            child:
                                pw.Text('What is the probable monthly rent')),
                        pw.Text(': ${_monthlyRentController.text}'),
                      ],
                    ),
                    pw.Row(
                      children: [
                        pw.Container(
                            width: 140,
                            child: pw.Text('What is the advance amount')),
                        pw.Text(': ${_advanceAmountController.text}'),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      // Part III - Description of Property
      pw.Text('III. DESCRIPTION OF THE PROPERTY:',
          style: pw.TextStyle(font: boldTtf)),
      pw.SizedBox(height: 10),

      pw.TableHelper.fromTextArray(
        data: <List<String>>[
          <String>['1', 'FSI:${_fsiController.text}'],
          <String>['2', 'Plot Coverage:${_plotCoverageController.text}'],
        ],
        headerCount: 0,
        cellAlignment: pw.Alignment.topLeft,
        cellStyle: defaultTextStyle,
        // headerStyle: boldTextStyle, // Not needed as headerCount is 0
        columnWidths: {
          0: const pw.FixedColumnWidth(30),
          1: const pw.FixedColumnWidth(500),
        },
      ),
      pw.SizedBox(height: 20),
      // Part B - Land
      pw.Text('PART B - LAND', style: pw.TextStyle(font: boldTtf)),
      pw.Table(
        border: pw.TableBorder.all(),
        columnWidths: {
          0: const pw.FixedColumnWidth(30), // S.No.
          1: const pw.FixedColumnWidth(200), // Description
          2: const pw.FixedColumnWidth(120), // A (as per title deed)
          3: const pw.FixedColumnWidth(120), // B (Actuals)
        },
        defaultVerticalAlignment: pw.TableCellVerticalAlignment.middle,
        children: [
          // Title row
          pw.TableRow(
            children: [
              pw.Container(
                alignment: pw.Alignment.center,
                padding: const pw.EdgeInsets.all(4),
                child: pw.Text('1.'),
              ),
              pw.Container(
                alignment: pw.Alignment.centerLeft,
                padding: const pw.EdgeInsets.all(4),
                child: pw.Text('Dimensions of the site'),
              ),
              pw.Container(
                alignment: pw.Alignment.center,
                padding: const pw.EdgeInsets.all(4),
                child: pw.Text('A (as per title deed)', style: boldTextStyle),
              ),
              pw.Container(
                alignment: pw.Alignment.center,
                padding: const pw.EdgeInsets.all(4),
                child: pw.Text('B (Actuals)', style: boldTextStyle),
              ),
            ],
          ),
          // North, South, East, West, Extent
          pw.TableRow(
            children: [
              pw.Container(),
              pw.Container(
                  alignment: pw.Alignment.centerLeft,
                  padding: const pw.EdgeInsets.all(4),
                  child: pw.Text('North')),
              pw.Container(
                  alignment: pw.Alignment.center,
                  padding: const pw.EdgeInsets.all(4),
                  child: pw.Text(_northDeedController.text)),
              pw.Container(
                  alignment: pw.Alignment.center,
                  padding: const pw.EdgeInsets.all(4),
                  child: pw.Text(_northActualController.text)),
            ],
          ),
          pw.TableRow(
            children: [
              pw.Container(),
              pw.Container(
                  alignment: pw.Alignment.centerLeft,
                  padding: const pw.EdgeInsets.all(4),
                  child: pw.Text('South')),
              pw.Container(
                  alignment: pw.Alignment.center,
                  padding: const pw.EdgeInsets.all(4),
                  child: pw.Text(_southDeedController.text)),
              pw.Container(
                  alignment: pw.Alignment.center,
                  padding: const pw.EdgeInsets.all(4),
                  child: pw.Text(_southActualController.text)),
            ],
          ),
          pw.TableRow(
            children: [
              pw.Container(),
              pw.Container(
                  alignment: pw.Alignment.centerLeft,
                  padding: const pw.EdgeInsets.all(4),
                  child: pw.Text('East')),
              pw.Container(
                  alignment: pw.Alignment.center,
                  padding: const pw.EdgeInsets.all(4),
                  child: pw.Text(_eastDeedController.text)),
              pw.Container(
                  alignment: pw.Alignment.center,
                  padding: const pw.EdgeInsets.all(4),
                  child: pw.Text(_eastActualController.text)),
            ],
          ),
          pw.TableRow(
            children: [
              pw.Container(),
              pw.Container(
                  alignment: pw.Alignment.centerLeft,
                  padding: const pw.EdgeInsets.all(4),
                  child: pw.Text('West')),
              pw.Container(
                  alignment: pw.Alignment.center,
                  padding: const pw.EdgeInsets.all(4),
                  child: pw.Text(_westDeedController.text)),
              pw.Container(
                  alignment: pw.Alignment.center,
                  padding: const pw.EdgeInsets.all(4),
                  child: pw.Text(_westActualController.text)),
            ],
          ),
          pw.TableRow(
            children: [
              pw.Container(),
              pw.Container(
                  alignment: pw.Alignment.centerLeft,
                  padding: const pw.EdgeInsets.all(4),
                  child: pw.Text('Extent')),
              pw.Container(
                  alignment: pw.Alignment.center,
                  padding: const pw.EdgeInsets.all(4),
                  child: pw.Text(_extentDeedController.text)),
              pw.Container(
                  alignment: pw.Alignment.center,
                  padding: const pw.EdgeInsets.all(4),
                  child: pw.Text(_extentActualController.text)),
            ],
          ),
          // 2. Extent of site (least of 1a & 1b)
          pw.TableRow(
            children: [
              pw.Container(
                alignment: pw.Alignment.center,
                padding: const pw.EdgeInsets.all(4),
                child: pw.Text('2.'),
              ),
              pw.Container(
                alignment: pw.Alignment.centerLeft,
                padding: const pw.EdgeInsets.all(4),
                child: pw.Text('Extent of site (least of 1a & 1b)'),
              ),
              pw.Container(
                alignment: pw.Alignment.center,
                padding: const pw.EdgeInsets.all(4),
                child: pw.Text(_extentConsideredController.text),
              ),
              pw.Container(),
            ],
          ),
          // Size of Plot rows
          pw.TableRow(
            children: [
              pw.Container(),
              pw.Container(
                  alignment: pw.Alignment.centerLeft,
                  padding: const pw.EdgeInsets.all(4),
                  child: pw.Text('Size of the Plot')),
              pw.Container(),
              pw.Container(),
            ],
          ),
          pw.TableRow(
            children: [
              pw.Container(),
              pw.Container(
                  alignment: pw.Alignment.centerLeft,
                  padding: const pw.EdgeInsets.only(
                      left: 18, top: 3, bottom: 3, right: 3),
                  child: pw.Text('North & South')),
              pw.Container(
                  alignment: pw.Alignment.centerLeft,
                  padding: const pw.EdgeInsets.all(4),
                  child: pw.Text(_plotSizeNSController.text)),
              pw.Container(),
            ],
          ),
          pw.TableRow(
            children: [
              pw.Container(),
              pw.Container(
                  alignment: pw.Alignment.centerLeft,
                  padding: const pw.EdgeInsets.only(
                      left: 18, top: 3, bottom: 3, right: 3),
                  child: pw.Text('East & West')),
              pw.Container(
                  alignment: pw.Alignment.centerLeft,
                  padding: const pw.EdgeInsets.all(4),
                  child: pw.Text(_plotSizeEWController.text)),
              pw.Container(),
            ],
          ),
          pw.TableRow(
            children: [
              pw.Container(),
              pw.Container(
                  alignment: pw.Alignment.centerLeft,
                  padding: const pw.EdgeInsets.only(
                      left: 18, top: 3, bottom: 3, right: 3),
                  child: pw.Text('Total Extent of Plot')),
              pw.Container(
                  alignment: pw.Alignment.centerLeft,
                  padding: const pw.EdgeInsets.all(4),
                  child: pw.Text(_totalExtentController.text)),
              pw.Container(),
            ],
          ),
        ],
      ),
      pw.Table(
        border: pw.TableBorder.all(),
        columnWidths: {
          0: const pw.FixedColumnWidth(210),
          1: const pw.FixedColumnWidth(260),
        },
        defaultVerticalAlignment: pw.TableCellVerticalAlignment.middle,
        children: [
          // Characteristics of the site
          tableRow2('What is the character of the locality',
              _localityCharacterController.text),
          tableRow2('What is the classification of the locality',
              _localityClassificationController.text),
          tableRow2('Development of surrounding areas',
              _surroundingDevelopmentController.text),
          tableRow2('Possibility of frequent flooding/sub merging',
              _floodingController.text),
          tableRow2(
              'Feasibility to the Civic amenities like school, hospital, bus stop, market etc.',
              _amenitiesController.text),
          tableRow2('Level of land with topographical conditions',
              _landLevelController.text),
          tableRow2('Shape of land', _landShapeController.text),
          tableRow2(
              'Type of use to which it can be put', _landUseController.text),
          tableRow2('Any usage restriction', _usageRestrictionController.text),
          tableRow2('Is plot in town planning approved layout?',
              _townPlanningController.text),
          tableRow2(
              'Corner plot or intermittent plot?', _plotTypeController.text),
          tableRow2('Road facilities', _roadFacilitiesController.text),
          tableRow2(
              'Type of road available at present', _roadTypeController.text),
          tableRow2('Width of road - is it below 20 ft. or more than 20 ft.',
              _roadWidthController.text),
          tableRow2('Is it a land - locked land?', _landLockedController.text),
          tableRow2('Water potentiality', _waterPotentialController.text),
          tableRow2('Underground sewerage system', _sewerageController.text),
          tableRow2('Is power supply available at the site?',
              _powerSupplyController.text),
          // Advantages of site
          pw.TableRow(
            children: [
              pw.Container(
                alignment: pw.Alignment.centerLeft,
                padding: const pw.EdgeInsets.all(4),
                child: pw.Text('Advantage of the site'),
              ),
              pw.Container(
                alignment: pw.Alignment.centerLeft,
                padding: const pw.EdgeInsets.all(4),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: _siteAdvantagesController.text
                      .split('\n')
                      .map((e) => pw.Text(e))
                      .toList(),
                ),
              ),
            ],
          ),
          // Special remarks
          tableRow2(
            'Special remarks, if any, like threat of acquisition of land for public service purposes, road widening or applicability of CRZ provisions etc. (Distance from seacoast / tidal level must be incorporated)',
            _specialRemarksController.text,
          ),
        ],
      ),
      pw.SizedBox(height: 12),
// Value adopting GLR and PMR tables
      pw.Table(
        border: pw.TableBorder.all(color: PdfColors.black, width: 1),
        columnWidths: {
          0: const pw.FlexColumnWidth(2.5),
          1: const pw.FlexColumnWidth(0.5),
          2: const pw.FlexColumnWidth(2),
        },
        children: [
          // GLR Header
          pw.TableRow(
            children: [
              pw.Container(
                alignment: pw.Alignment.centerLeft,
                padding: const pw.EdgeInsets.all(4),
                child: pw.Text('4. Value on adopting GLR (Guideline Rate)',
                    style: boldTextStyle),
              ),
              pw.Container(),
              pw.Container(),
            ],
          ),
          // GLR i
          pw.TableRow(
            children: [
              pw.Container(
                alignment: pw.Alignment.topLeft,
                padding: const pw.EdgeInsets.all(4),
                child: pw.Text(
                    'i) Guideline rate as obtained from the Registrar\'s office (an evidence thereof to be enclosed)'),
              ),
              pw.Container(
                alignment: pw.Alignment.center,
                padding: const pw.EdgeInsets.symmetric(vertical: 4),
                child: pw.Text(':'),
              ),
              pw.Container(
                alignment: pw.Alignment.topLeft,
                padding: const pw.EdgeInsets.all(4),
                child: pw.Text(_glrRateController.text),
              ),
            ],
          ),
          // GLR ii
          pw.TableRow(
            children: [
              pw.Container(
                alignment: pw.Alignment.topLeft,
                padding: const pw.EdgeInsets.all(4),
                child: pw.Text(
                    'ii) Value of land by adopting GLR (2.20 X 13,20,000)'),
              ),
              pw.Container(
                alignment: pw.Alignment.center,
                padding: const pw.EdgeInsets.symmetric(vertical: 4),
                child: pw.Text(':'),
              ),
              pw.Container(
                alignment: pw.Alignment.topLeft,
                padding: const pw.EdgeInsets.all(4),
                child: pw.Text(_glrValueController.text),
              ),
            ],
          ),
          // PMR Header
          pw.TableRow(
            children: [
              pw.Container(
                alignment: pw.Alignment.centerLeft,
                padding: const pw.EdgeInsets.all(4),
                child: pw.Text(
                    '5. Value by adopting PMR (Prevailing Market Rate)',
                    style: boldTextStyle),
              ),
              pw.Container(),
              pw.Container(),
            ],
          ),
          // PMR i
          pw.TableRow(
            children: [
              pw.Container(
                alignment: pw.Alignment.topLeft,
                padding: const pw.EdgeInsets.all(4),
                child: pw.Text(
                    'i) Prevailing market rate (Along with details/reference of at least two latest deals/transactions with respect to adjacent properties in the areas)'),
              ),
              pw.Container(
                alignment: pw.Alignment.center,
                padding: const pw.EdgeInsets.symmetric(vertical: 4),
                child: pw.Text(':'),
              ),
              pw.Container(
                alignment: pw.Alignment.topLeft,
                padding: const pw.EdgeInsets.all(4),
                child: pw.Text(_pmrRateController.text),
              ),
            ],
          ),
          // PMR ii
          pw.TableRow(
            children: [
              pw.Container(
                alignment: pw.Alignment.topLeft,
                padding: const pw.EdgeInsets.all(4),
                child: pw.Text(
                    'ii) Unit rate adopted in this valuation after considering the characteristics of the subject plot'),
              ),
              pw.Container(
                alignment: pw.Alignment.center,
                padding: const pw.EdgeInsets.symmetric(vertical: 4),
                child: pw.Text(':'),
              ),
              pw.Container(
                alignment: pw.Alignment.topLeft,
                padding: const pw.EdgeInsets.all(4),
                child: pw.Text(_pmrAdoptedController.text),
              ),
            ],
          ),
          // PMR iii
          pw.TableRow(
            children: [
              pw.Container(
                alignment: pw.Alignment.topLeft,
                padding: const pw.EdgeInsets.all(4),
                child: pw.Text('iii) Value of land by adopting PMR'),
              ),
              pw.Container(
                alignment: pw.Alignment.center,
                padding: const pw.EdgeInsets.symmetric(vertical: 4),
                child: pw.Text(':'),
              ),
              pw.Container(
                alignment: pw.Alignment.topLeft,
                padding: const pw.EdgeInsets.all(4),
                child: pw.Text(_pmrValueController.text ?? ''),
              ),
            ],
          ),
        ],
      ),

      pw.SizedBox(height: 20),

      // Part C - Buildings
      pw.Text('PART C - BUILDINGS', style: pw.TextStyle(font: boldTtf)),
      pw.SizedBox(height: 8),

// Type of Building Row (top bar)
      // Building Characteristics Table (left: label, right: value)
      pw.Table(
        border: pw.TableBorder.all(),
        columnWidths: {
          0: const pw.FixedColumnWidth(220),
          1: const pw.FixedColumnWidth(290),
        },
        defaultVerticalAlignment: pw.TableCellVerticalAlignment.middle,
        children: [
          tableRow2C(
              'Type of Building',
              _buildingTypeController.text.isNotEmpty
                  ? _buildingTypeController.text
                  : 'Residential'),
          tableRow2C(
              'Type of construction',
              _constructionTypeController.text.isNotEmpty
                  ? _constructionTypeController.text
                  : 'Load bearing / RCC / Steel Framed'),
          tableRow2C(
              'Quality of construction',
              _constructionQualityController.text.isNotEmpty
                  ? _constructionQualityController.text
                  : 'Superior / Class I / Class II'),
          tableRow2C(
              'Appearance of Building',
              _appearanceController.text.isNotEmpty
                  ? _appearanceController.text
                  : 'Common/Attractive/Aesthetic'),
          tableRow2C('Maintenance/condition of the building', ''),
          tableRow2C(
              '  Exterior',
              _exteriorConditionController.text.isNotEmpty
                  ? _exteriorConditionController.text
                  : 'Excellent, Good, Normal, Average, Poor'),
          tableRow2C(
              '  Interior',
              _interiorConditionController.text.isNotEmpty
                  ? _interiorConditionController.text
                  : 'Excellent, Good, Normal, Average, Poor'),
          tableRow2C('Plinth Area', _plinthAreaController.text),
          tableRow2C(
              'Number of floors and height of each floor including basement, if any',
              _floorsController.text),
        ],
      ),

      pw.SizedBox(height: 8),

// Floor-wise Plinth Area Table
      pw.Table(
        border: pw.TableBorder.all(),
        columnWidths: {
          0: const pw.FixedColumnWidth(42), // Floor
          1: const pw.FixedColumnWidth(75), // Year
          2: const pw.FixedColumnWidth(55), // Roof
          3: const pw.FixedColumnWidth(81), // Main
          4: const pw.FixedColumnWidth(81), // Cantilevered
          5: const pw.FixedColumnWidth(81), // Total
        },
        defaultVerticalAlignment: pw.TableCellVerticalAlignment.middle,
        children: [
          pw.TableRow(
            decoration: const pw.BoxDecoration(color: PdfColors.grey300),
            children: [
              pw.Padding(
                  padding: const pw.EdgeInsets.all(4),
                  child: pw.Text('Floor', style: boldTextStyle)),
              pw.Padding(
                  padding: const pw.EdgeInsets.all(4),
                  child: pw.Text(
                      'Year of Construction\n(as reported / as per deed)',
                      style: boldTextStyle)),
              pw.Padding(
                  padding: const pw.EdgeInsets.all(4),
                  child: pw.Text('Roof', style: boldTextStyle)),
              pw.Padding(
                  padding: const pw.EdgeInsets.all(4),
                  child: pw.Text('Main Portion\nA', style: boldTextStyle)),
              pw.Padding(
                  padding: const pw.EdgeInsets.all(4),
                  child:
                      pw.Text('Cantilevered Portion\nB', style: boldTextStyle)),
              pw.Padding(
                  padding: const pw.EdgeInsets.all(4),
                  child: pw.Text('Total', style: boldTextStyle)),
            ],
          ),
          pw.TableRow(
            children: [
              pw.Padding(
                  padding: const pw.EdgeInsets.all(4), child: pw.Text('G.F')),
              pw.Padding(
                  padding: const pw.EdgeInsets.all(4),
                  child: pw.Text(_gfYearController.text)),
              pw.Padding(
                  padding: const pw.EdgeInsets.all(4),
                  child: pw.Text(_gfRoofController.text)),
              pw.Padding(
                  padding: const pw.EdgeInsets.all(4),
                  child: pw.Text(_gfAreaController.text)),
              pw.Padding(
                  padding: const pw.EdgeInsets.all(4),
                  child: pw.Text(_gfCantileverController.text)),
              pw.Padding(
                  padding: const pw.EdgeInsets.all(4),
                  child: pw.Text(_gfTotalController.text)),
            ],
          ),
          pw.TableRow(
            children: [
              pw.Padding(
                  padding: const pw.EdgeInsets.all(4), child: pw.Text('F.F')),
              pw.Padding(
                  padding: const pw.EdgeInsets.all(4),
                  child: pw.Text(_ffYearController.text)),
              pw.Padding(
                  padding: const pw.EdgeInsets.all(4),
                  child: pw.Text(_ffRoofController.text)),
              pw.Padding(
                  padding: const pw.EdgeInsets.all(4),
                  child: pw.Text(_ffAreaController.text)),
              pw.Padding(
                  padding: const pw.EdgeInsets.all(4),
                  child: pw.Text(_ffCantileverController.text)),
              pw.Padding(
                  padding: const pw.EdgeInsets.all(4),
                  child: pw.Text(_ffTotalController.text)),
            ],
          ),
          pw.TableRow(
            children: [
              pw.Padding(
                  padding: const pw.EdgeInsets.all(4),
                  child: pw.Text('Terrace')),
              pw.Padding(
                  padding: const pw.EdgeInsets.all(4),
                  child: pw.Text(_terraceYearController.text)),
              pw.Padding(
                  padding: const pw.EdgeInsets.all(4),
                  child: pw.Text(_terraceRoofController.text)),
              pw.Padding(
                  padding: const pw.EdgeInsets.all(4),
                  child: pw.Text(_terraceAreaController.text)),
              pw.Padding(
                  padding: const pw.EdgeInsets.all(4), child: pw.Text('')),
              pw.Padding(
                  padding: const pw.EdgeInsets.all(4),
                  child: pw.Text(_terraceTotalController.text)),
            ],
          ),
          pw.TableRow(
            children: [
              pw.Padding(
                  padding: const pw.EdgeInsets.all(4),
                  child: pw.Text('Total', style: boldTextStyle)),
              pw.Padding(
                  padding: const pw.EdgeInsets.all(4), child: pw.Text('')),
              pw.Padding(
                  padding: const pw.EdgeInsets.all(4), child: pw.Text('')),
              pw.Padding(
                  padding: const pw.EdgeInsets.all(4),
                  child:
                      pw.Text(_totalAreaController.text, style: boldTextStyle)),
              pw.Padding(
                  padding: const pw.EdgeInsets.all(4), child: pw.Text('')),
              pw.Padding(
                  padding: const pw.EdgeInsets.all(4),
                  child:
                      pw.Text(_totalAreaController.text, style: boldTextStyle)),
            ],
          ),
        ],
      ),

      pw.SizedBox(height: 8),

// Approved Plan Table
      pw.Table(
        border: pw.TableBorder.all(),
        columnWidths: {
          0: const pw.FixedColumnWidth(260),
          1: const pw.FixedColumnWidth(250),
        },
        defaultVerticalAlignment: pw.TableCellVerticalAlignment.middle,
        children: [
          tableRow2C(
              'Date of issue and validity of layout of approved map / plan',
              _approvedPlanNoController.text),
          tableRow2C('Approved map / plan issuing authority',
              _approvedPlanAuthorityController.text),
          tableRow2C(
              'Whether genuineness or authenticity of approved map / plan is verified',
              _planVerifiedController.text),
          tableRow2C(
              'Any other comments by our empanelled valuers on authentic of approved plan',
              ''),
        ],
      ),

      pw.SizedBox(height: 8),

// Value of building, depreciation note
      pw.Text(
          'Value of the building is adopted by adopting suitable unit plinth area rate depending up on the specifications. Depreciation is calculated by straight line method assuming salvage value of 10%.',
          style: pw.TextStyle(fontSize: 10, font: ttf)),

      pw.SizedBox(height: 8),

// Specification Table (GF/FF side by side)
      pw.Table(
        border: pw.TableBorder.all(),
        columnWidths: {
          0: const pw.FixedColumnWidth(110),
          1: const pw.FixedColumnWidth(170),
          2: const pw.FixedColumnWidth(170),
        },
        defaultVerticalAlignment: pw.TableCellVerticalAlignment.middle,
        children: [
          pw.TableRow(
            decoration: const pw.BoxDecoration(color: PdfColors.grey300),
            children: [
              pw.Padding(
                  padding: const pw.EdgeInsets.all(5),
                  child: pw.Text('Description', style: boldTextStyle)),
              pw.Padding(
                  padding: const pw.EdgeInsets.all(5),
                  child: pw.Text('Ground Floor', style: boldTextStyle)),
              pw.Padding(
                  padding: const pw.EdgeInsets.all(5),
                  child: pw.Text('First Floor', style: boldTextStyle)),
            ],
          ),
          tableRow3C('Specification', _gfSpecificationController.text,
              _ffSpecificationController.text),
          tableRow3C('Floor Finish', _gfFloorFinishController.text,
              _ffFloorFinishController.text),
          tableRow3C('Super Structure', _gfSuperStructureController.text,
              _ffSuperStructureController.text),
          tableRow3C(
              'Roof', _gfRoofTypeController.text, _ffRoofTypeController.text),
          tableRow3C('Doors', _gfDoorsController.text, _ffDoorsController.text),
          tableRow3C(
              'Windows', _gfWindowsController.text, _ffWindowsController.text),
          tableRow3C('Weathering Course', _gfWeatheringController.text,
              _ffWeatheringController.text),
          tableRow3C(
              'Year of Construction (Approx)',
              _gfConstructionYearController.text,
              _ffConstructionYearController.text),
          tableRow3C('Age of the building', _gfAgeController.text,
              _ffAgeController.text),
          tableRow3C('Expected further life', _gfRemainingLifeController.text,
              _ffRemainingLifeController.text),
          tableRow3C('Depreciation Percentage', _gfDepreciationController.text,
              _ffDepreciationController.text),
          tableRow3C(
              'Replacement rate of construction with the existing condition and specifications',
              _gfReplacementRateController.text,
              _ffReplacementRateController.text),
        ],
      ),

      pw.SizedBox(height: 8),

// Present Value Table
      pw.Table(
        border: pw.TableBorder.all(),
        columnWidths: {
          0: const pw.FixedColumnWidth(370),
          1: const pw.FixedColumnWidth(180),
        },
        defaultVerticalAlignment: pw.TableCellVerticalAlignment.middle,
        children: [
          pw.TableRow(
            children: [
              pw.Padding(
                padding: const pw.EdgeInsets.all(4),
                child: pw.Text('Present Value of the Land & Building',
                    style: boldTextStyle),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(4),
                child:
                    pw.Text(_presentValueController.text, style: boldTextStyle),
              ),
            ],
          ),
          pw.TableRow(
            children: [
              pw.Padding(
                padding: const pw.EdgeInsets.all(4),
                child: pw.Text('Total Value of the Land & building',
                    style: boldTextStyle),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(4),
                child:
                    pw.Text(_presentValueController.text, style: boldTextStyle),
              ),
            ],
          ),
        ],
      ),

      pw.SizedBox(height: 10),

// Details of valuation (bottom table from image 4)
      pw.Text('Details of valuation', style: boldTextStyle),

      pw.Table(
        border: pw.TableBorder.all(),
        columnWidths: {
          0: const pw.FixedColumnWidth(22),
          1: const pw.FixedColumnWidth(80),
          2: const pw.FixedColumnWidth(60),
          3: const pw.FixedColumnWidth(40),
          4: const pw.FixedColumnWidth(40),
          5: const pw.FixedColumnWidth(65),
          6: const pw.FixedColumnWidth(75),
          7: const pw.FixedColumnWidth(75),
          8: const pw.FixedColumnWidth(75),
        },
        defaultVerticalAlignment: pw.TableCellVerticalAlignment.middle,
        children: [
          pw.TableRow(
            decoration: const pw.BoxDecoration(color: PdfColors.grey300),
            children: [
              pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('Sr. no.', style: boldTextStyle, textAlign: pw.TextAlign.center)),
              pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('Particulars of Item', style: boldTextStyle)),
              pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('Plinth area (Sq.ft)', style: boldTextStyle)),
              pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('Roof height', style: boldTextStyle)),
              pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('Age', style: boldTextStyle)),
              pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('Rate Rs.', style: boldTextStyle)),
              pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('Repl. cost Rs.', style: boldTextStyle)),
              pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('Dep. Rs.', style: boldTextStyle)),
              pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('Net Value Rs.', style: boldTextStyle)),
            ],
          ),
          // G.F.
          pw.TableRow(
            children: [
              pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('1', textAlign: pw.TextAlign.center)),
              pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('G. F.')),
              pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text(_gfAreaController.text)),
              pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('3.0')),
              pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text(_gfAgeController.text)),
              pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text(_gfReplacementRateController.text)),
              pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text(gfReplCostVal > 0 ? gfReplCostVal.toStringAsFixed(2) : '')),
              pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text(gfDepValVal > 0 ? gfDepValVal.toStringAsFixed(2) : '')),
              pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text(gfNetVal > 0 ? gfNetVal.toStringAsFixed(2) : '')),
            ],
          ),
          // F.F.
          pw.TableRow(
            children: [
              pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('2', textAlign: pw.TextAlign.center)),
              pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('F. F.')),
              pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text(_ffAreaController.text)),
              pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('3.0')),
              pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text(_ffAgeController.text)),
              pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text(_ffReplacementRateController.text)),
              pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text(ffReplCostVal > 0 ? ffReplCostVal.toStringAsFixed(2) : '')),
              pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text(ffDepValVal > 0 ? ffDepValVal.toStringAsFixed(2) : '')),
              pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text(ffNetVal > 0 ? ffNetVal.toStringAsFixed(2) : '')),
            ],
          ),
          // Terrace
          pw.TableRow(
            children: [
              pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('3', textAlign: pw.TextAlign.center)),
              pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('Terrace')),
              pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text(_terraceAreaController.text)),
              pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('3.0')),
              pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text(_terraceYearController.text)),
              pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('')),
              pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text(terraceReplCostVal > 0 ? terraceReplCostVal.toStringAsFixed(2) : '')),
              pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('')),
              pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text(terraceNetVal > 0 ? terraceNetVal.toStringAsFixed(2) : '')),
            ],
          ),
          // Total
          pw.TableRow(
            decoration: const pw.BoxDecoration(color: PdfColors.grey200),
            children: [
              pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('')),
              pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('Total', style: boldTextStyle)),
              pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text(totalPlinthValPdf > 0 ? totalPlinthValPdf.toStringAsFixed(2) : '', style: boldTextStyle)),
              pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('')),
              pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('')),
              pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('')),
              pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text(totalReplCostValPdf > 0 ? totalReplCostValPdf.toStringAsFixed(2) : '', style: boldTextStyle)),
              pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text(totalDepValPdf > 0 ? totalDepValPdf.toStringAsFixed(2) : '', style: boldTextStyle)),
              pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text(totalNetValPdf > 0 ? totalNetValPdf.toStringAsFixed(2) : '', style: boldTextStyle)),
            ],
          ),
        ],
      ),

      pw.SizedBox(height: 20),

// Part D - Amenities & Extra Items
      pw.Text('PART D - AMENITIES & EXTRA ITEMS', style: boldTextStyle),
      pw.Text('(Value after Depreciation)'),
      pw.SizedBox(height: 10),

// Main amenities 1-20
      pw.Table(
        border: pw.TableBorder.all(color: PdfColors.black, width: 1),
        columnWidths: {
          0: const pw.FixedColumnWidth(25),
          1: const pw.FixedColumnWidth(215),
          2: const pw.FixedColumnWidth(15),
          3: const pw.FixedColumnWidth(245),
        },
        children: [
          pw.TableRow(
            children: [
              pw.Container(
                alignment: pw.Alignment.topLeft,
                padding:
                    const pw.EdgeInsets.symmetric(vertical: 2, horizontal: 2),
                child: pw.Text('1.', style: defaultTextStyle),
              ),
              pw.Container(
                alignment: pw.Alignment.topLeft,
                padding:
                    const pw.EdgeInsets.symmetric(vertical: 2, horizontal: 2),
                child: pw.Text('Portico', style: defaultTextStyle),
              ),
              pw.Container(
                alignment: pw.Alignment.center,
                child: pw.Text(':', style: defaultTextStyle),
              ),
              pw.Container(
                alignment: pw.Alignment.topLeft,
                child: pw.Text(_amenityPorticoController.text,
                    style: defaultTextStyle),
              ),
            ],
          ),
          pw.TableRow(
            children: [
              pw.Container(
                alignment: pw.Alignment.topLeft,
                padding:
                    const pw.EdgeInsets.symmetric(vertical: 2, horizontal: 2),
                child: pw.Text('2.', style: defaultTextStyle),
              ),
              pw.Container(
                alignment: pw.Alignment.topLeft,
                padding:
                    const pw.EdgeInsets.symmetric(vertical: 2, horizontal: 2),
                child: pw.Text('Ornamental Front / Pooja door',
                    style: defaultTextStyle),
              ),
              pw.Container(
                alignment: pw.Alignment.center,
                child: pw.Text(':', style: defaultTextStyle),
              ),
              pw.Container(
                alignment: pw.Alignment.topLeft,
                child: pw.Text(_amenityOrnamentalDoorController.text,
                    style: defaultTextStyle),
              ),
            ],
          ),
          pw.TableRow(
            children: [
              pw.Container(
                alignment: pw.Alignment.topLeft,
                padding:
                    const pw.EdgeInsets.symmetric(vertical: 2, horizontal: 2),
                child: pw.Text('3.', style: defaultTextStyle),
              ),
              pw.Container(
                alignment: pw.Alignment.topLeft,
                padding:
                    const pw.EdgeInsets.symmetric(vertical: 2, horizontal: 2),
                child: pw.Text('Sitout/Verandah with Steel grills',
                    style: defaultTextStyle),
              ),
              pw.Container(
                alignment: pw.Alignment.center,
                child: pw.Text(':', style: defaultTextStyle),
              ),
              pw.Container(
                alignment: pw.Alignment.topLeft,
                child: pw.Text(_amenitySitoutGrillsController.text,
                    style: defaultTextStyle),
              ),
            ],
          ),
          pw.TableRow(
            children: [
              pw.Container(
                alignment: pw.Alignment.topLeft,
                padding:
                    const pw.EdgeInsets.symmetric(vertical: 2, horizontal: 2),
                child: pw.Text('4.', style: defaultTextStyle),
              ),
              pw.Container(
                alignment: pw.Alignment.topLeft,
                padding:
                    const pw.EdgeInsets.symmetric(vertical: 2, horizontal: 2),
                child: pw.Text('Extra Steel/collapsible gates',
                    style: defaultTextStyle),
              ),
              pw.Container(
                alignment: pw.Alignment.center,
                child: pw.Text(':', style: defaultTextStyle),
              ),
              pw.Container(
                alignment: pw.Alignment.topLeft,
                child: pw.Text(_amenitySteelGatesController.text,
                    style: defaultTextStyle),
              ),
            ],
          ),
          pw.TableRow(
            children: [
              pw.Container(
                alignment: pw.Alignment.topLeft,
                padding:
                    const pw.EdgeInsets.symmetric(vertical: 2, horizontal: 2),
                child: pw.Text('5.', style: defaultTextStyle),
              ),
              pw.Container(
                alignment: pw.Alignment.topLeft,
                padding:
                    const pw.EdgeInsets.symmetric(vertical: 2, horizontal: 2),
                child: pw.Text('Open staircase', style: defaultTextStyle),
              ),
              pw.Container(
                alignment: pw.Alignment.center,
                child: pw.Text(':', style: defaultTextStyle),
              ),
              pw.Container(
                alignment: pw.Alignment.topLeft,
                child: pw.Text(_amenityOpenStaircaseController.text,
                    style: defaultTextStyle),
              ),
            ],
          ),
          pw.TableRow(
            children: [
              pw.Container(
                alignment: pw.Alignment.topLeft,
                padding:
                    const pw.EdgeInsets.symmetric(vertical: 2, horizontal: 2),
                child: pw.Text('6.', style: defaultTextStyle),
              ),
              pw.Container(
                alignment: pw.Alignment.topLeft,
                padding:
                    const pw.EdgeInsets.symmetric(vertical: 2, horizontal: 2),
                child: pw.Text('Wardrobes, showcases,\nwooden cupboards',
                    style: defaultTextStyle),
              ),
              pw.Container(
                alignment: pw.Alignment.center,
                child: pw.Text(':', style: defaultTextStyle),
              ),
              pw.Container(
                alignment: pw.Alignment.topLeft,
                child: pw.Text(_amenityWardrobesController.text,
                    style: defaultTextStyle),
              ),
            ],
          ),
          pw.TableRow(
            children: [
              pw.Container(
                alignment: pw.Alignment.topLeft,
                padding:
                    const pw.EdgeInsets.symmetric(vertical: 2, horizontal: 2),
                child: pw.Text('7.', style: defaultTextStyle),
              ),
              pw.Container(
                alignment: pw.Alignment.topLeft,
                padding:
                    const pw.EdgeInsets.symmetric(vertical: 2, horizontal: 2),
                child: pw.Text('Glazed tiles', style: defaultTextStyle),
              ),
              pw.Container(
                alignment: pw.Alignment.center,
                child: pw.Text(':', style: defaultTextStyle),
              ),
              pw.Container(
                alignment: pw.Alignment.topLeft,
                child: pw.Text(_amenityGlazedTilesController.text,
                    style: defaultTextStyle),
              ),
            ],
          ),
          pw.TableRow(
            children: [
              pw.Container(
                alignment: pw.Alignment.topLeft,
                padding:
                    const pw.EdgeInsets.symmetric(vertical: 2, horizontal: 2),
                child: pw.Text('8.', style: defaultTextStyle),
              ),
              pw.Container(
                alignment: pw.Alignment.topLeft,
                padding:
                    const pw.EdgeInsets.symmetric(vertical: 2, horizontal: 2),
                child: pw.Text('Extra sinks and bath tub',
                    style: defaultTextStyle),
              ),
              pw.Container(
                alignment: pw.Alignment.center,
                child: pw.Text(':', style: defaultTextStyle),
              ),
              pw.Container(
                alignment: pw.Alignment.topLeft,
                child: pw.Text(_amenityExtraSinksController.text,
                    style: defaultTextStyle),
              ),
            ],
          ),
          pw.TableRow(
            children: [
              pw.Container(
                alignment: pw.Alignment.topLeft,
                padding:
                    const pw.EdgeInsets.symmetric(vertical: 2, horizontal: 2),
                child: pw.Text('9.', style: defaultTextStyle),
              ),
              pw.Container(
                alignment: pw.Alignment.topLeft,
                padding:
                    const pw.EdgeInsets.symmetric(vertical: 2, horizontal: 2),
                child: pw.Text('Marble/ceramic tiles\nflooring',
                    style: defaultTextStyle),
              ),
              pw.Container(
                alignment: pw.Alignment.center,
                child: pw.Text(':', style: defaultTextStyle),
              ),
              pw.Container(
                alignment: pw.Alignment.topLeft,
                child: pw.Text(_amenityMarbleTilesController.text,
                    style: defaultTextStyle),
              ),
            ],
          ),
          pw.TableRow(
            children: [
              pw.Container(
                alignment: pw.Alignment.topLeft,
                padding:
                    const pw.EdgeInsets.symmetric(vertical: 2, horizontal: 2),
                child: pw.Text('10.', style: defaultTextStyle),
              ),
              pw.Container(
                alignment: pw.Alignment.topLeft,
                padding:
                    const pw.EdgeInsets.symmetric(vertical: 2, horizontal: 2),
                child: pw.Text('Interior decorations', style: defaultTextStyle),
              ),
              pw.Container(
                alignment: pw.Alignment.center,
                child: pw.Text(':', style: defaultTextStyle),
              ),
              pw.Container(
                alignment: pw.Alignment.topLeft,
                child: pw.Text(_amenityInteriorDecorController.text,
                    style: defaultTextStyle),
              ),
            ],
          ),
          pw.TableRow(
            children: [
              pw.Container(
                alignment: pw.Alignment.topLeft,
                padding:
                    const pw.EdgeInsets.symmetric(vertical: 2, horizontal: 2),
                child: pw.Text('11.', style: defaultTextStyle),
              ),
              pw.Container(
                alignment: pw.Alignment.topLeft,
                padding:
                    const pw.EdgeInsets.symmetric(vertical: 2, horizontal: 2),
                child: pw.Text('Architectural Elevation\nworks',
                    style: defaultTextStyle),
              ),
              pw.Container(
                alignment: pw.Alignment.center,
                child: pw.Text(':', style: defaultTextStyle),
              ),
              pw.Container(
                alignment: pw.Alignment.topLeft,
                child: pw.Text(_amenityElevationWorksController.text,
                    style: defaultTextStyle),
              ),
            ],
          ),
          pw.TableRow(
            children: [
              pw.Container(
                alignment: pw.Alignment.topLeft,
                padding:
                    const pw.EdgeInsets.symmetric(vertical: 2, horizontal: 2),
                child: pw.Text('12.', style: defaultTextStyle),
              ),
              pw.Container(
                alignment: pw.Alignment.topLeft,
                padding:
                    const pw.EdgeInsets.symmetric(vertical: 2, horizontal: 2),
                child: pw.Text('False ceiling works', style: defaultTextStyle),
              ),
              pw.Container(
                alignment: pw.Alignment.center,
                child: pw.Text(':', style: defaultTextStyle),
              ),
              pw.Container(
                alignment: pw.Alignment.topLeft,
                child: pw.Text(_amenityFalseCeilingController.text,
                    style: defaultTextStyle),
              ),
            ],
          ),
          pw.TableRow(
            children: [
              pw.Container(
                alignment: pw.Alignment.topLeft,
                padding:
                    const pw.EdgeInsets.symmetric(vertical: 2, horizontal: 2),
                child: pw.Text('13.', style: defaultTextStyle),
              ),
              pw.Container(
                alignment: pw.Alignment.topLeft,
                padding:
                    const pw.EdgeInsets.symmetric(vertical: 2, horizontal: 2),
                child: pw.Text('Paneling works', style: defaultTextStyle),
              ),
              pw.Container(
                alignment: pw.Alignment.center,
                child: pw.Text(':', style: defaultTextStyle),
              ),
              pw.Container(
                alignment: pw.Alignment.topLeft,
                child: pw.Text(_amenityPanelingWorksController.text,
                    style: defaultTextStyle),
              ),
            ],
          ),
          pw.TableRow(
            children: [
              pw.Container(
                alignment: pw.Alignment.topLeft,
                padding:
                    const pw.EdgeInsets.symmetric(vertical: 2, horizontal: 2),
                child: pw.Text('14.', style: defaultTextStyle),
              ),
              pw.Container(
                alignment: pw.Alignment.topLeft,
                padding:
                    const pw.EdgeInsets.symmetric(vertical: 2, horizontal: 2),
                child: pw.Text('Aluminum works', style: defaultTextStyle),
              ),
              pw.Container(
                alignment: pw.Alignment.center,
                child: pw.Text(':', style: defaultTextStyle),
              ),
              pw.Container(
                alignment: pw.Alignment.topLeft,
                child: pw.Text(_amenityAluminumWorksController.text,
                    style: defaultTextStyle),
              ),
            ],
          ),
          pw.TableRow(
            children: [
              pw.Container(
                alignment: pw.Alignment.topLeft,
                padding:
                    const pw.EdgeInsets.symmetric(vertical: 2, horizontal: 2),
                child: pw.Text('15.', style: defaultTextStyle),
              ),
              pw.Container(
                alignment: pw.Alignment.topLeft,
                padding:
                    const pw.EdgeInsets.symmetric(vertical: 2, horizontal: 2),
                child: pw.Text('Aluminum handrails', style: defaultTextStyle),
              ),
              pw.Container(
                alignment: pw.Alignment.center,
                child: pw.Text(':', style: defaultTextStyle),
              ),
              pw.Container(
                alignment: pw.Alignment.topLeft,
                child: pw.Text(_amenityAluminumHandrailsController.text,
                    style: defaultTextStyle),
              ),
            ],
          ),
          pw.TableRow(
            children: [
              pw.Container(
                alignment: pw.Alignment.topLeft,
                padding:
                    const pw.EdgeInsets.symmetric(vertical: 2, horizontal: 2),
                child: pw.Text('16.', style: defaultTextStyle),
              ),
              pw.Container(
                alignment: pw.Alignment.topLeft,
                padding:
                    const pw.EdgeInsets.symmetric(vertical: 2, horizontal: 2),
                child: pw.Text('Separate Lumber Room', style: defaultTextStyle),
              ),
              pw.Container(
                alignment: pw.Alignment.center,
                child: pw.Text(':', style: defaultTextStyle),
              ),
              pw.Container(
                alignment: pw.Alignment.topLeft,
                child: pw.Text(_amenityLumberRoomController.text,
                    style: defaultTextStyle),
              ),
            ],
          ),
          pw.TableRow(
            children: [
              pw.Container(
                alignment: pw.Alignment.topLeft,
                padding:
                    const pw.EdgeInsets.symmetric(vertical: 2, horizontal: 2),
                child: pw.Text('17.', style: defaultTextStyle),
              ),
              pw.Container(
                alignment: pw.Alignment.topLeft,
                padding:
                    const pw.EdgeInsets.symmetric(vertical: 2, horizontal: 2),
                child: pw.Text('Separate Toilet Room', style: defaultTextStyle),
              ),
              pw.Container(
                alignment: pw.Alignment.center,
                child: pw.Text(':', style: defaultTextStyle),
              ),
              pw.Container(
                alignment: pw.Alignment.topLeft,
                child: pw.Text(_amenityToiletRoomController.text,
                    style: defaultTextStyle),
              ),
            ],
          ),
          pw.TableRow(
            children: [
              pw.Container(
                alignment: pw.Alignment.topLeft,
                padding:
                    const pw.EdgeInsets.symmetric(vertical: 2, horizontal: 2),
                child: pw.Text('18.', style: defaultTextStyle),
              ),
              pw.Container(
                alignment: pw.Alignment.topLeft,
                padding:
                    const pw.EdgeInsets.symmetric(vertical: 2, horizontal: 2),
                child: pw.Text('Separate water tank/sump',
                    style: defaultTextStyle),
              ),
              pw.Container(
                alignment: pw.Alignment.center,
                child: pw.Text(':', style: defaultTextStyle),
              ),
              pw.Container(
                alignment: pw.Alignment.topLeft,
                child: pw.Text(_amenityWaterTankSumpController.text,
                    style: defaultTextStyle),
              ),
            ],
          ),
          pw.TableRow(
            children: [
              pw.Container(
                alignment: pw.Alignment.topLeft,
                padding:
                    const pw.EdgeInsets.symmetric(vertical: 2, horizontal: 2),
                child: pw.Text('19.', style: defaultTextStyle),
              ),
              pw.Container(
                alignment: pw.Alignment.topLeft,
                padding:
                    const pw.EdgeInsets.symmetric(vertical: 2, horizontal: 2),
                child: pw.Text('Trees, gardening', style: defaultTextStyle),
              ),
              pw.Container(
                alignment: pw.Alignment.center,
                child: pw.Text(':', style: defaultTextStyle),
              ),
              pw.Container(
                alignment: pw.Alignment.topLeft,
                child: pw.Text(_amenityGardeningController.text,
                    style: defaultTextStyle),
              ),
            ],
          ),
          pw.TableRow(
            children: [
              pw.Container(
                alignment: pw.Alignment.topLeft,
                padding:
                    const pw.EdgeInsets.symmetric(vertical: 2, horizontal: 2),
                child: pw.Text('20.', style: defaultTextStyle),
              ),
              pw.Container(
                alignment: pw.Alignment.topLeft,
                padding:
                    const pw.EdgeInsets.symmetric(vertical: 2, horizontal: 2),
                child: pw.Text('Any other', style: defaultTextStyle),
              ),
              pw.Container(
                alignment: pw.Alignment.center,
                child: pw.Text(':', style: defaultTextStyle),
              ),
              pw.Container(
                alignment: pw.Alignment.topLeft,
                child: pw.Text(_amenityAnyOtherController.text,
                    style: defaultTextStyle),
              ),
            ],
          ),
        ],
      ),
      pw.SizedBox(height: 10),

// Water supply arrangements
      pw.Text('Water supply arrangements', style: boldTextStyle),
      pw.TableHelper.fromTextArray(
        data: <List<String>>[
          ['Open Well', _amenityOpenWellController.text],
          ['Deep bore', _amenityDeepBoreController.text],
          ['Hand pump', _amenityHandPumpController.text],
          ['Corporation Tap', _amenityCorporationTapController.text],
          ['Underground level sump', _amenityUndergroundSumpController.text],
          ['Overhead water tank', _amenityOverheadWaterTankController.text],
        ],
        cellAlignment: pw.Alignment.topLeft,
        cellStyle: defaultTextStyle,
        columnWidths: {
          0: const pw.FixedColumnWidth(200),
          1: const pw.FixedColumnWidth(300),
        },
      ),
      pw.SizedBox(height: 10),

// Drainage arrangements
      pw.Text('Drainage arrangements', style: boldTextStyle),
      pw.TableHelper.fromTextArray(
        data: <List<String>>[
          ['Septic Tank', _amenitySepticTankController.text],
          ['Underground sewerage', _amenityUndergroundSewerageController.text],
        ],
        cellAlignment: pw.Alignment.topLeft,
        cellStyle: defaultTextStyle,
        columnWidths: {
          0: const pw.FixedColumnWidth(200),
          1: const pw.FixedColumnWidth(300),
        },
      ),
      pw.SizedBox(height: 10),

// Compound Wall, Pavements, Steel Gate
      pw.Text('Compound Wall, Pavements, Steel Gate', style: boldTextStyle),
      pw.TableHelper.fromTextArray(
        data: <List<String>>[
          [
            'Compound Wall (Rm. @ Rs. .../m²)',
            _amenityCompoundWallController.text
          ],
          ['Compound Wall Height', _amenityCompoundWallHeightController.text],
          ['Compound Wall Length', _amenityCompoundWallLengthController.text],
          ['Type of construction', _amenityCompoundWallTypeController.text],
          [
            'Pavements ...... Rm. @ Rs. .../m²',
            _amenityPavementsController.text
          ],
          [
            'Steel gate ...... Rm. @ Rs. .../m²',
            _amenitySteelGateRmController.text
          ],
        ],
        cellAlignment: pw.Alignment.topLeft,
        cellStyle: defaultTextStyle,
        columnWidths: {
          0: const pw.FixedColumnWidth(200),
          1: const pw.FixedColumnWidth(300),
        },
      ),
      pw.SizedBox(height: 10),

// Deposits
      pw.Text('Deposits', style: boldTextStyle),
      pw.TableHelper.fromTextArray(
        data: <List<String>>[
          ['E.B Deposits', _amenityEBDepositsController.text],
          ['Water deposits', _amenityWaterDepositsController.text],
          ['Drainage deposits', _amenityDrainageDepositsController.text],
        ],
        cellAlignment: pw.Alignment.topLeft,
        cellStyle: defaultTextStyle,
        columnWidths: {
          0: const pw.FixedColumnWidth(200),
          1: const pw.FixedColumnWidth(300),
        },
      ),
      pw.SizedBox(height: 10),

// Electrical fittings & others
      pw.Text('Electrical fittings & others', style: boldTextStyle),
      pw.TableHelper.fromTextArray(
        data: <List<String>>[
          ['Type of wiring', _amenityWiringTypeController.text],
          [
            'Class of fittings (superior/Ordinary/Poor)',
            _amenityFittingsClassController.text
          ],
          ['Number of light Points', _amenityLightPointsController.text],
          ['Fan Points', _amenityFanPointsController.text],
          ['Spare Plug Points', _amenityPlugPointsController.text],
          ['Any other item', _amenityElectricalOtherController.text],
        ],
        cellAlignment: pw.Alignment.topLeft,
        cellStyle: defaultTextStyle,
        columnWidths: {
          0: const pw.FixedColumnWidth(200),
          1: const pw.FixedColumnWidth(300),
        },
      ),
      pw.SizedBox(height: 10),

// Plumbing installation
      pw.Text('Plumbing installation', style: boldTextStyle),
      pw.TableHelper.fromTextArray(
        data: <List<String>>[
          ['No. of water closets', _amenityNoOfClosetsController.text],
          ['Closets Type', _amenityClosetsTypeController.text],
          ['No. of wash basins', _amenityNoOfWashBasinsController.text],
          ['No. of bath tubs', _amenityNoOfBathTubsController.text],
          ['Water meter, taps etc', _amenityWaterMeterTapsController.text],
          [
            'Any other fixtures - Terrace Roof',
            _amenityPlumbingOtherFixturesController.text
          ],
        ],
        cellAlignment: pw.Alignment.topLeft,
        cellStyle: defaultTextStyle,
        columnWidths: {
          0: const pw.FixedColumnWidth(200),
          1: const pw.FixedColumnWidth(300),
        },
      ),
      pw.SizedBox(height: 10),

// Any other & Total
      pw.TableHelper.fromTextArray(
        data: <List<String>>[
          ['Any other', _amenityAnyOtherItemController.text],
          ['Total', _amenityTotalController.text],
        ],
        cellAlignment: pw.Alignment.topLeft,
        cellStyle: defaultTextStyle,
        columnWidths: {
          0: const pw.FixedColumnWidth(200),
          1: const pw.FixedColumnWidth(300),
        },
      ),
// Insert this after PART D in your PDF generation code

      pw.SizedBox(height: 10),
      pw.Text('Total abstract of the entire property', style: boldTextStyle),
      pw.Table(
        border: pw.TableBorder.all(),
        columnWidths: {
          0: const pw.FlexColumnWidth(2.5),
          1: const pw.FlexColumnWidth(0.7),
          2: const pw.FlexColumnWidth(2.2),
          3: const pw.FlexColumnWidth(2.2),
        },
        defaultVerticalAlignment: pw.TableCellVerticalAlignment.middle,
        children: [
          pw.TableRow(
            children: [
              pw.Padding(
                padding: const pw.EdgeInsets.all(6),
                child: pw.Text("Description", style: boldTextStyle),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(6),
                child: pw.Text(":", style: boldTextStyle),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(6),
                child: pw.Text("Value adopting\nGLR",
                    textAlign: pw.TextAlign.center, style: boldTextStyle),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(6),
                child: pw.Text("PMR",
                    textAlign: pw.TextAlign.center, style: boldTextStyle),
              ),
            ],
          ),
          pw.TableRow(
            children: [
              pw.Padding(
                padding: const pw.EdgeInsets.all(6),
                child: pw.Text("Part- B   Land"),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(6),
                child: pw.Text(":"),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(4),
                child: pw.Text(absLandGlrController.text),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(4),
                child: pw.Text(absLandPmrController.text),
              ),
            ],
          ),
          pw.TableRow(
            children: [
              pw.Padding(
                padding: const pw.EdgeInsets.all(6),
                child: pw.Text("Part- C   Building"),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(6),
                child: pw.Text(":"),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(4),
                child: pw.Text(absBuildingGlrController.text),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(4),
                child: pw.Text(absBuildingPmrController.text),
              ),
            ],
          ),
          pw.TableRow(
            children: [
              pw.Padding(
                padding: const pw.EdgeInsets.all(6),
                child: pw.Text("Part- D   Extra Items"),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(6),
                child: pw.Text(":"),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(4),
                child: pw.Text(absExtraGlrController.text),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(4),
                child: pw.Text(absExtraPmrController.text),
              ),
            ],
          ),
          pw.TableRow(
            children: [
              pw.Padding(
                padding: const pw.EdgeInsets.all(6),
                child: pw.Text("Part- E   Amenities"),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(6),
                child: pw.Text(":"),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(4),
                child: pw.Text(absAmenitiesGlrController.text),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(4),
                child: pw.Text(absAmenitiesPmrController.text),
              ),
            ],
          ),
          pw.TableRow(
            children: [
              pw.Padding(
                padding: const pw.EdgeInsets.all(6),
                child: pw.Text("Total", style: boldTextStyle),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(6),
                child: pw.Text(":", style: boldTextStyle),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(4),
                child: pw.Text(absTotalGlrController.text),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(4),
                child: pw.Text(absTotalPmrController.text),
              ),
            ],
          ),
          pw.TableRow(
            children: [
              pw.Padding(
                padding: const pw.EdgeInsets.all(6),
                child: pw.Text("Say", style: boldTextStyle),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(6),
                child: pw.Text(":", style: boldTextStyle),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(4),
                child: pw.Text(absSayGlrController.text),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(4),
                child: pw.Text(absSayPmrController.text),
              ),
            ],
          ),
        ],
      ),
      pw.SizedBox(height: 20),
      pw.SizedBox(height: 20),

      // Valuation conclusion
      pw.Paragraph(
          text:
              'As a result of my appraisal and analysis, it is my considered opinion that the present fair market value of the above property in the prevailing condition with aforesaid specifications is Rs. 2,30,00,000 (Rupees Two Crores & Thirty Lakhs Only). The realisable value of the above property as on 30.07.2024 is Rs. 2,07,00,000 (Rupees Two Crores & Seven Lakhs Only) and the distress value Rs. 1,84,00,000 (Rupees One Crore & Eighty-Four Lakhs Only). The book value of the above property as on 30.07.2024 is Rs. 88,66,270 (Rupees Eighty-Eight Lakhs Sixty-Six Thousand Two Hundred & Seventy Only)',
          style: defaultTextStyle),
      pw.SizedBox(height: 20),

      // Valuer signature
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.end,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text('Place: Thiruvananthapuram'),
              pw.Text('Date: 01.08.2024'),
              pw.SizedBox(height: 40),
              pw.Text('Signature'),
              pw.Text('(Name and Official seal of the Approved Valuer)'),
            ],
          ),
        ],
      ),
      pw.SizedBox(height: 20),

      // End notes
      pw.Text('End:'),
      pw.Text('1. Declaration from the valuer in Format E'),
      pw.Text('2. Model code of conduct for valuer'),

      if (_imagesWithLocation.isNotEmpty) ...[
        pw.NewPage(),
        pw.Text('Property Images with Location:', style: boldTextStyle),
        pw.SizedBox(height: 10),
        pw.Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _imagesWithLocation.map((imageData) {
            return pw.Container(
                width: 250,
                decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey)),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Image(pw.MemoryImage(imageData.imageBytes),
                        height: 150, width: 250, fit: pw.BoxFit.cover),
                    pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text('Location: ${imageData.locationString}',
                                  style: const pw.TextStyle(fontSize: 8)),
                              pw.Text(
                                  'Date: ${DateFormat('yyyy-MM-dd HH:mm').format(imageData.timestamp)}',
                                  style: const pw.TextStyle(fontSize: 8)),
                              if (imageData.description != null &&
                                  imageData.description!.isNotEmpty)
                                pw.Text('Desc: ${imageData.description}',
                                    style: const pw.TextStyle(fontSize: 8)),
                            ]))
                  ],
                ));
          }).toList(),
        ),
      ],
    ];
    // Add this to your PDF widgets list

    pdf.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          pageFormat: PdfPageFormat.a4,
          textDirection: pw.TextDirection.ltr,
          theme: pw.ThemeData.withFont(
            base: ttf,
            bold: boldTtf,
          ),
          margin: const pw.EdgeInsets.all(30),
        ),
        build: (pw.Context context) => widgets,
      ),
    );

    return pdf;
  }

  Widget _buildSection(
      {required String title,
      required List<Widget> children,
      bool initiallyExpanded = false}) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ExpansionTile(
        title: Text(title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        initiallyExpanded: initiallyExpanded,
        childrenPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: children
            .map((child) => Padding(
                padding: const EdgeInsets.only(bottom: 12), child: child))
            .toList(),
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false, // Optional: hides the "DEBUG" banner
    home: PropertyValuationReportPage(
      propertyData: {},
    ),
  ));
}
