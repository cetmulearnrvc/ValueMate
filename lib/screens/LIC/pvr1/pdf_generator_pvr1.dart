// lib/pdf_generator_pvr1.dart
// import 'dart:io';
import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'valuation_data_model_pvr1.dart';

class PdfGeneratorPVR1 {
  final ValuationDataPVR1 data;
  final currencyFormat =
      NumberFormat.currency(locale: 'en_IN', symbol: '', decimalDigits: 0);
  final DateFormat dateFormat = DateFormat('dd-MM-yyyy');

  PdfGeneratorPVR1(this.data);

  Future<Uint8List> generate() async {
    final pdf = pw.Document(version: PdfVersion.pdf_1_5, compress: true);
    pdf.addPage(_buildPage1());
    pdf.addPage(_buildPage2());
    pdf.addPage(_buildPage3());
    pdf.addPage(_buildAnnexurePage());
    if (data.images.isNotEmpty) {
      pdf.addPage(_buildImagePage());
    }
    return pdf.save();
  }

  pw.Page _buildPage1() {
    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(30),
      build: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          _buildTopInfo(),
          pw.Divider(thickness: 1.5),
          _buildSectionA(),
          pw.SizedBox(height: 50),
          _buildSectionB(),
        ],
      ),
    );
  }

  pw.Page _buildPage2() {
    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(30),
      build: (context) => pw.Column(
        children: [
          _buildSectionCPage1(),
          pw.SizedBox(height: 50),
          _buildSectionD(),
          // _buildSectionCPage2(),
          pw.SizedBox(height: 50),
        ],
      ),
    );
  }

  pw.Page _buildPage3() {
    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(30),
      build: (context) => pw.Column(
        children: [
          _sectionTitle('E. TOTAL VALUE'),
          _buildTotalValueTable(),
          _buildKeyValueBordered(
              '5.',
              'State the source for arriving at Market Value',
              data.marketValueSource,
              flexKey: 2,
              flexVal: 3),
          _buildKeyValueBordered(
              '6.',
              'Usage of building- Residential/Commercial...',
              data.buildingUsage,
              flexKey: 2,
              flexVal: 3),
          pw.SizedBox(height: 15),
          _sectionTitle('F. RECOMMENDATION'),
          _buildRecommendationTable(),
          pw.SizedBox(height: 15),
          _buildStageOfConstructionTable(),
          pw.SizedBox(height: 50),
          _sectionTitle('G. CERTIFICATE'),
          _buildCertificate(),
          pw.SizedBox(height: 70),
          _buildSignature(),
          pw.SizedBox(height: 50),
          _seal(),
        ],
      ),
    );
  }

  pw.Page _buildAnnexurePage() {
    return pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(30),
        build: (context) => pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Center(
                      child: pw.Text('PVR-1',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                  pw.Center(
                      child: pw.Text('ANNEXURE',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                  pw.Center(
                      child: pw.Text('Valuation of Existing Building',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                  pw.SizedBox(height: 20),
                  _buildAnnexureTable(),
                  pw.SizedBox(height: 20),
                  _buildKeyValue(
                      '2. Year of Construction', data.annexYearOfConstruction),
                  pw.SizedBox(height: 10),
                  _buildKeyValue('3. Age of the Building and future life',
                      data.annexBuildingAge),
                  pw.SizedBox(height: 20),
                  pw.Text('LOCAL MARKET ENQUIRY',
                      style: const pw.TextStyle(fontSize: 9)),
                  pw.Spacer(),
                  pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text('Place: ${data.certificatePlace}',
                                  style: const pw.TextStyle(fontSize: 9)),
                              pw.Text(
                                  'Date: ${dateFormat.format(data.certificateDate)}',
                                  style: const pw.TextStyle(fontSize: 9)),
                              pw.Text('Time :',
                                  style: const pw.TextStyle(fontSize: 9)),
                            ]),
                        pw.Text('PANEL VALUER',
                            style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold, fontSize: 9)),
                      ])
                ]));
  }

  pw.MultiPage _buildImagePage() {
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
                      child: pw.Image(image, fit: pw.BoxFit.contain),
                    ),
                  ),
                  pw.SizedBox(height: 5),
                  pw.Text(
                    '(Latitude): ${valuationImage.latitude}\n(Longitude): ${valuationImage.longitude}',
                    style: const pw.TextStyle(fontSize: 8),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  pw.Widget _buildHeader() => pw.Center(
          child: pw.Column(children: [
        pw.Text('LIC HOUSING FINANCE LIMITED',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        pw.Text('AREA OFFICE: THIRUVANANTHAPURAM'),
        pw.Text('House Construction',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 5),
        pw.Text('VALUATION REPORT BY PANEL VALUER FOR HOME LOAN',
            style: const pw.TextStyle(decoration: pw.TextDecoration.underline)),
        pw.SizedBox(height: 10),
      ]));

  pw.Widget _buildTopInfo() => pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('* Name of the Panel Valuer'),
                  pw.Text('* Code No.'),
                  pw.Text('Date of Inspection'),
                ]),
            pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(': ${data.valuerName}'),
                  pw.Text(': ${data.valuerCode}'),
                  pw.Text(': ${dateFormat.format(data.inspectionDate)}'),
                ]),
            pw.SizedBox(width: 100),
            pw.Text('PVR 1',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          ]);

  pw.Widget _sectionTitle(String title) => pw.Container(
      width: double.infinity,
      color: PdfColors.grey300,
      padding: const pw.EdgeInsets.all(2),
      margin: const pw.EdgeInsets.only(top: 8),
      child: pw.Text(title,
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)));

  pw.Widget _buildKeyValueBordered(String no, String key, String value,
          {int flexKey = 3, int flexVal = 4}) =>
      pw.Container(
          decoration: const pw.BoxDecoration(
              border: pw.Border(
                  left: pw.BorderSide(width: 0.5),
                  right: pw.BorderSide(width: 0.5),
                  bottom: pw.BorderSide(width: 0.5))),
          padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.SizedBox(
                    width: 20,
                    child: pw.Text(no, style: const pw.TextStyle(fontSize: 9))),
                pw.Expanded(
                    flex: flexKey,
                    child:
                        pw.Text(key, style: const pw.TextStyle(fontSize: 9))),
                pw.Expanded(
                    flex: flexVal,
                    child: pw.Text(value,
                        style: pw.TextStyle(
                            fontSize: 9, fontWeight: pw.FontWeight.bold))),
              ]));
  pw.Widget _buildKeyBoolBordered(String no, String key, bool val,
          {int flexKey = 3, int flexVal = 4}) =>
      _buildKeyValueBordered(no, key, val ? 'Yes' : 'No',
          flexKey: flexKey, flexVal: flexVal);

  pw.Widget _buildSectionA() => pw.Column(children: [
        _sectionTitle('A. GENERAL'),
        _buildKeyValueBordered('1.', 'File No.', data.fileNo),
        _buildKeyValueBordered(
            '2.', '* Name of the Applicant', data.applicantName),
        _buildKeyValueBordered('3.', 'Name of the owner', data.ownerName),
        _buildKeyValueBordered(
            '4.', 'Documents produced for perusal', data.documentsPerused),
        _buildKeyValueBordered(
            '5.',
            'Location of the property : Plot No./ S. No./C.T.S.No. /R.S.No.Village/Block No./ Taluk/Ward.District/Corporation/Municipality',
            data.propertyLocation),
        _buildKeyBoolBordered(
            '6.',
            'Whether address of the site tallies with address at point number \'5\'',
            data.addressTallies),
        _buildKeyBoolBordered(
            '7.', 'Location Sketch Verified', data.locationSketchVerified),
        _buildKeyValueBordered(
            '8.',
            'Development of surrounding area with Special reference to population',
            data.surroundingDev),
        _buildKeyBoolBordered(
            '9.',
            'Whether basic amenities like water, electricity, sewerage, roads, telephone are available',
            data.basicAmenitiesAvailable),
        _buildKeyValueBordered(
            '10.',
            'Any negatives to the locality (Crematoriums, slums, riot prone ,gases, chemical hazards,nagbana etc)',
            data.negativesToLocality),
        _buildKeyValueBordered(
            '11.',
            'Any favorable consideration for additional cost/value',
            data.favorableConsiderations),
        _buildKeyValueBordered(
            '12.', 'Details of the Nearby Landmark', data.nearbyLandmark),
        _buildKeyValueBordered(
            '13.',
            'Any other features like board of other financier indicating mortgage, notice of Court/any authority which may effect the security.',
            data.otherFeatures),
      ]);

  pw.Widget _buildKeyValue(String key, String value) =>
      pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
        pw.Expanded(
            flex: 2,
            child: pw.Text(key, style: const pw.TextStyle(fontSize: 9))),
        pw.Text(': ', style: const pw.TextStyle(fontSize: 9)),
        pw.Expanded(
            flex: 3,
            child: pw.Row(children: [
              pw.SizedBox(width: 10),
              pw.Text(value,
                  style:
                      pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold))
            ])),
      ]);

  pw.Widget _buildKeyBoolValue(String key, bool value) =>
      _buildKeyValue(key, value ? 'Yes' : 'No');

  pw.Widget _buildSectionB() =>
      pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
        _sectionTitle('B. LAND'),
        pw.Text('1. Boundaries & dimensions of the plot',
            style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
        pw.TableHelper.fromTextArray(
          cellStyle: const pw.TextStyle(fontSize: 9),
          headerStyle:
              pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
          border: pw.TableBorder.all(width: 0.5),
          columnWidths: {
            0: const pw.FlexColumnWidth(2),
            1: const pw.FlexColumnWidth(4),
            2: const pw.FlexColumnWidth(3)
          },
          headers: ['Directions', 'Boundaries', 'Dimensions'],
          data: [
            ['North/Front', data.northBoundary, data.northDim],
            ['South/Rear', data.southBoundary, data.southDim],
            ['East/Left (side 1)', data.eastBoundary, data.eastDim],
            ['West/Right (Side 2)', data.westBoundary, data.westDim],
            ['Total extent of land', data.totalExtent1, data.totalExtent2],
          ],
        ),
        pw.SizedBox(height: 5),
        _buildKeyBoolValue(
            '2. Do these boundaries & dimensions tally with the approved drawing? If not furnish details',
            data.boundariesTally),
        pw.SizedBox(height: 5),
        _buildAlignedKeyValue('3. Nature of land use', data.natureOfLandUse),
        _buildAlignedKeyValue('    a. Existing', data.existingLandUse),
        _buildAlignedKeyValue('    b. Proposed', data.proposedLandUse),
        pw.SizedBox(height: 5),
        _buildKeyBoolValue(
            '4. Whether N.A. Permission Required (If required, whether obtained)',
            data.naPermissionRequired),
      ]);

  pw.Widget _buildSectionCPage1() =>
      pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
        _sectionTitle('C. BUILDINGS'),
        pw.Text('1. Building Plan Approval',
            style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
        _buildKeyValue(
            'i) Layout planning approval No./ Planning permit No./ Building permission No.',
            data.approvalNo),
        _buildKeyValue('ii) Period of validity', data.validityPeriod),
        _buildKeyBoolValue('iii) If validity is expired, whether it is renewed',
            data.isValidityExpiredRenewed),
        _buildKeyValue(
            'iv) Approval was given by (authority)', data.approvalAuthority),
        pw.SizedBox(height: 5),
        pw.Text('2. Plinth/Built Up Area:',
            style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
        pw.Row(children: [
          pw.Expanded(
              child: _buildKeyValue('i) As per approved drawing',
                  'G.F.: ${data.approvedGf}  F.F.: ${data.approvedFf}  S.F.: ${data.approvedSf}')),
          pw.Text(
              'Total: ${(double.tryParse(data.approvedGf) ?? 0) + (double.tryParse(data.approvedFf) ?? 0) + (double.tryParse(data.approvedSf) ?? 0)}',
              style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
        ]),
        pw.Row(children: [
          pw.Expanded(
              child: _buildKeyValue('ii) Actual',
                  'G.F.: ${data.actualGf}  F.F.: ${data.actualFf}  S.F.: ${data.actualSf}')),
          pw.Text(
              'Total: ${(double.tryParse(data.actualGf) ?? 0) + (double.tryParse(data.actualFf) ?? 0) + (double.tryParse(data.actualSf) ?? 0)}',
              style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
        ]),
        pw.SizedBox(height: 5),
        pw.Text('3. Estimate',
            style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
        _buildKeyValue(
            'i) Cost as per Estimate provided by the Applicant (Rs.)',
            data.estimateCost),
        _buildKeyValue(
            'ii) Cost per Sq ft as per Applicant\'s estimate (Rs. Per sq. ft.)',
            data.costPerSqFt),
        _buildKeyBoolValue('iii) Is estimate reasonable, if not give remarks',
            data.isEstimateReasonable),
        pw.SizedBox(height: 5),
        _buildKeyValue('4. Marketability of the Property', data.marketability),
      ]);

  pw.Widget _buildSectionD() =>
      pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
        _sectionTitle('D. INSPECTION'),
        pw.SizedBox(height: 10),
        pw.Text('1.Construction Details',
            style: const pw.TextStyle(fontSize: 10)),
        pw.TableHelper.fromTextArray(
            border: pw.TableBorder.all(width: 0.5),
            cellStyle: const pw.TextStyle(fontSize: 9),
            headerStyle:
                pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9),
            headers: [
              'Directions',
              'As per approved plan',
              'As per actual'
            ],
            data: [
              [
                'i) Plinth/ Built Up Area',
                data.plinthApproved,
                data.plinthActual
              ],
              ['ii) F.S.I', data.fsi, data.fsi],
              [
                'iii) No. Of dwelling units',
                data.dwellingUnits,
                data.dwellingUnits
              ]
            ],
            columnWidths: {
              0: const pw.FlexColumnWidth(2),
              1: const pw.FlexColumnWidth(2),
              2: const pw.FlexColumnWidth(1.5),
              3: const pw.FlexColumnWidth(1.5)
            }),
        _buildKeyValue(
            '2. Whether the construction is as per approved plan(Yes/No)',
            data.isConstructionAsPerPlan ? 'YES' : 'NO'),
        pw.Text('3.Deviations (Please mention in detail)',
            style: const pw.TextStyle(fontSize: 10)),
        pw.TableHelper.fromTextArray(
            border: pw.TableBorder.all(width: 0.5),
            cellStyle: const pw.TextStyle(fontSize: 9),
            headers: [],
            data: [
              [
                'i)',
                'What are the deviations between approved drawing & actual?',
                data.deviations,
              ],
              [
                'ii)',
                'Whether deviation are minor/ major nature',
                data.deviationNature,
              ],
              [
                'iii)',
                'Whether revised approval is necessary',
                data.revisedApprovalNecessary ? 'Yes' : 'No',
              ]
            ],
            columnWidths: {
              0: const pw.FlexColumnWidth(1),
              1: const pw.FlexColumnWidth(2),
              2: const pw.FlexColumnWidth(1.5),
            }),
        _buildWorksCompletedRow(),
        _buildKeyValue(
            '5. i) Whether the Construction carried out / being carried out adheres to the Safety Specifications prescribed in the National Building Code of India 2005?ii) Guidelines issued by the National Disaster Management  Authority (NDMA)?',
            data.adheresToSafety ? 'YES' : 'NO'),
        _buildKeyValue(
            '6. Whether any High Tension Wire Lines are passing through the property and if there is any adverse impact due to this? ',
            data.highTensionImpact ? 'YES' : 'NO'),
      ]);

  // A special widget just for the "Total works" row
  pw.Widget _buildWorksCompletedRow() {
    const keyStyle = pw.TextStyle(fontSize: 9);
    final valueStyle =
        pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold);

    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Part 1: The key on the left
        pw.Expanded(
          flex: 2,
          child: pw.Text(
            "4. Total works completed as per applicant's estimate",
            style: keyStyle,
          ),
        ),
        pw.Text(': ', style: keyStyle),

        // Part 2: The container for the values on the right
        pw.Expanded(
          flex: 3,
          child: pw.Row(
            // This nested Row is the key to the solution
            children: [
              pw.SizedBox(width: 10),
              // The "Percentage" block
              pw.Expanded(
                child: pw.Text(
                  'Percentage\n${data.worksCompletedPercentage}',
                  style: valueStyle,
                ),
              ),
              // The "Value" block
              pw.Expanded(
                child: pw.Text(
                  'Value\n${data.worksCompletedValue}',
                  style: valueStyle,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  pw.Widget _buildTotalValueTable() => pw.TableHelper.fromTextArray(
          border: pw.TableBorder.all(width: 0.5),
          cellStyle: const pw.TextStyle(fontSize: 9),
          headerStyle:
              pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9),
          headers: [
            '',
            'as per Application',
            'Guideline Value',
            'Market Value'
          ],
          data: [
            [
              '1. Value of land',
              currencyFormat.format(double.tryParse(data.landValueApp) ?? 0),
              currencyFormat.format(double.tryParse(data.landValueGuide) ?? 0),
              currencyFormat.format(double.tryParse(data.landValueMarket) ?? 0)
            ],
            [
              '2. Stage value of the building as per applicant\'s estimate',
              currencyFormat
                  .format(double.tryParse(data.buildingStageValueApp) ?? 0),
              currencyFormat
                  .format(double.tryParse(data.buildingStageValueGuide) ?? 0),
              currencyFormat
                  .format(double.tryParse(data.buildingStageValueMarket) ?? 0)
            ],
            [
              '3. Total value of existing building (1 + 2)',
              currencyFormat.format((double.tryParse(data.landValueApp) ?? 0) +
                  (double.tryParse(data.buildingStageValueApp) ?? 0)),
              currencyFormat.format(double.tryParse(data.landValueGuide) ??
                  0 + (double.tryParse(data.buildingStageValueGuide) ?? 0)),
              currencyFormat.format(double.tryParse(data.landValueMarket) ??
                  0 + (double.tryParse(data.buildingStageValueMarket) ?? 0))
            ],
            [
              '4. Value of building on completion',
              currencyFormat.format(
                  double.tryParse(data.buildingCompletionValueApp) ?? 0),
              currencyFormat.format(
                  (double.tryParse(data.buildingCompletionValueGuide) ?? 0) /
                      1.8),
              currencyFormat.format(
                  double.tryParse(data.buildingCompletionValueMarket) ?? 0)
            ],
          ],
          cellAlignments: {
            1: pw.Alignment.centerRight,
            2: pw.Alignment.centerRight,
            3: pw.Alignment.centerRight
          });

  // A new, improved function for perfect alignment with long, wrapping text.
  pw.Widget _buildAlignedKeyValue(String key, String value,
      {double keyWidth = 203.5}) {
    return pw.Row(
      crossAxisAlignment:
          pw.CrossAxisAlignment.start, // Important for top-alignment
      children: [
        // The "Key" part with a fixed width
        pw.SizedBox(
          width:
              keyWidth, // Adjust this width as needed to fit your longest key
          child: pw.Text(key, style: const pw.TextStyle(fontSize: 9)),
        ),
        // The colon separator
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(horizontal: 9),
          child: pw.Text(':', style: const pw.TextStyle(fontSize: 9)),
        ),
        // The "Value" part, which expands and wraps
        pw.Expanded(
          child: pw.Text(
            value,
            style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
          ),
        ),
      ],
    );
  }

  pw.Widget _buildRecommendationTable() {
    // Define your data in a more structured way
    final tableData = <List<String>>[
      [
        '1. *Background information of the asset being valued:',
        data.recBackground
      ],
      [
        '2. Sources of information used for valuation of property:',
        data.recSources
      ],
      [
        '3. *Procedures adopted in carrying out the valuation:',
        data.recProcedures
      ],
      ['4. *Valuation methodology:', data.recMethodology],
      ['5. *Major factors that influenced the valuation:', data.recFactors],
    ];

    return pw.Table(
      border: pw.TableBorder.all(width: 0.5),
      columnWidths: const {
        0: pw.FlexColumnWidth(2),
        1: pw.FlexColumnWidth(3),
      },
      // This ensures all cells have the same vertical alignment
      defaultVerticalAlignment: pw.TableCellVerticalAlignment.middle,
      children: tableData.map((row) {
        return pw.TableRow(
          children: [
            // Cell for the question
            pw.Padding(
              padding: const pw.EdgeInsets.all(4), // Add some padding
              child: pw.Text(row[0], style: const pw.TextStyle(fontSize: 9)),
            ),
            // Cell for the answer (THE ONE WE ARE DEBUGGING)
            pw.Container(
              padding: const pw.EdgeInsets.all(4),
              child: pw.Text(
                row[1].trim(), // Use trim here just in case
                style: const pw.TextStyle(fontSize: 9),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  pw.Widget _buildStageOfConstructionTable() => pw.TableHelper.fromTextArray(
          border: pw.TableBorder.all(width: 0.5),
          cellStyle: const pw.TextStyle(fontSize: 9),
          headerStyle:
              pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9),
          headers: [
            'Sr.No',
            'Stage of Construction',
            '% Progress'
          ],
          data: [
            ['1', data.stageOfConstruction, data.progressPercentage]
          ]);

  pw.Widget _buildCertificate() => pw.Column(children: [
        pw.Text(
            'I declare that I am not associated with the builder or with any of his associate companies or with the borrower directly or indirectly in the past or in the present and this report has been prepared by me with highest professional integrity.',
            style: const pw.TextStyle(fontSize: 9)),
        pw.SizedBox(height: 5),
        pw.Text(
            'I further declare that I have personally inspected the site and building on ${dateFormat.format(data.inspectionDate)}. I further declare that all the above particulars and information given in this report are true to the best of my knowledge and belief.',
            style: const pw.TextStyle(fontSize: 9)),
      ]);

  pw.Widget _buildSignature() => pw.Padding(
      padding: const pw.EdgeInsets.only(top: 20),
      child: pw
          .Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
        pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          pw.Text('Date : ${dateFormat.format(data.certificateDate)}',
              style: const pw.TextStyle(fontSize: 9)),
          pw.Text('Time :', style: const pw.TextStyle(fontSize: 9)),
          pw.Text('Station: ${data.certificatePlace}',
              style: const pw.TextStyle(fontSize: 9)),
        ]),
        pw.Text('SIGNATURE OF THE VALUER',
            style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
      ]));

  pw.Widget _seal() => pw.Align(
      alignment: pw.Alignment.bottomRight,
      child: pw.Container(
          decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.black, width: 0.5)),
          padding: const pw.EdgeInsets.all(8.0),
          child: pw.Text(
              'Seal Containing Name, Code Number etc. allotted by LICHFL',
              style: const pw.TextStyle(fontSize: 7),
              textAlign: pw.TextAlign.end)));

  pw.Widget _buildAnnexureTable() {
    final landMarketVal = (double.tryParse(data.annexLandArea) ?? 0) *
        (double.tryParse(data.annexLandUnitRateMarket) ?? 0);
    final landGuideVal = (double.tryParse(data.annexLandArea) ?? 0) *
        (double.tryParse(data.annexLandUnitRateGuide) ?? 0);
    final gfMarketVal = (double.tryParse(data.annexGfArea) ?? 0) *
        (double.tryParse(data.annexGfUnitRateMarket) ?? 0);
    final gfGuideVal = (double.tryParse(data.annexGfArea) ?? 0) *
        (double.tryParse(data.annexGfUnitRateGuide) ?? 0);
    final totalMarketVal = landMarketVal + gfMarketVal;
    final totalGuideVal = landGuideVal + gfGuideVal;

    return pw.TableHelper.fromTextArray(
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
          data.annexLandArea,
          'RS. ${data.annexLandUnitRateMarket}',
          'RS. ${currencyFormat.format(landMarketVal)}',
          'RS. ${data.annexLandUnitRateGuide}',
          'RS. ${currencyFormat.format(landGuideVal)}'
        ],
        ['Building', '', '', '', '', ''],
        [
          'GF',
          data.annexGfArea,
          'RS. ${data.annexGfUnitRateMarket}',
          'RS. ${currencyFormat.format(gfMarketVal)}',
          'RS. ${data.annexGfUnitRateGuide}',
          'RS. ${currencyFormat.format(gfGuideVal)}'
        ],
        ['FF', data.annexFfArea, 'RS. 0', 'RS. 0', 'RS. 0', 'RS. 0'],
        ['SF', data.annexSfArea, 'RS. 0', 'RS. 0', 'RS. 0', 'RS. 0'],
        ['Amenities if any', '0', 'RS. 0', 'RS. 0', 'RS. 0', 'RS. 0'],
        [
          'Total Value',
          '',
          'RS. ${data.annexLandUnitRateMarket}',
          'RS. ${currencyFormat.format(totalMarketVal)}',
          'RS. ${data.annexLandUnitRateGuide}',
          'RS. ${currencyFormat.format(totalGuideVal)}'
        ],
      ],
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.centerRight,
        2: pw.Alignment.centerRight,
        3: pw.Alignment.centerRight,
        4: pw.Alignment.centerRight,
        5: pw.Alignment.centerRight,
      },
    );
  }
}
