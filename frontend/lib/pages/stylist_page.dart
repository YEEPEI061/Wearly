// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:frontend/pages/virtual_try_on_page.dart';
import 'package:frontend/theme/app_colors.dart';
import 'package:frontend/theme/app_text_styles.dart';
import 'package:frontend/theme/app_radius.dart';
import 'package:frontend/widgets/app_page_header.dart';
import 'package:frontend/services/api_service.dart';

class StylistPage extends StatefulWidget {
  final String occasion;
  final String mood;

  const StylistPage({super.key, required this.occasion, required this.mood});

  @override
  State<StylistPage> createState() => _StylistPageState();
}

class _StylistPageState extends State<StylistPage>
    with SingleTickerProviderStateMixin {
  bool _isAnimatingCard = false;

  List<Map<String, dynamic>> _recommendations = [];

  int _selectedRecommendationIndex = 0;

  Map<String, dynamic>? _recommendation;

  bool _isLoadingRecommendation = true;

  bool _isSubmittingFeedback = false;

  final Map<String, String> _feedbackByOutfitId = {};

  String? _recommendationError;

  DateTime _selectedDate = DateTime.now();

  late DateTime _scheduleDisplayedMonth;

  final TextEditingController _scheduleNotesController =
      TextEditingController();

  bool _isSavingSchedule = false;

  @override
  void initState() {
    super.initState();

    final now = DateTime.now();

    _selectedDate = DateTime(now.year, now.month, now.day);

    _scheduleDisplayedMonth = DateTime(now.year, now.month, 1);

    _loadRecommendation();
  }

  @override
  void dispose() {
    _scheduleNotesController.dispose();
    super.dispose();
  }

  Future<void> _loadRecommendation() async {
    if (!mounted) return;

    setState(() {
      _recommendationError = null;
      _isLoadingRecommendation = true;
    });

    try {
      final response = await ApiService.generateOutfit(
        occasion: widget.occasion,
        mood: widget.mood,
      );

      if (!mounted) return;

      final outfits = response['outfits'];

      if (outfits == null || outfits is! List || outfits.isEmpty) {
        setState(() {
          _recommendationError =
              'Not enough clothing items to generate an outfit.';
          _isLoadingRecommendation = false;
        });

        return;
      }

      final recommendations = outfits
          .map<Map<String, dynamic>>(
            (outfit) => Map<String, dynamic>.from(outfit),
          )
          .toList();

      for (final outfit in recommendations) {
        final outfitId = outfit['id']?.toString();
        final feedback = outfit['feedback']?.toString();

        if (outfitId != null && feedback != null && feedback.isNotEmpty) {
          _feedbackByOutfitId[outfitId] = feedback;
        }
      }

      setState(() {
        _recommendations = recommendations;
        _selectedRecommendationIndex = 0;
        _recommendation = recommendations.first;
        _isLoadingRecommendation = false;
      });

      print('✓ ${recommendations.length} outfit recommendations loaded');
      print('CURRENT OUTFIT: $_recommendation');
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _recommendationError = e.toString();
        _isLoadingRecommendation = false;
      });

      print('❌ Outfit recommendation failed: $e');
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

  // ============================================================
  // ACTIONS
  // ============================================================

  Future<void> _handleLike() async {
    await _submitFeedback('LIKE');
  }

  Future<void> _handleDislike() async {
    await _submitFeedback('DISLIKE');
  }

  Future<void> _submitFeedback(String feedback) async {
    if (_recommendation == null) return;

    if (_isSubmittingFeedback) return;

    final String outfitId = _recommendation!['id']?.toString() ?? '';

    if (outfitId.isEmpty) {
      _showFeedbackError('This recommendation does not have a valid ID.');
      return;
    }

    setState(() {
      _isSubmittingFeedback = true;
    });

    try {
      await ApiService.sendOutfitFeedback(
        outfitId: outfitId,
        feedback: feedback,
      );

      if (!mounted) return;

      setState(() {
        _isSubmittingFeedback = false;

        _feedbackByOutfitId[outfitId] = feedback;
      });

      _showTopSuccessMessage(
        feedback == 'LIKE'
            ? 'Look saved to your preferences.'
            : 'We will adjust future recommendations.',
      );

      // ------------------------------------------------------------
      // DISLIKE → MOVE TO NEXT EXISTING OUTFIT
      // ------------------------------------------------------------

      if (feedback == 'DISLIKE') {
        if (_recommendations.isEmpty) {
          return;
        }

        final nextIndex = _selectedRecommendationIndex + 1;

        if (nextIndex < _recommendations.length) {
          setState(() {
            _selectedRecommendationIndex = nextIndex;
            _recommendation = _recommendations[nextIndex];
          });
        } else {
          // All currently loaded outfits have been viewed.
          // Generate a new set of recommendations.
          await _loadRecommendation();
        }
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isSubmittingFeedback = false;
      });

      _showFeedbackError('Unable to save feedback.');

      print('❌ FEEDBACK ERROR: $e');
    }
  }

  void _showFeedbackError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _openVirtualTryOn() {
    if (_recommendation == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VirtualTryOnPage(outfit: _recommendation!),
      ),
    );
  }

  Future<void> _confirmSchedule() async {
    if (_recommendation == null) {
      return;
    }

    if (_isSavingSchedule) {
      return;
    }

    final outfitId = _recommendation!['id']?.toString() ?? '';

    if (outfitId.isEmpty) {
      _showFeedbackError('This outfit does not have a valid ID.');
      return;
    }

    setState(() {
      _isSavingSchedule = true;
    });

    try {
      await ApiService.scheduleOutfit(
        outfitId: outfitId,
        wornDate: _selectedDate,
        notes: _scheduleNotesController.text,
      );

      if (!mounted) return;

      setState(() {
        _isSavingSchedule = false;
      });

      Navigator.pop(context);

      _scheduleNotesController.clear();

      Future.delayed(const Duration(milliseconds: 250), () {
        if (!mounted) return;

        _showTopSuccessMessage('Look added to your outfit diary.');
      });

      print(
        '✓ OUTFIT SCHEDULED: '
        'outfit=$outfitId '
        'date=$_selectedDate',
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isSavingSchedule = false;
      });

      _showFeedbackError('Unable to schedule this look.');

      print('❌ SCHEDULE OUTFIT ERROR: $e');
    }
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
            const AppPageHeader(title: 'OUTFIT STYLIST'),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 48),
                child: Column(
                  children: [
                    if (_recommendationError != null)
                      _buildRecommendationError()
                    else if (_isLoadingRecommendation)
                      _buildRecommendationLoading()
                    else if (_recommendation != null) ...[
                      _buildIntro(),

                      const SizedBox(height: 24),

                      _buildRecommendationCard(),

                      const SizedBox(height: 24),

                      _buildScheduleButton(),
                    ],
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
    final recommendation = _recommendation;

    if (recommendation == null) {
      return const SizedBox.shrink();
    }

    final score = (recommendation['score'] as num?)?.toDouble() ?? 0.0;

    final matchPercentage = (score * 100).round();

    final reason = recommendation['reason']?.toString() ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                  'AI OUTFIT RECOMMENDATION',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.primaryContainer,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),

            const SizedBox(width: 12),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(AppRadius.small),
              ),
              child: Text(
                'MATCH: $matchPercentage%',
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
          'Your AI Curated Look',
          style: AppTextStyles.headlineMedium.copyWith(
            color: AppColors.primary,
          ),
        ),

        const SizedBox(height: 8),

        Text(
          reason,
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
    final recommendation = _recommendation;

    if (recommendation == null) {
      return const SizedBox.shrink();
    }

    final items = recommendation['items'] as List<dynamic>? ?? [];

    return AnimatedSlide(
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOut,
      offset: _isAnimatingCard ? const Offset(0.15, 0) : Offset.zero,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 350),
        opacity: _isAnimatingCard ? 0.15 : 1,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildRecommendationContext(),

              const SizedBox(height: 12),

              _buildRecommendedClothing(items),

              const SizedBox(height: 20),

              _buildRecommendationActions(),

              const SizedBox(height: 5),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecommendedClothing(List<dynamic> items) {
    if (_recommendations.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 350,
          child: PageView.builder(
            itemCount: _recommendations.length,
            onPageChanged: (index) {
              setState(() {
                _selectedRecommendationIndex = index;
                _recommendation = _recommendations[index];
              });
            },
            itemBuilder: (context, index) {
              final recommendation = _recommendations[index];

              final imagePath = recommendation['image_url']?.toString();

              if (imagePath == null || imagePath.isEmpty) {
                return const Center(
                  child: Icon(
                    Icons.checkroom_outlined,
                    size: 48,
                    color: AppColors.outline,
                  ),
                );
              }

              final imageUrl = '${ApiService.baseUrl}$imagePath';

              print('🖼️ Outfit preview URL: $imageUrl');

              return Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(AppRadius.large),
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    print('❌ Failed to load outfit preview:');
                    print(imageUrl);
                    print(error);

                    return const Center(
                      child: Icon(
                        Icons.checkroom_outlined,
                        size: 48,
                        color: AppColors.outline,
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 12),

        _buildRecommendationIndicator(),
      ],
    );
  }

  Widget _buildRecommendationIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_recommendations.length, (index) {
        final isSelected = index == _selectedRecommendationIndex;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isSelected ? 22 : 7,
          height: 7,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.outlineVariant,
            borderRadius: BorderRadius.circular(10),
          ),
        );
      }),
    );
  }

  // ============================================================
  // RECOMMENDATION ACTIONS
  // ============================================================

  Widget _buildRecommendationActions() {
    final outfitId = _recommendation?['id']?.toString() ?? '';

    final feedback = _feedbackByOutfitId[outfitId];

    final isLiked = feedback == 'LIKE';
    final isDisliked = feedback == 'DISLIKE';

    return Row(
      children: [
        _buildRoundActionButton(
          icon: isDisliked ? Icons.thumb_down : Icons.thumb_down_outlined,
          isSelected: isDisliked,
          onTap: _handleDislike,
        ),

        const SizedBox(width: 12),

        Expanded(
          child: SizedBox(
            height: 56,
            child: ElevatedButton.icon(
              onPressed: _openVirtualTryOn,
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

        _buildRoundActionButton(
          icon: isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
          isSelected: isLiked,
          onTap: _handleLike,
        ),
      ],
    );
  }

  Widget _buildRoundActionButton({
    required IconData icon,
    required VoidCallback onTap,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : AppColors.primary.withOpacity(0.25),
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : AppColors.white.withOpacity(0.25),
            width: isSelected ? 2 : 1,
          ),
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
                    'Choose a date and add optional notes',
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
    final firstDay = DateTime(
      _scheduleDisplayedMonth.year,
      _scheduleDisplayedMonth.month,
      1,
    );

    final daysInMonth = _daysInMonth(_scheduleDisplayedMonth);

    // Monday = 1, so Monday needs zero empty cells.
    final leadingEmptyDays = firstDay.weekday - 1;

    final totalCells = ((leadingEmptyDays + daysInMonth + 6) ~/ 7) * 7;

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
                    '${_scheduleMonthName(_scheduleDisplayedMonth.month)} '
                    '${_scheduleDisplayedMonth.year}',
                    style: AppTextStyles.headlineSmall.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                  Row(
                    children: [
                      _buildCalendarArrow(Icons.chevron_left, () {
                        setSheetState(() {
                          _scheduleDisplayedMonth = DateTime(
                            _scheduleDisplayedMonth.year,
                            _scheduleDisplayedMonth.month - 1,
                            1,
                          );
                        });
                      }),

                      const SizedBox(width: 4),

                      _buildCalendarArrow(Icons.chevron_right, () {
                        setSheetState(() {
                          _scheduleDisplayedMonth = DateTime(
                            _scheduleDisplayedMonth.year,
                            _scheduleDisplayedMonth.month + 1,
                            1,
                          );
                        });
                      }),
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
                itemCount: totalCells,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  mainAxisExtent: 42,
                ),
                itemBuilder: (_, index) {
                  final day = index - leadingEmptyDays + 1;

                  if (day < 1 || day > daysInMonth) {
                    return const SizedBox.shrink();
                  }

                  final date = DateTime(
                    _scheduleDisplayedMonth.year,
                    _scheduleDisplayedMonth.month,
                    day,
                  );

                  final isSelected =
                      _selectedDate.year == date.year &&
                      _selectedDate.month == date.month &&
                      _selectedDate.day == date.day;

                  return GestureDetector(
                    onTap: () {
                      setSheetState(() {
                        _selectedDate = date;
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
              // Notes
              Text(
                'NOTES',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.onSurfaceVariant,
                  letterSpacing: 1.3,
                ),
              ),

              const SizedBox(height: 8),

              TextField(
                controller: _scheduleNotesController,
                maxLength: 500,
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: 'Add a note about this look...',
                  hintStyle: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                  filled: true,
                  fillColor: AppColors.surfaceContainerHigh,
                  counterText: '',
                  contentPadding: const EdgeInsets.all(14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.small),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.small),
                    borderSide: BorderSide(color: AppColors.outlineVariant),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.small),
                    borderSide: const BorderSide(color: AppColors.primary),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Confirm
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _isSavingSchedule ? null : _confirmSchedule,
                  icon: const Icon(Icons.event_available, size: 18),
                  label: Text(
                    _isSavingSchedule ? 'SAVING...' : 'ADD TO OUTFIT DIARY',
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

  Widget _buildCalendarArrow(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerHigh,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 18, color: AppColors.onSurfaceVariant),
      ),
    );
  }

  String _scheduleMonthName(int month) {
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

  int _daysInMonth(DateTime month) {
    return DateTime(month.year, month.month + 1, 0).day;
  }

  Widget _buildRecommendationError() {
    return Padding(
      padding: const EdgeInsets.only(top: 60, bottom: 60),
      child: Column(
        children: [
          const Icon(
            Icons.checkroom_outlined,
            size: 56,
            color: AppColors.outline,
          ),

          const SizedBox(height: 20),

          Text(
            'Unable to Create an Outfit',
            style: AppTextStyles.headlineMedium.copyWith(
              color: AppColors.primary,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 8),

          Text(
            _recommendationError ?? 'Something went wrong.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),

          const SizedBox(height: 24),

          ElevatedButton(
            onPressed: _loadRecommendation,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
            ),
            child: const Text('TRY AGAIN'),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationLoading() {
    return Padding(
      padding: const EdgeInsets.only(top: 100, bottom: 100),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.10),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          Text(
            'Creating Your Look',
            style: AppTextStyles.headlineMedium.copyWith(
              color: AppColors.primary,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 8),

          Text(
            'AI is analysing your wardrobe and creating outfit recommendations.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),

          const SizedBox(height: 20),

          Text(
            'THIS MAY TAKE A MOMENT',
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.onSurfaceVariant,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationContext() {
    return Row(
      children: [
        Icon(
          Icons.auto_awesome_outlined,
          size: 18,
          color: AppColors.onSurfaceVariant,
        ),
        const SizedBox(width: 8),
        Text(
          '${widget.occasion} · ${widget.mood}',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
