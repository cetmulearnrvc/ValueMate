import 'package:flutter/material.dart';
import 'package:login_screen/screens/SIB/vacant_land/savedDraftsSIBVacantland.dart';
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
import 'dart:convert';
import 'package:http/http.dart' as http;
// import 'C:\flutter development\valuemate_1\ValueMate\lib\screens\SIB\vacant_land\savedDraftsSIBVacantland.dart';

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
      home: const VacantLandFormPage(propertyData: {}),
    );
  }
}

class VacantLandFormPage extends StatefulWidget {
  // const VacantLandFormPage({super.key});
  final Map<String, dynamic>? propertyData;
  const VacantLandFormPage({super.key, this.propertyData});

  @override
  State<VacantLandFormPage> createState() => _ValuationFormPageState();
}

class _ValuationFormPageState extends State<VacantLandFormPage> {
  @override
  void initState() {
    super.initState();
    if (widget.propertyData != null) {
      // Use the passed data to initialize your form only if it exists
      // debugPrint('Received property data: ${widget.propertyData}');
      // Example:
      // _fileNoController.text = widget.propertyData!['fileNo'].toString();
    } else {
      // debugPrint('No property data received - creating new valuation');
      // Initialize with empty/default values
    }
    _initializeFormWithPropertyData();
  }

  final TextEditingController _latController = TextEditingController();
  final TextEditingController _lonController = TextEditingController();

  final TextEditingController _latitude = TextEditingController();
  final TextEditingController _longitude = TextEditingController();

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

  final TextEditingController _LandTaxReceipt = TextEditingController();
  final TextEditingController _TitleDeed = TextEditingController();
  final TextEditingController _BuildingCertificate = TextEditingController();
  final TextEditingController _LocationSketch = TextEditingController();
  final TextEditingController _PossessionCertificate = TextEditingController();
  final TextEditingController _BuildingCompletionPlan = TextEditingController();
  final TextEditingController _ThandapperDocument = TextEditingController();
  final TextEditingController _BuildingTaxReceipt = TextEditingController();

  Future<pw.MemoryImage> loadLogoImage() async {
    final Uint8List bytes = await rootBundle
        .load('assets/images/logo.png')
        .then((data) => data.buffer.asUint8List());
    return pw.MemoryImage(bytes);
  }
  // // Checkbox states for documents (Page 1)
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

