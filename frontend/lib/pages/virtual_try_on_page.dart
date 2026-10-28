// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

import 'package:frontend/theme/app_colors.dart';
import 'package:frontend/theme/app_text_styles.dart';
import 'package:frontend/theme/app_radius.dart';
import 'package:frontend/widgets/app_page_header.dart';

class VirtualTryOnPage extends StatefulWidget {
  final Map<String, dynamic> outfit;

  const VirtualTryOnPage({super.key, required this.outfit});

  @override
  State<VirtualTryOnPage> createState() => _VirtualTryOnPageState();
}

class _VirtualTryOnPageState extends State<VirtualTryOnPage> {
  // ============================================================
  // STATE
  // ============================================================

  String? _personImagePath;
  String? _generatedImageUrl;

  bool _isGenerating = false;

  DateTime _selectedDate = DateTime.now();
  String _selectedOccasion = 'All Day';

  // ============================================================
  // OUTFIT HELPERS
  // ============================================================

  List<dynamic> get _outfitItems {
    final items = widget.outfit['items'];

    if (items is List) {
      return items;
    }

    return [];
  }

  String get _outfitTitle {
    final title = widget.outfit['title']?.toString();

    if (title == null || title.trim().isEmpty) {
      return 'Recommended Outfit';
    }

    return title;
  }

  String? _itemImagePath(dynamic item) {
    if (item is! Map) {
      return null;
    }

    final processedPath = item['processed_image_path']?.toString();

    if (processedPath != null && processedPath.isNotEmpty) {
      return processedPath;
    }

    final imagePath = item['image_path']?.toString();

    if (imagePath != null && imagePath.isNotEmpty) {
      return imagePath;
    }

    final image = item['image']?.toString();

    if (image != null && image.isNotEmpty) {
      return image;
    }

    return null;
  }

  String _itemName(dynamic item) {
    if (item is! Map) {
      return 'Clothing Item';
    }

    final name = item['name']?.toString();

    if (name == null || name.trim().isEmpty) {
      return 'Clothing Item';
    }

    return name;
  }

  String _itemCategory(dynamic item) {
    if (item is! Map) {
      return 'ITEM';
    }

    final category = item['category']?.toString().trim();

    if (category == null || category.isEmpty) {
      return 'ITEM';
    }

    return category.toUpperCase();
  }

  // ============================================================
  // IMAGE HELPERS
  // ============================================================

  String _buildImageUrl(String path) {
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }

    // TODO:
    // Replace this temporary base URL with ApiService.baseUrl
    // when connecting the real backend.
    const baseUrl = 'http://127.0.0.1:8000';

    if (path.startsWith('/')) {
      return '$baseUrl$path';
    }

