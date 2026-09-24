import 'package:flutter/material.dart';
import 'package:frontend/theme/app_colors.dart';
import 'package:frontend/theme/app_text_styles.dart';
import 'package:frontend/theme/app_radius.dart';
import 'package:frontend/widgets/app_header_back.dart';

class VirtualTryOnPage extends StatefulWidget {
  const VirtualTryOnPage({super.key});

  @override
  State<VirtualTryOnPage> createState() => _VirtualTryOnPageState();
}

class _VirtualTryOnPageState extends State<VirtualTryOnPage> {
  // ============================================================
  // MOCK DATA
  // ============================================================

  final String _previewImage =
      'https://lh3.googleusercontent.com/aida-public/AB6AXuCeEZMNSSPfjmxU8qkowb_gYN7kWIPXJZAhWo3yk1ebtegE_bRxi7FDMNjwTgFoSWJEvm4xdvdVjATxdbEzhuRbNioAF0Sb3eOYlXOeFaIeKwxRgAYDWOAWJ_4OgGSSS5mxxRIu1FDvTssKAHh9zt_NsKdyq5H00pUJbPVOlz8rjt-GDnc1bZhkmH_CvgpqKX4uFqai3uN0jakEV5NfXsBVkkbUqCHVw7PZEiPX6rkIbge6U7uD7Onv';

  final List<Map<String, String>> _outerwear = [
    {
      'category': 'TAILORED',
      'name': 'Wool Blazer',
      'image':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuAMoP20nrcjuXCCt-07hLgYqOwVXWynnQPGrl7QbZ889kHkvIeKGftovtf8m3kCHJH1Rr6-G0F4saIDB0psrPmczmPYCCkcBVck1PI1OKPRGHoC7Nv5BvSIPU17h8JKRcPDjSY5jojxVuSvHEoUg3V6pswbbZvx_9-sF3PqLpPsuSPGhtqYNMqQp0Fe86ZALwCxGi3C2C7lQFgciVW1RlUesk-pA5QRrMFJg8A_1hE1_JBoDTMwH7tl',
    },
    {
      'category': 'SILK BLEND',
      'name': 'Asymmetric Coat',
      'image':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuBuUCrfNZtOHkpihxbPZkIwqXdZ41vI99BT9WzjKwVmpLHoWWt8FlUg5Au61mWlkZnQ7KrtoMW69XXXDd8f_1Qq9b3LfYolTarRROw359obebR70b5eJ_BjUjFHMoZAlgZ5PmOXWS3b8qTrBlsPtT8wOPlY-QTX05Qf4oWbGpAP6Zp7Bf_dKcf6_8slOcfWPJ8D_iTtfJfT-TG68tWQgWDkW7onilESzKZB6hl3_oj_hYc08tHia_RN',
    },
    {
      'category': 'DOUBLE-B',
      'name': 'Cropped Jacket',
      'image':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuCi9aekNOKNcj08oW_JsF-kn9Z868ESwQsnFMP2OmSJW3e78CYjSZi9QpP1Rl35ektQe44joU6hdvrRkc2Mb3LJM4D0wc9O2j03_sMyeiLlWmyEgpuV7pvNnWUjgSOT4RmJ3rbW6BPP9MxiBrwcSdqEGRjy6bHxNRqtNX9v1IYWf2iCbZAp-Mo2HcSmWUrwIJr4HK1A8MlXdMOqxyTuhR56uW89UZsPoo_scNJChuA6ShABEdrtRhBj',
    },
  ];

