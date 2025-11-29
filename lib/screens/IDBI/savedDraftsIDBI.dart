import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// --- YOUR IMPORTS ---
import 'package:login_screen/screens/IDBI/valuation_form_ui.dart';
import 'config.dart';

class SavedDraftsIDBI extends StatefulWidget {
  const SavedDraftsIDBI({super.key});

  @override
  State<SavedDraftsIDBI> createState() => _SavedDraftsIDBIState();
}

class _SavedDraftsIDBIState extends State<SavedDraftsIDBI> {
  DateTime date = DateTime.now();
  List<dynamic> searchResults = [];
  bool isLoading = false;

  // --- SEARCH FUNCTION ---
  Future<void> searchByDate() async {
    setState(() {
      isLoading = true;
      searchResults = [];
    });

    try {
      final formattedDate = DateFormat('yyyy-MM-dd').format(date);

      // print("Fetching from: $url3"); // Debug print

      final response = await http.post(
        Uri.parse(url3),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'date': formattedDate}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (mounted) {
          setState(() {
            searchResults = data;
          });
        }
      } else {
        if (mounted) {
          showErrorSnackBar('Server error: ${response.statusCode}');
        }
      }
    } catch (e) {
      if (mounted) {
        showErrorSnackBar('Connection Error: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.redAccent,
        content: Text(message),
      ),
    );
  }

  void navigateToValuationForm(Map<String, dynamic> propertyData) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ValuationFormScreenIDBI(propertyData: propertyData),
      ),
    );
  }

  // A specific Navy Blue for the IDBI theme
  static const Color _brandBlue = Color(0xFF1E3A8A);
  static const Color _slateText = Color(0xFF334155);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
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
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back_ios, color: _brandBlue),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'IDBI DRAFTS',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: _brandBlue,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          // 1. BACKGROUND STRIPES
          Positioned.fill(
            child: Container(
              color: const Color(0xFFEAF2F8),
              child: CustomPaint(
                painter: _StripePainter(),
              ),
            ),
          ),

          // 2. CONTENT
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 20),

                // White Container Box
                Expanded(
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blueGrey.withOpacity(0.15),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // --- 1. DATE PICKER (Updated Colors) ---
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: const Color(
                                0xFFF1F5F9), // Light Slate Background
                            border: Border.all(
                                color: const Color(
                                    0xFFCBD5E1)), // Subtle Grey Border
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today,
                                  color: _brandBlue, size: 20),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Date: ${DateFormat('dd-MM-yyyy').format(date)}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: _slateText,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit_calendar,
                                    color: _brandBlue),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                onPressed: () async {
                                  final picked = await showDatePicker(
                                    context: context,
                                    initialDate: date,
                                    firstDate: DateTime(2000),
                                    lastDate: DateTime(2200),
                                    builder: (context, child) {
                                      // Customizing the Date Picker Popup colors to match
                                      return Theme(
                                        data: Theme.of(context).copyWith(
                                          colorScheme: const ColorScheme.light(
                                            primary: _brandBlue,
                                            onPrimary: Colors.white,
                                            onSurface: _slateText,
                                          ),
                                        ),
                                        child: child!,
                                      );
                                    },
                                  );
                                  if (picked != null) {
                                    setState(() => date = picked);
                                  }
                                },
                              )
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // --- 2. SEARCH BUTTON (Updated Colors) ---
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: isLoading ? null : searchByDate,
                            icon: const Icon(Icons.search, color: Colors.white),
                            label: const Text('Search'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: _brandBlue, // Deep Navy Blue
                              foregroundColor: Colors.white, // White Text
                              elevation: 2,
                              shadowColor: _brandBlue.withOpacity(0.4),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              textStyle: const TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        Divider(color: Colors.blueGrey.withOpacity(0.1)),
                        const SizedBox(height: 10),

                        // --- 3. LIST RESULTS (Updated Colors) ---
                        Expanded(
                          child: isLoading
                              ? const Center(
                                  child: CircularProgressIndicator(
                                      color: _brandBlue))
                              : searchResults.isEmpty
                                  ? Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.plagiarism_outlined,
                                              size: 50,
                                              color: Colors.blueGrey.shade200),
                                          const SizedBox(height: 12),
                                          Text(
                                            'No drafts found',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.blueGrey.shade400,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : ListView.builder(
                                      itemCount: searchResults.length,
                                      padding: EdgeInsets.zero,
                                      itemBuilder: (context, index) {
                                        final property = searchResults[index];

                                        // A consistent, professional Blue-Grey gradient
                                        // instead of random rainbow colors
                                        return Container(
                                          margin: const EdgeInsets.symmetric(
                                              vertical: 8),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(16),
                                            gradient: const LinearGradient(
                                              colors: [
                                                Color(
                                                    0xFFF8FAFC), // Very light grey-blue
                                                Color(0xFFEFF6FF), // Pale Blue
                                              ],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            ),
                                            border: Border.all(
                                              color: const Color(
                                                  0xFFE2E8F0), // Subtle border
                                            ),
                                          ),
                                          child: ListTile(
                                            contentPadding:
                                                const EdgeInsets.all(16),
                                            title: Text(
                                              'Application No: ${property['applicationNo'] ?? 'N/A'}',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                                color: Color(
                                                    0xFF1E293B), // Dark Slate
                                              ),
                                            ),
                                            subtitle: Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 8.0),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  _buildInfoRow(
                                                      Icons.person,
                                                      property[
                                                              'borrowerName'] ??
                                                          'N/A'),
                                                  const SizedBox(height: 4),
                                                  _buildInfoRow(
                                                      Icons.location_on,
                                                      property[
                                                              'postalAddress'] ??
                                                          'N/A'),
                                                  const SizedBox(height: 4),
                                                  _buildInfoRow(
                                                      Icons.event,
                                                      property['createdAt'] !=
                                                              null
                                                          ? DateFormat(
                                                                  'dd-MM-yyyy')
                                                              .format(DateTime.parse(
                                                                      property[
                                                                          'createdAt'])
                                                                  .toLocal())
                                                          : 'N/A'),
                                                ],
                                              ),
                                            ),
                                            trailing: Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  shape: BoxShape.circle,
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black
                                                          .withOpacity(0.05),
                                                      blurRadius: 4,
                                                    )
                                                  ]),
                                              child: const Icon(
                                                  Icons.arrow_forward_ios,
                                                  size: 14,
                                                  color: _brandBlue),
                                            ),
                                            onTap: () =>
                                                navigateToValuationForm(
                                                    property),
                                          ),
                                        );
                                      },
                                    ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper widget for the list items to keep code clean
  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: Colors.blueGrey),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF64748B), // Slate 500
            ),
          ),
        ),
      ],
    );
  }
}

// --- STRIPE PAINTER (Unchanged) ---
class _StripePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD4E0EB)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    const double spacing = 30.0;
    for (double i = -size.height; i < size.width; i += spacing) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + size.height, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
