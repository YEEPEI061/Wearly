// ignore_for_file: deprecated_member_use

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:frontend/models/clothing_item.dart';
import 'package:frontend/services/api_service.dart';
import 'package:frontend/theme/app_colors.dart';
import 'package:frontend/theme/app_text_styles.dart';
import 'package:frontend/theme/app_radius.dart';
import 'package:frontend/widgets/app_page_header.dart';

class RecordOutfitPage extends StatefulWidget {
  final ClothingItem? topItem;
  final ClothingItem? bottomItem;

  const RecordOutfitPage({super.key, this.topItem, this.bottomItem});

  @override
  State<RecordOutfitPage> createState() => _RecordOutfitPageState();
}

class _RecordOutfitPageState extends State<RecordOutfitPage> {
  // ============================================================
  // DATE
  // ============================================================

  late DateTime _selectedDate;

  late PageController _weekPageController;

  static const int _weekPageBase = 500;

  // ============================================================
  // OUTFIT DATA
  // ============================================================

  late ClothingItem? _topItem;
  late ClothingItem? _bottomItem;
  late ClothingItem? _fullItem;

  final List<String> _vibes = [
    'Airy & Effortless',
    'Highly Breathable',
    'Flattering Drape',
    'Archived Favorite',
  ];

  final Set<String> _selectedVibes = {};

  final TextEditingController _noteController = TextEditingController();

  List<ClothingItem> _wardrobeItems = [];
  // ignore: unused_field
  bool _isLoadingWardrobe = false;

  String? _outfitPreviewUrl;
  bool _isGeneratingPreview = false;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    final now = DateTime.now();

    _selectedDate = DateTime(now.year, now.month, now.day);

    _weekPageController = PageController(initialPage: _weekPageBase);

