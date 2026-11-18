import 'package:flutter/material.dart';
import 'package:frontend/theme/app_colors.dart';
import 'package:frontend/theme/app_radius.dart';
import 'package:frontend/theme/app_text_styles.dart';
import 'package:frontend/widgets/app_page_header.dart';
import 'package:frontend/pages/seasonal_color_result_page.dart';
import 'package:frontend/services/api_service.dart';

class SeasonalColorPage extends StatefulWidget {
  final Map<String, dynamic>? existingResult;

  const SeasonalColorPage({super.key, this.existingResult});

  @override
  State<SeasonalColorPage> createState() => _SeasonalColorPageState();
}

class _SeasonalColorPageState extends State<SeasonalColorPage> {
  String? _selectedUndertone;
  String? _selectedHair;
  String? _selectedEyes;
  String? _selectedContrast;
  bool _isAnalysing = false;

  bool get _isComplete =>
      _selectedUndertone != null &&
      _selectedHair != null &&
      _selectedEyes != null &&
      _selectedContrast != null;

  final List<String> _undertones = ['Warm', 'Cool', 'Neutral', 'Not Sure'];

  final List<String> _hairColors = [
    'Black',
    'Dark Brown',
    'Light Brown',
    'Blonde',
    'Red',
    'Other',
  ];

  final List<String> _eyeColors = [
    'Dark Brown',
    'Light Brown',
    'Blue',
    'Green',
    'Hazel',
    'Grey',
  ];

  final List<String> _contrastLevels = ['Low', 'Medium', 'High', 'Not Sure'];

  @override
  void initState() {
    super.initState();

    final result = widget.existingResult;

    if (result != null) {
      _selectedUndertone = result['undertone'];
      _selectedHair = result['hair_color'];
      _selectedEyes = result['eye_color'];
      _selectedContrast = result['contrast_level'];
    }
  }

  void _selectAnswer(String question, String answer) {
    setState(() {
      switch (question) {
        case 'undertone':
          _selectedUndertone = _selectedUndertone == answer ? null : answer;
          break;

        case 'hair':
          _selectedHair = _selectedHair == answer ? null : answer;
          break;

        case 'eyes':
          _selectedEyes = _selectedEyes == answer ? null : answer;
          break;

        case 'contrast':
          _selectedContrast = _selectedContrast == answer ? null : answer;
          break;
      }
    });
  }

  String _calculateSeason() {
    final bool isWarm = _selectedUndertone == 'Warm';
    final bool isCool = _selectedUndertone == 'Cool';

    final bool isDarkHair = ['Black', 'Dark Brown'].contains(_selectedHair);

    final bool isDarkEyes = ['Dark Brown'].contains(_selectedEyes);

    final bool isHighContrast = _selectedContrast == 'High';
    final bool isLowContrast = _selectedContrast == 'Low';

    // Warm undertone
    if (isWarm) {
      return (isHighContrast || (isDarkHair && isDarkEyes))
          ? 'Autumn'
          : 'Spring';
    }

    // Cool undertone
    if (isCool) {
      return (isHighContrast || (isDarkHair && isDarkEyes))
          ? 'Winter'
          : 'Summer';
    }

    // Neutral or uncertain undertone
    if (isHighContrast) {
      return isDarkHair || isDarkEyes ? 'Winter' : 'Autumn';
    }

    if (isLowContrast) {
      return 'Summer';
    }

    return isDarkHair || isDarkEyes ? 'Winter' : 'Spring';
  }

