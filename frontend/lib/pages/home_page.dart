import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:frontend/theme/app_colors.dart';
import 'package:frontend/theme/app_text_styles.dart';
import 'package:frontend/theme/app_radius.dart';
import 'package:frontend/widgets/app_header.dart';
import 'package:frontend/pages/travel_outfit_planner_page.dart';
import 'package:frontend/services/api_service.dart';

class HomePage extends StatefulWidget {
  final void Function(int index)? onNavigateToTab;

  const HomePage({super.key, this.onNavigateToTab});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // ============================================================
  // WEATHER
  // ============================================================

  String _temperature = '--°C';
  String _location = 'Loading...';
  IconData _weatherIcon = Icons.cloud_outlined;

  // ============================================================
  // WARDROBE
  // ============================================================

  String _totalPieces = '--';
  String _itemsWorn = '-- / --';
  String _rotationRate = '--%';

  bool _isLoadingWardrobe = true;

  // ============================================================
  // RECENT OUTFITS
  // ============================================================

  List<Map<String, dynamic>> _recentOutfits = [];

  bool _isLoadingRecentOutfits = true;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    _loadWeather();
    _loadWardrobe();
    _loadHomeAnalytics();
  }

  // ============================================================
  // REFRESH
  // ============================================================

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
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
  // WARDROBE
  // ============================================================

  Future<void> _loadWardrobe() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/wardrobe'),
      );

      print(
        'HOME WARDROBE STATUS: '
        '${response.statusCode}',
      );

      print(
        'HOME WARDROBE RESPONSE: '
        '${response.body}',
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to load wardrobe.');
      }

      final decoded = jsonDecode(response.body);

      List<dynamic> items;

      if (decoded is List) {
        items = decoded;
      } else if (decoded is Map && decoded['items'] is List) {
        items = decoded['items'];
      } else if (decoded is Map && decoded['clothing_items'] is List) {
        items = decoded['clothing_items'];
      } else {
        items = [];
      }

      if (!mounted) return;

      setState(() {
        _isLoadingWardrobe = false;

        _totalPieces = items.length.toString();
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoadingWardrobe = false;
        _totalPieces = '--';
      });

      debugPrint('Home wardrobe error: $e');
    }
  }

  String _buildImageUrl(String path) {
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }

    if (path.startsWith('/')) {
      return '${ApiService.baseUrl}$path';
    }

    return '${ApiService.baseUrl}/$path';
  }

  // ============================================================
  // HOME ANALYTICS + RECENT OUTFITS
  // ============================================================

  Future<void> _loadHomeAnalytics() async {
    final now = DateTime.now();

    try {
      final response = await http.get(
        Uri.parse(
          '${ApiService.baseUrl}/outfit-history'
          '?year=${now.year}'
          '&month=${now.month}',
        ),
      );

      print(
        'HOME HISTORY STATUS: '
        '${response.statusCode}',
      );

      print(
        'HOME HISTORY RESPONSE: '
        '${response.body}',
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to load outfit history.');
      }

      final data = jsonDecode(response.body);

      List<Map<String, dynamic>> history = [];

      if (data is Map && data['history'] is List) {
        history = List<Map<String, dynamic>>.from(
          (data['history'] as List).map(
            (item) => Map<String, dynamic>.from(item),
          ),
        );
      } else if (data is List) {
        history = List<Map<String, dynamic>>.from(
          data.map((item) => Map<String, dynamic>.from(item)),
        );
      }

      // --------------------------------------------------------
      // ANALYTICS
      // --------------------------------------------------------

      int totalActiveItems = 0;
      int usedItems = 0;
      int rotationRate = 0;

      if (data is Map) {
        totalActiveItems = (data['total_active_items'] as num?)?.toInt() ?? 0;

        usedItems = (data['used_items'] as num?)?.toInt() ?? 0;

        rotationRate = (data['rotation_rate'] as num?)?.toInt() ?? 0;
      }

      // --------------------------------------------------------
      // SORT RECENT OUTFITS
      // --------------------------------------------------------

      history.sort((a, b) {
        final dateA = DateTime.tryParse(a['worn_date']?.toString() ?? '');

        final dateB = DateTime.tryParse(b['worn_date']?.toString() ?? '');

        if (dateA == null && dateB == null) {
          return 0;
        }

        if (dateA == null) {
          return 1;
        }

        if (dateB == null) {
          return -1;
        }

        return dateB.compareTo(dateA);
      });

      final recent = history.take(2).toList();

      if (!mounted) return;

      setState(() {
        _isLoadingRecentOutfits = false;

        _itemsWorn = '$usedItems / $totalActiveItems';

        _rotationRate = '$rotationRate%';

        _recentOutfits = recent;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoadingRecentOutfits = false;

        _itemsWorn = '-- / --';
        _rotationRate = '--%';
        _recentOutfits = [];
      });

      debugPrint('Home history error: $e');
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
    widget.onNavigateToTab?.call(3);
  }

  void _openWardrobe() {
    widget.onNavigateToTab?.call(1);
  }

  void _styleAnOutfit() {
    widget.onNavigateToTab?.call(2);
  }

  void _openTravelPlanner() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TravelOutfitPlannerPage()),
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
                AppHeader(
                  title: 'HOME',
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

                // ========================================================
                // CONTENT
                // ========================================================
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 38),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _buildGreeting(),

                      const SizedBox(height: 24),

                      _buildHeroCard(),

                      const SizedBox(height: 24),

                      _buildAnalytics(),

                      const SizedBox(height: 24),

                      _buildWeatherInsight(),

                      const SizedBox(height: 16),

                      _buildTravelCapsule(),

                      const SizedBox(height: 24),

                      _buildRecentOutfits(),
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
          // ========================================================
          // REAL WARDROBE IMAGE
          // ========================================================
          Positioned.fill(
            child: Image.asset(
              'assets/images/home_page.png',
              fit: BoxFit.cover,
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
                    AppColors.primary.withOpacity(0.48),
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
                // ==================================================
                // TOP LABEL
                // ==================================================
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
                        'YOUR WARDROBE',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.primary,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ],
                ),

                const Spacer(),

                // ==================================================
                // HERO TEXT
                // ==================================================
                Text(
                  'YOUR PERSONAL COLLECTION',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.primaryDim,
                    letterSpacing: 1.2,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  'Explore What You Own',
                  style: AppTextStyles.headlineMedium.copyWith(
                    color: AppColors.white,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  'Explore your personal collection '
                  'and discover new ways to style '
                  'what you own.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.white.withOpacity(0.88),
                  ),
                ),

                const SizedBox(height: 20),

                // ==================================================
                // ACTION BUTTONS
                // ==================================================
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 46,
                        child: ElevatedButton.icon(
                          onPressed: _openWardrobe,
                          icon: const Padding(
                            padding: EdgeInsets.only(right: 4),
                            child: Icon(Icons.checkroom_outlined, size: 19),
                          ),
                          label: Text(
                            'VIEW WARDROBE',
                            style: AppTextStyles.labelMedium.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
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
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: SizedBox(
                        height: 46,
                        child: OutlinedButton.icon(
                          onPressed: _styleAnOutfit,
                          icon: const Padding(
                            padding: EdgeInsets.only(right: 4),
                            child: Icon(Icons.auto_awesome_outlined, size: 19),
                          ),
                          label: Text(
                            'STYLE AN OUTFIT',
                            style: AppTextStyles.labelMedium.copyWith(
                              color: AppColors.white,
                            ),
                          ),
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
                badge: _isLoadingWardrobe ? '--' : 'WARDROBE',
                value: _totalPieces,
                label: 'TOTAL PIECES',
                badgeColor: AppColors.secondary.withOpacity(0.35),
                badgeTextColor: AppColors.primary,
              ),
            ),

            const SizedBox(width: 16),

            Expanded(
              child: _buildStatCard(
                icon: Icons.auto_awesome,
                badge: _rotationRate,
                value: _itemsWorn,
                label: 'ITEMS WORN',
                badgeColor: AppColors.secondary.withOpacity(0.35),
                badgeTextColor: AppColors.primary,
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
    Color? badgeColor,
    Color? badgeTextColor,
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
                  color: badgeColor ?? AppColors.primary.withOpacity(0.35),
                  borderRadius: BorderRadius.circular(AppRadius.small),
                ),
                child: Text(
                  badge,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: badgeTextColor ?? AppColors.primary,
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
                  "We recommend checking "
                  "your wardrobe for "
                  "weather-friendly pieces "
                  "before heading out.",
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
  // TRAVEL CAPSULE
  // ============================================================

  Widget _buildTravelCapsule() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --------------------------------------------------------
          // TOP ROW
          // --------------------------------------------------------
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(AppRadius.small),
                ),
                child: Text(
                  'TRAVEL CAPSULE',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.primaryDim,
                    letterSpacing: 1.2,
                  ),
                ),
              ),

              const Icon(
                Icons.flight_takeoff,
                size: 24,
                color: AppColors.primaryDim,
              ),
            ],
          ),

          const SizedBox(height: 20),

          // --------------------------------------------------------
          // TITLE
          // --------------------------------------------------------
          Text(
            'Plan Your Journey Wardrobe',
            style: AppTextStyles.headlineMedium.copyWith(
              color: AppColors.white,
            ),
          ),

          const SizedBox(height: 4),

          // --------------------------------------------------------
          // DESCRIPTION
          // --------------------------------------------------------
          Text(
            'Smart packing & weather-synced rotation '
            'tailored to your destination.',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.white.withOpacity(0.80),
            ),
          ),

          const SizedBox(height: 20),

          // --------------------------------------------------------
          // PLAN OUTFITS
          // --------------------------------------------------------
          GestureDetector(
            onTap: _openTravelPlanner,
            behavior: HitTestBehavior.opaque,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'PLAN OUTFITS',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.secondaryDim,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(width: 6),

                const Icon(
                  Icons.arrow_forward,
                  size: 16,
                  color: AppColors.secondaryDim,
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

        if (_isLoadingRecentOutfits)
          _buildRecentOutfitLoadingCard()
        else if (_recentOutfits.isEmpty)
          _buildNoRecentOutfits()
        else
          ..._recentOutfits
              .map((outfit) => _buildRecentOutfitCard(outfit))
              .toList(),
      ],
    );
  }

  Widget _buildRecentOutfitCard(Map<String, dynamic> outfit) {
    final imagePath = outfit['image_url']?.toString();

    final imageUrl = imagePath != null && imagePath.isNotEmpty
        ? _buildImageUrl(imagePath)
        : null;

    final wornDate = DateTime.tryParse(outfit['worn_date']?.toString() ?? '');

    final date = wornDate != null
        ? DateFormat('MMM d').format(wornDate).toUpperCase()
        : 'RECENT';

    final title = outfit['title']?.toString() ?? 'Recorded Outfit';

    final items = outfit['items'] is List
        ? List<dynamic>.from(outfit['items'])
        : <dynamic>[];

    final description = _buildOutfitDescription(items);

    return Container(
      height: 112,
      margin: const EdgeInsets.only(bottom: 16),
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
            child: imageUrl != null
                ? Image.network(
                    imageUrl,
                    width: 64,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) {
                      return _buildRecentImagePlaceholder();
                    },
                  )
                : _buildRecentImagePlaceholder(),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),

                Text(
                  date,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.headlineSmall.copyWith(
                    color: AppColors.primary,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  description,
                  maxLines: 2,
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

  String _buildOutfitDescription(List<dynamic> items) {
    if (items.isEmpty) {
      return 'No clothing items';
    }

    final names = items
        .map((item) {
          if (item is Map<String, dynamic>) {
            return item['name']?.toString() ?? '';
          }

          if (item is Map) {
            return item['name']?.toString() ?? '';
          }

          return '';
        })
        .where((name) => name.isNotEmpty)
        .toList();

    if (names.isEmpty) {
      return 'No clothing items';
    }

    return names.join(' • ');
  }

  Widget _buildRecentImagePlaceholder() {
    return Container(
      width: 64,
      height: 80,
      color: AppColors.surfaceContainerHigh,
      child: const Icon(Icons.checkroom_outlined, color: AppColors.outline),
    );
  }

  Widget _buildRecentOutfitLoadingCard() {
    return Container(
      height: 112,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerMedium,
        borderRadius: BorderRadius.circular(AppRadius.medium),
      ),
      child: const Center(
        child: SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }

  Widget _buildNoRecentOutfits() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerMedium,
        borderRadius: BorderRadius.circular(AppRadius.medium),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.history_outlined,
            size: 28,
            color: AppColors.outline,
          ),

          const SizedBox(height: 8),

          Text(
            'No recent outfits yet.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
