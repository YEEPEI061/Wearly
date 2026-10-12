import 'package:flutter/material.dart';
import 'package:frontend/pages/record_outfit_page.dart';
import 'package:frontend/theme/app_colors.dart';
import 'package:frontend/theme/app_text_styles.dart';
import 'package:frontend/theme/app_radius.dart';
import 'package:frontend/widgets/app_header.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => HistoryPageState();
}

class HistoryPageState extends State<HistoryPage> {
  // ============================================================
  // STATE
  // ============================================================

  late DateTime _selectedDate;
  late DateTime _displayedMonth;

  late PageController _weekPageController;

  static const int _weekPageBase = 500;

  @override
  void initState() {
    super.initState();

    final now = DateTime.now();

    _selectedDate = DateTime(now.year, now.month, now.day);

    _displayedMonth = DateTime(now.year, now.month, 1);

    _weekPageController = PageController(initialPage: _weekPageBase);
  }

  String _monthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return months[month - 1];
  }

  String _shortMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return months[month - 1];
  }

  String _weekdayLetter(int weekday) {
    const weekdays = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return weekdays[weekday - 1];
  }

  DateTime _startOfWeek(DateTime date) {
    return DateTime(date.year, date.month, date.day - (date.weekday - 1));
  }

  List<DateTime> _getWeekDays(DateTime date) {
    final start = _startOfWeek(date);

    return List.generate(7, (index) => start.add(Duration(days: index)));
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();

    return _isSameDay(date, now);
  }

  int _getWeekNumber(DateTime date) {
    final thursday = date.add(Duration(days: 4 - date.weekday));

    final firstThursday = DateTime(thursday.year, 1, 4);

    final firstWeekThursday = firstThursday.add(
      Duration(days: 4 - firstThursday.weekday),
    );

    return 1 + thursday.difference(firstWeekThursday).inDays ~/ 7;
  }

  // void _goToPreviousWeek() {
  //   _weekPageController.previousPage(
  //     duration: const Duration(milliseconds: 450),
  //     curve: Curves.easeOutCubic,
  //   );
  // }

  // void _goToNextWeek() {
  //   _weekPageController.nextPage(
  //     duration: const Duration(milliseconds: 450),
  //     curve: Curves.easeOutCubic,
  //   );
  // }

  @override
  void dispose() {
    _weekPageController.dispose();
    super.dispose();
  }

  void resetToToday() {
    final now = DateTime.now();

    setState(() {
      _selectedDate = DateTime(now.year, now.month, now.day);

      _displayedMonth = DateTime(now.year, now.month, 1);
    });

    if (_weekPageController.hasClients) {
      _weekPageController.jumpToPage(_weekPageBase);
    }
  }

  final List<_HistoryEntry> _historyEntries = [
    _HistoryEntry(
      day: '16',
      month: 'Oct',
      weekday: 'Wed',
      title: 'The Autumnal Tailor',
      description: 'Camel Trench • Cashmere Knit • Loafers',
      image:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuAM14j4pFi7nXvWpwZw76_6jegeUAaeH8SMSfQSCtDSGeNhEeiGcJsTBF81Aeb9BVkzfGoaPrYVcJ7Q4Rz1camGa2IlxFH_CxKAeA9swWzOmZ_pm-V0Ukwnm9LgrrJubr8R8O_VtxrmZFjnqqTrGoe7dq0NTAn4JzlRp6_pRajQwXf0r0EPQe0l2tkKyZCeIpEFJOLtJCfCzqV8oQktJ6wEvg9BmrVOurCIlBmH3UW9BLzJQOWTu7sS',
      layout: 1,
    ),
    _HistoryEntry(
      day: '15',
      month: 'Oct',
      weekday: 'Tue',
      title: 'Monochrome Tailoring',
      description: 'Charcoal Blazer • Poplin Shirt • Pleated Trousers',
      images: [
        'https://lh3.googleusercontent.com/aida-public/AB6AXuBAJZfN_zNJEqAlGhZ_R2tQ6fynIxIhqGZpx9aH1xsAC-RT2rwoSGY4IejN_AZY1x-FkcWFXDncG1up5ecfypxPboYdituTw2-djjkjgi2dQk5H42JBFGT6SPumGkludmT-6Kj6YeJ8wnjXwZjJcHl1aRaRdcDqc0mnFNogOMwQ6ruJY9Jl05_4JCUPZBWeP1hS6ZG8jo4StYdWzPPdzgj7MAB8PVrBx0DWjg3Kv8vvq1U-gwmtfB_Q',
        'https://lh3.googleusercontent.com/aida-public/AB6AXuA7hylN80VHoNIKi1U2ytL-9KTlL6fWnYHqd8LefNyqrO8ZsPIP798XIr5uyhgN8lkIWNC0-KUFDSDQClHXdepgzyQVMJT_QDJ1n8cnwaaR2hs4wV27u1k5QJA_UemvBZ2TgHX2vIQOZl5pbR1SkVbN1AfmCh_wen46x5ZBAW5ETROB12J9gJUu-b5Be2ulh5R7gcAlJKocqt4GyDL5CfFDIwO3BAVj1toIehBCNypxobWHcFisfJ75',
      ],
      layout: 2,
    ),
    _HistoryEntry(
      day: '14',
      month: 'Oct',
      weekday: 'Mon',
      title: 'Weekend Casual',
      description: 'Relaxed Denim • Graphic Tee • Canvas Trainers',
      images: [
        'https://lh3.googleusercontent.com/aida-public/AB6AXuCOUcjMwu0NaPg7adnhpnQNs64u8Rbu5KFftoHe9rvKmWpjPArnMcQ7MZUhnDh5xMBNDeuMI1cMJwugQkyvFw_2N2Y3ncCXjW2PVZgaoEkkk7w2A2VfEwKNFIOwk3xe6HvAg97xisBIwhbJkwULwsyWAat7a5Fjt_VTV75PlrU7icTJN5b1yFKT8pC2_97WAvv_UeCsxIZLFcpO1OZgK0fn8PQdpqDYE0Av_TGdmDfQsMsNw8AGP9qS',
        'https://lh3.googleusercontent.com/aida-public/AB6AXuDvibRjkDnxm3BYu33x9OyK2rpV-ddoMVIDeScU5mk2YLdxJj9L-IU--qDdWW8CJZmYREkeocaGhCb3qnxlj4iT_uU3V9Cf1wzWNuh_4S3_nUMoqGlBYw5AKbLUUw7O6cIihEkfmkCfmRZb86u7Yd2mik3Q8J_ebHbfynZXFyLG8rKst34loxBDz7P0CWeJ7rBspaPv1dqgIh5ZJVDqZMijL-pLPI4R0z0pt7C6f9ZPJf9ZLZUqL3yS',
        'https://lh3.googleusercontent.com/aida-public/AB6AXuCMGDnRbNYm8Dg0hkzTRl5qMnNY6lJcqStvdJyjVMThTkjuysi6ToNKCHho6cS9lbsF7zr1iF3w1n873gxwh9Mj9eIkEMCwLQLzWJA16NVJbczG2LDnaV6HIMIcCYaCEukMbYDpzNfF4SnnLqC-GiECHyQh_GqSs69lkoxjRdlgnFnNn8MS9a5KM4HQoH-Vb4m0XmuxvCflGeZzp6SV-q7SbKf77qfMW02ipjH010bAXXhFG3aNSTD0',
      ],
      layout: 3,
    ),
  ];

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
                  title: 'OUTFIT HISTORY',
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
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 38),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      const SizedBox(height: 4),
                      _buildMonthHeader(),
                      const SizedBox(height: 16),
                      _buildRotationCard(),
                      const SizedBox(height: 24),
                      _buildWeekSelector(),
                      const SizedBox(height: 24),
                      _buildTimeline(),
                      const SizedBox(height: 24),
                      _buildLogPrompt(),
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
  // MONTH HEADER
  // ============================================================

  Widget _buildMonthHeader() {
    final monthTitle = '${_monthName(_displayedMonth.month)} Diary';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'CHRONICLE',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.onSurfaceVariant,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                monthTitle,
                style: AppTextStyles.headlineMedium.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),

        Row(
          children: [
            _buildMonthButton(
              icon: Icons.chevron_left,
              isPrimary: false,
              onTap: () {
                setState(() {
                  _displayedMonth = DateTime(
                    _displayedMonth.year,
                    _displayedMonth.month - 1,
                    1,
                  );

                  _selectedDate = DateTime(
                    _displayedMonth.year,
                    _displayedMonth.month,
                    1,
                  );
                });
              },
            ),

            const SizedBox(width: 8),

            _buildMonthButton(
              icon: Icons.chevron_right,
              isPrimary: true,
              onTap: () {
                setState(() {
                  _displayedMonth = DateTime(
                    _displayedMonth.year,
                    _displayedMonth.month + 1,
                    1,
                  );

                  _selectedDate = DateTime(
                    _displayedMonth.year,
                    _displayedMonth.month,
                    1,
                  );
                });
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMonthButton({
    required IconData icon,
    required bool isPrimary,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isPrimary
              ? AppColors.primary
              : AppColors.surfaceContainerMedium,
          borderRadius: BorderRadius.circular(AppRadius.small),
        ),
        child: Icon(
          icon,
          size: 20,
          color: isPrimary ? AppColors.white : AppColors.primary,
        ),
      ),
    );
  }

  // ============================================================
  // ROTATION RATE
  // ============================================================

  Widget _buildRotationCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.small),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'ROTATION RATE',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.onSurfaceVariant,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              const Icon(Icons.cached, size: 20, color: AppColors.primary),
            ],
          ),

          const SizedBox(height: 16),

          Text(
            '84%',
            style: AppTextStyles.headlineMedium.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 2),

          Text(
            'Active wardrobe utilization',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // WEEK SELECTOR
  // ============================================================

  Widget _buildWeekSelector() {
    final days = _getWeekDays(_selectedDate);

    final weekStart = days.first;
    final weekEnd = days.last;

    final weekNumber = _getWeekNumber(_selectedDate);

    String rangeText;

    if (weekStart.month == weekEnd.month) {
      rangeText =
          '${_shortMonthName(weekStart.month)} '
          '${weekStart.day} - ${weekEnd.day}';
    } else {
      rangeText =
          '${_shortMonthName(weekStart.month)} ${weekStart.day} - '
          '${_shortMonthName(weekEnd.month)} ${weekEnd.day}';
    }

    return Container(
      height: 142,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.small),
      ),
      child: Column(
        children: [
          // ======================================================
          // FIXED WEEK HEADER
          // ======================================================
          Row(
            children: [
              Expanded(
                child: Text(
                  'WEEK $weekNumber CURATION',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.primary,
                    letterSpacing: 1.1,
                  ),
                ),
              ),

              Text(
                rangeText,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),

          const SizedBox(height: 2),

          // ======================================================
          // SWIPEABLE DATE ROW ONLY
          // ======================================================
          SizedBox(
            height: 90,
            child: PageView.builder(
              controller: _weekPageController,
              itemCount: 1000,
              physics: const BouncingScrollPhysics(),
              onPageChanged: (page) {
                final difference = page - _weekPageBase;

                if (difference == 0) {
                  return;
                }

                setState(() {
                  _selectedDate = _selectedDate.add(
                    Duration(days: difference * 7),
                  );

                  _displayedMonth = DateTime(
                    _selectedDate.year,
                    _selectedDate.month,
                    1,
                  );
                });

                _weekPageController.jumpToPage(_weekPageBase);
              },
              itemBuilder: (context, index) {
                return _buildWeekDateRow(days);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekDateRow(List<DateTime> days) {
    return Align(
      // alignment: Alignment.topCenter,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: days.map((date) {
          final selected = _isSameDay(date, _selectedDate);

          final today = _isToday(date);

          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedDate = date;

                  _displayedMonth = DateTime(date.year, date.month, 1);
                });
              },
              child: Container(
                height: 66,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                padding: const EdgeInsets.only(top: 6, bottom: 0),
                decoration: BoxDecoration(
                  color: selected ? AppColors.primary : AppColors.background,
                  borderRadius: BorderRadius.circular(AppRadius.small),
                  border: today && !selected
                      ? Border.all(color: AppColors.primary, width: 1)
                      : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      _weekdayLetter(date.weekday),
                      style: AppTextStyles.labelSmall.copyWith(
                        color: selected
                            ? AppColors.white.withOpacity(0.7)
                            : AppColors.onSurfaceVariant,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      '${date.day}',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: selected ? AppColors.white : AppColors.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 2),

                    SizedBox(
                      // height: 5,
                      child: today
                          ? Container(
                              width: 4,
                              height: 4,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: selected
                                    ? AppColors.white
                                    : AppColors.primary,
                              ),
                            )
                          : null,
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ============================================================
  // TIMELINE
  // ============================================================

  Widget _buildTimeline() {
    return Column(
      children: _historyEntries.asMap().entries.map((entry) {
        final index = entry.key;
        final history = entry.value;

        return _buildTimelineEntry(
          history,
          isFirst: index == 0,
          isLast: index == _historyEntries.length - 1,
        );
      }).toList(),
    );
  }

  Widget _buildTimelineEntry(
    _HistoryEntry history, {
    required bool isFirst,
    required bool isLast,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ======================================================
          // DATE
          // ======================================================
          SizedBox(
            width: 56,
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${history.day} ${history.month}',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    history.weekday.toUpperCase(),
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 12),

          // ======================================================
          // TIMELINE LINE
          // ======================================================
          SizedBox(
            width: 10,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                if (!isLast)
                  Positioned(
                    top: 8,
                    bottom: -32,
                    left: 4,
                    child: Container(
                      width: 2,
                      color: AppColors.surfaceContainerHigh,
                    ),
                  ),
                Positioned(
                  top: 6,
                  left: 0,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isFirst
                          ? AppColors.primary
                          : AppColors.surfaceContainerHigh,
                      border: Border.all(color: AppColors.background, width: 3),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // ======================================================
          // OUTFIT CONTENT
          // ======================================================
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHistoryImages(history),

                  const SizedBox(height: 8),

                  Text(
                    history.title,
                    style: AppTextStyles.headlineSmall.copyWith(
                      color: AppColors.primary,
                    ),
                  ),

                  const SizedBox(height: 2),

                  Text(
                    history.description,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.onSurfaceVariant,
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

  // ============================================================
  // HISTORY IMAGES
  // ============================================================

  Widget _buildHistoryImages(_HistoryEntry history) {
    if (history.layout == 1) {
      return _buildSingleImage(history);
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.large),
      ),
      child: Row(
        children: history.images!.map((image) {
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.all(2),
              child: AspectRatio(
                aspectRatio: 1,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.small),
                  child: _buildNetworkImage(image),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSingleImage(_HistoryEntry history) {
    return Stack(
      children: [
        AspectRatio(
          aspectRatio: 4 / 3,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.large),
            child: _buildNetworkImage(history.image!),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // NETWORK IMAGE
  // ============================================================

  Widget _buildNetworkImage(String url) {
    return Image.network(
      url,
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) {
        return Container(
          color: AppColors.surfaceContainerMedium,
          child: const Center(
            child: Icon(
              Icons.checkroom_outlined,
              size: 42,
              color: AppColors.outline,
            ),
          ),
        );
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) {
          return child;
        }

        return Container(
          color: AppColors.surfaceContainerLow,
          child: const Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 1.5,
                color: AppColors.primary,
              ),
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // LOG TODAY'S LOOK
  // ============================================================

  Widget _buildLogPrompt() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerMedium,
        borderRadius: BorderRadius.circular(AppRadius.small),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(AppRadius.small),
            ),
            child: const Icon(
              Icons.add_a_photo_outlined,
              size: 20,
              color: AppColors.white,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Log Today's Look",
                  style: AppTextStyles.headlineSmall.copyWith(
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Capture or select items worn',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          GestureDetector(
            onTap: _recordLook,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(AppRadius.small),
              ),
              child: Text(
                'RECORD',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.white,
                  letterSpacing: 1.1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // RECORD LOOK
  // ============================================================

  void _recordLook() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RecordOutfitPage()),
    );
  }
}

// ================================================================
// HISTORY MODEL
// ================================================================

class _HistoryEntry {
  final String day;
  final String month;
  final String weekday;
  final String title;
  final String description;

  final String? image;
  final List<String>? images;

  final int layout;

  const _HistoryEntry({
    required this.day,
    required this.month,
    required this.weekday,
    required this.title,
    required this.description,
    this.image,
    this.images,
    required this.layout,
  });
}