  final List<Map<String, String>> _bottoms = [
    {
      'category': 'TAILORED',
      'name': 'Pleated Trousers',
      'image':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuAMoP20nrcjuXCCt-07hLgYqOwVXWynnQPGrl7QbZ889kHkvIeKGftovtf8m3kCHJH1Rr6-G0F4saIDB0psrPmczmPYCCkcBVck1PI1OKPRGHoC7Nv5BvSIPU17h8JKRcPDjSY5jojxVuSvHEoUg3V6pswbbZvx_9-sF3PqLpPsuSPGhtqYNMqQp0Fe86ZALwCxGi3C2C7lQFgciVW1RlUesk-pA5QRrMFJg8A_1hE1_JBoDTMwH7tl',
    },
    {
      'category': 'WOOL',
      'name': 'Wide Leg Trousers',
      'image':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuBuUCrfNZtOHkpihxbPZkIwqXdZ41vI99BT9WzjKwVmpLHoWWt8FlUg5Au61mWlkZnQ7KrtoMW69XXXDd8f_1Qq9b3LfYolTarRROw359obebR70b5eJ_BjUjFHMoZAlgZ5PmOXWS3b8qTrBlsPtT8wOPlY-QTX05Qf4oWbGpAP6Zp7Bf_dKcf6_8slOcfWPJ8D_iTtfJfT-TG68tWQgWDkW7onilESzKZB6hl3_oj_hYc08tHia_RN',
    },
    {
      'category': 'RELAXED',
      'name': 'Straight Trousers',
      'image':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuCi9aekNOKNcj08oW_JsF-kn9Z868ESwQsnFMP2OmSJW3e78CYjSZi9QpP1Rl35ektQe44joU6hdvrRkc2Mb3LJM4D0wc9O2j03_sMyeiLlWmyEgpuV7pvNnWUjgSOT4RmJ3rbW6BPP9MxiBrwcSdqEGRjy6bHxNRqtNX9v1IYWf2iCbZAp-Mo2HcSmWUrwIJr4HK1A8MlXdMOqxyTuhR56uW89UZsPoo_scNJChuA6ShABEdrtRhBj',
    },
  ];

  final List<Map<String, String>> _footwear = [
    {
      'category': 'LEATHER',
      'name': 'Classic Loafers',
      'image':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuAMoP20nrcjuXCCt-07hLgYqOwVXWynnQPGrl7QbZ889kHkvIeKGftovtf8m3kCHJH1Rr6-G0F4saIDB0psrPmczmPYCCkcBVck1PI1OKPRGHoC7Nv5BvSIPU17h8JKRcPDjSY5jojxVuSvHEoUg3V6pswbbZvx_9-sF3PqLpPsuSPGhtqYNMqQp0Fe86ZALwCxGi3C2C7lQFgciVW1RlUesk-pA5QRrMFJg8A_1hE1_JBoDTMwH7tl',
    },
    {
      'category': 'MINIMAL',
      'name': 'Leather Derbies',
      'image':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuBuUCrfNZtOHkpihxbPZkIwqXdZ41vI99BT9WzjKwVmpLHoWWt8FlUg5Au61mWlkZnQ7KrtoMW69XXXDd8f_1Qq9b3LfYolTarRROw359obebR70b5eJ_BjUjFHMoZAlgZ5PmOXWS3b8qTrBlsPtT8wOPlY-QTX05Qf4oWbGpAP6Zp7Bf_dKcf6_8slOcfWPJ8D_iTtfJfT-TG68tWQgWDkW7onilESzKZB6hl3_oj_hYc08tHia_RN',
    },
    {
      'category': 'FORMAL',
      'name': 'Oxford Shoes',
      'image':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuCi9aekNOKNcj08oW_JsF-kn9Z868ESwQsnFMP2OmSJW3e78CYjSZi9QpP1Rl35ektQe44joU6hdvrRkc2Mb3LJM4D0wc9O2j03_sMyeiLlWmyEgpuV7pvNnWUjgSOT4RmJ3rbW6BPP9MxiBrwcSdqEGRjy6bHxNRqtNX9v1IYWf2iCbZAp-Mo2HcSmWUrwIJr4HK1A8MlXdMOqxyTuhR56uW89UZsPoo_scNJChuA6ShABEdrtRhBj',
    },
  ];

