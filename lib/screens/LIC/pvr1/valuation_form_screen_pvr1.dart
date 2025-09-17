// lib/valuation_form_screen_pvr1.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart'; // Import for location
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:login_screen/screens/LIC/pvr1/savedDrafts.dart';
import 'package:login_screen/screens/nearbyDetails.dart';

import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'valuation_data_model_pvr1.dart';
import 'pdf_generator_pvr1.dart';
import 'package:http/http.dart' as http;
import 'config.dart';
import 'package:login_screen/screens/driveAPIconfig.dart';
import 'package:path/path.dart' as path;
// ignore: depend_on_referenced_packages

class ValuationFormScreenPVR1 extends StatefulWidget {
  final Map<String, dynamic>? propertyData;

  const ValuationFormScreenPVR1({
    super.key,
    this.propertyData,
  });

  @override
  _ValuationFormScreenPVR1State createState() =>
      _ValuationFormScreenPVR1State();
}

class _ValuationFormScreenPVR1State extends State<ValuationFormScreenPVR1> {
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

  late final _nearbyLatitude = TextEditingController();
  late final _nearbyLongitude = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();

  // Use the new ValuationImage class to store images with their location
  final List<ValuationImage> _valuationImages = [];

  // --- ALL CONTROLLERS AND STATE VARIABLES ---
  final _valuerNameCtrl = TextEditingController(text: 'VIGNESH S');
  final _valuerCodeCtrl = TextEditingController(text: 'TVV0001');
  DateTime _inspectionDate = DateTime(2025, 5, 20);
  final _fileNoCtrl = TextEditingController(text: '5002050002876');
  final _applicantNameCtrl = TextEditingController(text: 'SUBHA A');
  final _ownerNameCtrl = TextEditingController(text: 'SUBHA A');
  final _documentsPerusedCtrl = TextEditingController(text: 'Minor');
  final _propertyLocationCtrl = TextEditingController(
      text:
          '121 ARES RS N 277 16 3 BLDG NO 15 66 MARANALLOOR VILLAGE KATTAKADA TALUK RS N 277 16 3 MARANALLOOR MARANALLOOR THIRUVANANTHAPURAM 695501');
  bool _addressTallies = true;
  bool _locationSketchVerified = true;
  final _surroundingDevCtrl = TextEditingController(text: 'Middle Class');
  bool _basicAmenitiesAvailable = true;
  final _negativesToLocalityCtrl = TextEditingController(text: 'NIL');
  final _favorableConsiderationsCtrl = TextEditingController(text: 'NIL');
  final _nearbyLandmarkCtrl = TextEditingController(text: 'RUSSELPURAM');
  final _otherFeaturesCtrl = TextEditingController(text: 'NIL');
  final _northBoundaryCtrl = TextEditingController(text: 'PROPERTY OF GOPAN');
  final _northDimCtrl = TextEditingController(text: '1460 CM');
  final _southBoundaryCtrl =
      TextEditingController(text: 'PROPERTY OF AYAPPAN NAIR');
  final _southDimCtrl = TextEditingController(text: '1400 CM');
  final _eastBoundaryCtrl =
      TextEditingController(text: 'PANCHAYATH ROAD HAVING CAR ACCESS');
  final _eastDimCtrl = TextEditingController(text: '850 CM');
  final _westBoundaryCtrl =
      TextEditingController(text: 'PROPERTY OF AYAPPAN NAIR');
  final _westDimCtrl = TextEditingController(text: '850 CM');
  final _totalExtent1Ctrl = TextEditingController(text: '1.21');
  final _totalExtent2Ctrl = TextEditingController(text: '2.98');
  bool _boundariesTally = true;
  final _existingLandUseCtrl = TextEditingController(
      text: 'GROUND FLOOR TO BE RENOVATED HAVING A PLINTH AREA OF 393 SQFT');
  final _proposedLandUseCtrl = TextEditingController(
      text:
          'EXTENSION OF GF AND ADDITIONAL FF HAVING A TOTAL PLINTH AREA OF 524 SQFT');
  bool _naPermissionRequired = false;
  final _approvalNoCtrl =
      TextEditingController(text: 'A1/BA/134572/2025 DATED 26-04-2025');
  final _validityPeriodCtrl =
      TextEditingController(text: 'VALID UP TO 25-04-2030');
  bool _isValidityExpiredRenewed = false;
  final _approvalAuthorityCtrl =
      TextEditingController(text: 'MARANALLOOR GRAMA PANCHAYATH');
  final _approvedGfCtrl = TextEditingController(text: '65');
  final _approvedFfCtrl = TextEditingController(text: '459');
  final _approvedSfCtrl = TextEditingController(text: '0');
  final _actualGfCtrl = TextEditingController(text: '65');
  final _actualFfCtrl = TextEditingController(text: '459');
  final _actualSfCtrl = TextEditingController(text: '0');
  final _estimateCostCtrl = TextEditingController(text: '1193150');
  final _costPerSqFtCtrl = TextEditingController(text: '2277 per sqft');
  bool _isEstimateReasonable = true;
  final _marketabilityCtrl = TextEditingController(text: 'Good');
  final _fsiCtrl = TextEditingController(text: '0.7');
  final _dwellingUnitsCtrl = TextEditingController(text: '1');
  bool _isConstructionAsPerPlan = true;
  final _deviationsCtrl = TextEditingController(text: 'NIL');
  final _deviationNatureCtrl = TextEditingController(text: 'Minor');
  bool _revisedApprovalNecessary = false;
  final _worksCompletedPercentageCtrl = TextEditingController(text: '0');
  final _worksCompletedValue = TextEditingController(text: '0');
  bool _adheresToSafety = true;
  bool _highTensionImpact = false;
  final _plinthApprovedCtrl = TextEditingController(text: '524');
  final _plinthActualCtrl = TextEditingController(text: '524');
  final _landValueAppCtrl = TextEditingController(text: '1043000');
  final _landValueGuideCtrl = TextEditingController(text: '47916');
  final _landValueMarketCtrl = TextEditingController(text: '1043000');
  final _buildingStageValueAppCtrl = TextEditingController(text: '0');
  final _buildingCompletionValueCtrl = TextEditingController(text: '2236150');
  final _marketValueSourceCtrl =
      TextEditingController(text: 'LOCAL MARKET ENQUIRY');
  final _buildingUsageCtrl = TextEditingController(text: 'RESIDENTIAL');
  final _recBackgroundCtrl = TextEditingController(text: 'SUBMITTED DOCUMENTS');
  final _recSourcesCtrl = TextEditingController(text: 'LOCAL MARKET ENQUIRY');
  final _recProceduresCtrl = TextEditingController(text: 'MARKET APPROACH');
  final _recMethodologyCtrl =
      TextEditingController(text: 'COMPARISON METHOD AND COST OF CONSTRUCTION');
  final _recFactorsCtrl =
      TextEditingController(text: 'AMENITIES AND ACCESSIBILITY');
  final _stageOfConstructionCtrl =
      TextEditingController(text: 'NOT YET STARTED');
  final _progressPercentageCtrl = TextEditingController(text: '0');
  final _certificatePlaceCtrl =
      TextEditingController(text: 'THIRUVANANTHAPURAM');
  final _annexLandAreaCtrl = TextEditingController(text: '2.98');
  final _annexLandUnitRateMarketCtrl = TextEditingController(text: '350000');
  final _annexLandUnitRateGuideCtrl = TextEditingController(text: '39600');
  final _annexGfAreaCtrl = TextEditingController(text: '393');
  final _annexGfUnitRateMarketCtrl = TextEditingController(text: '1000');
  final _annexGfUnitRateGuideCtrl = TextEditingController(text: '1000');
  final _annexFfAreaCtrl = TextEditingController(text: '0');
  final _annexFfUnitRateMarketCtrl = TextEditingController(text: '0');
  final _annexFfUnitRateGuideCtrl = TextEditingController(text: '0');
  final _annexSfAreaCtrl = TextEditingController(text: '0');
  final _annexSfUnitRateMarketCtrl = TextEditingController(text: '0');
  final _annexSfUnitRateGuideCtrl = TextEditingController(text: '0');
  final _annexAmenitiesMarketCtrl = TextEditingController(text: '0');
  final _annexAmenitiesGuideCtrl = TextEditingController(text: '0');
  final _annexYearOfConstructionCtrl = TextEditingController(text: '2025');
  final _annexBuildingAgeCtrl = TextEditingController(text: '15 AND 35 YEARS');
  final _natureOflandUse = TextEditingController(text: 'Others');
  final _buildingStageValueGuide = TextEditingController(text: '0');
  final _buildingStageValueMarket = TextEditingController(text: '0');

