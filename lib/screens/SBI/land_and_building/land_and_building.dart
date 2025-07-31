import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:login_screen/screens/SBI/land_and_building/savedDraftsSBILand.dart';
import 'package:login_screen/screens/nearbyDetails.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart' as pdfLib;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:typed_data';
import 'dart:io';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'config.dart';
import 'package:login_screen/screens/driveAPIconfig.dart';
import 'package:path/path.dart' as path;

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
        fontFamily: 'Inter',
      ),
      home: const ValuationFormPage(
        propertyData: {},
      ),
    );
  }
}

class ValuationFormPage extends StatefulWidget {
  final Map<String, dynamic>? propertyData;
  const ValuationFormPage({super.key, this.propertyData});

  @override
  State<ValuationFormPage> createState() => _ValuationFormPageState();
}

class _ValuationFormPageState extends State<ValuationFormPage> {
  // ... [all code remains the same except for SIB -> SBI replacements] ...

  @override
  void initState() {
    super.initState();
    if (widget.propertyData != null) {
      debugPrint('Received property data: ${widget.propertyData}');
    } else {
      debugPrint('No property data received - creating new valuation');
    }
    _initializeFormWithPropertyData();
  }

  // ... [all controller and variable declarations remain unchanged] ...
  final TextEditingController _latController = TextEditingController();
  final TextEditingController _lonController = TextEditingController();
  final TextEditingController _refId = TextEditingController();

  // Controllers for text input fields (Page 1)
  final TextEditingController _purposeController = TextEditingController();
  final TextEditingController _dateOfInspectionController =
      TextEditingController();
  final TextEditingController _dateOfValuationController =
      TextEditingController();
  final TextEditingController _ownerNameController = TextEditingController();
  final TextEditingController _applicantNameController =
      TextEditingController();
  final TextEditingController _addressDocController = TextEditingController();
  final TextEditingController _addressActualController =
      TextEditingController();
  final TextEditingController _deviationsController = TextEditingController();
  final TextEditingController _propertyTypeController = TextEditingController();
  final TextEditingController _propertyZoneController = TextEditingController();

  // Controllers for text input fields (Page 2)
  final TextEditingController _classificationAreaController =
      TextEditingController();
  final TextEditingController _urbanSemiUrbanRuralController =
      TextEditingController();
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
  final TextEditingController _dimTotalAreaActualsController =
      TextEditingController();
  final TextEditingController _dimNorthDocumentsController =
      TextEditingController();
  final TextEditingController _dimSouthDocumentsController =
      TextEditingController();
  final TextEditingController _dimEastDocumentsController =
      TextEditingController();
  final TextEditingController _dimWestDocumentsController =
      TextEditingController();
  final TextEditingController _dimTotalAreaDocumentsController =
      TextEditingController();
  final TextEditingController _dimNorthAdoptedController =
      TextEditingController();
  final TextEditingController _dimSouthAdoptedController =
      TextEditingController();
  final TextEditingController _dimEastAdoptedController =
      TextEditingController();
  final TextEditingController _dimWestAdoptedController =
      TextEditingController();
  final TextEditingController _dimTotalAreaAdoptedController =
      TextEditingController();
  final TextEditingController _dimDeviationsController =
      TextEditingController();

  // Occupancy details controllers
  final TextEditingController _latitudeLongitudeController =
      TextEditingController();
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
  final TextEditingController _totalAbstractAmenitiesController =
      TextEditingController();
  final TextEditingController _totalAbstractTotalController =
      TextEditingController();
  final TextEditingController _totalAbstractSayController =
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
  final TextEditingController _insurableValueController =
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
  
  //
  Future<pw.MemoryImage> loadLogoImage() async {
    final Uint8List bytes = await rootBundle
        .load('assets/images/logo.png')
        .then((data) => data.buffer.asUint8List());
    return pw.MemoryImage(bytes);
  }

  // Checkbox states for documents (Page 1)
  final Map<String, bool> _documentChecks = {
    'Land Tax Receipt': false,
    'Title Deed': false,
    'Building Certificate': false,
    'Location Sketch': false,
    'Possession Certificate': false,
    'Building Completion Plan': false,
    'Thandapper Document': false,
    'Building Tax Receipt': false,
  };

  // MODIFIED: List to store uploaded images. Now dynamic to handle both File and Uint8List.
  final List<dynamic> _images = [];

  final _formKey = GlobalKey<FormState>();
  // In _saveToNearbyCollection change the bankName for SBI
  Future<void> _saveToNearbyCollection() async {
    try {
      String fullCoordinates = _latitudeLongitudeController.text;
      String latitude = '';
      String longitude = '';

      if (fullCoordinates.isNotEmpty && fullCoordinates.contains(',')) {
        final parts = fullCoordinates.split(',');
        if (parts.length == 2) {
          latitude = parts[0].trim();
          longitude = parts[1].trim();
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
        return;
      }

      final ownerName = _ownerNameController.text ?? '[is null]';
      final marketValue = _presentMarketValueController.text ?? '[is null]';

      debugPrint('------------------------------------------');
      debugPrint('DEBUGGING SAVE TO NEARBY COLLECTION:');
      debugPrint('Owner Name from Controller: "$ownerName"');
      debugPrint('Market Value from Controller: "$marketValue"');
      debugPrint('------------------------------------------');
      final dataToSave = {
        'refNo': _refId.text ?? '',
        'latitude': latitude,
        'longitude': longitude,
        'landValue': marketValue,
        'nameOfOwner': ownerName,
        'bankName': 'State Bank of India (Land & Building)',
      };

      final response = await http.post(
        Uri.parse(url5),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(dataToSave),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
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
 // ... [rest of the code is identical except for SIB -> SBI changes, e.g. import path, debugPrints, and references to SIB become SBI] ...
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
            borderRadius:
                BorderRadius.all(Radius.circular(20)), // Applied new styling
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        ),
      ),
    );
  }

