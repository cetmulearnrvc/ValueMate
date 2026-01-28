import 'dart:ui'; // Required for the painter
import 'package:flutter/material.dart';
import 'package:login_screen/screens/Canara/main.dart';
import 'package:login_screen/screens/Federal/federal.dart';
import 'package:login_screen/screens/IDBI/valuation_form_ui.dart';
import 'package:login_screen/screens/LIC/pvr1/valuation_form_screen_pvr1.dart';
import 'package:login_screen/screens/LIC/pvr3/valuation_form_screen.dart';
import 'package:login_screen/screens/SBI/Flat/valuation_form.dart';
import 'package:login_screen/screens/SBI/land_and_building/land_and_building.dart';
import 'package:login_screen/screens/SBI/vacant_land/vacant_land.dart';
import 'package:login_screen/screens/SIB/Flat/valuation_form.dart';
import 'package:login_screen/screens/SIB/land_and_building/land_and_building.dart';
import 'package:login_screen/screens/SIB/vacant_land/vacant_land.dart';

class LoanType extends StatelessWidget {
  final Map<String, dynamic> selectedBank;

  const LoanType({super.key, required this.selectedBank});

  // --- Define professional colors (copied from HomeScreen) ---
  static const Color _primaryColor =
      Color(0xFF0D47A1); // A deep, professional blue
  static final Color _secondaryTextColor = Colors.grey[800]!;
  static const Color _scaffoldBgTop = Color(0xFFF4F7F6);
  static const Color _scaffoldBgBottom = Color(0xFFDDE8F0); // Slightly bluer
  static const Color _cardBgColor = Colors.white;
  // ---

