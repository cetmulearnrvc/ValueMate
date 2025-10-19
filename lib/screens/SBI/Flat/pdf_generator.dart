// lib/pdf_generator_sib.dart
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:intl/intl.dart';

import 'package:pdf/widgets.dart' as pw;
import 'data_model.dart';

class SBIPdfGenerator {
  final SBIValuationData data;

  SBIPdfGenerator(this.data);

  Future<Uint8List> generate() async {
    final pdf = pw.Document(version: PdfVersion.pdf_1_5, compress: true);

    pdf.addPage(await _buildPage1());
    pdf.addPage(_buildPage2());
    pdf.addPage(_buildPage3());
    pdf.addPage(_buildPage4());

    // Add photo report pages (6 images per page)
    if (data.images.isNotEmpty) {
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(36),
          header: (context) => pw.Header(
            level: 0,
            child: pw.Center(
                child: pw.Text('PHOTO REPORT',
                    style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold, fontSize: 16))),
          ),
          build: (context) => [
            _buildPhotoGrid(data.images), // Call a helper to build the grid
          ],
        ),
      );
    }

    pdf.addPage(_buildPage6());
    pdf.addPage(_buildPage7());

    return pdf.save();
  }

  pw.Widget _buildPhotoGrid(List<ValuationImage> images) {
    return pw.GridView(
      crossAxisCount: 2,
      childAspectRatio: 2 / 2.5, // width / height ratio for each item
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      children: images.map((image) => _buildPhotoItem(image)).toList(),
    );
  }

