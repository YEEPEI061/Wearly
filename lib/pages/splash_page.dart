import 'dart:async';
import 'package:frontend/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend/theme/app_text_styles.dart';
import 'package:frontend/theme/app_radius.dart';
import 'package:frontend/pages/login_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  double progress = 0.0;

  Timer? _timer;

  bool _loadingFinished = false;
  bool _isExiting = false;

  final List<String> statuses = [
    'CURATING PALETTE',
    'GATHERING LOOKBOOK',
    'WEAVING SILHOUETTES',
    'ATELIER READY',
  ];

  // Fashion image from your HTML
  final String fashionImageUrl =
      'https://lh3.googleusercontent.com/aida/AEtjO1UpaGsYo0OkaLi2RTFicgnXPoXUHRV3-5KU0MZZHtWmvdAdgXbjtcWY9fnOKBdqKsvNYLDiG9GEASdwJHM7Xy4cAX-SShcRX1K5_1_hCm3-aTYbs__T9b5ewaC3jxTsd0tmn1hj7VzwMb4q9sBsxLhUzj4XavUpTqRcMW0ekqgkzygRw1ntMLQI32SqJfk5HeVauxob2yx2HZtew6XS6ZJ5OPDpO5LasHtUVmuFG8piHZVK9ig6VoeoDiM';
  @override
  void initState() {
    super.initState();
    _startLoading();
  }

  void _startLoading() {
    _timer = Timer.periodic(const Duration(milliseconds: 180), (timer) {
      if (!mounted) return;

      // Similar to:
      // Math.floor(Math.random() * 15) + 8
      final increment = 8 + (DateTime.now().millisecond % 15);

      setState(() {
        progress += increment;

        if (progress >= 100) {
          progress = 100;
          _loadingFinished = true;
          timer.cancel();
        }
      });
    });
  }

  String get currentStatus {
    if (progress >= 100) {
      return statuses[3];
    }

    final index = ((progress / 100) * (statuses.length - 1)).floor().clamp(
      0,
      statuses.length - 1,
    );

    return statuses[index];
  }

  void _finishLoading() {
    _timer?.cancel();

    setState(() {
      progress = 100;
      _loadingFinished = true;
    });
  }

  void _enterWardrobe() {
    if (!_loadingFinished) {
      _finishLoading();
      return;
    }

    setState(() {
      _isExiting = true;
    });

    // Later we will replace this with navigation to HomePage.
    //
    // For now, it simply performs the splash transition.
    Future.delayed(const Duration(milliseconds: 700), () {
      if (!mounted) return;

      setState(() {
        _isExiting = false;
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const LoginPage(),
        ),
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F5),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          if (!_loadingFinished) {
            _finishLoading();
          }
        },
        child: SafeArea(
          child: AnimatedScale(
            scale: _isExiting ? 1.03 : 1.0,
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOut,
            child: AnimatedOpacity(
              opacity: _isExiting ? 0.0 : 1.0,
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeInOut,
              child: SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: Column(children: [Expanded(child: _buildMainContent())]),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return Container(
      width: double.infinity,
      color: const Color(0xFFFAF9F5),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 64),
      child: Column(
        children: [
          // ----------------------------------------------------------
          // TOP EDITORIAL HEADER
          // ----------------------------------------------------------
          Opacity(
            opacity: 0.8,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    'DIGITAL WARDROBE COMPANION',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.sourceSans3(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 2.5,
                      color: const Color(0xFF102134),
                    ),
                  ),
                ),

                const SizedBox(height: 4),

                Container(width: 32, height: 1, color: const Color(0x4D102134)),

                const SizedBox(height: 4),

                Text(
                  'AI WARDROBE & STYLING',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.sourceSans3(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 1.8,
                    color: const Color(0xFF44474C),
                  ),
                ),
              ],
            ),
          ),

          // ----------------------------------------------------------
          // CENTER CONTENT
          // ----------------------------------------------------------
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 340),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Decorative glow
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 240,
                          height: 240,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                const Color(0x333D5A73),
                                const Color.fromARGB(0, 44, 74, 109),
                              ],
                            ),
                          ),
                        ),

                        Column(
                          children: [
                            // ------------------------------------------------
                            // LOGO
                            // ------------------------------------------------
                            SizedBox(
                              width: 64,
                              height: 64,
                              child: Image.asset(
                                'assets/images/wearly_logo.png',
                                fit: BoxFit.contain,
                              ),
                            ),

                            const SizedBox(height: 4),

                            // ------------------------------------------------
                            // WEARLY
                            // ------------------------------------------------
                            Text(
                              'Wearly',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.playfairDisplay(
                                fontSize: 34,
                                height: 1.08,
                                fontWeight: FontWeight.w400,
                                letterSpacing: -1.0,
                                color: const Color(0xFF26364A),
                              ),
                            ),

                            const SizedBox(height: 16),

                            // ------------------------------------------------
                            // TAGLINE
                            // ------------------------------------------------
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 240),
                              child: Text(
                                'Your intelligent personal wardrobe & everyday styling companion.',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.sourceSans3(
                                  fontSize: 14,
                                  height: 1.55,
                                  fontWeight: FontWeight.w400,
                                  fontStyle: FontStyle.italic,
                                  letterSpacing: 0.5,
                                  color: const Color(0xFF44474C),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // ----------------------------------------------------------
                    // EDITORIAL IMAGE
                    // ----------------------------------------------------------
                    Container(
                      width: double.infinity,
                      height: 200,
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppRadius.medium),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          // ------------------------------------------------
                          // IMAGE
                          // ------------------------------------------------
                          Image.network(
                            fashionImageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: AppColors.surfaceContainerHigh,
                                child: const Center(
                                  child: Icon(
                                    Icons.image_outlined,
                                    size: 40,
                                    color: AppColors.onSurfaceVariant,
                                  ),
                                ),
                              );
                            },
                          ),

                          // ------------------------------------------------
                          // IMAGE GRADIENT
                          // ------------------------------------------------
                          Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                stops: [0.25, 1.0],
                                colors: [Colors.transparent, Color(0xCC102134)],
                              ),
                            ),
                          ),

                          // ------------------------------------------------
                          // IMAGE TEXT
                          // ------------------------------------------------
                          Positioned(
                            left: 16,
                            right: 16,
                            bottom: 16,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '“Curating your personal style through intelligent AI.”',
                                  style: AppTextStyles.headlineSmall.copyWith(
                                    color: Colors.white,
                                  ),
                                ),

                                const SizedBox(height: 8),

                                Container(
                                  width: 16,
                                  height: 1,
                                  color: AppColors.secondary,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ----------------------------------------------------------
          // BOTTOM SECTION
          // ----------------------------------------------------------
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 340),
            child: Column(
              children: [
                // --------------------------------------------------------
                // LOADING
                // --------------------------------------------------------
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  child: !_loadingFinished
                      ? _buildLoader()
                      : _buildEnterButton(),
                ),

                const SizedBox(height: 12),

                Text(
                  'TAP ANYWHERE TO ENTER',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.sourceSans3(
                    fontSize: 12,
                    height: 1.5,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 1.5,
                    color: const Color(0x9944474C),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // LOADING BAR
  // ------------------------------------------------------------

  Widget _buildLoader() {
    return Column(
      key: const ValueKey('loader'),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              currentStatus,
              style: GoogleFonts.sourceSans3(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
                color: const Color(0xB3102134),
              ),
            ),
            Text(
              '${progress.round()}%',
              style: GoogleFonts.sourceSans3(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
                color: const Color(0xB3102134),
              ),
            ),
          ],
        ),

        const SizedBox(height: 4),

        Container(
          width: double.infinity,
          height: 2,
          color: const Color(0xFFE3E2DF),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progress / 100,
            child: Container(color: const Color(0xFF102134)),
          ),
        ),
      ],
    );
  }

  // ------------------------------------------------------------
  // OPEN WARDROBE BUTTON
  // ------------------------------------------------------------

  Widget _buildEnterButton() {
    return SizedBox(
      key: const ValueKey('button'),
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: _enterWardrobe,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF102134),
          foregroundColor: Colors.white,
          elevation: 2,
          shadowColor: Colors.black.withOpacity(0.15),
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'OPEN WARDROBE',
              style: GoogleFonts.sourceSans3(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 2.4,
              ),
            ),

            const SizedBox(width: 8),

            const Icon(Icons.arrow_forward, size: 17),
          ],
        ),
      ),
    );
  }
}