    _topItem = widget.topItem;
    _bottomItem = widget.bottomItem;
    _fullItem = null;
  }

  @override
  void dispose() {
    _weekPageController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  // ============================================================
  // DATE HELPERS
  // ============================================================

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

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  bool _isToday(DateTime date) {
    return _isSameDay(date, DateTime.now());
  }

  // ============================================================
  // IMAGE HELPERS
  // ============================================================

  Widget _buildClothingImage(ClothingItem? item) {
    if (item == null) {
      return _buildImagePlaceholder();
    }

    final processedPath = item.processedImagePath;

    if (processedPath != null && processedPath.isNotEmpty) {
      return Image.network(
        '${ApiService.baseUrl}$processedPath',
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) {
          return _buildLocalOrPlaceholder(item);
        },
      );
    }

    return _buildLocalOrPlaceholder(item);
  }

  Widget _buildLocalOrPlaceholder(ClothingItem item) {
    if (item.imagePath != null && item.imagePath!.isNotEmpty) {
      return Image.file(
        File(item.imagePath!),
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) {
          return _buildImagePlaceholder();
        },
      );
    }

    return _buildImagePlaceholder();
  }

  Widget _buildImagePlaceholder() {
    return const Center(
      child: Icon(Icons.checkroom_outlined, size: 42, color: AppColors.outline),
    );
  }

  // ============================================================
  // DISPLAY HELPERS
  // ============================================================

  String _capitalizeWords(String text) {
    return text
        .split(' ')
        .map(
          (word) =>
              word.isEmpty ? word : word[0].toUpperCase() + word.substring(1),
        )
        .join(' ');
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const AppPageHeader(title: 'RECORD OUTFIT'),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 48),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildEditorialHeader(),

                    const SizedBox(height: 24),

                    _buildDateSection(),

                    const SizedBox(height: 28),

                    _buildOutfitSection(),

                    const SizedBox(height: 28),

                    _buildVibeSection(),

                    const SizedBox(height: 28),

                    _buildNoteSection(),

                    const SizedBox(height: 32),

                    _buildSaveButton(),
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
  // EDITORIAL HEADER
  // ============================================================

  Widget _buildEditorialHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'OUTFIT DIARY',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.primaryContainer,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        Text(
          'Record Today\'s Ensemble',
          style: AppTextStyles.headlineLarge.copyWith(color: AppColors.primary),
        ),

        const SizedBox(height: 6),

        Text(
          'Preserve the look, mood, and pieces that carried you through the day.',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // DATE OF WEAR
  // ============================================================

  Widget _buildDateSection() {
    final dateText =
        '${_shortMonthName(_selectedDate.month)} '
        '${_selectedDate.day}, '
        '${_selectedDate.year}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'DATE OF WEAR',
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.secondary,
            letterSpacing: 1.5,
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 10),

        GestureDetector(
          onTap: _selectDate,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
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
                    Icons.calendar_today_outlined,
                    size: 18,
                    color: AppColors.white,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dateText,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 2),

                      Text(
                        _isToday(_selectedDate)
                            ? 'Today'
                            : 'Tap to change date',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),

                const Icon(Icons.chevron_right, color: AppColors.outline),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate() async {
    DateTime tempDate = _selectedDate;

    final selectedDate = await showModalBottomSheet<DateTime>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return _buildDatePickerSheet(tempDate, (date) {
              setSheetState(() {
                tempDate = date;
              });
            });
          },
        );
      },
    );

    if (selectedDate == null) return;

    setState(() {
      _selectedDate = selectedDate;
    });
  }

  Widget _buildDatePickerSheet(
    DateTime selectedDate,
    ValueChanged<DateTime> onDateChanged,
  ) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.72,
      ),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --------------------------------------------------
              // DRAG HANDLE
              // --------------------------------------------------
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.outlineVariant,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // --------------------------------------------------
              // HEADER
              // --------------------------------------------------
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'OUTFIT DIARY',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.secondary,
                            letterSpacing: 1.5,
                          ),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          'Select Date',
                          style: AppTextStyles.headlineMedium.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerHigh,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        size: 20,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              Divider(
                height: 1,
                color: AppColors.outlineVariant.withOpacity(0.4),
              ),

              const SizedBox(height: 20),

              // --------------------------------------------------
              // CALENDAR
              // --------------------------------------------------
              _buildCalendar(selectedDate, onDateChanged),

              const SizedBox(height: 20),

              // --------------------------------------------------
              // CONFIRM
              // --------------------------------------------------
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context, selectedDate);
                  },
                  icon: const Icon(Icons.check, size: 18),
                  label: Text(
                    'SELECT DATE',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.small),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCalendar(
    DateTime selectedDate,
    ValueChanged<DateTime> onDateChanged,
  ) {
    final monthStart = DateTime(selectedDate.year, selectedDate.month, 1);

    final daysInMonth = DateTime(
      selectedDate.year,
      selectedDate.month + 1,
      0,
    ).day;

    final leadingDays = monthStart.weekday - 1;

    final totalCells = ((leadingDays + daysInMonth) / 7).ceil() * 7;

    return Column(
      children: [
        // ------------------------------------------------------
        // MONTH HEADER
        // ------------------------------------------------------
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${_shortMonthName(selectedDate.month)} '
              '${selectedDate.year}',
              style: AppTextStyles.headlineSmall.copyWith(
                color: AppColors.primary,
              ),
            ),

            Row(
              children: [
                _buildCalendarArrow(Icons.chevron_left, () {
                  final previousMonth = DateTime(
                    selectedDate.year,
                    selectedDate.month - 1,
                    1,
                  );

                  final previousDaysInMonth = DateTime(
                    previousMonth.year,
                    previousMonth.month + 1,
                    0,
                  ).day;

                  final day = selectedDate.day.clamp(1, previousDaysInMonth);

                  onDateChanged(
                    DateTime(previousMonth.year, previousMonth.month, day),
                  );
                }),

                const SizedBox(width: 4),

                _buildCalendarArrow(Icons.chevron_right, () {
                  final nextMonth = DateTime(
                    selectedDate.year,
                    selectedDate.month + 1,
                    1,
                  );

                  final nextDaysInMonth = DateTime(
                    nextMonth.year,
                    nextMonth.month + 1,
                    0,
                  ).day;

                  final day = selectedDate.day.clamp(1, nextDaysInMonth);

                  onDateChanged(DateTime(nextMonth.year, nextMonth.month, day));
                }),
              ],
            ),
          ],
        ),

        const SizedBox(height: 14),

        // ------------------------------------------------------
        // WEEKDAYS
        // ------------------------------------------------------
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 7,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisExtent: 28,
          ),
          itemBuilder: (_, index) {
            const weekdays = ['MO', 'TU', 'WE', 'TH', 'FR', 'SA', 'SU'];

            return Center(
              child: Text(
                weekdays[index],
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.onSurfaceVariant,
                  letterSpacing: 0.8,
                ),
              ),
            );
          },
        ),

        const SizedBox(height: 6),

        // ------------------------------------------------------
        // DAYS
        // ------------------------------------------------------
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: totalCells,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisExtent: 46,
          ),
          itemBuilder: (_, index) {
            if (index < leadingDays || index >= leadingDays + daysInMonth) {
              return const SizedBox();
            }

            final day = index - leadingDays + 1;

            final date = DateTime(selectedDate.year, selectedDate.month, day);

            final isSelected = _isSameDay(date, selectedDate);

            final isToday = _isToday(date);

            return GestureDetector(
              onTap: () {
                onDateChanged(date);
              },
              child: Center(
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(AppRadius.small),
                    border: isToday && !isSelected
                        ? Border.all(color: AppColors.primary, width: 1)
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      '$day',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: isSelected
                            ? AppColors.white
                            : AppColors.onSurface,
                        fontWeight: isSelected || isToday
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildCalendarArrow(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(AppRadius.small),
        ),
        child: Icon(icon, size: 20, color: AppColors.primary),
      ),
    );
  }

  // ============================================================
  // OUTFIT CARD
  // ============================================================

  Widget _buildOutfitSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Text(
                'SELECTED ENSEMBLE',
                style: AppTextStyles.headlineSmall.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        _buildOutfitCard(),

        const SizedBox(height: 20),

        Text(
          'SELECT CLOTHING',
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.secondary,
            letterSpacing: 1.5,
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 10),

        _buildClothingSelectors(),
      ],
    );
  }

  Widget _buildOutfitCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // ------------------------------------------------------
          // OUTFIT PREVIEW
          // ------------------------------------------------------
          SizedBox(
            height: 390,
            width: double.infinity,
            child: _buildSelectedOutfitPreview(),
          ),

          // ------------------------------------------------------
          // LOOK BREAKDOWN
          // ------------------------------------------------------
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: AppColors.surfaceContainerLow,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'LOOK BREAKDOWN',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.secondary,
                    letterSpacing: 1.4,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  _buildOutfitTitle(),
                  style: AppTextStyles.headlineSmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w400,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  _buildOutfitDescription(),
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

  Widget _buildSelectedOutfitPreview() {
    Widget preview;

    // --------------------------------------------------------
    // GENERATING OUTFIT PREVIEW
    // --------------------------------------------------------

    if (_isGeneratingPreview) {
      preview = _buildOutfitPreviewLoading();
    }
    // --------------------------------------------------------
    // BACKEND-GENERATED PREVIEW
    // --------------------------------------------------------
    else if (_outfitPreviewUrl != null && _outfitPreviewUrl!.isNotEmpty) {
      preview = Container(
        key: ValueKey(_outfitPreviewUrl),
        width: double.infinity,
        height: 390,
        color: AppColors.background,
        child: Image.network(
          '${ApiService.baseUrl}$_outfitPreviewUrl',
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) {
            return _buildEmptyOutfitPreview();
          },
        ),
      );
    }
    // --------------------------------------------------------
    // TOP ONLY
    // --------------------------------------------------------
    else if (_topItem != null) {
      preview = _buildSingleClothingPreview(_topItem!);
    }
    // --------------------------------------------------------
    // BOTTOM ONLY
    // --------------------------------------------------------
    else if (_bottomItem != null) {
      preview = _buildSingleClothingPreview(_bottomItem!);
    }
    // --------------------------------------------------------
    // NOTHING SELECTED
    // --------------------------------------------------------
    else {
      preview = _buildEmptyOutfitPreview();
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 350),
      reverseDuration: const Duration(milliseconds: 150),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, animation) {
        return FadeTransition(opacity: animation, child: child);
      },
      child: preview,
    );
  }

  Widget _buildOutfitPreviewLoading() {
    return Container(
      key: const ValueKey('outfit-preview-loading'),
      width: double.infinity,
      height: 390,
      color: AppColors.background,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'CREATING YOUR LOOK',
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.primary,
              letterSpacing: 1.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Combining your selected pieces...',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSingleClothingPreview(ClothingItem item) {
    final imagePath = item.processedImagePath;

    return Container(
      width: double.infinity,
      height: 390,
      color: AppColors.background,
      child: Stack(
        children: [
          if (imagePath != null && imagePath.isNotEmpty)
            Align(
              alignment: item.category.toLowerCase() == 'upper'
                  ? Alignment.topCenter
                  : Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Image.network(
                  '${ApiService.baseUrl}$imagePath',
                  width: double.infinity,
                  height: 245,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) {
                    return _buildEmptyOutfitPreview();
                  },
                ),
              ),
            )
          else
            _buildEmptyOutfitPreview(),
        ],
      ),
    );
  }

  Widget _buildEmptyOutfitPreview() {
    return Container(
      width: double.infinity,
      color: AppColors.background,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(AppRadius.small),
            ),
            child: const Icon(
              Icons.checkroom_outlined,
              size: 28,
              color: AppColors.primary,
            ),
          ),

          const SizedBox(height: 12),

          Text(
            'SELECT AN OUTFIT',
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.primary,
              letterSpacing: 1.1,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            'Choose clothing below',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClothingSelectors() {
    return Row(
      children: [
        Expanded(
          child: _buildClothingSelectorButton(
            label: 'TOP',
            icon: Icons.checkroom_outlined,
          ),
        ),

        const SizedBox(width: 8),

        Expanded(
          child: _buildClothingSelectorButton(
            label: 'BOTTOM',
            icon: Icons.checkroom_outlined,
          ),
        ),

        const SizedBox(width: 8),

        Expanded(
          child: _buildClothingSelectorButton(
            label: 'FULL',
            icon: Icons.dry_cleaning_outlined,
          ),
        ),
      ],
    );
  }

  Widget _buildClothingSelectorButton({
    required String label,
    required IconData icon,
  }) {
    final ClothingItem? selectedItem;

    if (label == 'TOP') {
      selectedItem = _topItem;
    } else if (label == 'BOTTOM') {
      selectedItem = _bottomItem;
    } else {
      selectedItem = _fullItem;
    }

    final isSelected = selectedItem != null;

    return GestureDetector(
      onTap: () => _chooseClothing(label),
      child: Container(
        height: 82,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(AppRadius.small),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.outlineVariant,
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? AppColors.white : AppColors.primary,
            ),

            const SizedBox(height: 6),

            Text(
              label,
              style: AppTextStyles.labelSmall.copyWith(
                color: isSelected ? AppColors.white : AppColors.primary,
                letterSpacing: 1,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 2),

            Text(
              isSelected ? 'CHANGE' : 'SELECT',
              style: AppTextStyles.labelSmall.copyWith(
                color: isSelected
                    ? AppColors.white.withOpacity(0.7)
                    : AppColors.outline,
                fontSize: 9,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _buildItemSubtitle(ClothingItem item) {
    final parts = <String>[];

    if (item.color != null && item.color!.isNotEmpty) {
      parts.add(_capitalizeWords(item.color!));
    }

    if (item.style != null && item.style!.isNotEmpty) {
      parts.add(_capitalizeWords(item.style!));
    }

    if (parts.isEmpty) {
      return 'From your wardrobe';
    }

    return parts.join(' • ');
  }

  Future<void> _chooseClothing(String type) async {
    setState(() {
      _isLoadingWardrobe = true;
    });

    try {
      _wardrobeItems = await ApiService.getWardrobe();

      if (!mounted) return;

      setState(() {
        _isLoadingWardrobe = false;
      });

      final selected = await showModalBottomSheet<ClothingItem>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return _buildWardrobeSelector(type);
        },
      );

      if (selected == null) return;

      setState(() {
        _outfitPreviewUrl = null;

        if (type == 'TOP') {
          _topItem = selected;
          _fullItem = null;
        } else if (type == 'BOTTOM') {
          _bottomItem = selected;
          _fullItem = null;
        } else if (type == 'FULL') {
          _fullItem = selected;
          _topItem = null;
          _bottomItem = null;
        }
      });

      await _generateSelectedOutfitPreview();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoadingWardrobe = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  Widget _buildWardrobeSelector(String type) {
    String expectedCategory;

    if (type == 'TOP') {
      expectedCategory = 'upper';
    } else if (type == 'BOTTOM') {
      expectedCategory = 'lower';
    } else {
      expectedCategory = 'full';
    }

    final availableItems = _wardrobeItems.where((item) {
      return item.category.toLowerCase() == expectedCategory;
    }).toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.72,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 10),

            Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.outlineVariant,
                borderRadius: BorderRadius.circular(10),
              ),
            ),

            const SizedBox(height: 18),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'SELECT $type',
                      style: AppTextStyles.headlineSmall.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),

                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Choose an item from your wardrobe.',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ),
            ),

            Expanded(
              child: availableItems.isEmpty
                  ? _buildEmptyWardrobeState(type)
                  : GridView.builder(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.78,
                          ),
                      itemCount: availableItems.length,
                      itemBuilder: (context, index) {
                        final item = availableItems[index];

                        return _buildWardrobeChoice(item);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyWardrobeState(String type) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.checkroom_outlined,
              size: 48,
              color: AppColors.outline,
            ),

            const SizedBox(height: 16),

            Text(
              'No ${type.toLowerCase()} items found',
              textAlign: TextAlign.center,
              style: AppTextStyles.headlineSmall.copyWith(
                color: AppColors.primary,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              'Add this type of clothing to your wardrobe first.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWardrobeChoice(ClothingItem item) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context, item);
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(AppRadius.medium),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: _buildClothingImage(item),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 3),

                  Text(
                    _buildItemSubtitle(item),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.outline,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _buildOutfitTitle() {
    if (_fullItem != null) {
      return _fullItem!.name;
    }

    if (_topItem != null && _bottomItem != null) {
      return '${_topItem!.name} & ${_bottomItem!.name}';
    }

    if (_topItem != null) {
      return _topItem!.name;
    }

    if (_bottomItem != null) {
      return _bottomItem!.name;
    }

    return 'No Outfit Selected';
  }

  String _buildOutfitDescription() {
    if (_fullItem != null) {
      final style = _fullItem!.style;

      if (style != null && style.isNotEmpty) {
        return '${_capitalizeWords(style)} full-body piece from your wardrobe.';
      }

      return 'A full-body piece from your digital wardrobe.';
    }

    final topStyle = _topItem?.style;
    final bottomStyle = _bottomItem?.style;

    if (topStyle != null && bottomStyle != null) {
      return '${_capitalizeWords(topStyle)} pairing with '
          '${_capitalizeWords(bottomStyle)} balance.';
    }

    if (_topItem != null || _bottomItem != null) {
      return 'Complete the ensemble by selecting another piece.';
    }

    return 'Select clothing from your digital wardrobe.';
  }

  // ============================================================
  // VIBES
  // ============================================================

  Widget _buildVibeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'QUICK IMPRESSIONS',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.secondary,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            Text(
              'DIARY LOG',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.outline,
                letterSpacing: 1,
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _vibes.map((vibe) {
            final selected = _selectedVibes.contains(vibe);

            return GestureDetector(
              onTap: () {
                setState(() {
                  if (selected) {
                    _selectedVibes.remove(vibe);
                  } else {
                    _selectedVibes.add(vibe);
                  }
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.primary
                      : AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(AppRadius.small),
                ),
                child: Text(
                  vibe.toUpperCase(),
                  style: AppTextStyles.labelSmall.copyWith(
                    color: selected
                        ? AppColors.white
                        : AppColors.onSurfaceVariant,
                    letterSpacing: 0.9,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ============================================================
  // NOTE
  // ============================================================

  Widget _buildNoteSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SELF-EXPRESSION NOTE',
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.secondary,
            letterSpacing: 1.5,
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 10),

        Container(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(AppRadius.small),
          ),
          child: Column(
            children: [
              TextField(
                controller: _noteController,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Document how the outfit felt today...',
                  border: InputBorder.none,
                  isDense: true,
                ),
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.onSurface,
                ),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Icon(
                    Icons.edit_note,
                    size: 18,
                    color: AppColors.outline,
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
  // SAVE
  // ============================================================

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton.icon(
        onPressed: _saveOutfit,
        icon: const Icon(Icons.history_edu, size: 20),
        label: Text(
          'SAVE TO OUTFIT HISTORY',
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.white,
            letterSpacing: 1.0,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.medium),
          ),
        ),
      ),
    );
  }

  String _buildFinalNote() {
    final vibeText = _selectedVibes.join(' • ');
    final noteText = _noteController.text.trim();

    if (vibeText.isEmpty) {
      return noteText;
    }

    if (noteText.isEmpty) {
      return vibeText;
    }

    return '$vibeText\n\n$noteText';
  }

  Future<void> _saveOutfit() async {
    final List<String> itemIds = [];

    if (_fullItem != null) {
      itemIds.add(_fullItem!.id);
    } else {
      if (_topItem != null) {
        itemIds.add(_topItem!.id);
      }

      if (_bottomItem != null) {
        itemIds.add(_bottomItem!.id);
      }
    }

    if (itemIds.isEmpty) {
      _showError('Please select an outfit first.');
      return;
    }

    final finalNote = _buildFinalNote();

    try {
      await ApiService.saveOutfitHistory(
        itemIds: itemIds,
        wornDate: _selectedDate,
        notes: finalNote,
      );

      if (!mounted) return;

      _showTopSuccessMessage('Outfit recorded successfully.');

      await Future.delayed(const Duration(milliseconds: 700));

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      _showError(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  void _showTopSuccessMessage(String message) {
    final overlay = Overlay.of(context);

    final overlayEntry = OverlayEntry(
      builder: (context) {
        return Positioned(
          top: MediaQuery.of(context).padding.top + 16,
          left: 0,
          right: 0,
          child: Center(
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.10),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 26,
                      height: 26,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE8F5E9),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        size: 16,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      message,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );

    overlay.insert(overlayEntry);

    Future.delayed(const Duration(seconds: 2), () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red.shade700,
        ),
      );
  }

  Future<void> _generateSelectedOutfitPreview() async {
    // --------------------------------------------------------
    // FULL ITEM
    // --------------------------------------------------------

    if (_fullItem != null) {
      setState(() {
        _isGeneratingPreview = true;
      });

      try {
        final imageUrl = await ApiService.generateRecordOutfitPreview(
          itemIds: [_fullItem!.id],
        );

        if (!mounted) return;

        setState(() {
          _outfitPreviewUrl = imageUrl;
          _isGeneratingPreview = false;
        });
      } catch (e) {
        if (!mounted) return;

        setState(() {
          _isGeneratingPreview = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Unable to generate outfit preview: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }

      return;
    }

    // --------------------------------------------------------
    // TOP + BOTTOM
    // --------------------------------------------------------

    if (_topItem != null && _bottomItem != null) {
      setState(() {
        _isGeneratingPreview = true;
      });

      try {
        final imageUrl = await ApiService.generateRecordOutfitPreview(
          itemIds: [_topItem!.id, _bottomItem!.id],
        );

        if (!mounted) return;

        setState(() {
          _outfitPreviewUrl = imageUrl;
          _isGeneratingPreview = false;
        });
      } catch (e) {
        if (!mounted) return;

        setState(() {
          _isGeneratingPreview = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Unable to generate outfit preview: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }

      return;
    }

    // --------------------------------------------------------
    // TOP ONLY
    // --------------------------------------------------------

    if (_topItem != null) {
      setState(() {
        _outfitPreviewUrl = null;
        _isGeneratingPreview = false;
      });

      return;
    }

    // --------------------------------------------------------
    // BOTTOM ONLY
    // --------------------------------------------------------

    if (_bottomItem != null) {
      setState(() {
        _outfitPreviewUrl = null;
        _isGeneratingPreview = false;
      });

      return;
    }

    // --------------------------------------------------------
    // NOTHING SELECTED
    // --------------------------------------------------------

    setState(() {
      _outfitPreviewUrl = null;
      _isGeneratingPreview = false;
    });
  }
}
