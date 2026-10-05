// ignore_for_file: deprecated_member_use

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:frontend/models/clothing_item.dart';
import 'package:frontend/services/api_service.dart';
import 'package:frontend/theme/app_colors.dart';
import 'package:frontend/theme/app_text_styles.dart';
import 'package:frontend/theme/app_radius.dart';
import 'package:frontend/widgets/app_page_header.dart';
import 'package:frontend/pages/clothing_detail_page.dart';

class AddClothingPage extends StatefulWidget {
  const AddClothingPage({super.key});

  @override
  State<AddClothingPage> createState() => _AddClothingPageState();
}

class _AddClothingPageState extends State<AddClothingPage> {
  final ImagePicker _picker = ImagePicker();

  bool _flashOn = false;
  bool _isProcessing = false;
  bool _isDetectingCategory = false;

  File? _selectedImage;
  // ClothingItem? _aiResult;

  // Keep the original visual design.
  // These now act as real local recent scans.
  final List<File> _recentScans = [];

  String _selectedCategory = 'upper';

  // ============================================================
  // ACTIONS
  // ============================================================

  Future<void> _openGallery() async {
    if (_isProcessing) return;

    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 90,
      );

      if (image == null) return;

      final File selectedFile = File(image.path);

      setState(() {
        _selectedImage = selectedFile;
      });
      _addToRecentScans(selectedFile);

