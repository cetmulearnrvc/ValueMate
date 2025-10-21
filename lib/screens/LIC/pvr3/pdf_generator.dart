// lib/pdf_generator.dart
import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'valuation_data_model.dart';

Future<Uint8List> generateValuationPdf(ValuationData data) async {
  final pdf = pw.Document(version: PdfVersion.pdf_1_5, compress: true);

  pdf.addPage(_buildPage1(data));
  pdf.addPage(_buildPage2(data));
  pdf.addPage(_buildPage3(data));

  if (data.images.isNotEmpty) {
    pdf.addPage(_buildImagePage(data));
  }

  return pdf.save();
}

// --- PAGE 1 BUILDER ---
pw.Page _buildPage1(ValuationData data) {
  final dateFormat = DateFormat('dd-MM-yyyy');
  return pw.Page(
    pageFormat: PdfPageFormat.a4,
    margin: const pw.EdgeInsets.all(36),
    build: (context) {
      return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          _buildInfoTable(data, dateFormat),
          pw.SizedBox(height: 10),
          _buildSectionHeader('1. PROPERTY DETAILS:'),
          _buildPropertyDetails(data),
          _buildSectionHeader('2. DRAWING'),
          _buildDrawingDetails(data),
          pw.SizedBox(height: 10),
          _buildSectionHeader('3. Building Details'),
          _buildBuildingDetails(data),
        ],
      );
    },
  );
}

// --- PAGE 2 BUILDER ---
pw.Page _buildPage2(ValuationData data) {
  final currencyFormat =
      NumberFormat.currency(locale: 'en_IN', symbol: 'Rs. ', decimalDigits: 0);

  // Calculate total property value to show in section 7
  double totalMarketValue = 0;
  if (data.valuationType == PropertyType.House) {
    final landMarketVal = (double.tryParse(data.landArea) ?? 0) *
        (double.tryParse(data.landUnitRate) ?? 0);
    final amenitiesMarketVal = (double.tryParse(data.amenitiesArea) ?? 0) *
        (double.tryParse(data.amenitiesUnitRate) ?? 0);
    double floorsMarketValue = 0;
    for (var floor in data.floors) {
      floorsMarketValue += (double.tryParse(floor.area) ?? 0) *
          (double.tryParse(floor.marketRate) ?? 0);
    }
    totalMarketValue = landMarketVal + amenitiesMarketVal + floorsMarketValue;
  } else {
    totalMarketValue = double.tryParse(data.flatValueMarket) ?? 0;
  }
  final improvementTotal = double.tryParse(data.improvementAmount) ?? 0;
  final estimatedValueAfterImprovements = totalMarketValue + improvementTotal;

  return pw.Page(
    pageFormat: PdfPageFormat.a4,
    margin: const pw.EdgeInsets.all(36),
    build: (context) {
      return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _buildBuildingDetailsContinuation(data),
          _buildSectionHeader('4. VALUATION DETAILS:'),
          pw.Text(
              '(Exclude the value of items for which the estimate... have been submitted by the applicant)',
              style: const pw.TextStyle(fontSize: 8)),
          pw.SizedBox(height: 5),
          if (data.valuationType == PropertyType.House)
            _buildHouseValuationPdf(data, currencyFormat)
          else
            _buildFlatValuationPdf(data, currencyFormat),
          pw.SizedBox(height: 10),
          _buildSectionHeader('5. ESTIMATE FOR IMPROVEMENT (If applicable)'),
          _buildImprovementDetails(data, currencyFormat),
          pw.SizedBox(height: 10),
          _buildSectionHeader('6. PROGRESS OF WORK (If applicable)'),
          _buildProgressOfWorkTable(data, currencyFormat),
          pw.SizedBox(height: 10),
          // ADDED: Section 7 as per the image
          _buildSectionHeader(
              '7. Estimated Value of Property After Above Improvements'),
          pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Text(
                currencyFormat.format(estimatedValueAfterImprovements),
                style:
                    pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
              )),
          pw.SizedBox(height: 10),
        ],
      );
    },
  );
}

