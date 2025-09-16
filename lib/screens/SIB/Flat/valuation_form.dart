// lib/valuation_form_sib.dart

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:login_screen/screens/SIB/Flat/config.dart';
import 'package:login_screen/screens/SIB/Flat/data_model.dart';
import 'package:login_screen/screens/SIB/Flat/pdf_generator.dart';
import 'package:login_screen/screens/SIB/Flat/savedDrafts.dart';
import 'package:login_screen/screens/nearbyDetails.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:path/path.dart' as path;
import 'package:login_screen/screens/driveAPIconfig.dart';

class SIBValuationFormScreen extends StatefulWidget {
  final Map<String, dynamic>? propertyData;

  const SIBValuationFormScreen({
    super.key,
    this.propertyData,
  });
  @override
  _SIBValuationFormScreenState createState() => _SIBValuationFormScreenState();
}

class _SIBValuationFormScreenState extends State<SIBValuationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final SIBValuationData _data = SIBValuationData();
  final _picker = ImagePicker();

  late final Map<String, TextEditingController> _controllers;
  late List<ValuationImage> _valuationImages;
  late List<ValuationDetailItem> _valuationDetails;

  @override
  void initState() {
    super.initState();
    _valuationImages = _data.images;
    _valuationDetails = _data.valuationDetails;
    _controllers = _initializeControllers();
    _initializeFormWithPropertyData();
  }

  Map<String, TextEditingController> _initializeControllers() {
    return {
      'nearbyLatitude': TextEditingController(),
      'nearbyLongitude': TextEditingController(),
      'valuerName': TextEditingController(text: _data.valuerName),
      'valuerQualifications':
          TextEditingController(text: _data.valuerQualifications),
      'valuerRegInfo': TextEditingController(text: _data.valuerRegInfo),
      'valuerAddress': TextEditingController(text: _data.valuerAddress),
      'valuerContact': TextEditingController(text: _data.valuerContact),
      'valuerEmail': TextEditingController(text: _data.valuerEmail),
      'refNo': TextEditingController(text: _data.refNo),
      'bankName': TextEditingController(text: _data.bankName),
      'branchName': TextEditingController(text: _data.branchName),
      'branchAddress': TextEditingController(text: _data.branchAddress),
      'purposeOfValuation':
          TextEditingController(text: _data.purposeOfValuation),
      'docLandTaxReceipt': TextEditingController(text: _data.docLandTaxReceipt),
      'docTitleDeed': TextEditingController(text: _data.docTitleDeed),
      'docBuildingCertificate':
          TextEditingController(text: _data.docBuildingCertificate),
      'docLocationSketch': TextEditingController(text: _data.docLocationSketch),
      'docPossessionCertificate':
          TextEditingController(text: _data.docPossessionCertificate),
      'docBuildingCompletionPlan':
          TextEditingController(text: _data.docBuildingCompletionPlan),
      'docThandapperDocument':
          TextEditingController(text: _data.docThandapperDocument),
      'docBuildingTaxReceipt':
          TextEditingController(text: _data.docBuildingTaxReceipt),
      'nameOfOwner': TextEditingController(text: _data.nameOfOwner),
      'nameOfApplicant': TextEditingController(text: _data.nameOfApplicant),
      'addressAsPerDocuments':
          TextEditingController(text: _data.addressAsPerDocuments),
      'addressAsPerActual':
          TextEditingController(text: _data.addressAsPerActual),
      'deviations': TextEditingController(text: _data.deviations),
      'propertyTypeLeaseholdFreehold':
          TextEditingController(text: _data.propertyTypeLeaseholdFreehold),
      'propertyZone': TextEditingController(text: _data.propertyZone),
      'classificationAreaHighMiddlePoor':
          TextEditingController(text: _data.classificationAreaHighMiddlePoor),
      'classificationAreaUrbanSemiRural':
          TextEditingController(text: _data.classificationAreaUrbanSemiRural),
      'comingUnder': TextEditingController(text: _data.comingUnder),
      'coveredUnderGovtEnactments':
          TextEditingController(text: _data.coveredUnderGovtEnactments),
      'isAgriculturalLand':
          TextEditingController(text: _data.isAgriculturalLand),
      'natureOfApartment': TextEditingController(text: _data.natureOfApartment),
      'yearOfConstruction':
          TextEditingController(text: _data.yearOfConstruction),
      'numFloorsActuals': TextEditingController(text: _data.numFloorsActuals),
      'numFloorsApproved': TextEditingController(text: _data.numFloorsApproved),
      'numUnitsActuals': TextEditingController(text: _data.numUnitsActuals),
      'numUnitsApproved': TextEditingController(text: _data.numUnitsApproved),
      'deviationsActuals': TextEditingController(text: _data.deviationsActuals),
      'deviationsApproved':
          TextEditingController(text: _data.deviationsApproved),
      'roadWidth': TextEditingController(text: _data.roadWidth),
      'reraNoAndDate': TextEditingController(text: _data.reraNoAndDate),
      'typeOfStructure': TextEditingController(text: _data.typeOfStructure),
      'ageOfBuilding': TextEditingController(text: _data.ageOfBuilding),
      'residualAge': TextEditingController(text: _data.residualAge),
      'maintenanceOfBuilding':
          TextEditingController(text: _data.maintenanceOfBuilding),
      'facilitiesLift': TextEditingController(text: _data.facilitiesLift),
      'facilitiesWater': TextEditingController(text: _data.facilitiesWater),
      'facilitiesSewerage':
          TextEditingController(text: _data.facilitiesSewerage),
      'facilitiesCarParking':
          TextEditingController(text: _data.facilitiesCarParking),
      'facilitiesCompoundWall':
          TextEditingController(text: _data.facilitiesCompoundWall),
      'facilitiesPavement':
          TextEditingController(text: _data.facilitiesPavement),
      'facilitiesExtraAmenities':
          TextEditingController(text: _data.facilitiesExtraAmenities),
      'flatFloor': TextEditingController(text: _data.flatFloor),
      'flatDoorNo': TextEditingController(text: _data.flatDoorNo),
      'specRoof': TextEditingController(text: _data.specRoof),
      'specFlooring': TextEditingController(text: _data.specFlooring),
      'specDoors': TextEditingController(text: _data.specDoors),
      'specWindows': TextEditingController(text: _data.specWindows),
      'specFittings': TextEditingController(text: _data.specFittings),
      'specFinishing': TextEditingController(text: _data.specFinishing),
      'electricityConnectionNo':
          TextEditingController(text: _data.electricityConnectionNo),
      'meterCardName': TextEditingController(text: _data.meterCardName),
      'flatMaintenance': TextEditingController(text: _data.flatMaintenance),
      'saleDeedName': TextEditingController(text: _data.saleDeedName),
      'undividedLandArea': TextEditingController(text: _data.undividedLandArea),
      'flatArea': TextEditingController(text: _data.flatArea),
      'flatClass': TextEditingController(text: _data.flatClass),
      'flatUsage': TextEditingController(text: _data.flatUsage),
      'flatOccupancy': TextEditingController(text: _data.flatOccupancy),
      'flatMonthlyRent': TextEditingController(text: _data.flatMonthlyRent),
      'rateComparable': TextEditingController(text: _data.rateComparable),
      'rateNewConstruction':
          TextEditingController(text: _data.rateNewConstruction),
      'rateGuideline': TextEditingController(text: _data.rateGuideline),
      'remarks1': TextEditingController(text: _data.remarks1),
      'remarks2': TextEditingController(text: _data.remarks2),
      'remarks3': TextEditingController(text: _data.remarks3),
      'remarks4': TextEditingController(text: _data.remarks4),
      'valuationApproach': TextEditingController(text: _data.valuationApproach),
      'presentMarketValue':
          TextEditingController(text: _data.presentMarketValue),
      'realizableValue': TextEditingController(text: _data.realizableValue),
      'distressValue': TextEditingController(text: _data.distressValue),
      'insurableValue': TextEditingController(text: _data.insurableValue),
      'finalValuationPlace':
          TextEditingController(text: _data.finalValuationPlace),
      'p7background': TextEditingController(text: _data.p7background),
      'p7purpose': TextEditingController(text: _data.p7purpose),
      'p7identity': TextEditingController(text: _data.p7identity),
      'p7disclosure': TextEditingController(text: _data.p7disclosure),
      'p7dates': TextEditingController(text: _data.p7dates),
      'p7inspections': TextEditingController(text: _data.p7inspections),
      'p7nature': TextEditingController(text: _data.p7nature),
      'p7procedures': TextEditingController(text: _data.p7procedures),
      'p7restrictions': TextEditingController(text: _data.p7restrictions),
      'p7majorFactors1': TextEditingController(text: _data.p7majorFactors1),
      'p7majorFactors2': TextEditingController(text: _data.p7majorFactors2),
      'p7caveats': TextEditingController(text: _data.p7caveats),
      'p7reportPlace': TextEditingController(text: _data.p7reportPlace),
    };
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
  //       Uri.parse('https://www.googleapis.com/drive/v3/files/$fileId?alt=media'),
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
    print('PROPERTY DATA: ${widget.propertyData}');
    if (widget.propertyData != null) {
      final data = widget.propertyData!;

      // Loop over all controllers and set values if present in data
      _controllers.forEach((key, controller) {
        if (data.containsKey(key) && data[key] != null) {
          controller.text = data[key].toString();
        }
      });
      print(data['images']);
      _loadInitialImages(data);
      // Initialize images if available
      //
      print('Valuation : ${data['valuationDetails']}');
      setState(() {
        if (data.containsKey('valuationDetails') &&
            data['valuationDetails'] is List) {
          var detailsList = data['valuationDetails'] as List;
          debugPrint(
              "Received valuation details list with ${detailsList.length} items.");
          debugPrint("Raw list content: $detailsList");
          detailsList = detailsList
              .where((item) => item != null && item is Map<String, dynamic>)
              .toList();

          debugPrint(
              "Filtered valuation details list with ${detailsList.length} valid items.");

          _valuationDetails = (data['valuationDetails'] as List)
              .map((item) => ValuationDetailItem(
                    description: item['description'] ?? '',
                    area: item['area'] ?? '',
                    ratePerUnit: item['ratePerUnit'] ?? '',
                    estimatedValue: item['estimatedValue'] ?? '',
                  ))
              .toList();
        }
      });

      // Initialize date fields safely
      if (data['dateOfInspection'] != null) {
        try {
          _data.dateOfInspection = DateTime.parse(data['dateOfInspection']);
        } catch (e) {
          debugPrint('Invalid dateOfInspection: $e');
        }
      }

      if (data['dateOfValuation'] != null) {
        try {
          _data.dateOfValuation = DateTime.parse(data['dateOfValuation']);
        } catch (e) {
          debugPrint('Invalid dateOfValuation: $e');
        }
      }

      print('dateOfInspection: ${_data.dateOfInspection}');
      print('dateOfValuation: ${_data.dateOfValuation}');

      if (data['finalValuationDate'] != null) {
        try {
          _data.finalValuationDate = DateTime.parse(data['finalValuationDate']);
        } catch (e) {
          debugPrint('Invalid finalValuationDate: $e');
        }
      }

      if (data['p7reportDate'] != null) {
        try {
          _data.p7reportDate = DateTime.parse(data['p7reportDate']);
        } catch (e) {
          debugPrint('Invalid p7reportDate: $e');
        }
      }

      debugPrint('Form initialized with SIB property data');
    } else {
      debugPrint('No property data - using default values');
    }
  }

  Future<void> _loadInitialImages(Map<String, dynamic> data) async {
    final List<ValuationImage> loadedImages = [];
    try {
      if (data['images'] != null && data['images'] is List) {
        final List<dynamic> imagesData = data['images'];

        for (var imgData in imagesData) {
          try {
            // Get the file ID from your data (assuming it's stored as 'fileId')

            String fileName = imgData['fileName'];

            Uint8List imageBytes = await fetchImageBytes(fileName);

            // // Get file extension from original filename
            // String extension = path.extension(fileName).toLowerCase();
            // if (extension.isEmpty) extension = '.jpg'; // default fallback

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
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _controllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }

  void _populateDataFromControllers() {
    _controllers.forEach((key, controller) {
      switch (key) {
        case 'nearbyLatitude':
          _data.nearbyLatitude = controller.text;
          break;
        case 'nearbyLongitude':
          _data.nearbyLongitude = controller.text;
          break;
        case 'valuerName':
          _data.valuerName = controller.text;
          break;
        case 'valuerQualifications':
          _data.valuerQualifications = controller.text;
          break;
        case 'valuerRegInfo':
          _data.valuerRegInfo = controller.text;
          break;
        case 'valuerAddress':
          _data.valuerAddress = controller.text;
          break;
        case 'valuerContact':
          _data.valuerContact = controller.text;
          break;
        case 'valuerEmail':
          _data.valuerEmail = controller.text;
          break;
        case 'refNo':
          _data.refNo = controller.text;
          break;
        case 'bankName':
          _data.bankName = controller.text;
          break;
        case 'branchName':
          _data.branchName = controller.text;
          break;
        case 'branchAddress':
          _data.branchAddress = controller.text;
          break;
        case 'purposeOfValuation':
          _data.purposeOfValuation = controller.text;
          break;
        case 'docLandTaxReceipt':
          _data.docLandTaxReceipt = controller.text;
          break;
        case 'docTitleDeed':
          _data.docTitleDeed = controller.text;
          break;
        case 'docBuildingCertificate':
          _data.docBuildingCertificate = controller.text;
          break;
        case 'docLocationSketch':
          _data.docLocationSketch = controller.text;
          break;
        case 'docPossessionCertificate':
          _data.docPossessionCertificate = controller.text;
          break;
        case 'docBuildingCompletionPlan':
          _data.docBuildingCompletionPlan = controller.text;
          break;
        case 'docThandapperDocument':
          _data.docThandapperDocument = controller.text;
          break;
        case 'docBuildingTaxReceipt':
          _data.docBuildingTaxReceipt = controller.text;
          break;
        case 'nameOfOwner':
          _data.nameOfOwner = controller.text;
          break;
        case 'nameOfApplicant':
          _data.nameOfApplicant = controller.text;
          break;
        case 'addressAsPerDocuments':
          _data.addressAsPerDocuments = controller.text;
          break;
        case 'addressAsPerActual':
          _data.addressAsPerActual = controller.text;
          break;
        case 'deviations':
          _data.deviations = controller.text;
          break;
        case 'propertyTypeLeaseholdFreehold':
          _data.propertyTypeLeaseholdFreehold = controller.text;
          break;
        case 'propertyZone':
          _data.propertyZone = controller.text;
          break;
        case 'classificationAreaHighMiddlePoor':
          _data.classificationAreaHighMiddlePoor = controller.text;
          break;
        case 'classificationAreaUrbanSemiRural':
          _data.classificationAreaUrbanSemiRural = controller.text;
          break;
        case 'comingUnder':
          _data.comingUnder = controller.text;
          break;
        case 'coveredUnderGovtEnactments':
          _data.coveredUnderGovtEnactments = controller.text;
          break;
        case 'isAgriculturalLand':
          _data.isAgriculturalLand = controller.text;
          break;
        case 'natureOfApartment':
          _data.natureOfApartment = controller.text;
          break;
        case 'yearOfConstruction':
          _data.yearOfConstruction = controller.text;
          break;
        case 'numFloorsActuals':
          _data.numFloorsActuals = controller.text;
          break;
        case 'numFloorsApproved':
          _data.numFloorsApproved = controller.text;
          break;
        case 'numUnitsActuals':
          _data.numUnitsActuals = controller.text;
          break;
        case 'numUnitsApproved':
          _data.numUnitsApproved = controller.text;
          break;
        case 'deviationsActuals':
          _data.deviationsActuals = controller.text;
          break;
        case 'deviationsApproved':
          _data.deviationsApproved = controller.text;
          break;
        case 'roadWidth':
          _data.roadWidth = controller.text;
          break;
        case 'reraNoAndDate':
          _data.reraNoAndDate = controller.text;
          break;
        case 'typeOfStructure':
          _data.typeOfStructure = controller.text;
          break;
        case 'ageOfBuilding':
          _data.ageOfBuilding = controller.text;
          break;
        case 'residualAge':
          _data.residualAge = controller.text;
          break;
        case 'maintenanceOfBuilding':
          _data.maintenanceOfBuilding = controller.text;
          break;
        case 'facilitiesLift':
          _data.facilitiesLift = controller.text;
          break;
        case 'facilitiesWater':
          _data.facilitiesWater = controller.text;
          break;
        case 'facilitiesSewerage':
          _data.facilitiesSewerage = controller.text;
          break;
        case 'facilitiesCarParking':
          _data.facilitiesCarParking = controller.text;
          break;
        case 'facilitiesCompoundWall':
          _data.facilitiesCompoundWall = controller.text;
          break;
        case 'facilitiesPavement':
          _data.facilitiesPavement = controller.text;
          break;
        case 'facilitiesExtraAmenities':
          _data.facilitiesExtraAmenities = controller.text;
          break;
        case 'flatFloor':
          _data.flatFloor = controller.text;
          break;
        case 'flatDoorNo':
          _data.flatDoorNo = controller.text;
          break;
        case 'specRoof':
          _data.specRoof = controller.text;
          break;
        case 'specFlooring':
          _data.specFlooring = controller.text;
          break;
        case 'specDoors':
          _data.specDoors = controller.text;
          break;
        case 'specWindows':
          _data.specWindows = controller.text;
          break;
        case 'specFittings':
          _data.specFittings = controller.text;
          break;
        case 'specFinishing':
          _data.specFinishing = controller.text;
          break;
        case 'electricityConnectionNo':
          _data.electricityConnectionNo = controller.text;
          break;
        case 'meterCardName':
          _data.meterCardName = controller.text;
          break;
        case 'flatMaintenance':
          _data.flatMaintenance = controller.text;
          break;
        case 'saleDeedName':
          _data.saleDeedName = controller.text;
          break;
        case 'undividedLandArea':
          _data.undividedLandArea = controller.text;
          break;
        case 'flatArea':
          _data.flatArea = controller.text;
          break;
        case 'flatClass':
          _data.flatClass = controller.text;
          break;
        case 'flatUsage':
          _data.flatUsage = controller.text;
          break;
        case 'flatOccupancy':
          _data.flatOccupancy = controller.text;
          break;
        case 'flatMonthlyRent':
          _data.flatMonthlyRent = controller.text;
          break;
        case 'rateComparable':
          _data.rateComparable = controller.text;
          break;
        case 'rateNewConstruction':
          _data.rateNewConstruction = controller.text;
          break;
        case 'rateGuideline':
          _data.rateGuideline = controller.text;
          break;
        case 'remarks1':
          _data.remarks1 = controller.text;
          break;
        case 'remarks2':
          _data.remarks2 = controller.text;
          break;
        case 'remarks3':
          _data.remarks3 = controller.text;
          break;
        case 'remarks4':
          _data.remarks4 = controller.text;
          break;
        case 'valuationApproach':
          _data.valuationApproach = controller.text;
          break;
        case 'presentMarketValue':
          _data.presentMarketValue = controller.text;
          break;
        case 'realizableValue':
          _data.realizableValue = controller.text;
          break;
        case 'distressValue':
          _data.distressValue = controller.text;
          break;
        case 'insurableValue':
          _data.insurableValue = controller.text;
          break;
        case 'finalValuationPlace':
          _data.finalValuationPlace = controller.text;
          break;
        case 'p7background':
          _data.p7background = controller.text;
          break;
        case 'p7purpose':
          _data.p7purpose = controller.text;
          break;
        case 'p7identity':
          _data.p7identity = controller.text;
          break;
        case 'p7disclosure':
          _data.p7disclosure = controller.text;
          break;
        case 'p7dates':
          _data.p7dates = controller.text;
          break;
        case 'p7inspections':
          _data.p7inspections = controller.text;
          break;
        case 'p7nature':
          _data.p7nature = controller.text;
          break;
        case 'p7procedures':
          _data.p7procedures = controller.text;
          break;
        case 'p7restrictions':
          _data.p7restrictions = controller.text;
          break;
        case 'p7majorFactors1':
          _data.p7majorFactors1 = controller.text;
          break;
        case 'p7majorFactors2':
          _data.p7majorFactors2 = controller.text;
          break;
        case 'p7caveats':
          _data.p7caveats = controller.text;
          break;
        case 'p7reportPlace':
          _data.p7reportPlace = controller.text;
          break;
      }
    });
    _data.images = _valuationImages;
    _data.valuationDetails = _valuationDetails;
  }

  void _generatePdf() {
    if (_formKey.currentState!.validate()) {
      _populateDataFromControllers();
      Printing.layoutPdf(
        onLayout: (PdfPageFormat format) => SIBPdfGenerator(_data).generate(),
      );
    }
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

  // In lib/valuation_form_sib.dart, inside the _SIBValuationFormScreenState class

// In lib/valuation_form_sib.dart, inside the _SIBValuationFormScreenState class

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

      final ownerName = _controllers['nameOfOwner']?.text ?? '[is null]';
      final marketValue =
          _controllers['presentMarketValue']?.text ?? '[is null]';

      debugPrint('------------------------------------------');
      debugPrint('DEBUGGING SAVE TO NEARBY COLLECTION:');
      debugPrint('Owner Name from Controller: "$ownerName"');
      debugPrint('Market Value from Controller: "$marketValue"');
      debugPrint('------------------------------------------');
      // --- STEP 3: Build the payload with the correct data ---
      final dataToSave = {
        // Use the coordinates from the image we found
        'refNo': _controllers['refNo']?.text ?? '',
        'latitude': firstImageWithLocation.latitude,
        'longitude': firstImageWithLocation.longitude,

        'landValue': marketValue, // Use the variable we just created
        'nameOfOwner': ownerName,
        'bankName': _controllers['bankName']?.text ?? '',
      };

      // --- STEP 4: Send the data to your dedicated server endpoint ---
      final response = await http.post(
        Uri.parse(url5), // Use your dedicated URL for saving this data
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(dataToSave),
      );

      if (response.statusCode == 201) {
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
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      var request = http.MultipartRequest('POST', Uri.parse(url));

      request.fields.addAll(
        _controllers.map((key, controller) => MapEntry(key, controller.text)),
      );

      debugPrint('Saving dateOfInspection: ${_data.dateOfInspection}');
      debugPrint('Saving dateOfValuation: ${_data.dateOfValuation}');

      request.fields['dateOfInspection'] =
          DateFormat('yyyy-MM-dd').format(_data.dateOfInspection!);
      request.fields['dateOfValuation'] =
          DateFormat('yyyy-MM-dd').format(_data.dateOfValuation!);
      request.fields['finalValuationDate'] =
          DateFormat('yyyy-MM-dd').format(_data.finalValuationDate!);
      request.fields['p7reportDate'] =
          DateFormat('yyyy-MM-dd').format(_data.p7reportDate!);
      List<Map<String, String>> valuationDetails = _valuationDetails
          .map((item) => {
                'description': item.description,
                'area': item.area,
                'ratePerUnit': item.ratePerUnit,
                'estimatedValue': item.estimatedValue,
              })
          .toList();

      request.fields['valuationDetails'] = jsonEncode(valuationDetails);

      List<Map<String, String>> imageMetadata = [];

      for (int i = 0; i < _valuationImages.length; i++) {
        final image = _valuationImages[i];
        final imageBytes = image.imageFile is File
            ? await (image.imageFile as File).readAsBytes()
            : image.imageFile;

        request.files.add(http.MultipartFile.fromBytes(
          'images', // Field name for array of images
          imageBytes,
          filename: 'property_${_controllers['refNo']!.text}_$i.jpg',
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
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Upload failed: ${response.statusCode}')));
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
    if (imageIndex < 0 || imageIndex >= _valuationImages.length) return;

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

      // Update the specific image's latitude and longitude
      setState(() {
        _valuationImages[imageIndex].latitude = position.latitude.toString();
        _valuationImages[imageIndex].longitude = position.longitude.toString();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Location captured for image!"),
            backgroundColor: Colors.green),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error getting location: $e")),
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
                  }),
              ListTile(
                  leading: const Icon(Icons.photo_camera),
                  title: const Text('Camera'),
                  onTap: () {
                    _pickImage(ImageSource.camera);
                    Navigator.of(context).pop();
                  }),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFiles = source == ImageSource.gallery
          ? await _picker.pickMultiImage()
          : [await _picker.pickImage(source: source)]
              .where((file) => file != null)
              .cast<XFile>()
              .toList();
      if (pickedFiles.isNotEmpty) {
        for (var file in pickedFiles) {
          final bytes = await file.readAsBytes();
          _valuationImages.add(ValuationImage(imageFile: bytes));
        }
        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed to pick images: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SIB Valuation Report (Flats)')),
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
                      controller: _controllers['nearbyLatitude'],
                      decoration: const InputDecoration(labelText: 'Latitude'),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _controllers['nearbyLongitude'],
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
                                    _getNearbyLocation, // Call our new method
                                icon: const Icon(Icons.my_location),
                                label: const Text('Get Location'),
                              ),
                            ),
                            const SizedBox(
                              width: 5,
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
            _buildSection(
                title: 'Header & Recipient',
                initiallyExpanded: false,
                children: [
                  _buildTextField('Valuer Name', 'valuerName'),
                  _buildTextField(
                      'Valuer Qualifications', 'valuerQualifications'),
                  _buildTextField('Valuer Registration Info', 'valuerRegInfo',
                      maxLines: 3),
                  _buildTextField('Valuer Address', 'valuerAddress',
                      maxLines: 2),
                  _buildTextField('Valuer Contact', 'valuerContact'),
                  _buildTextField('Valuer Email', 'valuerEmail'),
                  const Divider(height: 20),
                  _buildTextField('Ref No.', 'refNo'),
                  _buildTextField('Bank Name', 'bankName'),
                  _buildTextField('Branch Name', 'branchName'),
                  _buildTextField('Branch Address', 'branchAddress'),
                ]),
            _buildSection(title: 'I. Property Details', children: [
              _buildTextField('Purpose for which the valuation is made',
                  'purposeOfValuation',
                  maxLines: 2),
              _buildDatePicker(
                  'Date of Inspection',
                  (date) => setState(() => _data.dateOfInspection = date),
                  _data.dateOfInspection),
              _buildDatePicker(
                  'Date of Valuation',
                  (date) => setState(() => _data.dateOfValuation = date),
                  _data.dateOfValuation),
              const SizedBox(height: 10),
              const Text(
                  "List of documents with No. & date produced for Persual",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              _buildTextField('i) Land Tax Receipt ()', 'docLandTaxReceipt'),
              _buildTextField('ii) Title Deed ()', 'docTitleDeed'),
              _buildTextField(
                  'iii) Building Certificate ()', 'docBuildingCertificate'),
              _buildTextField('iv) Location Sketch ()', 'docLocationSketch'),
              _buildTextField(
                  'v) Possession Certificate ()', 'docPossessionCertificate'),
              _buildTextField('vi) Building Completion Plan ()',
                  'docBuildingCompletionPlan'),
              _buildTextField(
                  'vii) Thandapper Document ()', 'docThandapperDocument'),
              _buildTextField(
                  'viii) Building Tax Receipt ()', 'docBuildingTaxReceipt'),
              const SizedBox(height: 10),
              _buildTextField('Name of the owner(s)', 'nameOfOwner'),
              _buildTextField('Name of the applicant(s)', 'nameOfApplicant'),
              const Text("The address of the property",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              _buildTextField('As Per Documents', 'addressAsPerDocuments'),
              _buildTextField('As per actual/postal', 'addressAsPerActual'),
              _buildTextField('Deviations if any:', 'deviations'),
              _buildTextField('Property type (Leasehold/Freehold)',
                  'propertyTypeLeaseholdFreehold'),
              _buildTextField(
                  'Property Zone (Residential/etc)', 'propertyZone'),
              const Text("Classification of the area",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              _buildTextField('i) High / Middle / Poor',
                  'classificationAreaHighMiddlePoor'),
              _buildTextField('ii) Urban / Semi Urban / Rural',
                  'classificationAreaUrbanSemiRural'),
              _buildTextField(
                  'Coming under Corporation limit / Village Panchayat',
                  'comingUnder'),
              _buildTextField(
                  'Whether covered under any State / Central Govt. enactments',
                  'coveredUnderGovtEnactments',
                  maxLines: 2),
              _buildTextField(
                  'In case it is an agricultural land any conversion to house site plots is contemplated',
                  'isAgriculturalLand',
                  maxLines: 2),
            ]),
            _buildSection(title: 'II. Apartment Building', children: [
              _buildTextField('Nature of the Apartment', 'natureOfApartment'),
              _buildTextField('Year of Construction', 'yearOfConstruction'),
              const Text("Number of Floors",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              // NEW, CORRECTED CODE
              Row(children: [
                Expanded(
                    child:
                        _buildTextField('As per actuals', 'numFloorsActuals')),
                const SizedBox(width: 8),
                Expanded(
                    child:
                        _buildTextField('As per approved', 'numFloorsApproved'))
              ]),
              const Text("Number of Units",
                  style: TextStyle(fontWeight: FontWeight.bold)),

              Row(children: [
                Expanded(
                    child:
                        _buildTextField('As per actuals', 'numUnitsActuals')),
                const SizedBox(width: 8),
                Expanded(
                    child:
                        _buildTextField('As per approved', 'numUnitsApproved'))
              ]),
              const Text("Deviations if any : ",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Row(children: [
                Expanded(
                    child:
                        _buildTextField('As per actuals', 'deviationsActuals')),
                const SizedBox(width: 8),
                Expanded(
                    child: _buildTextField(
                        'As per approved', 'deviationsApproved'))
              ]),
              _buildTextField(
                  'The width of the road abutting the project', 'roadWidth'),
              _buildTextField('The RERA registration No. with validity date\'s',
                  'reraNoAndDate'),
              _buildTextField('Type of Structure', 'typeOfStructure'),
              _buildTextField('Age of the building', 'ageOfBuilding'),
              _buildTextField('Residual age of the building', 'residualAge'),
              _buildTextField(
                  'Maintenance of the Building', 'maintenanceOfBuilding'),
              const Text("Facilities Available",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              _buildTextField('Lift', 'facilitiesLift'),
              _buildTextField('Protected Water Supply', 'facilitiesWater'),
              _buildTextField('Underground Sewerage', 'facilitiesSewerage'),
              _buildTextField(
                  'Car Parking - Open/ Covered', 'facilitiesCarParking'),
              _buildTextField(
                  'Is Compound wall existing?', 'facilitiesCompoundWall'),
              _buildTextField(
                  'Is pavement laid around the Building', 'facilitiesPavement'),
              _buildTextField(
                  'Extract Amenities If any', 'facilitiesExtraAmenities'),
            ]),
            _buildSection(title: 'III. Flat Details', children: [
              _buildTextField(
                  'The floor on which the flat is situated', 'flatFloor'),
              _buildTextField('Door No. of the flat', 'flatDoorNo'),
              const Text("Specifications of the flat",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              _buildTextField('Roof', 'specRoof'),
              _buildTextField('Flooring', 'specFlooring'),
              _buildTextField('Doors', 'specDoors'),
              _buildTextField('Windows', 'specWindows'),
              _buildTextField('Fittings', 'specFittings'),
              _buildTextField('Finishing', 'specFinishing'),
              const SizedBox(height: 10),
              _buildTextField('Electricity Service Connection no.',
                  'electricityConnectionNo'),
              _buildTextField('Meter Card is in the name of', 'meterCardName'),
              _buildTextField(
                  'How is the maintenance of the flat?', 'flatMaintenance'),
              _buildTextField(
                  'Sale Deed executed in the name of', 'saleDeedName'),
              _buildTextField(
                  'What is the undivided area of land as per Sale Deed?',
                  'undividedLandArea'),
              _buildTextField(
                  'What is the Supper Built Up/ Built Up/Carpet area of the flat?',
                  'flatArea'),
              _buildTextField(
                  'Is it Posh/ I class / Medium / Ordinary?', 'flatClass'),
              _buildTextField(
                  'Is it being used for Residential or Commercial purpose?',
                  'flatUsage'),
              _buildTextField(
                  'Is it Owner-occupied or let out?', 'flatOccupancy'),
              _buildTextField(
                  'If rented, what is the monthly rent?', 'flatMonthlyRent'),
            ]),
            _buildSection(title: 'IV. Rate', children: [
              _buildTextField(
                  'After analyzing the comparable sale instances instances, what is the composite rate for a similar flat with samespecifications in the adjoining locality?',
                  'rateComparable',
                  maxLines: 3),
              _buildTextField(
                  'Assuming it is a new construction what is the adopted basic composite rate of the flat under valuation after comparing with the specifications and othe factors with the flat under comparison (give details)',
                  'rateNewConstruction',
                  maxLines: 3),
              _buildTextField(
                  'Guideline rate obtained from the Registrar\'s office (Evidence to be enclosed)',
                  'rateGuideline',
                  maxLines: 2),
            ]),
            _buildSection(title: 'Details of Valuation', children: [
              _buildValuationTable(),
            ]),
            _buildSection(
                title: 'Consolidated Remarks/Observations',
                children: [
                  _buildTextField('Remark 1', 'remarks1', maxLines: 2),
                  _buildTextField('Remark 2', 'remarks2', maxLines: 2),
                  _buildTextField('Remark 3', 'remarks3', maxLines: 2),
                  _buildTextField('Remark 4', 'remarks4', maxLines: 2),
                ]),
            _buildSection(title: 'Final Valuation Summary', children: [
              _buildTextField('Valuation Approach Details', 'valuationApproach',
                  maxLines: 5),
              const SizedBox(height: 10),
              _buildTextField(
                  'Present Market Value of The Property', 'presentMarketValue'),
              _buildTextField(
                  'Realizable Value of the Property', 'realizableValue'),
              _buildTextField(
                  'Distress Value of the Property', 'distressValue'),
              _buildTextField(
                  'Insurable Value of the property', 'insurableValue'),
              const SizedBox(height: 10),
              _buildTextField('Place', 'finalValuationPlace'),
              _buildDatePicker(
                  'Date',
                  (date) => setState(() => _data.finalValuationDate = date),
                  _data.finalValuationDate),
            ]),
            _buildSection(title: 'Page 7 - Final Table', children: [
              _buildTextField(
                  'Background information of the asset', 'p7background',
                  maxLines: 2),
              _buildTextField(
                  'Purpose of valuation and appointing authority', 'p7purpose',
                  maxLines: 2),
              _buildTextField(
                  'Identity of the valuer and any other experts involved in the valuation',
                  'p7identity'),
              _buildTextField(
                  'Disclosure of valuer interest or conflict', 'p7disclosure'),
              _buildTextField(
                  'Date of appointment, valuation date and date of report',
                  'p7dates'),
              _buildTextField('Inspections and/or investigations undertaken',
                  'p7inspections'),
              _buildTextField(
                  'Nature and sources of the information used or relied upon',
                  'p7nature'),
              _buildTextField(
                  'Procedures adopted in carrying out the valuation',
                  'p7procedures'),
              _buildTextField(
                  'Restrictions on use of the report, if any', 'p7restrictions',
                  maxLines: 2),
              _buildTextField(
                  'Major factors that were taken into account (Land) during the valuation',
                  'p7majorFactors1',
                  maxLines: 2),
              _buildTextField(
                  'Major factors that were taken into account (Building) during the valuation',
                  'p7majorFactors2',
                  maxLines: 2),
              _buildTextField(
                  'Caveats, limitations and disclaimers', 'p7caveats',
                  maxLines: 2),
              _buildDatePicker(
                  'Report Date',
                  (date) => setState(() => _data.p7reportDate = date),
                  _data.p7reportDate),
              _buildTextField('Report Place', 'p7reportPlace'),
            ]),
            _buildSection(title: 'Photo Report', children: [
              Center(
                  child: ElevatedButton.icon(
                      onPressed: _showImagePickerOptions,
                      icon: const Icon(Icons.add_a_photo),
                      label: const Text('Add Images'))),
              const SizedBox(height: 10),

              // lib/valuation_form_sib.dart -> build() method -> 'Photo Report' section

// In lib/valuation_form_sib.dart -> build() method -> 'Photo Report' section

// --- REPLACE the old GridView.builder with THIS ENTIRE WIDGET ---
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 2 /
                      2.8, // Adjust ratio for a slightly taller, compact look
                ),
                itemCount: _valuationImages.length,
                itemBuilder: (context, index) {
                  final valuationImage = _valuationImages[index];

                  final latController =
                      TextEditingController(text: valuationImage.latitude);
                  final lonController =
                      TextEditingController(text: valuationImage.longitude);

                  // Using a Container with a border instead of a Card
                  return Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    clipBehavior: Clip
                        .antiAlias, // Important: This makes the child (Image) respect the borderRadius
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // --- Image with Delete Button ---
                        Expanded(
                          flex: 5, // Give the image more space
                          child: Stack(
                            alignment: Alignment.topRight,
                            children: [
                              Image.memory(
                                valuationImage.imageFile,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                              InkWell(
                                onTap: () => setState(
                                    () => _valuationImages.removeAt(index)),
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  margin: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.black54,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.close,
                                      color: Colors.white, size: 16),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // --- Lat/Long and Button section ---
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                              8, 4, 8, 4), // Reduced padding for compactness
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: latController,
                                      decoration: const InputDecoration(
                                          labelText: 'Lat',
                                          isDense: true,
                                          contentPadding: EdgeInsets.symmetric(
                                              vertical: 4)),
                                      onChanged: (value) =>
                                          valuationImage.latitude = value,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: TextField(
                                      controller: lonController,
                                      decoration: const InputDecoration(
                                          labelText: 'Lon',
                                          isDense: true,
                                          contentPadding: EdgeInsets.symmetric(
                                              vertical: 4)),
                                      onChanged: (value) =>
                                          valuationImage.longitude = value,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              SizedBox(
                                height:
                                    30, // Give the button a fixed, smaller height
                                child: ElevatedButton(
                                  onPressed: () => _getCurrentLocation(index),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8),
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: const Text('Get Location',
                                      style: TextStyle(fontSize: 12)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              )
// --- END OF REPLACEMENT WIDGET ---
            ]),
            Padding(
              padding: const EdgeInsets.only(left: 50, right: 50, top: 10),
              child: FloatingActionButton.extended(
                onPressed: _generatePdf,
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text('Generate PDF'),
              ),
            ),
          ],
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

  Widget _buildValuationTable() {
    return Column(
      children: [
        Table(
          columnWidths: const {
            0: FlexColumnWidth(3),
            1: FlexColumnWidth(2),
            2: FlexColumnWidth(2),
            3: FlexColumnWidth(2),
          },
          border: TableBorder.all(),
          children: [
            const TableRow(children: [
              Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Description',
                      style: TextStyle(fontWeight: FontWeight.bold))),
              Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Area in Sqft',
                      style: TextStyle(fontWeight: FontWeight.bold))),
              Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Rate Per unit Rs',
                      style: TextStyle(fontWeight: FontWeight.bold))),
              Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Estimated Rs.',
                      style: TextStyle(fontWeight: FontWeight.bold))),
            ]),
            ..._valuationDetails.asMap().entries.map((entry) {
              int idx = entry.key;
              ValuationDetailItem item = entry.value;
              return TableRow(children: [
                Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: TextFormField(
                        initialValue: item.description,
                        onChanged: (val) => item.description = val,
                        decoration:
                            const InputDecoration(border: InputBorder.none))),
                Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: TextFormField(
                        initialValue: item.area,
                        onChanged: (val) => item.area = val,
                        decoration:
                            const InputDecoration(border: InputBorder.none))),
                Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: TextFormField(
                        initialValue: item.ratePerUnit,
                        onChanged: (val) => item.ratePerUnit = val,
                        decoration:
                            const InputDecoration(border: InputBorder.none))),
                Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: TextFormField(
                        initialValue: item.estimatedValue,
                        onChanged: (val) => item.estimatedValue = val,
                        decoration:
                            const InputDecoration(border: InputBorder.none))),
              ]);
            }),
          ],
        ),
      ],
    );
  }

  Widget _buildTextField(String label, String key, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: _controllers[key],
        maxLines: maxLines,
        decoration: InputDecoration(
            labelText: label, border: const OutlineInputBorder()),
        validator: (value) {
          // You can enable validation if needed.
          // if (value == null || value.isEmpty) return 'Please enter a value';
          return null;
        },
      ),
    );
  }

  Widget _buildDatePicker(
      String label, Function(DateTime) onDateChanged, DateTime? initialDate) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      subtitle: Text(initialDate != null
          ? DateFormat('dd-MM-yyyy').format(initialDate)
          : 'Not set'),
      trailing: const Icon(Icons.calendar_today),
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: initialDate ?? DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2101),
        );
        if (picked != null) onDateChanged(picked);
      },
    );
  }

  Widget _buildSection(
      {required String title,
      required List<Widget> children,
      bool initiallyExpanded = false}) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ExpansionTile(
        title: Text(title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        initiallyExpanded: initiallyExpanded,
        childrenPadding: const EdgeInsets.all(16.0),
        children: children,
      ),
    );
  }
}