// --- ADD THIS SECOND NEW HELPER METHOD ---
  pw.Widget _buildPhotoItem(ValuationImage image) {
    final pwImage = pw.MemoryImage(image.imageFile);
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        // The image itself
        pw.Expanded(
          child: pw.Container(
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey300),
            ),
            child: pw.Image(pwImage, fit: pw.BoxFit.contain),
          ),
        ),
        // The latitude and longitude text below the image
        pw.SizedBox(height: 4),
        pw.Text(
          'Latitude: ${image.latitude}',
          style: const pw.TextStyle(fontSize: 8),
        ),
        pw.Text(
          'Longitude: ${image.longitude}',
          style: const pw.TextStyle(fontSize: 8),
        ),
      ],
    );
  }

  Future<pw.Page> _buildPage1() async {
    final dateFormat = DateFormat('dd-MM-yyyy');

    pw.Widget header = pw.Align(
        alignment: pw.Alignment.centerRight,
        child:
            pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.end, children: [
          pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Image(
                    height: 50,
                    width: 50,
                    pw.MemoryImage(
                        (await rootBundle.load('assets/images/symbol.jpg'))
                            .buffer
                            .asUint8List())),
                pw.Text(data.valuerName,
                    style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold, fontSize: 16)),
              ]),
          pw.Text(data.valuerQualifications,
              style: const pw.TextStyle(fontSize: 10)),
          pw.Text(data.valuerRegInfo,
              style: const pw.TextStyle(
                fontSize: 9,
              ),
              textAlign: pw.TextAlign.right),
          pw.SizedBox(height: 5),
          pw.Container(height: 1, color: PdfColors.black),
          pw.SizedBox(height: 5),
          pw.Column(mainAxisAlignment: pw.MainAxisAlignment.end, children: [
            pw.Text(data.valuerAddress,
                style: const pw.TextStyle(fontSize: 10)),
            pw.SizedBox(height: 5),
            pw.Container(height: 1, color: PdfColors.black),
            pw.SizedBox(height: 5),
          ]),
          pw.Row(mainAxisAlignment: pw.MainAxisAlignment.center, children: [
            pw.Image(
                height: 13,
                width: 13,
                pw.MemoryImage(
                    (await rootBundle.load('assets/images/phone.png'))
                        .buffer
                        .asUint8List())),
            pw.Text(data.valuerContact,
                style: const pw.TextStyle(fontSize: 10)),
            pw.SizedBox(width: 20),
            pw.Image(
                height: 13,
                width: 13,
                pw.MemoryImage((await rootBundle.load('assets/images/mail.png'))
                    .buffer
                    .asUint8List())),
            pw.Text(data.valuerEmail, style: const pw.TextStyle(fontSize: 10)),
          ]),
          pw.SizedBox(height: 5),
        ]));

    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(36),
      build: (context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            header,
            pw.SizedBox(height: 20),
            pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Text('Ref No.: ${data.refNo}')),
            pw.SizedBox(height: 10),
            pw.Text('To,'),
            pw.Text(
              '\t\t\t\t${data.bankName}',
            ),
            pw.Text('\t\t\t\t${data.branchName}'),
            pw.Text('\t\t\t\t${data.branchAddress}'),
            pw.SizedBox(height: 20),
            pw.Center(
                child: pw.Text('FORMAT - A',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
            pw.Center(
                child: pw.Text('VALUATION REPORT (IN RESPECT OF FLATS)',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
            pw.SizedBox(height: 10),
            _buildSectionTable([
              _buildTableRow('I.', 'PROPERTY DETAILS', '', bold: true),
              _buildTableRow('1.', 'Purpose for which the valuation is made',
                  data.purposeOfValuation),
              _buildTableRow(
                  '2.',
                  pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('a) Date of inspection'),
                        pw.Text('b) Date on which the valuation is'),
                      ]),
                  pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                            ': ${data.dateOfInspection != null ? dateFormat.format(data.dateOfInspection!) : ''}'),
                        pw.Text(
                            ': ${data.dateOfValuation != null ? dateFormat.format(data.dateOfValuation!) : ''}'),
                      ])),
              _buildTableRow(
                  '3.',
                  'List of documents with No. & date produced for Persual',
                  pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                            'i) : Land Tax Receipt (${data.docLandTaxReceipt})'),
                        pw.Text('ii) : Title Deed (${data.docTitleDeed})'),
                        pw.Text(
                            'iii) : Building Certificate (${data.docBuildingCertificate})'),
                        pw.Text(
                            'iv) : Location Sketch (${data.docLocationSketch})'),
                        pw.Text(
                            'v) : Possession Certificate (${data.docPossessionCertificate})'),
                        pw.Text(
                            'vi) : Building Completion Plan (${data.docBuildingCompletionPlan})'),
                        pw.Text(
                            'vii) : Thandapper Document (${data.docThandapperDocument})'),
                        pw.Text(
                            'viii) : Building Tax Receipt (${data.docBuildingTaxReceipt})'),
                      ])),
              // _buildTableRow('3.', 'List of documents with No. & date produced for Persual',''),
              //     _buildTableRow('', 'i) Land Tax Receipt() ', ': ${data.docLandTaxReceipt}'),
              //     _buildTableRow('', 'ii) Title Deed()', ': ${data.docTitleDeed}'),
              //     _buildTableRow('', 'iii) Building Certificate()', ': ${data.docBuildingCertificate}'),
              //     _buildTableRow('', 'iv) Location Sketch()', ': ${data.docLocationSketch}'),
              //     _buildTableRow('', 'v) Possession Certificate()', ': ${data.docPossessionCertificate}'),
              //     _buildTableRow('', 'vi) Building Completion Plan()', ': ${data.docBuildingCompletionPlan}'),
              //     _buildTableRow('', 'vii) Thandapper Document()', ': ${data.docThandapperDocument}'),
              //     _buildTableRow('', 'viii) Building Tax Receipt()', ': ${data.docBuildingTaxReceipt}'),

              _buildTableRow('4.', 'Name of the owner(s)', data.nameOfOwner),
              _buildTableRow('5.', 'Name of the applicant(s)',
                  data.nameOfApplicant), // No colon in image
              _buildTableRow(
                  '6.',
                  pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('The address of the property'),
                        pw.Text('(including pin code)'),
                      ]),
                  pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                            'As Per Documents : ${data.addressAsPerDocuments}'),
                        pw.Container(height: 1, color: PdfColors.black),
                        pw.Text(
                            'As per actual/postal : ${data.addressAsPerActual}'),
                      ])),
              _buildTableRow('7.', 'Deviations if any:', data.deviations),
              _buildTableRow('8.', 'The property type (Leasehold/Freehold)',
                  data.propertyTypeLeaseholdFreehold),
            ]),
            pw.Spacer(),
            // pw.Center(child: pw.Text('Page 1 of 7')),
          ],
        );
      },
    );
  }

  pw.Page _buildPage2() {
    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(36),
      build: (context) {
        return pw.Column(
          children: [
            _buildSectionTable([
              _buildTableRow(
                  '9.',
                  'Property Zone (Residential/Commercial/ industrial/Agricultural)',
                  data.propertyZone),
              _buildTableRow(
                  '10.',
                  pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('Classification of the area'),
                        pw.Text('i. High / Middle / Poor'),
                        pw.Text('ii. Urban / Semi Urban / Rural'),
                      ]),
                  pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(':'),
                        pw.Text(': ${data.classificationAreaHighMiddlePoor}'),
                        pw.Text(': ${data.classificationAreaUrbanSemiRural}'),
                      ])),
              _buildTableRow(
                  '11.',
                  'Coming under Corporation limit / Village Panchayat /',
                  ': ${data.comingUnder}'),
              _buildTableRow(
                  '12.',
                  'Whether covered under any State / Central Govt. enactments (e.g. Urban Land Ceiling Act) or notified under',
                  ': ${data.coveredUnderGovtEnactments}'),
              _buildTableRow(
                  '13.',
                  'In case it is an agricultural land, any conversion to house site plots is contemplated',
                  ': ${data.isAgriculturalLand}'),
            ]),
            pw.SizedBox(height: 10),
            _buildSectionTableWithHeader(
                header:
                    _buildTableRow('II.', 'APARTMENT BUILDING', '', bold: true),
                rows: [
                  _buildTableRow('1.', 'Nature of the Apartment',
                      ': ${data.natureOfApartment}'),
                  _buildTableRow('2.', 'Year of Construction',
                      ': ${data.yearOfConstruction}'),
                  // --- ADD THIS NEW, CORRECTED BLOCK IN ITS PLACE ---

// Row for item 3's headers
                  pw.TableRow(
                    children: [
                      _dataCell('3.'), // Cell 1: The number
                      _dataCell(''), // Cell 2: Spanning header
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                        children: [
                          pw.Row(
                            children: [
                              pw.Expanded(
                                flex: 6,
                                child: pw.Row(
                                  children: [
                                    pw.Expanded(
                                      child: pw.Text(
                                        'As per actuals',
                                        textAlign: pw.TextAlign.center,
                                        style: pw.TextStyle(
                                            fontWeight: pw.FontWeight.bold),
                                      ),
                                    ),
                                    // Vertical divider
                                    pw.Container(
                                      width: 1,
                                      height: 20,
                                      color: PdfColors.black,
                                    ),
                                    pw.Expanded(
                                      child: pw.Text(
                                        'As per approved',
                                        textAlign: pw.TextAlign.center,
                                        style: pw.TextStyle(
                                            fontWeight: pw.FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),

// Row for "Number of Floors"
                  pw.TableRow(
                    children: [
                      _dataCell(''), // Empty Sl No.
                      _dataCell('Number of Floors'), // Label
                      pw.Row(
                        children: [
                          pw.Expanded(
                            child: pw.Text(
                              data.numFloorsActuals,
                              textAlign: pw.TextAlign.center,
                            ),
                          ),
                          pw.Container(
                            width: 1,
                            height: 20,
                            color: PdfColors.black,
                          ),
                          pw.Expanded(
                            child: pw.Text(
                              data.numFloorsApproved,
                              textAlign: pw.TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

// Row for "Number of Units"
                  pw.TableRow(
                    children: [
                      _dataCell(''), // Empty Sl No.
                      _dataCell('Number of Units'), // Label
                      pw.Row(
                        children: [
                          pw.Expanded(
                            child: pw.Text(
                              data.numUnitsActuals,
                              textAlign: pw.TextAlign.center,
                            ),
                          ),
                          pw.Container(
                            width: 1,
                            height: 20,
                            color: PdfColors.black,
                          ),
                          pw.Expanded(
                            child: pw.Text(
                              data.numUnitsApproved,
                              textAlign: pw.TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

// Row for "Deviations if any"
                  pw.TableRow(
                    children: [
                      _dataCell(''), // Empty Sl No.
                      _dataCell('Deviations if any:'), // Label
                      pw.Row(
                        children: [
                          pw.Expanded(
                            child: pw.Text(
                              data.deviationsActuals,
                              textAlign: pw.TextAlign.center,
                            ),
                          ),
                          pw.Container(
                            width: 1,
                            height: 20,
                            color: PdfColors.black,
                          ),
                          pw.Expanded(
                            child: pw.Text(
                              data.deviationsApproved,
                              textAlign: pw.TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

// --- END OF NEW BLOCK ---
                  _buildTableRow(
                      '4.',
                      'The width of the road abutting the project',
                      ': ${data.roadWidth}'),
                  _buildTableRow(
                      '5.',
                      'The RERA registration No. with validity date\'s',
                      data.reraNoAndDate),
                  _buildTableRow(
                      '6.', 'Type of Structure', ': ${data.typeOfStructure}'),
                  _buildTableRow(
                      '7.', 'Age of the building', ': ${data.ageOfBuilding}'),
                  _buildTableRow('8.', 'Residual age of the building',
                      ': ${data.residualAge}'),
                  _buildTableRow('9.', 'Maintenance of the Building',
                      ': ${data.maintenanceOfBuilding}'),
                  _buildTableRow('10.', 'Facilities Available',
                      ':'), // Title row with just a colon
                  _buildTableRow('', 'Lift', ': ${data.facilitiesLift}'),
                  _buildTableRow('', 'Protected Water Supply',
                      ': ${data.facilitiesWater}'),
                  _buildTableRow('', 'Underground Sewerage',
                      ': ${data.facilitiesSewerage}'),
                  _buildTableRow('', 'Car Parking - Open/ Covered',
                      ': ${data.facilitiesCarParking}'),
                  _buildTableRow('', 'Is Compound wall existing?',
                      ': ${data.facilitiesCompoundWall}'),
                  _buildTableRow('', 'Is pavement laid around the Building',
                      ': ${data.facilitiesPavement}'),
                  _buildTableRow('', 'Extract Amenities If any',
                      ': ${data.facilitiesExtraAmenities}'),
                ]),
          ],
        );
      },
    );
  }

  pw.Page _buildPage3() {
    return pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        build: (context) {
          return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _buildSectionTableWithHeader(
                    header: _buildTableRow('III.', 'FLAT', '', bold: true),
                    rows: [
                      _buildTableRow(
                          '1.',
                          'The floor on which the flat is situated',
                          ': ${data.flatFloor}'),
                      _buildTableRow(
                          '2.', 'Door No. of the flat', ': ${data.flatDoorNo}'),
                      _buildTableRow('3.', 'Specifications of the flat', ':'),
                      _buildTableRow('', 'Roof', ': ${data.specRoof}'),
                      _buildTableRow('', 'Flooring', ': ${data.specFlooring}'),
                      _buildTableRow('', 'Doors', ': ${data.specDoors}'),
                      _buildTableRow('', 'Windows', ': ${data.specWindows}'),
                      _buildTableRow('', 'Fittings', ': ${data.specFittings}'),
                      _buildTableRow(
                          '', 'Finishing', ': ${data.specFinishing}'),
                      _buildTableRow('4.', 'Electricity Service Connection no.',
                          ': ${data.electricityConnectionNo}'),
                      _buildTableRow('', 'Meter Card is in the name of',
                          ': ${data.meterCardName}'),
                      _buildTableRow(
                          '5.',
                          'How is the maintenance of the flat?',
                          ': ${data.flatMaintenance}'),
                      _buildTableRow('6.', 'Sale Deed executed in the name of',
                          ': ${data.saleDeedName}'),
                      _buildTableRow(
                          '7.',
                          'What is the undivided area of land as per Sale Deed?',
                          ': ${data.undividedLandArea}'),
                      _buildTableRow(
                          '8.',
                          'What is the supper Built Up/ Built Up/Carpet area of the flat?',
                          ': ${data.flatArea}'),
                      _buildTableRow(
                          '9.',
                          'Is it Posh/ I class / Medium / Ordinary?',
                          ': ${data.flatClass}'),
                      _buildTableRow(
                          '10.',
                          'Is it being used for Residential or Commercial purpose?',
                          ': ${data.flatUsage}'),
                      _buildTableRow('11.', 'Is it Owner-occupied or let out?',
                          ': ${data.flatOccupancy}'),
                      _buildTableRow(
                          '12.',
                          'If rented, what is the monthly rent?',
                          ': ${data.flatMonthlyRent}'),
                    ]),
                pw.SizedBox(height: 10),
                _buildSectionTableWithHeader(
                    header: _buildTableRow('IV', 'Rate', '', bold: true),
                    rows: [
                      _buildTableRow(
                          '1.',
                          'After analyzing the comparable sale instances, what is the composite rate for a similar flat with same specifications in the adjoining locality?',
                          data.rateComparable),
                      _buildTableRow(
                          '2.',
                          'Assuming it is a new construction, what is the adopted basic composite rate of the flat under valuation after comparing with the specifications and othe factors with the flat under comparison (give details).',
                          data.rateNewConstruction),
                      _buildTableRow(
                          '3.',
                          'Guideline rate obtained from the Registrar\'s office (an evidence thereof to be enclosed)',
                          data.rateGuideline),
                    ]),
              ]);
        });
  }

  pw.Page _buildPage4() {
    final dateFormat = DateFormat('dd-MM-yyyy');
    return pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        build: (context) {
          return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Details of Valuation:',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.Table(border: pw.TableBorder.all(), columnWidths: {
                  0: const pw.FlexColumnWidth(1),
                  1: const pw.FlexColumnWidth(4),
                  2: const pw.FlexColumnWidth(2),
                  3: const pw.FlexColumnWidth(2),
                  4: const pw.FlexColumnWidth(2)
                }, children: [
                  pw.TableRow(children: [
                    _headerCell('Sr.No'),
                    _headerCell('Description'),
                    _headerCell('Area in Sqft'),
                    _headerCell('Rate Per unit Rs'),
                    _headerCell('Estimated Rs.')
                  ]),
                  ...data.valuationDetails.asMap().entries.map((entry) {
                    int idx = entry.key;
                    ValuationDetailItem item = entry.value;
                    return pw.TableRow(children: [
                      _dataCell((idx + 1).toString()),
                      _dataCell(item.description),
                      _dataCell(item.area),
                      _dataCell(item.ratePerUnit),
                      _dataCell(item.estimatedValue),
                    ]);
                  }),
                ]),
                pw.SizedBox(height: 20),
                pw.Text('Consolidated Remarks/ Observations of the property:',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.Text('1. ${data.remarks1}'),
                pw.Text('2. ${data.remarks2}'),
                pw.Text('3. ${data.remarks3}'),
                pw.Text('4. ${data.remarks4}'),
                pw.SizedBox(height: 10),
                pw.Text(
                    '(Valuation: Here the approved valuer should discuss in detail his approach to valuation of property and indicate how the value has been arrived at, supported by necessary calculations. Also, such aspects as impending threat of acquisition by government for road widening / public service purposes, sub merging & applicability of CRZ provisions (Distance from sea-coast / tidal level must be incorporated) and their effect on i) salability ii) likely rental value in future and iii) any likely income it may generate may be discussed).',
                    style: const pw.TextStyle(fontSize: 10)),
                // pw.SizedBox(height: ),
                // pw.Text(data.valuationApproach, style:  pw.TextStyle(fontSize: 10, fontStyle: pw.FontStyle.italic)),
                pw.SizedBox(height: 10),
                pw.Text(
                    'Photograph of owner/representative with property in background to be enclosed.',
                    style: const pw.TextStyle(fontSize: 10)),
                pw.SizedBox(height: 10),
                pw.Text(
                    'Screen shot of longitude/latitude and co-ordinates of property using GPS/Various Apps/Internet sites',
                    style: const pw.TextStyle(fontSize: 10)),
                pw.SizedBox(height: 10),
                pw.Text(
                    'As a result of my appraisal and analysis, it is my considered opinion that the present value\'s of the above property in the prevailing condition with aforesaid specifications is'),
                pw.SizedBox(height: 10),
                pw.Table(
                    columnWidths: {
                      0: const pw.FlexColumnWidth(
                          2.5), // First column - 3 parts
                      1: const pw.FlexColumnWidth(
                          2.5), // Second column - 2 parts
                    },
                    border: pw.TableBorder.all(),
                    children: [
                      pw.TableRow(children: [
                        pw.Text('  Present Market Value of The Property',
                            style: const pw.TextStyle(fontSize: 10)),
                        pw.Text('  ${data.presentMarketValue}',
                            style: const pw.TextStyle(fontSize: 10))
                      ]),
                      pw.TableRow(children: [
                        pw.Text('  Realizable Value of the Property',
                            style: const pw.TextStyle(fontSize: 10)),
                        pw.Text('  ${data.realizableValue}',
                            style: const pw.TextStyle(fontSize: 10))
                      ]),
                      pw.TableRow(children: [
                        pw.Text('  Distress Value of the Property',
                            style: const pw.TextStyle(fontSize: 10)),
                        pw.Text('  ${data.distressValue}',
                            style: const pw.TextStyle(fontSize: 10))
                      ]),
                      pw.TableRow(children: [
                        pw.Text('  Insurable Value of the property',
                            style: const pw.TextStyle(fontSize: 10)),
                        pw.Text('  ${data.insurableValue}',
                            style: const pw.TextStyle(fontSize: 10))
                      ]),
                    ]),
                pw.SizedBox(height: 70),
                pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text('Place: ${data.finalValuationPlace}'),
                            pw.Text(
                                'Date: ${data.finalValuationDate != null ? dateFormat.format(data.finalValuationDate!) : ''}'),
                          ]),
                      pw.Column(children: [
                        pw.Text('Signature'),
                        pw.Text(
                            '(Name and Official seal of\nthe Approved Valuer)',
                            textAlign: pw.TextAlign.center),
                      ]),
                    ]),
                pw.Spacer(),
                // pw.Center(child: pw.Text('Page 4 of 7')),
              ]);
        });
  }

  pw.Page _buildPage6() {
    final declarationDateFormat = DateFormat('dd-MM-yyyy');
    return pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(48),
        build: (context) {
          return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Center(
                    child: pw.Text('FORMAT E',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                pw.Center(
                    child: pw.Text('DECLARATION FROM VALUERS',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                pw.SizedBox(height: 20),
                pw.Text('I hereby declare that-'),
                pw.SizedBox(height: 15),
                _buildDeclarationPoint('a.',
                    'The information furnished in my valuation report dated ${data.dateOfValuation != null ? declarationDateFormat.format(data.dateOfValuation!) : ''} is true and correct to the best of my knowledge and belief and I have made an impartial and true valuation of the property.'),
                _buildDeclarationPoint('b.',
                    'I have no direct or indirect interest in the property valued;'),
                _buildDeclarationPoint('c.',
                    'I have personally inspected the property on ${data.dateOfInspection != null ? declarationDateFormat.format(data.dateOfInspection!) : ''} The work is not sub-contracted to any other valuer and carried out by myself.'),
                _buildDeclarationPoint('d.',
                    'I have not been convicted of any offence and sentenced to a term of Imprisonment;'),
                _buildDeclarationPoint('e.',
                    'I have not been found guilty of misconduct in my professional capacity.'),
                _buildDeclarationPoint('f.',
                    'I have read the Handbook on Policy, Standards and procedure for Real Estate Valuation, 2011 of the IBA and this report is in conformity to the "Standards" enshrined for valuation in the Part-B of the above handbook to the best of my ability.'),
                _buildDeclarationPoint('g.',
                    'I have read the International Valuation Standards (IVS) and the report submitted to the Bank for the respective asset class is in conformity to the "Standards" as enshrined for valuation in the IVS in "General Standards" and "Asset Standards" as applicable.'),
                _buildDeclarationPoint('h.',
                    'I abide by the Model Code of Conduct for empanelment of valuer in the Bank. (Annexure III- A signed copy of same to be taken and kept along with this declaration)'),
                _buildDeclarationPoint('i.',
                    'I am registered under Section 34 AB of the Wealth Tax Act, 1957.'),
                _buildDeclarationPoint('j.',
                    'I am the proprietor / partner / authorized official of the firm / company, who is competent to sign this valuation report.'),
                _buildDeclarationPoint('k.',
                    'Further, I hereby provide the following information.'),
                pw.Spacer(),
                // pw.Center(child: pw.Text('Page 6 of 7')),
              ]);
        });
  }

  pw.Page _buildPage7() {
    final dateFormat = DateFormat('dd-MM-yyyy');
    return pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        build: (context) {
          return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Table(border: pw.TableBorder.all(), columnWidths: {
                  0: const pw.FlexColumnWidth(1),
                  1: const pw.FlexColumnWidth(4),
                  2: const pw.FlexColumnWidth(6)
                }, children: [
                  pw.TableRow(children: [
                    _headerCell('Sl No.'),
                    _headerCell('Particulars'),
                    _headerCell('Valuer comment')
                  ]),
                  _finalTableRow(
                      '1',
                      'background information of the asset being valued;',
                      data.p7background),
                  _finalTableRow(
                      '2',
                      'purpose of valuation and appointing authority',
                      data.p7purpose),
                  _finalTableRow(
                      '3',
                      'identity of the valuer and any other experts involved in the valuation;',
                      data.p7identity),
                  _finalTableRow(
                      '4',
                      'disclosure of valuer interest or conflict, if any;',
                      data.p7disclosure),
                  _finalTableRow(
                      '5',
                      'date of appointment, valuation date and date of report;',
                      data.p7dates),
                  _finalTableRow(
                      '6',
                      'inspections and/or investigations undertaken;',
                      data.p7inspections),
                  _finalTableRow(
                      '7',
                      'nature and sources of the information used or relied upon;',
                      data.p7nature),
                  _finalTableRow(
                      '8',
                      'procedures adopted in carrying out the valuation and valuation standards followed;',
                      data.p7procedures),
                  _finalTableRow(
                      '9',
                      'restrictions on use of the report, if any;',
                      data.p7restrictions),
                  _finalTableRow(
                      '10',
                      'major factors that were taken into account during the valuation;',
                      data.p7majorFactors1),
                  _finalTableRow(
                      '11',
                      'major factors that were taken into account during the valuation;',
                      data.p7majorFactors2),
                  _finalTableRow(
                      '12',
                      'Caveats, limitations and disclaimers to the extent they explain or elucidate the limitations faced by valuer, which shall not be for the purpose of limiting his responsibility for the valuation report.',
                      data.p7caveats),
                ]),
                pw.SizedBox(height: 20),
                pw.Text(
                    'Date: ${data.p7reportDate != null ? dateFormat.format(data.p7reportDate!) : ''}'),
                pw.Text('Place: ${data.p7reportPlace}'),
                pw.Spacer(),
                pw.Align(
                    alignment: pw.Alignment.centerRight,
                    child: pw.Column(children: [
                      pw.Text('Signature'),
                      pw.Text(
                          '(Name of the Approved Valuer and Seal of the Firm /Company)'),
                    ])),
                pw.Spacer(),
                // pw.Center(child: pw.Text('Page 7 of 7')),
              ]);
        });
  }

  // Helper Widgets for PDF
// NEW, CORRECT DEFINITION
  pw.TableRow _buildTableRow(String col1, dynamic col2, dynamic col3,
      {bool bold = false}) {
    return pw.TableRow(
      children: [
        pw.Padding(
            padding: const pw.EdgeInsets.all(2),
            child: pw.Text(col1,
                style: pw.TextStyle(
                    fontWeight:
                        bold ? pw.FontWeight.bold : pw.FontWeight.normal))),
        // Check if col2 is a String or a Widget before wrapping in a Text widget
        pw.Padding(
            padding: const pw.EdgeInsets.all(2),
            child: col2 is String
                ? pw.Text(col2,
                    style: pw.TextStyle(
                        fontWeight:
                            bold ? pw.FontWeight.bold : pw.FontWeight.normal))
                : col2),
        // Check if col3 is a String or a Widget
        pw.Padding(
            padding: const pw.EdgeInsets.all(2),
            child: col3 is String
                ? pw.Text(col3,
                    style: pw.TextStyle(
                        fontWeight:
                            bold ? pw.FontWeight.bold : pw.FontWeight.normal))
                : col3),
      ],
    );
  }

  pw.TableRow _finalTableRow(String slNo, String particulars, String comment) {
    return pw.TableRow(children: [
      _dataCell(slNo),
      _dataCell(particulars),
      _dataCell(comment),
    ]);
  }

  pw.Widget _buildSectionTable(List<pw.TableRow> rows) {
    return pw.Table(
      border: pw.TableBorder.all(),
      columnWidths: {
        0: const pw.FlexColumnWidth(1),
        1: const pw.FlexColumnWidth(4),
        2: const pw.FlexColumnWidth(6)
      },
      children: rows,
    );
  }

  pw.Widget _buildSectionTableWithHeader(
      {required pw.TableRow header, required List<pw.TableRow> rows}) {
    return pw.Table(
      border: pw.TableBorder.all(),
      columnWidths: {
        0: const pw.FlexColumnWidth(1),
        1: const pw.FlexColumnWidth(4),
        2: const pw.FlexColumnWidth(6)
      },
      children: [header, ...rows],
    );
  }

  pw.Widget _headerCell(String text) => pw.Padding(
      padding: const pw.EdgeInsets.all(4),
      child: pw.Text(text,
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          textAlign: pw.TextAlign.center));
  pw.Widget _dataCell(String text, {bool bold = false}) => pw.Padding(
      padding: const pw.EdgeInsets.all(2),
      child: pw.Text(text,
          style: pw.TextStyle(
              fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal)));

  pw.Widget _buildDeclarationPoint(String label, String text) {
    return pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 4),
        child:
            pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          pw.SizedBox(width: 20, child: pw.Text(label)),
          pw.Expanded(child: pw.Text(text, textAlign: pw.TextAlign.justify)),
        ]));
  }
}