pw.Page _buildPage3(ValuationData data) {
  return pw.Page(
    pageFormat: PdfPageFormat.a4,
    margin: const pw.EdgeInsets.all(36),
    build: (context) {
      return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('8. Remarks If Any'),
          _buildRemarks(data),
          _buildSectionHeader('9. CERTIFICATE'),
          pw.SizedBox(height: 7),
          pw.Text(
              'I declare that I am not associated with the builder or with any of his associate companies or with the borrower directly or indirectly in the past or in the present and this report has been prepared by me with highest professional integrity.',
              style: const pw.TextStyle(fontSize: 9)),
          pw.Spacer(),
          pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Text('SIGNATURE OF THE VALUER',
                  style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold, fontSize: 10))),
        ],
      );
    },
  );
}

// --- IMAGE PAGE BUILDER ---
pw.MultiPage _buildImagePage(ValuationData data) {
  return pw.MultiPage(
    pageFormat: PdfPageFormat.a4,
    margin: const pw.EdgeInsets.all(36),
    header: (context) => pw.Text('Uploaded Images',
        style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16)),
    build: (context) => [
      pw.GridView(
        crossAxisCount: 2,
        childAspectRatio: 0.65,
        children: data.images.map((valuationImage) {
          final image = pw.MemoryImage(valuationImage.imageFile);
          return pw.Padding(
            padding: const pw.EdgeInsets.all(4),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Expanded(
                    child: pw.SizedBox(
                        width: double.infinity,
                        child: pw.Image(image, fit: pw.BoxFit.contain))),
                pw.SizedBox(height: 5),
                pw.Text(
                    '(Latitude): ${valuationImage.latitude}\n(Longitude): ${valuationImage.longitude}',
                    style: const pw.TextStyle(fontSize: 8)),
              ],
            ),
          );
        }).toList(),
      ),
    ],
  );
}

// --- HELPER WIDGETS FOR BUILDING PDF SECTIONS ---

