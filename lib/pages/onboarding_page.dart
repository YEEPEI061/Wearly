import 'package:flutter/material.dart';
import 'package:frontend/theme/app_colors.dart';
import 'package:frontend/theme/app_text_styles.dart';
import 'package:frontend/theme/app_radius.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  // ============================================================
  // SELECTIONS
  // ============================================================

  String? _selectedGender = 'Women / Girl';

  String? _selectedStyle = 'Minimalist Tailoring';

  final Set<String> _selectedColors = {'Navy'};

  // ============================================================
  // DATA
  // ============================================================

  final List<String> _genders = [
    'Women / Girl',
    'Men / Boy',
    'Non-Binary / All',
  ];

  final List<String> _styles = [
    'Minimalist Tailoring',
    'Parisian Chic',
    'Avant-Garde',
    'Effortless Luxury',
    'Casual Summer',
  ];

  final List<Map<String, dynamic>> _colors = [
    {'name': 'Navy', 'color': Color(0xFF26364A)},
    {'name': 'Sage', 'color': Color(0xFF8E9E82)},
    {'name': 'Ecru', 'color': Color(0xFFEFECE6)},
    {'name': 'Terracotta', 'color': Color(0xFFC67D5A)},
    {'name': 'Muted Blue', 'color': Color(0xFFAABFD0)},
    {'name': 'Charcoal', 'color': Color(0xFF30343B)},
  ];

  // ============================================================
  // ACTIONS
  // ============================================================

  void _selectGender(String gender) {
    setState(() {
      _selectedGender = gender;
    });
  }

  void _selectStyle(String style) {
    setState(() {
      _selectedStyle = style;
    });
  }

  void _toggleColor(String color) {
    setState(() {
      if (_selectedColors.contains(color)) {
        _selectedColors.remove(color);
      } else {
        _selectedColors.add(color);
      }
    });
  }

  void _continue() {
    // Backend personalization will be connected later.

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Your style preferences have been saved.')),
    );
  }

  void _skipIntro() {
    // connect to the next page later
  }

  // ============================================================
  // GENDER PILL
  // ============================================================

  Widget _buildGenderPill(String gender) {
    final bool isSelected = _selectedGender == gender;

    return GestureDetector(
      onTap: () => _selectGender(gender),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(AppRadius.small),
        ),
        child: Text(
          gender,
          style: AppTextStyles.labelMedium.copyWith(
            color: isSelected ? AppColors.white : AppColors.primary,
            letterSpacing: 1.0,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // STYLE PILL
  // ============================================================

  Widget _buildStylePill(String style) {
    final bool isSelected = _selectedStyle == style;

    return GestureDetector(
      onTap: () => _selectStyle(style),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(AppRadius.small),
        ),
        child: Text(
          style,
          textAlign: TextAlign.center,
          style: AppTextStyles.labelMedium.copyWith(
            color: isSelected ? AppColors.white : AppColors.primary,
            letterSpacing: 0.8,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // COLOR SWATCH
  // ============================================================

  Widget _buildColorSwatch({required String name, required Color color}) {
    final bool isSelected = _selectedColors.contains(name);

    return GestureDetector(
      onTap: () => _toggleColor(name),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.outlineVariant,
            width: isSelected ? 1.2 : 1,
          ),
          borderRadius: BorderRadius.circular(AppRadius.small),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(
                  color: name == 'Ecru'
                      ? AppColors.outlineVariant
                      : Colors.transparent,
                ),
              ),
            ),

            const SizedBox(width: 8),

            Text(
              name,
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.primary,
              ),
            ),

            if (isSelected) ...[
              const SizedBox(width: 6),
              const Icon(Icons.check, size: 14, color: AppColors.primary),
            ],
          ],
        ),
      ),
    );
  }

  // ============================================================
  // PAGE
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 48),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ==================================================
                // TOP HEADER
                // ==================================================
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/wearly_logo.png',
                      width: 32,
                      height: 32,
                      fit: BoxFit.contain,
                    ),

                    GestureDetector(
                      onTap: _skipIntro,
                      child: Text(
                        'SKIP INTRO',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.secondary,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // ==================================================
                // HERO IMAGE MOSAIC
                // ==================================================
                _buildImageMosaic(),

                const SizedBox(height: 42),

                // ==================================================
                // TYPOGRAPHY
                // ==================================================
                Column(
                  children: [
                    Text(
                      'YOUR PERSONAL STYLIST',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.secondary,
                        letterSpacing: 1.8,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'Curated elegance,\ntailored to your essence.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.headlineMedium.copyWith(height: 1.18),
                    ),

                    const SizedBox(height: 8),

                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 360),
                      child: Text(
                        'Bespoke wardrobe curation and intelligent styling recommendations designed exclusively for you.',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // ==================================================
                // GENDER
                // ==================================================
                Text(
                  'SELECT GENDER / IDENTITY',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.secondary,
                    letterSpacing: 1.5,
                  ),
                ),

                const SizedBox(height: 12),

                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 10,
                  runSpacing: 10,
                  children: _genders.map(_buildGenderPill).toList(),
                ),

                const SizedBox(height: 32),

                // ==================================================
                // STYLE
                // ==================================================
                Text(
                  'SELECT YOUR PRIMARY AESTHETIC',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.secondary,
                    letterSpacing: 1.5,
                  ),
                ),

                const SizedBox(height: 12),

                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  runSpacing: 8,
                  children: _styles.map(_buildStylePill).toList(),
                ),

                const SizedBox(height: 32),

                // ==================================================
                // COLORS
                // ==================================================
                Text(
                  'FAVORITE PALETTE / COLORS',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.secondary,
                    letterSpacing: 1.5,
                  ),
                ),

                const SizedBox(height: 12),

                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 10,
                  runSpacing: 10,
                  children: _colors.map((item) {
                    return _buildColorSwatch(
                      name: item['name'] as String,
                      color: item['color'] as Color,
                    );
                  }).toList(),
                ),

                const SizedBox(height: 36),

                // ==================================================
                // CONTINUE
                // ==================================================
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _continue,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.medium),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'CONTINUE',
                          style: AppTextStyles.labelMedium.copyWith(
                            color: AppColors.white,
                            letterSpacing: 1.8,
                          ),
                        ),

                        const SizedBox(width: 8),

                        const Icon(Icons.arrow_forward, size: 18),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // IMAGE MOSAIC
  // ============================================================

  Widget _buildImageMosaic() {
    const String textureImage =
        'https://lh3.googleusercontent.com/aida-public/AB6AXuBvgYKdRXGOXK0HKg8_mc1T__L9644LYqRdAeUd1CpEqBkm-hF1GSFd7xIbo8E69nzxtgnfS6KfOrQOtYN87fo7hyQd7-swyDguhQaGKTgiL7mmt0tyVUOs_SN32O1UO_VEToStLInJXeAciKo7__yKebsn4Zd3CHOyrytFg_rldRcnHuzZdLOO_qycIqdD1nTxQOJc-0c1L7qVzlv7V7N3Rk7iRQYOn7txE6eqCLP32SIKyQ3Q_QcX';

    const String accessoryImage =
        'https://lh3.googleusercontent.com/aida-public/AB6AXuDfKqVNjS1oNSPgMAGfPwYQm3gFXS4AW7ai_25zrWzL-MCgW9e-mw2vZRpX8lsI0rFs4hbcH9KCbUNcqU5R73ftNRsrtja4ZHVsI7pCcmjEc8HQedoXBkIe6x1sPtOnVOOmyfTV_lVR6sblEmQjDj_W56_HuRGR7JgUGJnYOpifxeDuEZ9LsFKOod8BE3ivM326aUwoYUG2YXgeFCAIppLCuav1b2uToY1gyvEKagxGIc-40jNN20i1';

    return SizedBox(
      height: 300,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // MAIN IMAGE
          // MAIN IMAGE
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            right: 104,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.small),
              child: Image.asset(
                'assets/images/main_fashion.png',
                fit: BoxFit.cover,
              ),
            ),
          ),

          // TOP RIGHT IMAGE
          Positioned(
            top: 0,
            right: 0,
            width: 95,
            height: 145,
            child: _buildImage(
              textureImage,
              borderRadius: BorderRadius.circular(AppRadius.small),
            ),
          ),

          // BOTTOM RIGHT IMAGE
          Positioned(
            bottom: 0,
            right: 0,
            width: 95,
            height: 145,
            child: _buildImage(
              accessoryImage,
              borderRadius: BorderRadius.circular(AppRadius.small),
            ),
          ),

          // FLOATING BADGE
          Positioned(
            bottom: -20,
            right: 18,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(AppRadius.medium),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.10),
                    blurRadius: 14,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.auto_awesome,
                    size: 18,
                    color: AppColors.primary,
                  ),

                  const SizedBox(width: 8),

                  Text(
                    'POWERED BY WEARLY AI',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.primary,
                      letterSpacing: 1.1,
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

  Widget _buildImage(String url, {BorderRadius? borderRadius}) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.circular(AppRadius.small),
      child: Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: AppColors.surfaceContainerHigh,
            child: const Center(
              child: Icon(
                Icons.image_outlined,
                size: 32,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          );
        },
      ),
    );
  }
}