  bool _isNotValidState = false;

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

      final ownerName = _ownerNameCtrl.text ?? '[is null]';
      final marketValue = _landValueMarketCtrl.text ?? '[is null]';

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
        'bankName': 'LIC (PVR - 1)',
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
          _ownerNameCtrl.text.isEmpty ||
          _propertyLocationCtrl.text.isEmpty ||
          _landValueMarketCtrl.text.isEmpty) {
        debugPrint("not all field available");
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

      var request = http.MultipartRequest('POST', Uri.parse(url));

      // Add text fields
      request.fields.addAll({
        "valuerName": _valuerNameCtrl.text,
        "valuationCode": _valuerCodeCtrl.text,
        "inspectionDate": _inspectionDate.toString(),
        "fileNo": _fileNoCtrl.text,
        "applicantName": _applicantNameCtrl.text,
        "ownerName": _ownerNameCtrl.text,
        "documentsPerused": _documentsPerusedCtrl.text,
        "propertyLocation": _propertyLocationCtrl.text,
        "addressTallies": _addressTallies.toString(),
        "locationSketchVerified": _locationSketchVerified.toString(),
        "surroundingDevelopment": _surroundingDevCtrl.text,
        "basicAmenitiesAvailable": _basicAmenitiesAvailable.toString(),
        "negativesToLocality": _negativesToLocalityCtrl.text,
        "favorableConsiderations": _favorableConsiderationsCtrl.text,
        "nearbyLandmark": _nearbyLandmarkCtrl.text,
        "otherFeatures": _otherFeaturesCtrl.text,
        "northBoundary": _northBoundaryCtrl.text,
        "northDimension": _northDimCtrl.text,
        "southBoundary": _southBoundaryCtrl.text,
        "southDimension": _southDimCtrl.text,
        "eastBoundary": _eastBoundaryCtrl.text,
        "eastDimension": _eastDimCtrl.text,
        "westBoundary": _westBoundaryCtrl.text,
        "westDimension": _westDimCtrl.text,
        "totalExtent1": _totalExtent1Ctrl.text,
        "totalExtent2": _totalExtent2Ctrl.text,
        "boundariesTally": _boundariesTally.toString(),
        "existingLandUse": _existingLandUseCtrl.text,
        "proposedLandUse": _proposedLandUseCtrl.text,
        "naPermissionRequired": _naPermissionRequired.toString(),
        "approvalNo": _approvalNoCtrl.text,
        "validityPeriod": _validityPeriodCtrl.text,
        "isValidityExpiredRenewed": _isValidityExpiredRenewed.toString(),
        "approvalAuthority": _approvalAuthorityCtrl.text,
        "approvedGF": _approvedGfCtrl.text,
        "approvedFF": _approvedFfCtrl.text,
        "approvedSF": _approvedSfCtrl.text,
        "actualGF": _actualGfCtrl.text,
        "actualFF": _actualFfCtrl.text,
        "actualSF": _actualSfCtrl.text,
        "estimateCost": _estimateCostCtrl.text,
        "costPerSqFt": _costPerSqFtCtrl.text,
        "isEstimateReasonable": _isEstimateReasonable.toString(),
        "marketability": _marketabilityCtrl.text,
        "fsi": _fsiCtrl.text,
        "dwellingUnits": _dwellingUnitsCtrl.text,
        "isConstructionAsPerPlan": _isConstructionAsPerPlan.toString(),
        "deviations": _deviationsCtrl.text,
        "deviationNature": _deviationNatureCtrl.text,
        "revisedApprovalNecessary": _revisedApprovalNecessary.toString(),
        "worksCompletedPercentage": _worksCompletedPercentageCtrl.text,
        "worksCompletedValue": _worksCompletedValue.text,
        "adheresToSafety": _adheresToSafety.toString(),
        "highTensionImpact": _highTensionImpact.toString(),
        "plinthApproved": _plinthApprovedCtrl.text,
        "plinthActual": _plinthActualCtrl.text,
        "landValueApp": _landValueAppCtrl.text,
        "landValueGuide": _landValueGuideCtrl.text,
        "landValueMarket": _landValueMarketCtrl.text,
        "buildingStageValueApp": _buildingStageValueAppCtrl.text,
        "buildingCompletionValue": _buildingCompletionValueCtrl.text,
        "marketValueSource": _marketValueSourceCtrl.text,
        "buildingUsage": _buildingUsageCtrl.text,
        "recBackground": _recBackgroundCtrl.text,
        "recSources": _recSourcesCtrl.text,
        "recProcedures": _recProceduresCtrl.text,
        "recMethodology": _recMethodologyCtrl.text,
        "recFactors": _recFactorsCtrl.text,
        "stageOfConstruction": _stageOfConstructionCtrl.text,
        "progressPercentage": _progressPercentageCtrl.text,
        "certificatePlace": _certificatePlaceCtrl.text,
        "annexLandArea": _annexLandAreaCtrl.text,
        "annexLandUnitRateMarket": _annexLandUnitRateMarketCtrl.text,
        "annexLandUnitRateGuide": _annexLandUnitRateGuideCtrl.text,
        "annexGFArea": _annexGfAreaCtrl.text,
        "annexGFUnitRateMarket": _annexGfUnitRateMarketCtrl.text,
        "annexGFUnitRateGuide": _annexGfUnitRateGuideCtrl.text,
        "annexFFArea": _annexFfAreaCtrl.text,
        "annexFFUnitRateMarket": _annexFfUnitRateMarketCtrl.text,
        "annexFFUnitRateGuide": _annexFfUnitRateGuideCtrl.text,
        "annexSFArea": _annexSfAreaCtrl.text,
        "annexSFUnitRateMarket": _annexSfUnitRateMarketCtrl.text,
        "annexSFUnitRateGuide": _annexSfUnitRateGuideCtrl.text,
        "annexAmenitiesMarket": _annexAmenitiesMarketCtrl.text,
        "annexAmenitiesGuide": _annexAmenitiesGuideCtrl.text,
        "annexYearOfConstruction": _annexYearOfConstructionCtrl.text,
        "annexBuildingAge": _annexBuildingAgeCtrl.text,
        "natureOfLandUse": _natureOflandUse.text,
        "buildingStageValueGuide": _buildingStageValueGuide.text,
        "buildingStageValueMarket": _buildingStageValueMarket.text,
      });

      // Handle the image upload - works for both File and Uint8List

      /* final image = _valuationImages[0];
      final imageBytes = image.imageFile is File
          ? await (image.imageFile as File).readAsBytes()
          : image.imageFile;

      request.files.add(http.MultipartFile.fromBytes(
        'image', // Matches Multer's field name
        imageBytes,
        filename: 'property_${_fileNoCtrl.text}.jpg',
      ));

      debugPrint(image.latitude); */

      List<Map<String, String>> imageMetadata = [];

      for (int i = 0; i < _valuationImages.length; i++) {
        final image = _valuationImages[i];
        final imageBytes = image.imageFile is File
            ? await (image.imageFile as File).readAsBytes()
            : image.imageFile;

        request.files.add(http.MultipartFile.fromBytes(
          'images', // Field name for array of images
          imageBytes,
          filename: 'property_${_fileNoCtrl.text}_$i.jpg',
        ));

        imageMetadata.add({
          "latitude": image.latitude.toString(),
          "longitude": image.longitude.toString(),
        });

        request.fields['images'] = jsonEncode(imageMetadata);
      }

      final response = await request.send();

      debugPrint("send req to back");

      if (context.mounted) Navigator.of(context).pop();
      // debugPrint("${response.statusCode}");
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Data saved successfully!')));
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

  Future<String> _getAccessToken() async {
    final response = await http.post(
      Uri.parse('https://oauth2.googleapis.com/token'),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'client_id': clientId,
        'client_secret': clientSecret,
        'refresh_token': refreshToken,
        'grant_type': 'refresh_token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['access_token'] as String;
    } else {
      throw Exception('Failed to refresh access token');
    }
  }

  String _getMimeTypeFromExtension(String extension) {
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
  }

  Future<Uint8List> fetchImageFromDrive(String fileId) async {
    try {
      // Get access token using refresh token
      final accessToken = await _getAccessToken();

      final response = await http.get(
        Uri.parse(
            'https://www.googleapis.com/drive/v3/files/$fileId?alt=media'),
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        throw Exception('Failed to load image: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching image from Drive: $e');
    }
  }

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
      _valuerCodeCtrl.text =
          data["valuationCode"].toString() ?? _valuerCodeCtrl.text;
      _valuerNameCtrl.text =
          data['valuerName'].toString() ?? _valuerNameCtrl.text;
      _fileNoCtrl.text = data['fileNo']?.toString() ?? _fileNoCtrl.text;
      _applicantNameCtrl.text =
          data['applicantName'] ?? _applicantNameCtrl.text;
      _ownerNameCtrl.text = data['ownerName'] ?? _ownerNameCtrl.text;
      _documentsPerusedCtrl.text =
          data['documentsPerused'] ?? _documentsPerusedCtrl.text;
      _propertyLocationCtrl.text =
          data['propertyLocation'] ?? _propertyLocationCtrl.text;

      // Boolean fields
      _addressTallies = data['addressTallies'] as bool? ?? _addressTallies;
      _locationSketchVerified =
          data['locationSketchVerified'] as bool? ?? _locationSketchVerified;
      _basicAmenitiesAvailable =
          data['basicAmenitiesAvailable'] as bool? ?? _basicAmenitiesAvailable;
      _boundariesTally = data['boundariesTally'] as bool? ?? _boundariesTally;
      _naPermissionRequired =
          data['naPermissionRequired'] as bool? ?? _naPermissionRequired;
      _isValidityExpiredRenewed = data['isValidityExpiredRenewed'] as bool? ??
          _isValidityExpiredRenewed;
      _isEstimateReasonable =
          data['isEstimateReasonable'] as bool? ?? _isEstimateReasonable;
      _isConstructionAsPerPlan =
          data['isConstructionAsPerPlan'] as bool? ?? _isConstructionAsPerPlan;
      _revisedApprovalNecessary = data['revisedApprovalNecessary'] as bool? ??
          _revisedApprovalNecessary;
      _adheresToSafety = data['adheresToSafety'] as bool? ?? _adheresToSafety;
      _highTensionImpact =
          data['highTensionImpact'] as bool? ?? _highTensionImpact;

      // Text fields
      _surroundingDevCtrl.text =
          data['surroundingDev'] ?? _surroundingDevCtrl.text;
      _negativesToLocalityCtrl.text =
          data['negativesToLocality'] ?? _negativesToLocalityCtrl.text;
      _favorableConsiderationsCtrl.text =
          data['favorableConsiderations'] ?? _favorableConsiderationsCtrl.text;
      _nearbyLandmarkCtrl.text =
          data['nearbyLandmark'] ?? _nearbyLandmarkCtrl.text;
      _otherFeaturesCtrl.text =
          data['otherFeatures'] ?? _otherFeaturesCtrl.text;

      // Boundary fields
      _northBoundaryCtrl.text =
          data['northBoundary'] ?? _northBoundaryCtrl.text;
      _northDimCtrl.text = data['northDimension'] ?? _northDimCtrl.text;
      _southBoundaryCtrl.text =
          data['southBoundary'] ?? _southBoundaryCtrl.text;
      _southDimCtrl.text = data['southDimension'] ?? _southDimCtrl.text;
      _eastBoundaryCtrl.text = data['eastBoundary'] ?? _eastBoundaryCtrl.text;
      _eastDimCtrl.text = data['eastDimension'] ?? _eastDimCtrl.text;
      _westBoundaryCtrl.text = data['westBoundary'] ?? _westBoundaryCtrl.text;
      _westDimCtrl.text = data['westDimension'] ?? _westDimCtrl.text;

      // Land and building details
      _totalExtent1Ctrl.text =
          data['totalExtent1']?.toString() ?? _totalExtent1Ctrl.text;
      _totalExtent2Ctrl.text =
          data['totalExtent2']?.toString() ?? _totalExtent2Ctrl.text;
      _existingLandUseCtrl.text =
          data['existingLandUse'] ?? _existingLandUseCtrl.text;
      _proposedLandUseCtrl.text =
          data['proposedLandUse'] ?? _proposedLandUseCtrl.text;

      // Approval details
      _approvalNoCtrl.text = data['approvalNo'] ?? _approvalNoCtrl.text;
      _validityPeriodCtrl.text =
          data['validityPeriod'] ?? _validityPeriodCtrl.text;
      _approvalAuthorityCtrl.text =
          data['approvalAuthority'] ?? _approvalAuthorityCtrl.text;

      // Area fields
      _approvedGfCtrl.text =
          data['approvedGF']?.toString() ?? _approvedGfCtrl.text;
      _approvedFfCtrl.text =
          data['approvedFF']?.toString() ?? _approvedFfCtrl.text;
      _approvedSfCtrl.text =
          data['approvedSF']?.toString() ?? _approvedSfCtrl.text;
      _actualGfCtrl.text = data['actualGF']?.toString() ?? _actualGfCtrl.text;
      _actualFfCtrl.text = data['actualFF']?.toString() ?? _actualFfCtrl.text;
      _actualSfCtrl.text = data['actualSF']?.toString() ?? _actualSfCtrl.text;

      //Construction details
      _plinthApprovedCtrl.text =
          data['plinthApproved']?.toString() ?? _plinthApprovedCtrl.text;
      _plinthActualCtrl.text =
          data['plinthActual']?.toString() ?? _plinthActualCtrl.text;
      _fsiCtrl.text = data['fsi']?.toString() ?? _fsiCtrl.text;
      _dwellingUnitsCtrl.text =
          data['dwellingUnits']?.toString() ?? _dwellingUnitsCtrl.text;
      _deviationsCtrl.text =
          data['deviations']?.toString() ?? _deviationsCtrl.text;
      _deviationNatureCtrl.text =
          data['deviationNature']?.toString() ?? _deviationNatureCtrl.text;
      _stageOfConstructionCtrl.text = data['stageOfConstruction']?.toString() ??
          _stageOfConstructionCtrl.text;
      _progressPercentageCtrl.text = data['progressPercentage']?.toString() ??
          _progressPercentageCtrl.text;

      // Works Completed
      _worksCompletedPercentageCtrl.text =
          data['worksCompletedPercentage']?.toString() ??
              _worksCompletedPercentageCtrl.text;
      _worksCompletedValue.text =
          data['worksCompletedValue']?.toString() ?? _worksCompletedValue.text;

      _estimateCostCtrl.text =
          data['estimateCost']?.toString() ?? _estimateCostCtrl.text;
      _costPerSqFtCtrl.text =
          data['costPerSqFt']?.toString() ?? _costPerSqFtCtrl.text;
      _marketabilityCtrl.text =
          data['marketability']?.toString() ?? _marketabilityCtrl.text;

      // Value fields
      _landValueAppCtrl.text =
          data['landValueApp']?.toString() ?? _landValueAppCtrl.text;
      _landValueGuideCtrl.text =
          data['landValueGuide']?.toString() ?? _landValueGuideCtrl.text;
      _landValueMarketCtrl.text =
          data['landValueMarket']?.toString() ?? _landValueMarketCtrl.text;
      _buildingStageValueAppCtrl.text =
          data['buildingStageValueApp']?.toString() ??
              _buildingStageValueAppCtrl.text;
      _buildingStageValueGuide.text =
          data['buildingStageValueGuide']?.toString() ??
              _buildingStageValueGuide.text;
      _buildingStageValueMarket.text =
          data['buildingStageValueMarket']?.toString() ??
              _buildingStageValueMarket.text;
      _buildingCompletionValueCtrl.text =
          data['buildingCompletionValue']?.toString() ??
              _buildingCompletionValueCtrl.text;

      //Recomended fields
      _recBackgroundCtrl.text =
          data['recBackground']?.toString() ?? _recBackgroundCtrl.text;
      _recSourcesCtrl.text =
          data['recSources']?.toString() ?? _recSourcesCtrl.text;
      _recProceduresCtrl.text =
          data['recProcedures']?.toString() ?? _recProceduresCtrl.text;
      _recMethodologyCtrl.text =
          data['recMethodology']?.toString() ?? _recMethodologyCtrl.text;
      _recFactorsCtrl.text =
          data['recFactors']?.toString() ?? _recFactorsCtrl.text;

      // Other fields
      _marketValueSourceCtrl.text =
          data['marketValueSource'] ?? _marketValueSourceCtrl.text;
      _buildingUsageCtrl.text =
          data['buildingUsage'] ?? _buildingUsageCtrl.text;
      _certificatePlaceCtrl.text =
          data['certificatePlace'] ?? _certificatePlaceCtrl.text;

      // Annexure Details
      _annexLandAreaCtrl.text =
          data['annexLandArea']?.toString() ?? _annexLandAreaCtrl.text;
      _annexLandUnitRateMarketCtrl.text =
          data['annexLandUnitRateMarket']?.toString() ??
              _annexLandUnitRateMarketCtrl.text;
      _annexLandUnitRateGuideCtrl.text =
          data['annexLandUnitRateGuide']?.toString() ??
              _annexLandUnitRateGuideCtrl.text;
      _annexGfAreaCtrl.text =
          data['annexGFArea']?.toString() ?? _annexGfAreaCtrl.text;
      _annexGfUnitRateMarketCtrl.text =
          data['annexGFUnitRateMarket']?.toString() ??
              _annexGfUnitRateMarketCtrl.text;
      _annexGfUnitRateGuideCtrl.text =
          data['annexGFUnitRateGuide']?.toString() ??
              _annexGfUnitRateGuideCtrl.text;
      _annexFfAreaCtrl.text =
          data['annexFFArea']?.toString() ?? _annexFfAreaCtrl.text;
      _annexFfUnitRateMarketCtrl.text =
          data['annexFFUnitRateMarket']?.toString() ??
              _annexFfUnitRateMarketCtrl.text;
      _annexFfUnitRateGuideCtrl.text =
          data['annexFFUnitRateGuide']?.toString() ??
              _annexFfUnitRateGuideCtrl.text;
      _annexSfAreaCtrl.text =
          data['annexSFArea']?.toString() ?? _annexSfAreaCtrl.text;
      _annexSfUnitRateMarketCtrl.text =
          data['annexSFUnitRateMarket']?.toString() ??
              _annexSfUnitRateMarketCtrl.text;
      _annexSfUnitRateGuideCtrl.text =
          data['annexSFUnitRateGuide']?.toString() ??
              _annexSfUnitRateGuideCtrl.text;
      _annexAmenitiesMarketCtrl.text =
          data['annexAmenitiesMarket']?.toString() ??
              _annexAmenitiesMarketCtrl.text;
      _annexAmenitiesGuideCtrl.text = data['annexAmenitiesGuide']?.toString() ??
          _annexAmenitiesGuideCtrl.text;
      _annexYearOfConstructionCtrl.text =
          data['annexYearOfConstruction']?.toString() ??
              _annexYearOfConstructionCtrl.text;
      _annexBuildingAgeCtrl.text =
          data['annexBuildingAge']?.toString() ?? _annexBuildingAgeCtrl.text;

      try {
        if (data['images'] != null && data['images'] is List) {
          final List<dynamic> imagesData = data['images'];

          for (var imgData in imagesData) {
            try {
              // Get the file ID from your data (assuming it's stored as 'fileId')

              String fileName = imgData['fileName'];

              String signedUrl = await fetchSignedUrl(fileName);
              Uint8List imageBytes = await fetchImageBytes(signedUrl);

              _valuationImages.add(ValuationImage(
                imageFile: imageBytes,
                latitude: imgData['latitude']?.toString() ?? '',
                longitude: imgData['longitude']?.toString() ?? '',
              ));
            } catch (e) {
              debugPrint('Error loading image from Drive: $e');
            }
          }
        }
      } catch (e) {
        debugPrint('Error in fetchImages: $e');
      }

      if (mounted) setState(() {});

      // Date fields
      if (data['inspectionDate'] != null) {
        try {
          debugPrint(data['inspectionDate']);
          _inspectionDate = DateTime.parse(data['inspectionDate']);
        } catch (e) {
          debugPrint('Error parsing inspection date: $e');
        }
      }

      debugPrint('Form initialized with property data');
    } else {
      debugPrint('No property data - form will use default values');
    }
  }

  // --- LOCATION AND IMAGE PICKER LOGIC ---

  Future<void> _getCurrentLocation(int imageIndex) async {
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
        _valuationImages[imageIndex].latitude = position.latitude.toString();
        _valuationImages[imageIndex].longitude = position.longitude.toString();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error getting location: $e")),
      );
    }
  }

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
  // Inside _ValuationFormScreenPVR1State

  Future<void> _pickImage(ImageSource source) async {
    try {
      if (source == ImageSource.gallery) {
        final pickedFiles = await _picker.pickMultiImage();
        if (pickedFiles.isNotEmpty) {
          for (var file in pickedFiles) {
            // Read the bytes from the picked file
            final bytes = await file.readAsBytes();
            // Add the bytes to your list, not the file object
            _valuationImages.add(ValuationImage(imageFile: bytes));
          }
          setState(() {}); // Update the UI
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
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Photo Library'),
                onTap: () {
                  _pickImage(ImageSource.gallery);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Camera'),
                onTap: () {
                  _pickImage(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _generatePdf() {
    if (_formKey.currentState!.validate()) {
      final data = ValuationDataPVR1(
        nearbyLatitude: _nearbyLatitude.text,
        nearbyLongitude: _nearbyLongitude.text,
        worksCompletedValue: _worksCompletedValue.text,
        buildingStageValueMarket: _buildingStageValueMarket.text,
        buildingStageValueGuide: _buildingStageValueGuide.text,
        natureOfLandUse: _natureOflandUse.text,
        valuerName: _valuerNameCtrl.text,
        valuerCode: _valuerCodeCtrl.text,
        inspectionDate: _inspectionDate,
        fileNo: _fileNoCtrl.text,
        applicantName: _applicantNameCtrl.text,
        ownerName: _ownerNameCtrl.text,
        documentsPerused: _documentsPerusedCtrl.text,
        propertyLocation: _propertyLocationCtrl.text,
        addressTallies: _addressTallies,
        locationSketchVerified: _locationSketchVerified,
        surroundingDev: _surroundingDevCtrl.text,
        negativesToLocality: _negativesToLocalityCtrl.text,
        favorableConsiderations: _favorableConsiderationsCtrl.text,
        nearbyLandmark: _nearbyLandmarkCtrl.text,
        otherFeatures: _otherFeaturesCtrl.text,
        basicAmenitiesAvailable: _basicAmenitiesAvailable,
        northBoundary: _northBoundaryCtrl.text,
        southBoundary: _southBoundaryCtrl.text,
        eastBoundary: _eastBoundaryCtrl.text,
        westBoundary: _westBoundaryCtrl.text,
        northDim: _northDimCtrl.text,
        southDim: _southDimCtrl.text,
        eastDim: _eastDimCtrl.text,
        westDim: _westDimCtrl.text,
        totalExtent1: _totalExtent1Ctrl.text,
        totalExtent2: _totalExtent2Ctrl.text,
        boundariesTally: _boundariesTally,
        existingLandUse: _existingLandUseCtrl.text,
        proposedLandUse: _proposedLandUseCtrl.text,
        naPermissionRequired: _naPermissionRequired,
        approvalNo: _approvalNoCtrl.text,
        validityPeriod: _validityPeriodCtrl.text,
        approvalAuthority: _approvalAuthorityCtrl.text,
        isValidityExpiredRenewed: _isValidityExpiredRenewed,
        approvedGf: _approvedGfCtrl.text,
        approvedFf: _approvedFfCtrl.text,
        approvedSf: _approvedSfCtrl.text,
        actualGf: _actualGfCtrl.text,
        actualFf: _actualFfCtrl.text,
        actualSf: _actualSfCtrl.text,
        estimateCost: _estimateCostCtrl.text,
        costPerSqFt: _costPerSqFtCtrl.text,
        isEstimateReasonable: _isEstimateReasonable,
        marketability: _marketabilityCtrl.text,
        fsi: _fsiCtrl.text,
        dwellingUnits: _dwellingUnitsCtrl.text,
        isConstructionAsPerPlan: _isConstructionAsPerPlan,
        deviations: _deviationsCtrl.text,
        deviationNature: _deviationNatureCtrl.text,
        revisedApprovalNecessary: _revisedApprovalNecessary,
        worksCompletedPercentage: _worksCompletedPercentageCtrl.text,
        adheresToSafety: _adheresToSafety,
        highTensionImpact: _highTensionImpact,
        plinthApproved: _plinthApprovedCtrl.text,
        plinthActual: _plinthActualCtrl.text,
        landValueApp: _landValueAppCtrl.text,
        landValueGuide: _landValueGuideCtrl.text,
        landValueMarket: _landValueMarketCtrl.text,
        buildingStageValueApp: _buildingStageValueAppCtrl.text,
        buildingCompletionValue: _buildingCompletionValueCtrl.text,
        marketValueSource: _marketValueSourceCtrl.text,
        buildingUsage: _buildingUsageCtrl.text,
        recBackground: _recBackgroundCtrl.text,
        recSources: _recSourcesCtrl.text,
        recProcedures: _recProceduresCtrl.text,
        recMethodology: _recMethodologyCtrl.text,
        recFactors: _recFactorsCtrl.text,
        stageOfConstruction: _stageOfConstructionCtrl.text,
        progressPercentage: _progressPercentageCtrl.text,
        certificateDate: DateTime.now(),
        certificatePlace: _certificatePlaceCtrl.text,
        annexLandArea: _annexLandAreaCtrl.text,
        annexLandUnitRateMarket: _annexLandUnitRateMarketCtrl.text,
        annexLandUnitRateGuide: _annexLandUnitRateGuideCtrl.text,
        annexGfArea: _annexGfAreaCtrl.text,
        annexGfUnitRateMarket: _annexGfUnitRateMarketCtrl.text,
        annexGfUnitRateGuide: _annexGfUnitRateGuideCtrl.text,
        annexFfArea: _annexFfAreaCtrl.text,
        annexFfUnitRateMarket: _annexFfUnitRateMarketCtrl.text,
        annexFfUnitRateGuide: _annexFfUnitRateGuideCtrl.text,
        annexSfArea: _annexSfAreaCtrl.text,
        annexSfUnitRateMarket: _annexSfUnitRateMarketCtrl.text,
        annexSfUnitRateGuide: _annexSfUnitRateGuideCtrl.text,
        annexAmenitiesMarket: _annexAmenitiesMarketCtrl.text,
        annexAmenitiesGuide: _annexAmenitiesGuideCtrl.text,
        annexYearOfConstruction: _annexYearOfConstructionCtrl.text,
        annexBuildingAge: _annexBuildingAgeCtrl.text,
        images: _valuationImages,
      );
      Printing.layoutPdf(
        onLayout: (PdfPageFormat format) => PdfGeneratorPVR1(data).generate(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PVR 1 - House Construction'),
        backgroundColor: Colors.blue,
      ),
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
                  right: 50, left: 50, top: 10, bottom: 10),
              child: FloatingActionButton.extended(
                icon: const Icon(Icons.search),
                label: const Text('Search Saved Drafts'),
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (ctx) {
                    return const SavedDrafts();
                  }));
                },
              ),
            ),
            _buildSection(title: 'Header', initiallyExpanded: true, children: [
              TextFormField(
                  controller: _valuerNameCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Name of the Panel Valuer')),
              TextFormField(
                  controller: _valuerCodeCtrl,
                  decoration: const InputDecoration(labelText: 'Code No.')),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text("Date of Inspection"),
                subtitle:
                    Text(DateFormat('dd-MM-yyyy').format(_inspectionDate)),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                      context: context,
                      initialDate: _inspectionDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100));
                  if (picked != null) setState(() => _inspectionDate = picked);
                },
              ),
            ]),
            _buildSection(title: 'A. GENERAL', children: [
              TextFormField(
                  controller: _fileNoCtrl,
                  decoration: const InputDecoration(labelText: '1. File No.')),
              TextFormField(
                  controller: _applicantNameCtrl,
                  decoration: const InputDecoration(
                      labelText: '2. Name of the Applicant')),
              TextFormField(
                  controller: _ownerNameCtrl,
                  decoration:
                      const InputDecoration(labelText: '3. Name of the owner')),
              TextFormField(
                  controller: _documentsPerusedCtrl,
                  decoration: const InputDecoration(
                      labelText: '4. Documents produced for perusal')),
              TextFormField(
                  controller: _propertyLocationCtrl,
                  decoration: const InputDecoration(
                      labelText:
                          '5. Location of the property : Plot No./ S. No./C.T.S.No. /R.S.No.Village/Block No./ Taluk/Ward.District/Corporation/Municipality'),
                  maxLines: 4),
              SwitchListTile(
                  title: const Text(
                      '6. Whether address tallies with site with point number 5?'),
                  value: _addressTallies,
                  onChanged: (v) => setState(() => _addressTallies = v)),
              SwitchListTile(
                  title: const Text('7. Is Location Sketch Verified'),
                  value: _locationSketchVerified,
                  onChanged: (v) =>
                      setState(() => _locationSketchVerified = v)),
              TextFormField(
                  controller: _surroundingDevCtrl,
                  decoration: const InputDecoration(
                      labelText:
                          '8. Development of surrounding area with Special reference to population')),
              SwitchListTile(
                  title: const Text('9. Basic amenities available?'),
                  value: _basicAmenitiesAvailable,
                  onChanged: (v) =>
                      setState(() => _basicAmenitiesAvailable = v)),
              TextFormField(
                  controller: _negativesToLocalityCtrl,
                  decoration: const InputDecoration(
                      labelText: '10. Any negatives to the locality?')),
              TextFormField(
                  controller: _favorableConsiderationsCtrl,
                  decoration: const InputDecoration(
                      labelText:
                          '11. Any favorable consideration for additional cost/value?')),
              TextFormField(
                  controller: _nearbyLandmarkCtrl,
                  decoration: const InputDecoration(
                      labelText: '12. Details of the Nearby Landmark')),
              TextFormField(
                  controller: _otherFeaturesCtrl,
                  decoration: const InputDecoration(
                      labelText:
                          '13. Any other features like board of other financier indicating mortgage, notice of Court/any authority which may effect the security?')),
            ]),
            _buildSection(title: 'B. LAND', children: [
              TextFormField(
                  controller: _northBoundaryCtrl,
                  decoration:
                      const InputDecoration(labelText: 'North Boundary')),
              TextFormField(
                  controller: _northDimCtrl,
                  decoration:
                      const InputDecoration(labelText: 'North Dimension')),
              TextFormField(
                  controller: _southBoundaryCtrl,
                  decoration:
                      const InputDecoration(labelText: 'South Boundary')),
              TextFormField(
                  controller: _southDimCtrl,
                  decoration:
                      const InputDecoration(labelText: 'South Dimension')),
              TextFormField(
                  controller: _eastBoundaryCtrl,
                  decoration:
                      const InputDecoration(labelText: 'East Boundary')),
              TextFormField(
                  controller: _eastDimCtrl,
                  decoration:
                      const InputDecoration(labelText: 'East Dimension')),
              TextFormField(
                  controller: _westBoundaryCtrl,
                  decoration:
                      const InputDecoration(labelText: 'West Boundary')),
              TextFormField(
                  controller: _westDimCtrl,
                  decoration:
                      const InputDecoration(labelText: 'West Dimension')),
              TextFormField(
                  controller: _totalExtent1Ctrl,
                  decoration:
                      const InputDecoration(labelText: 'Total Extent 1')),
              TextFormField(
                  controller: _totalExtent2Ctrl,
                  decoration:
                      const InputDecoration(labelText: 'Total Extent 2')),
              SwitchListTile(
                  title: const Text(
                      '2. Do boundaries Tally with Approved Drawing?'),
                  value: _boundariesTally,
                  onChanged: (v) => setState(() => _boundariesTally = v)),
              TextFormField(
                  controller: _natureOflandUse,
                  decoration:
                      const InputDecoration(labelText: 'Nature of Land Use')),
              TextFormField(
                controller: _existingLandUseCtrl,
                decoration:
                    const InputDecoration(labelText: '3a. Existing Land Use'),
                maxLines: 4,
              ),
              TextFormField(
                  controller: _proposedLandUseCtrl,
                  decoration:
                      const InputDecoration(labelText: '3b. Proposed Land Use'),
                  maxLines: 4),
              SwitchListTile(
                  title: const Text('4. Whether N.A. Permission Required'),
                  value: _naPermissionRequired,
                  onChanged: (v) => setState(() => _naPermissionRequired = v)),
            ]),
            _buildSection(title: 'C. BUILDINGS', children: [
              TextFormField(
                  controller: _approvalNoCtrl,
                  decoration: const InputDecoration(
                      labelText:
                          '1. Layout planning approval No./Planning Permit No/Building Permission No')),
              TextFormField(
                  controller: _validityPeriodCtrl,
                  decoration: const InputDecoration(
                      labelText: '1.ii Period of validity')),
              SwitchListTile(
                  title: const Text(
                      '1.iii If validity is expired, is it renewed?'),
                  value: _isValidityExpiredRenewed,
                  onChanged: (v) =>
                      setState(() => _isValidityExpiredRenewed = v)),
              TextFormField(
                  controller: _approvalAuthorityCtrl,
                  decoration: const InputDecoration(
                      labelText: '1.iv Approval was given by (authority)')),
              TextFormField(
                  controller: _approvedGfCtrl,
                  decoration: const InputDecoration(
                      labelText: '2.i Approved G.F. Area')),
              TextFormField(
                  controller: _approvedFfCtrl,
                  decoration: const InputDecoration(
                      labelText: '2.i Approved F.F. Area')),
              TextFormField(
                  controller: _approvedSfCtrl,
                  decoration: const InputDecoration(
                      labelText: '2.i Approved S.F. Area')),
              TextFormField(
                  controller: _actualGfCtrl,
                  decoration: const InputDecoration(
                      labelText: '2.ii Actual G.F. Area')),
              TextFormField(
                  controller: _actualFfCtrl,
                  decoration: const InputDecoration(
                      labelText: '2.ii Actual F.F. Area')),
              TextFormField(
                  controller: _actualSfCtrl,
                  decoration: const InputDecoration(
                      labelText: '2.ii Actual S.F. Area')),
              TextFormField(
                  controller: _estimateCostCtrl,
                  decoration: const InputDecoration(
                      labelText: '3.i Estimate Cost (Rs)')),
              TextFormField(
                  controller: _costPerSqFtCtrl,
                  decoration:
                      const InputDecoration(labelText: '3.ii Cost per Sq ft')),
              SwitchListTile(
                  title: const Text('3.iii Is estimate reasonable?'),
                  value: _isEstimateReasonable,
                  onChanged: (v) => setState(() => _isEstimateReasonable = v)),
              TextFormField(
                  controller: _marketabilityCtrl,
                  decoration: const InputDecoration(
                      labelText: '4. Marketability of the Property')),
            ]),
            _buildSection(title: 'D. INSPECTION', children: [
              TextFormField(
                  controller: _plinthApprovedCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Plinth/Built Up Area (Approved)')),
              TextFormField(
                  controller: _plinthActualCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Plinth/Built Up Area (Actual)')),
              TextFormField(
                  controller: _fsiCtrl,
                  decoration: const InputDecoration(labelText: 'F.S.I.')),
              TextFormField(
                  controller: _dwellingUnitsCtrl,
                  decoration: const InputDecoration(
                      labelText: 'No. Of dwelling units')),
              SwitchListTile(
                  title: const Text('Construction as per plan?'),
                  value: _isConstructionAsPerPlan,
                  onChanged: (v) =>
                      setState(() => _isConstructionAsPerPlan = v)),
              TextFormField(
                  controller: _deviationsCtrl,
                  decoration: const InputDecoration(
                      labelText:
                          'Deviations between approved drawing & actual?')),
              TextFormField(
                  controller: _deviationNatureCtrl,
                  decoration: const InputDecoration(
                      labelText:
                          'Whether deviations are of minor/ major nature?')),
              SwitchListTile(
                  title: const Text('Whether revised approval is necessary?'),
                  value: _revisedApprovalNecessary,
                  onChanged: (v) =>
                      setState(() => _revisedApprovalNecessary = v)),
              TextFormField(
                  controller: _worksCompletedPercentageCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Total works completed %')),
              TextFormField(
                  controller: _worksCompletedValue,
                  decoration:
                      const InputDecoration(labelText: 'Total works value')),
              SwitchListTile(
                  title: const Text('Construction Adheres to Safety Specs?'),
                  value: _adheresToSafety,
                  onChanged: (v) => setState(() => _adheresToSafety = v)),
              SwitchListTile(
                  title: const Text(
                      'Any High Tension Wire Lines are passing through the property?'),
                  value: _highTensionImpact,
                  onChanged: (v) => setState(() => _highTensionImpact = v)),
            ]),
            _buildSection(title: 'E. TOTAL VALUE', children: [
              TextFormField(
                  controller: _landValueAppCtrl,
                  decoration: const InputDecoration(
                      labelText: '1. Value of land (as per Application)')),
              TextFormField(
                  controller: _landValueGuideCtrl,
                  decoration: const InputDecoration(
                      labelText: '1. Value of land (Guideline)')),
              TextFormField(
                  controller: _landValueMarketCtrl,
                  decoration: const InputDecoration(
                      labelText: '1. Value of land (Market)')),
              TextFormField(
                  controller: _buildingStageValueAppCtrl,
                  decoration: const InputDecoration(
                      labelText: '2. Stage value of building (Applicant)')),
              TextFormField(
                  controller: _buildingStageValueAppCtrl,
                  decoration: const InputDecoration(
                      labelText:
                          '2. Stage value of building (Guideline Value)')),
              TextFormField(
                  controller: _buildingStageValueAppCtrl,
                  decoration: const InputDecoration(
                      labelText: '2. Stage value of building (Market Value)')),
              TextFormField(
                  controller: _buildingCompletionValueCtrl,
                  decoration: const InputDecoration(
                      labelText: '4. Value of building on completion')),
              TextFormField(
                  controller: _marketValueSourceCtrl,
                  decoration: const InputDecoration(
                      labelText: '5. Source for arriving at Market Value')),
              TextFormField(
                  controller: _buildingUsageCtrl,
                  decoration:
                      const InputDecoration(labelText: '6. Usage of building')),
            ]),
            _buildSection(title: 'F. RECOMMENDATION', children: [
              TextFormField(
                  controller: _recBackgroundCtrl,
                  decoration: const InputDecoration(
                      labelText:
                          '1. Background information of the asset being valued')),
              TextFormField(
                  controller: _recSourcesCtrl,
                  decoration: const InputDecoration(
                      labelText:
                          '2. Sources of information used for valuation of property')),
              TextFormField(
                  controller: _recProceduresCtrl,
                  decoration: const InputDecoration(
                      labelText:
                          '3. Procedures adopted carrying out valuation')),
              TextFormField(
                  controller: _recMethodologyCtrl,
                  decoration: const InputDecoration(
                      labelText: '4. Valuation methodology')),
              TextFormField(
                  controller: _recFactorsCtrl,
                  decoration: const InputDecoration(
                      labelText:
                          '5. Major factors that influenced the valuation')),
            ]),
            _buildSection(title: 'Stage of Construction (Table)', children: [
              TextFormField(
                  controller: _stageOfConstructionCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Stage of Construction')),
              TextFormField(
                  controller: _progressPercentageCtrl,
                  decoration: const InputDecoration(labelText: '% Progress')),
            ]),
            _buildSection(title: 'G. CERTIFICATE', children: [
              TextFormField(
                  controller: _certificatePlaceCtrl,
                  decoration:
                      const InputDecoration(labelText: 'Station/Place')),
            ]),
            _buildSection(
                title: 'ANNEXURE (Valuation of Existing Building)',
                children: [
                  TextFormField(
                      controller: _annexLandAreaCtrl,
                      decoration:
                          const InputDecoration(labelText: 'Land Area')),
                  TextFormField(
                      controller: _annexLandUnitRateMarketCtrl,
                      decoration: const InputDecoration(
                          labelText: 'Land Unit Rate (Market)')),
                  TextFormField(
                      controller: _annexLandUnitRateGuideCtrl,
                      decoration: const InputDecoration(
                          labelText: 'Land Unit Rate (Guide)')),
                  TextFormField(
                      controller: _annexGfAreaCtrl,
                      decoration: const InputDecoration(labelText: 'GF Area')),
                  TextFormField(
                      controller: _annexGfUnitRateMarketCtrl,
                      decoration: const InputDecoration(
                          labelText: 'GF Unit Rate (Market)')),
                  TextFormField(
                      controller: _annexGfUnitRateGuideCtrl,
                      decoration: const InputDecoration(
                          labelText: 'GF Unit Rate (Guide)')),
                  TextFormField(
                      controller: _annexFfAreaCtrl,
                      decoration: const InputDecoration(labelText: 'FF Area')),
                  TextFormField(
                      controller: _annexFfUnitRateMarketCtrl,
                      decoration: const InputDecoration(
                          labelText: 'FF Unit Rate (Market)')),
                  TextFormField(
                      controller: _annexFfUnitRateGuideCtrl,
                      decoration: const InputDecoration(
                          labelText: 'FF Unit Rate (Guide)')),
                  TextFormField(
                      controller: _annexSfAreaCtrl,
                      decoration: const InputDecoration(labelText: 'SF Area')),
                  TextFormField(
                      controller: _annexSfUnitRateMarketCtrl,
                      decoration: const InputDecoration(
                          labelText: 'SF Unit Rate (Market)')),
                  TextFormField(
                      controller: _annexSfUnitRateGuideCtrl,
                      decoration: const InputDecoration(
                          labelText: 'SF Unit Rate (Guide)')),
                  TextFormField(
                      controller: _annexAmenitiesMarketCtrl,
                      decoration: const InputDecoration(
                          labelText: 'Amenities (Market)')),
                  TextFormField(
                      controller: _annexAmenitiesGuideCtrl,
                      decoration: const InputDecoration(
                          labelText: 'Amenities (Guide)')),
                  TextFormField(
                      controller: _annexYearOfConstructionCtrl,
                      decoration: const InputDecoration(
                          labelText: 'Year of Construction')),
                  TextFormField(
                      controller: _annexBuildingAgeCtrl,
                      decoration: const InputDecoration(
                          labelText: 'Age of Building and future life')),
                ]),
            _buildSection(
              title: "Images & Location",
              initiallyExpanded: true,
              children: [
                Center(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.add_a_photo),
                    label: const Text('Add Images'),
                    onPressed: _showImagePickerOptions,
                  ),
                ),
                if (_valuationImages.isNotEmpty)
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _valuationImages.length,
                    itemBuilder: (context, index) {
                      final valuationImage = _valuationImages[index];
                      final latController =
                          TextEditingController(text: valuationImage.latitude);
                      final lonController =
                          TextEditingController(text: valuationImage.longitude);

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Stack(
                                children: [
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
                                            _valuationImages.removeAt(index)),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: latController,
                                      readOnly: false,
                                      decoration: const InputDecoration(
                                          labelText: 'Latitude',
                                          border: OutlineInputBorder()),
                                      onChanged: (value) =>
                                          valuationImage.latitude = value,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: TextFormField(
                                      controller: lonController,
                                      readOnly: true,
                                      decoration: const InputDecoration(
                                          labelText: 'Longitude',
                                          border: OutlineInputBorder()),
                                      onChanged: (value) =>
                                          valuationImage.longitude = value,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              ElevatedButton.icon(
                                icon: const Icon(Icons.my_location),
                                label: const Text('Get Current Location'),
                                onPressed: () => _getCurrentLocation(index),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 50, right: 50, top: 10),
              child: FloatingActionButton.extended(
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text('Generate PDF'),
                  onPressed: () {
                    _generatePdf();
                  }),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
          icon: const Icon(Icons.save),
          label: const Text('Save data'),
          onPressed: () {
            _saveData();
          }),
    );
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