pw.Widget _buildHeader() => pw.Column(children: [
      pw.Stack(children: [
        pw.Center(
            child: pw.Column(children: [
          pw.Text('LIC HOUSING FINANCE LIMITED',
              style:
                  pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
          pw.Text('AREA OFFICE: THIRUVANANTHAPURAM',
              style: const pw.TextStyle(fontSize: 10)),
          pw.SizedBox(height: 5),
          pw.Text('VALUATION REPORT BY PANEL VALUER FOR HOME LOAN',
              style: const pw.TextStyle(
                  decoration: pw.TextDecoration.underline, fontSize: 10)),
        ])),
        pw.Align(
            alignment: pw.Alignment.topRight,
            child: pw.Text('PVR-3',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
      ]),
      pw.SizedBox(height: 15),
    ]);

pw.Table _buildInfoTable(ValuationData data, DateFormat dateFormat) => pw.Table(
      columnWidths: {
        0: const pw.FlexColumnWidth(1),
        1: const pw.FlexColumnWidth(2)
      },
      children: [
        pw.TableRow(children: [
          pw.Text(' * File no.', style: const pw.TextStyle(fontSize: 9)),
          pw.Text(': ${data.fileNo}', style: const pw.TextStyle(fontSize: 9))
        ]),
        pw.TableRow(children: [
          pw.Text(' * Name of the Valuer',
              style: const pw.TextStyle(fontSize: 9)),
          pw.Text(': ${data.valuerName} (${data.valuerCode})',
              style: const pw.TextStyle(fontSize: 9))
        ]),
        pw.TableRow(children: [
          pw.Text(' Appointing Authority',
              style: const pw.TextStyle(fontSize: 9)),
          pw.Text(': ${data.appointingAuthority}',
              style: const pw.TextStyle(fontSize: 9))
        ]),
        pw.TableRow(children: [
          pw.Text(' Date of Inspection',
              style: const pw.TextStyle(fontSize: 9)),
          pw.Text(': ${dateFormat.format(data.inspectionDate)}',
              style: const pw.TextStyle(fontSize: 9))
        ]),
        pw.TableRow(children: [
          pw.Text(' RERA NO. (For Flats)',
              style: const pw.TextStyle(fontSize: 9)),
          pw.Text(': ${data.reraNo}', style: const pw.TextStyle(fontSize: 9))
        ]),
      ],
    );

// lib/pdf_generator.dart

// REPLACE the old _buildPropertyDetails function with this entire block of code.
pw.Widget _buildPropertyDetails(ValuationData data) {
  // --- Start of Fix ---
  // Step 1: Declare the custom widgets as variables at the top of the function.
  final occupantKeyWidget = pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Text('g. Occupant', style: const pw.TextStyle(fontSize: 9)),
      pw.Padding(
          padding: const pw.EdgeInsets.only(left: 10, top: 2),
          child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('If Occupied, Name of the Occupant',
                    style: const pw.TextStyle(fontSize: 8)),
                pw.Text('If rented, List of occupants',
                    style: const pw.TextStyle(fontSize: 8)),
              ])),
    ],
  );

  final occupantValueWidget =
      pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
    pw.Text(data.occupantStatus.name,
        style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9)),
    pw.Text(data.occupantName,
        style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9)),
  ]);
  // --- End of Fix ---

  // Step 2: Return the main Column widget, now that the variables are declared.
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      _buildKeyValue('a. * Name of the Applicant', data.applicantName),
      _buildKeyValue('b. Document perused', data.documentPerused),
      _buildKeyValue(
          'c. * Location of the Property Survey Number/Block No. /Village Ward No. /Taluk ',
          data.propertyAddress),
      _buildKeyBoolValue(
          'd. Location Sketch verified', data.locationSketchVerified),
      pw.SizedBox(height: 5),
      pw.Text('e. Boundaries and Dimensions',
          style: const pw.TextStyle(
            fontSize: 10,
          )),
      pw.TableHelper.fromTextArray(
        border: pw.TableBorder.all(width: 0.5),
        headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9),
        cellStyle: const pw.TextStyle(fontSize: 9),
        headers: [' ', 'Boundaries', 'Dimensions'],
        data: [
          ['North/Front', data.northBoundary, data.northDim],
          ['South/Rear', data.southBoundary, data.southDim],
          ['East/Left(side 1)', data.eastBoundary, data.eastDim],
          ['West/Right(side 2)', data.westBoundary, data.westDim],
          ['Extent', data.extent1, data.extent2],
        ],
      ),
      pw.SizedBox(height: 5),
      _buildKeyValue('f. Type of the property', data.propertyType),

      // Step 3: Use the declared widgets inside the layout.
      pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 1),
        child:
            pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          pw.Expanded(flex: 2, child: occupantKeyWidget),
          pw.Text(': ', style: const pw.TextStyle(fontSize: 9)),
          pw.Expanded(flex: 3, child: occupantValueWidget),
        ]),
      ),

      _buildKeyValue('h. Usage of the Building (Explain ratio of each type)',
          data.usageOfBuilding),
      _buildKeyValue('i. Details of the Nearby Landmark', data.nearbyLandmark),
      _buildKeyValue(
          'j. Development of surrounding area with Special reference to population',
          data.surroundingAreaDev),
      _buildKeyBoolValue(
          'k.Whether basic amenities like water, electricity, roads, sewerage, telephone are available',
          data.basicAmenitiesAvailable),
      _buildKeyValue(
          'l. Any negatives to the locality (Crematoriums, slums, riot prone, gases Chemical hazards,nagbana etc',
          data.negativesToLocality),
      _buildKeyValue('m. Any favourable considerations for addl value',
          data.favourableConsiderations),
      _buildKeyValue(
          'n. Any other features like board of other financier indicating mortgage, notice of Court/any authority which may effect the security.',
          data.otherFeatures),
    ],
  );
}