  final List<Map<String, String>> _accessories = [
    {
      'category': 'LEATHER',
      'name': 'Structured Bag',
      'image':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuAMoP20nrcjuXCCt-07hLgYqOwVXWynnQPGrl7QbZ889kHkvIeKGftovtf8m3kCHJH1Rr6-G0F4saIDB0psrPmczmPYCCkcBVck1PI1OKPRGHoC7Nv5BvSIPU17h8JKRcPDjSY5jojxVuSvHEoUg3V6pswbbZvx_9-sF3PqLpPsuSPGhtqYNMqQp0Fe86ZALwCxGi3C2C7lQFgciVW1RlUesk-pA5QRrMFJg8A_1hE1_JBoDTMwH7tl',
    },
    {
      'category': 'METAL',
      'name': 'Minimal Watch',
      'image':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuBuUCrfNZtOHkpihxbPZkIwqXdZ41vI99BT9WzjKwVmpLHoWWt8FlUg5Au61mWlkZnQ7KrtoMW69XXXDd8f_1Qq9b3LfYolTarRROw359obebR70b5eJ_BjUjFHMoZAlgZ5PmOXWS3b8qTrBlsPtT8wOPlY-QTX05Qf4oWbGpAP6Zp7Bf_dKcf6_8slOcfWPJ8D_iTtfJfT-TG68tWQgWDkW7onilESzKZB6hl3_oj_hYc08tHia_RN',
    },
    {
      'category': 'CLASSIC',
      'name': 'Leather Belt',
      'image':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuCi9aekNOKNcj08oW_JsF-kn9Z868ESwQsnFMP2OmSJW3e78CYjSZi9QpP1Rl35ektQe44joU6hdvrRkc2Mb3LJM4D0wc9O2j03_sMyeiLlWmyEgpuV7pvNnWUjgSOT4RmJ3rbW6BPP9MxiBrwcSdqEGRjy6bHxNRqtNX9v1IYWf2iCbZAp-Mo2HcSmWUrwIJr4HK1A8MlXdMOqxyTuhR56uW89UZsPoo_scNJChuA6ShABEdrtRhBj',
    },
  ];

  String _selectedCategory = 'Outerwear';
  int _selectedItem = 1;

  DateTime _selectedDate = DateTime(2024, 11, 14);
  String _selectedOccasion = 'All Day';

  // ============================================================
  // HELPERS
  // ============================================================

  List<Map<String, String>> get _currentItems {
    switch (_selectedCategory) {
      case 'Bottoms':
        return _bottoms;
      case 'Footwear':
        return _footwear;
      case 'Acc.':
        return _accessories;
      default:
        return _outerwear;
    }
  }

  // ============================================================
  // ACTIONS
  // ============================================================

  void _selectCategory(String category) {
    setState(() {
      _selectedCategory = category;
      _selectedItem = 0;
    });
  }

  void _selectItem(int index) {
    setState(() {
      _selectedItem = index;
    });
  }

  void _resetLook() {
    setState(() {
      _selectedCategory = 'Outerwear';
      _selectedItem = 1;
    });

    _showMessage('Mannequin reset to baseline');
  }