  Future<void> _analyseColors() async {
    if (!_isComplete || _isAnalysing) return;

    setState(() {
      _isAnalysing = true;
    });

    try {
      final season = _calculateSeason();

      // Save seasonal colour analysis to backend
      await ApiService.saveSeasonalColor(
        undertone: _selectedUndertone!,
        hairColor: _selectedHair!,
        eyeColor: _selectedEyes!,
        contrastLevel: _selectedContrast!,
        season: season,
      );

      if (!mounted) return;

      // Navigate only after successful saving
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => SeasonalColorResultPage(
            seasonalColor: {
              'undertone': _selectedUndertone,
              'hair_color': _selectedHair,
              'eye_color': _selectedEyes,
              'contrast_level': _selectedContrast,
              'season': season,
            },
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to save colour analysis. Please try again.'),
          backgroundColor: Colors.red.shade700,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isAnalysing = false;
        });
      }
    }
  }

  Widget _buildSectionHeading(String number, String title, String description) {
    return Column(
      children: [
        Text(
          '$number  ·  $title',
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

  Widget _buildOptions({
    required List<String> options,
    required String? selectedValue,
    required Function(String) onSelected,
  }) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 10,
      runSpacing: 10,
      children: options.map((option) {
        final bool isSelected = selectedValue == option;

        return GestureDetector(
          onTap: () => onSelected(option),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary
                  : AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(AppRadius.small),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  option,
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
      }).toList(),
    );
  }

  Widget _buildQuestionSection({
    required String number,
    required String title,
    required String description,
    required List<String> options,
    required String? selectedValue,
    required Function(String) onSelected,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSectionHeading(number, title, description),
        const SizedBox(height: 16),
        _buildOptions(
          options: options,
          selectedValue: selectedValue,
          onSelected: onSelected,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const AppPageHeader(title: 'COLOR ANALYSIS'),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 48),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Small heading
                    Text(
                      'YOUR PERSONAL COLOUR GUIDE',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.secondary,
                        letterSpacing: 1.8,
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Main heading
                    Text(
                      'Discover your\nseasonal palette.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.headlineMedium.copyWith(
                        color: AppColors.primary,
                        height: 1.18,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Description
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 360),
                      child: Text(
                        'Answer a few questions about your natural features '
                        'to explore a seasonal colour palette that may suit you.',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Information banner
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(AppRadius.medium),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: AppColors.secondary,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Choose the answers that best describe your '
                              'natural features. You can select "Not Sure" '
                              'if you are uncertain.',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 36),

                    // Question 01
                    _buildQuestionSection(
                      number: '01',
                      title: 'SKIN UNDERTONE',
                      description:
                          'How would you describe your skin undertone?',
                      options: _undertones,
                      selectedValue: _selectedUndertone,
                      onSelected: (value) => _selectAnswer('undertone', value),
                    ),

                    const SizedBox(height: 32),

                    // Question 02
                    _buildQuestionSection(
                      number: '02',
                      title: 'NATURAL HAIR COLOUR',
                      description: 'What is your natural hair colour?',
                      options: _hairColors,
                      selectedValue: _selectedHair,
                      onSelected: (value) => _selectAnswer('hair', value),
                    ),

                    const SizedBox(height: 32),

                    // Question 03
                    _buildQuestionSection(
                      number: '03',
                      title: 'EYE COLOUR',
                      description:
                          'Which option best describes your natural eye colour?',
                      options: _eyeColors,
                      selectedValue: _selectedEyes,
                      onSelected: (value) => _selectAnswer('eyes', value),
                    ),

                    const SizedBox(height: 32),

                    // Question 04
                    _buildQuestionSection(
                      number: '04',
                      title: 'NATURAL CONTRAST',
                      description:
                          'How noticeable is the difference between your '
                          'natural hair, skin and eye colours?',
                      options: _contrastLevels,
                      selectedValue: _selectedContrast,
                      onSelected: (value) => _selectAnswer('contrast', value),
                    ),

                    const SizedBox(height: 40),

                    // Analyse button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isComplete && !_isAnalysing
                            ? _analyseColors
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          disabledBackgroundColor: AppColors.outlineVariant,
                          foregroundColor: AppColors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppRadius.medium,
                            ),
                          ),
                        ),
                        child: _isAnalysing
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.white,
                                  ),
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'ANALYSE MY COLOURS',
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

                    const SizedBox(height: 16),

                    // Disclaimer
                    Text(
                      'Your result is an estimated style guide, '
                      'not a professional colour diagnosis.',
                      textAlign: TextAlign.center,
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
      ),
    );
  }
}