pw.Widget _buildDrawingDetails(ValuationData data) => pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _buildKeyBoolValue('a. Whether the approved drawing is available?',
            data.approvedDrawingAvailable),
        _buildKeyValue('b. Approval No. & date', data.approvalNoAndDate),
        _buildKeyBoolValue(
            'c. Whether the construction is as per approved plan(Yes/No)',
            data.constructionAsPerPlan),
        _buildKeyValue(
            'd. What are the deviations between approved drawing & actual?',
            data.drawingDeviations),
        _buildKeyValue('e. Whether deviations are minor/major in nature',
            data.deviationNature.name),
      ],
    );

pw.Widget _buildBuildingDetails(ValuationData data) => pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _buildKeyValue('1. Marketability of the Property', data.marketability),
        _buildKeyValue('2. Age of the Building', data.buildingAge),
      ],
    );

pw.Widget _buildBuildingDetailsContinuation(ValuationData data) =>
    pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
      _buildKeyValue('3. Future Residual life expected', data.residualLife),
      pw.Table(
        border: pw.TableBorder.all(width: 0.5),
        columnWidths: {
          0: const pw.FlexColumnWidth(3),
          1: const pw.FlexColumnWidth(3),
          2: const pw.FlexColumnWidth(2)
        },
        children: [
          pw.TableRow(children: [
            pw.Padding(
                padding: const pw.EdgeInsets.all(2),
                child: pw.Text('4. Floor Space Index')),
            pw.Center(child: pw.Text('As per Approved Plan/as per rule')),
            pw.Center(child: pw.Text('Actual')),
          ]),
          pw.TableRow(children: [
            pw.Container(),
            pw.Center(child: pw.Text(data.fsiApproved)),
            pw.Center(child: pw.Text(data.fsiActual)),
          ]),
        ],
      ),
      _buildKeyValue('5. Specification', ''),
      _buildKeyValue('    Foundation', data.specFoundation, isSubItem: true),
      _buildKeyValue('    Roof', data.specRoof, isSubItem: true),
      _buildKeyValue('    Flooring', data.specFlooring, isSubItem: true),
      _buildKeyValue('6. Quality of Construction (Exterior & Interior)',
          data.qualityOfConstruction),
      _buildKeyBoolValue(
          '7. i) Whether the Construction carried out / being carried out adheres to the Safety Specifications prescribed in the National Building Code of India 2005?\nii) Guidelines issued by the National Disaster Management Authority (NDMA',
          data.adheresToSafetySpecs),
      _buildKeyBoolValue(
          '8. Whether any High Tension Wire Lines are passing through the property and if there is any adverse impact due to this?',
          data.highTensionLineImpact),
    ]);
