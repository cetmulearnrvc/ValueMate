import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:login_screen/screens/IDBI/savedDraftsIDBI.dart';
import 'package:login_screen/screens/nearbyDetails.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'valuation_data_model.dart';
import 'pdf_generator.dart';
import 'package:http/http.dart' as http;
import 'config.dart';

class ValuationFormScreenIDBI extends StatefulWidget {
  final Map<String, dynamic>? propertyData;

  const ValuationFormScreenIDBI({super.key, this.propertyData});

  @override
  _ValuationFormScreenState createState() => _ValuationFormScreenState();
}

class _ValuationFormScreenState extends State<ValuationFormScreenIDBI> {
  final _formKey = GlobalKey<FormState>();
  final _data = ValuationData();
  final _picker = ImagePicker();

  late final Map<String, TextEditingController> _controllers;

  late final List<ValuationImage> _valuationImages = [];
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
    _initializeControllers();
    _initializeFormWithPropertyData();
  }

  void _initializeControllers() {
    _controllers = {
      'nearbyLatitude': TextEditingController(),

      'nearbyLongitude': TextEditingController(),

      'valuerNameAndQuals': TextEditingController(
        text: _data.valuerNameAndQuals,
      ),
      'valuerCredentials': TextEditingController(text: _data.valuerCredentials),
      'valuerAddressLine1': TextEditingController(
        text: _data.valuerAddressLine1,
      ),
      'valuerMob': TextEditingController(text: _data.valuerMob),
      'valuerEmail': TextEditingController(text: _data.valuerEmail),

      'bankName': TextEditingController(text: _data.bankName),
      'branchName': TextEditingController(text: _data.branchName),
      'caseType': TextEditingController(text: _data.caseType),
      'applicationNo': TextEditingController(text: _data.applicationNo),
      'titleHolderName': TextEditingController(text: _data.titleHolderName),
      'borrowerName': TextEditingController(text: _data.borrowerName),
      'landTaxReceiptNo': TextEditingController(text: _data.landTaxReceiptNo),
      'possessionCertNo': TextEditingController(text: _data.possessionCertNo),
      'locationSketchNo': TextEditingController(text: _data.locationSketchNo),
      'thandaperAbstractNo': TextEditingController(
        text: _data.thandaperAbstractNo,
      ),
      'approvedLayoutPlanNo': TextEditingController(
        text: _data.approvedLayoutPlanNo,
      ),
      'approvedBuildingPlanNo': TextEditingController(
        text: _data.approvedBuildingPlanNo,
      ),
      'briefDescription': TextEditingController(text: _data.briefDescription),
      'locationAndLandmark': TextEditingController(
        text: _data.locationAndLandmark,
      ),
      'reSyNo': TextEditingController(text: _data.reSyNo),
      'blockNo': TextEditingController(text: _data.blockNo),
      'village': TextEditingController(text: _data.village),
      'taluk': TextEditingController(text: _data.taluk),
      'district': TextEditingController(text: _data.district),
      'state': TextEditingController(text: _data.state),
      'postOffice': TextEditingController(text: _data.postOffice),
      'pinCode': TextEditingController(text: _data.pinCode),
      'postalAddress': TextEditingController(text: _data.postalAddress),
      'northAsPerSketch': TextEditingController(text: _data.northAsPerSketch),
      'northActual': TextEditingController(text: _data.northActual),
      'southAsPerSketch': TextEditingController(text: _data.southAsPerSketch),
      'southActual': TextEditingController(text: _data.southActual),
      'eastAsPerSketch': TextEditingController(text: _data.eastAsPerSketch),
      'eastActual': TextEditingController(text: _data.eastActual),
      'westAsPerSketch': TextEditingController(text: _data.westAsPerSketch),
      'westActual': TextEditingController(text: _data.westActual),
      'localAuthority': TextEditingController(text: _data.localAuthority),
      'plotDemarcated': TextEditingController(text: _data.plotDemarcated),
      'natureOfProperty': TextEditingController(text: _data.natureOfProperty),
      'classOfProperty': TextEditingController(text: _data.classOfProperty),
      'topographicalCondition': TextEditingController(
        text: _data.topographicalCondition,
      ),
      'approvedLandUse': TextEditingController(text: _data.approvedLandUse),
      'fourWheelerAccessibility': TextEditingController(
        text: _data.fourWheelerAccessibility,
      ),
      'occupiedBy': TextEditingController(text: _data.occupiedBy),
      'yearsOfOccupancy': TextEditingController(text: _data.yearsOfOccupancy),
      'ownerRelationship': TextEditingController(text: _data.ownerRelationship),
      'areaOfLand': TextEditingController(text: _data.areaOfLand),
      'plinthArea': TextEditingController(),
      'carpetArea': TextEditingController(),
      'saleableArea': TextEditingController(text: _data.saleableArea),
      'landExtent': TextEditingController(text: _data.landExtent),
      'landRatePerCent': TextEditingController(text: _data.landRatePerCent),
      'landTotalValue': TextEditingController(text: _data.landTotalValue),
      'landMarketValue': TextEditingController(text: _data.landMarketValue),
      'landRealizableValue': TextEditingController(
        text: _data.landRealizableValue,
      ),
      'landDistressValue': TextEditingController(text: _data.landDistressValue),
      'landFairValue': TextEditingController(text: _data.landFairValue),
      'grandTotalMarketValue': TextEditingController(
        text: _data.grandTotalMarketValue,
      ),
      'grandTotalRealizableValue': TextEditingController(
        text: _data.grandTotalRealizableValue,
      ),
      'grandTotalDistressValue': TextEditingController(
        text: _data.grandTotalDistressValue,
      ),
      'declarationPlace': TextEditingController(text: _data.declarationPlace),
      'valuerName': TextEditingController(text: _data.valuerName),
      'valuerAddress': TextEditingController(text: _data.valuerAddress),

      // Add this block to your _controllers map in initState
      'buildingNo': TextEditingController(text: _data.buildingNo),
      'approvingAuthority': TextEditingController(
        text: _data.approvingAuthority,
      ),
      'stageOfConstruction': TextEditingController(
        text: _data.stageOfConstruction,
      ),
      'typeOfStructure': TextEditingController(text: _data.typeOfStructure),
      'noOfFloors': TextEditingController(text: _data.noOfFloors),
      'livingDiningRooms': TextEditingController(text: _data.livingDiningRooms),
      'bedrooms': TextEditingController(text: _data.bedrooms),
      'toilets': TextEditingController(text: _data.toilets),
      'kitchen': TextEditingController(text: _data.kitchen),
      'typeOfFlooring': TextEditingController(text: _data.typeOfFlooring),
      'ageOfBuilding': TextEditingController(text: _data.ageOfBuilding),
      'residualLife': TextEditingController(text: _data.residualLife),
      'violationObserved': TextEditingController(text: _data.violationObserved),

      // ADD THIS BLOCK TO YOUR _controllers MAP IN initState
      'buildingPlinth': TextEditingController(text: _data.buildingPlinth),
      'buildingRatePerSqft': TextEditingController(
        text: _data.buildingRatePerSqft,
      ),
      'buildingTotalValue': TextEditingController(
        text: _data.buildingTotalValue,
      ),
      'buildingMarketValue': TextEditingController(
        text: _data.buildingMarketValue,
      ),
      'buildingRealizableValue': TextEditingController(
        text: _data.buildingRealizableValue,
      ),
      'buildingDistressValue': TextEditingController(
        text: _data.buildingDistressValue,
      ),
      'remarks': TextEditingController(),
      // 'images': TextEditingController(),
    };
    _data.inspectionDate = DateTime(2024, 8, 7);
    _data.declarationDate = DateTime(2024, 12, 2);
  }

  bool _isNotValidState = false;

  @override
  void dispose() {
    _controllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }

  Future<void> _getNearbyProperty() async {
    final latitude = _controllers['nearbyLatitude']!.text.trim();
    final longitude = _controllers['nearbyLongitude']!.text.trim();

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

      final ownerName = _controllers['titleHolderName']!.text ?? '[is null]';
      final marketValue = _controllers['landMarketValue']!.text ?? '[is null]';

      debugPrint('------------------------------------------');
      debugPrint('DEBUGGING SAVE TO NEARBY COLLECTION:');
      debugPrint('Owner Name from Controller: "$ownerName"');
      debugPrint('Market Value from Controller: "$marketValue"');
      debugPrint('------------------------------------------');
      // --- STEP 3: Build the payload with the correct data ---
      final dataToSave = {
        // Use the coordinates from the image we found
        'refNo': _controllers['applicationNo']!.text ?? '',
        'latitude': firstImageWithLocation.latitude,
        'longitude': firstImageWithLocation.longitude,

        'landValue': marketValue, // Use the variable we just created
        'nameOfOwner': ownerName,
        'bankName': 'IDBI Bank',
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
      if (_controllers['applicationNo']!.text.isEmpty) {
        debugPrint("Application number missing");
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please fill Application number')));
        setState(() => _isNotValidState = true);
        return;
      }

      if (_valuationImages.isEmpty) {
        debugPrint("No images available");
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

      // Add text fields
      request.fields.addAll({
        // Valuer Information
        "valuerNameAndQuals": _controllers['valuerNameAndQuals']!.text,
        "valuerCredentials": _controllers['valuerCredentials']!.text,
        "valuerAddressLine1": _controllers['valuerAddressLine1']!.text,
        "valuerMob": _controllers['valuerMob']!.text,
        "valuerEmail": _controllers['valuerEmail']!.text,

        // Bank Information
        "bankName": _controllers['bankName']!.text,
        "branchName": _controllers['branchName']!.text,

        // General Information
        "caseType": _controllers['caseType']!.text,
        "inspectionDate": _data.inspectionDate.toString(),
        "applicationNo": _controllers['applicationNo']!.text,
        "titleHolderName": _controllers['titleHolderName']!.text,
        "borrowerName": _controllers['borrowerName']!.text,

        // Documents Verified
        "landTaxReceiptNo": _controllers['landTaxReceiptNo']!.text,
        "possessionCertNo": _controllers['possessionCertNo']!.text,
        "locationSketchNo": _controllers['locationSketchNo']!.text,
        "thandaperAbstractNo": _controllers['thandaperAbstractNo']!.text,
        "approvedLayoutPlanNo": _controllers['approvedLayoutPlanNo']!.text,
        "approvedBuildingPlanNo": _controllers['approvedBuildingPlanNo']!.text,

        // Property Description
        "briefDescription": _controllers['briefDescription']!.text,
        "locationAndLandmark": _controllers['locationAndLandmark']!.text,

        // Property Location Details
        "reSyNo": _controllers['reSyNo']!.text,
        "blockNo": _controllers['blockNo']!.text,
        "village": _controllers['village']!.text,
        "taluk": _controllers['taluk']!.text,
        "district": _controllers['district']!.text,
        "state": _controllers['state']!.text,
        "postOffice": _controllers['postOffice']!.text,
        "pinCode": _controllers['pinCode']!.text,
        "postalAddress": _controllers['postalAddress']!.text,

        // Boundary Details
        "northAsPerSketch": _controllers['northAsPerSketch']!.text,
        "northActual": _controllers['northActual']!.text,
        "southAsPerSketch": _controllers['southAsPerSketch']!.text,
        "southActual": _controllers['southActual']!.text,
        "eastAsPerSketch": _controllers['eastAsPerSketch']!.text,
        "eastActual": _controllers['eastActual']!.text,
        "westAsPerSketch": _controllers['westAsPerSketch']!.text,
        "westActual": _controllers['westActual']!.text,

        // Property Characteristics
        "localAuthority": _controllers['localAuthority']!.text,
        "plotDemarcated": _controllers['plotDemarcated']!.text,
        "natureOfProperty": _controllers['natureOfProperty']!.text,
        "classOfProperty": _controllers['classOfProperty']!.text,
        "topographicalCondition": _controllers['topographicalCondition']!.text,
        "approvedLandUse": _controllers['approvedLandUse']!.text,
        "fourWheelerAccessibility":
            _controllers['fourWheelerAccessibility']!.text,
        "occupiedBy": _controllers['occupiedBy']!.text,
        "yearsOfOccupancy": _controllers['yearsOfOccupancy']!.text,
        "ownerRelationship": _controllers['ownerRelationship']!.text,

        // Area Details
        "areaOfLand": _controllers['areaOfLand']!.text,
        "plinthArea": _controllers['plinthArea']!.text,
        "carpetArea": _controllers['carpetArea']!.text,
        "saleableArea": _controllers['saleableArea']!.text,

        // Land Valuation
        "landExtent": _controllers['landExtent']!.text,
        "landRatePerCent": _controllers['landRatePerCent']!.text,
        "landTotalValue": _controllers['landTotalValue']!.text,
        "landMarketValue": _controllers['landMarketValue']!.text,
        "landRealizableValue": _controllers['landRealizableValue']!.text,
        "landDistressValue": _controllers['landDistressValue']!.text,
        "landFairValue": _controllers['landFairValue']!.text,

        // Building Valuation
        "buildingPlinth": _controllers['buildingPlinth']!.text,
        "buildingRatePerSqft": _controllers['buildingRatePerSqft']!.text,
        "buildingTotalValue": _controllers['buildingTotalValue']!.text,
        "buildingMarketValue": _controllers['buildingMarketValue']!.text,
        "buildingRealizableValue":
            _controllers['buildingRealizableValue']!.text,
        "buildingDistressValue": _controllers['buildingDistressValue']!.text,

        // Building Physical Details
        "buildingNo": _controllers['buildingNo']!.text,
        "approvingAuthority": _controllers['approvingAuthority']!.text,
        "stageOfConstruction": _controllers['stageOfConstruction']!.text,
        "typeOfStructure": _controllers['typeOfStructure']!.text,
        "noOfFloors": _controllers['noOfFloors']!.text,
        "livingDiningRooms": _controllers['livingDiningRooms']!.text,
        "bedrooms": _controllers['bedrooms']!.text,
        "toilets": _controllers['toilets']!.text,
        "kitchen": _controllers['kitchen']!.text,
        "typeOfFlooring": _controllers['typeOfFlooring']!.text,
        "ageOfBuilding": _controllers['ageOfBuilding']!.text,
        "residualLife": _controllers['residualLife']!.text,
        "violationObserved": _controllers['violationObserved']!.text,

        // Grand Totals
        "grandTotalMarketValue": _controllers['grandTotalMarketValue']!.text,
        "grandTotalRealizableValue":
            _controllers['grandTotalRealizableValue']!.text,
        "grandTotalDistressValue":
            _controllers['grandTotalDistressValue']!.text,

        // Declaration
        "declarationDate": _data.declarationDate.toString(),
        "declarationPlace": _controllers['declarationPlace']!.text,
        "valuerName": _controllers['valuerName']!.text,
        "valuerAddress": _controllers['valuerAddress']!.text,
        "remarks": _controllers['remarks']!.text,
      });

      // Handle the image upload
      List<Map<String, String>> imageMetadata = [];

      for (int i = 0; i < _valuationImages.length; i++) {
        final image = _valuationImages[i];
        final imageBytes = image.imageFile is File
            ? await (image.imageFile as File).readAsBytes()
            : image.imageFile;

        request.files.add(http.MultipartFile.fromBytes(
          'images', // Field name for array of images
          imageBytes,
          filename: 'property_${_data.applicationNo}_$i.jpg',
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
  //           'https://www.googleapis.com/drive/v3/files/$fileId?alt=media'),
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

      // Valuer Information
      _controllers['valuerNameAndQuals']!.text =
          data['valuerNameAndQuals']?.toString() ?? '';
      _controllers['valuerCredentials']!.text =
          data['valuerCredentials']?.toString() ?? '';
      _controllers['valuerAddressLine1']!.text =
          data['valuerAddressLine1']?.toString() ?? '';
      _controllers['valuerMob']!.text = data['valuerMob']?.toString() ?? '';
      _controllers['valuerEmail']!.text = data['valuerEmail']?.toString() ?? '';

      // Bank Information
      _controllers['bankName']!.text = data['bankName']?.toString() ?? '';
      _controllers['branchName']!.text = data['branchName']?.toString() ?? '';

      // General Information
      _controllers['caseType']!.text = data['caseType']?.toString() ?? '';
      if (data['inspectionDate'] != null) {
        _data.inspectionDate = DateTime.parse(data['inspectionDate']);
      }
      _controllers['applicationNo']!.text =
          data['applicationNo']?.toString() ?? '';
      _controllers['titleHolderName']!.text =
          data['titleHolderName']?.toString() ?? '';
      _controllers['borrowerName']!.text =
          data['borrowerName']?.toString() ?? '';

      // Documents Verified
      _controllers['landTaxReceiptNo']!.text =
          data['landTaxReceiptNo']?.toString() ?? '';
      _controllers['possessionCertNo']!.text =
          data['possessionCertNo']?.toString() ?? '';
      _controllers['locationSketchNo']!.text =
          data['locationSketchNo']?.toString() ?? '';
      _controllers['thandaperAbstractNo']!.text =
          data['thandaperAbstractNo']?.toString() ?? '';
      _controllers['approvedLayoutPlanNo']!.text =
          data['approvedLayoutPlanNo']?.toString() ?? '';
      _controllers['approvedBuildingPlanNo']!.text =
          data['approvedBuildingPlanNo']?.toString() ?? '';

      // Property Description
      _controllers['briefDescription']!.text =
          data['briefDescription']?.toString() ?? '';
      _controllers['locationAndLandmark']!.text =
          data['locationAndLandmark']?.toString() ?? '';

      // Property Location Details
      _controllers['reSyNo']!.text = data['reSyNo']?.toString() ?? '';
      _controllers['blockNo']!.text = data['blockNo']?.toString() ?? '';
      _controllers['village']!.text = data['village']?.toString() ?? '';
      _controllers['taluk']!.text = data['taluk']?.toString() ?? '';
      _controllers['district']!.text = data['district']?.toString() ?? '';
      _controllers['state']!.text = data['state']?.toString() ?? '';
      _controllers['postOffice']!.text = data['postOffice']?.toString() ?? '';
      _controllers['pinCode']!.text = data['pinCode']?.toString() ?? '';
      _controllers['postalAddress']!.text =
          data['postalAddress']?.toString() ?? '';

      // Boundary Details
      _controllers['northAsPerSketch']!.text =
          data['northAsPerSketch']?.toString() ?? '';
      _controllers['northActual']!.text = data['northActual']?.toString() ?? '';
      _controllers['southAsPerSketch']!.text =
          data['southAsPerSketch']?.toString() ?? '';
      _controllers['southActual']!.text = data['southActual']?.toString() ?? '';
      _controllers['eastAsPerSketch']!.text =
          data['eastAsPerSketch']?.toString() ?? '';
      _controllers['eastActual']!.text = data['eastActual']?.toString() ?? '';
      _controllers['westAsPerSketch']!.text =
          data['westAsPerSketch']?.toString() ?? '';
      _controllers['westActual']!.text = data['westActual']?.toString() ?? '';

      // Property Characteristics
      _controllers['localAuthority']!.text =
          data['localAuthority']?.toString() ?? '';
      _controllers['plotDemarcated']!.text =
          data['plotDemarcated']?.toString() ?? '';
      _controllers['natureOfProperty']!.text =
          data['natureOfProperty']?.toString() ?? '';
      _controllers['classOfProperty']!.text =
          data['classOfProperty']?.toString() ?? '';
      _controllers['topographicalCondition']!.text =
          data['topographicalCondition']?.toString() ?? '';
      _controllers['approvedLandUse']!.text =
          data['approvedLandUse']?.toString() ?? '';
      _controllers['fourWheelerAccessibility']!.text =
          data['fourWheelerAccessibility']?.toString() ?? '';
      _controllers['occupiedBy']!.text = data['occupiedBy']?.toString() ?? '';
      _controllers['yearsOfOccupancy']!.text =
          data['yearsOfOccupancy']?.toString() ?? '';
      _controllers['ownerRelationship']!.text =
          data['ownerRelationship']?.toString() ?? '';

      // Area Details
      _controllers['areaOfLand']!.text = data['areaOfLand']?.toString() ?? '';
      _controllers['plinthArea']!.text = data['plinthArea']?.toString() ?? '';
      _controllers['carpetArea']!.text = data['carpetArea']?.toString() ?? '';

      _controllers['saleableArea']!.text =
          data['saleableArea']?.toString() ?? '';

      // Land Valuation
      _controllers['landExtent']!.text = data['landExtent']?.toString() ?? '';
      _controllers['landRatePerCent']!.text =
          data['landRatePerCent']?.toString() ?? '';
      _controllers['landTotalValue']!.text =
          data['landTotalValue']?.toString() ?? '';
      _controllers['landMarketValue']!.text =
          data['landMarketValue']?.toString() ?? '';
      _controllers['landRealizableValue']!.text =
          data['landRealizableValue']?.toString() ?? '';
      _controllers['landDistressValue']!.text =
          data['landDistressValue']?.toString() ?? '';
      _controllers['landFairValue']!.text =
          data['landFairValue']?.toString() ?? '';

      // Building Valuation
      _controllers['buildingPlinth']!.text =
          data['buildingPlinth']?.toString() ?? '';
      _controllers['buildingRatePerSqft']!.text =
          data['buildingRatePerSqft']?.toString() ?? '';
      _controllers['buildingTotalValue']!.text =
          data['buildingTotalValue']?.toString() ?? '';
      _controllers['buildingMarketValue']!.text =
          data['buildingMarketValue']?.toString() ?? '';
      _controllers['buildingRealizableValue']!.text =
          data['buildingRealizableValue']?.toString() ?? '';
      _controllers['buildingDistressValue']!.text =
          data['buildingDistressValue']?.toString() ?? '';

      // Building Physical Details
      _controllers['buildingNo']!.text = data['buildingNo']?.toString() ?? '';
      _controllers['approvingAuthority']!.text =
          data['approvingAuthority']?.toString() ?? '';
      _controllers['stageOfConstruction']!.text =
          data['stageOfConstruction']?.toString() ?? '';
      _controllers['typeOfStructure']!.text =
          data['typeOfStructure']?.toString() ?? '';
      _controllers['noOfFloors']!.text = data['noOfFloors']?.toString() ?? '';
      _controllers['livingDiningRooms']!.text =
          data['livingDiningRooms']?.toString() ?? '';
      _controllers['bedrooms']!.text = data['bedrooms']?.toString() ?? '';
      _controllers['toilets']!.text = data['toilets']?.toString() ?? '';
      _controllers['kitchen']!.text = data['kitchen']?.toString() ?? '';
      _controllers['typeOfFlooring']!.text =
          data['typeOfFlooring']?.toString() ?? '';
      _controllers['ageOfBuilding']!.text =
          data['ageOfBuilding']?.toString() ?? '';
      _controllers['residualLife']!.text =
          data['residualLife']?.toString() ?? '';
      _controllers['violationObserved']!.text =
          data['violationObserved']?.toString() ?? '';

      // Grand Totals
      _controllers['grandTotalMarketValue']!.text =
          data['grandTotalMarketValue']?.toString() ?? '';
      _controllers['grandTotalRealizableValue']!.text =
          data['grandTotalRealizableValue']?.toString() ?? '';
      _controllers['grandTotalDistressValue']!.text =
          data['grandTotalDistressValue']?.toString() ?? '';
      _controllers['remarks']!.text = data['remarks']?.toString() ?? '';
      // Declaration
      if (data['declarationDate'] != null) {
        _data.declarationDate = DateTime.parse(data['declarationDate']);
      }
      _controllers['declarationPlace']!.text =
          data['declarationPlace']?.toString() ?? '';
      _controllers['valuerName']!.text = data['valuerName']?.toString() ?? '';
      _controllers['valuerAddress']!.text =
          data['valuerAddress']?.toString() ?? '';

      // Handle images if needed
      try {
        if (data['images'] != null && data['images'] is List) {
          final List<dynamic> imagesData = data['images'];
          for (var imgData in imagesData) {
            try {
              String fileName = imgData['fileName'];

              Uint8List imageBytes = await fetchImageBytes(fileName);

              _valuationImages.add(ValuationImage(
                imageFile: imageBytes,
                latitude: imgData['latitude']?.toString() ?? '',
                longitude: imgData['longitude']?.toString() ?? '',
              ));
            } catch (e) {
              debugPrint('Error loading image from Cloudina: $e');
            }
          }
        }
      } catch (e) {
        debugPrint('Error in fetchImages: $e');
      }

      if (mounted) setState(() {});
      debugPrint('New form initialized with property data');
    } else {
      debugPrint('No property data - new form will use default values');
    }
  }

  /// Replaces special characters that built-in PDF fonts can't handle.
  String _sanitizeString(String input) {
    // Replaces the special "en dash" with a standard hyphen.
    return input.replaceAll('–', '-');
  }

  Future<void> _getNearbyLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enable location services")),
      );
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Location permissions denied")),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Location permissions permanently denied")),
      );
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // This is the key difference: update the main controllers
      setState(() {
        _controllers['nearbyLatitude']!.text = position.latitude.toString();
        _controllers['nearbyLongitude']!.text = position.longitude.toString();
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error getting location: $e")),
      );
    }
  }

  Future<void> _getCurrentLocation(int imageIndex) async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Location services are disabled.")),
      );
      return;
    }
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Location permissions are denied.")),
        );
        return;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Location permissions are permanently denied."),
        ),
      );
      return;
    }
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _valuationImages[imageIndex].latitude = position.latitude.toString();
        _valuationImages[imageIndex].longitude = position.longitude.toString();
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error getting location: $e")));
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to pick images: $e')));
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
      // First, sanitize all text inputs to prevent font errors.
      _controllers.forEach((key, controller) {
        controller.text = _sanitizeString(controller.text);
      });

      _data.valuerNameAndQuals = _controllers['valuerNameAndQuals']!.text;
      _data.valuerCredentials = _controllers['valuerCredentials']!.text;
      _data.valuerAddressLine1 = _controllers['valuerAddressLine1']!.text;
      _data.valuerMob = _controllers['valuerMob']!.text;
      _data.valuerEmail = _controllers['valuerEmail']!.text;

      _data.images = _valuationImages;
      // Then, save the sanitized data from controllers back to the data model.
      _data.bankName = _controllers['bankName']!.text;
      _data.branchName = _controllers['branchName']!.text;
      _data.caseType = _controllers['caseType']!.text;
      _data.applicationNo = _controllers['applicationNo']!.text;
      _data.titleHolderName = _controllers['titleHolderName']!.text;
      _data.borrowerName = _controllers['borrowerName']!.text;
      _data.landTaxReceiptNo = _controllers['landTaxReceiptNo']!.text;
      _data.possessionCertNo = _controllers['possessionCertNo']!.text;
      _data.locationSketchNo = _controllers['locationSketchNo']!.text;
      _data.thandaperAbstractNo = _controllers['thandaperAbstractNo']!.text;
      _data.approvedLayoutPlanNo = _controllers['approvedLayoutPlanNo']!.text;
      _data.approvedBuildingPlanNo =
          _controllers['approvedBuildingPlanNo']!.text;
      _data.briefDescription = _controllers['briefDescription']!.text;
      _data.locationAndLandmark = _controllers['locationAndLandmark']!.text;
      _data.reSyNo = _controllers['reSyNo']!.text;
      _data.blockNo = _controllers['blockNo']!.text;
      _data.village = _controllers['village']!.text;
      _data.taluk = _controllers['taluk']!.text;
      _data.district = _controllers['district']!.text;
      _data.state = _controllers['state']!.text;
      _data.postOffice = _controllers['postOffice']!.text;
      _data.pinCode = _controllers['pinCode']!.text;
      _data.postalAddress = _controllers['postalAddress']!.text;
      _data.northAsPerSketch = _controllers['northAsPerSketch']!.text;
      _data.northActual = _controllers['northActual']!.text;
      _data.southAsPerSketch = _controllers['southAsPerSketch']!.text;
      _data.southActual = _controllers['southActual']!.text;
      _data.eastAsPerSketch = _controllers['eastAsPerSketch']!.text;
      _data.eastActual = _controllers['eastActual']!.text;
      _data.westAsPerSketch = _controllers['westAsPerSketch']!.text;
      _data.westActual = _controllers['westActual']!.text;
      _data.localAuthority = _controllers['localAuthority']!.text;
      _data.plotDemarcated = _controllers['plotDemarcated']!.text;
      _data.natureOfProperty = _controllers['natureOfProperty']!.text;
      _data.classOfProperty = _controllers['classOfProperty']!.text;
      _data.topographicalCondition =
          _controllers['topographicalCondition']!.text;
      _data.approvedLandUse = _controllers['approvedLandUse']!.text;
      _data.fourWheelerAccessibility =
          _controllers['fourWheelerAccessibility']!.text;
      _data.occupiedBy = _controllers['occupiedBy']!.text;
      _data.yearsOfOccupancy = _controllers['yearsOfOccupancy']!.text;
      _data.ownerRelationship = _controllers['ownerRelationship']!.text;
      _data.areaOfLand = _controllers['areaOfLand']!.text;
      _data.plinthArea = _controllers['plinthArea']!.text;
      _data.carpetArea = _controllers['carpetArea']!.text;
      _data.saleableArea = _controllers['saleableArea']!.text;
      _data.landExtent = _controllers['landExtent']!.text;
      _data.landRatePerCent = _controllers['landRatePerCent']!.text;
      _data.landTotalValue = _controllers['landTotalValue']!.text;
      _data.landMarketValue = _controllers['landMarketValue']!.text;
      _data.landRealizableValue = _controllers['landRealizableValue']!.text;
      _data.landDistressValue = _controllers['landDistressValue']!.text;
      _data.landFairValue = _controllers['landFairValue']!.text;
      _data.grandTotalMarketValue = _controllers['grandTotalMarketValue']!.text;
      _data.grandTotalRealizableValue =
          _controllers['grandTotalRealizableValue']!.text;
      _data.grandTotalDistressValue =
          _controllers['grandTotalDistressValue']!.text;
      _data.declarationPlace = _controllers['declarationPlace']!.text;
      _data.valuerName = _controllers['valuerName']!.text;
      _data.valuerAddress = _controllers['valuerAddress']!.text;

      // Add this block inside the _generatePdf method, with the other assignments.
      _data.buildingNo = _controllers['buildingNo']!.text;
      _data.approvingAuthority = _controllers['approvingAuthority']!.text;
      _data.stageOfConstruction = _controllers['stageOfConstruction']!.text;
      _data.typeOfStructure = _controllers['typeOfStructure']!.text;
      _data.noOfFloors = _controllers['noOfFloors']!.text;
      _data.livingDiningRooms = _controllers['livingDiningRooms']!.text;
      _data.bedrooms = _controllers['bedrooms']!.text;
      _data.toilets = _controllers['toilets']!.text;
      _data.kitchen = _controllers['kitchen']!.text;
      _data.typeOfFlooring = _controllers['typeOfFlooring']!.text;
      _data.ageOfBuilding = _controllers['ageOfBuilding']!.text;
      _data.residualLife = _controllers['residualLife']!.text;
      _data.violationObserved = _controllers['violationObserved']!.text;

      // ADD THIS BLOCK INSIDE THE _generatePdf METHOD
      _data.buildingPlinth = _controllers['buildingPlinth']!.text;
      _data.buildingRatePerSqft = _controllers['buildingRatePerSqft']!.text;
      _data.buildingTotalValue = _controllers['buildingTotalValue']!.text;
      _data.buildingMarketValue = _controllers['buildingMarketValue']!.text;
      _data.buildingRealizableValue =
          _controllers['buildingRealizableValue']!.text;
      _data.buildingDistressValue = _controllers['buildingDistressValue']!.text;
      _data.remarks = _controllers['remarks']!.text;
      Printing.layoutPdf(
        onLayout: (PdfPageFormat format) => PdfGenerator(_data).generate(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Valuation Report Input')),
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
                    _buildTextField(
                      'Latitude',
                      _controllers['nearbyLatitude']!,
                    ),
                    _buildTextField(
                      'Longitude',
                      _controllers['nearbyLongitude']!,
                    ),
                    const SizedBox(height: 8),
                    Center(
                        child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed:
                                    _getNearbyLocation, // Call our new method
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
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  top: 10, right: 50, left: 50, bottom: 10),
              child: FloatingActionButton.extended(
                icon: const Icon(Icons.search),
                label: const Text('Search Saved Drafts'),
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (ctx) {
                    return const SavedDraftsIDBI();
                  }));
                },
              ),
            ),
            _buildSection(
              title: 'Valuer Header Info',
              initiallyExpanded: true,
              children: [
                _buildTextField(
                  'Valuer Name & Qualifications',
                  _controllers['valuerNameAndQuals']!,
                ),
                _buildTextField(
                  'Valuer Credentials (multiline)',
                  _controllers['valuerCredentials']!,
                  maxLines: 3,
                ),
                _buildTextField(
                  'Valuer Address (Ushas Nivas...)',
                  _controllers['valuerAddressLine1']!,
                  maxLines: 2,
                ),
                _buildTextField('Mobile Number', _controllers['valuerMob']!),
                _buildTextField('Email Address', _controllers['valuerEmail']!),
              ],
            ),
            _buildSection(
              title: 'I. GENERAL',
              initiallyExpanded: true,
              children: [
                _buildTextField('Case type', _controllers['caseType']!),
                _buildDatePicker(
                  'Date of Inspection',
                  _data.inspectionDate!,
                  (date) => setState(() => _data.inspectionDate = date),
                ),
                _buildTextField(
                  'Application no.',
                  _controllers['applicationNo']!,
                ),
                _buildTextField(
                  'Name of the title holder',
                  _controllers['titleHolderName']!,
                ),
                _buildTextField(
                  'Name of the borrower',
                  _controllers['borrowerName']!,
                ),
                const SizedBox(height: 8),
                const Text(
                  "List of documents verified",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                _buildTextField(
                  'a) Land tax receipt no.',
                  _controllers['landTaxReceiptNo']!,
                ),
                _buildTextField(
                  'b) Possession certificate no.',
                  _controllers['possessionCertNo']!,
                ),
                _buildTextField(
                  'c) Location sketch no.',
                  _controllers['locationSketchNo']!,
                ),
                _buildTextField(
                  'd) Thandaper abstract no.',
                  _controllers['thandaperAbstractNo']!,
                ),
                _buildTextField(
                  'e) Approved Layout Plan no.',
                  _controllers['approvedLayoutPlanNo']!,
                ),
                _buildTextField(
                  'f) Approved Building Plan no.',
                  _controllers['approvedBuildingPlanNo']!,
                ),
              ],
            ),
            _buildSection(
              title: 'II. PHYSICAL DETAILS OF LAND',
              children: [
                _buildTextField(
                  '1. Brief description of the property',
                  _controllers['briefDescription']!,
                  maxLines: 5,
                ),
                _buildTextField(
                  '2. Location with nearest landmark',
                  _controllers['locationAndLandmark']!,
                  maxLines: 5,
                ),
                const SizedBox(height: 8),
                const Text(
                  "3. Details of land",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                _buildTextField('a) Re Sy. No.', _controllers['reSyNo']!),
                _buildTextField('b) Block no.', _controllers['blockNo']!),
                _buildTextField('c) Village', _controllers['village']!),
                _buildTextField('d) Taluk', _controllers['taluk']!),
                _buildTextField('e) District', _controllers['district']!),
                _buildTextField('f) State', _controllers['state']!),
                _buildTextField('g) Post office', _controllers['postOffice']!),
                _buildTextField('h) Pin code', _controllers['pinCode']!),
                _buildTextField(
                  'Postal address of the property',
                  _controllers['postalAddress']!,
                  maxLines: 5,
                ),
                const SizedBox(height: 8),
                const Text(
                  "4. Boundaries",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                _buildBoundaryRow(
                  "North",
                  _controllers['northAsPerSketch']!,
                  _controllers['northActual']!,
                ),
                _buildBoundaryRow(
                  "South",
                  _controllers['southAsPerSketch']!,
                  _controllers['southActual']!,
                ),
                _buildBoundaryRow(
                  "East",
                  _controllers['eastAsPerSketch']!,
                  _controllers['eastActual']!,
                ),
                _buildBoundaryRow(
                  "West",
                  _controllers['westAsPerSketch']!,
                  _controllers['westActual']!,
                ),
                _buildTextField(
                  '5. Local authority',
                  _controllers['localAuthority']!,
                ),
                SwitchListTile(
                  title: const Text('6. Property identified?'),
                  value: _data.isPropertyIdentified,
                  onChanged: (val) =>
                      setState(() => _data.isPropertyIdentified = val),
                ),
                _buildTextField(
                  '7. Plot demarcated',
                  _controllers['plotDemarcated']!,
                ),
                _buildTextField(
                  '8. Nature of property',
                  _controllers['natureOfProperty']!,
                ),
                _buildTextField(
                  '9. Class of property',
                  _controllers['classOfProperty']!,
                ),
                _buildTextField(
                  '10. Topographical condition',
                  _controllers['topographicalCondition']!,
                ),
                SwitchListTile(
                  title: const Text('11. Chance of acquisition?'),
                  value: _data.chanceOfAcquisition,
                  onChanged: (val) =>
                      setState(() => _data.chanceOfAcquisition = val),
                ),
                _buildTextField(
                  '12. Approved land used',
                  _controllers['approvedLandUse']!,
                ),
                _buildTextField(
                  '13. Four wheeler accessibility',
                  _controllers['fourWheelerAccessibility']!,
                ),
                _buildTextField(
                  '14 a) Occupied by Owner/Tenant',
                  _controllers['occupiedBy']!,
                ),
                _buildTextField(
                  '14 b) No. of years of occupancy',
                  _controllers['yearsOfOccupancy']!,
                ),
                _buildTextField(
                  '14 c) Relationship of owner & occupant',
                  _controllers['ownerRelationship']!,
                ),
              ],
            ),
            // In the build method's ListView, add this:
            _buildSection(
              title: 'II. PHYSICAL DETAILS OF BUILDING',
              children: [
                _buildTextField('1. Building no.', _controllers['buildingNo']!),
                _buildTextField(
                  '2. Approving authority of building plan',
                  _controllers['approvingAuthority']!,
                ),
                _buildTextField(
                  '3. Stage of construction (%)',
                  _controllers['stageOfConstruction']!,
                ),
                _buildTextField(
                  '4. Type of structure',
                  _controllers['typeOfStructure']!,
                ),
                _buildTextField(
                  '5. No. of floors',
                  _controllers['noOfFloors']!,
                ),
                const Text(
                  "6. No. of rooms",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        'Living/dining',
                        _controllers['livingDiningRooms']!,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildTextField(
                        'Bedrooms',
                        _controllers['bedrooms']!,
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        'Toilets',
                        _controllers['toilets']!,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildTextField(
                        'Kitchen',
                        _controllers['kitchen']!,
                      ),
                    ),
                  ],
                ),
                _buildTextField(
                  '7. Type of flooring',
                  _controllers['typeOfFlooring']!,
                ),
                _buildTextField(
                  '8. Age of the building',
                  _controllers['ageOfBuilding']!,
                ),
                _buildTextField(
                  '9. Residual life of the building',
                  _controllers['residualLife']!,
                ),
                _buildTextField(
                  '10. Violation if any observed',
                  _controllers['violationObserved']!,
                ),
              ],
            ),
            _buildSection(
              title: 'III. AREA DETAILS OF THE PROPERTY',
              children: [
                _buildTextField('1. Area of land', _controllers['areaOfLand']!),
                _buildTextField('2. Plinth area of proposed building',
                    _controllers['plinthArea']!),
                _buildTextField(
                    '3. Carpet area of building', _controllers['carpetArea']!),
                _buildTextField(
                  '4. Saleable area',
                  _controllers['saleableArea']!,
                ),
              ],
            ),
            _buildSection(
              title: 'VI. DETAILED VALUATION (LAND)',
              children: [
                _buildTextField('Extent', _controllers['landExtent']!),
                _buildTextField('Rate/Cent', _controllers['landRatePerCent']!),
                _buildTextField('Total', _controllers['landTotalValue']!),
                const Divider(),
                _buildTextField(
                  'Market value of land',
                  _controllers['landMarketValue']!,
                ),
                _buildTextField(
                  'Realizable value of land',
                  _controllers['landRealizableValue']!,
                ),
                _buildTextField(
                  'Distress value of land',
                  _controllers['landDistressValue']!,
                ),
                _buildTextField(
                  'Fair value of land',
                  _controllers['landFairValue']!,
                ),
              ],
            ),
            _buildSection(
              title: 'VI. DETAILED VALUATION (BUILDING)',
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        'Plinth Area',
                        _controllers['buildingPlinth']!,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildTextField(
                        'Rate/sqft',
                        _controllers['buildingRatePerSqft']!,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildTextField(
                        'Total',
                        _controllers['buildingTotalValue']!,
                      ),
                    ),
                  ],
                ),
                _buildTextField(
                  'Market value of building',
                  _controllers['buildingMarketValue']!,
                ),
                _buildTextField(
                  'Realizable value of building',
                  _controllers['buildingRealizableValue']!,
                ),
                _buildTextField(
                  'Distress value of proposed building',
                  _controllers['buildingDistressValue']!,
                ),
              ],
            ),
            _buildSection(
              title: 'GRAND TOTAL',
              children: [
                _buildTextField(
                  'Market value',
                  _controllers['grandTotalMarketValue']!,
                ),
                _buildTextField(
                  'Realizable value',
                  _controllers['grandTotalRealizableValue']!,
                ),
                _buildTextField(
                  'Distress value',
                  _controllers['grandTotalDistressValue']!,
                ),
              ],
            ),
            _buildSection(
              title: 'DECLARATION & FOOTER',
              children: [
                _buildDatePicker(
                  'Declaration Date',
                  _data.declarationDate!,
                  (date) => setState(() => _data.declarationDate = date),
                ),
                _buildTextField('Place', _controllers['declarationPlace']!),
                _buildTextField(
                  'Valuer Name & Quals',
                  _controllers['valuerName']!,
                ),
                _buildTextField(
                  'Valuer Address',
                  _controllers['valuerAddress']!,
                  maxLines: 3,
                ),
                _buildTextField(
                  'Remarks',
                  _controllers['remarks']!,
                  maxLines: 3,
                ),
              ],
            ),
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
                      final latController = TextEditingController(
                        text: valuationImage.latitude,
                      );
                      final lonController = TextEditingController(
                        text: valuationImage.longitude,
                      );
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Stack(
                                children: [
                                  Image.memory(
                                    valuationImage.imageFile,
                                    height: 150,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                  Positioned(
                                    right: 0,
                                    top: 0,
                                    child: CircleAvatar(
                                      radius: 18,
                                      backgroundColor: Colors.white70,
                                      child: IconButton(
                                        padding: EdgeInsets.zero,
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                        ),
                                        onPressed: () => setState(
                                          () =>
                                              _valuationImages.removeAt(index),
                                        ),
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
                                      decoration: const InputDecoration(
                                        labelText: 'Latitude',
                                        border: OutlineInputBorder(),
                                      ),
                                      onChanged: (value) =>
                                          valuationImage.latitude = value,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: TextFormField(
                                      controller: lonController,
                                      decoration: const InputDecoration(
                                        labelText: 'Longitude',
                                        border: OutlineInputBorder(),
                                      ),
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
              padding: const EdgeInsets.only(top: 10, right: 50, left: 50),
              child: FloatingActionButton.extended(
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text('Generate PDF'),
                onPressed: _generatePdf,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            icon: const Icon(Icons.save),
            label: const Text('Save'),
            onPressed: () {
              _saveData();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter a value';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDatePicker(
    String label,
    DateTime date,
    Function(DateTime) onDateChanged,
  ) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      subtitle: Text(DateFormat('dd-MM-yyyy').format(date)),
      trailing: const Icon(Icons.calendar_today),
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date,
          firstDate: DateTime(2000),
          lastDate: DateTime(2101),
        );
        if (picked != null && picked != date) {
          onDateChanged(picked);
        }
      },
    );
  }

  Widget _buildBoundaryRow(
    String label,
    TextEditingController sketchCtrl,
    TextEditingController actualCtrl,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          SizedBox(width: 50, child: Text(label)),
          const SizedBox(width: 10),
          Expanded(child: _buildTextField('As per sketch', sketchCtrl)),
          const SizedBox(width: 10),
          Expanded(child: _buildTextField('Actual', actualCtrl)),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
    bool initiallyExpanded = false,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ExpansionTile(
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        initiallyExpanded: initiallyExpanded,
        childrenPadding: const EdgeInsets.all(16),
        children: children,
      ),
    );
  }
}
