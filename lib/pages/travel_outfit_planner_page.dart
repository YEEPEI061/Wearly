import 'package:flutter/material.dart';

import 'package:frontend/theme/app_colors.dart';
import 'package:frontend/theme/app_text_styles.dart';
import 'package:frontend/theme/app_radius.dart';
import 'package:frontend/widgets/app_header_back.dart';

class TravelOutfitPlannerPage extends StatefulWidget {
  const TravelOutfitPlannerPage({super.key});

  @override
  State<TravelOutfitPlannerPage> createState() =>
      _TravelOutfitPlannerPageState();
}

class _TravelOutfitPlannerPageState extends State<TravelOutfitPlannerPage> {
  int _selectedDay = 1;
  int _selectedDuration = 7;

  bool _isSaved = false;
  bool _showDays5To7 = false;

  final List<bool> _packedItems = [true, true, true, true, true, true];

  final List<Map<String, dynamic>> _days = [
    {'day': 'Day 01', 'title': 'Transit & Coastal Walk', 'status': 'star'},
    {'day': 'Day 02', 'title': 'Old Town & Cafe', 'status': 'packed'},
    {'day': 'Day 03', 'title': 'Beach Club & Riviera', 'status': 'packed'},
    {'day': 'Day 04', 'title': 'Yacht Excursion & Sun', 'status': 'packed'},
    {'day': 'Day 05', 'title': 'Art Gallery & Bistro', 'status': 'none'},
    {'day': 'Day 06', 'title': 'Sunset Dining & Wine', 'status': 'none'},
    {'day': 'Day 07', 'title': 'Market & Departure', 'status': 'none'},
  ];

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.white),
          ),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.medium),
          ),
          duration: const Duration(milliseconds: 2600),
        ),
      );
  }

  void _selectDay(int day) {
    setState(() {
      _selectedDay = day;
    });

    _showMessage(
      'Showing curated look for Day ${day.toString().padLeft(2, '0')}',
    );
  }

  void _selectDuration(int duration) {
    setState(() {
      _selectedDuration = duration;
    });

    _showMessage('$duration-day capsule selected');
  }

  void _togglePacked(int index) {
    setState(() {
      _packedItems[index] = !_packedItems[index];
    });
  }

  void _toggleSave() {
    setState(() {
      _isSaved = !_isSaved;
    });

    _showMessage(
      _isSaved
          ? 'Lookbook outfit saved to Favorites'
          : 'Look removed from saved outfits',
    );
  }

  void _openTripSettings() {
    _showMessage('Opening trip settings & calendar editor');
  }

  void _openDestination() {
    _showMessage('Select destination: Amalfi Coast active');
  }

  void _openDates() {
    _showMessage('Opening travel calendar: Oct 24 – Oct 30');
  }

  void _autoGenerate() {
    _showMessage(
      'Regenerating $_selectedDuration-day capsule for Amalfi Coast',
    );
  }

  void _openWeatherSettings() {
    _showMessage('Weather settings: Mediterranean 24°C coastal breeze');
  }

  void _scheduleOutfit() {
    _showMessage('Outfit scheduled to Day $_selectedDay itinerary');
  }

  void _swapItem() {
    _showMessage('Swapped ivory shirt with knit polo');
  }

  void _quickReroll() {
    _showMessage('Replaced Linen Shirt with Silk Popover');
  }

  void _exportChecklist() {
    _showMessage('Checklist exported to PDF & luggage tag created');
  }

  void _shareItinerary() {
    _showMessage('Shared itinerary capsule link');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            AppPageHeader(
              title: 'TRAVEL OUTFIT PLANNER',
              onProfileTap: () {
                _showMessage('Profile opened');
              },
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildIntro(),
                    const SizedBox(height: 24),
                    _buildTripConfiguration(),
                    const SizedBox(height: 24),
                    _buildTimeline(),
                    const SizedBox(height: 24),
                    _buildFeaturedLook(),
                    const SizedBox(height: 24),
                    _buildAllDaysItinerary(),
                    const SizedBox(height: 24),
                    _buildPackingCapsule(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // INTRO
  // ============================================================

  Widget _buildIntro() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Intelligent wardrobe rotation & packing harmony',
          style: AppTextStyles.headlineMedium.copyWith(
            color: AppColors.primary,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Thoughtfully styled capsule maximizing versatile '
          'elegance with minimal luggage weight.',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // TRIP CONFIGURATION
  // ============================================================

  Widget _buildTripConfiguration() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.large),
        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.7)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(
                Icons.luggage_outlined,
                size: 18,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'TRIP CONFIGURATION',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.primary,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              GestureDetector(
                onTap: _openTripSettings,
                child: Row(
                  children: [
                    const Icon(
                      Icons.tune,
                      size: 14,
                      color: AppColors.secondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'EDIT DETAILS',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Container(
            height: 1,
            color: AppColors.outlineVariant.withOpacity(0.4),
          ),

          const SizedBox(height: 12),

          _buildConfigurationCard(
            icon: Icons.location_on_outlined,
            title: 'DESTINATION',
            value: 'Amalfi Coast, Italy',
            badge: '24°C Sunny',
            subtitle: 'Mediterranean Warm Coastal • Spring/Summer',
            trailingIcon: Icons.expand_more,
            onTap: _openDestination,
          ),

          const SizedBox(height: 10),

          _buildConfigurationCard(
            icon: Icons.calendar_today_outlined,
            title: 'TRIP DURATION & DATES',
            value: 'Oct 24 – Oct 30, 2025',
            badge: '7 Days',
            subtitle: '7 Days • 6 Nights curated itinerary',
            trailingIcon: Icons.edit_calendar_outlined,
            onTap: _openDates,
          ),

          const SizedBox(height: 14),

          _buildDurationFilters(),

          const SizedBox(height: 14),

          Container(
            height: 1,
            color: AppColors.outlineVariant.withOpacity(0.4),
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: ElevatedButton.icon(
                    onPressed: _autoGenerate,
                    icon: const Icon(Icons.auto_awesome, size: 16),
                    label: Text(
                      'AUTO-GENERATE $_selectedDuration DAYS',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.white,
                        letterSpacing: 0.8,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.medium),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _openWeatherSettings,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(AppRadius.medium),
                    border: Border.all(
                      color: AppColors.outlineVariant.withOpacity(0.7),
                    ),
                  ),
                  child: const Icon(
                    Icons.wb_sunny_outlined,
                    size: 18,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildConfigurationCard({
    required IconData icon,
    required String title,
    required String value,
    required String badge,
    required String subtitle,
    required IconData trailingIcon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(AppRadius.large),
          border: Border.all(color: AppColors.outlineVariant.withOpacity(0.6)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 13, color: AppColors.primary),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    title,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.1,
                    ),
                  ),
                ),
                Icon(trailingIcon, size: 15, color: AppColors.secondary),
              ],
            ),
            const SizedBox(height: 7),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryDim.withOpacity(0.35),
                    borderRadius: BorderRadius.circular(AppRadius.small),
                  ),
                  child: Text(
                    badge,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.primary,
                      letterSpacing: 0,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDurationFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          Text(
            'QUICK DAYS:',
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.secondary,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(width: 8),
          _buildDurationChip(3),
          const SizedBox(width: 6),
          _buildDurationChip(5),
          const SizedBox(width: 6),
          _buildDurationChip(7),
          const SizedBox(width: 6),
          _buildDurationChip(10),
          const SizedBox(width: 6),
          _buildDurationChip(null),
        ],
      ),
    );
  }

  Widget _buildDurationChip(int? duration) {
    final bool selected = duration != null && duration == _selectedDuration;

    final String label = duration == null ? 'CUSTOM +' : '$duration DAYS';

    return GestureDetector(
      onTap: () {
        if (duration == null) {
          _showMessage('Custom date picker opened');
        } else {
          _selectDuration(duration);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.background,
          borderRadius: BorderRadius.circular(AppRadius.medium),
          border: Border.all(
            color: selected
                ? AppColors.primary
                : AppColors.outlineVariant.withOpacity(0.6),
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color: selected ? AppColors.white : AppColors.secondary,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            letterSpacing: 0,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // TIMELINE
  // ============================================================

  Widget _buildTimeline() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'ITINERARY TIMELINE',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.secondary,
                letterSpacing: 1.5,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Text(
              'Scroll to select day',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.secondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 72,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _days.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final day = _days[index];
              final int dayNumber = index + 1;
              final bool selected = _selectedDay == dayNumber;

              return _buildDayTab(
                day: day,
                dayNumber: dayNumber,
                selected: selected,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDayTab({
    required Map<String, dynamic> day,
    required int dayNumber,
    required bool selected,
  }) {
    return GestureDetector(
      onTap: () => _selectDay(dayNumber),
      child: Container(
        width: 185,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primaryContainer
              : AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(AppRadius.large),
          border: Border.all(
            color: selected
                ? AppColors.primary.withOpacity(0.3)
                : AppColors.outlineVariant.withOpacity(0.4),
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  day['day'],
                  style: AppTextStyles.labelSmall.copyWith(
                    color: selected
                        ? AppColors.white.withOpacity(0.8)
                        : AppColors.secondary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.0,
                  ),
                ),
                const Spacer(),
                if (day['status'] == 'star')
                  Icon(
                    Icons.star,
                    size: 13,
                    color: selected ? AppColors.white : AppColors.primary,
                  )
                else if (day['status'] == 'packed')
                  const Icon(
                    Icons.check_circle,
                    size: 13,
                    color: Color(0xFF287A52),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              day['title'],
              style: AppTextStyles.bodySmall.copyWith(
                color: selected ? AppColors.white : AppColors.primary,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // FEATURED LOOK
  // ============================================================

  Widget _buildFeaturedLook() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(AppRadius.medium),
              ),
            ),
            const SizedBox(width: 7),
            Text(
              'Featured Daily Look',
              style: AppTextStyles.headlineSmall.copyWith(
                color: AppColors.primary,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(AppRadius.small),
              ),
              child: Text(
                'ACTIVE VIEW',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.secondary,
                  letterSpacing: 1.0,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(AppRadius.large),
            border: Border.all(
              color: AppColors.outlineVariant.withOpacity(0.6),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(children: [_buildLookHero(), _buildLookDetails()]),
        ),
      ],
    );
  }

  Widget _buildLookHero() {
    return SizedBox(
      width: double.infinity,
      height: 288,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            'https://lh3.googleusercontent.com/aida/AEtjO1W0SRYUmnwFrTh6FxKxxCT__fpF-4vhi02_J27rjjAUsZln3Ffs3gcBAT43iAlrKclmO-KQq3WgvBGPa5LJveOzX9BLtrpzV0oXs2BoRD8TzhD-gmYAvS4o1Y6UAznBPdRwOhroKguV62mnjbsWEVZKbJ0O3MUba9402QXkQoOaxVIbOPQ3AQ6UFXXgPaoJwJPuHag-sLghKVZKAnKG_jQ3LamprM3YcNSPqN-dHNQtGbpu9U4LY',
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) {
              return Container(
                color: AppColors.surfaceContainerLow,
                child: const Center(
                  child: Icon(
                    Icons.checkroom_outlined,
                    size: 64,
                    color: AppColors.outline,
                  ),
                ),
              );
            },
          ),

          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    AppColors.primary.withOpacity(0.88),
                  ],
                ),
              ),
            ),
          ),

          Positioned(
            top: 12,
            left: 12,
            right: 12,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.background.withOpacity(0.92),
                    borderRadius: BorderRadius.circular(AppRadius.medium),
                  ),
                  child: Text(
                    'DAY ${_selectedDay.toString().padLeft(2, '0')} • '
                    '${_days[_selectedDay - 1]['title']}',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
                const Spacer(),
                _buildHeroAction(
                  icon: _isSaved ? Icons.bookmark : Icons.bookmark_border,
                  onTap: _toggleSave,
                  selected: _isSaved,
                ),
                const SizedBox(width: 6),
                _buildHeroAction(
                  icon: Icons.event_outlined,
                  onTap: () {
                    _showMessage('Added Day $_selectedDay to Apple Calendar');
                  },
                ),
              ],
            ),
          ),

          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(AppRadius.small),
                      ),
                      child: Text(
                        'MEDITERRANEAN TRANSIT',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: AppColors.white,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '24°C Sunny',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.white.withOpacity(0.85),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'The Riviera Transit Ensemble',
                  style: AppTextStyles.headlineMedium.copyWith(
                    color: AppColors.white,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroAction({
    required IconData icon,
    required VoidCallback onTap,
    bool selected = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary
              : AppColors.background.withOpacity(0.85),
          borderRadius: BorderRadius.circular(AppRadius.medium),
        ),
        child: Icon(
          icon,
          size: 17,
          color: selected ? AppColors.white : AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildLookDetails() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            'Breathable linen tailored layer paired with relaxed '
            'trousers and slip-ons for transit-to-dinner effortless '
            'elegance.',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.onSurfaceVariant,
              height: 1.55,
            ),
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Text(
                'GARMENT PIECES (4)',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.secondary,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.0,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: _quickReroll,
                child: Text(
                  'QUICK RE-ROLL',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.primary,
                    decoration: TextDecoration.underline,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 2.7,
            children: [
              _buildGarmentPiece(
                icon: Icons.checkroom_outlined,
                category: 'TOP',
                name: 'Linen Shirt (Ivory)',
              ),
              _buildGarmentPiece(
                icon: Icons.straighten,
                category: 'BOTTOM',
                name: 'Pleated Trouser (Ecru)',
              ),
              _buildGarmentPiece(
                icon: Icons.directions_walk_outlined,
                category: 'FOOTWEAR',
                name: 'Leather Slide (Tan)',
              ),
              _buildGarmentPiece(
                icon: Icons.shopping_bag_outlined,
                category: 'ACCESSORY',
                name: 'Raffia Tote & Hat',
              ),
            ],
          ),

          const SizedBox(height: 14),

          Container(
            height: 1,
            color: AppColors.outlineVariant.withOpacity(0.4),
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _swapItem,
                  icon: const Icon(Icons.swap_horiz, size: 15),
                  label: Text(
                    'SWAP ITEM',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.primary,
                      letterSpacing: 0.7,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: BorderSide(
                      color: AppColors.outlineVariant.withOpacity(0.7),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.medium),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _scheduleOutfit,
                  icon: const Icon(Icons.calendar_month_outlined, size: 15),
                  label: Text(
                    'SCHEDULE',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.white,
                      letterSpacing: 0.7,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.medium),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGarmentPiece({
    required IconData icon,
    required String category,
    required String name,
  }) {
    return Container(
      padding: const EdgeInsets.all(7),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(AppRadius.medium),
            ),
            child: Icon(icon, size: 17, color: AppColors.primary),
          ),
          const SizedBox(width: 7),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.secondary,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  name,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ALL DAYS ITINERARY
  // ============================================================

  Widget _buildAllDaysItinerary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: AppColors.secondary,
                borderRadius: BorderRadius.circular(AppRadius.medium),
              ),
            ),
            const SizedBox(width: 7),
            Text(
              'All 7 Days Itinerary',
              style: AppTextStyles.headlineSmall.copyWith(
                color: AppColors.primary,
              ),
            ),
            const Spacer(),
            Text(
              'Complete Plan',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.secondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        _buildItineraryCard(
          day: 'DAY 02',
          title: 'Morning Cafe & Historical Walk',
          description: 'Linen sleeveless blouse + pleated shorts',
          packed: true,
          imageUrl:
              'https://lh3.googleusercontent.com/aida/AEtjO1VylXnNqX5zTSGUUcFAp5sMP37sRQxbPnMgWTS5hPiTP91gu0ymrsA-1g1yCl61PZU-4IHd7BEEinpoPAeOcBUKYVD45_JEqgR6gA0DPyU-KFcBWKldfCKSYsxmni2qRIkW6-VadkbFgr_RfBxVfRqSkSnrRCKq-y8Xcq0YDJXTEeu53jnvC708buddQbQ5m47pm4s1kKn7w03tdFiEMXbs9_6qk1seBSuIhkWVcQJn1bPgYw09qESGV3I',
        ),

        const SizedBox(height: 10),

        _buildItineraryCard(
          day: 'DAY 03',
          title: 'Riviera Resort & Lounge',
          description: 'Silk-cotton button down + relaxed trousers',
          packed: true,
          imageUrl:
              'https://lh3.googleusercontent.com/aida/AEtjO1UUVLNY_pq41iJ9-AXLmQSLUf1uTqjgN6CpESmfhX1EkA--G4N02mfiuyYR2ip8FH8rrcjCTH0LxN-31N8V_nQ1Y9o-Xdek5yuKQ0TLFTl0E_BtN8WgB7nVGCq5btq4FFdvunb1jZRTflzulZyDOQbnvKFEpTw5n9Zff848AORC34MOve-OKTSHtPRUVC-Y15uZBC3Vvvkqb96ueQMIevsX1v6gotbrwL8uc2SnEYSlgWy3y0GiSNpDd3w',
        ),

        const SizedBox(height: 10),

        _buildItineraryCard(
          day: 'DAY 04',
          title: 'Sunset Dinner by the Coast',
          description: 'Silk slip dress + lightweight cashmere wrap',
          packed: true,
          imageUrl:
              'https://lh3.googleusercontent.com/aida-public/AB6AXuBqoPNqOZEqbyCDa_TvnpeeQOjiIRTgZvGJHwb-Mq5FcO8aRwXosa6_aAB2SekfWxEpNCeXprruEQDop_bQkc55Z7sCAOwpglvjSY_WjPiT_-PEzZeUzmwH9E_KlxZyPdBA-rKDt1pWKb2-K13pHEt-WTfyLVBhmLy55wP09qKmf1rFCigK-qBdOil9d2lnfch0k_O7_nwAILcl9PZylroWTJaPrNWWQYzn3BzYATrxPIRlWMg6R61-',
        ),

        const SizedBox(height: 10),

        _buildPreviewAccordion(),
      ],
    );
  }

  Widget _buildItineraryCard({
    required String day,
    required String title,
    required String description,
    required bool packed,
    required String imageUrl,
  }) {
    return GestureDetector(
      onTap: () {
        final dayNumber =
            int.tryParse(day.replaceAll(RegExp(r'[^0-9]'), '')) ?? 1;
        _selectDay(dayNumber);
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(AppRadius.large),
          border: Border.all(color: AppColors.outlineVariant.withOpacity(0.6)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.medium),
              child: Image.network(
                imageUrl,
                width: 56,
                height: 56,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) {
                  return Container(
                    width: 56,
                    height: 56,
                    color: AppColors.surfaceContainerLow,
                    child: const Icon(
                      Icons.checkroom_outlined,
                      size: 24,
                      color: AppColors.outline,
                    ),
                  );
                },
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        day,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.secondary,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.0,
                        ),
                      ),
                      if (packed) ...[
                        const SizedBox(width: 7),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE9F6EF),
                            borderRadius: BorderRadius.circular(
                              AppRadius.small,
                            ),
                            border: Border.all(color: const Color(0xFFB9DFC8)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.check,
                                size: 10,
                                color: Color(0xFF287A52),
                              ),
                              const SizedBox(width: 2),
                              Text(
                                'PACKED',
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: const Color(0xFF287A52),
                                  letterSpacing: 0,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    title,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            const SizedBox(width: 6),

            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(AppRadius.medium),
              ),
              child: const Icon(
                Icons.chevron_right,
                size: 18,
                color: AppColors.secondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewAccordion() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.large),
        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.6)),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                _showDays5To7 = !_showDays5To7;
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Text(
                          'Day 05 – Day 07 Preview',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 7),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(
                              AppRadius.medium,
                            ),
                            border: Border.all(
                              color: AppColors.outlineVariant.withOpacity(0.6),
                            ),
                          ),
                          child: Text(
                            '3 LOOKS',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.secondary,
                              letterSpacing: 0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: _showDays5To7 ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(
                      Icons.expand_more,
                      size: 18,
                      color: AppColors.secondary,
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (_showDays5To7)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Column(
                children: [
                  _buildPreviewDay(
                    'DAY 05 • ART GALLERY',
                    'Pleated Ecru Trouser + Ribbed Silk Tank',
                    'Rewear #2',
                  ),
                  _buildPreviewDay(
                    'DAY 06 • WINE & DINE',
                    'Silk Popover + Wrap Skirt',
                    'Coordinated',
                  ),
                  _buildPreviewDay(
                    'DAY 07 • MARKET & FLY HOME',
                    'Linen Shirt (Ivory) + Knit Loungewear',
                    'Easy Transit',
                    isLast: true,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPreviewDay(
    String day,
    String outfit,
    String label, {
    bool isLast = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 9),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(
                bottom: BorderSide(
                  color: AppColors.outlineVariant.withOpacity(0.3),
                ),
              ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  day,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  outfit,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.secondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PACKING CAPSULE
  // ============================================================

  Widget _buildPackingCapsule() {
    final int packedCount = _packedItems.where((item) => item).length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.large),
        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.7)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'LUGGAGE MANIFEST',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.secondary,
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Luggage Capsule: 12 Pieces Total',
                      style: AppTextStyles.headlineSmall.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.primaryDim.withOpacity(0.45),
                  borderRadius: BorderRadius.circular(AppRadius.medium),
                ),
                child: Text(
                  '100% COORDINATED',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.primary,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _buildManifestChip('4 Tops'),
              _buildManifestChip('3 Bottoms'),
              _buildManifestChip('1 Dress'),
              _buildManifestChip('2 Shoes'),
              _buildManifestChip('2 Accessories'),
            ],
          ),

          const SizedBox(height: 12),

          Container(
            height: 1,
            color: AppColors.outlineVariant.withOpacity(0.4),
          ),

          const SizedBox(height: 12),

          _buildChecklistItem(
            index: 0,
            name: 'Linen Oversized Ivory Shirt',
            usage: 'Day 1, Day 4',
          ),
          _buildChecklistItem(
            index: 1,
            name: 'Silk Button-Up Popover',
            usage: 'Day 3, Day 6',
          ),
          _buildChecklistItem(
            index: 2,
            name: 'Tailored Pleated Trouser',
            usage: 'Day 1, Day 5',
          ),
          _buildChecklistItem(
            index: 3,
            name: 'Resort Linen Shorts',
            usage: 'Day 2',
          ),
          _buildChecklistItem(
            index: 4,
            name: 'Evening Silk Slip Dress',
            usage: 'Day 4',
          ),
          _buildChecklistItem(
            index: 5,
            name: 'Leather Slides & Espadrilles',
            usage: '2 Pairs',
          ),

          const SizedBox(height: 10),

          Text(
            '$packedCount of ${_packedItems.length} '
            'packing items checked',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.secondary),
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _exportChecklist,
                  icon: const Icon(Icons.luggage_outlined, size: 16),
                  label: Text(
                    'EXPORT PACKING CHECKLIST',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.white,
                      letterSpacing: 0.7,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.large),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _shareItinerary,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(AppRadius.large),
                    border: Border.all(
                      color: AppColors.outlineVariant.withOpacity(0.6),
                    ),
                  ),
                  child: const Icon(
                    Icons.share_outlined,
                    size: 18,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildManifestChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppRadius.small),
        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.6)),
      ),
      child: Text(
        text,
        style: AppTextStyles.labelSmall.copyWith(
          color: AppColors.secondary,
          letterSpacing: 0,
        ),
      ),
    );
  }

  Widget _buildChecklistItem({
    required int index,
    required String name,
    required String usage,
  }) {
    final bool checked = _packedItems[index];

    return GestureDetector(
      onTap: () => _togglePacked(index),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(AppRadius.medium),
          border: Border.all(color: AppColors.outlineVariant.withOpacity(0.4)),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: checked
                    ? AppColors.primary
                    : AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(AppRadius.small),
                border: checked
                    ? null
                    : Border.all(color: AppColors.outlineVariant),
              ),
              child: checked
                  ? const Icon(Icons.check, size: 14, color: AppColors.white)
                  : null,
            ),

            const SizedBox(width: 10),

            Expanded(
              child: Text(
                name,
                style: AppTextStyles.bodySmall.copyWith(
                  color: checked ? AppColors.onSurface : AppColors.secondary,
                  fontWeight: FontWeight.w600,
                  decoration: checked ? null : TextDecoration.none,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            const SizedBox(width: 8),

            Text(
              usage,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.secondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
