import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend/theme/app_colors.dart';
import 'package:frontend/theme/app_text_styles.dart';
import 'package:frontend/theme/app_radius.dart';
import 'package:frontend/widgets/app_header.dart';
import 'package:frontend/widgets/bottom_nav_bar.dart';
import 'package:frontend/pages/wardrobe_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isSaved = false;

  // ============================================================
  // WEATHER
  // ============================================================

  String _temperature = '--°C';
  String _location = 'Loading...';
  IconData _weatherIcon = Icons.cloud_outlined;

  // ============================================================
  // IMAGES
  // ============================================================

  // Mock data for frontend development.
  // These will be connected to the backend later.
  final String _heroImage =
      'https://lh3.googleusercontent.com/aida-public/AB6AXuA9mKLdSK_xMjuuJesWEk0kMOydg8pkm6K8Z70N3jthxlFcZOPZC1LgztsH2RxpM463APF9EmJgJ2UB5-Wau_BrVDP0pmgwpDj-Tq7Iq1u13oxwT-toscxH4m6sSWEZdP_C2j8yZXoB65FmcQvmzokDiep8kwKuNQM3e6U_inUJRnhOm1Hhc2mmyp5IKidHHMDNi4fI60bwZdCkzCDpagE8UtPSp--z_57s03bmmcFtGtwy3zX17A90';

  final String _recentImage1 =
      'https://lh3.googleusercontent.com/aida-public/AB6AXuDAxTkCyvtBSxmH7U_oKEWhoPVpwoJgsSqmgcyYuBqt78UIq2LlWlbkzmfLnRYfP8J0Y1iBrRlaK0z4uSGPAOs0FClzjg2FtEyBV7zhywyOXGuOZEMLTx29VEolAyDzDPHPhTMK9679alN_LMHLJBsj7pbBtPC4MH3ieTtQP7UTW0FIiMlTD5ngEc4GNW0zcfrCigP-Dpl6ByflAhmtIfOWYMnvCcokunf9ZKdn4FoAoBgFhTeRiJes';

  final String _recentImage2 =
      'https://lh3.googleusercontent.com/aida-public/AB6AXuAS5zmS-c2eAdaXsEKF7oENaBti8sQxEG7ILc40MQNAQl977BxeMPDzReUyiscJh1VAUNtbaHLR_BToDGbbEmIWlT9_y1oxOw2ob2g6n2QorNmhW3lnV-hF2s3gfBz3TRME1hZ2pRu2YWqc0U4y_6nXk03Z1p-VKcbxlwTQ25xh6q1WuDlMD2AnjYENPBpSuEfxxoP2nYi5qcgS9gyNp19IA7cRzI9ZpN97EEb-9-C9ZUqipCOeDVXZ';

  @override
  void initState() {
    super.initState();
    _loadWeather();
  }

  // ============================================================
  // WEATHER
  // ============================================================

  Future<void> _loadWeather() async {
    const double latitude = 3.1073;
    const double longitude = 101.6067;

    try {
      final url = Uri.parse(
        'https://api.open-meteo.com/v1/forecast'
        '?latitude=$latitude'
        '&longitude=$longitude'
        '&current=temperature_2m,weather_code'
        '&timezone=auto',
      );

      final response = await http.get(url);

      if (response.statusCode != 200) {
        throw Exception('Weather API request failed');
      }

      final data = jsonDecode(response.body);

      final double temperature = (data['current']['temperature_2m'] as num)
          .toDouble();

      final int weatherCode = data['current']['weather_code'] as int;

      if (!mounted) return;

      setState(() {
        _temperature = '${temperature.round()}°C';
        _location = 'Petaling Jaya';
        _weatherIcon = _getWeatherIcon(weatherCode);
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _temperature = '--°C';
        _location = 'Weather unavailable';
        _weatherIcon = Icons.cloud_off_outlined;
      });

      debugPrint('Weather error: $e');
    }
  }

  IconData _getWeatherIcon(int code) {
    if (code == 0) {
      return Icons.wb_sunny_outlined;
    }

    if (code == 1 || code == 2) {
      return Icons.wb_cloudy_outlined;
    }

    if (code == 3) {
      return Icons.cloud_outlined;
    }

    if (code >= 45 && code <= 48) {
      return Icons.foggy;
    }

    if (code >= 51 && code <= 57) {
      return Icons.grain;
    }

    if (code >= 61 && code <= 67) {
      return Icons.water_drop_outlined;
    }

    if (code >= 71 && code <= 77) {
      return Icons.ac_unit_outlined;
    }

    if (code >= 80 && code <= 82) {
      return Icons.grain;
    }

    if (code >= 95 && code <= 99) {
      return Icons.thunderstorm_outlined;
    }

    return Icons.cloud_outlined;
  }

  // ============================================================
  // BOTTOM NAV
  // ============================================================
  void _onNavigationSelected(int index) {
    switch (index) {
      case 0:
        // Already on Home
        break;

      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const WardrobePage()),
        );
        break;

      case 2:
        // Navigate to Stylist later
        break;

      case 3:
        // Navigate to History later
        break;

      case 4:
        // Navigate to Profile later
        break;
    }
  }

  // ============================================================
  // GREETING
  // ============================================================

  String _getGreeting() {
    final hour = DateTime.now().hour;

    if (hour < 12) {
      return 'Good morning';
    } else if (hour < 18) {
      return 'Good afternoon';
    } else {
      return 'Good evening';
    }
  }

  String _getCurrentDate() {
    return DateFormat('EEEE, MMMM d').format(DateTime.now()).toUpperCase();
  }

  // ============================================================
  // ACTIONS
  // ============================================================

  void _viewAllHistory() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Full outfit history will be connected later.'),
      ),
    );
  }

  void _wearToday() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Outfit selected for today.')));
  }

  void _swapItems() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('AI outfit swapping will be connected later.'),
      ),
    );
  }

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
                const AppHeader(title: 'HOME'),
                // ========================================================
                // CONTENT
                // ========================================================
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 110),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _buildGreeting(),

                      const SizedBox(height: 32),

                      _buildHeroCard(),

                      const SizedBox(height: 32),

                      _buildAnalytics(),

                      const SizedBox(height: 32),

                      _buildWeatherInsight(),

                      const SizedBox(height: 32),

                      _buildRecentOutfits(),
                    ]),
                  ),
                ),
              ],
            ),

            // ============================================================
            // FLOATING BOTTOM NAVIGATION
            // ============================================================
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: BottomNavBar(
                selectedIndex: 0,
                onItemSelected: _onNavigationSelected,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // GREETING
  // ============================================================

  Widget _buildGreeting() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getCurrentDate(),
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.onSurfaceVariant,
                  letterSpacing: 1.5,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                '${_getGreeting()}, Elena.',
                style: AppTextStyles.headlineSmall.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 12),

        // ============================================================
        // WEATHER MINI CARD
        // ============================================================
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(AppRadius.medium),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(_weatherIcon, size: 24, color: AppColors.primary),

              const SizedBox(width: 8),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _temperature,
                    style: AppTextStyles.bodySmall.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),

                  Text(
                    _location,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // HERO CARD
  // ============================================================

  Widget _buildHeroCard() {
    return Container(
      height: 380,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.medium),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.network(
              _heroImage,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) {
                return Container(
                  color: AppColors.surfaceContainerHigh,
                  child: const Center(
                    child: Icon(
                      Icons.image_outlined,
                      size: 40,
                      color: AppColors.outline,
                    ),
                  ),
                );
              },
            ),
          ),

          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.primary.withOpacity(0.15),
                    AppColors.primary.withOpacity(0.45),
                    AppColors.primary.withOpacity(0.97),
                  ],
                  stops: const [0.0, 0.42, 1.0],
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.white.withOpacity(0.90),
                        borderRadius: BorderRadius.circular(AppRadius.small),
                      ),
                      child: Text(
                        "TODAY'S EDITORIAL PICK",
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.primary,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),

                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isSaved = !_isSaved;
                        });
                      },
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.white.withOpacity(0.90),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _isSaved ? Icons.bookmark : Icons.bookmark_border,
                          size: 20,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),

                const Spacer(),

                Text(
                  'BUSINESS CASUAL • 18°C & BREEZY',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.primaryDim,
                    letterSpacing: 1.2,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  'The Monochromatic Trench',
                  style: AppTextStyles.headlineLarge.copyWith(
                    color: AppColors.white,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  'A refined balance of structure and ease, '
                  'designed for a polished day in the city.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.white.withOpacity(0.88),
                  ),
                ),

                const SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 46,
                        child: ElevatedButton(
                          onPressed: _wearToday,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.white,
                            foregroundColor: AppColors.primary,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppRadius.medium,
                              ),
                            ),
                          ),
                          child: Text(
                            'WEAR TODAY',
                            style: AppTextStyles.labelMedium.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: SizedBox(
                        height: 46,
                        child: OutlinedButton(
                          onPressed: _swapItems,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.white,
                            side: BorderSide(
                              color: AppColors.white.withOpacity(0.7),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppRadius.medium,
                              ),
                            ),
                          ),
                          child: Text(
                            'SWAP ITEMS',
                            style: AppTextStyles.labelMedium.copyWith(
                              color: AppColors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // WARDROBE ANALYTICS
  // ============================================================

  Widget _buildAnalytics() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'WARDROBE ANALYTICS',
              style: AppTextStyles.headlineSmall.copyWith(
                color: AppColors.primary,
                letterSpacing: 1.2,
              ),
            ),

            Text(
              'THIS MONTH',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.checkroom_outlined,
                badge: '+4 NEW',
                value: '142',
                label: 'TOTAL PIECES',
              ),
            ),

            const SizedBox(width: 16),

            Expanded(
              child: _buildStatCard(
                icon: Icons.auto_awesome,
                badge: '94%',
                value: '28 / 30',
                label: 'ITEMS WORN',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String badge,
    required String value,
    required String label,
  }) {
    return Container(
      height: 155,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerMedium,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, size: 24, color: AppColors.secondary),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.35),
                  borderRadius: BorderRadius.circular(AppRadius.small),
                ),
                child: Text(
                  badge,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),

          const Spacer(),

          Text(
            value,
            style: AppTextStyles.headlineMedium.copyWith(
              color: AppColors.primary,
            ),
          ),

          const SizedBox(height: 2),

          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.onSurfaceVariant,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // WEATHER INSIGHT
  // ============================================================

  Widget _buildWeatherInsight() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.secondaryDim,
              borderRadius: BorderRadius.circular(AppRadius.medium),
            ),
            child: const Icon(
              Icons.umbrella_outlined,
              size: 24,
              color: AppColors.primary,
            ),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Rain expected by 4 PM',
                  style: AppTextStyles.headlineSmall.copyWith(
                    color: AppColors.primary,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  "We swapped your suede loafers for "
                  "water-resistant leather boots in "
                  "today's recommendation.",
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // RECENT OUTFITS
  // ============================================================

  Widget _buildRecentOutfits() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'RECENT OUTFITS',
              style: AppTextStyles.headlineSmall.copyWith(
                color: AppColors.primary,
                letterSpacing: 1.2,
              ),
            ),

            GestureDetector(
              onTap: _viewAllHistory,
              child: Text(
                'VIEW ALL',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.primary,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        _buildRecentOutfitCard(
          imageUrl: _recentImage1,
          date: 'YESTERDAY',
          title: 'Evening Dinner & Gallery',
          description: 'Silk slip dress • Oversized blazer',
          isFavorite: true,
        ),

        const SizedBox(height: 16),

        _buildRecentOutfitCard(
          imageUrl: _recentImage2,
          date: 'SATURDAY',
          title: 'Weekend Brunch',
          description: 'Raw denim • Poplin shirt • Sneakers',
          isFavorite: false,
        ),
      ],
    );
  }

  Widget _buildRecentOutfitCard({
    required String imageUrl,
    required String date,
    required String title,
    required String description,
    required bool isFavorite,
  }) {
    return Container(
      height: 112,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerMedium,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.small),
            child: Image.network(
              imageUrl,
              width: 64,
              height: 80,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) {
                return Container(
                  width: 64,
                  height: 80,
                  color: AppColors.surfaceContainerHigh,
                  child: const Icon(
                    Icons.image_outlined,
                    color: AppColors.outline,
                  ),
                );
              },
            ),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        date,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ),

                    Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      size: 18,
                      color: isFavorite
                          ? AppColors.primary
                          : AppColors.onSurfaceVariant,
                    ),
                  ],
                ),

                const SizedBox(height: 2),

                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.headlineSmall.copyWith(
                    color: AppColors.primary,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
