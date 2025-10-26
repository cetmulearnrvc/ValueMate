import 'dart:ui'; // Make sure this import is here
import 'package:flutter/material.dart';
import 'package:login_screen/screens/loanType.dart';
import 'package:login_screen/screens/splash.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final List<Map<String, dynamic>> banks = [
    {
      'name': 'Canara Bank',
      'icon': 'assets/images/canara.jpeg',
    },
    {
      'name': 'IDBI Bank',
      'icon': 'assets/images/idbi.jpeg',
    },
    {
      'name': 'LIC',
      'icon': 'assets/images/lic.jpeg',
    },
    {
      'name': 'Federal Bank',
      'icon': 'assets/images/federal.jpeg',
    },
    {
      'name': 'South Indian Bank',
      'icon': 'assets/images/south indian.jpeg',
    },
    {
      'name': 'State Bank of India',
      'icon': 'assets/images/sbi.png',
    },
  ];

  late AnimationController _controller;

  // Define professional colors
  final Color _primaryColor =
      const Color(0xFF0D47A1); // A deep, professional blue
  final Color _secondaryTextColor = Colors.grey[800]!;

  // Adjusted background gradient for more contrast
  final Color _scaffoldBgTop = const Color(0xFFF4F7F6);
  final Color _scaffoldBgBottom = const Color(0xFFDDE8F0); // Slightly bluer

  final Color _cardBgColor = Colors.white;

  @override
  void initState() {
    super.initState();
    // MODIFICATION: Set up controller for a fade-in animation
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600), // Fade-in duration
    );
    _controller.forward(); // Start the animation on load
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                // Frosted glass effect
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _primaryColor.withOpacity(0.1),
                        ),
                        // Professional icon
                        child: Icon(Icons.apps, color: _primaryColor, size: 32),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        // Professional title
                        'Dashboard',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: _primaryColor,
                        ),
                      ),
                    ],
                  ),
                  // IconButton(
                  //   onPressed: () {
                  //     signout(context);
                  //   },
                  //   icon: const Icon(Icons.exit_to_app, color: Colors.black54),
                  // ),
                ],
              ),
            ),
          ),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Layer 1: The background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  _scaffoldBgTop,
                  _scaffoldBgBottom, // Using the new, bluer bottom color
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

          // Layer 3: Your original content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // This SizedBox is REQUIRED to push content below the floating AppBar
                    const SizedBox(height: 20.0),

                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: // Wrap the Text widget with a ShaderMask
                          ShaderMask(
                        blendMode: BlendMode.srcIn,
                        shaderCallback: (bounds) => LinearGradient(
                          colors: [
                            _primaryColor, // Your deep blue
                            _primaryColor.withOpacity(0.7), // A lighter shade
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ).createShader(
                            Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
                        child: Text(
                          // Stylish gradient title
                          'SELECT YOUR BANK',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight
                                .w700, // Slightly bolder for the gradient
                            fontFamily: 'Poppins',
                            color: Colors.white, // Color is set by the shader
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),

                    // Removed the duplicate SizedBox here
                    const SizedBox(height: 20),

                    // Added the FadeTransition back for a professional feel
                    FadeTransition(
                      opacity: _controller,
                      child: GridView.builder(
                        itemCount: banks.length,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          // MODIFICATION 1: Makes cards square and smaller
                          childAspectRatio: 1.0,
                        ),
                        itemBuilder: (context, index) {
                          final bank = banks[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => LoanType(selectedBank: bank),
                                ),
                              );
                            },
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.start, // Align to top
                                  children: [
                                    Container(
                                      // MODIFICATION 2: Thinner border
                                      height: 8,
                                      width: double.infinity,
                                      color: _primaryColor.withOpacity(0.8),
                                    ),

                                    const Spacer(), // Top spacer

                                    Image.asset(
                                      bank['icon'],
                                      height: 50,
                                      width: 60,
                                      fit: BoxFit.contain,
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      bank['name'],
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),

                                    const Spacer(), // Bottom spacer

                                    Icon(
                                      Icons.arrow_forward_ios,
                                      size: 18.0,
                                      color: _primaryColor.withOpacity(0.4),
                                    ),
                                    const SizedBox(height: 16),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // void signout(BuildContext ctx) async {
  //   final sharedPrefs = await SharedPreferences.getInstance();
  //   await sharedPrefs.clear();

  //   Navigator.of(ctx).pushAndRemoveUntil(
  //     MaterialPageRoute(builder: (ctx1) => const SplashScreen()),
  //     (route) => false,
  //   );
  // }
}

// *** Custom Painter for the background lines (Unchanged) ***
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