pw.Widget _buildHouseValuationPdf(
    ValuationData data, NumberFormat currencyFormat) {
  final List<List<String>> floorRows = data.floors.map((floor) {
    final marketValue = (double.tryParse(floor.area) ?? 0) *
        (double.tryParse(floor.marketRate) ?? 0);
    final guidelineValue = (double.tryParse(floor.area) ?? 0) *
        (double.tryParse(floor.guidelineRate) ?? 0);
    return [
      floor.name,
      floor.area,
      currencyFormat.format(double.tryParse(floor.marketRate) ?? 0),
      currencyFormat.format(marketValue),
      currencyFormat.format(double.tryParse(floor.guidelineRate) ?? 0),
      currencyFormat.format(guidelineValue)
    ];
  }).toList();

  final landMarketVal = (double.tryParse(data.landArea) ?? 0) *
      (double.tryParse(data.landUnitRate) ?? 0);
  final landGuideVal = (double.tryParse(data.landArea) ?? 0) *
      (double.tryParse(data.landGuidelineRate) ?? 0);
  final amenitiesMarketVal = (double.tryParse(data.amenitiesArea) ?? 0) *
      (double.tryParse(data.amenitiesUnitRate) ?? 0);
  final amenitiesGuideVal = (double.tryParse(data.amenitiesArea) ?? 0) *
      (double.tryParse(data.amenitiesGuidelineRate) ?? 0);

  double totalMarketValue = landMarketVal + amenitiesMarketVal;
  double totalGuidelineValue = landGuideVal + amenitiesGuideVal;
  double totalArea = (double.tryParse(data.landArea) ?? 0) +
      (double.tryParse(data.amenitiesArea) ?? 0);
  double totalMarketRate = (double.tryParse(data.landUnitRate) ?? 0) +
      (double.tryParse(data.amenitiesUnitRate) ?? 0);
  double totalGuidelineRate = (double.tryParse(data.landGuidelineRate) ?? 0) +
      (double.tryParse(data.amenitiesGuidelineRate) ?? 0);

  for (var floor in data.floors) {
    totalArea += double.tryParse(floor.area) ?? 0;
    totalMarketRate += double.tryParse(floor.marketRate) ?? 0;
    totalGuidelineRate += double.tryParse(floor.guidelineRate) ?? 0;
    totalMarketValue += (double.tryParse(floor.area) ?? 0) *
        (double.tryParse(floor.marketRate) ?? 0);
    totalGuidelineValue += (double.tryParse(floor.area) ?? 0) *
        (double.tryParse(floor.guidelineRate) ?? 0);
  }

  return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
    pw.Text('a. Value of the property (if it is a house) :',
        style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
    pw.TableHelper.fromTextArray(
      border: pw.TableBorder.all(width: 0.5),
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9),
      cellStyle: const pw.TextStyle(fontSize: 9),
      headers: [
        'Description',
        'Area',
        'Unit Rate',
        'Estimated market value',
        'Unit Rate',
        'Guide line Value'
      ],
      data: [
        [
          'Land',
          data.landArea,
          currencyFormat.format(double.tryParse(data.landUnitRate) ?? 0),
          currencyFormat.format(landMarketVal),
          currencyFormat.format(double.tryParse(data.landGuidelineRate) ?? 0),
          currencyFormat.format(landGuideVal)
        ],
        ['Building', '', '', '', '', ''],
        ...floorRows,
        [
          'Amenities if any',
          data.amenitiesArea,
          currencyFormat.format(double.tryParse(data.amenitiesUnitRate) ?? 0),
          currencyFormat.format(amenitiesMarketVal),
          currencyFormat
              .format(double.tryParse(data.amenitiesGuidelineRate) ?? 0),
          currencyFormat.format(amenitiesGuideVal)
        ],
        [
          'Total Value',
          totalArea.toStringAsFixed(2),
          currencyFormat.format(totalMarketRate),
          currencyFormat.format(totalMarketValue),
          currencyFormat.format(totalGuidelineRate),
          currencyFormat.format(totalGuidelineValue)
        ],
      ],
      cellAlignments: {
        1: pw.Alignment.centerRight,
        2: pw.Alignment.centerRight,
        3: pw.Alignment.centerRight,
        4: pw.Alignment.centerRight,
        5: pw.Alignment.centerRight
      },
    ),
    pw.SizedBox(height: 5),
    _buildKeyValue('State the source for arriving at the Market Value',
        data.marketValueSourceHouse,
        boldValue: true),
  ]);
}

