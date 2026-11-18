import 'package:flutter/material.dart';
import 'package:frontend/theme/app_colors.dart';
import 'package:frontend/theme/app_radius.dart';
import 'package:frontend/theme/app_text_styles.dart';
import 'package:frontend/widgets/app_page_header.dart';
import 'package:frontend/pages/seasonal_color_page.dart';

class SeasonalColorResultPage extends StatelessWidget {
  final Map<String, dynamic> seasonalColor;

  const SeasonalColorResultPage({super.key, required this.seasonalColor});

  String get season => seasonalColor['season'] as String;

  static const Map<String, Map<String, dynamic>> seasonData = {
    'Spring': {
      'description':
          'Your estimated palette features warm, light and fresh colours. '
          'These shades create a bright and lively appearance.',
      'colors': [
        {'name': 'Coral', 'color': Color(0xFFFF7F70)},
        {'name': 'Peach', 'color': Color(0xFFFFCBA4)},
        {'name': 'Warm Yellow', 'color': Color(0xFFFFD966)},
        {'name': 'Mint Green', 'color': Color(0xFF98D8B0)},
        {'name': 'Turquoise', 'color': Color(0xFF40C4B4)},
        {'name': 'Ivory', 'color': Color(0xFFFFF1D0)},
      ],
      'suggestion': 'Try coral, peach, warm yellow and fresh greens.',
    },
    'Summer': {
      'description':
          'Your estimated palette features cool, soft and muted colours. '
          'These shades create a gentle and elegant appearance.',
      'colors': [
        {'name': 'Dusty Rose', 'color': Color(0xFFD8A0A8)},
        {'name': 'Lavender', 'color': Color(0xFFC3B1D8)},
        {'name': 'Powder Blue', 'color': Color(0xFFAEC6DC)},
        {'name': 'Sage', 'color': Color(0xFFA8BFA3)},
        {'name': 'Mauve', 'color': Color(0xFFB784A7)},
        {'name': 'Soft Grey', 'color': Color(0xFFC8C8CC)},
      ],
      'suggestion': 'Try dusty rose, lavender, powder blue and soft grey.',
    },
    'Autumn': {
      'description':
          'Your estimated palette features warm, rich and earthy colours. '
          'These shades create a natural and grounded appearance.',
      'colors': [
        {'name': 'Terracotta', 'color': Color(0xFFC76E45)},
        {'name': 'Mustard', 'color': Color(0xFFD6A52C)},
        {'name': 'Olive', 'color': Color(0xFF858443)},
        {'name': 'Rust', 'color': Color(0xFFA84F32)},
        {'name': 'Camel', 'color': Color(0xFFC19A6B)},
        {'name': 'Forest', 'color': Color(0xFF42634A)},
      ],
      'suggestion': 'Try terracotta, mustard, olive and warm brown.',
    },
    'Winter': {
      'description':
          'Your estimated palette features cool, bold and high-contrast '
          'colours. These shades create a striking appearance.',
      'colors': [
        {'name': 'True Red', 'color': Color(0xFFC62828)},
        {'name': 'Emerald', 'color': Color(0xFF00866A)},
        {'name': 'Royal Blue', 'color': Color(0xFF2855A6)},
        {'name': 'Fuchsia', 'color': Color(0xFFC21875)},
        {'name': 'Icy Blue', 'color': Color(0xFFB9DDF2)},
        {'name': 'Black', 'color': Color(0xFF202020)},
      ],
      'suggestion': 'Try emerald, royal blue, fuchsia and crisp black.',
    },
  };

  @override
  Widget build(BuildContext context) {
    final data = seasonData[season]!;

    final colors = data['colors'] as List<Map<String, dynamic>>;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const AppPageHeader(title: 'MY COLOUR PALETTE'),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.auto_awesome,
                      size: 38,
                      color: AppColors.secondary,
                    ),

                    const SizedBox(height: 16),

                    Text(
                      'YOUR ESTIMATED SEASON',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.secondary,
                        letterSpacing: 1.8,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      season.toUpperCase(),
                      style: AppTextStyles.headlineLarge.copyWith(
                        color: AppColors.primary,
                        letterSpacing: 2,
                      ),
                    ),

                    const SizedBox(height: 14),

                    Text(
                      data['description'] as String,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),

                    const SizedBox(height: 32),

                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'YOUR COLOUR PALETTE',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: AppColors.primary,
                          letterSpacing: 1.3,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: colors.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 14,
                            mainAxisSpacing: 18,
                            childAspectRatio: 0.85,
                          ),
                      itemBuilder: (context, index) {
                        final item = colors[index];

                        return Column(
                          children: [
                            Expanded(
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: item['color'] as Color,
                                  borderRadius: BorderRadius.circular(
                                    AppRadius.medium,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              item['name'] as String,
                              textAlign: TextAlign.center,
                              style: AppTextStyles.labelSmall.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        );
                      },
                    ),

                    const SizedBox(height: 30),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(AppRadius.medium),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'STYLING SUGGESTION',
                            style: AppTextStyles.labelMedium.copyWith(
                              color: AppColors.secondary,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            data['suggestion'] as String,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    Text(
                      'This is an estimated colour guide based on your '
                      'questionnaire answers. Individual results may vary.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),

                    const SizedBox(height: 30),

                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SeasonalColorPage(
                              existingResult: seasonalColor,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.refresh_rounded, size: 20),
                      label: Text(
                        'RETAKE COLOUR ANALYSIS',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: AppColors.white,
                          letterSpacing: 1.0,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white,
                        disabledBackgroundColor: AppColors.primary,
                        disabledForegroundColor: AppColors.white,
                        elevation: 0,
                        minimumSize: const Size(double.infinity, 52),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.medium),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
