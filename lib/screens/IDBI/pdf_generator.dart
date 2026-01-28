import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:number_to_indian_words/number_to_indian_words.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/pdf.dart' as pdfLib;
import 'package:pdf/widgets.dart' as pw;
import 'valuation_data_model.dart';

class PdfGenerator {
  final ValuationData data;
  final pw.Font font;
  final pw.Font boldFont;

  PdfGenerator(this.data)
      : font = pw.Font.helvetica(),
        boldFont = pw.Font.helveticaBold();

  Future<Uint8List> generate() async {
    final pdf = pw.Document();
    final Uint8List logoBytes =
        (await rootBundle.load('assets/images/symbol.jpg'))
            .buffer
            .asUint8List();

    // 2. Create the PDF image object
    final pw.MemoryImage logoImage = pw.MemoryImage(logoBytes);
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        build: (context) => [
          _buildHeader(logoImage),
          pw.SizedBox(height: 20),
          _buildRecipient(),
          pw.SizedBox(height: 10),
          _buildTitle(),
          pw.SizedBox(height: 10),
          _buildGeneralSection(),
          pw.SizedBox(height: 10),
          _buildPhysicalDetailsSection(),
          pw.SizedBox(height: 10),
          _buildPhysicalDetailsOfBuildingSection(),
          pw.SizedBox(height: 10),
          _buildAreaDetailsSection(),
          pw.SizedBox(height: 10),
          _buildDetailedValuationSection(),
          _buildBuildingValuationSection(),
          _buildGrandTotalSection(),
          pw.SizedBox(height: 20),
          _buildDeclarationAndFooter(),
        ],
        footer: (context) {
          return pw.Container(
            alignment: pw.Alignment.centerRight,
            child: pw.Text(
              '${context.pageNumber}',
              style: pw.TextStyle(font: font),
            ),
          );
        },
      ),
    );

    if (data.images.isNotEmpty) {
      pdf.addPage(_buildImagePage(data));
    }

    return pdf.save();
  }

  pw.MultiPage _buildImagePage(ValuationData data) {
    return pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(10),
      header: (context) => pw.Text('Uploaded Images',
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16)),
      build: (context) => [
        pw.GridView(
          crossAxisCount: 2,
          childAspectRatio: 1.1,
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

  // ============== HELPER WIDGETS =============

  // REPLACE THE EXISTING _buildHeader METHOD WITH THIS
  pw.Widget _buildHeader(pw.MemoryImage logoImage) {
    return pw.Column(
      children: [
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
                data.valuerAddressLine1,
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
              mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Phone
                pw.Row(
                  children: [
                    pw.Text(
                      'Phone: ${data.valuerMob}',
                      style: const pw.TextStyle(fontSize: 12),
                    ),
                  ],
                ),

                // Email
                pw.Row(
                  children: [
                    pw.Text(
                      'Email: ${data.valuerEmail}',
                      style: const pw.TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        // pw.Divider(thickness: 1, height: 10),
        // pw.Center(
        //     child: pw.Text(data.valuerAddressLine1,
        //         style: pw.TextStyle(font: font))),
        // pw.Divider(thickness: 1, height: 10),
      ],
    );
  }

  pw.Widget _buildRecipient() {
    print(data.bankName);
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('TO,', style: pw.TextStyle(font: font)),
        pw.SizedBox(height: 5),
        pw.Text('\t\tBranch Head', style: pw.TextStyle(font: boldFont)),
        pw.Text('\t\t${data.bankName}', style: pw.TextStyle(font: boldFont)),
        pw.Text('\t\t${data.branchName}', style: pw.TextStyle(font: boldFont)),
        pw.Text('\t\tTRIVANDRUM', style: pw.TextStyle(font: boldFont)),
      ],
    );
  }

  pw.Widget _buildTitle() {
    return pw.Center(
      child: pw.Text('VALUATION REPORT', style: pw.TextStyle(font: boldFont)),
    );
  }

  pw.Widget _buildGeneralSection() {
    final formatter = DateFormat('dd-MM-yyyy');
    return pw.Table(
      border: pw.TableBorder.all(),
      columnWidths: const {0: pw.FlexColumnWidth(1), 1: pw.FlexColumnWidth(3)},
      defaultVerticalAlignment: pw.TableCellVerticalAlignment.middle,
      children: [
        pw.TableRow(
          children: [
            _cell('I', isBold: true),
            _cell('GENERAL', isBold: true),
          ],
        ),
        _buildSimpleRow('Case Type', data.caseType),
        _buildSimpleRow('Application no.', data.applicationNo),
        _buildSimpleRow(
            'Date of Inspection',
            data.inspectionDate != null
                ? formatter.format(data.inspectionDate!)
                : ''),
        _buildSimpleRow('1. Name of the title holder', data.titleHolderName),
        _buildSimpleRow('2. Name of the borrower', data.borrowerName),
        pw.TableRow(
          children: [
            _cell('3. List of documents verified'),
            pw.Table(
              border: pw.TableBorder.all(),
              children: data.docs.map((doc) {
                return _buildSimpleRow(
                  doc['label'] ?? '',
                  doc['val'] ?? '', // Dynamic value from UI
                );
              }).toList(),
            ),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildPhysicalDetailsSection() {
    return pw.Table(
      border: pw.TableBorder.all(),
      columnWidths: const {0: pw.FlexColumnWidth(1), 1: pw.FlexColumnWidth(3)},
      defaultVerticalAlignment: pw.TableCellVerticalAlignment.top,
      children: [
        pw.TableRow(
          children: [
            _cell('II', isBold: true),
            _cell('PHYSICAL DETAILS OF LAND', isBold: true),
          ],
        ),
        _buildSimpleRow(
          '1. Brief description of the property',
          data.briefDescription,
        ),
        _buildSimpleRow(
          '2. Location of the property with nearest landmark.',
          data.locationAndLandmark,
        ),
        pw.TableRow(
          children: [
            _cell('3. Details of land'),
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Expanded(
                  flex: 1,
                  child: pw.Table(
                    border: pw.TableBorder.all(),
                    children: [
                      _buildSimpleRow('a. Re Sy. No.', data.reSyNo),
                      _buildSimpleRow('b. Block no.', data.blockNo),
                      _buildSimpleRow('c. Village', data.village),
                      _buildSimpleRow('d. Taluk', data.taluk),
                      _buildSimpleRow('e. District', data.district),
                      _buildSimpleRow('f. State', data.state),
                      _buildSimpleRow('g. Post office', data.postOffice),
                      _buildSimpleRow('h. Pin code', data.pinCode),
                    ],
                  ),
                ),
                pw.Expanded(
                  flex: 1,
                  child: _cell(
                    'Postal address of the property\n\n${data.postalAddress}',
                  ),
                ),
              ],
            ),
          ],
        ),
        pw.TableRow(
          children: [
            _cell('4. Boundaries'),
            pw.TableHelper.fromTextArray(
              border: pw.TableBorder.all(),
              cellStyle: pw.TextStyle(font: font),
              headerStyle: pw.TextStyle(
                font: font,
                fontWeight: pw.FontWeight.normal,
              ),
              headerCellDecoration: const pw.BoxDecoration(
                color: PdfColors.white,
              ),
              headers: ['', 'As per sale location sketch', 'Actual at site'],
              data: [
                ['North', data.northAsPerSketch, data.northActual],
                ['South', data.southAsPerSketch, data.southActual],
                ['East', data.eastAsPerSketch, data.eastActual],
                ['West', data.westAsPerSketch, data.westActual],
              ],
              columnWidths: {
                0: const pw.FlexColumnWidth(1),
                1: const pw.FlexColumnWidth(2),
                2: const pw.FlexColumnWidth(2),
              },
            ),
          ],
        ),
        _buildSimpleRow('5. Local authority', data.localAuthority),
        _buildSimpleRow(
          '6. Property identified?',
          data.isPropertyIdentified ? 'Yes' : 'No',
        ),
        _buildSimpleRow('7. Plot demarcated', data.plotDemarcated),
        _buildSimpleRow('8. Nature of property', data.natureOfProperty),
        _buildSimpleRow('9. Class of property', data.classOfProperty),
        _buildSimpleRow(
          '10. Topographical condition of the plot',
          data.topographicalCondition,
        ),
        _buildSimpleRow(
          '11. Chance of acquisition?',
          data.chanceOfAcquisition ? 'No' : 'Yes',
        ),
        _buildSimpleRow('12. Approved land used', data.approvedLandUse),
        _buildSimpleRow(
          '13. Four wheeler accessibility',
          data.fourWheelerAccessibility,
        ),
        pw.TableRow(
          children: [
            _cell('14. Tenuer/occupancy status of tenuer'),
            pw.Table(
              border: pw.TableBorder.all(),
              children: [
                _buildSimpleRow('a. Occupied by Owner/Tenant', data.occupiedBy),
                _buildSimpleRow(
                  'b. No. of years of occupancy',
                  data.yearsOfOccupancy,
                ),
                _buildSimpleRow(
                  'c. Relationship of owner & occupant',
                  data.ownerRelationship,
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  // Add this new method inside the PdfGenerator class
  pw.Widget _buildPhysicalDetailsOfBuildingSection() {
    return pw.Table(
      border: pw.TableBorder.all(),
      columnWidths: const {0: pw.FlexColumnWidth(1), 1: pw.FlexColumnWidth(2)},
      defaultVerticalAlignment: pw.TableCellVerticalAlignment.middle,
      children: [
        pw.TableRow(children: [
          _cell('II', isBold: true),
          _cell('PHYSICAL DETAILS OF BUILDING', isBold: true),
        ]),
        _buildSimpleRow('1. Building no.', data.buildingNo),
        _buildSimpleRow(
            '2. Approving authority of building plan', data.approvingAuthority),
        _buildSimpleRow(
            '3. Stage of construction (%)', data.stageOfConstruction),
        _buildSimpleRow('4. Type of structure', data.typeOfStructure),
        _buildSimpleRow('5. No. of floors', data.noOfFloors),
        pw.TableRow(children: [
          _cell('6. No. of rooms'),
          pw.Table(border: pw.TableBorder.all(), children: [
            pw.TableRow(children: [
              _cell('Living/dining'),
              _cell('Bedrooms'),
              _cell('Toilets'),
              _cell('Kitchen'),
            ]),
            pw.TableRow(children: [
              _cell(data.livingDiningRooms),
              _cell(data.bedrooms),
              _cell(data.toilets),
              _cell(data.kitchen),
            ]),
          ])
        ]),
        _buildSimpleRow('7. Type of flooring', data.typeOfFlooring),
        _buildSimpleRow('8. Age of the building', data.ageOfBuilding),
        _buildSimpleRow('9. Residual life of the building', data.residualLife),
        _buildSimpleRow(
            '10. Violation if any observed', data.violationObserved),
      ],
    );
  }

  pw.Widget _buildAreaDetailsSection() {
    return pw.Table(
      border: pw.TableBorder.all(),
      columnWidths: const {0: pw.FlexColumnWidth(1), 1: pw.FlexColumnWidth(2)},
      children: [
        pw.TableRow(
          children: [
            _cell('III', isBold: true),
            _cell('AREA DETAILS OF THE PROPERTY', isBold: true),
          ],
        ),
        _buildSimpleRow('1. Area of land', data.areaOfLand),
        _buildSimpleRow('2. Plinth area of proposed building', data.plinthArea),
        _buildSimpleRow('3. Carpet area of building', data.carpetArea),
        _buildSimpleRow('4. Saleable area', data.saleableArea),
      ],
    );
  }

  pw.Widget _buildDetailedValuationSection() {
    return pw.Table(
      border: pw.TableBorder.all(),
      columnWidths: const {0: pw.FlexColumnWidth(1), 1: pw.FlexColumnWidth(2)},
      children: [
        pw.TableRow(
          children: [
            _cell('VI', isBold: true),
            _cell('DETAILED VALUATION', isBold: true),
          ],
        ),
        pw.TableRow(
          children: [
            _cell('1. Land valuation'),
            pw.Column(
              children: [
                pw.TableHelper.fromTextArray(
                  border: pw.TableBorder.all(),
                  cellStyle: pw.TextStyle(font: font),
                  headerStyle: pw.TextStyle(font: font),
                  headers: ['Extent', 'Rate/Cent', 'Total'],
                  data: [
                    [
                      data.landExtent,
                      'Rs. ${data.landRatePerCent}',
                      'Rs. ${data.landTotalValue}',
                    ],
                  ],
                ),
                pw.Table(
                  border: pw.TableBorder.all(),
                  children: [
                    _buildSimpleRow(
                      'Market value of land',
                      'Rs. ${data.landMarketValue}',
                    ),
                    _buildSimpleRow(
                      'Realizable value of land',
                      'Rs. ${data.landRealizableValue}',
                    ),
                    _buildSimpleRow(
                      'Distress value of land',
                      'Rs. ${data.landDistressValue}',
                    ),
                    _buildSimpleRow(
                      'Fair value of land',
                      'Rs. ${data.landFairValue}',
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildBuildingValuationSection() {
    return pw.Table(
      border: pw.TableBorder.all(),
      columnWidths: const {0: pw.FlexColumnWidth(1), 1: pw.FlexColumnWidth(2)},
      children: [
        pw.TableRow(
          children: [
            _cell('2. Building valuation'),
            pw.Column(
              children: [
                pw.TableHelper.fromTextArray(
                  border: pw.TableBorder.all(),
                  cellStyle: pw.TextStyle(font: font),
                  headerStyle: pw.TextStyle(font: font),
                  headers: ['Plinth Area', 'Rate/Sqft', 'Total'],
                  data: [
                    [
                      data.buildingPlinth,
                      'Rs. ${data.buildingRatePerSqft}',
                      'Rs. ${data.buildingTotalValue}',
                    ],
                  ],
                ),
                pw.Table(
                  border: pw.TableBorder.all(),
                  children: [
                    _buildSimpleRow(
                      'Market value of land',
                      'Rs. ${data.buildingMarketValue}',
                    ),
                    _buildSimpleRow(
                      'Realizable value of land',
                      'Rs. ${data.buildingRealizableValue}',
                    ),
                    _buildSimpleRow(
                      'Distress value of land',
                      'Rs. ${data.buildingDistressValue}',
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildGrandTotalSection() {
    return pw.Table(
      border: pw.TableBorder.all(),
      columnWidths: const {0: pw.FlexColumnWidth(1), 1: pw.FlexColumnWidth(2)},
      children: [
        pw.TableRow(children: [
          _cell('3. GRAND TOTAL (Land)', isBold: true),
          _cell(''),
        ]),
        _buildSimpleRow(
          'Market value',
          _formatValueInWords(data.grandTotalMarketValue),
        ),
        _buildSimpleRow(
          'Realizable value',
          _formatValueInWords(data.grandTotalRealizableValue),
          isValueBold: true,
        ),
        _buildSimpleRow(
          'Distress value',
          _formatValueInWords(data.grandTotalDistressValue),
        ),
      ],
    );
  }

  pw.Widget _buildDeclarationAndFooter() {
    final formatter = DateFormat('dd-MM-yyyy');
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Table(
          border: pw.TableBorder.all(),
          columnWidths: const {
            0: pw.FlexColumnWidth(1),
            1: pw.FlexColumnWidth(2),
          },
          children: [
            pw.TableRow(
              children: [
                _cell('V', isBold: true),
                _cell('LIST OF DOCUMENTS ENCLOSED', isBold: true),
              ],
            ),
            _buildSimpleRow(
              '',
              'a. Coordinates (Latitude & Longitude) of the property.',
            ),
            _buildSimpleRow(
              '',
              'b. Route map of the property with nearest landmark.',
            ),
            _buildSimpleRow(
              '',
              'c. Photographs of the property (Interior, front elevation & approach road).',
            ),
          ],
        ),
        pw.SizedBox(height: 10),
        pw.Table(
          border: pw.TableBorder.all(),
          columnWidths: const {
            0: pw.FlexColumnWidth(0.1),
            1: pw.FlexColumnWidth(2),
          },
          children: [
            pw.TableRow(
              children: [
                _cell('VI', isBold: true),
                _cell('DECLARATION', isBold: true),
              ],
            ),
            pw.TableRow(
              children: [
                _cell('a.', align: pw.Alignment.topCenter),
                _cell(
                  'The property was inspected by the undersigned on ${data.inspectionDate != null ? formatter.format(data.inspectionDate!) : ''}.',
                ),
              ],
            ),
            pw.TableRow(
              children: [
                _cell('b.', align: pw.Alignment.topCenter),
                _cell(
                  'The undersigned does not have any direct /indirect interest in the above property.',
                ),
              ],
            ),
            pw.TableRow(
              children: [
                _cell('c.', align: pw.Alignment.topCenter),
                _cell('Legal aspects of the property have not been verified.'),
              ],
            ),
            pw.TableRow(
              children: [
                _cell('d.', align: pw.Alignment.topCenter),
                _cell(
                  'The information furnished herein is true & correct to the best of my knowledge.',
                ),
              ],
            ),
            pw.TableRow(
              children: [
                _cell('e.', align: pw.Alignment.topCenter),
                _cell(
                  'As per G. O. (Ms) 41/2011/LSGD dt 14/02/2011, the State Government, entrusted and empowered the Local Self - Government Institutions (L.S.G.I.) such as Municipal Corporations, Municipalities and Grama Panchayaths, to implement all the Town planning Acts and Rules within the jurisdiction of them. So they are competent to enforce the Town Panning Rules and developmental activities with respect to Town and Country Planning. Moreover the "Kerala Model" developmental activities, are influencing by the geographical, statistical and economical features of the state, and are going on, and seen stretching in a continuous manner all over Kerala irrespective of Municipal Corporations, Municipalities and Grama Panchayaths without creating a noticeable boundaries in between the L.S.G.I\'s. So when compared with the Land value in Municipal Corporations, Municipalities Grama Panchayaths in Kerala are more or less equal, or tends to equal or have nearby value or have very close values when compared with the L.S.G.I\'s. The marketability of this property is good.',
                  align: pw.Alignment.centerLeft,
                ),
              ],
            ),
          ],
        ),
        pw.SizedBox(height: 10),
        pw.Table(border: pw.TableBorder.all(), columnWidths: const {
          0: pw.FlexColumnWidth(1),
          1: pw.FlexColumnWidth(2),
        }, children: [
          pw.TableRow(children: [
            _cell('NAME & ADDRESS OF VALUER', isBold: true),
            _cell('${data.valuerName}\n${data.valuerAddress}'),
          ]),
          pw.TableRow(children: [
            _cell('Remarks', isBold: true),
            _cell(data.remarks),
          ]),
        ]),
        pw.SizedBox(height: 70),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Date: ${data.declarationDate != null ? formatter.format(data.declarationDate!) : ''}',
                ),
                pw.Text('Place: ${data.declarationPlace}'),
              ],
            ),
            pw.Text('Signature of the Valuer'),
          ],
        ),
      ],
    );
  }

  // ============== UTILITY HELPERS ==============

  pw.TableRow _buildSimpleRow(
    String title,
    String value, {
    bool isValueBold = false,
  }) {
    return pw.TableRow(
      children: [
        _cell(title, isBold: false),
        _cell(
          value,
          isBold: isValueBold ||
              title.contains('borrower') ||
              title.contains('holder'),
        ),
      ],
    );
  }

  pw.Widget _cell(
    String text, {
    pw.Alignment align = pw.Alignment.centerLeft,
    bool isBold = false,
    pw.EdgeInsets? padding,
  }) {
    return pw.Padding(
      padding: padding ?? const pw.EdgeInsets.all(4),
      child: pw.Text(
        text,
        style: pw.TextStyle(font: isBold ? boldFont : font),
        textAlign:
            align == pw.Alignment.centerLeft ? null : pw.TextAlign.justify,
      ),
    );
  }

  String _formatValueInWords(String valueStr) {
    final cleanStr = valueStr.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanStr.isEmpty) return valueStr;
    final value = int.tryParse(cleanStr);
    if (value == null) return valueStr;
    return '$valueStr (Rupees ${NumToWords.convertNumberToIndianWords(value)} only)';
  }
}