pw.Widget _buildFlatValuationPdf(
    ValuationData data, NumberFormat currencyFormat) {
  return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
    pw.Text('b. Value of the property (if it is a flat) :',
        style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
    _buildKeyValue('1. Undivided Share of Land(if applicable)',
        '= ${data.flatUndividedShare}'),
    _buildKeyValue('2. Built Up Area of the Flat', '= ${data.flatBuiltUpArea}'),
    _buildKeyValue('3. Adopted unit composite Rate',
        '= ${currencyFormat.format(double.tryParse(data.flatCompositeRate) ?? 0)}'),
    pw.SizedBox(height: 5),
    pw.TableHelper.fromTextArray(
      border: pw.TableBorder.all(width: 0.5),
      cellStyle: const pw.TextStyle(fontSize: 9),
      cellAlignment: pw.Alignment.center,
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9),
      headers: [
        '4. Estimated Value of the Flat',
        'Unit Rate',
        'Market Value',
        'Guideline Rate',
        'Guideline Value'
      ],
      data: [
        [
          '',
          data.flatValueUnitRate,
          data.flatValueMarket,
          data.flatValueGuidelineRate,
          data.flatValueGuideline,
        ]
      ],
    ),
    pw.SizedBox(height: 5),
    _buildKeyValue('e. State the source for arriving at the Market Value',
        data.marketValueSourceFlat,
        boldValue: false),
    _buildKeyValue('f. Add for extra amenities if any',
        '= ${currencyFormat.format(double.tryParse(data.flatExtraAmenities) ?? 0)}'),
  ]);
}

// MODIFIED: PDF builder for Section 5
pw.Widget _buildImprovementDetails(
        ValuationData data, NumberFormat currencyFormat) =>
    pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _buildKeyValue(
            '1. Description of improvement works as per applicants estimate',
            data.improvementDescription),
        _buildKeyValue(
            '2. Amount estimated by the applicant for the improvement works',
            currencyFormat
                .format(double.tryParse(data.improvementAmount) ?? 0)),
        _buildKeyBoolValue(
            '3. Whether the estimate submitted by the applicant is reasonable?',
            data.improvementEstimateReasonable),
        if (!data.improvementEstimateReasonable)
          _buildKeyValue(
            '4. If not, what would be the reasonable estimate',
            currencyFormat.format(
                double.tryParse(data.improvementReasonableEstimate) ?? 0),
          )
      ],
    );

// MODIFIED: PDF builder for Section 6
// lib/pdf_generator.dart -> REPLACE THIS FUNCTION

