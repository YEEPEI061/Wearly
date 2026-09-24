import 'package:flutter/material.dart';
import 'package:frontend/theme/app_colors.dart';
import 'package:frontend/theme/app_text_styles.dart';
import 'package:frontend/theme/app_radius.dart';
import 'package:frontend/widgets/app_header.dart';
import 'package:frontend/widgets/bottom_nav_bar.dart';
import 'package:frontend/pages/home_page.dart';
import 'package:frontend/pages/wardrobe_page.dart';
import 'package:frontend/pages/stylist_page.dart';
import 'package:frontend/pages/history_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // ============================================================
  // STATE
  // ============================================================

  bool _dailyBriefingEnabled = true;
  bool _weatherEnabled = true;

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: true,
        child: Stack(
          children: [
            CustomScrollView(
              slivers: [
                // ==================================================
                // HEADER
                // ==================================================
                AppHeader(
                  title: 'PROFILE',
                  onNotificationTap: () {},
                  onProfileTap: () {},
                ),

                // ==================================================
                // MAIN CONTENT
                // ==================================================
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 90),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _buildProfileHeader(),

                      const SizedBox(height: 12),

                      _buildUtilizationCard(),

                      const SizedBox(height: 24),

                      _buildColorPalette(),

                      const SizedBox(height: 24),

                      _buildSilhouettePreferences(),

                      const SizedBox(height: 24),

                      _buildAIInsight(),

                      const SizedBox(height: 24),

                      _buildPreferencesList(),

                      const SizedBox(height: 24),

                      _buildFooterActions(),
                    ]),
                  ),
                ),
              ],
            ),

            // ======================================================
            // BOTTOM NAVIGATION
            // ======================================================
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: BottomNavBar(
                selectedIndex: 4,
                onItemSelected: _onNavigationSelected,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // PROFILE HEADER
  // ============================================================

  Widget _buildProfileHeader() {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Avatar
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 84,
                height: 84,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(AppRadius.large),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.10),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Text(
                  'VC',
                  style: AppTextStyles.headlineLarge.copyWith(
                    color: AppColors.white,
                    fontSize: 32,
                  ),
                ),
              ),

              // Verified badge
              Positioned(
                right: -4,
                bottom: -4,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: AppColors.secondaryDim,
                    borderRadius: BorderRadius.circular(AppRadius.small),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.verified,
                    size: 15,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Text(
            'Victoria Chase',
            textAlign: TextAlign.center,
            style: AppTextStyles.headlineLarge.copyWith(
              color: AppColors.primary,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            "MEMBER SINCE AUTUMN '22",
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.onSurfaceVariant,
              letterSpacing: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // UTILIZATION
  // ============================================================

  Widget _buildUtilizationCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.small),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'UTILIZATION',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.onSurfaceVariant,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              const Icon(
                Icons.eco_outlined,
                size: 18,
                color: AppColors.primary,
              ),
            ],
          ),

          const SizedBox(height: 14),

          Text(
            '84%',
            style: AppTextStyles.headlineLarge.copyWith(
              color: AppColors.primary,
            ),
          ),

          const SizedBox(height: 2),

          Text(
            'Wear Index',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CORE COLOR PALETTE
  // ============================================================

  Widget _buildColorPalette() {
    final colors = [
      _PaletteColor(name: 'Navy', color: AppColors.primary),
      _PaletteColor(name: 'Soft Blue', color: AppColors.primaryDim),
      _PaletteColor(name: 'Stone', color: Color(0xFFE3E2DF)),
      _PaletteColor(name: 'Ecru', color: Color(0xFFE3E2DF)),
      _PaletteColor(name: 'Charcoal', color: Color(0xFF31353C)),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.small),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Heading
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  'CORE COLOR PALETTE',
                  style: AppTextStyles.headlineSmall.copyWith(
                    color: AppColors.primary,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'AUTUMN TONE',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Text(
            'Your wardrobe favors a grounded neutral foundation accented with deep maritime navy and soft coastal blues.',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),

          const SizedBox(height: 16),

          // Palette
          Row(
            children: colors.map((item) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        height: 48,
                        decoration: BoxDecoration(
                          color: item.color,
                          borderRadius: BorderRadius.circular(AppRadius.small),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 3,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 5),

                      Text(
                        item.name.toUpperCase(),
                        textAlign: TextAlign.center,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.onSurfaceVariant,
                          fontSize: 9,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SILHOUETTE PREFERENCES
  // ============================================================

  Widget _buildSilhouettePreferences() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.small),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'SILHOUETTE PROPORTIONS',
                  style: AppTextStyles.headlineSmall.copyWith(
                    color: AppColors.primary,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
              Text(
                'BALANCED',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          _buildPreferenceBar(title: 'Relaxed Tailoring', percentage: 45),

          const SizedBox(height: 18),

          _buildPreferenceBar(title: 'Oversized Outerwear', percentage: 30),

          const SizedBox(height: 18),

          _buildPreferenceBar(title: 'Structured Minimal', percentage: 25),
        ],
      ),
    );
  }

  Widget _buildPreferenceBar({required String title, required int percentage}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              '$percentage%',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),

        const SizedBox(height: 6),

        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.small),
          child: Stack(
            children: [
              Container(
                width: double.infinity,
                height: 8,
                color: AppColors.surfaceContainerHigh,
              ),

              FractionallySizedBox(
                widthFactor: percentage / 100,
                child: Container(height: 8, color: AppColors.primary),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // AI STYLIST INSIGHT
  // ============================================================

  Widget _buildAIInsight() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(AppRadius.small),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Main content
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'AI STYLIST INSIGHT',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.primaryDim,
                  letterSpacing: 1.5,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                'The Capsule Efficiency',
                style: AppTextStyles.headlineSmall.copyWith(
                  color: AppColors.white,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'Your current pieces permit up to 48 unique outfit permutations without repeating primary pairings.',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.white.withOpacity(0.80),
                ),
              ),

              const SizedBox(height: 18),

              GestureDetector(
                onTap: _viewFullReport,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(AppRadius.small),
                  ),
                  child: Text(
                    'VIEW FULL REPORT',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.primary,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Decorative analytics icon
          Positioned(
            right: -8,
            bottom: -12,
            child: Icon(
              Icons.analytics_outlined,
              size: 110,
              color: AppColors.white.withOpacity(0.07),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SETTINGS / PREFERENCES
  // ============================================================

  Widget _buildPreferencesList() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.small),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildPreferenceRow(
            icon: Icons.tune,
            title: 'Style Questionnaire',
            onTap: _openStyleQuestionnaire,
          ),

          _buildDivider(),

          _buildPreferenceRow(
            icon: Icons.palette_outlined,
            title: 'Seasonal Color Analysis',
            onTap: _openColorAnalysis,
          ),

          _buildDivider(),

          _buildToggleRow(
            icon: Icons.notifications_active_outlined,
            title: 'Daily Briefing Notifications',
            value: _dailyBriefingEnabled,
            onChanged: (value) {
              setState(() {
                _dailyBriefingEnabled = value;
              });
            },
          ),

          _buildDivider(),

          _buildToggleRow(
            icon: Icons.cloud_outlined,
            title: 'Local Weather Integration',
            value: _weatherEnabled,
            onChanged: (value) {
              setState(() {
                _weatherEnabled = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPreferenceRow({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppColors.onSurfaceVariant),

            const SizedBox(width: 12),

            Expanded(
              child: Text(
                title,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            const Icon(
              Icons.chevron_right,
              size: 20,
              color: AppColors.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleRow({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.onSurfaceVariant),

          const SizedBox(width: 12),

          Expanded(
            child: Text(
              title,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.white,
            activeTrackColor: AppColors.primary,
            inactiveThumbColor: AppColors.outline,
            inactiveTrackColor: AppColors.surfaceContainerHigh,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: AppColors.surfaceContainerHigh,
    );
  }

  // ============================================================
  // FOOTER ACTIONS
  // ============================================================

  Widget _buildFooterActions() {
    return Column(
      children: [
        GestureDetector(
          onTap: _signOut,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 13),
            decoration: BoxDecoration(
              color: Colors.transparent,
              border: Border.all(color: AppColors.primary, width: 1),
              borderRadius: BorderRadius.circular(AppRadius.small),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.logout, size: 16, color: AppColors.primary),

                const SizedBox(width: 8),

                Text(
                  'SIGN OUT',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.primary,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 14),

        Text(
          'WEARLY • BOUTIQUE CAPSULE EDITION V2.4.0',
          textAlign: TextAlign.center,
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.onSurfaceVariant,
            letterSpacing: 0.8,
          ),
        ),

        const SizedBox(height: 8),
      ],
    );
  }

  // ============================================================
  // ACTIONS
  // ============================================================

  void _viewFullReport() {
    _showMessage('Full wardrobe report will be connected later.');
  }

  void _openStyleQuestionnaire() {
    _showMessage('Style Questionnaire will be connected later.');
  }

  void _openColorAnalysis() {
    _showMessage('Seasonal Color Analysis will be connected later.');
  }

  void _signOut() {
    _showMessage('Sign out will be connected later.');
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(24, 0, 24, 90),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.small),
        ),
        content: Row(
          children: [
            const Icon(Icons.auto_awesome, color: AppColors.white, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // NAVIGATION
  // ============================================================

  void _onNavigationSelected(int index) {
    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
        break;

      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const WardrobePage()),
        );
        break;

      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const StylistPage()),
        );
        break;

      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HistoryPage()),
        );
        break;

      case 4:
        // Already on Profile.
        break;
    }
  }
}

// ================================================================
// PALETTE MODEL
// ================================================================

class _PaletteColor {
  final String name;
  final Color color;

  const _PaletteColor({required this.name, required this.color});
}