  @override
  Widget build(BuildContext context) {
    final Widget bankName;
    if (selectedBank['name'] == 'Canara Bank') {
      bankName = Canara(context);
    } else if (selectedBank['name'] == 'IDBI Bank') {
      bankName = IDBI(context);
    } else if (selectedBank['name'] == 'LIC') {
      bankName = LIC(context);
    } else if (selectedBank['name'] == 'South Indian Bank') {
      bankName = SIB(context);
    } else if (selectedBank['name'] == 'State Bank of India') {
      bankName = SBI(context);
    } else {
      bankName = Federal(context);
    }

    return Scaffold(
      // Use the same AppBar style as HomeScreen
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.85),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // Back button
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.arrow_back_ios, color: _primaryColor),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'LOAN TYPE',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: _primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      extendBodyBehindAppBar: true,
      // Use the same Stack/Background as HomeScreen
      body: Stack(
        children: [
          // Layer 1: The background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  _scaffoldBgTop,
                  _scaffoldBgBottom,
                ],
              ),
            ),
          ),

          // Layer 2: The tile pattern painter
          CustomPaint(
            size: Size.infinite,
            painter: _TilePatternPainter(
              lineColor: _primaryColor.withOpacity(0.08),
              strokeWidth: 2.0,
            ),
          ),

          // Layer 3: Your content
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // This SizedBox is REQUIRED to push content below the floating AppBar
                  const SizedBox(height: 110.0),

                  // Wrap the content in a padded card
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: _cardBgColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.12),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Column(
                          children: [
                            // Top border design
                            Container(
                              height: 8,
                              width: double.infinity,
                              color: _primaryColor.withOpacity(0.8),
                            ),
                            // Add padding around the bank widget
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: bankName, // Your unchanged logic goes here
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ========== BANK WIDGETS (Theme applied) ==========

  // Helper function for styled dropdown
  InputDecoration _getDropdownDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: _scaffoldBgTop.withOpacity(0.7),
      hintText: 'Select the valuation type',
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _primaryColor, width: 2),
      ),
    );
  }

  // Helper for styled bank title
  Widget _buildBankTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 24, // Slightly smaller to fit in card
        color: _primaryColor,
      ),
    );
  }

  Widget LIC(BuildContext ctx) {
    final List<String> loanTypes = [
      '---SELECT---',
      'HOUSE CONSTRUCTION (PVR - 1)',
      'HOUSE RENOVATION (PVR - 3)',
    ];
    String? selectedValue = loanTypes[0];

    return Column(
      children: [
        const SizedBox(height: 10), // Reduced spacing
        _buildBankTitle('LIC'), // Styled title
        const SizedBox(height: 10),
        Image.asset('assets/images/lic.jpeg', height: 100), // Fixed height
        const SizedBox(height: 30), // Reduced spacing
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: StatefulBuilder(
            builder: (context, setState) {
              return DropdownButtonFormField<String>(
                value: selectedValue,
                decoration: _getDropdownDecoration(), // Styled dropdown
                isExpanded: true,
                items: loanTypes.map((e) {
                  return DropdownMenuItem<String>(value: e, child: Text(e));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedValue = value;
                  });
                  if (value == 'HOUSE RENOVATION (PVR - 3)') {
                    Navigator.of(ctx).push(MaterialPageRoute(
                        builder: (_) => const ValuationFormScreen()));
                  } else if (value == 'HOUSE CONSTRUCTION (PVR - 1)') {
                    Navigator.of(ctx).push(MaterialPageRoute(
                        builder: (_) => const ValuationFormScreenPVR1()));
                  }
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget IDBI(BuildContext ctx) {
    final List<String> loanTypes = [
      '---SELECT---',
      'VALUATION REPORT',
    ];
    String? selectedValue = loanTypes[0];

    return Column(
      children: [
        const SizedBox(height: 10),
        _buildBankTitle('IDBI Bank'), // Styled title
        const SizedBox(height: 10),
        Image.asset('assets/images/idbi.jpeg', height: 100),
        const SizedBox(height: 30),
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: StatefulBuilder(
            builder: (context, setState) {
              return DropdownButtonFormField<String>(
                value: selectedValue,
                decoration: _getDropdownDecoration(), // Styled dropdown
                isExpanded: true,
                items: loanTypes.map((e) {
                  return DropdownMenuItem<String>(value: e, child: Text(e));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedValue = value;
                  });
                  if (value == 'VALUATION REPORT') {
                    Navigator.of(ctx).push(MaterialPageRoute(
                        builder: (_) => const ValuationFormScreenIDBI()));
                  }
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget Federal(BuildContext ctx) {
    final List<String> loanTypes = [
      '---SELECT---',
      'LAND AND BUILDING',
    ];
    String? selectedValue = loanTypes[0];

    return Column(
      children: [
        const SizedBox(height: 10),
        _buildBankTitle('FEDERAL BANK'), // Styled title
        const SizedBox(height: 10),
        Image.asset('assets/images/federal.jpeg', height: 100),
        const SizedBox(height: 30),
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: StatefulBuilder(
            builder: (context, setState) {
              return DropdownButtonFormField<String>(
                value: selectedValue,
                decoration: _getDropdownDecoration(), // Styled dropdown
                isExpanded: true,
                items: loanTypes.map((e) {
                  return DropdownMenuItem<String>(value: e, child: Text(e));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedValue = value;
                  });
                  if (value == 'LAND AND BUILDING') {
                    Navigator.of(ctx).push(MaterialPageRoute(
                        builder: (_) => const PdfGeneratorScreen()));
                  }
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget Canara(BuildContext ctx) {
    final List<String> loanTypes = ['---SELECT---', 'CANARA FORM'];
    String? selectedValue = loanTypes[0];

    return Column(
      children: [
        const SizedBox(height: 10),
        _buildBankTitle('CANARA BANK'), // Styled title
        const SizedBox(height: 15),
        Image.asset('assets/images/canara.jpeg', height: 100),
        const SizedBox(height: 30),
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: StatefulBuilder(
            builder: (context, setState) {
              return DropdownButtonFormField<String>(
                value: selectedValue,
                decoration: _getDropdownDecoration(), // Styled dropdown
                isExpanded: true,
                items: loanTypes.map((e) {
                  return DropdownMenuItem<String>(value: e, child: Text(e));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedValue = value;
                  });
                  // Added check for placeholder
                  if (value != null && value != '---SELECT---') {
                    Navigator.of(ctx).push(MaterialPageRoute(
                        builder: (_) => const PropertyValuationReportPage()));
                  }
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget SIB(BuildContext ctx) {
    final List<String> loanTypes = [
      '---SELECT---',
      'VALUATION REPORT (IN RESPECT OF LAND / SITE AND BUILDING)',
      'VALUATION REPORT (IN RESPECT OF FLATS)',
      'VALUATION REPORT (IN RESPECT OF VACANT LAND / SITE)',
    ];
    String? selectedValue = loanTypes[0];

    return Column(
      children: [
        const SizedBox(height: 10),
        _buildBankTitle('SOUTH INDIAN BANK'), // Styled title
        const SizedBox(height: 10),
        Image.asset('assets/images/south indian.jpeg', height: 100),
        const SizedBox(height: 30),
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: StatefulBuilder(
            builder: (context, setState) {
              return DropdownButtonFormField<String>(
                value: selectedValue,
                decoration: _getDropdownDecoration(), // Styled dropdown
                isExpanded: true,
                items: loanTypes.map((e) {
                  return DropdownMenuItem<String>(value: e, child: Text(e));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedValue = value;
                  });
                  if (value == 'VALUATION REPORT (IN RESPECT OF FLATS)') {
                    Navigator.of(ctx).push(MaterialPageRoute(
                        builder: (_) => const SIBValuationFormScreen()));
                  } else if (value ==
                      'VALUATION REPORT (IN RESPECT OF LAND / SITE AND BUILDING)') {
                    Navigator.of(ctx).push(MaterialPageRoute(
                        builder: (_) => const ValuationFormPage()));
                  } else if (value ==
                      'VALUATION REPORT (IN RESPECT OF VACANT LAND / SITE)') {
                    Navigator.of(ctx).push(MaterialPageRoute(
                        builder: (_) => const VacantLandFormPage()));
                  }
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget SBI(BuildContext ctx) {
    final List<String> loanTypes = [
      '---SELECT---',
      'VALUATION REPORT (IN RESPECT OF LAND / SITE AND BUILDING)',
      // 'VALUATION REPORT (IN RESPECT OF FLATS)',
      // 'VALUATION REPORT (IN RESPECT OF VACANT LAND / SITE)',
    ];
    String? selectedValue = loanTypes[0];

    return Column(
      children: [
        const SizedBox(height: 10),
        _buildBankTitle('STATE BANK OF INDIA'), // Styled title
        const SizedBox(height: 10),
        Image.asset('assets/images/sbi.png', height: 100),
        const SizedBox(height: 30),
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: StatefulBuilder(
            builder: (context, setState) {
              return DropdownButtonFormField<String>(
                value: selectedValue,
                decoration: _getDropdownDecoration(), // Styled dropdown
                isExpanded: true,
                items: loanTypes.map((e) {
                  return DropdownMenuItem<String>(value: e, child: Text(e));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedValue = value;
                  });
                  // if (value == 'VALUATION REPORT (IN RESPECT OF FLATS)') {
                  //   Navigator.of(ctx).push(MaterialPageRoute(
                  //       builder: (_) => const SBIValuationFormScreen()));
                  // }
                  if (value ==
                      'VALUATION REPORT (IN RESPECT OF LAND / SITE AND BUILDING)') {
                    Navigator.of(ctx).push(MaterialPageRoute(
                        builder: (_) => const SBIValuationFormPage()));
                  }
                  //else if (value ==
                  //     'VALUATION REPORT (IN RESPECT OF VACANT LAND / SITE)') {
                  //   Navigator.of(ctx).push(MaterialPageRoute(
                  //       builder: (_) => const SBIVacantLandFormPage()));
                  // }
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

// *** Custom Painter for the background lines (Copied from HomeScreen) ***
class _TilePatternPainter extends CustomPainter {
  final Color lineColor;
  final double strokeWidth;

  _TilePatternPainter({required this.lineColor, required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    const double spacing = 40.0; // The distance between lines

    // Draw diagonal lines (/)
    for (double i = -size.height; i < size.width; i += spacing) {
      canvas.drawLine(
        Offset(i, 0), // Start from top edge
        Offset(i + size.height, size.height), // End on bottom edge
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _TilePatternPainter oldDelegate) {
    return oldDelegate.lineColor != lineColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
