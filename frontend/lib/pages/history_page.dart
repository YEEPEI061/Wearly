import 'package:flutter/material.dart';
import 'package:frontend/pages/record_outfit_page.dart';
import 'package:frontend/theme/app_colors.dart';
import 'package:frontend/theme/app_text_styles.dart';
import 'package:frontend/theme/app_radius.dart';
import 'package:frontend/widgets/app_header.dart';
import 'package:frontend/services/api_service.dart';

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

  List<Map<String, dynamic>> _historyEntries = [];

  int _rotationRate = 0;

  bool _isLoadingHistory = false;

  String? _historyError;

  int _monthAnimationDirection = 1;
  int _timelineAnimationKey = 0;

  @override
  void initState() {
    super.initState();

    final now = DateTime.now();

    _selectedDate = DateTime(now.year, now.month, now.day);

    _displayedMonth = DateTime(now.year, now.month, 1);

    _loadHistory();
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

  String _weekdayName(int weekday) {
    const weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

    return weekdays[weekday - 1].toUpperCase();
  }

  String _buildHistoryDescription(Map<String, dynamic> history) {
    final notes = history['notes']?.toString().trim() ?? '';

    if (notes.isNotEmpty) {
      return notes
          .split(RegExp(r'\r?\n+'))
          .where((line) => line.trim().isNotEmpty)
          .join(' • ');
    }

    return '';
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

  Future<void> _loadHistory() async {
    setState(() {
      _isLoadingHistory = true;
      _historyError = null;
    });

    try {
      final data = await ApiService.getOutfitHistory(
        year: _displayedMonth.year,
        month: _displayedMonth.month,
      );

      if (!mounted) return;

      setState(() {
        _rotationRate = (data['rotation_rate'] as num?)?.toInt() ?? 0;

        _historyEntries = List<Map<String, dynamic>>.from(
          data['history'] ?? [],
        );

        _isLoadingHistory = false;

        // Trigger the timeline transition
        _timelineAnimationKey++;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoadingHistory = false;
        _historyError = e.toString().replaceFirst('Exception: ', '');
      });
    }
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
    super.dispose();
  }

  void resetToToday() {
    final now = DateTime.now();

    setState(() {
      _selectedDate = DateTime(now.year, now.month, now.day);

      _displayedMonth = DateTime(now.year, now.month, 1);
    });

    _loadHistory();
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
                      _buildAnimatedTimeline(),
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

  // ============================================================
  // MONTH HEADER
  // ============================================================

  Widget _buildMonthHeader() {
    final monthTitle = '${_monthName(_displayedMonth.month)} Diary';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Align(
            alignment: Alignment.centerLeft,
            child: ClipRect(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (child, animation) {
                  final isEntering = child.key == ValueKey(monthTitle);

                  final beginOffset = isEntering
                      ? Offset(0.25 * _monthAnimationDirection, 0)
                      : Offset(-0.25 * _monthAnimationDirection, 0);

                  final slideAnimation = Tween<Offset>(
                    begin: beginOffset,
                    end: Offset.zero,
                  ).animate(animation);

                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: slideAnimation,
                      child: child,
                    ),
                  );
                },
                child: Column(
                  key: ValueKey(monthTitle),
                  mainAxisSize: MainAxisSize.min,
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
            ),
          ),
        ),

        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildMonthButton(
              icon: Icons.chevron_left,
              isPrimary: false,
              onTap: () {
                _monthAnimationDirection = -1;

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

                _loadHistory();
              },
            ),

            const SizedBox(width: 8),

            _buildMonthButton(
              icon: Icons.chevron_right,
              isPrimary: true,
              onTap: () {
                _monthAnimationDirection = 1;

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

                _loadHistory();
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
            '$_rotationRate%',
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

          SizedBox(height: 90, child: _buildWeekDateRow(days)),
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

  String _buildHistoryTitle(List<Map<String, dynamic>> items) {
    final colors = <String>[];

    for (final item in items) {
      final name = item['name']?.toString().trim() ?? '';

      if (name.isEmpty) continue;

      final lowerName = name.toLowerCase();

      if (lowerName.contains('black')) {
        colors.add('Black');
      } else if (lowerName.contains('dark gray') ||
          lowerName.contains('dark grey')) {
        colors.add('Gray');
      } else if (lowerName.contains('light gray') ||
          lowerName.contains('light grey')) {
        colors.add('Gray');
      } else if (lowerName.contains('white')) {
        colors.add('White');
      } else if (lowerName.contains('beige')) {
        colors.add('Beige');
      } else if (lowerName.contains('brown')) {
        colors.add('Brown');
      } else if (lowerName.contains('navy')) {
        colors.add('Navy');
      } else if (lowerName.contains('blue')) {
        colors.add('Blue');
      } else if (lowerName.contains('green')) {
        colors.add('Green');
      } else if (lowerName.contains('red')) {
        colors.add('Red');
      } else if (lowerName.contains('pink')) {
        colors.add('Pink');
      } else if (lowerName.contains('purple')) {
        colors.add('Purple');
      } else if (lowerName.contains('orange')) {
        colors.add('Orange');
      } else if (lowerName.contains('yellow')) {
        colors.add('Yellow');
      }
    }

    final uniqueColors = colors.toSet().toList();

    if (uniqueColors.isEmpty) {
      return 'Outfit';
    }

    if (uniqueColors.length == 1) {
      return '${uniqueColors.first} Outfit';
    }

    if (uniqueColors.length == 2) {
      return '${uniqueColors[0]} & ${uniqueColors[1]} Outfit';
    }

    return '${uniqueColors.take(3).join(', ')} Outfit';
  }

  // ============================================================
  // TIMELINE
  // ============================================================

  Widget _buildAnimatedTimeline() {
    return ClipRect(
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 420),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) {
          final isEntering = child.key == ValueKey(_timelineAnimationKey);

          final beginOffset = isEntering
              ? Offset(0.10 * _monthAnimationDirection, 0)
              : Offset(-0.10 * _monthAnimationDirection, 0);

          final slideAnimation = Tween<Offset>(
            begin: beginOffset,
            end: Offset.zero,
          ).animate(animation);

          return FadeTransition(
            opacity: animation,
            child: SlideTransition(position: slideAnimation, child: child),
          );
        },
        child: KeyedSubtree(
          key: ValueKey(_timelineAnimationKey),
          child: _buildTimeline(),
        ),
      ),
    );
  }

  Widget _buildTimeline() {
    if (_isLoadingHistory) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: CircularProgressIndicator(
            strokeWidth: 1.5,
            color: AppColors.primary,
          ),
        ),
      );
    }

    if (_historyError != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 30),
        child: Center(
          child: Text(
            _historyError!,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (_historyEntries.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(AppRadius.small),
        ),
        child: Column(
          children: [
            const Icon(
              Icons.checkroom_outlined,
              size: 32,
              color: AppColors.outline,
            ),
            const SizedBox(height: 12),
            Text(
              'NO OUTFITS RECORDED',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.primary,
                letterSpacing: 1.2,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Your outfit diary is empty for this month.',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

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
    Map<String, dynamic> history, {
    required bool isFirst,
    required bool isLast,
  }) {
    final wornDate = DateTime.parse(history['worn_date'].toString());

    final items = List<Map<String, dynamic>>.from(history['items'] ?? []);

    final title = _buildHistoryTitle(items);

    final description = _buildHistoryDescription(history);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 56,
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${wornDate.day} ${_shortMonthName(wornDate.month)}',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _weekdayName(wornDate.weekday),
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 12),

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

          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHistoryImages(items),

                  const SizedBox(height: 8),

                  Text(
                    title,
                    style: AppTextStyles.headlineSmall.copyWith(
                      color: AppColors.primary,
                    ),
                  ),

                  const SizedBox(height: 2),

                  Text(
                    description,
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

  Widget _buildHistoryImages(List<Map<String, dynamic>> items) {
    if (items.isEmpty) {
      return _buildEmptyHistoryImage();
    }

    final imageItems = items.where((item) {
      final processed = item['processed_image_path']?.toString();

      final original = item['image_path']?.toString();

      return (processed != null && processed.isNotEmpty) ||
          (original != null && original.isNotEmpty);
    }).toList();

    if (imageItems.isEmpty) {
      return _buildEmptyHistoryImage();
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.large),
      ),
      child: Row(
        children: imageItems.map((item) {
          final imagePath = item['processed_image_path']?.toString();

          final fallbackPath = item['image_path']?.toString();

          final path = imagePath != null && imagePath.isNotEmpty
              ? imagePath
              : fallbackPath;

          return Expanded(
            child: Padding(
              padding: const EdgeInsets.all(2),
              child: AspectRatio(
                aspectRatio: 1,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.small),
                  child: _buildBackendImage(path!),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBackendImage(String path) {
    final url = path.startsWith('http') ? path : '${ApiService.baseUrl}$path';

    return Image.network(
      url,
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) {
        return Container(
          color: AppColors.surfaceContainerMedium,
          child: const Center(
            child: Icon(
              Icons.checkroom_outlined,
              size: 36,
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

  Widget _buildEmptyHistoryImage() {
    return Container(
      width: double.infinity,
      height: 120,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.large),
      ),
      child: const Center(
        child: Icon(
          Icons.checkroom_outlined,
          size: 40,
          color: AppColors.outline,
        ),
      ),
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
