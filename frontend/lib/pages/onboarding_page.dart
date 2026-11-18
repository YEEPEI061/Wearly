import 'package:flutter/material.dart';
import 'package:frontend/theme/app_colors.dart';
import 'package:frontend/theme/app_text_styles.dart';
import 'package:frontend/theme/app_radius.dart';
import 'package:frontend/services/api_service.dart';

class OnboardingPage extends StatefulWidget {
  final bool isEditing;

  const OnboardingPage({super.key, this.isEditing = false});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  // ============================================================
  // SELECTIONS
  // ============================================================

  String? _selectedGender;

  final Set<String> _selectedStyles = {};
  final Set<String> _selectedColors = {};
  final Set<String> _selectedCategories = {};
  final Set<String> _selectedOccasions = {};
  final Set<String> _dislikedStyles = {};
  final Set<String> _dislikedColors = {};

  bool _isLoadingPreferences = false;
  bool _isSavingPreferences = false;

  // ============================================================
  // DATA
  // ============================================================

  final List<String> _genders = [
    'Women / Girl',
    'Men / Boy',
    'Non-Binary / All',
  ];

  final List<String> _styles = [
    'Casual',
    'Smart Casual',
    'Formal',
    'Sporty',
    'Streetwear',
    'Minimalist',
    'Elegant',
    'Vintage',
    'Preppy',
    'Relaxed',
  ];

  final List<Map<String, dynamic>> _colors = [
    {'name': 'Black', 'color': Color(0xFF222222)},
    {'name': 'White', 'color': Color(0xFFF5F5F5)},
    {'name': 'Beige', 'color': Color(0xFFD8C3A5)},
    {'name': 'Brown', 'color': Color(0xFF795548)},
    {'name': 'Navy Blue', 'color': Color(0xFF1E3A5F)},
    {'name': 'Blue', 'color': Color(0xFF2196F3)},
    {'name': 'Green', 'color': Color(0xFF4F7942)},
    {'name': 'Red', 'color': Color(0xFFC62828)},
    {'name': 'Pink', 'color': Color(0xFFE8A0B5)},
    {'name': 'Purple', 'color': Color(0xFF8064A2)},
    {'name': 'Orange', 'color': Color(0xFFE68A35)},
    {'name': 'Yellow', 'color': Color(0xFFE5C453)},
    {'name': 'Grey', 'color': Color(0xFF808080)},
  ];

  final List<String> _categories = ['Upper', 'Lower', 'Full Body'];

  final List<String> _occasions = [
    'Casual / Daily',
    'Work / Study',
    'Formal Events',
    'Going Out',
    'Sports / Activities',
    'Special Occasions',
  ];

  @override
  void initState() {
    super.initState();

    if (widget.isEditing) {
      _loadPreferences();
    }
  }

  // ============================================================
  // ACTIONS
  // ============================================================

  void _selectGender(String gender) {
    setState(() {
      _selectedGender = gender;
    });
  }

  void _toggleSelection(Set<String> selections, String value) {
    setState(() {
      if (selections.contains(value)) {
        selections.remove(value);
      } else {
        selections.add(value);
      }
    });
  }

