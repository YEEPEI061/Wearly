import 'package:flutter/material.dart';
import 'package:frontend/theme/app_colors.dart';
import 'package:frontend/theme/app_text_styles.dart';
import 'package:frontend/theme/app_radius.dart';
import 'package:frontend/widgets/app_header.dart';

class StylistPage extends StatefulWidget {
  const StylistPage({super.key});

  @override
  State<StylistPage> createState() => _StylistPageState();
}

class _StylistPageState extends State<StylistPage>
    with SingleTickerProviderStateMixin {
  // ============================================================
  // RECOMMENDATION DATA
  // ============================================================

  final String _outfitImage =
      'https://lh3.googleusercontent.com/aida-public/AB6AXuCfWgEl90E3ZhFYfWwCpCyaDZ7R1tR1xXbkjllcIapnkmoK9DM_HSQOP0zDJ3AGGzhOpHjI4WfHTuDPd_VVOWdcheiRgpD3CYFmDapBZ2OwB49J7HrYbjC8Hf0PKDseeacwv4OHpie5aK8N5D23EVFoT3HlxEnOBWMXsoonm7fyujSzrfZP3igw9xkYnFNwZ3xmLvsfV1Q80AMKlCVtia8laOWVfSyfH24qzlIdwRpT9sFLoHuaz_d5';
  final String _tryOnImage =
      'https://lh3.googleusercontent.com/aida-public/AB6AXuC2Ij6vuxhBGdF26K6qlz2ztH4EB0nVCWpBE1kFauAhoJxGVQJM3UaIbFe8B-zVVWoe_Ntijl9lmSBpE38R3jDysovsRi2lIf9Y19gFxOeemU4sHQD-vmty1fWQWgy6h8Z-vR7k2428Gbkj_R_BxmrhP_RNnLN1lJg03WR7ddmc9LQRCruGTtdF3fry5nAWy26V1eYvFgy7lloeOnFj6xr8P9cSTNF97cD7kpyUkeG7uPLOY_9fi55t';

  final String _captureImage =
      'https://lh3.googleusercontent.com/aida-public/AB6AXuDvB89rz2QmnIQ49madhFclydn6tRAtd1pQDNVytCA8MT_CouU-WYZaiRzryl4U0tWoASDz0GL2nw7J3Unyf5mFwDWs94J9u2dmKVFlhFi882_bucHRWZN7sECeyXYVkGsv2TkMbPWfkBHeLQ-T8uNwKqKFsWlKHhnIeLoAwYloHBV8cGEtI1Z4UMzS6W2ZNvBN0b0Hymeg6X0WWfV9tGKmiZlaXHcX3KnUPb4qzr9zAD0DNdpQPkC';

  bool _isAnimatingCard = false;
  bool _showTryOnResult = false;

  String _selectedOccasion = 'Evening';
  DateTime _selectedDate = DateTime(2024, 10, 24);

  // ============================================================
  // ACTIONS
  // ============================================================

  void _handleLike() {
    _animateRecommendation(true);
  }

  void _handleDislike() {
    _animateRecommendation(false);
  }

  void _animateRecommendation(bool liked) {
    if (_isAnimatingCard) return;

    setState(() {
      _isAnimatingCard = true;
    });

    Future.delayed(const Duration(milliseconds: 450), () {
      if (!mounted) return;

      setState(() {
        _isAnimatingCard = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            liked
                ? 'Look saved to your preferences.'
                : 'We will adjust future recommendations.',
          ),
          duration: const Duration(milliseconds: 1200),
        ),
      );
    });
  }

  void _openTryOnModal() {
    setState(() {
      _showTryOnResult = false;
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: AppColors.primary.withOpacity(0.80),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return _buildTryOnSheet(setModalState);
          },
        );
      },
    );
  }

  void _simulateCapture(StateSetter setModalState) {
    setModalState(() {});

    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;

      setModalState(() {
        _showTryOnResult = true;
      });
    });
  }

  void _confirmSchedule() {
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Look scheduled for ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}.',
        ),
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
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 38),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      const SizedBox(height: 8),
                      _buildIntro(),
                      const SizedBox(height: 20),
                      _buildRecommendationCard(),
                      const SizedBox(height: 24),
                      _buildScheduleButton(),
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
  // INTRO
  // ============================================================

  Widget _buildIntro() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'CURATED SESSION #042',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.primary,
                  letterSpacing: 1.5,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(AppRadius.small),
              ),
              child: Text(
                'MATCH: 98%',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.onSurfaceVariant,
                  letterSpacing: 0.8,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        Text(
          'The Modern Monolith Look',
          style: AppTextStyles.headlineMedium.copyWith(
            color: AppColors.primary,
          ),
        ),

        const SizedBox(height: 8),

        Text(
          'Tailored precisely for your upcoming evening symposium and minimalist silhouette preferences.',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // RECOMMENDATION CARD
  // ============================================================

  Widget _buildRecommendationCard() {
    return AnimatedSlide(
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOut,
      offset: _isAnimatingCard ? const Offset(0.15, 0) : Offset.zero,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 350),
        opacity: _isAnimatingCard ? 0.15 : 1,
        child: Container(
          width: double.infinity,
          height: 520,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(AppRadius.medium),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.network(
                  _outfitImage,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;

                    return const Center(child: CircularProgressIndicator());
                  },
                  errorBuilder: (context, error, stackTrace) {
                    print('IMAGE ERROR: $error');

                    return const Center(
                      child: Icon(Icons.broken_image_outlined, size: 64),
                    );
                  },
                ),
              ),

              // Dark gradient
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.primary.withOpacity(0.05),
                        AppColors.primary.withOpacity(0.15),
                        AppColors.primary.withOpacity(0.92),
                      ],
                      stops: const [0.0, 0.45, 1.0],
                    ),
                  ),
                ),
              ),

              // Bottom content
              Positioned(
                left: 24,
                right: 24,
                bottom: 24,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'LOOK BREAKDOWN',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.primaryDim,
                        letterSpacing: 1.5,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      'Double-Breasted Wool Blazer & Pleated Trousers',
                      style: AppTextStyles.headlineMedium.copyWith(
                        color: AppColors.white,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      'Structured shoulders elongate your frame while the fluid trousers create an effortless drape. Ideal for cooler evening settings.',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.surfaceContainerHigh,
                      ),
                    ),

                    const SizedBox(height: 18),

                    _buildRecommendationActions(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // RECOMMENDATION ACTIONS
  // ============================================================

  Widget _buildRecommendationActions() {
    return Row(
      children: [
        _buildRoundActionButton(
          icon: Icons.thumb_down_outlined,
          onTap: _handleDislike,
        ),

        const SizedBox(width: 12),

        Expanded(
          child: SizedBox(
            height: 56,
            child: ElevatedButton.icon(
              onPressed: _openTryOnModal,
              icon: const Icon(Icons.checkroom, size: 20),
              label: Text(
                'VIRTUAL TRY-ON',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.primary,
                  letterSpacing: 0.5,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.background,
                foregroundColor: AppColors.primary,
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.small),
                ),
              ),
            ),
          ),
        ),

        const SizedBox(width: 12),

        _buildRoundActionButton(icon: Icons.thumb_up, onTap: _handleLike),
      ],
    );
  }

  Widget _buildRoundActionButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.25),
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.white.withOpacity(0.25)),
        ),
        child: Icon(icon, size: 24, color: AppColors.white),
      ),
    );
  }

  // ============================================================
  // SCHEDULE BUTTON
  // ============================================================

  Widget _buildScheduleButton() {
    return GestureDetector(
      onTap: _openScheduleSheet,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          border: Border.all(color: AppColors.primary.withOpacity(0.20)),
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
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.10),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.calendar_today_outlined,
                size: 18,
                color: AppColors.primary,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SCHEDULE THIS LOOK',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.primary,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Select date & styling occasion',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'PICK DATE',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.primary,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.arrow_forward,
                  size: 18,
                  color: AppColors.primary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // SCHEDULE SHEET
  // ============================================================

  void _openScheduleSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: AppColors.primary.withOpacity(0.80),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return _buildScheduleSheet(setSheetState);
          },
        );
      },
    );
  }

  Widget _buildScheduleSheet(StateSetter setSheetState) {
    final days = List.generate(35, (index) => index - 1);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'WARDROBE PLANNER',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.secondary,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Schedule Outfit',
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

              // Month
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'October 2024',
                    style: AppTextStyles.headlineSmall.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                  Row(
                    children: [
                      _buildCalendarArrow(Icons.chevron_left),
                      const SizedBox(width: 4),
                      _buildCalendarArrow(Icons.chevron_right),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Weekdays
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 7,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
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

              // Calendar
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: days.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  mainAxisExtent: 42,
                ),
                itemBuilder: (_, index) {
                  final day = days[index];

                  if (day <= 0 || day > 31) {
                    final displayDay = day <= 0 ? 30 : day - 31;

                    return Center(
                      child: Text(
                        '$displayDay',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.outlineVariant,
                        ),
                      ),
                    );
                  }

                  final isSelected = day == _selectedDate.day;

                  return GestureDetector(
                    onTap: () {
                      setSheetState(() {
                        _selectedDate = DateTime(2024, 10, day);
                      });
                    },
                    child: Center(
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(AppRadius.small),
                        ),
                        child: Center(
                          child: Text(
                            '$day',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: isSelected
                                  ? AppColors.white
                                  : AppColors.onSurface,
                              fontWeight: isSelected
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

              const SizedBox(height: 20),

              // Occasion
              Text(
                'OCCASION WINDOW',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.onSurfaceVariant,
                  letterSpacing: 1.3,
                ),
              ),

              const SizedBox(height: 8),

              Row(
                children: [
                  _buildOccasionButton('ALL DAY', setSheetState),
                  const SizedBox(width: 8),
                  _buildOccasionButton('DAYTIME', setSheetState),
                  const SizedBox(width: 8),
                  _buildOccasionButton('EVENING', setSheetState),
                ],
              ),

              const SizedBox(height: 20),

              // Confirm
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _confirmSchedule,
                  icon: const Icon(Icons.event_available, size: 18),
                  label: Text(
                    'ADD TO CALENDAR',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    elevation: 2,
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

  Widget _buildCalendarArrow(IconData icon) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 18, color: AppColors.onSurfaceVariant),
    );
  }

  Widget _buildOccasionButton(String label, StateSetter setSheetState) {
    final isSelected = _selectedOccasion == _occasionValue(label);

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setSheetState(() {
            _selectedOccasion = _occasionValue(label);
          });
        },
        child: Container(
          height: 42,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryContainer : Colors.transparent,
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.outlineVariant,
            ),
            borderRadius: BorderRadius.circular(AppRadius.small),
          ),
          child: Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: isSelected ? AppColors.white : AppColors.onSurface,
              letterSpacing: 0.8,
            ),
          ),
        ),
      ),
    );
  }

  String _occasionValue(String label) {
    switch (label) {
      case 'ALL DAY':
        return 'All Day';
      case 'DAYTIME':
        return 'Daytime';
      default:
        return 'Evening';
    }
  }

  // ============================================================
  // VIRTUAL TRY-ON SHEET
  // ============================================================

  Widget _buildTryOnSheet(StateSetter setModalState) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.90,
      ),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          child: _showTryOnResult
              ? _buildTryOnResult()
              : _buildTryOnCapture(setModalState),
        ),
      ),
    );
  }

  Widget _buildTryOnCapture(StateSetter setModalState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'VIRTUAL FITTING SUITE',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.primaryContainer,
                      letterSpacing: 1.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Calibrate Your Silhouette',
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
                child: const Icon(Icons.close, color: AppColors.onSurface),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        Text(
          'Position your device 6 feet away. Align your full silhouette within the optical guide below for hyper-realistic draping.',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),

        const SizedBox(height: 16),

        // Viewfinder
        Container(
          width: double.infinity,
          height: 420,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(AppRadius.medium),
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.network(
                  _captureImage,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) {
                    return Container(
                      color: AppColors.surfaceContainerHigh,
                      child: const Center(
                        child: Icon(
                          Icons.person_outline,
                          size: 80,
                          color: AppColors.outline,
                        ),
                      ),
                    );
                  },
                ),
              ),

              Positioned.fill(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppColors.outlineVariant,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 24),

                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.primary),
                        ),
                        child: const Icon(
                          Icons.face_outlined,
                          color: AppColors.primary,
                          size: 20,
                        ),
                      ),

                      const Spacer(),

                      Container(
                        width: 96,
                        height: 190,
                        decoration: BoxDecoration(
                          border: Border(
                            left: BorderSide(
                              color: AppColors.primary.withOpacity(0.6),
                              style: BorderStyle.solid,
                            ),
                            right: BorderSide(
                              color: AppColors.primary.withOpacity(0.6),
                              style: BorderStyle.solid,
                            ),
                          ),
                        ),
                      ),

                      const Spacer(),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        color: AppColors.primary,
                        child: Text(
                          'ALIGN SILHOUETTE HERE',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.white,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Capture buttons
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: () => _simulateCapture(setModalState),
                  icon: const Icon(Icons.photo_camera),
                  label: Text(
                    'CAPTURE PORTRAIT',
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
                      borderRadius: BorderRadius.circular(AppRadius.small),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 12),

            SizedBox(
              height: 56,
              child: OutlinedButton(
                onPressed: () => _simulateCapture(setModalState),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.small),
                  ),
                ),
                child: Text(
                  'UPLOAD FILE',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.primary,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ============================================================
  // TRY-ON RESULT
  // ============================================================

  Widget _buildTryOnResult() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'VIRTUAL FITTING SUITE',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.primaryContainer,
                      letterSpacing: 1.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Your Virtual Fit',
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
                child: const Icon(Icons.close, color: AppColors.onSurface),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        Container(
          width: double.infinity,
          height: 420,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(AppRadius.medium),
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.network(
                  _tryOnImage,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) {
                    return const Center(
                      child: Icon(
                        Icons.image_outlined,
                        size: 64,
                        color: AppColors.outline,
                      ),
                    );
                  },
                ),
              ),

              Positioned(
                left: 16,
                bottom: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  color: AppColors.background.withOpacity(0.92),
                  child: Text(
                    'DRAPE ACCURACY: 99.4%',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.primary,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        Text(
          'Your virtual fit is ready. Fabric drape and sizing have been calibrated to your measurements.',
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.onSurface),
        ),

        const SizedBox(height: 16),

        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.small),
              ),
            ),
            child: Text(
              'RETURN TO STYLIST FEED',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.white,
                letterSpacing: 1.0,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
