// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:frontend/theme/app_colors.dart';
import 'package:frontend/theme/app_text_styles.dart';
import 'package:frontend/theme/app_radius.dart';
import 'package:frontend/widgets/app_header.dart';
import 'package:frontend/pages/stylist_page.dart';

class StylistStartPage extends StatefulWidget {
  const StylistStartPage({super.key});

  @override
  State<StylistStartPage> createState() => _StylistStartPageState();
}

class _StylistStartPageState extends State<StylistStartPage> {
  String _selectedOccasion = 'Casual';
  String _selectedMood = 'Relaxed';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: true,
        child: Stack(
          children: [
            CustomScrollView(
              // physics: const BouncingScrollPhysics(),
              slivers: [
                AppHeader(
                  title: 'OUTFIT STYLIST',
                  onNotificationTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Notifications will be connected later.'),
                      ),
                    );
                  },
                  onProfileTap: () {
                    // Navigate to Profile
                  },
                ),

                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 38),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _buildStartStylingSection(context),
                    ]),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStartStylingSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ============================================================
        // AI LABEL
        // ============================================================
        Row(
          children: [
            const Icon(Icons.auto_awesome, size: 18, color: AppColors.primary),
            const SizedBox(width: 6),
            Text(
              'WEARLY AI STYLIST',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.onSurfaceVariant,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        // ============================================================
        // TITLE
        // ============================================================
        Text(
          'Ready to Style',
          style: AppTextStyles.headlineMedium.copyWith(
            color: AppColors.primary,
          ),
        ),

        const SizedBox(height: 6),

        // ============================================================
        // DESCRIPTION
        // ============================================================
        Text(
          'Let AI create your next look from your wardrobe.',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),

        const SizedBox(height: 24),

        // ============================================================
        // HERO PREVIEW
        // ============================================================
        _buildHeroPreview(),

        const SizedBox(height: 28),

        // ============================================================
        // OCCASION TITLE
        // ============================================================
        Text(
          'Select Occasion',
          style: AppTextStyles.headlineSmall.copyWith(color: AppColors.primary),
        ),

        const SizedBox(height: 12),

        // ============================================================
        // OCCASION OPTIONS
        // ============================================================
        _buildOccasionSelector(),

        const SizedBox(height: 28),

        // ============================================================
        // MOOD TITLE
        // ============================================================
        Text(
          'Select Mood',
          style: AppTextStyles.headlineSmall.copyWith(color: AppColors.primary),
        ),

        const SizedBox(height: 12),

        // ============================================================
        // MOOD OPTIONS
        // ============================================================
        _buildMoodSelector(),

        const SizedBox(height: 28),

        // ============================================================
        // START STYLING BUTTON
        // ============================================================
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => StylistPage(
                    occasion: _selectedOccasion,
                    mood: _selectedMood,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.arrow_forward, size: 20),
            label: Text(
              'START STYLING',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.white,
                letterSpacing: 1.0,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.medium),
              ),
            ),
          ),
        ),

        const SizedBox(height: 10),

        // ============================================================
        // SUPPORTING TEXT
        // ============================================================
        Center(
          child: Text(
            'Personalized using your wardrobe and preferences',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }

  // ================================================================
  // HERO PREVIEW
  // ================================================================

  Widget _buildHeroPreview() {
    return Container(
      width: double.infinity,
      height: 210,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerMedium,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // HERO IMAGE
          Positioned.fill(
            child: Image.asset(
              'assets/images/main_fashion.png',
              fit: BoxFit.cover,
            ),
          ),

          // DARK GRADIENT
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    AppColors.primary.withOpacity(0.80),
                  ],
                ),
              ),
            ),
          ),

          // HERO TEXT
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'WARDROBE READY',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.secondary,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Your wardrobe is ready to style',
                        style: AppTextStyles.headlineSmall.copyWith(
                          color: AppColors.white,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.auto_awesome,
                    color: AppColors.white,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================================================================
  // OCCASION SELECTOR
  // ================================================================

  Widget _buildOccasionSelector() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 3.4,
      children: [
        _buildOccasionOption('Casual', Icons.weekend_outlined),
        _buildOccasionOption('Work', Icons.business_center_outlined),
        _buildOccasionOption('Evening', Icons.nightlife_outlined),
        _buildOccasionOption('Going Out', Icons.celebration_outlined),
      ],
    );
  }

  Widget _buildOccasionOption(String title, IconData icon) {
    final bool isSelected = _selectedOccasion == title;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedOccasion = title;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : AppColors.surfaceContainerMedium,
          borderRadius: BorderRadius.circular(AppRadius.small),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : AppColors.outline.withOpacity(0.12),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 17,
              color: isSelected ? AppColors.white : AppColors.onSurfaceVariant,
            ),
            const SizedBox(width: 7),
            Text(
              title,
              style: AppTextStyles.bodySmall.copyWith(
                color: isSelected ? AppColors.white : AppColors.onSurface,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================================================================
  // MOOD SELECTOR
  // ================================================================

  Widget _buildMoodSelector() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 3.4,
      children: [
        _buildMoodOption('Relaxed', Icons.spa_outlined),
        _buildMoodOption('Smart', Icons.auto_awesome_outlined),
        _buildMoodOption('Elegant', Icons.diamond_outlined),
        _buildMoodOption('Trendy', Icons.local_fire_department_outlined),
      ],
    );
  }

  Widget _buildMoodOption(String title, IconData icon) {
    final bool isSelected = _selectedMood == title;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMood = title;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : AppColors.surfaceContainerMedium,
          borderRadius: BorderRadius.circular(AppRadius.small),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : AppColors.outline.withOpacity(0.12),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 17,
              color: isSelected ? AppColors.white : AppColors.onSurfaceVariant,
            ),
            const SizedBox(width: 7),
            Text(
              title,
              style: AppTextStyles.bodySmall.copyWith(
                color: isSelected ? AppColors.white : AppColors.onSurface,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
