// lib/valuation_form_screen.dart
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:login_screen/screens/LIC/pvr3/savedDraftsPVR3.dart';
import 'package:login_screen/screens/nearbyDetails.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'valuation_data_model.dart';
import 'pdf_generator.dart';
import 'package:http/http.dart' as http;
import 'config.dart';

class ValuationFormScreen extends StatefulWidget {
  final Map<String, dynamic>? propertyData;

  const ValuationFormScreen({super.key, this.propertyData});
  @override
  _ValuationFormScreenState createState() => _ValuationFormScreenState();
}

class _ValuationFormScreenState extends State<ValuationFormScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.propertyData != null) {
      // Use the passed data to initialize your form only if it exists
      debugPrint('Received property data: ${widget.propertyData}');
      // Example:
      // _fileNoController.text = widget.propertyData!['fileNo'].toString();
    } else {
      debugPrint('No property data received - creating new valuation');
      // Initialize with empty/default values
    }
    _initializeFormWithPropertyData();
  }

  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();

  // --- STATE FOR DYNAMIC UI ---
  PropertyType _selectedPropertyType = PropertyType.House;
  final List<FloorData> _floors = [
    FloorData(
        name: 'GF', area: '676', marketRate: '1500', guidelineRate: '1500'),
    FloorData(
        name: 'FF', area: '716', marketRate: '1500', guidelineRate: '1500'),
  ];
  final List<ValuationImage> _valuationImages = [];
  // ADDED: State for the dynamic "Progress of Work" table
  final List<ProgressWorkItem> _progressWorkItems = [
    ProgressWorkItem(
        description:
            'FLOORING PAINTING SHEET ROOFING SANITARY FITTINGS ELECTRICAL WORKS ALL WORKS COMPLETED AS PER ESTIMATE',
        applicantEstimate: '2000000',
        valuerOpinion: '')
  ];

  // --- ALL CONTROLLERS ---
  final _nearbyLatitude = TextEditingController();
  final _nearbyLongitude = TextEditingController();
  final _fileNoCtrl = TextEditingController(text: '5002050002910');
  final _valuerNameCtrl = TextEditingController(text: 'VIGNESH S');
  final _valuerCodeCtrl = TextEditingController(text: 'TVV0001');
  final _appointingAuthorityCtrl =
      TextEditingController(text: 'LICHFL THIRUVANANTHAPURAM');
  DateTime _inspectionDate = DateTime(2025, 6, 5);
  final _reraNoCtrl = TextEditingController(text: 'NA');
  final _schemeCtrl =
      TextEditingController(text: 'Purchase/ Renovation /Griha Vikas');
  final _applicantNameCtrl =
      TextEditingController(text: 'NARAYANAN GANESH KUMAR');
  final _documentPerusedCtrl = TextEditingController(text: 'Minor');
  final _addressCtrl = TextEditingController(
      text: '118 ARES RS NO 2100 A 1 DOOR NO 79 2290 MUTTATHARA VILLAGE...');
  bool _locationSketchVerified = true;
  final _northBoundaryCtrl =
      TextEditingController(text: 'PRIVATE ROAD HAVING CAR ACCESS');
  final _northDimCtrl = TextEditingController(text: '1000 CM');
  final _southBoundaryCtrl =
      TextEditingController(text: 'PROPERTY OF KRISHNAMMA');
  final _southDimCtrl = TextEditingController(text: '1000 CM');
  final _eastBoundaryCtrl =
      TextEditingController(text: 'PROPERTY OF MOHANASUNDARAM');
  final _eastDimCtrl = TextEditingController(text: '1581 CM');
  final _westBoundaryCtrl = TextEditingController(text: 'PROPERTY OF RADHIKA');
  final _westDimCtrl = TextEditingController(text: '891 CM');
  final _extent1Ctrl = TextEditingController(text: '1.18');
  final _extent2Ctrl = TextEditingController(text: '2.91');
  final _propertyTypeCtrl = TextEditingController(text: 'Bunglow');
  OccupantStatus _occupantStatus = OccupantStatus.Occupied;
  final _occupantNameCtrl = TextEditingController(text: 'RENTED');
  final _usageOfBuildingCtrl = TextEditingController(text: 'RESIDENTIAL');
  final _nearbyLandmarkCtrl = TextEditingController(
      text: 'SREEVARAHAM MARKET JUNCTION AND MANSIONS SREENIDHI');
  final _surroundingAreaDevCtrl = TextEditingController(text: 'Middle Class');
  bool _basicAmenitiesAvailable = true;
  final _negativesToLocalityCtrl = TextEditingController(text: 'NIL');
  final _favourableConsiderationsCtrl = TextEditingController(text: 'NIL');
  final _otherFeaturesCtrl = TextEditingController(text: 'NIL');
  bool _approvedDrawingAvailable = true;
  final _approvalNoAndDateCtrl =
      TextEditingController(text: 'FE2/TSL/28/11 25-04-11');
  bool _constructionAsPerPlan = true;
  final _drawingDeviationsCtrl = TextEditingController(text: 'NIL');
  DeviationNature _deviationNature = DeviationNature.Minor;
  final _marketabilityCtrl = TextEditingController(text: 'Good');
  final _buildingAgeCtrl = TextEditingController(text: '13');
  final _residualLifeCtrl = TextEditingController(text: '37');
  final _fsiApprovedCtrl = TextEditingController(text: '1.1');
  final _fsiActualCtrl = TextEditingController(text: '1.1');
  final _specFoundationCtrl = TextEditingController(text: 'RR MASONRY');
  final _specRoofCtrl = TextEditingController(text: 'RCC');
  final _specFlooringCtrl = TextEditingController(text: 'VITRIFIED TILES');
  final _qualityOfConstructionCtrl = TextEditingController(text: 'GOOD');
  bool _adheresToSafetySpecs = true;
  bool _highTensionLineImpact = false;
  final _landAreaCtrl = TextEditingController(text: '2.91');
  final _landUnitRateCtrl = TextEditingController(text: '1200000');
  final _landGuidelineRateCtrl = TextEditingController(text: '1141140');
  final _amenitiesAreaCtrl = TextEditingController(text: '0');
  final _amenitiesUnitRateCtrl = TextEditingController(text: '0');
  final _amenitiesGuidelineRateCtrl = TextEditingController(text: '0');
  final _marketValueSourceHouseCtrl =
      TextEditingController(text: 'LOCAL MARKET ENQUIRY');
  final _flatUndividedShareCtrl = TextEditingController(text: 'NA');
  final _flatBuiltUpAreaCtrl = TextEditingController(text: '0');
  final _flatCompositeRateCtrl = TextEditingController(text: '0');
  final _flatValueUnitRateCtrl = TextEditingController(text: '0');
  final _flatValueMarketCtrl = TextEditingController(text: '0');
  final _flatValueGuidelineRateCtrl = TextEditingController(text: '0');
  final _flatValueGuidelineCtrl = TextEditingController(text: '0');
  final _marketValueSourceFlatCtrl = TextEditingController(text: 'NA');
  final _flatExtraAmenitiesCtrl = TextEditingController(text: '0');
  final _improvementDescriptionCtrl =
      TextEditingController(text: 'FLOORING PAINTING SHEET ROOFING...');
  final _improvementAmountCtrl = TextEditingController(text: '2000000');
  bool _improvementEstimateReasonable = true;
  final _improvementReasonableEstimateCtrl =
      TextEditingController(); // ADDED for section 5.4
  // REMOVED: final _improvementCompletedValueCtrl = TextEditingController(text: '2000000');
  final _remarksBackgroundCtrl =
      TextEditingController(text: 'SUBMITTED DOCUMENTS');
  final _remarksSourcesCtrl =
      TextEditingController(text: 'LOCAL MARKET ENQUIRY');
  final _remarksProceduresCtrl = TextEditingController(text: 'MARKET APPROACH');
  final _remarksMethodologyCtrl =
      TextEditingController(text: 'COMPARISON METHOD');
  final _remarksFactorsCtrl =
      TextEditingController(text: 'AMENITIES AND ACCESSIBILITY');

  bool _isNotValidState = false;

  //save data function

  Future<void> _saveToNearbyCollection() async {
    try {
      // --- STEP 1: Find the first image with valid coordinates ---
      ValuationImage? firstImageWithLocation;
      try {
        // Use .firstWhere to find the first image that satisfies the condition.
        firstImageWithLocation = _valuationImages.firstWhere(
          (img) => img.latitude.isNotEmpty && img.longitude.isNotEmpty,
        );
      } catch (e) {
        // .firstWhere throws an error if no element is found. We catch it here.
        firstImageWithLocation = null;
      }

      // --- STEP 2: Handle the case where no image has location data ---
      if (firstImageWithLocation == null) {
        debugPrint(
            'No image with location data found. Skipping save to nearby collection.');
        return; // Exit the function early.
      }

      final ownerName = _applicantNameCtrl.text ?? '[is null]';
      final marketValue = _marketValueSourceHouseCtrl.text ?? '[is null]';

      debugPrint('------------------------------------------');
      debugPrint('DEBUGGING SAVE TO NEARBY COLLECTION:');
      debugPrint('Owner Name from Controller: "$ownerName"');
      debugPrint('Market Value from Controller: "$marketValue"');
      debugPrint('------------------------------------------');
      // --- STEP 3: Build the payload with the correct data ---
      final dataToSave = {
        // Use the coordinates from the image we found
        'refNo': _fileNoCtrl.text ?? '',
        'latitude': firstImageWithLocation.latitude,
        'longitude': firstImageWithLocation.longitude,

        'landValue': marketValue, // Use the variable we just created
        'nameOfOwner': ownerName,
        'bankName': 'LIC (PVR - 3)',
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
        debugPrint('Response body: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error in _saveToNearbyCollection: $e');
    }
  }

  Future<void> _saveData() async {
    try {
      // Validate required fields
      if (_valuerNameCtrl.text.isEmpty ||
          _valuerCodeCtrl.text.isEmpty ||
          _fileNoCtrl.text.isEmpty ||
          _applicantNameCtrl.text.isEmpty ||
          _addressCtrl.text.isEmpty ||
          _appointingAuthorityCtrl.text.isEmpty) {
        debugPrint("not all required fields available");
        setState(() => _isNotValidState = true);
        return;
      }

      if (_valuationImages.isEmpty) {
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

      final formattedDate = DateFormat('yyyy-MM-dd').format(_inspectionDate);

      var request = http.MultipartRequest('POST', Uri.parse(url1));

      // Add text fields
      request.fields.addAll({
        // Basic Information
        "fileNo": _fileNoCtrl.text,
        "valuerName": _valuerNameCtrl.text,
        "valuerCode": _valuerCodeCtrl.text,
        "appointingAuthority": _appointingAuthorityCtrl.text,
        "inspectionDate": formattedDate.toString(),
        "reraNo": _reraNoCtrl.text,
        "scheme": _schemeCtrl.text,
        "applicantName": _applicantNameCtrl.text,
        "documentPerused": _documentPerusedCtrl.text,
        "address": _addressCtrl.text,

        // Location Details
        "locationSketchVerified": _locationSketchVerified.toString(),
        "northBoundary": _northBoundaryCtrl.text,
        "northDim": _northDimCtrl.text,
        "southBoundary": _southBoundaryCtrl.text,
        "southDim": _southDimCtrl.text,
        "eastBoundary": _eastBoundaryCtrl.text,
        "eastDim": _eastDimCtrl.text,
        "westBoundary": _westBoundaryCtrl.text,
        "westDim": _westDimCtrl.text,
        "extent1": _extent1Ctrl.text,
        "extent2": _extent2Ctrl.text,

        // Property Details
        "propertyType": _propertyTypeCtrl.text,
        "occupantStatus": _occupantStatus.toString().split('.').last,
        "occupantName": _occupantNameCtrl.text,
        "usageOfBuilding": _usageOfBuildingCtrl.text,
        "nearbyLandmark": _nearbyLandmarkCtrl.text,
        "surroundingAreaDev": _surroundingAreaDevCtrl.text,
        "basicAmenitiesAvailable": _basicAmenitiesAvailable.toString(),
        "negativesToLocality": _negativesToLocalityCtrl.text,
        "favourableConsiderations": _favourableConsiderationsCtrl.text,
        "otherFeatures": _otherFeaturesCtrl.text,

        // Construction Details
        "approvedDrawingAvailable": _approvedDrawingAvailable.toString(),
        "approvalNoAndDate": _approvalNoAndDateCtrl.text,
        "constructionAsPerPlan": _constructionAsPerPlan.toString(),
        "drawingDeviations": _drawingDeviationsCtrl.text,
        "deviationNature": _deviationNature.toString().split('.').last,
        "marketability": _marketabilityCtrl.text,
        "buildingAge": _buildingAgeCtrl.text,
        "residualLife": _residualLifeCtrl.text,
        "fsiApproved": _fsiApprovedCtrl.text,
        "fsiActual": _fsiActualCtrl.text,
        "specFoundation": _specFoundationCtrl.text,
        "specRoof": _specRoofCtrl.text,
        "specFlooring": _specFlooringCtrl.text,
        "qualityOfConstruction": _qualityOfConstructionCtrl.text,
        "adheresToSafetySpecs": _adheresToSafetySpecs.toString(),
        "highTensionLineImpact": _highTensionLineImpact.toString(),

        // Valuation Details
        "landArea": _landAreaCtrl.text,
        "landUnitRate": _landUnitRateCtrl.text,
        "landGuidelineRate": _landGuidelineRateCtrl.text,
        "amenitiesArea": _amenitiesAreaCtrl.text,
        "amenitiesUnitRate": _amenitiesUnitRateCtrl.text,
        "amenitiesGuidelineRate": _amenitiesGuidelineRateCtrl.text,
        "marketValueSourceHouse": _marketValueSourceHouseCtrl.text,

        // Flat Details
        "flatUndividedShare": _flatUndividedShareCtrl.text,
        "flatBuiltUpArea": _flatBuiltUpAreaCtrl.text,
        "flatCompositeRate": _flatCompositeRateCtrl.text,
        "flatValueUnitRate": _flatValueUnitRateCtrl.text,
        "flatValueMarket": _flatValueMarketCtrl.text,
        "flatValueGuidelineRate": _flatValueGuidelineRateCtrl.text,
        "flatValueGuideline": _flatValueGuidelineCtrl.text,
        "marketValueSourceFlat": _marketValueSourceFlatCtrl.text,
        "flatExtraAmenities": _flatExtraAmenitiesCtrl.text,

        // Improvement Details
        "improvementDescription": _improvementDescriptionCtrl.text,
        "improvementAmount": _improvementAmountCtrl.text,
        "improvementEstimateReasonable":
            _improvementEstimateReasonable.toString(),
        "improvementReasonableEstimate":
            _improvementReasonableEstimateCtrl.text,

        // Remarks
        "remarksBackground": _remarksBackgroundCtrl.text,
        "remarksSources": _remarksSourcesCtrl.text,
        "remarksProcedures": _remarksProceduresCtrl.text,
        "remarksMethodology": _remarksMethodologyCtrl.text,
        "remarksFactors": _remarksFactorsCtrl.text,

        "selectedPropertyType":
            _selectedPropertyType.toString().split('.').last,
      });

      // Handle image uploads
      List<Map<String, String>> imageMetadata = [];

      for (int i = 0; i < _valuationImages.length; i++) {
        final image = _valuationImages[i];
        final imageBytes = image.imageFile is File
            ? await (image.imageFile as File).readAsBytes()
            : image.imageFile;

        request.files.add(http.MultipartFile.fromBytes(
          'images',
          imageBytes,
          filename: 'property_${_fileNoCtrl.text}_$i.jpg',
        ));

        imageMetadata.add({
          "latitude": image.latitude.toString(),
          "longitude": image.longitude.toString(),
        });
      }

      request.fields['images'] = jsonEncode(imageMetadata);

      final response = await request.send();

      debugPrint("Request sent to backend");

      if (context.mounted) Navigator.of(context).pop();

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('PVR3 data saved successfully!')));
        }
        await _saveToNearbyCollection();
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Upload failed: ${response.reasonPhrase}')));
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

  OccupantStatus _parseOccupantStatus(String? status) {
    if (status == null) return OccupantStatus.Occupied;
    switch (status.toLowerCase()) {
      case 'rented':
        return OccupantStatus.Rented;
      default:
        return OccupantStatus.Occupied;
    }
  }

  DeviationNature _parseDeviationNature(String? nature) {
    if (nature == null) return DeviationNature.NIL;
    switch (nature.toLowerCase()) {
      case 'major':
        return DeviationNature.Major;
      case 'minor':
        return DeviationNature.Minor;
      default:
        return DeviationNature.NIL;
    }
  }

  PropertyType _parsePropertyType(String? type) {
    if (type == null) return PropertyType.House;
    switch (type.toLowerCase()) {
      case 'flat':
        return PropertyType.Flat;
      default:
        return PropertyType.House;
    }
  }

  void _initializeFormWithPropertyData() async {
    if (widget.propertyData != null) {
      final data = widget.propertyData!;

      // Basic Information
      _fileNoCtrl.text = data['fileNo']?.toString() ?? _fileNoCtrl.text;
      _valuerNameCtrl.text =
          data['valuerName']?.toString() ?? _valuerNameCtrl.text;
      _valuerCodeCtrl.text =
          data['valuerCode']?.toString() ?? _valuerCodeCtrl.text;
      _appointingAuthorityCtrl.text = data['appointingAuthority']?.toString() ??
          _appointingAuthorityCtrl.text;
      _reraNoCtrl.text = data['reraNo']?.toString() ?? _reraNoCtrl.text;
      _schemeCtrl.text = data['scheme']?.toString() ?? _schemeCtrl.text;
      _applicantNameCtrl.text =
          data['applicantName']?.toString() ?? _applicantNameCtrl.text;
      _documentPerusedCtrl.text =
          data['documentPerused']?.toString() ?? _documentPerusedCtrl.text;
      _addressCtrl.text = data['address']?.toString() ?? _addressCtrl.text;

      // Location Details
      _locationSketchVerified =
          data['locationSketchVerified'] as bool? ?? _locationSketchVerified;
      _northBoundaryCtrl.text =
          data['northBoundary']?.toString() ?? _northBoundaryCtrl.text;
      _northDimCtrl.text = data['northDim']?.toString() ?? _northDimCtrl.text;
      _southBoundaryCtrl.text =
          data['southBoundary']?.toString() ?? _southBoundaryCtrl.text;
      _southDimCtrl.text = data['southDim']?.toString() ?? _southDimCtrl.text;
      _eastBoundaryCtrl.text =
          data['eastBoundary']?.toString() ?? _eastBoundaryCtrl.text;
      _eastDimCtrl.text = data['eastDim']?.toString() ?? _eastDimCtrl.text;
      _westBoundaryCtrl.text =
          data['westBoundary']?.toString() ?? _westBoundaryCtrl.text;
      _westDimCtrl.text = data['westDim']?.toString() ?? _westDimCtrl.text;
      _extent1Ctrl.text = data['extent1']?.toString() ?? _extent1Ctrl.text;
      _extent2Ctrl.text = data['extent2']?.toString() ?? _extent2Ctrl.text;

      // Property Details
      _propertyTypeCtrl.text =
          data['propertyType']?.toString() ?? _propertyTypeCtrl.text;
      _occupantStatus =
          _parseOccupantStatus(data['occupantStatus']?.toString());
      _occupantNameCtrl.text =
          data['occupantName']?.toString() ?? _occupantNameCtrl.text;
      _usageOfBuildingCtrl.text =
          data['usageOfBuilding']?.toString() ?? _usageOfBuildingCtrl.text;
      _nearbyLandmarkCtrl.text =
          data['nearbyLandmark']?.toString() ?? _nearbyLandmarkCtrl.text;
      _surroundingAreaDevCtrl.text = data['surroundingAreaDev']?.toString() ??
          _surroundingAreaDevCtrl.text;
      _basicAmenitiesAvailable =
          data['basicAmenitiesAvailable'] as bool? ?? _basicAmenitiesAvailable;
      _negativesToLocalityCtrl.text = data['negativesToLocality']?.toString() ??
          _negativesToLocalityCtrl.text;
      _favourableConsiderationsCtrl.text =
          data['favourableConsiderations']?.toString() ??
              _favourableConsiderationsCtrl.text;
      _otherFeaturesCtrl.text =
          data['otherFeatures']?.toString() ?? _otherFeaturesCtrl.text;

      // Construction Details
      _approvedDrawingAvailable = data['approvedDrawingAvailable'] as bool? ??
          _approvedDrawingAvailable;
      _approvalNoAndDateCtrl.text =
          data['approvalNoAndDate']?.toString() ?? _approvalNoAndDateCtrl.text;
      _constructionAsPerPlan =
          data['constructionAsPerPlan'] as bool? ?? _constructionAsPerPlan;
      _drawingDeviationsCtrl.text =
          data['drawingDeviations']?.toString() ?? _drawingDeviationsCtrl.text;
      _deviationNature =
          _parseDeviationNature(data['deviationNature']?.toString());
      _marketabilityCtrl.text =
          data['marketability']?.toString() ?? _marketabilityCtrl.text;
      _buildingAgeCtrl.text =
          data['buildingAge']?.toString() ?? _buildingAgeCtrl.text;
      _residualLifeCtrl.text =
          data['residualLife']?.toString() ?? _residualLifeCtrl.text;
      _fsiApprovedCtrl.text =
          data['fsiApproved']?.toString() ?? _fsiApprovedCtrl.text;
      _fsiActualCtrl.text =
          data['fsiActual']?.toString() ?? _fsiActualCtrl.text;
      _specFoundationCtrl.text =
          data['specFoundation']?.toString() ?? _specFoundationCtrl.text;
      _specRoofCtrl.text = data['specRoof']?.toString() ?? _specRoofCtrl.text;
      _specFlooringCtrl.text =
          data['specFlooring']?.toString() ?? _specFlooringCtrl.text;
      _qualityOfConstructionCtrl.text =
          data['qualityOfConstruction']?.toString() ??
              _qualityOfConstructionCtrl.text;
      _adheresToSafetySpecs =
          data['adheresToSafetySpecs'] as bool? ?? _adheresToSafetySpecs;
      _highTensionLineImpact =
          data['highTensionLineImpact'] as bool? ?? _highTensionLineImpact;

      // Valuation Details
      _landAreaCtrl.text = data['landArea']?.toString() ?? _landAreaCtrl.text;
      _landUnitRateCtrl.text =
          data['landUnitRate']?.toString() ?? _landUnitRateCtrl.text;
      _landGuidelineRateCtrl.text =
          data['landGuidelineRate']?.toString() ?? _landGuidelineRateCtrl.text;
      _amenitiesAreaCtrl.text =
          data['amenitiesArea']?.toString() ?? _amenitiesAreaCtrl.text;
      _amenitiesUnitRateCtrl.text =
          data['amenitiesUnitRate']?.toString() ?? _amenitiesUnitRateCtrl.text;
      _amenitiesGuidelineRateCtrl.text =
          data['amenitiesGuidelineRate']?.toString() ??
              _amenitiesGuidelineRateCtrl.text;
      _marketValueSourceHouseCtrl.text =
          data['marketValueSourceHouse']?.toString() ??
              _marketValueSourceHouseCtrl.text;

      // Flat Details
      _flatUndividedShareCtrl.text = data['flatUndividedShare']?.toString() ??
          _flatUndividedShareCtrl.text;
      _flatBuiltUpAreaCtrl.text =
          data['flatBuiltUpArea']?.toString() ?? _flatBuiltUpAreaCtrl.text;
      _flatCompositeRateCtrl.text =
          data['flatCompositeRate']?.toString() ?? _flatCompositeRateCtrl.text;
      _flatValueUnitRateCtrl.text =
          data['flatValueUnitRate']?.toString() ?? _flatValueUnitRateCtrl.text;
      _flatValueMarketCtrl.text =
          data['flatValueMarket']?.toString() ?? _flatValueMarketCtrl.text;
      _flatValueGuidelineRateCtrl.text =
          data['flatValueGuidelineRate']?.toString() ??
              _flatValueGuidelineRateCtrl.text;
      _flatValueGuidelineCtrl.text = data['flatValueGuideline']?.toString() ??
          _flatValueGuidelineCtrl.text;
      _marketValueSourceFlatCtrl.text =
          data['marketValueSourceFlat']?.toString() ??
              _marketValueSourceFlatCtrl.text;
      _flatExtraAmenitiesCtrl.text = data['flatExtraAmenities']?.toString() ??
          _flatExtraAmenitiesCtrl.text;

      // Improvement Details
      _improvementDescriptionCtrl.text =
          data['improvementDescription']?.toString() ??
              _improvementDescriptionCtrl.text;
      _improvementAmountCtrl.text =
          data['improvementAmount']?.toString() ?? _improvementAmountCtrl.text;
      _improvementEstimateReasonable =
          data['improvementEstimateReasonable'] as bool? ??
              _improvementEstimateReasonable;
      _improvementReasonableEstimateCtrl.text =
          data['improvementReasonableEstimate']?.toString() ??
              _improvementReasonableEstimateCtrl.text;

      // Remarks
      _remarksBackgroundCtrl.text =
          data['remarksBackground']?.toString() ?? _remarksBackgroundCtrl.text;
      _remarksSourcesCtrl.text =
          data['remarksSources']?.toString() ?? _remarksSourcesCtrl.text;
      _remarksProceduresCtrl.text =
          data['remarksProcedures']?.toString() ?? _remarksProceduresCtrl.text;
      _remarksMethodologyCtrl.text = data['remarksMethodology']?.toString() ??
          _remarksMethodologyCtrl.text;
      _remarksFactorsCtrl.text =
          data['remarksFactors']?.toString() ?? _remarksFactorsCtrl.text;

      // Property Type
      _selectedPropertyType =
          _parsePropertyType(data['selectedPropertyType']?.toString());

      // Date fields
      if (data['inspectionDate'] != null) {
        try {
          debugPrint(data['inspectionDate']);
          _inspectionDate = DateTime.parse(data['inspectionDate']);
        } catch (e) {
          debugPrint('Error parsing inspection date: $e');
        }
      }

      // Handle images if they exist
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

                _valuationImages.add(ValuationImage(
                  imageFile: imageBytes,
                  latitude: imgData['latitude']?.toString() ?? '',
                  longitude: imgData['longitude']?.toString() ?? '',
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
      debugPrint('PVR3 Form initialized with property data');
    } else {
      debugPrint('No property data - PVR3 form will use default values');
    }
  }

  Future<void> _getNearbyProperty() async {
    final latitude = _nearbyLatitude.text.trim();
    final longitude = _nearbyLongitude.text.trim();

    debugPrint(latitude);

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
        debugPrint('Response Data (Array):');
        for (var item in responseData) {
          debugPrint(item.toString()); // Print each item in the array
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

  // Helper methods for enum parsing
  Future<void> _getNearbytLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text("Location services are disabled. Please enable them.")),
      );
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Location permissions are denied.")),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                "Location permissions are permanently denied, we cannot request permissions.")),
      );
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _nearbyLatitude.text = position.latitude.toString();
        _nearbyLongitude.text = position.longitude.toString();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error getting location: $e")),
      );
    }
  }

  void _addFloor() => setState(() => _floors.add(FloorData(name: 'New Floor')));
  void _removeFloor(int index) {
    if (_floors.length > 1) {
      setState(() => _floors.removeAt(index));
    }
  }

  // ADDED: Methods to manage the "Progress of Work" items
  void _addProgressWorkItem() =>
      setState(() => _progressWorkItems.add(ProgressWorkItem()));
  void _removeProgressWorkItem(int index) {
    setState(() => _progressWorkItems.removeAt(index));
  }

  Future<void> _getCurrentLocation(int imageIndex) async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Location services are disabled.")));
      return;
    }
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Location permissions are denied.")));
        return;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Location permissions are permanently denied.")));
      return;
    }
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _valuationImages[imageIndex].latitude = position.latitude.toString();
        _valuationImages[imageIndex].longitude = position.longitude.toString();
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error getting location: $e")));
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      if (source == ImageSource.gallery) {
        final pickedFiles = await _picker.pickMultiImage();
        if (pickedFiles.isNotEmpty) {
          for (var file in pickedFiles) {
            final bytes = await file.readAsBytes();
            _valuationImages.add(ValuationImage(imageFile: bytes));
          }
          setState(() {});
        }
      } else {
        final pickedFile = await _picker.pickImage(source: source);
        if (pickedFile != null) {
          final bytes = await pickedFile.readAsBytes();
          setState(() {
            _valuationImages.add(ValuationImage(imageFile: bytes));
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick images: $e')),
      );
    }
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
            child: Wrap(children: <Widget>[
          ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Photo Library'),
              onTap: () {
                _pickImage(ImageSource.gallery);
                Navigator.of(context).pop();
              }),
          ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Camera'),
              onTap: () {
                _pickImage(ImageSource.camera);
                Navigator.of(context).pop();
              }),
        ]));
      },
    );
  }

  void _generatePdf() {
    if (_formKey.currentState!.validate()) {
      final data = ValuationData(
        fileNo: _fileNoCtrl.text,
        valuerName: _valuerNameCtrl.text,
        valuerCode: _valuerCodeCtrl.text,
        appointingAuthority: _appointingAuthorityCtrl.text,
        inspectionDate: _inspectionDate,
        reraNo: _reraNoCtrl.text,
        scheme: _schemeCtrl.text,
        applicantName: _applicantNameCtrl.text,
        documentPerused: _documentPerusedCtrl.text,
        propertyAddress: _addressCtrl.text,
        locationSketchVerified: _locationSketchVerified,
        northBoundary: _northBoundaryCtrl.text,
        southBoundary: _southBoundaryCtrl.text,
        eastBoundary: _eastBoundaryCtrl.text,
        westBoundary: _westBoundaryCtrl.text,
        northDim: _northDimCtrl.text, southDim: _southDimCtrl.text,
        eastDim: _eastDimCtrl.text, westDim: _westDimCtrl.text,
        extent1: _extent1Ctrl.text,
        extent2: _extent2Ctrl.text,
        propertyType: _propertyTypeCtrl.text,
        occupantStatus: _occupantStatus,
        occupantName: _occupantNameCtrl.text,
        usageOfBuilding: _usageOfBuildingCtrl.text,
        nearbyLandmark: _nearbyLandmarkCtrl.text,
        surroundingAreaDev: _surroundingAreaDevCtrl.text,
        basicAmenitiesAvailable: _basicAmenitiesAvailable,
        negativesToLocality: _negativesToLocalityCtrl.text,
        favourableConsiderations: _favourableConsiderationsCtrl.text,
        otherFeatures: _otherFeaturesCtrl.text,
        approvedDrawingAvailable: _approvedDrawingAvailable,
        approvalNoAndDate: _approvalNoAndDateCtrl.text,
        constructionAsPerPlan: _constructionAsPerPlan,
        drawingDeviations: _drawingDeviationsCtrl.text,
        deviationNature: _deviationNature,
        marketability: _marketabilityCtrl.text,
        buildingAge: _buildingAgeCtrl.text,
        residualLife: _residualLifeCtrl.text,
        fsiApproved: _fsiApprovedCtrl.text, fsiActual: _fsiActualCtrl.text,
        specFoundation: _specFoundationCtrl.text, specRoof: _specRoofCtrl.text,
        specFlooring: _specFlooringCtrl.text,
        qualityOfConstruction: _qualityOfConstructionCtrl.text,
        adheresToSafetySpecs: _adheresToSafetySpecs,
        highTensionLineImpact: _highTensionLineImpact,
        valuationType: _selectedPropertyType,
        landArea: _landAreaCtrl.text, landUnitRate: _landUnitRateCtrl.text,
        landGuidelineRate: _landGuidelineRateCtrl.text,
        floors: _floors,
        amenitiesArea: _amenitiesAreaCtrl.text,
        amenitiesUnitRate: _amenitiesUnitRateCtrl.text,
        amenitiesGuidelineRate: _amenitiesGuidelineRateCtrl.text,
        marketValueSourceHouse: _marketValueSourceHouseCtrl.text,
        flatUndividedShare: _flatUndividedShareCtrl.text,
        flatBuiltUpArea: _flatBuiltUpAreaCtrl.text,
        flatCompositeRate: _flatCompositeRateCtrl.text,
        flatValueUnitRate: _flatValueUnitRateCtrl.text,
        flatValueMarket: _flatValueMarketCtrl.text,
        flatValueGuideline: _flatValueGuidelineCtrl.text,
        flatValueGuidelineRate: _flatValueGuidelineRateCtrl.text,
        marketValueSourceFlat: _marketValueSourceFlatCtrl.text,
        flatExtraAmenities: _flatExtraAmenitiesCtrl.text,
        improvementDescription: _improvementDescriptionCtrl.text,
        improvementAmount: _improvementAmountCtrl.text,
        improvementEstimateReasonable: _improvementEstimateReasonable,
        improvementReasonableEstimate:
            _improvementReasonableEstimateCtrl.text, // ADDED
        progressWorkItems: _progressWorkItems, // MODIFIED
        remarksBackground: _remarksBackgroundCtrl.text,
        remarksSources: _remarksSourcesCtrl.text,
        remarksProcedures: _remarksProceduresCtrl.text,
        remarksMethodology: _remarksMethodologyCtrl.text,
        remarksFactors: _remarksFactorsCtrl.text,
        images: _valuationImages,
      );
      Printing.layoutPdf(
        onLayout: (PdfPageFormat format) => generateValuationPdf(data),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PVR-3 Dynamic Report')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
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
                      controller: _nearbyLatitude,
                      decoration: const InputDecoration(labelText: 'Latitude'),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _nearbyLongitude,
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
                                onPressed:
                                    _getNearbytLocation, // Call our new method
                                icon: const Icon(Icons.my_location),
                                label: const Text('Get Location'),
                              ),
                            ),
                            const SizedBox(
                              width: 4,
                            ),
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
                            )
                          ],
                        ),
                      ],
                    )),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  right: 40, left: 40, top: 10, bottom: 10),
              child: FloatingActionButton.extended(
                heroTag: "f1",
                icon: const Icon(Icons.search),
                label: const Text('Search Saved Drafts'),
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (ctx) {
                    return const SavedDraftsPVR3();
                  }));
                },
              ),
            ),
            _buildSection(title: 'Header Information', children: [
              TextFormField(
                  controller: _fileNoCtrl,
                  decoration: const InputDecoration(labelText: 'File No.')),
              TextFormField(
                  controller: _valuerNameCtrl,
                  decoration: const InputDecoration(labelText: 'Valuer Name')),
              TextFormField(
                  controller: _valuerCodeCtrl,
                  decoration: const InputDecoration(labelText: 'Valuer Code')),
              TextFormField(
                  controller: _appointingAuthorityCtrl,
                  decoration:
                      const InputDecoration(labelText: 'Appointing Authority')),
              TextFormField(
                  controller: _reraNoCtrl,
                  decoration: const InputDecoration(labelText: 'RERA NO.')),
              TextFormField(
                  controller: _schemeCtrl,
                  decoration: const InputDecoration(labelText: 'Scheme')),
              ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text("Inspection Date"),
                  subtitle:
                      Text(DateFormat('dd-MM-yyyy').format(_inspectionDate)),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final picked = await showDatePicker(
                        context: context,
                        initialDate: _inspectionDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100));
                    if (picked != null) {
                      setState(() => _inspectionDate = picked);
                    }
                  }),
            ]),
            _buildSection(title: '1. Property Details', children: [
              TextFormField(
                  controller: _applicantNameCtrl,
                  decoration:
                      const InputDecoration(labelText: 'Applicant Name')),
              TextFormField(
                  controller: _documentPerusedCtrl,
                  decoration:
                      const InputDecoration(labelText: 'Document Perused')),
              TextFormField(
                  controller: _addressCtrl,
                  decoration:
                      const InputDecoration(labelText: 'Property Address'),
                  maxLines: 3),
              SwitchListTile(
                  title: const Text('Location Sketch Verified?'),
                  value: _locationSketchVerified,
                  onChanged: (v) =>
                      setState(() => _locationSketchVerified = v)),
              TextFormField(
                  controller: _propertyTypeCtrl,
                  decoration:
                      const InputDecoration(labelText: 'Type of property')),
              DropdownButtonFormField<OccupantStatus>(
                  value: _occupantStatus,
                  decoration:
                      const InputDecoration(labelText: 'Occupant Status'),
                  items: OccupantStatus.values
                      .map((s) =>
                          DropdownMenuItem(value: s, child: Text(s.name)))
                      .toList(),
                  onChanged: (v) => setState(() => _occupantStatus = v!)),
              TextFormField(
                  controller: _occupantNameCtrl,
                  decoration: InputDecoration(
                      labelText: _occupantStatus == OccupantStatus.Occupied
                          ? 'Name of Occupant'
                          : 'List of Occupants')),
              TextFormField(
                  controller: _usageOfBuildingCtrl,
                  decoration:
                      const InputDecoration(labelText: 'Usage of Building')),
              TextFormField(
                  controller: _nearbyLandmarkCtrl,
                  decoration: const InputDecoration(
                      labelText: ' Details of the Nearby Landmark')),
              TextFormField(
                  controller: _surroundingAreaDevCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Development of surrounding area')),
              SwitchListTile(
                  title: const Text('Basic amenities available?'),
                  value: _basicAmenitiesAvailable,
                  onChanged: (v) =>
                      setState(() => _basicAmenitiesAvailable = v)),
              TextFormField(
                  controller: _negativesToLocalityCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Any negatives to the locality')),
              TextFormField(
                  controller: _favourableConsiderationsCtrl,
                  decoration: const InputDecoration(
                      labelText:
                          'Any favourable considerations for addl value')),
              TextFormField(
                  controller: _otherFeaturesCtrl,
                  decoration: const InputDecoration(
                      labelText:
                          ' Any other features like board of other financier indicating mortgage, notice of Court/any authority which may effect the security.')),
            ]),
            _buildSection(title: '2. Drawing', children: [
              SwitchListTile(
                  title:
                      const Text('Whether the approved drawing is available?'),
                  value: _approvedDrawingAvailable,
                  onChanged: (v) =>
                      setState(() => _approvedDrawingAvailable = v)),
              TextFormField(
                  controller: _approvalNoAndDateCtrl,
                  decoration:
                      const InputDecoration(labelText: 'Approval No. & Date')),
              SwitchListTile(
                  title: const Text('Construction as per plan?'),
                  value: _constructionAsPerPlan,
                  onChanged: (v) => setState(() => _constructionAsPerPlan = v)),
              TextFormField(
                  controller: _drawingDeviationsCtrl,
                  decoration: const InputDecoration(
                      labelText:
                          'What are the deviations between drawing & actual')),
              DropdownButtonFormField<DeviationNature>(
                  value: _deviationNature,
                  decoration: const InputDecoration(
                      labelText:
                          'Whether deviations are minor/major in nature '),
                  items: DeviationNature.values
                      .map((d) =>
                          DropdownMenuItem(value: d, child: Text(d.name)))
                      .toList(),
                  onChanged: (v) => setState(() => _deviationNature = v!)),
            ]),
            _buildSection(title: '3. Building Details', children: [
              TextFormField(
                  controller: _marketabilityCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Marketability of the Property')),
              TextFormField(
                  controller: _buildingAgeCtrl,
                  decoration:
                      const InputDecoration(labelText: 'Age of Building'),
                  keyboardType: TextInputType.number),
              TextFormField(
                  controller: _residualLifeCtrl,
                  decoration:
                      const InputDecoration(labelText: 'Future Residual Life'),
                  keyboardType: TextInputType.number),
              TextFormField(
                  controller: _fsiApprovedCtrl,
                  decoration:
                      const InputDecoration(labelText: 'FSI (Approved)')),
              TextFormField(
                  controller: _fsiActualCtrl,
                  decoration: const InputDecoration(labelText: 'FSI (Actual)')),
              TextFormField(
                  controller: _specFoundationCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Specification: Foundation')),
              TextFormField(
                  controller: _specRoofCtrl,
                  decoration:
                      const InputDecoration(labelText: 'Specification: Roof')),
              TextFormField(
                  controller: _specFlooringCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Specification: Flooring')),
              TextFormField(
                  controller: _qualityOfConstructionCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Quality of Construction')),
              SwitchListTile(
                  title: const Text('Adheres to Safety Specs (NBC/NDMA)?'),
                  value: _adheresToSafetySpecs,
                  onChanged: (v) => setState(() => _adheresToSafetySpecs = v)),
              SwitchListTile(
                  title: const Text('Adverse Impact from High Tension Lines?'),
                  value: _highTensionLineImpact,
                  onChanged: (v) => setState(() => _highTensionLineImpact = v)),
            ]),
            _buildSection(
                title: '4. Valuation Details',
                initiallyExpanded: true,
                children: [
                  Text('Select Property Type:',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  Row(children: [
                    Expanded(
                        child: RadioListTile<PropertyType>(
                            title: const Text('House'),
                            value: PropertyType.House,
                            groupValue: _selectedPropertyType,
                            onChanged: (v) =>
                                setState(() => _selectedPropertyType = v!))),
                    Expanded(
                        child: RadioListTile<PropertyType>(
                            title: const Text('Flat'),
                            value: PropertyType.Flat,
                            groupValue: _selectedPropertyType,
                            onChanged: (v) =>
                                setState(() => _selectedPropertyType = v!))),
                  ]),
                  const Divider(height: 20),
                  if (_selectedPropertyType == PropertyType.House)
                    _buildHouseValuationUI()
                  else
                    _buildFlatValuationUI(),
                ]),
            // MODIFIED: Section 5 UI
            _buildSection(title: '5. Estimate for Improvement', children: [
              TextFormField(
                  controller: _improvementDescriptionCtrl,
                  decoration: const InputDecoration(
                      labelText:
                          '1. Description of improvement works as per applicants estimate'),
                  maxLines: 2),
              TextFormField(
                  controller: _improvementAmountCtrl,
                  decoration: const InputDecoration(
                      labelText:
                          '2. Amount estimated by the applicant for the improvement works'),
                  keyboardType: TextInputType.number),
              SwitchListTile(
                  title: const Text(
                      '3. Whether the estimate submitted by the applicant is reasonable?'),
                  value: _improvementEstimateReasonable,
                  onChanged: (v) =>
                      setState(() => _improvementEstimateReasonable = v)),
              if (!_improvementEstimateReasonable)
                TextFormField(
                  controller: _improvementReasonableEstimateCtrl,
                  decoration: const InputDecoration(
                      labelText:
                          '4. If not, what would be the reasonable estimate'),
                  keyboardType: TextInputType.number,
                ),
            ]),
            // MODIFIED: Section 6 UI
            _buildSection(title: '6. Progress of Work', children: [
              const Text('1. Value of improvement works completed'),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _progressWorkItems.length,
                itemBuilder: (context, index) =>
                    _buildProgressWorkItemRow(index),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  icon: const Icon(Icons.add_circle),
                  label: const Text('Add Row'),
                  onPressed: _addProgressWorkItem,
                ),
              ),
            ]),
            _buildSection(title: '8. Remarks', children: [
              TextFormField(
                  controller: _remarksBackgroundCtrl,
                  decoration: const InputDecoration(
                      labelText: 'a) Background information')),
              TextFormField(
                  controller: _remarksSourcesCtrl,
                  decoration: const InputDecoration(
                      labelText: 'b) Sources of information')),
              TextFormField(
                  controller: _remarksProceduresCtrl,
                  decoration: const InputDecoration(
                      labelText: 'c) Procedures adopted')),
              TextFormField(
                  controller: _remarksMethodologyCtrl,
                  decoration: const InputDecoration(
                      labelText: 'd) Valuation methodology')),
              TextFormField(
                  controller: _remarksFactorsCtrl,
                  decoration: const InputDecoration(
                      labelText: 'e) Major factors that influenced')),
            ]),
            _buildSection(
                title: "Images & Location",
                initiallyExpanded: true,
                children: [
                  Center(
                      child: ElevatedButton.icon(
                          icon: const Icon(Icons.add_a_photo),
                          label: const Text('Add Images'),
                          onPressed: _showImagePickerOptions)),
                  if (_valuationImages.isNotEmpty)
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _valuationImages.length,
                      itemBuilder: (context, index) {
                        final valuationImage = _valuationImages[index];
                        final latController = TextEditingController(
                            text: valuationImage.latitude);
                        final lonController = TextEditingController(
                            text: valuationImage.longitude);
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(children: [
                                Stack(children: [
                                  Image.memory(valuationImage.imageFile,
                                      height: 150,
                                      width: double.infinity,
                                      fit: BoxFit.cover),
                                  Positioned(
                                      right: 0,
                                      top: 0,
                                      child: CircleAvatar(
                                          radius: 18,
                                          backgroundColor: Colors.white70,
                                          child: IconButton(
                                              padding: EdgeInsets.zero,
                                              icon: const Icon(Icons.delete,
                                                  color: Colors.red),
                                              onPressed: () => setState(() =>
                                                  _valuationImages
                                                      .removeAt(index))))),
                                ]),
                                const SizedBox(height: 10),
                                Row(children: [
                                  Expanded(
                                      child: TextFormField(
                                          controller: latController,
                                          decoration: const InputDecoration(
                                              labelText: 'Latitude',
                                              border: OutlineInputBorder()),
                                          onChanged: (value) =>
                                              valuationImage.latitude = value)),
                                  const SizedBox(width: 10),
                                  Expanded(
                                      child: TextFormField(
                                          controller: lonController,
                                          decoration: const InputDecoration(
                                              labelText: 'Longitude',
                                              border: OutlineInputBorder()),
                                          onChanged: (value) => valuationImage
                                              .longitude = value)),
                                ]),
                                const SizedBox(height: 10),
                                ElevatedButton.icon(
                                    icon: const Icon(Icons.my_location),
                                    label: const Text('Get Current Location'),
                                    onPressed: () =>
                                        _getCurrentLocation(index)),
                              ])),
                        );
                      },
                    ),
                ]),
            const SizedBox(height: 15),
            FloatingActionButton.extended(
                heroTag: "f2",
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text('Generate PDF'),
                onPressed: _generatePdf),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            heroTag: "f3",
            icon: const Icon(Icons.save),
            label: const Text('Save'),
            onPressed: _saveData,
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
          {required String title,
          required List<Widget> children,
          bool initiallyExpanded = false}) =>
      Card(
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: ExpansionTile(
          title: Text(title,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          initiallyExpanded: initiallyExpanded,
          childrenPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          children: children
              .map((child) => Padding(
                  padding: const EdgeInsets.only(bottom: 12), child: child))
              .toList(),
        ),
      );

  Widget _buildHouseValuationUI() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('a. Value of the property (if it is a house)',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text('Land Details', style: Theme.of(context).textTheme.titleSmall),
          TextFormField(
              controller: _landAreaCtrl,
              decoration: const InputDecoration(labelText: 'Land Area')),
          TextFormField(
              controller: _landUnitRateCtrl,
              decoration:
                  const InputDecoration(labelText: 'Land Unit Rate (Market)')),
          TextFormField(
              controller: _landGuidelineRateCtrl,
              decoration: const InputDecoration(
                  labelText: 'Land Unit Rate (Guideline)')),
          const Divider(height: 20, thickness: 1),
          Text('Floor Details', style: Theme.of(context).textTheme.titleSmall),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _floors.length,
            itemBuilder: (context, index) => _buildFloorInputRow(index),
          ),
          Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                  icon: const Icon(Icons.add_circle),
                  label: const Text('Add Floor'),
                  onPressed: _addFloor)),
          const Divider(height: 20, thickness: 1),
          Text('Amenities', style: Theme.of(context).textTheme.titleSmall),
          TextFormField(
              controller: _amenitiesAreaCtrl,
              decoration: const InputDecoration(labelText: 'Amenities Area')),
          TextFormField(
              controller: _amenitiesUnitRateCtrl,
              decoration: const InputDecoration(
                  labelText: 'Amenities Unit Rate (Market)')),
          TextFormField(
              controller: _amenitiesGuidelineRateCtrl,
              decoration: const InputDecoration(
                  labelText: 'Amenities Unit Rate (Guideline)')),
          const Divider(height: 20, thickness: 1),
          TextFormField(
              controller: _marketValueSourceHouseCtrl,
              decoration:
                  const InputDecoration(labelText: 'Source for Market Value')),
        ],
      );

  Widget _buildFloorInputRow(int index) {
    final floor = _floors[index];
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(children: [
              Expanded(
                  flex: 3,
                  child: TextFormField(
                      initialValue: floor.name,
                      decoration:
                          const InputDecoration(labelText: 'Floor Name'),
                      onChanged: (value) => floor.name = value)),
              if (_floors.length > 1)
                IconButton(
                    icon: const Icon(Icons.remove_circle_outline,
                        color: Colors.red),
                    onPressed: () => _removeFloor(index))
            ]),
            TextFormField(
                initialValue: floor.area,
                decoration: const InputDecoration(labelText: 'Area'),
                onChanged: (value) => floor.area = value,
                keyboardType: TextInputType.number),
            TextFormField(
                initialValue: floor.marketRate,
                decoration: const InputDecoration(labelText: 'Market Rate'),
                onChanged: (value) => floor.marketRate = value,
                keyboardType: TextInputType.number),
            TextFormField(
                initialValue: floor.guidelineRate,
                decoration: const InputDecoration(labelText: 'Guideline Rate'),
                onChanged: (value) => floor.guidelineRate = value,
                keyboardType: TextInputType.number),
          ],
        ),
      ),
    );
  }

  // ADDED: New widget builder for a row in the "Progress of Work" table
  Widget _buildProgressWorkItemRow(int index) {
    final item = _progressWorkItems[index];
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                    child: Text('Item ${index + 1}',
                        style: const TextStyle(fontWeight: FontWeight.bold))),
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline,
                      color: Colors.red),
                  onPressed: () => _removeProgressWorkItem(index),
                )
              ],
            ),
            TextFormField(
              initialValue: item.description,
              decoration:
                  const InputDecoration(labelText: 'Description of work'),
              onChanged: (value) => item.description = value,
              maxLines: 2,
            ),
            TextFormField(
              initialValue: item.applicantEstimate,
              decoration:
                  const InputDecoration(labelText: "Applicant's estimate"),
              onChanged: (value) => item.applicantEstimate = value,
              keyboardType: TextInputType.number,
            ),
            TextFormField(
              initialValue: item.valuerOpinion,
              decoration: const InputDecoration(labelText: "Valuer's opinion"),
              onChanged: (value) => item.valuerOpinion = value,
              keyboardType: TextInputType.number,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFlatValuationUI() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('b. Value of the property (if it is a flat)',
              style: Theme.of(context).textTheme.titleMedium),
          TextFormField(
              controller: _flatUndividedShareCtrl,
              decoration: const InputDecoration(
                  labelText: '1. Undivided Share of Land')),
          TextFormField(
              controller: _flatBuiltUpAreaCtrl,
              decoration: const InputDecoration(
                  labelText: '2. Built Up Area of the Flat')),
          TextFormField(
              controller: _flatCompositeRateCtrl,
              decoration: const InputDecoration(
                  labelText: '3. Adopted unit composite Rate')),
          const SizedBox(height: 10),
          Text('4. Estimated Value of the Flat',
              style: Theme.of(context).textTheme.bodyLarge),
          Row(children: [
            Expanded(
                child: TextFormField(
                    controller: _flatValueUnitRateCtrl,
                    decoration: const InputDecoration(labelText: 'Unit Rate'))),
            const SizedBox(width: 8),
            Expanded(
                child: TextFormField(
                    controller: _flatValueMarketCtrl,
                    decoration:
                        const InputDecoration(labelText: 'Market Value'))),
          ]),
          Row(children: [
            Expanded(
                child: TextFormField(
                    controller: _flatValueGuidelineRateCtrl,
                    decoration:
                        const InputDecoration(labelText: 'Guideline Rate'))),
            const SizedBox(width: 8),
            Expanded(
                child: TextFormField(
                    controller: _flatValueGuidelineCtrl,
                    decoration:
                        const InputDecoration(labelText: 'Guideline Value'))),
          ]),
          const SizedBox(height: 10),
          TextFormField(
              controller: _marketValueSourceFlatCtrl,
              decoration: const InputDecoration(
                  labelText:
                      'e. State the source for arriving at the Market Value')),
          TextFormField(
              controller: _flatExtraAmenitiesCtrl,
              decoration: const InputDecoration(
                  labelText: 'f. Add for extra amenities if any')),
        ],
      );
}