  void _wearToday() {
    _showMessage('Look added to today’s history');
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
                    const SizedBox(height: 20),
                    _buildPreviewStage(),
                    const SizedBox(height: 32),
                    _buildGarmentLayering(),
                    const SizedBox(height: 32),
                    _buildActionBar(),
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'ATELIER DIGITAL • LOOK 04',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.secondary,
                letterSpacing: 1.2,
              ),
            ),
            Text(
              'MANNEQUIN 01',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.primary,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),

        const SizedBox(height: 4),

        Text(
          'Virtual Fitting Suite',
          style: AppTextStyles.headlineMedium.copyWith(
            color: AppColors.primary,
          ),
        ),

        const SizedBox(height: 4),

        Text(
          'Swipe through artisanal pieces to construct your bespoke silhouette.',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // PREVIEW STAGE
  // ============================================================

  Widget _buildPreviewStage() {
    return Container(
      width: double.infinity,
      height: 380,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.network(
              _previewImage,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) {
                return Container(
                  color: AppColors.surfaceContainerLow,
                  child: const Center(
                    child: Icon(
                      Icons.checkroom_outlined,
                      size: 72,
                      color: AppColors.outline,
                    ),
                  ),
                );
              },
            ),
          ),

          // Ambient overlay
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.secondaryDim.withOpacity(0.18),
                    Colors.transparent,
                    AppColors.primaryDim.withOpacity(0.10),
                  ],
                ),
              ),
            ),
          ),

          // Fit score
          Positioned(
            right: 16,
            bottom: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(AppRadius.small),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.check_circle,
                    size: 16,
                    color: AppColors.white,
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SILHOUETTE MATCH',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.primaryDim,
                          letterSpacing: 0.7,
                        ),
                      ),
                      Text(
                        '98% IDEAL FIT',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
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
  // GARMENT LAYERING
  // ============================================================

  Widget _buildGarmentLayering() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'GARMENT LAYERING',
              style: AppTextStyles.headlineSmall.copyWith(
                color: AppColors.primary,
                letterSpacing: 1.2,
              ),
            ),

            GestureDetector(
              onTap: _resetLook,
              child: Text(
                'RESET ALL',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.secondary,
                  letterSpacing: 1.0,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Category tabs
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildCategoryTab('Outerwear'),
              const SizedBox(width: 8),
              _buildCategoryTab('Bottoms'),
              const SizedBox(width: 8),
              _buildCategoryTab('Footwear'),
              const SizedBox(width: 8),
              _buildCategoryTab('Acc.'),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Items
        SizedBox(
          height: 190,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _currentItems.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, index) {
              return _buildGarmentCard(
                item: _currentItems[index],
                index: index,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryTab(String label) {
    final isSelected = _selectedCategory == label;

    return GestureDetector(
      onTap: () => _selectCategory(label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : AppColors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(AppRadius.small),
        ),
        child: Text(
          label.toUpperCase(),
          style: AppTextStyles.labelMedium.copyWith(
            color: isSelected ? AppColors.white : AppColors.onSurface,
            letterSpacing: 0.8,
          ),
        ),
      ),
    );
  }

  Widget _buildGarmentCard({
    required Map<String, String> item,
    required int index,
  }) {
    final isSelected = _selectedItem == index;

    return GestureDetector(
      onTap: () => _selectItem(index),
      child: Container(
        width: 150,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 1.2,
          ),
          borderRadius: BorderRadius.circular(AppRadius.small),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.small),
                child: SizedBox(
                  width: double.infinity,
                  child: Image.network(
                    item['image']!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) {
                      return Container(
                        color: AppColors.surfaceContainerHigh,
                        child: const Center(
                          child: Icon(
                            Icons.checkroom_outlined,
                            color: AppColors.outline,
                            size: 36,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),

            Text(
              item['category']!,
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.secondary,
                letterSpacing: 0.7,
              ),
            ),

            const SizedBox(height: 2),

            Text(
              item['name']!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // ACTION BAR
  // ============================================================

  Widget _buildActionBar() {
    return Column(
      children: [
        // Wear Today
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            onPressed: _wearToday,
            icon: const Icon(Icons.calendar_today_outlined, size: 18),
            label: Text(
              'WEAR TODAY & LOG TO HISTORY',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.white,
                letterSpacing: 1.0,
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

        const SizedBox(height: 12),

        // Schedule
        GestureDetector(
          onTap: _openScheduleSheet,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              border: Border.all(
                color: AppColors.outlineVariant.withOpacity(0.3),
              ),
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
        ),
      ],
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

    // Monday = 1, Sunday = 7
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
                    _monthName(_selectedDate.month),
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

  String _monthName(int month) {
    const months = [
      'January 2024',
      'February 2024',
      'March 2024',
      'April 2024',
      'May 2024',
      'June 2024',
      'July 2024',
      'August 2024',
      'September 2024',
      'October 2024',
      'November 2024',
      'December 2024',
    ];

    return months[month - 1];
  }
}