  Future<String> fetchSignedUrl(String imagePublicId) async {
    // --- YOU MUST CUSTOMIZE THESE VALUES ---
    const String apiKey =
        "db74f0da81338f1ad24d0be8298f90f4e6be5f0df5b53aca2f95ead470665641";
    const String apiBaseUrl = 'http://72.60.219.196/'; // For Android emulator
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
      _refId.text = data['refNo']?.toString() ?? '';

      // Set document checks
      _LandTaxReceipt.text = data['landTaxReceipt']?.toString() ?? '';
      _TitleDeed.text = data['titleDeed']?.toString() ?? '';
      _BuildingCertificate.text = data['buildingCertificate']?.toString() ?? '';
      _LocationSketch.text = data['locationSketch']?.toString() ?? '';
      _PossessionCertificate.text =
          data['possessionCertificate']?.toString() ?? '';
      _BuildingCompletionPlan.text =
          data['buildingCompletionPlan']?.toString() ?? '';
      _ThandapperDocument.text = data['thandapperDocument']?.toString() ?? '';
      _BuildingTaxReceipt.text = data['buildingTaxReceipt']?.toString() ?? '';

      // Page 1 fields
      _purposeController.text = data['purpose']?.toString() ?? '';

      // Handle date formatting
      if (data['dateOfInspection'] != null) {
        try {
          final inspectionDate = DateTime.parse(data['dateOfInspection']);
          _dateOfInspectionController.text =
              DateFormat('dd-MM-yyyy').format(inspectionDate);
        } catch (e) {
          _dateOfInspectionController.text =
              data['dateOfInspection']?.toString() ?? '';
        }
      }

      if (data['dateOfValuation'] != null) {
        try {
          final valuationDate = DateTime.parse(data['dateOfValuation']);
          _dateOfValuationController.text =
              DateFormat('dd-MM-yyyy').format(valuationDate);
        } catch (e) {
          _dateOfValuationController.text =
              data['dateOfValuation']?.toString() ?? '';
        }
      }

      _ownerNameController.text = data['ownerName']?.toString() ?? '';
      _applicantNameController.text = data['applicantName']?.toString() ?? '';
      _addressDocController.text =
          data['addressAsPerDocument']?.toString() ?? '';
      _addressActualController.text =
          data['addressAsPerActual']?.toString() ?? '';
      _deviationsController.text = data['deviations']?.toString() ?? '';
      _propertyTypeController.text = data['propertyType']?.toString() ?? '';
      _propertyZoneController.text = data['propertyZone']?.toString() ?? '';

      // Page 2 fields
      _classificationAreaController.text =
          data['classificationArea']?.toString() ?? '';
      _urbanSemiUrbanRuralController.text =
          data['urbanSemiUrbanRural']?.toString() ?? '';
      _comingUnderCorporationController.text =
          data['comingUnderCorporation']?.toString() ?? '';
      _coveredUnderStateCentralGovtController.text =
          data['coveredUnderStateCentralGovt']?.toString() ?? '';
      _agriculturalLandConversionController.text =
          data['agriculturalLandConversion']?.toString() ?? '';

      // Boundaries - handle both direct fields and JSON boundaries
      if (data['boundaries'] is String) {
        try {
          final boundaries = json.decode(data['boundaries']);
          _boundaryNorthTitleController.text =
              boundaries['north']?['titleDeed']?.toString() ?? '';
          _boundaryNorthSketchController.text =
              boundaries['north']?['sketch']?.toString() ?? '';
          _boundarySouthTitleController.text =
              boundaries['south']?['titleDeed']?.toString() ?? '';
          _boundarySouthSketchController.text =
              boundaries['south']?['sketch']?.toString() ?? '';
          _boundaryEastTitleController.text =
              boundaries['east']?['titleDeed']?.toString() ?? '';
          _boundaryEastSketchController.text =
              boundaries['east']?['sketch']?.toString() ?? '';
          _boundaryWestTitleController.text =
              boundaries['west']?['titleDeed']?.toString() ?? '';
          _boundaryWestSketchController.text =
              boundaries['west']?['sketch']?.toString() ?? '';
          _boundaryDeviationsController.text =
              boundaries['deviations']?.toString() ?? '';
        } catch (e) {
          // debugPrint('Error parsing boundaries JSON: $e');
        }
      } else {
        _boundaryNorthTitleController.text =
            data['boundaryNorthTitle']?.toString() ?? '';
        _boundaryNorthSketchController.text =
            data['boundaryNorthSketch']?.toString() ?? '';
        _boundarySouthTitleController.text =
            data['boundarySouthTitle']?.toString() ?? '';
        _boundarySouthSketchController.text =
            data['boundarySouthSketch']?.toString() ?? '';
        _boundaryEastTitleController.text =
            data['boundaryEastTitle']?.toString() ?? '';
        _boundaryEastSketchController.text =
            data['boundaryEastSketch']?.toString() ?? '';
        _boundaryWestTitleController.text =
            data['boundaryWestTitle']?.toString() ?? '';
        _boundaryWestSketchController.text =
            data['boundaryWestSketch']?.toString() ?? '';
        _boundaryDeviationsController.text =
            data['boundaryDeviations']?.toString() ?? '';
      }

      // Dimensions
      _dimNorthActualsController.text =
          data['dimNorthActuals']?.toString() ?? '';
      _dimSouthActualsController.text =
          data['dimSouthActuals']?.toString() ?? '';
      _dimEastActualsController.text = data['dimEastActuals']?.toString() ?? '';
      _dimWestActualsController.text = data['dimWestActuals']?.toString() ?? '';
      _dimTotalAreaActualsController.text =
          data['dimTotalAreaActuals']?.toString() ?? '';
      _dimNorthDocumentsController.text =
          data['dimNorthDocuments']?.toString() ?? '';
      _dimSouthDocumentsController.text =
          data['dimSouthDocuments']?.toString() ?? '';
      _dimEastDocumentsController.text =
          data['dimEastDocuments']?.toString() ?? '';
      _dimWestDocumentsController.text =
          data['dimWestDocuments']?.toString() ?? '';
      _dimTotalAreaDocumentsController.text =
          data['dimTotalAreaDocuments']?.toString() ?? '';
      _dimNorthAdoptedController.text =
          data['dimNorthAdopted']?.toString() ?? '';
      _dimSouthAdoptedController.text =
          data['dimSouthAdopted']?.toString() ?? '';
      _dimEastAdoptedController.text = data['dimEastAdopted']?.toString() ?? '';
      _dimWestAdoptedController.text = data['dimWestAdopted']?.toString() ?? '';
      _dimTotalAreaAdoptedController.text =
          data['dimTotalAreaAdopted']?.toString() ?? '';
      _dimDeviationsController.text = data['dimDeviations']?.toString() ?? '';

      // Location and coordinates
      _latitudeLongitudeController.text =
          data['latitudeLongitude']?.toString() ?? '';

      // Set lat/lon controllers if coordinates exist
      if (_latitudeLongitudeController.text.contains(',')) {
        final parts = _latitudeLongitudeController.text.split(',');
        if (parts.length >= 2) {
          _latController.text = parts[0].trim();
          _lonController.text = parts[1].trim();
        }
      }

      // Road details
      _typeOfRoadController.text = data['typeOfRoad']?.toString() ?? '';
      _widthOfRoadController.text = data['widthOfRoad']?.toString() ?? '';
      _isLandLockedController.text = data['isLandLocked']?.toString() ?? '';

      // Land Valuation
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

      // Total abstract values
      _totalAbstractLandController.text =
          data['totalAbstractLand']?.toString() ?? '';
      _totalAbstractBuildingController.text =
          data['totalAbstractBuilding']?.toString() ?? '';
      _totalAbstractAmenitiesController.text =
          data['totalAbstractAmenities']?.toString() ?? '';
      _totalAbstractTotalController.text =
          data['totalAbstractTotal']?.toString() ?? '';
      _totalAbstractSayController.text =
          data['totalAbstractSay']?.toString() ?? '';

      // Final valuation
      _presentMarketValueController.text =
          data['presentMarketValue']?.toString() ?? '';
      _realizableValueController.text =
          data['realizableValue']?.toString() ?? '';
      _distressValueController.text = data['distressValue']?.toString() ?? '';
      _insurableValueController.text = data['insurableValue']?.toString() ?? '';

      // Remarks
      _remark1Controller.text = data['remark1']?.toString() ?? '';
      _remark2Controller.text = data['remark2']?.toString() ?? '';
      _remark3Controller.text = data['remark3']?.toString() ?? '';
      _remark4Controller.text = data['remark4']?.toString() ?? '';

      // Declaration dates
      if (data['declarationDateA'] != null) {
        try {
          final dateA = DateTime.parse(data['declarationDateA']);
          _declarationDateAController.text =
              DateFormat('dd-MM-yyyy').format(dateA);
        } catch (e) {
          _declarationDateAController.text =
              data['declarationDateA']?.toString() ?? '';
        }
      }

      if (data['declarationDateC'] != null) {
        try {
          final dateC = DateTime.parse(data['declarationDateC']);
          _declarationDateCController.text =
              DateFormat('dd-MM-yyyy').format(dateC);
        } catch (e) {
          _declarationDateCController.text =
              data['declarationDateC']?.toString() ?? '';
        }
      }

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

      // Load images if available
      try {
        if (data['images'] != null && data['images'] is List) {
          final List<dynamic> imagesData = data['images'];
          for (var imgData in imagesData) {
            try {
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
              // debugPrint('Error loading image: $e');
            }
          }
        }
      } catch (e) {
        // debugPrint('Error in fetchImages: $e');
      }

      if (mounted) setState(() {});
      // debugPrint('SIB Vacant Land form initialized with property data');
    } else {
      // debugPrint( 'No property data - SIB Vacant Land form will use default values');
    }
  }

  Future<void> _getNearbyProperty() async {
    final latitude = _latitude.text.trim();
    final longitude = _longitude.text.trim();

    // debugPrint('Searching nearby properties at: $latitude, $longitude');

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
        body: jsonEncode({
          'latitude': latitude,
          'longitude': longitude,
        }),
      );

      if (response.statusCode == 200) {
        // Decode the JSON response
        final List<dynamic> responseData = jsonDecode(response.body);

        // Debug print the results
        // debugPrint('Nearby Properties Found: ${responseData.length}');
        for (var item in responseData) {
          // debugPrint(
          //     'Property: ${item['refNo'] ?? item['refId'] ?? 'N/A'} - ${item['ownerName'] ?? 'Unknown Owner'}');
        }

        if (context.mounted) {
          showModalBottomSheet(
            context: context,
            builder: (ctx) {
              return Nearbydetails(responseData: responseData);
            },
          );
        }
      } else if (response.statusCode == 404) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No nearby properties found'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Server error: ${response.statusCode}')),
        );
      }
    } catch (e) {
      // debugPrint('Error fetching nearby properties: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Network error: Please check your connection')),
      );
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
  List<pw.TableRow> _getPage1TableRows() {
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
    rows.add(
      pw.TableRow(
        children: [
          pw.Container(
              padding: cellPadding,
              child: pw.Text('3.', style: contentTextStyle)),
          pw.Container(
              padding: cellPadding,
              child: pw.Text('List of documents produced for perusal',
                  style: contentTextStyle)),
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
              child: pw.Text('', style: contentTextStyle)),
          pw.Container(
              padding: cellPadding,
              child: pw.Text('i) Land Tax Receipt (${_LandTaxReceipt.text})',
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
              child: pw.Text('ii) Title Deed (${_TitleDeed.text})',
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
              child: pw.Text(
                  'iii) Building Certificate (${_BuildingCertificate.text})',
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
              child: pw.Text('iv) Location Sketch (${_LocationSketch.text})',
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
              child: pw.Text(
                  'v) Possession Certificate (${_PossessionCertificate.text})',
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
              child: pw.Text(
                  'vi) Building Completion Plan (${_BuildingCompletionPlan.text})',
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
              child: pw.Text(
                  'vii) Thandapper Document (${_ThandapperDocument.text})',
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
              child: pw.Text(
                  'viii) Building Tax Receipt (${_BuildingTaxReceipt.text})',
                  style: contentTextStyle)),
        ],
      ),
    );

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
          padding: cellPadding, child: pw.Text('17.', style: contentTextStyle)),
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
          padding: cellPadding, child: pw.Text('18.', style: contentTextStyle)),
      pw.Container(
          padding: cellPadding,
          child: pw.Text('Width of road - in feet', style: contentTextStyle)),
      pw.Container(
          padding: cellPadding, child: pw.Text(':', style: contentTextStyle)),
      pw.Container(
          padding: cellPadding,
          child: pw.Text(_widthOfRoadController.text, style: contentTextStyle)),
    ]));
    rows.add(pw.TableRow(children: [
      pw.Container(
          padding: cellPadding, child: pw.Text('19.', style: contentTextStyle)),
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

    rows.add(pw.TableRow(children: [
      pw.Container(
          padding: cellPadding, child: pw.Text('20.', style: contentTextStyle)),
      pw.Container(
          padding: cellPadding,
          child: pw.Text('Type of Demarcation (Side stone/Fencing)',
              style: contentTextStyle)),
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
            child: pw.Text('Present Market Value of The Property',
                style: contentTextStyle)),
        pw.Container(
            padding: cellPadding,
            child: pw.Text(' ${_presentMarketValueController.text}',
                style: contentTextStyle)),
      ],
    ));
    rows.add(pw.TableRow(
      children: [
        pw.Container(
            padding: cellPadding,
            child: pw.Text('Realizable Value of the Property ',
                style: contentTextStyle)),
        pw.Container(
            padding: cellPadding,
            child: pw.Text(' ${_realizableValueController.text}',
                style: contentTextStyle)),
      ],
    ));
    rows.add(pw.TableRow(
      children: [
        pw.Container(
            padding: cellPadding,
            child: pw.Text('Distress Value of the Property ',
                style: contentTextStyle)),
        pw.Container(
            padding: cellPadding,
            child: pw.Text(' ${_distressValueController.text}',
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

    // below code were commented for changing to text field
    // Get selected documents
    // final List<String> selectedDocuments = _documentChecks.entries
    //     .where((entry) => entry.value)
    //     .map((entry) => entry.key)
    //     .toList();

    // Get table rows for each section
    final List<pw.TableRow> page1Rows = _getPage1TableRows();
    final List<pw.TableRow> page2Table1Rows = _getPage2Table1Rows();
    final List<pw.TableRow> page2Table2Rows = _getPage2Table2Rows();
    final List<pw.TableRow> page2Table2RowsHeading =
        _getPage2Table2RowsHeading();
    final List<pw.TableRow> page2Table2RowsPart2Heading =
        _getPage2Table2RowsPart2Heading();
    final List<pw.TableRow> page2Table2RowsPart2 = _getPage2Table2RowsPart2();
    final List<pw.TableRow> page2Table3Rows =
        _getPage2Table3Rows(); // Get rows for section 18
    final List<pw.TableRow> page2Table5Rows = _getPage2Table5Rows();
    final List<pw.TableRow> landValuationRowsHeading =
        _getLandValuationTableRowsHeading(); // Get rows for page 3
    final List<pw.TableRow> landValuationRows = _getLandValuationTableRows();
    final List<pw.TableRow> totalAbstractTableRows =
        _getTotalAbstractTableRows(); // NEW: Get rows for total abstract table
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
                'FORMAT - B',
                style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight:
                        pw.FontWeight.bold), // Slightly reduced font size
              ),
            ),
            pw.SizedBox(height: 8), // Reduced SizedBox height
            pw.Center(
              child: pw.Text(
                'VALUATION REPORT (IN RESPECT OF VACANT LAND / SITE)',
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

            pw.SizedBox(height: 30), // Add some space between tables

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

    // Page 4 - New page for the final valuation table
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

    // NEW: Valuer Comments Table (Page 7)
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
        //   'Latitude or Longitude is missing from the controller. Skipping save to nearby collection.';
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
        'bankName': 'South Indian Bank (Vacant Land)',
      };

      // --- STEP 4: Send the data to your dedicated server endpoint ---
      final response = await http.post(
        Uri.parse(url5), // Use your dedicated URL for saving this data
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(dataToSave),
      );

      // if (response.statusCode == 200 || response.statusCode == 201) {
      //   debugPrint('Successfully saved data to nearby collection.');
      // } else {
      //   debugPrint(
      //     'Failed to save to nearby collection: ${response.statusCode}',
      //   );
      //   debugPrint('Response body: ${response.body}');
      // }
    } catch (e) {
      // debugPrint('Error in _saveToNearbyCollection: $e');
    }
  }

  Future<void> _saveForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Show loading dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) =>
              const Center(child: CircularProgressIndicator()),
        );

        // Create multipart request using AppConfig
        var request = http.MultipartRequest(
          'POST',
          Uri.parse(url1),
        );

        // Add basic fields
        request.fields.addAll({
          'refNo': _refId.text,
          'typo': 'sibVacantLand',
          'purpose': _purposeController.text,
          'ownerName': _ownerNameController.text,
          'applicantName': _applicantNameController.text,
          'addressAsPerDocument': _addressDocController.text,
          'addressAsPerActual': _addressActualController.text,
          'deviations': _deviationsController.text,
          'propertyType': _propertyTypeController.text,
          'propertyZone': _propertyZoneController.text,

          // Document fields
          'landTaxReceipt': _LandTaxReceipt.text,
          'titleDeed': _TitleDeed.text,
          'buildingCertificate': _BuildingCertificate.text,
          'locationSketch': _LocationSketch.text,
          'possessionCertificate': _PossessionCertificate.text,
          'buildingCompletionPlan': _BuildingCompletionPlan.text,
          'thandapperDocument': _ThandapperDocument.text,
          'buildingTaxReceipt': _BuildingTaxReceipt.text,

          // Additional property details
          'classificationArea': _classificationAreaController.text,
          'urbanSemiUrbanRural': _urbanSemiUrbanRuralController.text,
          'comingUnderCorporation': _comingUnderCorporationController.text,
          'coveredUnderStateCentralGovt':
              _coveredUnderStateCentralGovtController.text,
          'agriculturalLandConversion':
              _agriculturalLandConversionController.text,

          // Boundaries
          'boundaryNorthTitle': _boundaryNorthTitleController.text,
          'boundaryNorthSketch': _boundaryNorthSketchController.text,
          'boundarySouthTitle': _boundarySouthTitleController.text,
          'boundarySouthSketch': _boundarySouthSketchController.text,
          'boundaryEastTitle': _boundaryEastTitleController.text,
          'boundaryEastSketch': _boundaryEastSketchController.text,
          'boundaryWestTitle': _boundaryWestTitleController.text,
          'boundaryWestSketch': _boundaryWestSketchController.text,
          'boundaryDeviations': _boundaryDeviationsController.text,

          // Dimensions
          'dimNorthActuals': _dimNorthActualsController.text,
          'dimSouthActuals': _dimSouthActualsController.text,
          'dimEastActuals': _dimEastActualsController.text,
          'dimWestActuals': _dimWestActualsController.text,
          'dimTotalAreaActuals': _dimTotalAreaActualsController.text,
          'dimNorthDocuments': _dimNorthDocumentsController.text,
          'dimSouthDocuments': _dimSouthDocumentsController.text,
          'dimEastDocuments': _dimEastDocumentsController.text,
          'dimWestDocuments': _dimWestDocumentsController.text,
          'dimTotalAreaDocuments': _dimTotalAreaDocumentsController.text,
          'dimNorthAdopted': _dimNorthAdoptedController.text,
          'dimSouthAdopted': _dimSouthAdoptedController.text,
          'dimEastAdopted': _dimEastAdoptedController.text,
          'dimWestAdopted': _dimWestAdoptedController.text,
          'dimTotalAreaAdopted': _dimTotalAreaAdoptedController.text,
          'dimDeviations': _dimDeviationsController.text,

          // Location and road details
          'latitudeLongitude': _latitudeLongitudeController.text,
          'typeOfRoad': _typeOfRoadController.text,
          'widthOfRoad': _widthOfRoadController.text,
          'isLandLocked': _isLandLockedController.text,

          // Land valuation
          'landAreaDetails': _landAreaDetailsController.text,
          'landAreaGuideline': _landAreaGuidelineController.text,
          'landAreaPrevailing': _landAreaPrevailingController.text,
          'ratePerSqFtGuideline': _ratePerSqFtGuidelineController.text,
          'ratePerSqFtPrevailing': _ratePerSqFtPrevailingController.text,
          'valueInRsGuideline': _valueInRsGuidelineController.text,
          'valueInRsPrevailing': _valueInRsPrevailingController.text,

          // Total abstract
          'totalAbstractLand': _totalAbstractLandController.text,
          'totalAbstractBuilding': _totalAbstractBuildingController.text,
          'totalAbstractAmenities': _totalAbstractAmenitiesController.text,
          'totalAbstractTotal': _totalAbstractTotalController.text,
          'totalAbstractSay': _totalAbstractSayController.text,

          'presentMarketValue': _presentMarketValueController.text,
          'realizableValue': _realizableValueController.text,
          'distressValue': _distressValueController.text,

          // Remarks
          'remark1': _remark1Controller.text,
          'remark2': _remark2Controller.text,
          'remark3': _remark3Controller.text,
          'remark4': _remark4Controller.text,

          // Declaration dates
          'declarationDateA': _declarationDateAController.text,
          'declarationDateC': _declarationDateCController.text,

          // Valuer comments
          'vcBackgroundInfo': _vcBackgroundInfoController.text,
          'vcPurposeOfValuation': _vcPurposeOfValuationController.text,
          'vcIdentityOfValuer': _vcIdentityOfValuerController.text,
          'vcDisclosureOfInterest': _vcDisclosureOfInterestController.text,
          'vcDateOfAppointment': _vcDateOfAppointmentController.text,
          'vcInspectionsUndertaken': _vcInspectionsUndertakenController.text,
          'vcNatureAndSources': _vcNatureAndSourcesController.text,
          'vcProceduresAdopted': _vcProceduresAdoptedController.text,
          'vcRestrictionsOnUse': _vcRestrictionsOnUseController.text,
          'vcMajorFactors1': _vcMajorFactors1Controller.text,
          'vcMajorFactors2': _vcMajorFactors2Controller.text,
          'vcCaveatsLimitations': _vcCaveatsLimitationsController.text,
        });

        // Add dates in proper format
        if (_dateOfInspectionController.text.isNotEmpty) {
          final inspectionDate =
              DateFormat('dd-MM-yyyy').parse(_dateOfInspectionController.text);
          request.fields['dateOfInspection'] =
              DateFormat('yyyy-MM-dd').format(inspectionDate);
        }

        if (_dateOfValuationController.text.isNotEmpty) {
          final valuationDate =
              DateFormat('dd-MM-yyyy').parse(_dateOfValuationController.text);
          request.fields['dateOfValuation'] =
              DateFormat('yyyy-MM-dd').format(valuationDate);
        }

        // Add complex fields as JSON strings
        final boundaries = {
          'north': {
            'titleDeed': _boundaryNorthTitleController.text,
            'sketch': _boundaryNorthSketchController.text,
          },
          'south': {
            'titleDeed': _boundarySouthTitleController.text,
            'sketch': _boundarySouthSketchController.text,
          },
          'east': {
            'titleDeed': _boundaryEastTitleController.text,
            'sketch': _boundaryEastSketchController.text,
          },
          'west': {
            'titleDeed': _boundaryWestTitleController.text,
            'sketch': _boundaryWestSketchController.text,
          },
          'deviations': _boundaryDeviationsController.text,
        };
        request.fields['boundaries'] = json.encode(boundaries);

        // Add images with coordinates
        for (int i = 0; i < _images.length; i++) {
          final image = _images[i];
          Uint8List imageBytes;

          if (image is File) {
            imageBytes = await image.readAsBytes();
          } else if (image is Uint8List) {
            imageBytes = image;
          } else {
            continue;
          }

          request.files.add(http.MultipartFile.fromBytes(
            'images',
            imageBytes,
            filename: 'property_${_refId.text}_$i.jpg',
          ));

          request.fields['imageLatitude'] = _latController.text;
          request.fields['imageLongitude'] = _lonController.text;
        }

        // Send request
        final response = await request.send();

        // Handle response
        if (context.mounted) Navigator.of(context).pop();

        if (response.statusCode == 200 || response.statusCode == 201) {
          final responseBody =
              await response.stream.transform(utf8.decoder).join();
          final jsonResponse = json.decode(responseBody);

          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(jsonResponse['message'] ??
                      'Valuation saved successfully!')),
            );
          }
          await _saveToNearbyCollection();
        } else {
          final errorBody =
              await response.stream.transform(utf8.decoder).join();
          final errorJson = json.decode(errorBody);

          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content:
                      Text(errorJson['message'] ?? 'Failed to save valuation')),
            );
          }
        }
      } catch (e) {
        if (context.mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${e.toString()}')),
          );
        }
      }
    }
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
                                    onPressed: _getNearbyProperty,
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
                      heroTag: "f1",
                      icon: const Icon(Icons.search),
                      label: const Text('Search Saved Drafts'),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (ctx) {
                              return const SavedDraftsSIBVacantLand();
                            },
                          ),
                        );
                      }),
                ),
              ),

              // Center(
              //   child: Container(
              //     padding: const EdgeInsets.all(20),
              //     margin: const EdgeInsets.all(20),
              //     decoration: BoxDecoration(
              //       color: const Color.fromARGB(255, 244, 238, 238), // Light background color
              //       borderRadius: BorderRadius.circular(15),
              //       boxShadow: [
              //         BoxShadow(
              //           color: const Color.fromARGB(255, 204, 200, 200).withOpacity(0.3),
              //           spreadRadius: 4,
              //           blurRadius: 8,
              //           offset: const Offset(0, 4), // Shadow position
              //         ),
              //       ],
              //     ),
              //     child: Column(
              //       mainAxisSize: MainAxisSize.min,
              //       children: [
              //         TextField( // Changed from TextFormField to TextField
              //           controller: _latController,
              //           decoration: const InputDecoration(
              //             border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(20))), // Applied new styling
              //             hintText: 'Latitude',
              //           ),
              //         ),
              //         const SizedBox(height: 20),
              //         TextField( // Changed from TextFormField to TextField
              //           controller: _lonController,
              //           decoration: const InputDecoration(
              //             border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(20))), // Applied new styling
              //             hintText: 'Longitude',
              //           ),
              //         ),
              //         const SizedBox(height: 30),

              //         Row(
              //           mainAxisAlignment: MainAxisAlignment.center,
              //           children: [
              //             ElevatedButton.icon(
              //               onPressed: _getCurrentLocation,
              //               icon: const Icon(Icons.my_location),
              //               label: const Text('Get Location', style: TextStyle(fontSize: 15.5)),
              //               style: ButtonStyle(
              //                 fixedSize: WidgetStateProperty.all(const Size(200, 40)),
              //                 shape: WidgetStateProperty.all(
              //                   RoundedRectangleBorder(
              //                     borderRadius: BorderRadius.circular(20),
              //                   ),
              //                 ),
              //               ),
              //             ),
              //             const SizedBox(width: 15), // Spacing between buttons
              //             ElevatedButton.icon(
              //               onPressed: () {},
              //               icon: const Icon(Icons.search),
              //               label: const Text('Search', style: TextStyle(fontSize: 15.5)),
              //               style: ButtonStyle(
              //                 fixedSize: WidgetStateProperty.all(const Size(150, 40)),
              //                 shape: WidgetStateProperty.all(
              //                   RoundedRectangleBorder(
              //                     borderRadius: BorderRadius.circular(20),
              //                   ),
              //                 ),
              //               ),
              //             ),
              //           ],
              //         )
              //       ],
              //     ),
              //   ),
              // ),

              // const SizedBox(height: 20),

              // Center(
              //   child: ElevatedButton.icon(
              //     onPressed: () {},
              //     icon: const Icon(Icons.search, size: 30,),
              //     label: const Text('Search Saved Drafts', style: TextStyle(fontSize: 20),),
              //     style: ButtonStyle(
              //       fixedSize: WidgetStateProperty.all(const Size(300, 50)),
              //       shape: WidgetStateProperty.all(
              //         RoundedRectangleBorder(
              //           borderRadius: BorderRadius.circular(20), // 👈 Small border radius
              //         ),
              //       ),
              //     ),
              //   ),
              // ),

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
                  const SizedBox(height: 13),
                  TextField(
                    // Changed from _buildTextField
                    controller: _purposeController,
                    decoration: const InputDecoration(
                      labelText: '1. Purpose for which the valuation is made',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20))),
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
                          borderRadius: BorderRadius.all(Radius.circular(20))),
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
                          borderRadius: BorderRadius.all(Radius.circular(20))),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '3. List of documents produced for perusal',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 13),
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
                      labelText: 'Title Deed',
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
                      labelText: 'Building Certificate',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 13),
                  TextField(
                    // Changed from _buildTextField
                    controller: _LocationSketch,
                    decoration: const InputDecoration(
                      labelText: 'Location Sketch',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 13),
                  TextField(
                    // Changed from _buildTextField
                    controller: _PossessionCertificate,
                    decoration: const InputDecoration(
                      labelText: 'Possession Certificate',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 13),
                  TextField(
                    // Changed from _buildTextField
                    controller: _BuildingCompletionPlan,
                    decoration: const InputDecoration(
                      labelText: 'Building Completion Plan',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 13),
                  TextField(
                    // Changed from _buildTextField
                    controller: _ThandapperDocument,
                    decoration: const InputDecoration(
                      labelText: 'Thandapper Document',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 13),
                  TextField(
                    // Changed from _buildTextField
                    controller: _BuildingTaxReceipt,
                    decoration: const InputDecoration(
                      labelText: 'Building Tax Receipt',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  TextField(
                    // Changed from _buildTextField
                    controller: _ownerNameController,
                    decoration: const InputDecoration(
                      labelText: '4. Name of the owner(s)',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20))),
                    ),
                  ),
                  const SizedBox(height: 13),
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
                  const SizedBox(height: 13),
                  TextField(
                    // Changed from _buildTextField
                    controller: _addressDocController,
                    decoration: const InputDecoration(
                      labelText: '  As Per Documents',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20))),
                    ),
                  ),
                  const SizedBox(height: 13),
                  TextField(
                    // Changed from _buildTextField
                    controller: _addressActualController,
                    decoration: const InputDecoration(
                      labelText: '  As per actual/postal',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20))),
                    ),
                  ),
                  const SizedBox(height: 13),
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
                  const SizedBox(height: 13),
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
                  const SizedBox(height: 13),
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
                  const SizedBox(height: 13),
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
                  const SizedBox(height: 13),
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
                  const SizedBox(height: 13),
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
                  const SizedBox(height: 13),
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
                  const SizedBox(height: 13),
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
                  const SizedBox(height: 13),
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
                            horizontal: 20, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  TextField(
                    // Changed from _buildTextField
                    controller: _typeOfRoadController,
                    decoration: const InputDecoration(
                      labelText:
                          '17. Type of road available at present (Bitumen/Mud/CC/Private)',
                      hintText: 'e.g., Bitumen',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20))),
                    ),
                  ),
                  const SizedBox(height: 13),
                  TextField(
                    // Changed from _buildTextField
                    controller: _widthOfRoadController,
                    decoration: const InputDecoration(
                      labelText: '18. Width of road - in feet',
                      hintText: 'e.g., 20',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20))),
                    ),
                  ),
                  const SizedBox(height: 13),
                  TextField(
                    // Changed from _buildTextField
                    controller: _isLandLockedController,
                    decoration: const InputDecoration(
                      labelText: '19. Is it a land - locked land?',
                      hintText: 'Yes/No',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20))),
                    ),
                  ),
                  const SizedBox(height: 13),
                  TextField(
                    // Changed from _buildTextField
                    controller: _isLandLockedController,
                    decoration: const InputDecoration(
                      labelText: 'Type of Demarcation (Side stone/Fencing)',
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
                  const SizedBox(height: 13),
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
                  const SizedBox(height: 13),
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
                  const SizedBox(height: 13),
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
                  const SizedBox(height: 13),
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
                  const SizedBox(height: 13),
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
                  const SizedBox(height: 13),
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
                    controller: _presentMarketValueController,
                    decoration: const InputDecoration(
                      labelText: 'Present Market Value of The Property',
                      hintText: 'e.g., 3750000',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20))),
                    ),
                  ),
                  const SizedBox(height: 13),
                  TextField(
                    // Changed from _buildTextField
                    controller: _realizableValueController,
                    decoration: const InputDecoration(
                      labelText: 'Realizable Value of the Property',
                      hintText: 'e.g., 2500000',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20))),
                    ),
                  ),
                  const SizedBox(height: 13),
                  TextField(
                    // Changed from _buildTextField
                    controller: _distressValueController,
                    decoration: const InputDecoration(
                      labelText: 'Distress Value of the Property',
                      hintText: 'e.g., 80000',
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
                  const SizedBox(height: 13),
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
                  const SizedBox(height: 13),
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
                  const SizedBox(height: 13),
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
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: "f2",
        onPressed: () {
          _saveForm();
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
