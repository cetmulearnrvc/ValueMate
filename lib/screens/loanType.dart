import 'package:flutter/material.dart';
import 'package:login_screen/screens/Canara/main.dart';
import 'package:login_screen/screens/Federal/federal.dart';
import 'package:login_screen/screens/IDBI/valuation_form_ui.dart';
import 'package:login_screen/screens/LIC/pvr1/valuation_form_screen_pvr1.dart';
import 'package:login_screen/screens/LIC/pvr3/valuation_form_screen.dart';
import 'package:login_screen/screens/SIB/Flat/valuation_form.dart';
import 'package:login_screen/screens/location.dart';
import 'package:login_screen/screens/SIB/land_and_building/land_and_building.dart';
import 'package:login_screen/screens/SIB/vacant_land/vacant_land.dart';

class LoanType extends StatelessWidget {
  final Map<String, dynamic> selectedBank;

  const LoanType({super.key, required this.selectedBank});

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

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFB0D9F8),
            Color(0xFF90C1F7),
            Color(0xFFA1A4F8),
            Color(0xFFC49CF7),
            Color(0xFFE4A2F5),
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
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
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back, color: Colors.black),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'LOAN TYPE',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        body: SafeArea(
          child: Center(child: bankName),
        ),
      ),
    );
  }

  // ========== BANK WIDGETS ==========

  Widget LIC(BuildContext ctx) {
    final List<String> loanTypes = [
      '---SELECT---',
      'HOUSE CONSTRUCTION (PVR - 1)',
      'HOUSE RENOVATION (PVR - 3)',
    ];

    String? selectedValue = loanTypes[0];

    return Column(
      children: [
        const SizedBox(
          height: 20,
        ),
        const Text('LIC',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 28,
            )),
        const SizedBox(height: 10),
        Image.asset('assets/images/lic.jpeg'),
        const SizedBox(height: 50),
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: StatefulBuilder(
            builder: (context, setState) {
              return DropdownButtonFormField<String>(
                value: selectedValue,
                decoration: const InputDecoration(border: OutlineInputBorder()),
                hint: const Text('Select the valuation type'),
                isExpanded: true,
                items: loanTypes.map((e) {
                  return DropdownMenuItem<String>(
                    value: e,
                    child: Text(e),
                  );
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
        const SizedBox(
          height: 20,
        ),
        const Text('IDBI Bank',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 28,
            )),
        const SizedBox(height: 10),
        Image.asset('assets/images/idbi.jpeg'),
        const SizedBox(height: 50),
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: StatefulBuilder(
            builder: (context, setState) {
              return DropdownButtonFormField<String>(
                value: selectedValue,
                decoration: const InputDecoration(border: OutlineInputBorder()),
                hint: const Text('Select the valuation type'),
                isExpanded: true,
                items: loanTypes.map((e) {
                  return DropdownMenuItem<String>(
                    value: e,
                    child: Text(e),
                  );
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
        const SizedBox(
          height: 20,
        ),
        const Text('FEDERAL BANK',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 28,
            )),
        const SizedBox(height: 10),
        Image.asset('assets/images/federal.jpeg'),
        const SizedBox(height: 50),
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: StatefulBuilder(
            builder: (context, setState) {
              return DropdownButtonFormField<String>(
                value: selectedValue,
                decoration: const InputDecoration(border: OutlineInputBorder()),
                hint: const Text('Select the valuation type'),
                isExpanded: true,
                items: loanTypes.map((e) {
                  return DropdownMenuItem<String>(
                    value: e,
                    child: Text(e),
                  );
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
    final List<String> loanTypes = [
      '---SELECT---',
      /* 'Plant And Machinery',
      'Property (Land & BUILDING)',
      'VALUATION OF COMMERCIAL BUILDING BY RENT CAPITALISATION METHOD',
      'VALUATION OF FLAT BY COMPOSITE RATE METHOD',
      'GENERAL FORMAT VALUATION REPORT OTHER PROPERTIES',
      'VALUATION OF VACANT SITES/ RESIDENTIAL PLOT / COMMERCIAL SITE / LAND',
      'VALUATION REPORT (IN RESPECT OF AGRICULTURAL LANDS)', */
      'CANARA FORM'
    ];

    String? selectedValue = loanTypes[0];

    return Column(
      children: [
        const SizedBox(
          height: 20,
        ),
        const Text('CANARA BANK',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 28,
            )),
        const SizedBox(height: 15),
        Image.asset('assets/images/canara.jpeg'),
        const SizedBox(height: 50),
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: StatefulBuilder(
            builder: (context, setState) {
              return DropdownButtonFormField<String>(
                value: selectedValue,
                decoration: const InputDecoration(border: OutlineInputBorder()),
                hint: const Text('Select the valuation type'),
                isExpanded: true,
                items: loanTypes.map((e) {
                  return DropdownMenuItem<String>(
                    value: e,
                    child: Text(e),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedValue = value;
                  });
                  Navigator.of(ctx).push(MaterialPageRoute(
                      builder: (_) => const PropertyValuationReportPage()));
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
        const SizedBox(
          height: 20,
        ),
        const Text('SOUTH INDIAN BANK',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 28,
            )),
        const SizedBox(height: 10),
        Image.asset('assets/images/south indian.jpeg'),
        const SizedBox(height: 50),
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: StatefulBuilder(
            builder: (context, setState) {
              return DropdownButtonFormField<String>(
                value: selectedValue,
                decoration: const InputDecoration(border: OutlineInputBorder()),
                hint: const Text('Select the valuation type'),
                isExpanded: true,
                items: loanTypes.map((e) {
                  return DropdownMenuItem<String>(
                    value: e,
                    child: Text(e),
                  );
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
      'VALUATION REPORT (IN RESPECT OF FLATS)',
      'VALUATION REPORT (IN RESPECT OF VACANT LAND / SITE)',
    ];

    String? selectedValue = loanTypes[0];

    return Column(
      children: [
        const SizedBox(
          height: 20,
        ),
        const Text('STATE BANK OF INDIA',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 28,
            )),
        const SizedBox(height: 10),
        Image.asset('assets/images/sbi.png'),
        const SizedBox(height: 50),
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: StatefulBuilder(
            builder: (context, setState) {
              return DropdownButtonFormField<String>(
                value: selectedValue,
                decoration: const InputDecoration(border: OutlineInputBorder()),
                hint: const Text('Select the valuation type'),
                isExpanded: true,
                items: loanTypes.map((e) {
                  return DropdownMenuItem<String>(
                    value: e,
                    child: Text(e),
                  );
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
}