    return '$baseUrl/$path';
  }

  // ============================================================
  // ACTIONS
  // ============================================================

  void _takePhoto() {
    // TODO:
    // Connect image_picker camera here later.
    _showMessage('Camera will be connected to virtual try-on.');
  }

  void _uploadPhoto() {
    // TODO:
    // Connect image_picker gallery here later.
    _showMessage('Photo upload will be connected to virtual try-on.');
  }

  Future<void> _generateTryOn() async {
    if (_personImagePath == null) {
      _showMessage('Please upload or take a full-body photo first.');
      return;
    }

    setState(() {
      _isGenerating = true;
    });

    try {
      // ========================================================
      // TODO: VIRTUAL TRY-ON API
      // ========================================================
      //
      // Later:
      //
      // final result = await ApiService.generateVirtualTryOn(
      //   personImagePath: _personImagePath!,
      //   outfitId: widget.outfit['id'],
      // );
      //
      // setState(() {
      //   _generatedImageUrl =
      //       result['image_url']?.toString();
      // });
      //
      // ========================================================

      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;

      setState(() {
        _isGenerating = false;
      });

      _showMessage('Virtual try-on API will be connected here.');
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isGenerating = false;
      });

      _showMessage('Unable to generate virtual try-on.');
    }
  }

  void _tryAnotherPhoto() {
    setState(() {
      _personImagePath = null;
      _generatedImageUrl = null;
    });
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(milliseconds: 2200),
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
        child: Column(
          children: [
            AppPageHeader(
              title: 'VIRTUAL TRY ON',
              onProfileTap: () {
                _showMessage('Profile will be connected later.');
              },
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildIntro(),

                    const SizedBox(height: 24),

                    _buildPersonPhotoSection(),

                    const SizedBox(height: 32),

                    _buildTryingOnSection(),

                    const SizedBox(height: 24),

                    _buildGenerateButton(),

                    if (_isGenerating) ...[
                      const SizedBox(height: 24),
                      _buildGeneratingCard(),
                    ],

                    if (_generatedImageUrl != null) ...[
                      const SizedBox(height: 32),
                      _buildGeneratedResult(),
                    ],

                    const SizedBox(height: 32),

                    _buildScheduleButton(),
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
          'AI FITTING STUDIO',
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.secondary,
            letterSpacing: 1.4,
          ),
        ),

        const SizedBox(height: 4),

        Text(
          'See This Outfit on You',
          style: AppTextStyles.headlineMedium.copyWith(
            color: AppColors.primary,
          ),
        ),

        const SizedBox(height: 6),

        Text(
          'Upload a clear, full-body photo to preview '
          'your recommended outfit on you.',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // PERSON PHOTO
  // ============================================================

  Widget _buildPersonPhotoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(label: 'YOUR PHOTO', title: 'Full-Body Photo'),

        const SizedBox(height: 12),

        Container(
          width: double.infinity,
          height: 360,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(AppRadius.medium),
            border: Border.all(
              color: AppColors.outlineVariant.withOpacity(0.35),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: _personImagePath == null
              ? _buildPhotoPlaceholder()
              : _buildSelectedPersonImage(),
        ),

        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _takePhoto,
                  icon: const Icon(Icons.photo_camera_outlined, size: 19),
                  label: Text(
                    'TAKE PHOTO',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.white,
                      letterSpacing: 0.8,
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

            Expanded(
              child: SizedBox(
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: _uploadPhoto,
                  icon: const Icon(Icons.upload_outlined, size: 19),
                  label: Text(
                    'UPLOAD PHOTO',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.primary,
                      letterSpacing: 0.8,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.small),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.info_outline,
              size: 16,
              color: AppColors.onSurfaceVariant,
            ),

            const SizedBox(width: 8),

            Expanded(
              child: Text(
                'For the best result, use a clear '
                'front-facing photo where your full body '
                'is visible.',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPhotoPlaceholder() {
    return Container(
      color: AppColors.surfaceContainerLow,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.06),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person_outline,
                  size: 38,
                  color: AppColors.primary,
                ),
              ),

              const SizedBox(height: 18),

              Text(
                'Add Your Photo',
                style: AppTextStyles.headlineSmall.copyWith(
                  color: AppColors.primary,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                'Take or upload a full-body photo '
                'to begin your virtual try-on.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedPersonImage() {
    // This will be changed to Image.file()
    // after image_picker is connected.
    return Container(
      color: AppColors.surfaceContainerLow,
      child: const Center(
        child: Icon(Icons.person, size: 100, color: AppColors.outline),
      ),
    );
  }

  // ============================================================
  // TRYING ON
  // ============================================================

  Widget _buildTryingOnSection() {
    final items = _outfitItems;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(label: 'RECOMMENDED LOOK', title: 'Trying On'),

        const SizedBox(height: 4),

        Text(
          _outfitTitle,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),

        const SizedBox(height: 14),

        if (items.isEmpty)
          _buildNoOutfitItems()
        else
          SizedBox(
            height: 190,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (_, index) {
                return _buildOutfitItemCard(items[index]);
              },
            ),
          ),
      ],
    );
  }

  Widget _buildOutfitItemCard(dynamic item) {
    final imagePath = _itemImagePath(item);

    return Container(
      width: 150,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.small),
        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.small),
              child: Container(
                width: double.infinity,
                color: AppColors.surfaceContainerHigh,
                child: imagePath != null
                    ? Image.network(
                        _buildImageUrl(imagePath),
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) {
                          return _buildGarmentPlaceholder();
                        },
                      )
                    : _buildGarmentPlaceholder(),
              ),
            ),
          ),

          const SizedBox(height: 8),

          Text(
            _itemCategory(item),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.secondary,
              letterSpacing: 0.7,
            ),
          ),

          const SizedBox(height: 2),

          Text(
            _itemName(item),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGarmentPlaceholder() {
    return const Center(
      child: Icon(Icons.checkroom_outlined, size: 38, color: AppColors.outline),
    );
  }

  Widget _buildNoOutfitItems() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.small),
      ),
      child: Row(
        children: [
          const Icon(Icons.checkroom_outlined, color: AppColors.outline),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'No clothing items were found '
              'for this recommendation.',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // GENERATE
  // ============================================================

  Widget _buildGenerateButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: _isGenerating ? null : _generateTryOn,
        icon: _isGenerating
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.white,
                ),
              )
            : const Icon(Icons.auto_awesome, size: 19),
        label: Text(
          _isGenerating ? 'GENERATING TRY-ON...' : 'GENERATE TRY-ON',
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.white,
            letterSpacing: 1.0,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          disabledBackgroundColor: AppColors.primary,
          disabledForegroundColor: AppColors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.small),
          ),
        ),
      ),
    );
  }

  Widget _buildGeneratingCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.medium),
      ),
      child: Column(
        children: [
          const SizedBox(
            width: 26,
            height: 26,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: AppColors.primary,
            ),
          ),

          const SizedBox(height: 14),

          Text(
            'Creating Your Virtual Look',
            style: AppTextStyles.headlineSmall.copyWith(
              color: AppColors.primary,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            'Your photo and selected garments '
            'are being prepared for virtual try-on.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // GENERATED RESULT
  // ============================================================

  Widget _buildGeneratedResult() {
    final resultUrl = _generatedImageUrl;

    if (resultUrl == null) {
      return const SizedBox();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          label: 'AI GENERATED PREVIEW',
          title: 'Your Virtual Look',
        ),

        const SizedBox(height: 12),

        Container(
          width: double.infinity,
          height: 460,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(AppRadius.medium),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Image.network(
            _buildImageUrl(resultUrl),
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) {
              return Container(
                color: AppColors.surfaceContainerLow,
                child: const Center(
                  child: Icon(
                    Icons.image_outlined,
                    size: 64,
                    color: AppColors.outline,
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 12),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(AppRadius.small),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.auto_awesome_outlined,
                size: 18,
                color: AppColors.secondary,
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Text(
                  'AI-generated preview. Results may '
                  'not perfectly represent actual fit, '
                  'fabric drape, colour, or sizing.',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton.icon(
            onPressed: _tryAnotherPhoto,
            icon: const Icon(Icons.refresh, size: 19),
            label: Text(
              'TRY ANOTHER PHOTO',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.primary,
                letterSpacing: 0.9,
              ),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.small),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // SECTION HEADER
  // ============================================================

  Widget _buildSectionHeader({required String label, required String title}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.secondary,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          title,
          style: AppTextStyles.headlineSmall.copyWith(color: AppColors.primary),
        ),
      ],
    );
  }

  // ============================================================
  // SCHEDULE THIS LOOK
  // ============================================================

  Widget _buildScheduleButton() {
    return GestureDetector(
      onTap: _openScheduleSheet,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          border: Border.all(color: AppColors.outlineVariant.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(AppRadius.small),
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
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.event_outlined,
                size: 20,
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
                      letterSpacing: 0.9,
                      fontWeight: FontWeight.w600,
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
                    letterSpacing: 0.8,
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
      barrierColor: AppColors.primary.withOpacity(0.60),
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
    final firstDay = DateTime(_selectedDate.year, _selectedDate.month, 1);

    final daysInMonth = DateTime(
      _selectedDate.year,
      _selectedDate.month + 1,
      0,
    ).day;

    final startingOffset = firstDay.weekday - 1;

    final totalCells = ((startingOffset + daysInMonth) / 7).ceil() * 7;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
                          'CALENDAR PLANNER',
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
                color: AppColors.outlineVariant.withOpacity(0.3),
              ),

              const SizedBox(height: 20),

              // Month navigation
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _monthName(_selectedDate.month, _selectedDate.year),
                    style: AppTextStyles.headlineSmall.copyWith(
                      color: AppColors.primary,
                    ),
                  ),

                  Row(
                    children: [
                      _buildCalendarArrow(Icons.chevron_left, () {
                        setSheetState(() {
                          _selectedDate = DateTime(
                            _selectedDate.year,
                            _selectedDate.month - 1,
                            1,
                          );
                        });
                      }),
                      const SizedBox(width: 4),
                      _buildCalendarArrow(Icons.chevron_right, () {
                        setSheetState(() {
                          _selectedDate = DateTime(
                            _selectedDate.year,
                            _selectedDate.month + 1,
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
              Row(
                children: const ['M', 'T', 'W', 'T', 'F', 'S', 'S'].map((day) {
                  return Expanded(
                    child: Center(
                      child: Text(
                        day,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1,
                          color: AppColors.secondary,
                        ),
                      ),
                    ),
                  );
                }).toList(),
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
                  final day = index - startingOffset + 1;

                  if (day < 1 || day > daysInMonth) {
                    return const SizedBox();
                  }

                  final isSelected = day == _selectedDate.day;

                  return GestureDetector(
                    onTap: () {
                      setSheetState(() {
                        _selectedDate = DateTime(
                          _selectedDate.year,
                          _selectedDate.month,
                          day,
                        );
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
                'OCCASION & TIMING',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.secondary,
                  letterSpacing: 1.2,
                ),
              ),

              const SizedBox(height: 8),

              Row(
                children: [
                  _buildOccasionButton('All Day', setSheetState),
                  const SizedBox(width: 8),
                  _buildOccasionButton('Daytime', setSheetState),
                  const SizedBox(width: 8),
                  _buildOccasionButton('Evening', setSheetState),
                ],
              ),

              const SizedBox(height: 20),

              // Confirm
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);

                    _showMessage('Look added to your calendar.');
                  },
                  icon: const Icon(Icons.calendar_month, size: 18),
                  label: Text(
                    'ADD TO CALENDAR',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.white,
                      letterSpacing: 1.1,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryContainer,
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

  Widget _buildOccasionButton(String label, StateSetter setSheetState) {
    final isSelected = _selectedOccasion == label;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setSheetState(() {
            _selectedOccasion = label;
          });
        },
        child: Container(
          height: 42,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary
                : AppColors.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(AppRadius.small),
          ),
          child: Text(
            label.toUpperCase(),
            style: AppTextStyles.labelSmall.copyWith(
              color: isSelected ? AppColors.white : AppColors.onSurface,
              letterSpacing: 0.7,
            ),
          ),
        ),
      ),
    );
  }

  String _monthName(int month, int year) {
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

    return '${months[month - 1]} $year';
  }
}