  // Function to select a date
  Future<void> _selectDate(
      BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        controller.text =
            DateFormat('dd-MM-yyyy').format(picked); // Formatted date
      });
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
            content:
                Text('Location services are disabled. Please enable them.')),
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
                'Location permissions are permanently denied, we cannot request permissions.')),
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching location: $e')),
      );
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
      1: 'I'
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
  List<pw.TableRow> _getPage1TableRows(List<String> selectedDocuments) {
    const pw.TextStyle contentTextStyle = pw.TextStyle(fontSize: 8);
    const pw.EdgeInsets cellPadding = pw.EdgeInsets.all(3);

    List<pw.TableRow> rows = [];

    rows.add(pw.TableRow(children: [
      pw.Container(
          padding: cellPadding, child: pw.Text('1.', style: contentTextStyle)),
      pw.Container(
          padding: cellPadding,
          child: pw.Text('Purpose for which the valuation is made',
              style: contentTextStyle)),
      pw.Container(
          padding: cellPadding, child: pw.Text(':', style: contentTextStyle)),
      pw.Container(
          padding: cellPadding,
          child: pw.Text(_purposeController.text, style: contentTextStyle)),
    ]));
    rows.add(pw.TableRow(children: [
      pw.Container(
          padding: cellPadding, child: pw.Text('2.', style: contentTextStyle)),
      pw.Container(
          padding: cellPadding,
          child: pw.Text('a) Date of inspection', style: contentTextStyle)),
      pw.Container(
          padding: cellPadding, child: pw.Text(':', style: contentTextStyle)),
      pw.Container(
          padding: cellPadding,
          child: pw.Text(_dateOfInspectionController.text,
              style: contentTextStyle)),
    ]));
    rows.add(pw.TableRow(children: [
      pw.Container(padding: cellPadding, child: pw.Text('')),
      pw.Container(
          padding: cellPadding,
          child: pw.Text('    b) Date on which the valuation is made',
              style: contentTextStyle)),
      pw.Container(
          padding: cellPadding, child: pw.Text(':', style: contentTextStyle)),
      pw.Container(
          padding: cellPadding,
          child: pw.Text(_dateOfValuationController.text,
              style: contentTextStyle)),
    ]));
    rows.add(pw.TableRow(children: [
      pw.Container(
          padding: cellPadding, child: pw.Text('3.', style: contentTextStyle)),
      pw.Container(
          padding: cellPadding,
          child: pw.Text('List of documents produced for perusal',
              style: contentTextStyle)),
      pw.Container(padding: cellPadding, child: pw.Text('')),
      pw.Container(padding: cellPadding, child: pw.Text('')),
    ]));
    rows.addAll(selectedDocuments.asMap().entries.map((entry) {
      int idx = entry.key + 1;
      String doc = entry.value;
      return pw.TableRow(children: [
        pw.Container(padding: cellPadding, child: pw.Text('')),
        pw.Container(
            padding: cellPadding,
            child:
                pw.Text('    ${_toRoman(idx)}) $doc', style: contentTextStyle)),
        pw.Container(
            padding: cellPadding, child: pw.Text(':', style: contentTextStyle)),
        pw.Container(
            padding: cellPadding, child: pw.Text('', style: contentTextStyle)),
      ]);
    }).toList());
    if (selectedDocuments.isEmpty) {
      rows.add(pw.TableRow(children: [
        pw.Container(padding: cellPadding, child: pw.Text('')),
        pw.Container(
            padding: cellPadding,
            child: pw.Text('    (No documents selected)',
                style: contentTextStyle)),
        pw.Container(
            padding: cellPadding, child: pw.Text(':', style: contentTextStyle)),
        pw.Container(
            padding: cellPadding, child: pw.Text('', style: contentTextStyle)),
      ]));
    }
    rows.add(pw.TableRow(children: [
      pw.Container(
          padding: cellPadding, child: pw.Text('4.', style: contentTextStyle)),
      pw.Container(
          padding: cellPadding,
          child: pw.Text('Name of the owner(s)', style: contentTextStyle)),
      pw.Container(
          padding: cellPadding, child: pw.Text(':', style: contentTextStyle)),
      pw.Container(
          padding: cellPadding,
          child: pw.Text(_ownerNameController.text, style: contentTextStyle)),
    ]));
    rows.add(pw.TableRow(children: [
      pw.Container(
          padding: cellPadding, child: pw.Text('5.', style: contentTextStyle)),
      pw.Container(
          padding: cellPadding,
          child: pw.Text('Name of the applicant(s)', style: contentTextStyle)),
      pw.Container(
          padding: cellPadding, child: pw.Text(':', style: contentTextStyle)),
      pw.Container(
          padding: cellPadding,
          child:
              pw.Text(_applicantNameController.text, style: contentTextStyle)),
    ]));
    rows.add(pw.TableRow(children: [
      pw.Container(
          padding: cellPadding, child: pw.Text('6.', style: contentTextStyle)),
      pw.Container(
          padding: cellPadding,
          child: pw.Text('The address of the property (including pin code)',
              style: contentTextStyle)),
      pw.Container(padding: cellPadding, child: pw.Text('')),
      pw.Container(padding: cellPadding, child: pw.Text('')),
    ]));
    rows.add(pw.TableRow(children: [
      pw.Container(padding: cellPadding, child: pw.Text('')),
      pw.Container(
          padding: cellPadding,
          child: pw.Text('    As Per Documents', style: contentTextStyle)),
      pw.Container(
          padding: cellPadding, child: pw.Text(':', style: contentTextStyle)),
      pw.Container(
          padding: cellPadding,
          child: pw.Text(_addressDocController.text, style: contentTextStyle)),
    ]));
    rows.add(pw.TableRow(children: [
      pw.Container(padding: cellPadding, child: pw.Text('')),
      pw.Container(
          padding: cellPadding,
          child: pw.Text('    As per actual/postal', style: contentTextStyle)),
      pw.Container(
          padding: cellPadding, child: pw.Text(':', style: contentTextStyle)),
      pw.Container(
          padding: cellPadding,
          child:
              pw.Text(_addressActualController.text, style: contentTextStyle)),
    ]));
    rows.add(pw.TableRow(children: [
      pw.Container(
          padding: cellPadding, child: pw.Text('7.', style: contentTextStyle)),
      pw.Container(
          padding: cellPadding,
          child: pw.Text('Deviations if any', style: contentTextStyle)),
      pw.Container(
          padding: cellPadding, child: pw.Text(':', style: contentTextStyle)),
      pw.Container(
          padding: cellPadding,
          child: pw.Text(_deviationsController.text, style: contentTextStyle)),
    ]));
    rows.add(pw.TableRow(children: [
      pw.Container(
          padding: cellPadding, child: pw.Text('8.', style: contentTextStyle)),
      pw.Container(
          padding: cellPadding,
          child: pw.Text('The property type (Leasehold/ Freehold)',
              style: contentTextStyle)),
      pw.Container(
          padding: cellPadding, child: pw.Text(':', style: contentTextStyle)),
      pw.Container(
          padding: cellPadding,
          child:
              pw.Text(_propertyTypeController.text, style: contentTextStyle)),
    ]));
    rows.add(pw.TableRow(children: [
      pw.Container(
          padding: cellPadding, child: pw.Text('9.', style: contentTextStyle)),
      pw.Container(
          padding: cellPadding,
          child: pw.Text(
              'Property Zone (Residential/ Commercial/ Industrial/ Agricultural)',
              style: contentTextStyle)),
      pw.Container(
          padding: cellPadding, child: pw.Text(':', style: contentTextStyle)),
      pw.Container(
          padding: cellPadding,
          child:
              pw.Text(_propertyZoneController.text, style: contentTextStyle)),
    ]));
    return rows;
  }

  List<pw.TableRow> _getPage2Table1Rows() {
    const pw.TextStyle contentTextStyle =
        pw.TextStyle(fontSize: 10); // Increased font size to 10
    const pw.EdgeInsets cellPadding = pw.EdgeInsets.all(3);

    List<pw.TableRow> rows = [];

    // Items 10-13 (adjusted for 5-column layout, last cell empty)
    rows.add(pw.TableRow(children: [
      pw.Container(
          padding: cellPadding, child: pw.Text('10.', style: contentTextStyle)),
      pw.Container(
          padding: cellPadding,
          child:
              pw.Text('Classification of the area', style: contentTextStyle)),
      pw.Container(
          padding: cellPadding, child: pw.Text(':', style: contentTextStyle)),
      pw.Container(padding: cellPadding, child: pw.Text(''))
    ]));
    rows.add(pw.TableRow(children: [
      pw.Container(padding: cellPadding, child: pw.Text('')),
      pw.Container(
          padding: cellPadding,
          child:
              pw.Text('    i) High / Middle / Poor', style: contentTextStyle)),
      pw.Container(
          padding: cellPadding, child: pw.Text(':', style: contentTextStyle)),
      pw.Container(
          padding: cellPadding,
          child: pw.Text(_classificationAreaController.text,
              style: contentTextStyle)),
    ]));
    rows.add(pw.TableRow(children: [
      pw.Container(padding: cellPadding, child: pw.Text('')),
      pw.Container(
          padding: cellPadding,
          child: pw.Text('    ii) Urban / Semi Urban / Rural',
              style: contentTextStyle)),
      pw.Container(
          padding: cellPadding, child: pw.Text(':', style: contentTextStyle)),
      pw.Container(
          padding: cellPadding,
          child: pw.Text(_urbanSemiUrbanRuralController.text,
              style: contentTextStyle)),
    ]));
    rows.add(pw.TableRow(children: [
      pw.Container(
          padding: cellPadding, child: pw.Text('11.', style: contentTextStyle)),
      pw.Container(
          padding: cellPadding,
          child: pw.Text(
              'Coming under Corporation limit / Village Panchayat / Municipality',
              style: contentTextStyle)),
      pw.Container(
          padding: cellPadding, child: pw.Text(':', style: contentTextStyle)),
      pw.Container(
          padding: cellPadding,
          child: pw.Text(_comingUnderCorporationController.text,
              style: contentTextStyle)),
    ]));
    rows.add(pw.TableRow(children: [
      pw.Container(
          padding: cellPadding, child: pw.Text('12.', style: contentTextStyle)),
      pw.Container(
          padding: cellPadding,
          child: pw.Text(
              'Whether covered under any State / Central Govt. enactments (e.g. Urban Land Ceiling Act) or notified under agency area / scheduled area',
              style: contentTextStyle)),
      pw.Container(
          padding: cellPadding, child: pw.Text(':', style: contentTextStyle)),
      pw.Container(
          padding: cellPadding,
          child: pw.Text(_coveredUnderStateCentralGovtController.text,
              style: contentTextStyle)),
    ]));
    rows.add(pw.TableRow(children: [
      pw.Container(
          padding: cellPadding, child: pw.Text('13.', style: contentTextStyle)),
      pw.Container(
          padding: cellPadding,
          child: pw.Text(
              'In case it is an agricultural land, any conversion to house site plots is contemplated',
              style: contentTextStyle)),
      pw.Container(
          padding: cellPadding, child: pw.Text(':', style: contentTextStyle)),
      pw.Container(
          padding: cellPadding,
          child: pw.Text(_agriculturalLandConversionController.text,
              style: contentTextStyle)),
    ]));
    return rows;
  }

  List<pw.TableRow> _getPage2Table2RowsHeading() {
    const pw.TextStyle contentTextStyle =
        pw.TextStyle(fontSize: 10); // Increased font size to 10
    const pw.EdgeInsets cellPadding = pw.EdgeInsets.all(3);

    List<pw.TableRow> rows = [];

    rows.add(pw.TableRow(children: [
      pw.Container(
          padding: cellPadding, child: pw.Text('14.', style: contentTextStyle)),
      pw.Container(
          padding: cellPadding,
          child: pw.Text('Boundaries of the property:',
              style: contentTextStyle)), // empty
    ]));

    return rows;
  }

  // Helper function to get table rows for Page 2 - Table 2 (Item 15)
  List<pw.TableRow> _getPage2Table2Rows() {
    const pw.TextStyle contentTextStyle =
        pw.TextStyle(fontSize: 10); // Increased font size to 10
    const pw.EdgeInsets cellPadding = pw.EdgeInsets.all(3);

    List<pw.TableRow> rows = [];
    rows.add(pw.TableRow(
      children: [
        pw.Container(padding: cellPadding, child: pw.Text('')),
        pw.Container(
            padding: cellPadding,
            child: pw.Text('Directions', style: contentTextStyle)),
        pw.Container(
            padding: cellPadding, child: pw.Text(':', style: contentTextStyle)),
        pw.Container(
            padding: cellPadding,
            child: pw.Text('As per Title Deed', style: contentTextStyle)),
        pw.Container(
            padding: cellPadding,
            child: pw.Text('As per Location Sketch', style: contentTextStyle)),
      ],
    ));
    rows.add(pw.TableRow(children: [
      pw.Container(padding: cellPadding, child: pw.Text('')),
      pw.Container(
          padding: cellPadding,
          child: pw.Text('North', style: contentTextStyle)),
      pw.Container(
          padding: cellPadding,
          child: pw.Text(_boundaryNorthTitleController.text,
              style: contentTextStyle)),
      pw.Container(
          padding: cellPadding,
          child: pw.Text(':',
              style: contentTextStyle)), // colon added for consistency
      pw.Container(
          padding: cellPadding,
          child: pw.Text(_boundaryNorthSketchController.text,
              style: contentTextStyle)),
    ]));
    rows.add(pw.TableRow(children: [
      pw.Container(padding: cellPadding, child: pw.Text('')),
      pw.Container(
          padding: cellPadding,
          child: pw.Text('South', style: contentTextStyle)),
      pw.Container(
          padding: cellPadding,
          child: pw.Text(':',
              style: contentTextStyle)), // colon added for consistency
      pw.Container(
          padding: cellPadding,
          child: pw.Text(_boundarySouthTitleController.text,
              style: contentTextStyle)),
      pw.Container(
          padding: cellPadding,
          child: pw.Text(_boundarySouthSketchController.text,
              style: contentTextStyle)),
    ]));
    rows.add(pw.TableRow(children: [
      pw.Container(padding: cellPadding, child: pw.Text('')),
      pw.Container(
          padding: cellPadding,
          child: pw.Text('East', style: contentTextStyle)),
      pw.Container(
          padding: cellPadding,
          child: pw.Text(':',
              style: contentTextStyle)), // colon added for consistency
      pw.Container(
          padding: cellPadding,
          child: pw.Text(_boundaryEastTitleController.text,
              style: contentTextStyle)),
      pw.Container(
          padding: cellPadding,
          child: pw.Text(_boundaryEastSketchController.text,
              style: contentTextStyle)),
    ]));
    rows.add(pw.TableRow(children: [
      pw.Container(padding: cellPadding, child: pw.Text('')),
      pw.Container(
          padding: cellPadding,
          child: pw.Text('West', style: contentTextStyle)),
      pw.Container(
          padding: cellPadding,
          child: pw.Text(':',
              style: contentTextStyle)), // colon added for consistency
      pw.Container(
          padding: cellPadding,
          child: pw.Text(_boundaryWestTitleController.text,
              style: contentTextStyle)),
      pw.Container(
          padding: cellPadding,
          child: pw.Text(_boundaryWestSketchController.text,
              style: contentTextStyle)),
    ]));
    rows.add(pw.TableRow(children: [
      pw.Container(padding: cellPadding, child: pw.Text('')),
      pw.Container(
          padding: cellPadding,
          child: pw.Text('Deviations if any :', style: contentTextStyle)),
      pw.Container(
          padding: cellPadding,
          child: pw.Text('')), // Empty cell for colon column
      pw.Container(
          padding: cellPadding,
          child: pw.Text(_boundaryDeviationsController.text,
              style: contentTextStyle)),
      pw.Container(
          padding: cellPadding,
          child: pw.Text('')), // Empty cell for 5th column
    ]));

    return rows;
  }

  List<pw.TableRow> _getPage2Table2RowsPart2Heading() {
    const pw.TextStyle contentTextStyle =
        pw.TextStyle(fontSize: 10); // Increased font size to 10
    const pw.EdgeInsets cellPadding = pw.EdgeInsets.all(3);

    List<pw.TableRow> rows = [];

    // Item 15. Dimensions of the site (main header, 4-column like before)
    rows.add(pw.TableRow(children: [
      pw.Container(
          padding: cellPadding, child: pw.Text('15.', style: contentTextStyle)),
      pw.Container(
          padding: cellPadding,
          child: pw.Text('Dimensions of the site', style: contentTextStyle)),
    ]));

    return rows;
  }

  List<pw.TableRow> _getPage2Table2RowsPart2() {
    const pw.TextStyle contentTextStyle =
        pw.TextStyle(fontSize: 10); // Increased font size to 10
    const pw.EdgeInsets cellPadding = pw.EdgeInsets.all(3);

    List<pw.TableRow> rows = [];

    // Item 15. Dimensions of the site (sub-header, now 5 columns)
    rows.add(pw.TableRow(
      children: [
        pw.Container(
            padding: cellPadding, child: pw.Text('')), // S.No column (empty)
        pw.Container(
            padding: cellPadding,
            child: pw.Text('Directions', style: contentTextStyle)),
        pw.Container(
            padding: cellPadding,
            child: pw.Text('As per Actuals', style: contentTextStyle)),
        pw.Container(
            padding: cellPadding,
            child: pw.Text('As per Documents', style: contentTextStyle)),
        pw.Container(
            padding: cellPadding,
            child: pw.Text('Adopted area in Sft', style: contentTextStyle)),
      ],
    ));
    rows.add(pw.TableRow(children: [
      pw.Container(padding: cellPadding, child: pw.Text('')),
      pw.Container(
          padding: cellPadding,
          child: pw.Text('North', style: contentTextStyle)),
      pw.Container(
          padding: cellPadding,
          child: pw.Text(_dimNorthActualsController.text,
              style: contentTextStyle)),
      pw.Container(
          padding: cellPadding,
          child: pw.Text(_dimNorthDocumentsController.text,
              style: contentTextStyle)),
      pw.Container(
          padding: cellPadding,
          child: pw.Text(_dimNorthAdoptedController.text,
              style: contentTextStyle)),
    ]));
    rows.add(pw.TableRow(children: [
      pw.Container(padding: cellPadding, child: pw.Text('')),
      pw.Container(
          padding: cellPadding,
          child: pw.Text('South', style: contentTextStyle)),
      pw.Container(
          padding: cellPadding,
          child: pw.Text(_dimSouthActualsController.text,
              style: contentTextStyle)),
      pw.Container(
          padding: cellPadding,
          child: pw.Text(_dimSouthDocumentsController.text,
              style: contentTextStyle)),
      pw.Container(
          padding: cellPadding,
          child: pw.Text(_dimSouthAdoptedController.text,
              style: contentTextStyle)),
    ]));
    rows.add(pw.TableRow(children: [
      pw.Container(padding: cellPadding, child: pw.Text('')),
      pw.Container(
          padding: cellPadding,
          child: pw.Text('East', style: contentTextStyle)),
      pw.Container(
          padding: cellPadding,
          child:
              pw.Text(_dimEastActualsController.text, style: contentTextStyle)),
      pw.Container(
          padding: cellPadding,
          child: pw.Text(_dimEastDocumentsController.text,
              style: contentTextStyle)),
      pw.Container(
          padding: cellPadding,
          child:
              pw.Text(_dimEastAdoptedController.text, style: contentTextStyle)),
    ]));
    rows.add(pw.TableRow(children: [
      pw.Container(padding: cellPadding, child: pw.Text('')),
      pw.Container(
          padding: cellPadding,
          child: pw.Text('West', style: contentTextStyle)),
      pw.Container(
          padding: cellPadding,
          child:
              pw.Text(_dimWestActualsController.text, style: contentTextStyle)),
      pw.Container(
          padding: cellPadding,
          child: pw.Text(_dimWestDocumentsController.text,
              style: contentTextStyle)),
      pw.Container(
          padding: cellPadding,
          child:
              pw.Text(_dimWestAdoptedController.text, style: contentTextStyle)),
    ]));
    rows.add(pw.TableRow(children: [
      pw.Container(padding: cellPadding, child: pw.Text('')),
      pw.Container(
          padding: cellPadding,
          child: pw.Text('Total Area', style: contentTextStyle)),
      pw.Container(
          padding: cellPadding,
          child: pw.Text(_dimTotalAreaActualsController.text,
              style: contentTextStyle)),
      pw.Container(
          padding: cellPadding,
          child: pw.Text(_dimTotalAreaDocumentsController.text,
              style: contentTextStyle)),
      pw.Container(
          padding: cellPadding,
          child: pw.Text(_dimTotalAreaAdoptedController.text,
              style: contentTextStyle)),
    ]));
    rows.add(pw.TableRow(children: [
      pw.Container(padding: cellPadding, child: pw.Text('')),
      pw.Container(
          padding: cellPadding,
          child: pw.Text('Deviations if any :', style: contentTextStyle)),
    ]));

    return rows;
  }

  // Helper function to get table rows for Page 2 - Table 3 (Items 16-17)
  List<pw.TableRow> _getPage2Table3Rows() {
    const pw.TextStyle contentTextStyle =
        pw.TextStyle(fontSize: 10); // Increased font size to 10
    const pw.EdgeInsets cellPadding = pw.EdgeInsets.all(3);

    List<pw.TableRow> rows = [];

    // Item 16
    rows.add(pw.TableRow(children: [
      pw.Container(
          padding: cellPadding, child: pw.Text('16.', style: contentTextStyle)),
      pw.Container(
          padding: cellPadding,
          child: pw.Text('Latitude, Longitude and Coordinates of the site',
              style: contentTextStyle)),
      pw.Container(
          padding: cellPadding, child: pw.Text(':', style: contentTextStyle)),
      pw.Container(
          padding: cellPadding,
          child: pw.Text(_latitudeLongitudeController.text,
              style: contentTextStyle)),
    ]));

    // Item 17
    rows.add(pw.TableRow(children: [
      pw.Container(
          padding: cellPadding, child: pw.Text('17.', style: contentTextStyle)),
      pw.Container(
          padding: cellPadding,
          child: pw.Text(
              'Whether occupied by the Self /tenant? If occupied by tenant, since how long? Rent received per month.',
              style: contentTextStyle)),
      pw.Container(
          padding: cellPadding, child: pw.Text(':', style: contentTextStyle)),
      pw.Container(
          padding: cellPadding,
          child: pw.Text(
            '${_occupiedBySelfTenantController.text}${_occupiedBySelfTenantController.text.toLowerCase() == 'tenant' && _occupiedByTenantSinceController.text.isNotEmpty ? ', since ${_occupiedByTenantSinceController.text}' : ''}${_rentReceivedPerMonthController.text.isNotEmpty ? '. Rent: ${_rentReceivedPerMonthController.text}' : ''}',
            style: contentTextStyle,
          )),
    ]));

    return rows;
  }

  // Helper function to get table rows for new section 18
  List<pw.TableRow> _getPage2Table4Rows() {
    const pw.TextStyle contentTextStyle =
        pw.TextStyle(fontSize: 10); // Increased font size to 10
    const pw.EdgeInsets cellPadding = pw.EdgeInsets.all(3);

    List<pw.TableRow> rows = [];

    rows.add(
      pw.TableRow(
        children: [
          pw.Container(
              padding: cellPadding,
              child: pw.Text('18.', style: contentTextStyle)),
          pw.Container(
              padding: cellPadding,
              child: pw.Text('Details /Floors', style: contentTextStyle)),
          pw.Container(
              padding: cellPadding,
              child:
                  pw.Text('Occupancy\n(Self/Rented)', style: contentTextStyle)),
          pw.Container(
              padding: cellPadding,
              child: pw.Text('No. Of Room', style: contentTextStyle)),
          pw.Container(
              padding: cellPadding,
              child: pw.Text('No. Of Kitchen', style: contentTextStyle)),
          pw.Container(
              padding: cellPadding,
              child: pw.Text('No. of Bathroom', style: contentTextStyle)),
          pw.Container(
              padding: cellPadding,
              child: pw.Text('Usage Remarks\n(Resi/Comm)',
                  style: contentTextStyle)),
        ],
      ),
    );

    // Ground Floor Row
    rows.add(
      pw.TableRow(
        children: [
          pw.Container(
              padding: cellPadding, child: pw.Text('')), // Empty for S.No.
          pw.Container(
              padding: cellPadding,
              child: pw.Text('Ground', style: contentTextStyle)),
          pw.Container(
              padding: cellPadding,
              child: pw.Text(_groundFloorOccupancyController.text,
                  style: contentTextStyle)),
          pw.Container(
              padding: cellPadding,
              child: pw.Text(_groundFloorNoOfRoomController.text,
                  style: contentTextStyle)),
          pw.Container(
              padding: cellPadding,
              child: pw.Text(_groundFloorNoOfKitchenController.text,
                  style: contentTextStyle)),
          pw.Container(
              padding: cellPadding,
              child: pw.Text(_groundFloorNoOfBathroomController.text,
                  style: contentTextStyle)),
          pw.Container(
              padding: cellPadding,
              child: pw.Text(_groundFloorUsageRemarksController.text,
                  style: contentTextStyle)),
        ],
      ),
    );

    // First Floor Row
    rows.add(
      pw.TableRow(
        children: [
          pw.Container(
              padding: cellPadding, child: pw.Text('')), // Empty for S.No.
          pw.Container(
              padding: cellPadding,
              child: pw.Text('First', style: contentTextStyle)),
          pw.Container(
              padding: cellPadding,
              child: pw.Text(_firstFloorOccupancyController.text,
                  style: contentTextStyle)),
          pw.Container(
              padding: cellPadding,
              child: pw.Text(_firstFloorNoOfRoomController.text,
                  style: contentTextStyle)),
          pw.Container(
              padding: cellPadding,
              child: pw.Text(_firstFloorNoOfKitchenController.text,
                  style: contentTextStyle)),
          pw.Container(
              padding: cellPadding,
              child: pw.Text(_firstFloorNoOfBathroomController.text,
                  style: contentTextStyle)),
          pw.Container(
              padding: cellPadding,
              child: pw.Text(_firstFloorUsageRemarksController.text,
                  style: contentTextStyle)),
        ],
      ),
    );

    // Note: "Add Row" functionality implies dynamic addition which is not implemented here.
    // You would typically manage a list of floor data models to dynamically generate rows.

    return rows;
  }

  // Helper function to get table rows for new section (Items 19-20)
  List<pw.TableRow> _getPage2Table5Rows() {
    const pw.TextStyle contentTextStyle =
        pw.TextStyle(fontSize: 10); // Increased font size to 10
    const pw.EdgeInsets cellPadding = pw.EdgeInsets.all(3);

    List<pw.TableRow> rows = [];

    rows.add(pw.TableRow(children: [
      pw.Container(
          padding: cellPadding, child: pw.Text('19.', style: contentTextStyle)),
      pw.Container(
          padding: cellPadding,
          child: pw.Text(
              'Type of road available at present :\n(Bitumen/Mud/CC/Private)',
              style: contentTextStyle)),
      pw.Container(
          padding: cellPadding, child: pw.Text(':', style: contentTextStyle)),
      pw.Container(
          padding: cellPadding,
          child: pw.Text(_typeOfRoadController.text, style: contentTextStyle)),
    ]));
    rows.add(pw.TableRow(children: [
      pw.Container(
          padding: cellPadding, child: pw.Text('20.', style: contentTextStyle)),
      pw.Container(
          padding: cellPadding,
          child: pw.Text('Width of road - in feet', style: contentTextStyle)),
      pw.Container(
          padding: cellPadding, child: pw.Text(':', style: contentTextStyle)),
      pw.Container(
          padding: cellPadding,
          child: pw.Text(_widthOfRoadController.text, style: contentTextStyle)),
    ]));

    return rows;
  }

  // Helper function to get table rows for Page 3 (Item 21)
  List<pw.TableRow> _getPage3TableRows() {
    const pw.TextStyle contentTextStyle = pw.TextStyle(fontSize: 10);
    const pw.EdgeInsets cellPadding = pw.EdgeInsets.all(3);

    List<pw.TableRow> rows = [];

    rows.add(pw.TableRow(children: [
      pw.Container(
          padding: cellPadding, child: pw.Text('21.', style: contentTextStyle)),
      pw.Container(
          padding: cellPadding,
          child:
              pw.Text('Is it a land - locked land?', style: contentTextStyle)),
      pw.Container(
          padding: cellPadding, child: pw.Text(':', style: contentTextStyle)),
      pw.Container(
          padding: cellPadding,
          child:
              pw.Text(_isLandLockedController.text, style: contentTextStyle)),
    ]));

    return rows;
  }

  List<pw.TableRow> _getLandValuationTableRowsHeading() {
    const pw.EdgeInsets cellPadding = pw.EdgeInsets.all(3);
    List<pw.TableRow> rows = [];

    rows.add(pw.TableRow(
      children: [
        pw.Container(
          padding: cellPadding,
          alignment: pw.Alignment.centerLeft,
          child: pw.Text('Part - A (Valuation of land)',
              style:
                  pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
        ),
      ],
    ));

    return rows;
  }

  // NEW: Helper function to get table rows for "Part - A (Valuation of land)"
  List<pw.TableRow> _getLandValuationTableRows() {
    final pw.TextStyle headerTextStyle =
        pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10);
    const pw.TextStyle contentTextStyle = pw.TextStyle(fontSize: 10);
    const pw.EdgeInsets cellPadding = pw.EdgeInsets.all(3);

    List<pw.TableRow> rows = [];

    // Headers Row
    rows.add(pw.TableRow(
      children: [
        pw.Container(
            padding: cellPadding, child: pw.Text('1', style: contentTextStyle)),
        pw.Container(
            padding: cellPadding,
            alignment: pw.Alignment.center,
            child: pw.Text('Details', style: headerTextStyle)),
        pw.Container(
            padding: cellPadding,
            alignment: pw.Alignment.center,
            child: pw.Text('Land area in\nSq Ft', style: headerTextStyle)),
        pw.Container(
            padding: cellPadding,
            alignment: pw.Alignment.center,
            child: pw.Text('Rate per Sq ft', style: headerTextStyle)),
        pw.Container(
            padding: cellPadding,
            alignment: pw.Alignment.center,
            child: pw.Text('Value in Rs.', style: headerTextStyle)),
      ],
    ));

    // Row 2: Guideline rate
    rows.add(pw.TableRow(
      children: [
        pw.Container(
            padding: cellPadding,
            child: pw.Text('2.', style: contentTextStyle)),
        pw.Container(
            padding: cellPadding,
            child: pw.Text(
                'Guideline rate obtained from the Registrar\'s Office (an evidence thereof to be enclosed)',
                style: contentTextStyle)),
        pw.Container(
            padding: cellPadding,
            child: pw.Text(_landAreaGuidelineController.text,
                style: contentTextStyle)),
        pw.Container(
            padding: cellPadding,
            child: pw.Text(_ratePerSqFtGuidelineController.text,
                style: contentTextStyle)),
        pw.Container(
            padding: cellPadding,
            child: pw.Text(_valueInRsGuidelineController.text,
                style: contentTextStyle)),
      ],
    ));

    // Row 3: Prevailing market value
    rows.add(pw.TableRow(
      children: [
        pw.Container(
            padding: cellPadding,
            child: pw.Text('3.', style: contentTextStyle)),
        pw.Container(
            padding: cellPadding,
            child: pw.Text('Prevailing market value of the land',
                style: contentTextStyle)),
        pw.Container(
            padding: cellPadding,
            child: pw.Text(_landAreaPrevailingController.text,
                style: contentTextStyle)),
        pw.Container(
            padding: cellPadding,
            child: pw.Text(_ratePerSqFtPrevailingController.text,
                style: contentTextStyle)),
        pw.Container(
            padding: cellPadding,
            child: pw.Text(_valueInRsPrevailingController.text,
                style: contentTextStyle)),
      ],
    ));

    return rows;
  }

  // NEW: Helper function to get table rows for "Part - B (Valuation of Building)"

  List<pw.TableRow> _getBuildingValuationTableRowsHeading() {
    const pw.EdgeInsets cellPadding = pw.EdgeInsets.all(3);

    List<pw.TableRow> rows = [];

    // Main Header
    rows.add(pw.TableRow(
      children: [
        pw.Container(
          padding: cellPadding,
          alignment: pw.Alignment.centerLeft,
          child: pw.Text('Part - B (Valuation of Building)',
              style:
                  pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
        ),
      ],
    ));

    return rows;
  }

  List<pw.TableRow> _getBuildingValuationTableRowsSubHeading() {
    const pw.EdgeInsets cellPadding = pw.EdgeInsets.all(3);
    final pw.TextStyle headerTextStyle =
        pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10);
    const pw.TextStyle contentTextStyle = pw.TextStyle(fontSize: 10);

    List<pw.TableRow> rows = [];

    rows.add(pw.TableRow(
      children: [
        pw.Container(
            padding: cellPadding,
            child: pw.Text('1.', style: contentTextStyle)),
        pw.Container(
            padding: cellPadding,
            child: pw.Text('Technical details of the building',
                style: headerTextStyle)),
      ],
    ));

    return rows;
  }

  List<pw.TableRow> _getBuildingValuationTableRows() {
    const pw.TextStyle contentTextStyle = pw.TextStyle(fontSize: 10);
    const pw.EdgeInsets cellPadding = pw.EdgeInsets.all(3);

    List<pw.TableRow> rows = [];

    // Rows for technical details
    rows.add(pw.TableRow(
      children: [
        pw.Container(padding: cellPadding, child: pw.Text('')),
        pw.Container(
            padding: cellPadding, child: pw.Text('a', style: contentTextStyle)),
        pw.Container(
            padding: cellPadding,
            child: pw.Text(
                'Type of Building (Residential / Commercial / Industrial)',
                style: contentTextStyle)),
        pw.Container(
            padding: cellPadding,
            child: pw.Text(_typeOfBuildingController.text,
                style: contentTextStyle)),
      ],
    ));
    rows.add(pw.TableRow(
      children: [
        pw.Container(padding: cellPadding, child: pw.Text('')),
        pw.Container(
            padding: cellPadding, child: pw.Text('b', style: contentTextStyle)),
        pw.Container(
            padding: cellPadding,
            child: pw.Text(
                'Type of construction (Load bearing / RCC / Steel Framed)',
                style: contentTextStyle)),
        pw.Container(
            padding: cellPadding,
            child: pw.Text(_typeOfConstructionController.text,
                style: contentTextStyle)),
      ],
    ));
    rows.add(pw.TableRow(
      children: [
        pw.Container(padding: cellPadding, child: pw.Text('')),
        pw.Container(
            padding: cellPadding, child: pw.Text('c', style: contentTextStyle)),
        pw.Container(
            padding: cellPadding,
            child: pw.Text('Age of the building', style: contentTextStyle)),
        pw.Container(
            padding: cellPadding,
            child: pw.Text(_ageOfTheBuildingController.text,
                style: contentTextStyle)),
      ],
    ));
    rows.add(pw.TableRow(
      children: [
        pw.Container(padding: cellPadding, child: pw.Text('')),
        pw.Container(
            padding: cellPadding, child: pw.Text('d', style: contentTextStyle)),
        pw.Container(
            padding: cellPadding,
            child: pw.Text('Residual age of the building',
                style: contentTextStyle)),
        pw.Container(
            padding: cellPadding,
            child: pw.Text(_residualAgeOfTheBuildingController.text,
                style: contentTextStyle)),
      ],
    ));
    rows.add(pw.TableRow(
      children: [
        pw.Container(padding: cellPadding, child: pw.Text('')),
        pw.Container(
            padding: cellPadding, child: pw.Text('e', style: contentTextStyle)),
        pw.Container(
            padding: cellPadding,
            child: pw.Text('Approved map / plan issuing authority',
                style: contentTextStyle)),
        pw.Container(
            padding: cellPadding,
            child: pw.Text(_approvedMapAuthorityController.text,
                style: contentTextStyle)),
      ],
    ));
    rows.add(pw.TableRow(
      children: [
        pw.Container(padding: cellPadding, child: pw.Text('')),
        pw.Container(
            padding: cellPadding, child: pw.Text('f', style: contentTextStyle)),
        pw.Container(
            padding: cellPadding,
            child: pw.Text(
                'Whether genuineness or authenticity of approved map / plan is verified',
                style: contentTextStyle)),
        pw.Container(
            padding: cellPadding,
            child: pw.Text(_genuinenessVerifiedController.text,
                style: contentTextStyle)),
      ],
    ));
    rows.add(pw.TableRow(
      children: [
        pw.Container(padding: cellPadding, child: pw.Text('')),
        pw.Container(
            padding: cellPadding, child: pw.Text('g', style: contentTextStyle)),
        pw.Container(
            padding: cellPadding,
            child: pw.Text(
                'Any other comments by our empanelled valuers on authentic of approved plan',
                style: contentTextStyle)),
        pw.Container(
            padding: cellPadding,
            child: pw.Text(_otherCommentsController.text,
                style: contentTextStyle)),
      ],
    ));

    return rows;
  }

  // NEW: Helper function to get table rows for "Build up Area"
  List<pw.TableRow> _getBuildUpAreaTableRows() {
    final pw.TextStyle headerTextStyle =
        pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10);
    const pw.TextStyle contentTextStyle = pw.TextStyle(fontSize: 10);
    const pw.EdgeInsets cellPadding = pw.EdgeInsets.all(3);

    List<pw.TableRow> rows = [];

    // First header row
    rows.add(pw.TableRow(
      children: [
        pw.Container(
            padding: cellPadding,
            alignment: pw.Alignment.center,
            child: pw.Text('S n', style: headerTextStyle)),
        pw.Container(
            padding: cellPadding,
            alignment: pw.Alignment.center,
            child: pw.Text('Particular of item', style: headerTextStyle)),
        // "Build up Area" header - placed in the first of the three columns it spans
        pw.Container(
            padding: cellPadding,
            alignment: pw.Alignment.center,
            child: pw.Text('Build up Area', style: headerTextStyle)),
        pw.Container(), // Empty cell for the second column of "Build up Area" span
        pw.Container(), // Empty cell for the third column of "Build up Area" span
        pw.Container(
            padding: cellPadding,
            alignment: pw.Alignment.center,
            child: pw.Text('Replacement\nCost in Rs.', style: headerTextStyle)),
        pw.Container(
            padding: cellPadding,
            alignment: pw.Alignment.center,
            child: pw.Text('Depreciation\nin Rs.', style: headerTextStyle)),
        pw.Container(
            padding: cellPadding,
            alignment: pw.Alignment.center,
            child: pw.Text('Net value\nafter\nDepreciations Rs.',
                style: headerTextStyle)),
      ],
    ));

    // Second header row (sub-headers for "Build up Area")
    rows.add(pw.TableRow(
      children: [
        pw.Container(padding: cellPadding, child: pw.Text('')), // Empty for S n
        pw.Container(
            padding: cellPadding,
            child: pw.Text('')), // Empty for Particular of item
        pw.Container(
            padding: cellPadding,
            alignment: pw.Alignment.center,
            child:
                pw.Text('As per approved\nPlan/FSI', style: headerTextStyle)),
        pw.Container(
            padding: cellPadding,
            alignment: pw.Alignment.center,
            child: pw.Text('As per\nActual', style: headerTextStyle)),
        pw.Container(
            padding: cellPadding,
            alignment: pw.Alignment.center,
            child: pw.Text('Area\nConsidered\nfor the\nValuation',
                style: headerTextStyle)),
        pw.Container(
            padding: cellPadding,
            child: pw.Text('')), // Empty for Replacement Cost
        pw.Container(
            padding: cellPadding, child: pw.Text('')), // Empty for Depreciation
        pw.Container(
            padding: cellPadding, child: pw.Text('')), // Empty for Net value
      ],
    ));

    // Ground floor row
    rows.add(pw.TableRow(
      children: [
        pw.Container(
            padding: cellPadding, child: pw.Text('', style: contentTextStyle)),
        pw.Container(
            padding: cellPadding,
            child: pw.Text('Ground\nfloor', style: contentTextStyle)),
        pw.Container(
            padding: cellPadding,
            child: pw.Text(_groundFloorApprovedPlanController.text,
                style: contentTextStyle)),
        pw.Container(
            padding: cellPadding,
            child: pw.Text(_groundFloorActualController.text,
                style: contentTextStyle)),
        pw.Container(
            padding: cellPadding,
            child: pw.Text(_groundFloorConsideredValuationController.text,
                style: contentTextStyle)),
        pw.Container(
            padding: cellPadding,
            child: pw.Text(_groundFloorReplacementCostController.text,
                style: contentTextStyle)),
        pw.Container(
            padding: cellPadding,
            child: pw.Text(_groundFloorDepreciationController.text,
                style: contentTextStyle)),
        pw.Container(
            padding: cellPadding,
            child: pw.Text(_groundFloorNetValueController.text,
                style: contentTextStyle)),
      ],
    ));

    // First floor row
    rows.add(pw.TableRow(
      children: [
        pw.Container(
            padding: cellPadding, child: pw.Text('', style: contentTextStyle)),
        pw.Container(
            padding: cellPadding,
            child: pw.Text('First\nfloor', style: contentTextStyle)),
        pw.Container(
            padding: cellPadding,
            child: pw.Text(_firstFloorApprovedPlanController.text,
                style: contentTextStyle)),
        pw.Container(
            padding: cellPadding,
            child: pw.Text(_firstFloorActualController.text,
                style: contentTextStyle)),
        pw.Container(
            padding: cellPadding,
            child: pw.Text(_firstFloorConsideredValuationController.text,
                style: contentTextStyle)),
        pw.Container(
            padding: cellPadding,
            child: pw.Text(_firstFloorReplacementCostController.text,
                style: contentTextStyle)),
        pw.Container(
            padding: cellPadding,
            child: pw.Text(_firstFloorDepreciationController.text,
                style: contentTextStyle)),
        pw.Container(
            padding: cellPadding,
            child: pw.Text(_firstFloorNetValueController.text,
                style: contentTextStyle)),
      ],
    ));

    // Total row
    rows.add(pw.TableRow(
      children: [
        pw.Container(
            padding: cellPadding, child: pw.Text('', style: contentTextStyle)),
        pw.Container(
            padding: cellPadding,
            child: pw.Text('Total', style: headerTextStyle)),
        pw.Container(
            padding: cellPadding,
            child: pw.Text(_totalApprovedPlanController.text,
                style: contentTextStyle)),
        pw.Container(
            padding: cellPadding,
            child:
                pw.Text(_totalActualController.text, style: contentTextStyle)),
        pw.Container(
            padding: cellPadding,
            child: pw.Text(_totalConsideredValuationController.text,
                style: contentTextStyle)),
        pw.Container(
            padding: cellPadding,
            child: pw.Text(_totalReplacementCostController.text,
                style: contentTextStyle)),
        pw.Container(
            padding: cellPadding,
            child: pw.Text(_totalDepreciationController.text,
                style: contentTextStyle)),
        pw.Container(
            padding: cellPadding,
            child: pw.Text(_totalNetValueController.text,
                style: contentTextStyle)),
      ],
    ));

    return rows;
  }

  // NEW: Helper function to get table rows for "Part C - Amenities"
  List<pw.TableRow> _getAmenitiesTableRows() {
    final pw.TextStyle headerTextStyle =
        pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10);
    const pw.TextStyle contentTextStyle = pw.TextStyle(fontSize: 10);
    const pw.EdgeInsets cellPadding = pw.EdgeInsets.all(3);

    List<pw.TableRow> rows = [];

    rows.add(pw.TableRow(
      children: [
        pw.Container(
            padding: cellPadding,
            child: pw.Text('1.', style: contentTextStyle)),
        pw.Container(
            padding: cellPadding,
            child: pw.Text('Wardrobes', style: contentTextStyle)),
        pw.Container(
            padding: cellPadding, child: pw.Text(':', style: contentTextStyle)),
        pw.Container(
            padding: cellPadding,
            child: pw.Text(_wardrobesController.text, style: contentTextStyle)),
      ],
    ));
    rows.add(pw.TableRow(
      children: [
        pw.Container(
            padding: cellPadding,
            child: pw.Text('2.', style: contentTextStyle)),
        pw.Container(
            padding: cellPadding,
            child: pw.Text('Amenities', style: contentTextStyle)),
        pw.Container(
            padding: cellPadding, child: pw.Text(':', style: contentTextStyle)),
        pw.Container(
            padding: cellPadding,
            child: pw.Text(_amenitiesController.text, style: contentTextStyle)),
      ],
    ));
    rows.add(pw.TableRow(
      children: [
        pw.Container(
            padding: cellPadding,
            child: pw.Text('3.', style: contentTextStyle)),
        pw.Container(
            padding: cellPadding,
            child: pw.Text('Any other Additional', style: contentTextStyle)),
        pw.Container(
            padding: cellPadding, child: pw.Text(':', style: contentTextStyle)),
        pw.Container(
            padding: cellPadding,
            child: pw.Text(_anyOtherAdditionalController.text,
                style: contentTextStyle)),
      ],
    ));
    rows.add(pw.TableRow(
      children: [
        pw.Container(
            padding: cellPadding,
            child: pw.Text('4.', style: contentTextStyle)),
        pw.Container(
            padding: cellPadding, child: pw.Text('', style: contentTextStyle)),
        pw.Container(
            padding: cellPadding, child: pw.Text(':', style: contentTextStyle)),
        pw.Container(
            padding: cellPadding, child: pw.Text('', style: contentTextStyle)),
      ],
    ));
    rows.add(pw.TableRow(
      children: [
        pw.Container(
            padding: cellPadding,
            child: pw.Text('5.', style: contentTextStyle)),
        pw.Container(
            padding: cellPadding, child: pw.Text('', style: contentTextStyle)),
        pw.Container(
            padding: cellPadding, child: pw.Text(':', style: contentTextStyle)),
        pw.Container(
            padding: cellPadding, child: pw.Text('', style: contentTextStyle)),
      ],
    ));
    rows.add(pw.TableRow(
      children: [
        pw.Container(padding: cellPadding, child: pw.Text('')),
        pw.Container(
            padding: cellPadding,
            child: pw.Text('Total', style: headerTextStyle)),
        pw.Container(
            padding: cellPadding, child: pw.Text(':', style: headerTextStyle)),
        pw.Container(
            padding: cellPadding,
            child: pw.Text(_amenitiesTotalController.text,
                style: contentTextStyle)),
      ],
    ));

    return rows;
  }

  // NEW: Helper function to get table rows for "Total abstract of the entire property"
  List<pw.TableRow> _getTotalAbstractTableRows() {
    final pw.TextStyle headerTextStyle =
        pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10);
    const pw.TextStyle contentTextStyle = pw.TextStyle(fontSize: 10);
    const pw.EdgeInsets cellPadding = pw.EdgeInsets.all(3);

    List<pw.TableRow> rows = [];

    rows.add(pw.TableRow(
      children: [
        pw.Container(
            padding: cellPadding,
            child: pw.Text('Part- A', style: headerTextStyle)),
        pw.Container(
            padding: cellPadding,
            child: pw.Text('Land', style: contentTextStyle)),
        pw.Container(
            padding: cellPadding, child: pw.Text(':', style: contentTextStyle)),
        pw.Container(
            padding: cellPadding,
            child: pw.Text('₹ ${_totalAbstractLandController.text}',
                style: contentTextStyle)),
      ],
    ));
    rows.add(pw.TableRow(
      children: [
        pw.Container(
            padding: cellPadding,
            child: pw.Text('Part- B', style: headerTextStyle)),
        pw.Container(
            padding: cellPadding,
            child: pw.Text('Building', style: contentTextStyle)),
        pw.Container(
            padding: cellPadding, child: pw.Text(':', style: contentTextStyle)),
        pw.Container(
            padding: cellPadding,
            child: pw.Text('₹ ${_totalAbstractBuildingController.text}',
                style: contentTextStyle)),
      ],
    ));
    rows.add(pw.TableRow(
      children: [
        pw.Container(
            padding: cellPadding,
            child: pw.Text('Part- C', style: headerTextStyle)),
        pw.Container(
            padding: cellPadding,
            child: pw.Text('Amenities', style: contentTextStyle)),
        pw.Container(
            padding: cellPadding, child: pw.Text(':', style: contentTextStyle)),
        pw.Container(
            padding: cellPadding,
            child: pw.Text('₹ ${_totalAbstractAmenitiesController.text}',
                style: contentTextStyle)),
      ],
    ));
    rows.add(pw.TableRow(
      children: [
        pw.Container(
            padding: cellPadding, child: pw.Text('', style: contentTextStyle)),
        pw.Container(
            padding: cellPadding,
            child: pw.Text('Total', style: headerTextStyle)),
        pw.Container(
            padding: cellPadding, child: pw.Text(':', style: contentTextStyle)),
        pw.Container(
            padding: cellPadding,
            child: pw.Text('₹ ${_totalAbstractTotalController.text}',
                style: contentTextStyle)),
      ],
    ));
    rows.add(pw.TableRow(
      children: [
        pw.Container(
            padding: cellPadding, child: pw.Text('', style: contentTextStyle)),
        pw.Container(
            padding: cellPadding,
            child: pw.Text('Say', style: headerTextStyle)),
        pw.Container(
            padding: cellPadding, child: pw.Text(':', style: contentTextStyle)),
        pw.Container(
            padding: cellPadding,
            child: pw.Text('₹ ${_totalAbstractSayController.text}',
                style: contentTextStyle)),
      ],
    ));

    return rows;
  }

  // NEW: Helper function to get table rows for the final valuation table
  List<pw.TableRow> _getFinalValuationTableRows() {
    const pw.TextStyle contentTextStyle = pw.TextStyle(fontSize: 10);
    const pw.EdgeInsets cellPadding = pw.EdgeInsets.all(3);

    List<pw.TableRow> rows = [];

    rows.add(pw.TableRow(
      children: [
        pw.Container(
            padding: cellPadding,
            child: pw.Text('Present Market Value of The Property',
                style: contentTextStyle)),
        pw.Container(
            padding: cellPadding,
            child: pw.Text(_presentMarketValueController.text,
                style: contentTextStyle)),
      ],
    ));
    rows.add(pw.TableRow(
      children: [
        pw.Container(
            padding: cellPadding,
            child: pw.Text('Realizable Value of the Property',
                style: contentTextStyle)),
        pw.Container(
            padding: cellPadding,
            child: pw.Text(_realizableValueController.text,
                style: contentTextStyle)),
      ],
    ));
    rows.add(pw.TableRow(
      children: [
        pw.Container(
            padding: cellPadding,
            child: pw.Text('Distress Value of the Property',
                style: contentTextStyle)),
        pw.Container(
            padding: cellPadding,
            child: pw.Text(_distressValueController.text,
                style: contentTextStyle)),
      ],
    ));
    rows.add(pw.TableRow(
      children: [
        pw.Container(
            padding: cellPadding,
            child: pw.Text('Insurable Value of the property',
                style: contentTextStyle)),
        pw.Container(
            padding: cellPadding,
            child: pw.Text(_insurableValueController.text,
                style: contentTextStyle)),
      ],
    ));

    return rows;
  }

  // NEW: Helper function to get table rows for the Valuer Comments table
  List<pw.TableRow> _getValuerCommentsTableRows() {
    final pw.TextStyle headerTextStyle =
        pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10);
    const pw.TextStyle contentTextStyle =
        pw.TextStyle(fontSize: 9); // Slightly smaller font for content
    const pw.EdgeInsets cellPadding = pw.EdgeInsets.all(3);

    List<Map<String, dynamic>> data = [
      {
        'siNo': '1',
        'particulars': 'background information of the asset being valued;',
        'controller': _vcBackgroundInfoController
      },
      {
        'siNo': '2',
        'particulars': 'purpose of valuation and appointing authority',
        'controller': _vcPurposeOfValuationController
      },
      {
        'siNo': '3',
        'particulars':
            'identity of the valuer and any other experts involved in the valuation;',
        'controller': _vcIdentityOfValuerController
      },
      {
        'siNo': '4',
        'particulars': 'disclosure of valuer interest or conflict, if any;',
        'controller': _vcDisclosureOfInterestController
      },
      {
        'siNo': '5',
        'particulars':
            'date of appointment, valuation date and date of report;',
        'controller': _vcDateOfAppointmentController
      },
      {
        'siNo': '6',
        'particulars': 'inspections and/or investigations undertaken;',
        'controller': _vcInspectionsUndertakenController
      },
      {
        'siNo': '7',
        'particulars':
            'nature and sources of the information used or relied upon;',
        'controller': _vcNatureAndSourcesController
      },
      {
        'siNo': '8',
        'particulars':
            'procedures adopted in carrying out the valuation and valuation standards followed;',
        'controller': _vcProceduresAdoptedController
      },
      {
        'siNo': '9',
        'particulars': 'restrictions on use of the report, if any;',
        'controller': _vcRestrictionsOnUseController
      },
      {
        'siNo': '10',
        'particulars':
            'major factors that were taken into account during the valuation;',
        'controller': _vcMajorFactors1Controller
      },
      {
        'siNo': '11',
        'particulars':
            'major factors that were taken into account during the valuation;',
        'controller': _vcMajorFactors2Controller
      },
      {
        'siNo': '12',
        'particulars':
            'Caveats, limitations and disclaimers to the extent they explain or elucidate the limitations faced by valuer, which shall not be for the purpose of limiting his responsibility for the valuation report.',
        'controller': _vcCaveatsLimitationsController
      },
    ];

    List<pw.TableRow> rows = [];

    // Table Header
    rows.add(pw.TableRow(
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
    ));

    // Data Rows
    for (var item in data) {
      rows.add(pw.TableRow(
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
      ));
    }
    return rows;
  }

  // Function to generate the PDF
  Future<void> _generatePdf() async {
    final pdf = pw.Document();

    // Get selected documents
    final List<String> selectedDocuments = _documentChecks.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();

    // Get table rows for each section
    final List<pw.TableRow> page1Rows = _getPage1TableRows(selectedDocuments);
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
    final List<pw.TableRow> totalAbstractTableRows =
        _getTotalAbstractTableRows(); // NEW: Get rows for total abstract table
    final List<pw.TableRow> finalValuationTableRows =
        _getFinalValuationTableRows(); // NEW: Get rows for final valuation table
    final List<pw.TableRow> valuerCommentsTableRows =
        _getValuerCommentsTableRows(); // NEW: Get rows for valuer comments table

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
                      logoImage), // logoImage = pw.MemoryImage or pw.ImageProvider
                ),

                // Right side text
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text('VIGNESH. S',
                        style: pw.TextStyle(
                            fontSize: 14,
                            fontWeight: pw.FontWeight.bold,
                            color: pdfLib.PdfColors.indigo)),
                    pw.SizedBox(height: 4),
                    pw.Text('Chartered Engineer (AM1920793)',
                        style: const pw.TextStyle(
                            fontSize: 12, color: pdfLib.PdfColors.indigo)),
                    pw.Text(
                        'Registered valuer under section 247 of Companies Act, 2013',
                        style: const pw.TextStyle(
                            fontSize: 12, color: pdfLib.PdfColors.indigo)),
                    pw.Text('(IBBI/RV/01/2020/13411)',
                        style: const pw.TextStyle(
                            fontSize: 12, color: pdfLib.PdfColors.indigo)),
                    pw.Text(
                        'Registered valuer under section 34AB of Wealth Tax Act, 1957',
                        style: const pw.TextStyle(
                            fontSize: 12, color: pdfLib.PdfColors.indigo)),
                    pw.Text('(I-9AV/CC-TVM/2020-21)',
                        style: const pw.TextStyle(
                            fontSize: 12, color: pdfLib.PdfColors.indigo)),
                    pw.Text(
                        'Registered valuer under section 77(1) of Black Money Act, 2015',
                        style: const pw.TextStyle(
                            fontSize: 12, color: pdfLib.PdfColors.indigo)),
                    pw.Text('(I-3/AV-BM/PCIT-TVM/2023-24)',
                        style: const pw.TextStyle(
                            fontSize: 12, color: pdfLib.PdfColors.indigo)),
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
                      '#8a9b8e'), // Approx background color
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
                        pw.Text('Phone: +91 89030 42635',
                            style: const pw.TextStyle(fontSize: 12)),
                      ],
                    ),

                    // Email
                    pw.Row(
                      children: [
                        pw.Text('Email: subramonyvignesh@gmail.com',
                            style: const pw.TextStyle(fontSize: 12)),
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
                        pw.Text('To,',
                            style: pw.TextStyle(
                                fontSize: 12, fontWeight: pw.FontWeight.bold)),
                        pw.Text('The South Indian Bank',
                            style: const pw.TextStyle(fontSize: 12)),
                        pw.Text('Chakai Branch',
                            style: const pw.TextStyle(fontSize: 12)),
                        pw.Text('Thiruvananthapuram',
                            style: const pw.TextStyle(fontSize: 12)),
                      ],
                    ),
                    pw.Text('Ref No.: ${_refId.text}',
                        style: pw.TextStyle(
                            fontSize: 12, fontWeight: pw.FontWeight.bold)),
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
                    fontWeight:
                        pw.FontWeight.bold), // Slightly reduced font size
              ),
            ),
            pw.SizedBox(height: 8), // Reduced SizedBox height
            pw.Center(
              child: pw.Text(
                'VALUATION REPORT (IN RESPECT OF LAND / SITE AND BUILDING)',
                style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight:
                        pw.FontWeight.bold), // Slightly reduced font size
                textAlign: pw.TextAlign.center,
              ),
            ),
            pw.SizedBox(height: 15), // Reduced SizedBox height

            pw.Table(
              border:
                  pw.TableBorder.all(color: pdfLib.PdfColors.black, width: 0.5),
              columnWidths: {
                0: const pw.FlexColumnWidth(0.5), // S.No
                1: const pw.FlexColumnWidth(
                    3), // PROPERTY DETAILS (Description)
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
                      child: pw.Text('S.No',
                          style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 9)), // Reduced font size
                      decoration: pw.BoxDecoration(
                          border: pw.Border.all(
                              color: pdfLib.PdfColors.black, width: 0.5)),
                    ),
                    pw.Container(
                      alignment: pw.Alignment.center,
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Text('PROPERTY DETAILS',
                          style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 9)), // Reduced font size
                      decoration: pw.BoxDecoration(
                          border: pw.Border.all(
                              color: pdfLib.PdfColors.black, width: 0.5)),
                    ),
                    pw.Container(
                      alignment: pw.Alignment.center,
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Text('',
                          style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 9)), // Colon column header
                      decoration: pw.BoxDecoration(
                          border: pw.Border.all(
                              color: pdfLib.PdfColors.black, width: 0.5)),
                    ),
                    pw.Container(
                      alignment: pw.Alignment.center,
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Text('',
                          style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize:
                                  9)), // Value column header (empty as per request)
                      decoration: pw.BoxDecoration(
                          border: pw.Border.all(
                              color: pdfLib.PdfColors.black, width: 0.5)),
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
              border:
                  pw.TableBorder.all(color: pdfLib.PdfColors.black, width: 0.5),
              columnWidths: {
                0: const pw.FlexColumnWidth(0.5), // S.No
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
              border:
                  pw.TableBorder.all(color: pdfLib.PdfColors.black, width: 0.5),
              columnWidths: {
                0: const pw.FlexColumnWidth(0.1), // S.No
                1: const pw.FlexColumnWidth(1.5), // Directions
              },
              children: [
                ...page2Table2RowsHeading, // Add rows for the second table on page 2
              ],
            ),

            pw.Table(
              border:
                  pw.TableBorder.all(color: pdfLib.PdfColors.black, width: 0.5),
              columnWidths: {
                0: const pw.FlexColumnWidth(0.5), // S.No
                1: const pw.FlexColumnWidth(1.5), // Directions
                2: const pw.FlexColumnWidth(0.2), // As per Actuals
                3: const pw.FlexColumnWidth(
                    2.0), // As per Documents (slightly wider for text)
                4: const pw.FlexColumnWidth(
                    2.5), // Adopted area in Sft (wider to accommodate text)
              },
              children: [
                ...page2Table2Rows, // Add rows for the second table on page 2
              ],
            ),

            pw.Table(
              border:
                  pw.TableBorder.all(color: pdfLib.PdfColors.black, width: 0.5),
              columnWidths: {
                0: const pw.FlexColumnWidth(0.1), // S.No
                1: const pw.FlexColumnWidth(1.5), // Directions
              },
              children: [
                ...page2Table2RowsPart2Heading, // Add rows for the second table on page 2
              ],
            ),

            pw.Table(
              border:
                  pw.TableBorder.all(color: pdfLib.PdfColors.black, width: 0.5),
              columnWidths: {
                0: const pw.FlexColumnWidth(0.5), // S.No
                1: const pw.FlexColumnWidth(1.5), // Directions
                2: const pw.FlexColumnWidth(1.5), // As per Actuals
                3: const pw.FlexColumnWidth(
                    2.0), // As per Documents (slightly wider for text)
                4: const pw.FlexColumnWidth(
                    2.5), // Adopted area in Sft (wider to accommodate text)
              },
              children: [
                ...page2Table2RowsPart2, // Add rows for the second table on page 2
              ],
            ),

            // Third table on Page 2 (Items 16-17)
            pw.Table(
              border:
                  pw.TableBorder.all(color: pdfLib.PdfColors.black, width: 0.5),
              columnWidths: {
                0: const pw.FlexColumnWidth(0.5), // S.No
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
            pw.Table(
              border:
                  pw.TableBorder.all(color: pdfLib.PdfColors.black, width: 0.5),
              columnWidths: {
                0: const pw.FlexColumnWidth(0.5), // S.No.
                1: const pw.FlexColumnWidth(
                    1.5), // Details /Floors / Description
                2: const pw.FlexColumnWidth(
                    1.5), // Occupancy (Self/Rented) / Colon
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
              border:
                  pw.TableBorder.all(color: pdfLib.PdfColors.black, width: 0.5),
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
              border:
                  pw.TableBorder.all(color: pdfLib.PdfColors.black, width: 0.5),
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
              border:
                  pw.TableBorder.all(color: pdfLib.PdfColors.black, width: 0.5),
              columnWidths: {
                0: const pw.FlexColumnWidth(0.5), // Value in Rs.
              },
              children: [
                ...landValuationRowsHeading, // Add rows for the new land valuation table
              ],
            ),
            pw.Table(
              border:
                  pw.TableBorder.all(color: pdfLib.PdfColors.black, width: 0.5),
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
              border:
                  pw.TableBorder.all(color: pdfLib.PdfColors.black, width: 0.5),
              columnWidths: {
                0: const pw.FlexColumnWidth(0.5), // Value in Rs.
              },
              children: [
                ...buildingValuationRowsHeading, // Add rows for the new land valuation table
              ],
            ),

            pw.Table(
              border:
                  pw.TableBorder.all(color: pdfLib.PdfColors.black, width: 0.5),
              columnWidths: {
                0: const pw.FlexColumnWidth(0.25), // S.No
                1: const pw.FlexColumnWidth(5.0),
              },
              children: [
                ...buildingValuationTableRowsSubHeading, // Add rows for the new building valuation table
              ],
            ),

            pw.Table(
              border:
                  pw.TableBorder.all(color: pdfLib.PdfColors.black, width: 0.5),
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
              border:
                  pw.TableBorder.all(color: pdfLib.PdfColors.black, width: 0.5),
              columnWidths: {
                0: const pw.FlexColumnWidth(0.5), // S n
                1: const pw.FlexColumnWidth(1.5), // Particular of item
                2: const pw.FlexColumnWidth(1.5), // As per approved Plan/FSI
                3: const pw.FlexColumnWidth(1.5), // As per Actual
                4: const pw.FlexColumnWidth(
                    1.5), // Area Considered for the Valuation
                5: const pw.FlexColumnWidth(1.5), // Replacement Cost in Rs.
                6: const pw.FlexColumnWidth(1.5), // Depreciation in Rs.
                7: const pw.FlexColumnWidth(
                    1.5), // Net value after Depreciations Rs.
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
            pw.Center(
              child: pw.Text(
                'Details of Valuation',
                style:
                    pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12),
                textAlign: pw.TextAlign.center,
              ),
            ),
            pw.SizedBox(height: 30),

            pw.Center(
              child: pw.Text(
                'Part C- Amenities                                            (Amount in Rs.)',
                style:
                    pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12),
                textAlign: pw.TextAlign.center,
              ),
            ),

            pw.SizedBox(height: 10),
            pw.Table(
              border:
                  pw.TableBorder.all(color: pdfLib.PdfColors.black, width: 0.5),
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

            pw.Center(
              child: pw.Text(
                'Total abstract of the entire property',
                style:
                    pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12),
                textAlign: pw.TextAlign.center,
              ),
            ),
            pw.SizedBox(height: 30),

            // NEW: Total abstract of the entire property Table
            pw.Table(
              border:
                  pw.TableBorder.all(color: pdfLib.PdfColors.black, width: 0.5),
              columnWidths: {
                0: const pw.FlexColumnWidth(1.0), // Part
                1: const pw.FlexColumnWidth(2.0), // Description
                2: const pw.FlexColumnWidth(0.2), // Colon
                3: const pw.FlexColumnWidth(2.0), // Amount
              },
              children: [
                ...totalAbstractTableRows, // Add rows for total abstract table
              ],
            ),
            pw.SizedBox(height: 30),

            // NEW: Consolidated Remarks/ Observations of the property
            pw.Text(
              'Consolidated Remarks/ Observations of the property:',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12),
            ),
            pw.SizedBox(height: 30),
            pw.Text('1. ${_remark1Controller.text}',
                style: const pw.TextStyle(fontSize: 10)),
            pw.Text('2. ${_remark2Controller.text}',
                style: const pw.TextStyle(fontSize: 10)),
            pw.Text('3. ${_remark3Controller.text}',
                style: const pw.TextStyle(fontSize: 10)),
            pw.Text('4. ${_remark4Controller.text}',
                style: const pw.TextStyle(fontSize: 10)),
          ];
        },
      ),
    );

    // Page 5 - New page for the final valuation table
    pdf.addPage(pw.MultiPage(
        pageFormat: pdfLib.PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            pw.Center(
                child: pw.Column(children: [
              pw.Text(
                  '     (Valuation: Here the approved valuer should discuss in detail his approach to valuation of property and indicate how the value has been arrived at, supported by necessary calculations. Also, such aspects as i) Salability ii) Likely rental values in future in iii) Any likely income it may generate, may be discussed).',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              pw.Text(
                  'Photograph of owner/representative with property in background to be enclosed.'),
              pw.SizedBox(height: 10),
              pw.Text(
                  'Screen shot of longitude/latitude and co-ordinates of property using GPS/Various Apps/Internet sites'),
              pw.SizedBox(height: 10),
              pw.Text(
                  "As a result of my appraisal and analysis, it is my considered opinion that the present value's of the above property in the prevailing condition with aforesaid specifications is "),
              pw.SizedBox(height: 30),
              pw.Table(
                border: pw.TableBorder.all(
                    color: pdfLib.PdfColors.black, width: 0.5),
                columnWidths: {
                  0: const pw.FlexColumnWidth(3.0), // Description
                  1: const pw.FlexColumnWidth(2.0), // Value
                },
                children: [
                  ...finalValuationTableRows, // Add rows for the new final valuation table
                ],
              ),
            ])),
            pw.SizedBox(height: 30),
            pw.Text('Place: ',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
            pw.Text('Date: ',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
            pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Column(children: [
                  pw.Text('Signature',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 10),
                  pw.Text('(Name and Official seal of',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.Text('   the Approved Valuer)',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                ])),
            pw.SizedBox(height: 50),
            pw.Text('Encl: Declaration from the valuer in Format E'),
          ];
        }));

    if (_images.isNotEmpty) {
      final double pageWidth =
          pdfLib.PdfPageFormat.a4.availableWidth - (2 * 22); // Subtract margins
      final double pageHeight = pdfLib.PdfPageFormat.a4.availableHeight -
          (2 * 22); // Subtract margins

      // Calculate desired image dimensions for 3 images per row, 2 rows (6 images total)
      // Allow for some padding between images
      const double imageHorizontalPadding = 10;
      const double imageVerticalPadding = 10;
      // Width for 3 images: (pageWidth - 2 * padding) / 3
      final double targetImageWidth =
          (pageWidth - 2 * imageHorizontalPadding) / 3;
      // Height for 2 rows: (pageHeight - padding for title - 2 * vertical padding) / 2
      // Assuming 30 for title and its padding, and 20 for row spacing
      final double targetImageHeight =
          (pageHeight - 30 - 2 * imageVerticalPadding) / 2;

      for (int i = 0; i < _images.length; i += 6) {
        final List<pw.Widget> pageImages = [];
        for (int j = 0; j < 6 && (i + j) < _images.length; j++) {
          final imageItem =
              _images[i + j]; // Get the image item (File or Uint8List)
          try {
            pw.MemoryImage pwImage;
            if (imageItem is File) {
              pwImage = pw.MemoryImage(await imageItem.readAsBytes());
            } else if (imageItem is Uint8List) {
              pwImage = pw.MemoryImage(imageItem);
            } else {
              // Handle unexpected type, though with current logic this shouldn't happen
              print('Unexpected image type: ${imageItem.runtimeType}');
              continue;
            }

            // Calculate scaled dimensions to fit within target size without cropping
            double originalWidth = pwImage.width?.toDouble() ?? 1.0;
            double originalHeight = pwImage.height?.toDouble() ?? 1.0;

            double scale = 1.0;
            if (originalWidth > targetImageWidth) {
              scale = targetImageWidth / originalWidth;
            }
            if (originalHeight * scale > targetImageHeight) {
              scale = targetImageHeight / originalHeight;
            }

            final double finalWidth = originalWidth * scale;
            final double finalHeight = originalHeight * scale;

            pageImages.add(
              pw.SizedBox(
                width: targetImageWidth, // Allocate full cell width
                height: targetImageHeight, // Allocate full cell height
                child: pw.Center(
                  // Center the image within its allocated space
                  child: pw.Image(
                    pwImage,
                    width: finalWidth,
                    height: finalHeight,
                    fit: pw.BoxFit.contain, // Use contain to avoid cropping
                  ),
                ),
              ),
            );
          } catch (e) {
            // Corrected from .name to .path for File, and just showing type for Uint8List
            String errorSource = (imageItem is File)
                ? imageItem.path
                : imageItem.runtimeType.toString();
            print('Error loading image: $errorSource, Error: $e');
            pageImages.add(
              pw.SizedBox(
                width: targetImageWidth,
                height: targetImageHeight,
                child: pw.Center(
                  child: pw.Text('Failed to load image: $errorSource'),
                ),
              ),
            );
          }
        }

        // Arrange images in a grid-like structure (2 rows of 3 images)
        List<pw.Widget> rows = [];
        for (int k = 0; k < pageImages.length; k += 3) {
          List<pw.Widget> rowChildren = [];
          for (int l = 0; l < 3 && (k + l) < pageImages.length; l++) {
            rowChildren.add(
              pw.Expanded(
                child: pageImages[k + l],
              ),
            );
          }
          rows.add(
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
              children: rowChildren,
            ),
          );
          if (k + 3 < pageImages.length) {
            rows.add(pw.SizedBox(
                height: imageVerticalPadding)); // Space between rows
          }
        }

        pdf.addPage(
          pw.MultiPage(
            pageFormat: pdfLib.PdfPageFormat.a4,
            margin: const pw.EdgeInsets.all(22),
            build: (context) => [
              pw.Center(
                child: pw.Text(
                  'PHOTO REPORT', // Renumbered
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                  ),
                  textAlign: pw.TextAlign.center,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Column(
                children: rows,
              ),
            ],
          ),
        );
      }
    }

    // NEW: FORMAT E - DECLARATION FROM VALUERS page
    pdf.addPage(
      pw.MultiPage(
        pageFormat: pdfLib.PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(50),
        build: (context) => [
          pw.Center(
            child: pw.Text(
              'FORMAT E',
              style: pw.TextStyle(
                fontSize: 12,
                fontWeight: pw.FontWeight.bold,
              ),
              textAlign: pw.TextAlign.center,
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Center(
            child: pw.Text(
              'DECLARATION FROM VALUERS',
              style: pw.TextStyle(
                fontSize: 12,
                fontWeight: pw.FontWeight.bold,
              ),
              textAlign: pw.TextAlign.center,
            ),
          ),
          pw.SizedBox(height: 30),
          pw.Text('I hereby declare that - ',
              style: const pw.TextStyle(fontSize: 12)),
          pw.SizedBox(height: 15),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'a. The information furnished in my valuation report dated ${_declarationDateAController.text} is true and correct to the best of my knowledge and belief and I have made an impartial and true valuation of the property.',
                style: const pw.TextStyle(fontSize: 12),
              ),
              pw.SizedBox(height: 15),
              pw.Text(
                'b. I have no direct or indirect interest in the property valued;',
                style: const pw.TextStyle(fontSize: 12),
              ),
              pw.SizedBox(height: 15),
              pw.Text(
                'c. I have personally inspected the property on ${_declarationDateCController.text} The work is not sub-contracted to any other valuer and carried out by myself.',
                style: const pw.TextStyle(fontSize: 12),
              ),
              pw.SizedBox(height: 15),
              pw.Text(
                'd. I have not been convicted of any offence and sentenced to a term of Imprisonment;',
                style: const pw.TextStyle(fontSize: 12),
              ),
              pw.SizedBox(height: 15),
              pw.Text(
                'e. I have not been found guilty of misconduct in my professional capacity.',
                style: const pw.TextStyle(fontSize: 12),
              ),
              pw.SizedBox(height: 15),
              pw.Text(
                'f. I have read the Handbook on Policy, Standards and procedure for Real Estate Valuation, 2011 of the IBA and this report is in conformity to the Standards enshrined for valuation in the Part-B of the above handbook to the best of my ability.',
                style: const pw.TextStyle(fontSize: 12),
              ),
              pw.SizedBox(height: 15),
              pw.Text(
                'g. I have read the International Valuation Standards (IVS) and the report submitted to the Bank for the respective asset class is in conformity to the Standards as enshrined for valuation in the IVS in General Standards and Asset Standards as applicable.',
                style: const pw.TextStyle(fontSize: 12),
              ),
              pw.SizedBox(height: 15),
              pw.Text(
                'h. I abide by the Model Code of Conduct for empanelment of valuer in the Bank. (Annexure III- A signed copy of same to be taken and kept along with this declaration)',
                style: const pw.TextStyle(fontSize: 12),
              ),
              pw.SizedBox(height: 15),
              pw.Text(
                'i. I am registered under Section 34 AB of the Wealth Tax Act, 1957.',
                style: const pw.TextStyle(fontSize: 12),
              ),
              pw.SizedBox(height: 15),
              pw.Text(
                'j. I am the proprietor / partner / authorized official of the firm / company, who is competent to sign this valuation report.',
                style: const pw.TextStyle(fontSize: 12),
              ),
              pw.SizedBox(height: 15),
              pw.Text(
                'k. Further, I hereby provide the following information.',
                style: const pw.TextStyle(fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );

    // NEW: Valuer Comments Table (Page 8)
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
            border:
                pw.TableBorder.all(color: pdfLib.PdfColors.black, width: 0.5),
            columnWidths: {
              0: const pw.FlexColumnWidth(0.5), // SI No.
              1: const pw.FlexColumnWidth(3.0), // Particulars
              2: const pw.FlexColumnWidth(4.0), // Valuer comment
            },
            children: valuerCommentsTableRows, // Use the generated rows
          ),
        ],
      ),
    );

    // Open the printing preview page instead of sharing/downloading directly
    await Printing.layoutPdf(
      onLayout: (pdfLib.PdfPageFormat format) async => pdf.save(),
    );
  }
 // 
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
              // ... [UI code remains unchanged] ...
              Center(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  margin: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(
                        255, 244, 238, 238), // Light background color
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: const Color.fromARGB(255, 204, 200, 200)
                            .withOpacity(0.3),
                        spreadRadius: 4,
                        blurRadius: 8,
                        offset: const Offset(0, 4), // Shadow position
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        // Changed from TextFormField to TextField
                        controller: _latController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                  Radius.circular(20))), // Applied new styling
                          hintText: 'Latitude',
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        // Changed from TextFormField to TextField
                        controller: _lonController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                  Radius.circular(20))), // Applied new styling
                          hintText: 'Longitude',
                        ),
                      ),
                      const SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton.icon(
                            onPressed: _getCurrentLocation,
                            icon: const Icon(Icons.my_location),
                            label: const Text('Get Location',
                                style: TextStyle(fontSize: 15.5)),
                            style: ButtonStyle(
                              fixedSize:
                                  WidgetStateProperty.all(const Size(200, 40)),
                              shape: WidgetStateProperty.all(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 15), // Spacing between buttons
                          ElevatedButton.icon(
                            onPressed: () {
                              _getNearbyProperty();
                            },
                            icon: const Icon(Icons.search),
                            label: const Text('Search',
                                style: TextStyle(fontSize: 15.5)),
                            style: ButtonStyle(
                              fixedSize:
                                  WidgetStateProperty.all(const Size(150, 40)),
                              shape: WidgetStateProperty.all(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),
              Center(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SavedDraftsSBILand(),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.search,
                    size: 30,
                  ),
                  label: const Text(
                    'Search Saved Drafts',
                    style: TextStyle(fontSize: 20),
                  ),
                  style: ButtonStyle(
                    fixedSize: WidgetStateProperty.all(const Size(300, 50)),
                    shape: WidgetStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
              ),
              // ... [rest of UI code unchanged, all business logic, fields, PDF generation, etc. remain identical] ...
              const SizedBox(height: 20),

              TextField(
                decoration: const InputDecoration(
                  hintText: "Reference ID",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20))),
                ),
                controller: _refId,
              ),

              const SizedBox(height: 20),
              // Collapsible Section: I. PROPERTY DETAILS
              ExpansionTile(
                title: const Text(
                  'I. PROPERTY DETAILS',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                initiallyExpanded:
                    false, // You can set this to false to start collapsed
                children: <Widget>[
                  const Divider(),
                  TextField(
                    // Changed from _buildTextField
                    controller: _purposeController,
                    decoration: const InputDecoration(
                      labelText: '1. Purpose for which the valuation is made',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20))),
                    ),
                  ),
                  TextField(
                    // Changed from _buildTextField
                    controller: _dateOfInspectionController,
                    readOnly: true,
                    onTap: () =>
                        _selectDate(context, _dateOfInspectionController),
                    decoration: const InputDecoration(
                      labelText: '2. a) Date of inspection',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20))),
                    ),
                  ),
                  TextField(
                    // Changed from _buildTextField
                    controller: _dateOfValuationController,
                    readOnly: true,
                    onTap: () =>
                        _selectDate(context, _dateOfValuationController),
                    decoration: const InputDecoration(
                      labelText: '2. b) Date on which the valuation is made',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20))),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '3. List of documents produced for perusal',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  ..._documentChecks.keys.map((documentName) {
                    return CheckboxListTile(
                      title: Text(documentName),
                      value: _documentChecks[documentName],
                      onChanged: (bool? value) {
                        setState(() {
                          _documentChecks[documentName] = value!;
                        });
                      },
                    );
                  }),
                  const SizedBox(height: 16),
                  TextField(
                    // Changed from _buildTextField
                    controller: _ownerNameController,
                    decoration: const InputDecoration(
                      labelText: '4. Name of the owner(s)',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20))),
                    ),
                  ),
                  TextField(
                    // Changed from _buildTextField
                    controller: _applicantNameController,
                    decoration: const InputDecoration(
                      labelText: '5. Name of the applicant(s)',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20))),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '6. The address of the property (including pin code)',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  TextField(
                    // Changed from _buildTextField
                    controller: _addressDocController,
                    decoration: const InputDecoration(
                      labelText: '  As Per Documents',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20))),
                    ),
                  ),
                  TextField(
                    // Changed from _buildTextField
                    controller: _addressActualController,
                    decoration: const InputDecoration(
                      labelText: '  As per actual/postal',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20))),
                    ),
                  ),
                  TextField(
                    // Changed from _buildTextField
                    controller: _deviationsController,
                    decoration: const InputDecoration(
                      labelText: '7. Deviations if any',
                      hintText: 'Enter any deviations (e.g., "None")',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20))),
                    ),
                  ),
                  TextField(
                    // Changed from _buildTextField
                    controller: _propertyTypeController,
                    decoration: const InputDecoration(
                      labelText: '8. The property type (Leasehold/ Freehold)',
                      hintText: 'e.g., Leasehold or Freehold',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20))),
                    ),
                  ),
                  TextField(
                    // Changed from _buildTextField
                    controller: _propertyZoneController,
                    decoration: const InputDecoration(
                      labelText:
                          '9. Property Zone (Residential/ Commercial/ Industrial/ Agricultural)',
                      hintText: 'e.g., Residential',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20))),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20), // Spacer between collapsible sections

              // Collapsible Section: Additional Property Details
              ExpansionTile(
                title: const Text(
                  'Additional Property Details',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                initiallyExpanded: false,
                children: <Widget>[
                  const Divider(),
                  TextField(
                    // Changed from _buildTextField
                    controller: _classificationAreaController,
                    decoration: const InputDecoration(
                      labelText:
                          '10. i) Classification of the area (High / Middle / Poor)',
                      hintText: 'e.g., Middle',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20))),
                    ),
                  ),
                  TextField(
                    // Changed from _buildTextField
                    controller: _urbanSemiUrbanRuralController,
                    decoration: const InputDecoration(
                      labelText: '10. ii) Urban / Semi Urban / Rural',
                      hintText: 'e.g., Urban',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20))),
                    ),
                  ),
                  TextField(
                    // Changed from _buildTextField
                    controller: _comingUnderCorporationController,
                    decoration: const InputDecoration(
                      labelText:
                          '11. Coming under Corporation limit / Village Panchayat / Municipality',
                      hintText: 'e.g., Corporation limit',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20))),
                    ),
                  ),
                  TextField(
                    // Changed from _buildTextField
                    controller: _coveredUnderStateCentralGovtController,
                    decoration: const InputDecoration(
                      labelText:
                          '12. Whether covered under any State / Central Govt. enactments',
                      hintText: 'e.g., No',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20))),
                    ),
                  ),
                  TextField(
                    // Changed from _buildTextField
                    controller: _agriculturalLandConversionController,
                    decoration: const InputDecoration(
                      labelText:
                          '13. In case it is an agricultural land, any conversion to house site plots is contemplated',
                      hintText: 'e.g., Not applicable / Yes / No',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20))),
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    '14. Boundaries of the property',
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
                            Expanded(flex: 3, child: Text('As per Title Deed')),
                            Expanded(
                                flex: 3, child: Text('As per Location Sketch')),
                          ],
                        ),
                        _buildBoundaryRow(
                            'North',
                            _boundaryNorthTitleController,
                            _boundaryNorthSketchController),
                        _buildBoundaryRow(
                            'South',
                            _boundarySouthTitleController,
                            _boundarySouthSketchController),
                        _buildBoundaryRow('East', _boundaryEastTitleController,
                            _boundaryEastSketchController),
                        _buildBoundaryRow('West', _boundaryWestTitleController,
                            _boundaryWestSketchController),
                      ],
                    ),
                  ),
                  TextField(
                    // Changed from _buildTextField
                    controller: _boundaryDeviationsController,
                    decoration: const InputDecoration(
                      labelText: 'Deviations if any',
                      hintText: 'Enter any deviations (e.g., "None")',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20))),
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    '15. Dimensions of the site',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: Column(
                      children: [
                        const Row(
                          children: [
                            Expanded(flex: 2, child: Text('Directions')),
                            Expanded(flex: 3, child: Text('As per Actuals')),
                            Expanded(flex: 3, child: Text('As per Documents')),
                            Expanded(
                                flex: 3, child: Text('Adopted area in Sft')),
                          ],
                        ),
                        _buildDimensionsRow(
                            'North',
                            _dimNorthActualsController,
                            _dimNorthDocumentsController,
                            _dimNorthAdoptedController),
                        _buildDimensionsRow(
                            'South',
                            _dimSouthActualsController,
                            _dimSouthDocumentsController,
                            _dimSouthAdoptedController),
                        _buildDimensionsRow(
                            'East',
                            _dimEastActualsController,
                            _dimEastDocumentsController,
                            _dimEastAdoptedController),
                        _buildDimensionsRow(
                            'West',
                            _dimWestActualsController,
                            _dimWestDocumentsController,
                            _dimWestAdoptedController),
                        _buildDimensionsRow(
                            'Total Area',
                            _dimTotalAreaActualsController,
                            _dimTotalAreaDocumentsController,
                            _dimTotalAreaAdoptedController,
                            isTotalArea: true),
                      ],
                    ),
                  ),
                  TextField(
                    // Changed from _buildTextField
                    controller: _dimDeviationsController,
                    decoration: const InputDecoration(
                      labelText: 'Deviations if any',
                      hintText: 'Enter any deviations (e.g., "None")',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20))),
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
                          '16. Latitude, Longitude and Coordinates of the site',
                      hintText: 'e.g., 9.1234, 76.5678',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20))),
                    ),
                  ),
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
                            horizontal: 20, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  TextField(
                    // Changed from _buildTextField
                    controller: _occupiedBySelfTenantController,
                    decoration: const InputDecoration(
                      labelText: '17. Whether occupied by the Self /tenant?',
                      hintText: 'e.g., Self or Tenant',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20))),
                    ),
                  ),
                  TextField(
                    // Changed from _buildTextField
                    controller: _occupiedByTenantSinceController,
                    decoration: const InputDecoration(
                      labelText: '  If occupied by tenant, since how long?',
                      hintText: 'e.g., 5 years (leave blank if Self occupied)',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20))),
                    ),
                  ),
                  TextField(
                    // Changed from _buildTextField
                    controller: _rentReceivedPerMonthController,
                    decoration: const InputDecoration(
                      labelText: '  Rent received per month',
                      hintText: 'e.g., 10000 (leave blank if Self occupied)',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20))),
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    '18. Floor Details',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const Divider(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          children: [
                            Expanded(
                                flex: 2,
                                child: Text('Details /Floors',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold))),
                            Expanded(
                                flex: 2,
                                child: Text('Occupancy\n(Self/Rented)',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold))),
                            Expanded(
                                flex: 1,
                                child: Text('No. Of Room',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold))),
                            Expanded(
                                flex: 1,
                                child: Text('No. Of Kitchen',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold))),
                            Expanded(
                                flex: 1,
                                child: Text('No. of Bathroom',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold))),
                            Expanded(
                                flex: 2,
                                child: Text('Usage Remarks\n(Resi/Comm)',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold))),
                          ],
                        ),
                      ),
                      _buildFloorDetailRow(
                        'Ground',
                        _groundFloorOccupancyController,
                        _groundFloorNoOfRoomController,
                        _groundFloorNoOfKitchenController,
                        _groundFloorNoOfBathroomController,
                        _groundFloorUsageRemarksController,
                      ),
                      _buildFloorDetailRow(
                        'First',
                        _firstFloorOccupancyController,
                        _firstFloorNoOfRoomController,
                        _firstFloorNoOfKitchenController,
                        _firstFloorNoOfBathroomController,
                        _firstFloorUsageRemarksController,
                      ),
                    ],
                  ),
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
                          borderRadius: BorderRadius.all(Radius.circular(20))),
                    ),
                  ),
                  TextField(
                    // Changed from _buildTextField
                    controller: _widthOfRoadController,
                    decoration: const InputDecoration(
                      labelText: '20. Width of road - in feet',
                      hintText: 'e.g., 20',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20))),
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
                          borderRadius: BorderRadius.all(Radius.circular(20))),
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
                          borderRadius: BorderRadius.all(Radius.circular(20))),
                    ),
                  ),
                  TextField(
                    // Changed from _buildTextField
                    controller: _landAreaGuidelineController,
                    decoration: const InputDecoration(
                      labelText: '2. Guideline rate (Land area in Sq Ft)',
                      hintText: 'e.g., 1400',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20))),
                    ),
                  ),
                  TextField(
                    // Changed from _buildTextField
                    controller: _ratePerSqFtGuidelineController,
                    decoration: const InputDecoration(
                      labelText: '   Guideline rate (Rate per Sq ft)',
                      hintText: 'e.g., 2000',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20))),
                    ),
                  ),
                  TextField(
                    // Changed from _buildTextField
                    controller: _valueInRsGuidelineController,
                    decoration: const InputDecoration(
                      labelText: '   Guideline rate (Value in Rs.)',
                      hintText: 'e.g., 2800000',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20))),
                    ),
                  ),
                  TextField(
                    // Changed from _buildTextField
                    controller: _landAreaPrevailingController,
                    decoration: const InputDecoration(
                      labelText:
                          '3. Prevailing market value (Land area in Sq Ft)',
                      hintText: 'e.g., 1500',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20))),
                    ),
                  ),
                  TextField(
                    // Changed from _buildTextField
                    controller: _ratePerSqFtPrevailingController,
                    decoration: const InputDecoration(
                      labelText: '   Prevailing market value (Rate per Sq ft)',
                      hintText: 'e.g., 2500',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20))),
                    ),
                  ),
                  TextField(
                    // Changed from _buildTextField
                    controller: _valueInRsPrevailingController,
                    decoration: const InputDecoration(
                      labelText: '   Prevailing market value (Value in Rs.)',
                      hintText: 'e.g., 3750000',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20))),
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
                          borderRadius: BorderRadius.all(Radius.circular(20))),
                    ),
                  ),
                  TextField(
                    // Changed from _buildTextField
                    controller: _typeOfConstructionController,
                    decoration: const InputDecoration(
                      labelText:
                          '   b) Type of construction (Load bearing / RCC / Steel Framed)',
                      hintText: 'e.g., RCC',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20))),
                    ),
                  ),
                  TextField(
                    // Changed from _buildTextField
                    controller: _ageOfTheBuildingController,
                    decoration: const InputDecoration(
                      labelText: '   c) Age of the building',
                      hintText: 'e.g., 10 years',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20))),
                    ),
                  ),
                  TextField(
                    // Changed from _buildTextField
                    controller: _residualAgeOfTheBuildingController,
                    decoration: const InputDecoration(
                      labelText: '   d) Residual age of the building',
                      hintText: 'e.g., 40 years',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20))),
                    ),
                  ),
                  TextField(
                    // Changed from _buildTextField
                    controller: _approvedMapAuthorityController,
                    decoration: const InputDecoration(
                      labelText: '   e) Approved map / plan issuing authority',
                      hintText: 'e.g., Local Municipality',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20))),
                    ),
                  ),
                  TextField(
                    // Changed from _buildTextField
                    controller: _genuinenessVerifiedController,
                    decoration: const InputDecoration(
                      labelText:
                          '   f) Whether genuineness or authenticity of approved map / plan is verified',
                      hintText: 'YES / NO',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20))),
                    ),
                  ),
                  TextField(
                    // Changed from _buildTextField
                    controller: _otherCommentsController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText:
                          '   g) Any other comments by our empanelled valuers on authentic of approved plan',
                      hintText: 'e.g., None',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20))),
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
                  const Divider(),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      children: [
                        Expanded(
                            flex: 1,
                            child: Text('S n',
                                style: TextStyle(fontWeight: FontWeight.bold))),
                        Expanded(
                            flex: 2,
                            child: Text('Particular of item',
                                style: TextStyle(fontWeight: FontWeight.bold))),
                        Expanded(
                            flex: 2,
                            child: Text('As per approved\nPlan/FSI',
                                style: TextStyle(fontWeight: FontWeight.bold))),
                        Expanded(
                            flex: 2,
                            child: Text('As per Actual',
                                style: TextStyle(fontWeight: FontWeight.bold))),
                        Expanded(
                            flex: 2,
                            child: Text('Area Considered\nfor the Valuation',
                                style: TextStyle(fontWeight: FontWeight.bold))),
                        Expanded(
                            flex: 2,
                            child: Text('Replacement Cost\nin Rs.',
                                style: TextStyle(fontWeight: FontWeight.bold))),
                        Expanded(
                            flex: 2,
                            child: Text('Depreciation\nin Rs.',
                                style: TextStyle(fontWeight: FontWeight.bold))),
                        Expanded(
                            flex: 2,
                            child: Text('Net value after\nDepreciations Rs.',
                                style: TextStyle(fontWeight: FontWeight.bold))),
                      ],
                    ),
                  ),
                  _buildBuildUpAreaRow(
                    'Ground floor',
                    _groundFloorApprovedPlanController,
                    _groundFloorActualController,
                    _groundFloorConsideredValuationController,
                    _groundFloorReplacementCostController,
                    _groundFloorDepreciationController,
                    _groundFloorNetValueController,
                  ),
                  _buildBuildUpAreaRow(
                    'First floor',
                    _firstFloorApprovedPlanController,
                    _firstFloorActualController,
                    _firstFloorConsideredValuationController,
                    _firstFloorReplacementCostController,
                    _firstFloorDepreciationController,
                    _firstFloorNetValueController,
                  ),
                  _buildBuildUpAreaRow(
                    'Total',
                    _totalApprovedPlanController,
                    _totalActualController,
                    _totalConsideredValuationController,
                    _totalReplacementCostController,
                    _totalDepreciationController,
                    _totalNetValueController,
                    isTotal: true,
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
                          borderRadius: BorderRadius.all(Radius.circular(20))),
                    ),
                  ),
                  TextField(
                    // Changed from _buildTextField
                    controller: _amenitiesController,
                    decoration: const InputDecoration(
                      labelText: '2. Amenities (Amount in Rs.)',
                      hintText: 'e.g., 20000',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20))),
                    ),
                  ),
                  TextField(
                    // Changed from _buildTextField
                    controller: _anyOtherAdditionalController,
                    decoration: const InputDecoration(
                      labelText: '3. Any other Additional (Amount in Rs.)',
                      hintText: 'e.g., 10000',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20))),
                    ),
                  ),
                  TextField(
                    // Changed from _buildTextField
                    controller: _amenitiesTotalController,
                    decoration: const InputDecoration(
                      labelText: 'Total Amenities (Amount in Rs.)',
                      hintText: 'e.g., 80000',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20))),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

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
                          borderRadius: BorderRadius.all(Radius.circular(20))),
                    ),
                  ),
                  TextField(
                    // Changed from _buildTextField
                    controller: _totalAbstractBuildingController,
                    decoration: const InputDecoration(
                      labelText: 'Part- B Building (Amount in Rs.)',
                      hintText: 'e.g., 2500000',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20))),
                    ),
                  ),
                  TextField(
                    // Changed from _buildTextField
                    controller: _totalAbstractAmenitiesController,
                    decoration: const InputDecoration(
                      labelText: 'Part- C Amenities (Amount in Rs.)',
                      hintText: 'e.g., 80000',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20))),
                    ),
                  ),
                  TextField(
                    // Changed from _buildTextField
                    controller: _totalAbstractTotalController,
                    decoration: const InputDecoration(
                      labelText: 'Total (Amount in Rs.)',
                      hintText: 'e.g., 6330000',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20))),
                    ),
                  ),
                  TextField(
                    // Changed from _buildTextField
                    controller: _totalAbstractSayController,
                    decoration: const InputDecoration(
                      labelText: 'Say (Amount in Rs.)',
                      hintText: 'e.g., 6330000',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20))),
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
                          borderRadius: BorderRadius.all(Radius.circular(20))),
                    ),
                  ),
                  TextField(
                    // Changed from _buildTextField
                    controller: _remark2Controller,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: '2.',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20))),
                    ),
                  ),
                  TextField(
                    // Changed from _buildTextField
                    controller: _remark3Controller,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: '3.',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20))),
                    ),
                  ),
                  TextField(
                    // Changed from _buildTextField
                    controller: _remark4Controller,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: '4.',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20))),
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
                          borderRadius: BorderRadius.all(Radius.circular(20))),
                    ),
                  ),
                  TextField(
                    // Changed from _buildTextField
                    controller: _realizableValueController,
                    decoration: const InputDecoration(
                      labelText: 'Realizable Value of the Property',
                      hintText: 'Enter value',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20))),
                    ),
                  ),
                  TextField(
                    // Changed from _buildTextField
                    controller: _distressValueController,
                    decoration: const InputDecoration(
                      labelText: 'Distress Value of the Property',
                      hintText: 'Enter value',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20))),
                    ),
                  ),
                  TextField(
                    // Changed from _buildTextField
                    controller: _insurableValueController,
                    decoration: const InputDecoration(
                      labelText: 'Insurable Value of the property',
                      hintText: 'Enter value',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20))),
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
                          borderRadius: BorderRadius.all(Radius.circular(20))),
                    ),
                  ),
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
                          borderRadius: BorderRadius.all(Radius.circular(20))),
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
                            horizontal: 20, vertical: 10),
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
                                      'Invalid image type: ${imageItem.runtimeType}'));
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
                        horizontal: 30, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 5,
                    shadowColor: Colors.blueAccent.withOpacity(0.5),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              //
            ],
          ),
        ),
      ),
      floatingActionButton: ElevatedButton.icon(
        onPressed: () {
          _saveData();
        },
        icon: const Icon(Icons.save),
        label: const Text('Save', style: TextStyle(fontSize: 15.5)),
        style: ButtonStyle(
          fixedSize: WidgetStateProperty.all(const Size(100, 50)),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.endFloat,
    );
  }

  // ... [all helper widgets and functions remain unchanged] ...
  Widget _buildBoundaryRow(
      String direction,
      TextEditingController titleController,
      TextEditingController sketchController) {
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
                    borderRadius: BorderRadius.all(
                        Radius.circular(20))), // Applied new styling
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
                    borderRadius: BorderRadius.all(
                        Radius.circular(20))), // Applied new styling
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
      TextEditingController documentsController,
      TextEditingController adoptedController,
      {bool isTotalArea = false}) {
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
                    borderRadius: BorderRadius.all(
                        Radius.circular(20))), // Applied new styling
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
                    borderRadius: BorderRadius.all(
                        Radius.circular(20))), // Applied new styling
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 3,
            child: TextField(
              // Changed from _buildTextField
              controller: adoptedController,
              decoration: const InputDecoration(
                labelText: '',
                hintText: 'Adopted area in Sft',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                        Radius.circular(20))), // Applied new styling
              ),
            ),
          ),
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
                padding:
                    const EdgeInsets.only(top: 12.0), // Align text vertically
                child: Text(floorName),
              )),
          Expanded(
            flex: 2,
            child: TextField(
              // Changed from _buildTextField
              controller: occupancyController,
              decoration: const InputDecoration(
                labelText: '',
                hintText: 'Self/Rented',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                        Radius.circular(20))), // Applied new styling
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
                    borderRadius: BorderRadius.all(
                        Radius.circular(20))), // Applied new styling
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
                    borderRadius: BorderRadius.all(
                        Radius.circular(20))), // Applied new styling
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
                    borderRadius: BorderRadius.all(
                        Radius.circular(20))), // Applied new styling
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
                    borderRadius: BorderRadius.all(
                        Radius.circular(20))), // Applied new styling
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
      TextEditingController netValueController,
      {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
              flex: 1,
              child: Padding(
                padding:
                    const EdgeInsets.only(top: 12.0), // Align text vertically
                child:
                    Text(isTotal ? '' : ''), // Empty for S n for non-total rows
              )),
          Expanded(
              flex: 2,
              child: Padding(
                padding:
                    const EdgeInsets.only(top: 12.0), // Align text vertically
                child: Text(particularOfItem,
                    style: TextStyle(
                        fontWeight:
                            isTotal ? FontWeight.bold : FontWeight.normal)),
              )),
          Expanded(
            flex: 2,
            child: TextField(
              // Changed from _buildTextField
              controller: approvedPlanController,
              decoration: InputDecoration(
                labelText: '',
                hintText: isTotal ? 'Total Approved' : 'Approved Plan/FSI',
                border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                        Radius.circular(20))), // Applied new styling
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
                    borderRadius: BorderRadius.all(
                        Radius.circular(20))), // Applied new styling
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
                    borderRadius: BorderRadius.all(
                        Radius.circular(20))), // Applied new styling
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
                    borderRadius: BorderRadius.all(
                        Radius.circular(20))), // Applied new styling
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
                    borderRadius: BorderRadius.all(
                        Radius.circular(20))), // Applied new styling
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
                    borderRadius: BorderRadius.all(
                        Radius.circular(20))), // Applied new styling
              ),
            ),
          ),
        ],
      ),
    );
  }

  // NEW: Helper widget for Valuer Comments table rows (for UI)
  Widget _buildValuerCommentRow(
      String siNo, String particulars, TextEditingController controller,
      {String? hintText, int maxLines = 1}) {
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
              )),
          Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: Text(particulars),
              )),
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
                    borderRadius: BorderRadius.all(
                        Radius.circular(20))), // Applied new styling
              ),
            ),
          ),
        ],
      ),
    );
  }
}