      await _detectCategory(selectedFile);
    } catch (e) {
      _showError('Unable to open your photo library.');
    }
  }

  Future<void> _captureGarment() async {
    if (_isProcessing) return;

    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 90,
      );

      if (image == null) return;

      final File selectedFile = File(image.path);

      setState(() {
        _selectedImage = selectedFile;
      });
      _addToRecentScans(selectedFile);

      await _detectCategory(selectedFile);
    } catch (e) {
      _showError('Unable to open the camera.');
    }
  }

  void _addToRecentScans(File image) {
    setState(() {
      // Remove the same image if it already exists.
      _recentScans.removeWhere((file) => file.path == image.path);

      // Add newest scan to the beginning.
      _recentScans.insert(0, image);

      // Keep only the latest 6 scans.
      if (_recentScans.length > 6) {
        _recentScans.removeLast();
      }
    });
  }

  void _toggleFlash() {
    setState(() {
      _flashOn = !_flashOn;
    });

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            _flashOn
                ? 'Flash indicator turned on.'
                : 'Flash indicator turned off.',
          ),
          duration: const Duration(seconds: 1),
        ),
      );
  }

  // ============================================================
  // AUTOMATIC CATEGORY DETECTION
  // ============================================================

  Future<void> _detectCategory(File image) async {
    if (_isProcessing) return;

    setState(() {
      _isDetectingCategory = true;
    });

    try {
      final String category = await ApiService.detectClothingCategory(
        image: image,
      );

      if (!mounted) return;

      setState(() {
        _selectedCategory = category;
        _isDetectingCategory = false;
      });

      print('✓ AI detected category: $category');
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isDetectingCategory = false;
      });

      print('⚠ Category detection failed: $e');

      // Keep current category if detection fails.
    }
  }

  // ============================================================
  // AI ANALYSIS
  // ============================================================

  Future<void> _analyseClothing() async {
    if (_selectedImage == null) {
      _showError('Please select or capture a clothing photo first.');
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      final ClothingItem result = await ApiService.processClothing(
        image: _selectedImage!,
        selectedCategory: _selectedCategory,
      );

      if (!mounted) return;

      setState(() {
        _isProcessing = false;
      });

      // Go to Clothing Detail for user confirmation/editing.
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ClothingDetailPage(
            item: result,
            isNewItem: true,
            previewImage: _selectedImage,
          ),
        ),
      );

      if (!mounted) return;

      // Reset Add Clothing page after returning.
      setState(() {
        _selectedImage = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isProcessing = false;
      });

      _showError(_cleanErrorMessage(e));
    }
  }
  // ============================================================
  // RESET
  // ============================================================

  void _resetScan() {
    if (_isProcessing) return;

    setState(() {
      _selectedImage = null;
    });
  }

  // ============================================================
  // RECENT SCANS
  // ============================================================

  Future<void> _openRecentScan(int index) async {
    if (_isProcessing) return;

    if (index < 0 || index >= _recentScans.length) {
      return;
    }

    final File selectedFile = _recentScans[index];

    setState(() {
      _selectedImage = selectedFile;
    });

    await _detectCategory(selectedFile);
  }

  // ============================================================
  // MESSAGES
  // ============================================================

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

  String _cleanErrorMessage(Object error) {
    final message = error.toString();

    if (message.startsWith('Exception: ')) {
      return message.substring('Exception: '.length);
    }

    return message;
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
            const AppPageHeader(title: 'ADD CLOTHING'),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 48),
                child: Column(
                  children: [
                    _buildIntro(),

                    const SizedBox(height: 24),

                    _buildScanArea(),

                    const SizedBox(height: 20),

                    if (_selectedImage != null && !_isProcessing)
                      _buildCategorySelector(),

                    if (_selectedImage != null && !_isProcessing)
                      const SizedBox(height: 20),

                    if (_selectedImage != null) _buildAnalyseButton(),

                    const SizedBox(height: 20),

                    _buildCameraControls(),

                    const SizedBox(height: 24),

                    _buildRecentScans(),
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
      children: [
        Text(
          'SMART CAPTURE STUDIO',
          textAlign: TextAlign.center,
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.secondary,
            letterSpacing: 1.2,
          ),
        ),

        const SizedBox(height: 4),

        Text(
          'Scan Garment',
          textAlign: TextAlign.center,
          style: AppTextStyles.headlineLarge.copyWith(color: AppColors.primary),
        ),

        const SizedBox(height: 4),

        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 320),
          child: Text(
            'Center your piece inside the optical guide for instant '
            'fabric analysis and auto-tagging.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // SCAN AREA
  // ============================================================

  Widget _buildScanArea() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.large),
      child: Container(
        height: 380,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.primaryContainer,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          children: [
            // ====================================================
            // IMAGE
            // ====================================================
            Positioned.fill(
              child: _selectedImage != null
                  ? Container(
                      color: AppColors.secondary,
                      child: Image.file(_selectedImage!, fit: BoxFit.contain),
                    )
                  : Container(
                      color: AppColors.secondary,
                      child: const Center(
                        child: Icon(
                          Icons.checkroom_outlined,
                          size: 64,
                          color: AppColors.primaryDim,
                        ),
                      ),
                    ),
            ),

            // ====================================================
            // OVERLAY
            // ====================================================
            Positioned.fill(
              child: Container(
                color: AppColors.primary.withOpacity(
                  _selectedImage != null ? 0.12 : 0.25,
                ),
              ),
            ),

            // ====================================================
            // SCANNING LINE
            // ====================================================
            if (_selectedImage == null || _isProcessing)
              Positioned(
                left: 0,
                right: 0,
                top: 127,
                child: Container(
                  height: 2,
                  decoration: BoxDecoration(
                    color: AppColors.primaryDim,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryDim.withOpacity(0.8),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                ),
              ),

            // ====================================================
            // OPTICAL GUIDE
            // ====================================================
            Positioned(
              left: 32,
              right: 32,
              top: 32,
              bottom: 32,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.background.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(AppRadius.medium),
                  border: Border.all(
                    color: AppColors.white.withOpacity(0.4),
                    width: 2,
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: 16,
                      left: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.80),
                          borderRadius: BorderRadius.circular(AppRadius.small),
                        ),
                        child: Text(
                          _isProcessing
                              ? 'AI ANALYSING'
                              : _selectedImage != null
                              ? 'IMAGE READY'
                              : 'AI ACTIVE',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.white,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ),

                    // Empty state instruction
                    if (_selectedImage == null)
                      Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.35),
                            borderRadius: BorderRadius.circular(
                              AppRadius.medium,
                            ),
                          ),
                          child: Text(
                            'Select or capture a garment',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.white,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // ====================================================
            // PROCESSING OVERLAY
            // ====================================================
            if (_isProcessing)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.52),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(
                          width: 42,
                          height: 42,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            color: AppColors.white,
                          ),
                        ),

                        const SizedBox(height: 16),

                        Text(
                          'Analysing garment...',
                          style: AppTextStyles.labelMedium.copyWith(
                            color: AppColors.white,
                          ),
                        ),

                        const SizedBox(height: 6),

                        Text(
                          'Detecting clothing, colour and style',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.white.withOpacity(0.85),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // CATEGORY
  // ============================================================

  void _selectCategory(String category) {
    if (_isProcessing || _isDetectingCategory) {
      return;
    }

    setState(() {
      _selectedCategory = category;
    });
  }

  // ============================================================
  // CATEGORY SELECTOR
  // ============================================================

  Widget _buildCategorySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'CLOTHING TYPE',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.primary,
                letterSpacing: 1.0,
              ),
            ),

            const SizedBox(width: 8),

            if (_isDetectingCategory)
              const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primary,
                ),
              ),
          ],
        ),

        const SizedBox(height: 10),

        Row(
          children: [
            _buildCategoryButton('upper', 'Upper'),

            const SizedBox(width: 8),

            _buildCategoryButton('lower', 'Lower'),

            const SizedBox(width: 8),

            _buildCategoryButton('full', 'Full'),
          ],
        ),

        const SizedBox(height: 8),

        Text(
          _isDetectingCategory
              ? 'AI is detecting the clothing type...'
              : 'AI detected the clothing type. You can change it if needed.',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryButton(String value, String label) {
    final bool selected = _selectedCategory == value;

    return Expanded(
      child: GestureDetector(
        onTap: () => _selectCategory(value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 48,
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primary
                : AppColors.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(AppRadius.medium),
          ),
          child: Center(
            child: Text(
              label,
              style: AppTextStyles.labelMedium.copyWith(
                color: selected ? AppColors.white : AppColors.primary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // ANALYSE BUTTON
  // ============================================================

  Widget _buildAnalyseButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton.icon(
        onPressed: _isProcessing ? null : _analyseClothing,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.medium),
          ),
        ),
        icon: const Icon(Icons.auto_awesome, size: 20),
        label: Text(
          'ANALYSE WITH AI',
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.white,
            letterSpacing: 1.0,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // CAMERA CONTROLS
  // ============================================================

  Widget _buildCameraControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // ========================================================
        // GALLERY
        // ========================================================
        GestureDetector(
          onTap: _isProcessing ? null : _openGallery,
          child: Opacity(
            opacity: _isProcessing ? 0.4 : 1,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(AppRadius.large),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.photo_library_outlined,
                size: 22,
                color: AppColors.primary,
              ),
            ),
          ),
        ),

        // ========================================================
        // CAMERA
        // ========================================================
        GestureDetector(
          onTap: _isProcessing ? null : _captureGarment,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: _isProcessing ? AppColors.primaryDim : AppColors.primary,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.18),
                  blurRadius: 16,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: const Icon(
              Icons.photo_camera_outlined,
              size: 32,
              color: AppColors.white,
            ),
          ),
        ),

        // ========================================================
        // FLASH / RESET
        // ========================================================
        GestureDetector(
          onTap: _isProcessing
              ? null
              : (_selectedImage != null ? _resetScan : _toggleFlash),
          child: Opacity(
            opacity: _isProcessing ? 0.4 : 1,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _selectedImage != null
                    ? AppColors.surfaceContainerHigh
                    : _flashOn
                    ? AppColors.primaryDim
                    : AppColors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(AppRadius.large),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                _selectedImage != null
                    ? Icons.refresh
                    : (_flashOn ? Icons.flash_on : Icons.flash_off_outlined),
                size: 22,
                color: AppColors.primary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // RECENT SCANS
  // ============================================================

  Widget _buildRecentScans() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'RECENT SCANS',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.primary,
                letterSpacing: 1.0,
              ),
            ),

            Text(
              '${_recentScans.length} items',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.secondary,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        SizedBox(
          height: 80,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _recentScans.length + 1,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              if (index == _recentScans.length) {
                return _buildAddRecentScan();
              }

              return _buildRecentScanItem(index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRecentScanItem(int index) {
    return GestureDetector(
      onTap: () => _openRecentScan(index),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.medium),
        child: Container(
          width: 64,
          height: 80,
          color: AppColors.surfaceContainerHigh,
          child: Image.file(
            _recentScans[index],
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) {
              return const Icon(
                Icons.checkroom_outlined,
                color: AppColors.secondary,
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildAddRecentScan() {
    return GestureDetector(
      onTap: _isProcessing ? null : _openGallery,
      child: Container(
        width: 64,
        height: 80,
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerMedium,
          borderRadius: BorderRadius.circular(AppRadius.medium),
        ),
        child: const Icon(Icons.add, size: 24, color: AppColors.secondary),
      ),
    );
  }
}