  Future<void> _continue() async {
    if (_isSavingPreferences || _isLoadingPreferences) return;

    // Prevent selecting the same style as both preferred and disliked.
    final overlappingStyles = _selectedStyles.intersection(_dislikedStyles);

    if (overlappingStyles.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please remove styles selected in both preferred and disliked.',
          ),
        ),
      );
      return;
    }

    // Prevent selecting the same colour as both preferred and disliked.
    final overlappingColors = _selectedColors.intersection(_dislikedColors);

    if (overlappingColors.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please remove colours selected in both preferred and disliked.',
          ),
        ),
      );
      return;
    }

    setState(() {
      _isSavingPreferences = true;
    });

    try {
      await ApiService.updateUserPreferences(
        gender: _selectedGender,
        preferredStyles: _selectedStyles.toList(),
        preferredColors: _selectedColors.toList(),
        preferredCategories: _selectedCategories.toList(),
        preferredOccasions: _selectedOccasions.toList(),
        dislikedStyles: _dislikedStyles.toList(),
        dislikedColors: _dislikedColors.toList(),
      );

      if (!mounted) return;

      if (widget.isEditing) {
        Navigator.pop(context);

        _showMessage('Your preferences have been updated.');
      } else {
        _showMessage('Your preferences have been saved.');
      }
    } catch (e) {
      debugPrint('SAVE USER PREFERENCES ERROR: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to save your preferences. Please try again.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSavingPreferences = false;
        });
      }
    }
  }

  Future<void> _loadPreferences() async {
    setState(() {
      _isLoadingPreferences = true;
    });

    try {
      final data = await ApiService.getUserPreferences();

      if (!mounted) return;

      final preferences = data['preferences'] as Map<String, dynamic>;

      setState(() {
        _selectedGender = data['gender'] as String?;

        _selectedStyles
          ..clear()
          ..addAll(List<String>.from(preferences['preferred_styles'] ?? []));

        _selectedColors
          ..clear()
          ..addAll(List<String>.from(preferences['preferred_colors'] ?? []));

        _selectedCategories
          ..clear()
          ..addAll(
            List<String>.from(preferences['preferred_categories'] ?? []),
          );

        _selectedOccasions
          ..clear()
          ..addAll(List<String>.from(preferences['preferred_occasions'] ?? []));

        _dislikedStyles
          ..clear()
          ..addAll(List<String>.from(preferences['disliked_styles'] ?? []));

        _dislikedColors
          ..clear()
          ..addAll(List<String>.from(preferences['disliked_colors'] ?? []));
      });
    } catch (e) {
      debugPrint('LOAD USER PREFERENCES ERROR: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to load your preferences.')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingPreferences = false;
        });
      }
    }
  }

  void _showMessage(String message) {
    final overlay = Overlay.of(context);

    final overlayEntry = OverlayEntry(
      builder: (overlayContext) {
        return Positioned(
          top: MediaQuery.of(overlayContext).padding.top + 16,
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

                    Flexible(
                      child: Text(
                        message,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
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
  // GENDER PILL
  // ============================================================

  Widget _buildGenderPill(String gender) {
    final bool isSelected = _selectedGender == gender;

    return GestureDetector(
      onTap: () => _selectGender(gender),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(AppRadius.small),
        ),
        child: Text(
          gender,
          style: AppTextStyles.labelMedium.copyWith(
            color: isSelected ? AppColors.white : AppColors.primary,
            letterSpacing: 1.0,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // STYLE PILL
  // ============================================================

  Widget _buildStylePill(String style) {
    final bool isSelected = _selectedStyles.contains(style);

    return GestureDetector(
      onTap: () => _toggleSelection(_selectedStyles, style),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(AppRadius.small),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              style,
              textAlign: TextAlign.center,
              style: AppTextStyles.labelMedium.copyWith(
                color: isSelected ? AppColors.white : AppColors.primary,
                letterSpacing: 0.8,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 6),
              const Icon(Icons.check, size: 14, color: AppColors.white),
            ],
          ],
        ),
      ),
    );
  }

  // ============================================================
  // COLOR SWATCH
  // ============================================================

  Widget _buildColorSwatch({
    required String name,
    required Color color,
    required Set<String> selections,
  }) {
    final bool isSelected = selections.contains(name);

    return GestureDetector(
      onTap: () => _toggleSelection(selections, name),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.outlineVariant,
            width: isSelected ? 1.2 : 1,
          ),
          borderRadius: BorderRadius.circular(AppRadius.small),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(
                  color: name == 'White' || name == 'Beige'
                      ? AppColors.outlineVariant
                      : Colors.transparent,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              name,
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.primary,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 6),
              const Icon(Icons.check, size: 14, color: AppColors.primary),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPreferenceHeading(String title, String description) {
    return Column(
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.secondary,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          description,
          textAlign: TextAlign.center,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildStylePillForSet(String value, Set<String> selections) {
    final bool isSelected = selections.contains(value);

    return GestureDetector(
      onTap: () => _toggleSelection(selections, value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(AppRadius.small),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: AppTextStyles.labelMedium.copyWith(
                color: isSelected ? AppColors.white : AppColors.primary,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 6),
              const Icon(Icons.check, size: 14, color: AppColors.white),
            ],
          ],
        ),
      ),
    );
  }

  // ============================================================
  // PAGE
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 48),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 12),

                // ==================================================
                // HERO IMAGE MOSAIC
                // ==================================================
                _buildImageMosaic(),

                const SizedBox(height: 42),

                // ==================================================
                // TYPOGRAPHY
                // ==================================================
                Column(
                  children: [
                    Text(
                      widget.isEditing
                          ? 'REFINE YOUR PERSONAL STYLE'
                          : 'YOUR PERSONAL STYLIST',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.secondary,
                        letterSpacing: 1.8,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      widget.isEditing
                          ? 'Your style,\nyour way.'
                          : 'Curated elegance,\ntailored to your essence.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.headlineMedium.copyWith(
                        height: 1.18,
                      ),
                    ),

                    const SizedBox(height: 8),

                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 360),
                      child: Text(
                        widget.isEditing
                            ? 'Update your preferences to keep your outfit recommendations aligned with your personal taste.'
                            : 'Bespoke wardrobe curation and intelligent styling recommendations designed exclusively for you.',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // ==================================================
                // GENDER
                // ==================================================
                _buildPreferenceHeading(
                  'SELECT GENDER / IDENTITY',
                  'Choose the clothing preferences that best suit you.',
                ),

                const SizedBox(height: 12),

                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 10,
                  runSpacing: 10,
                  children: _genders.map(_buildGenderPill).toList(),
                ),

                const SizedBox(height: 32),

                // ==================================================
                // PREFERRED STYLES
                // ==================================================
                _buildPreferenceHeading(
                  'YOUR PREFERRED STYLES',
                  'Select all the styles that reflect your personal taste.',
                ),

                const SizedBox(height: 12),

                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  runSpacing: 8,
                  children: _styles.map(_buildStylePill).toList(),
                ),

                const SizedBox(height: 32),

                // ==================================================
                // PREFERRED COLOURS
                // ==================================================
                _buildPreferenceHeading(
                  'FAVOURITE COLOURS',
                  'Which colours do you enjoy wearing?',
                ),

                const SizedBox(height: 12),

                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 10,
                  runSpacing: 10,
                  children: _colors.map((item) {
                    return _buildColorSwatch(
                      name: item['name'] as String,
                      color: item['color'] as Color,
                      selections: _selectedColors,
                    );
                  }).toList(),
                ),

                const SizedBox(height: 32),

                // ==================================================
                // CLOTHING CATEGORIES
                // ==================================================
                _buildPreferenceHeading(
                  'PREFERRED CLOTHING CATEGORIES',
                  'Which types of clothing would you like recommendations for?',
                ),

                const SizedBox(height: 12),

                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 10,
                  runSpacing: 10,
                  children: _categories.map((category) {
                    return _buildStylePillForSet(category, _selectedCategories);
                  }).toList(),
                ),

                const SizedBox(height: 32),

                // ==================================================
                // OCCASIONS
                // ==================================================
                _buildPreferenceHeading(
                  'YOUR LIFESTYLE & OCCASIONS',
                  'When do you usually need outfit inspiration?',
                ),

                const SizedBox(height: 12),

                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 10,
                  runSpacing: 10,
                  children: _occasions.map((occasion) {
                    return _buildStylePillForSet(occasion, _selectedOccasions);
                  }).toList(),
                ),

                const SizedBox(height: 32),

                // ==================================================
                // DISLIKED STYLES
                // ==================================================
                _buildPreferenceHeading(
                  'STYLES YOU PREFER TO AVOID',
                  'Optional — select styles that do not match your taste.',
                ),

                const SizedBox(height: 12),

                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  runSpacing: 8,
                  children: _styles.map((style) {
                    return _buildStylePillForSet(style, _dislikedStyles);
                  }).toList(),
                ),

                const SizedBox(height: 32),

                // ==================================================
                // DISLIKED COLOURS
                // ==================================================
                _buildPreferenceHeading(
                  'COLOURS YOU PREFER TO AVOID',
                  'Optional — select colours you rarely want in your outfits.',
                ),

                const SizedBox(height: 12),

                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 10,
                  runSpacing: 10,
                  children: _colors.map((item) {
                    return _buildColorSwatch(
                      name: item['name'] as String,
                      color: item['color'] as Color,
                      selections: _dislikedColors,
                    );
                  }).toList(),
                ),

                const SizedBox(height: 36),

                // ==================================================
                // CONTINUE
                // ==================================================
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isSavingPreferences || _isLoadingPreferences
                        ? null
                        : _continue,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.medium),
                      ),
                    ),
                    child: _isSavingPreferences
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.white,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                widget.isEditing ? 'SAVE CHANGES' : 'CONTINUE',
                                style: AppTextStyles.labelMedium.copyWith(
                                  color: AppColors.white,
                                  letterSpacing: 1.8,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.arrow_forward, size: 18),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // IMAGE MOSAIC
  // ============================================================

  Widget _buildImageMosaic() {
    const String textureImage =
        'https://lh3.googleusercontent.com/aida-public/AB6AXuBvgYKdRXGOXK0HKg8_mc1T__L9644LYqRdAeUd1CpEqBkm-hF1GSFd7xIbo8E69nzxtgnfS6KfOrQOtYN87fo7hyQd7-swyDguhQaGKTgiL7mmt0tyVUOs_SN32O1UO_VEToStLInJXeAciKo7__yKebsn4Zd3CHOyrytFg_rldRcnHuzZdLOO_qycIqdD1nTxQOJc-0c1L7qVzlv7V7N3Rk7iRQYOn7txE6eqCLP32SIKyQ3Q_QcX';

    const String accessoryImage =
        'https://lh3.googleusercontent.com/aida-public/AB6AXuDfKqVNjS1oNSPgMAGfPwYQm3gFXS4AW7ai_25zrWzL-MCgW9e-mw2vZRpX8lsI0rFs4hbcH9KCbUNcqU5R73ftNRsrtja4ZHVsI7pCcmjEc8HQedoXBkIe6x1sPtOnVOOmyfTV_lVR6sblEmQjDj_W56_HuRGR7JgUGJnYOpifxeDuEZ9LsFKOod8BE3ivM326aUwoYUG2YXgeFCAIppLCuav1b2uToY1gyvEKagxGIc-40jNN20i1';

    return SizedBox(
      height: 300,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // MAIN IMAGE
          // MAIN IMAGE
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            right: 104,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.small),
              child: Image.asset(
                'assets/images/main_fashion.png',
                fit: BoxFit.cover,
              ),
            ),
          ),

          // TOP RIGHT IMAGE
          Positioned(
            top: 0,
            right: 0,
            width: 95,
            height: 145,
            child: _buildImage(
              textureImage,
              borderRadius: BorderRadius.circular(AppRadius.small),
            ),
          ),

          // BOTTOM RIGHT IMAGE
          Positioned(
            bottom: 0,
            right: 0,
            width: 95,
            height: 145,
            child: _buildImage(
              accessoryImage,
              borderRadius: BorderRadius.circular(AppRadius.small),
            ),
          ),

          // FLOATING BADGE
          Positioned(
            bottom: -20,
            right: 18,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(AppRadius.medium),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.10),
                    blurRadius: 14,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.auto_awesome,
                    size: 18,
                    color: AppColors.primary,
                  ),

                  const SizedBox(width: 8),

                  Text(
                    'POWERED BY WEARLY AI',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.primary,
                      letterSpacing: 1.1,
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

  Widget _buildImage(String url, {BorderRadius? borderRadius}) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.circular(AppRadius.small),
      child: Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: AppColors.surfaceContainerHigh,
            child: const Center(
              child: Icon(
                Icons.image_outlined,
                size: 32,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          );
        },
      ),
    );
  }
}