pw.Widget _buildProgressOfWorkTable(
    ValuationData data, NumberFormat currencyFormat) {
  final headerStyle = pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9);
  final subHeaderStyle =
      pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8);
  const cellStyle = pw.TextStyle(fontSize: 9);
  const cellPadding = pw.EdgeInsets.all(3);

  // Define column widths that will be used by both header and data tables to ensure alignment.
  // The header's 3rd column (flex 5) will be split into two data columns (flex 2.5 + 2.5).
  const Map<int, pw.TableColumnWidth> headerWidths = {
    0: pw.FlexColumnWidth(1),
    1: pw.FlexColumnWidth(5),
    2: pw.FlexColumnWidth(
        5), // This single column will contain the nested sub-header table
  };
  const Map<int, pw.TableColumnWidth> dataWidths = {
    0: pw.FlexColumnWidth(1),
    1: pw.FlexColumnWidth(5),
    2: pw.FlexColumnWidth(2.5),
    3: pw.FlexColumnWidth(2.5),
  };

  // Build the data rows first
  final dataRows = data.progressWorkItems.asMap().entries.map((entry) {
    int index = entry.key;
    ProgressWorkItem item = entry.value;
    return pw.TableRow(children: [
      pw.Padding(
          padding: cellPadding,
          child: pw.Text((index + 1).toString(),
              style: cellStyle, textAlign: pw.TextAlign.center)),
      pw.Padding(
          padding: cellPadding,
          child: pw.Text(item.description, style: cellStyle)),
      pw.Padding(
          padding: cellPadding,
          child: pw.Text(
              item.applicantEstimate.isNotEmpty
                  ? currencyFormat
                      .format(double.tryParse(item.applicantEstimate) ?? 0)
                  : '',
              style: cellStyle,
              textAlign: pw.TextAlign.right)),
      pw.Padding(
          padding: cellPadding,
          child: pw.Text(
              item.valuerOpinion.isNotEmpty
                  ? currencyFormat
                      .format(double.tryParse(item.valuerOpinion) ?? 0)
                  : '',
              style: cellStyle,
              textAlign: pw.TextAlign.right)),
    ]);
  }).toList();

  // Return a Column with two tables: one for the header, one for the data.
  return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        // 1. HEADER TABLE
        pw.Table(
            border: pw.TableBorder.all(),
            columnWidths: headerWidths,
            children: [
              pw.TableRow(
                  verticalAlignment: pw.TableCellVerticalAlignment.middle,
                  children: [
                    // Cell 1: Sr. No.
                    pw.Padding(
                        padding: const pw.EdgeInsets.fromLTRB(3, 11, 3, 11),
                        child: pw.Center(
                            child: pw.Text('Sr. No.', style: headerStyle))),
                    // Cell 2: Description
                    pw.Padding(
                        padding: cellPadding,
                        child: pw.Center(
                            child: pw.Text('Description of work',
                                style: headerStyle))),
                    // Cell 3: The complex header cell
                    pw.Column(
                        mainAxisAlignment: pw.MainAxisAlignment.center,
                        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                        children: [
                          pw.Center(
                              child: pw.Padding(
                                  padding: const pw.EdgeInsets.only(
                                      top: 2, bottom: 2),
                                  child: pw.Text('Amount incurred as per',
                                      style: headerStyle))),
                          pw.Divider(
                              height: 1,
                              thickness: 0.5,
                              color: PdfColors.black),
                          // NESTED table for the sub-headers
                          pw.Table(
                              // border: pw.TableBorder.all(),
                              columnWidths: const {
                                0: pw.FlexColumnWidth(1),
                                1: pw.FlexColumnWidth(1)
                              },
                              children: [
                                pw.TableRow(children: [
                                  pw.Center(
                                      child: pw.Padding(
                                          padding: const pw.EdgeInsets.only(
                                              top: 2, bottom: 2),
                                          child: pw.Text('Applicants estimate',
                                              style: subHeaderStyle))),
                                  pw.Center(
                                      child: pw.Padding(
                                          padding: const pw.EdgeInsets.only(
                                              top: 2, bottom: 2),
                                          child: pw.Text('Valuers opinion',
                                              style: subHeaderStyle))),
                                ])
                              ])
                        ]),
                  ]),
            ]),
        // 2. DATA TABLE
        pw.Table(
          border: pw.TableBorder.all()
          // No top border, to connect seamlessly with the header table
          ,
          columnWidths: dataWidths,
          children: dataRows,
        )
      ]);
}

pw.Widget _buildRemarks(ValuationData data) => pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _buildKeyValue('a) Background information...', data.remarksBackground),
        _buildKeyValue('b) Sources of information...', data.remarksSources),
        _buildKeyValue('c) Procedures adopted...', data.remarksProcedures),
        _buildKeyValue('d) Valuation methodology', data.remarksMethodology),
        _buildKeyValue('e) Major factors that influenced the valuation',
            data.remarksFactors),
      ],
    );

pw.Widget _buildSectionHeader(String title) => pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 8),
      child: pw.Text(title,
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)),
    );

pw.Widget _buildKeyValue(String key, String value,
        {bool boldValue = true, bool isSubItem = false}) =>
    pw.Padding(
      padding:
          pw.EdgeInsets.symmetric(vertical: 1, horizontal: isSubItem ? 15 : 0),
      child: pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
        pw.Expanded(
            flex: 2,
            child: pw.Text(key, style: const pw.TextStyle(fontSize: 9))),
        pw.Text(': ', style: const pw.TextStyle(fontSize: 9)),
        pw.Expanded(
            flex: 3,
            child: pw.Text(value,
                style: pw.TextStyle(
                    fontWeight:
                        boldValue ? pw.FontWeight.bold : pw.FontWeight.normal,
                    fontSize: 9))),
      ]),
    );

pw.Widget _buildKeyBoolValue(String key, bool value) =>
    _buildKeyValue(key, value ? 'Yes' : 'No');
