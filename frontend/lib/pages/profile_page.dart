// ignore_for_file: deprecated_member_use
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:frontend/pages/onboarding_page.dart';
import 'package:frontend/theme/app_colors.dart';
import 'package:frontend/theme/app_text_styles.dart';
import 'package:frontend/theme/app_radius.dart';
import 'package:frontend/widgets/app_header.dart';
import 'package:image_picker/image_picker.dart';
import 'package:frontend/services/api_service.dart';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:frontend/pages/seasonal_color_page.dart';
import 'package:frontend/pages/seasonal_color_result_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // ============================================================
  // STATE
  // ============================================================

  bool _dailyBriefingEnabled = true;
  bool _weatherEnabled = true;

  Map<String, dynamic>? _profile;
  bool _isLoadingProfile = true;
  String? _profileError;
  String? _selectedProfileImagePath;

  int? _wearIndex;
  bool _isLoadingWearIndex = true;

  List<dynamic> _colorPalette = [];
  bool _isLoadingColorPalette = true;

  List<dynamic> _stylePreferences = [];
  bool _isLoadingStylePreferences = true;

  Map<String, dynamic>? _profileInsights;
  bool _isLoadingInsights = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _loadWearIndex();
    _loadColorPalette();
    _loadStylePreferences();
    _loadProfileInsights();
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await ApiService.getProfile();

      if (!mounted) return;

      setState(() {
        _profile = profile;
        _isLoadingProfile = false;
        _profileError = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoadingProfile = false;
        _profileError = e.toString();
      });
    }
  }

  Future<void> _loadProfileInsights() async {
    try {
      final result = await ApiService.getProfileInsights();

      if (!mounted) return;

      setState(() {
        _profileInsights = result;
        _isLoadingInsights = false;
      });
    } catch (e) {
      debugPrint('PROFILE INSIGHTS ERROR: $e');

      if (!mounted) return;

      setState(() {
        _isLoadingInsights = false;
      });
    }
  }

  Future<void> _showPreparingPhotoDialog() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: AppColors.surfaceContainerLow,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.large),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(color: AppColors.primary),
                const SizedBox(height: 18),
                Text(
                  'Preparing photo...',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Generate initials from the user's name.
  String _getInitials(String? name) {
    if (name == null || name.trim().isEmpty) {
      return '?';
    }

    final parts = name.trim().split(RegExp(r'\s+'));

    if (parts.length == 1) {
      return parts.first[0].toUpperCase();
    }

    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  // Format the database membership date.
  String _getMemberSince(String? dateString) {
    if (dateString == null || dateString.isEmpty) {
      return 'MEMBER SINCE UNKNOWN';
    }

    final date = DateTime.tryParse(dateString);

    if (date == null) {
      return 'MEMBER SINCE UNKNOWN';
    }

    const months = [
      'JANUARY',
      'FEBRUARY',
      'MARCH',
      'APRIL',
      'MAY',
      'JUNE',
      'JULY',
      'AUGUST',
      'SEPTEMBER',
      'OCTOBER',
      'NOVEMBER',
      'DECEMBER',
    ];

    return "MEMBER SINCE ${months[date.month - 1]} '${date.year.toString().substring(2)}";
  }

  Future<void> _changeProfileImage() async {
    final ImagePicker picker = ImagePicker();

    // 1. Select image from gallery
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (image == null || !mounted) return;

    // 2. Show loading dialog
    _showPreparingPhotoDialog();

    try {
      final File imageFile = File(image.path);

      // 3. Read and decode image dimensions
      final imageBytes = await imageFile.readAsBytes();
      final decodedImage = await ui.instantiateImageCodec(imageBytes);
      final frame = await decodedImage.getNextFrame();

      final double originalWidth = frame.image.width.toDouble();
      final double originalHeight = frame.image.height.toDouble();

      frame.image.dispose();
      decodedImage.dispose();

      // 4. Calculate display dimensions
      const double cropSize = 280;

      final double coverScale =
          cropSize /
          (originalWidth < originalHeight ? originalWidth : originalHeight);

      final double displayWidth = originalWidth * coverScale;
      final double displayHeight = originalHeight * coverScale;

      if (!mounted) return;

      // 5. Close loading dialog
      Navigator.of(context, rootNavigator: true).pop();

      // 6. Open crop editor using prepared dimensions
      final File? croppedImage = await _showProfilePhotoEditor(
        imageFile,
        displayWidth: displayWidth,
        displayHeight: displayHeight,
      );

      if (croppedImage == null || !mounted) return;

      // 7. Show cropped image immediately
      setState(() {
        _selectedProfileImagePath = croppedImage.path;
      });

      // 8. Upload cropped image
      final savedImagePath = await ApiService.uploadProfileImage(
        croppedImage.path,
      );

      if (!mounted) return;

      // 9. Update saved profile image
      setState(() {
        _profile!['profile_image'] = savedImagePath;
        _selectedProfileImagePath = null;
      });

      _showMessage('Profile photo saved successfully.');
    } catch (e) {
      if (!mounted) return;

      Navigator.of(context, rootNavigator: true).pop();

      setState(() {
        _selectedProfileImagePath = null;
      });

      print('PROFILE IMAGE ERROR: $e');

      _showMessage('Unable to save profile photo. Please try again.');
    }
  }

  Future<void> _loadWearIndex() async {
    try {
      final result = await ApiService.getWearIndex();

      if (!mounted) return;

      setState(() {
        _wearIndex = (result['wear_index'] as num?)?.toInt();
        _isLoadingWearIndex = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoadingWearIndex = false;
      });
    }
  }

  Future<void> _loadColorPalette() async {
    try {
      final result = await ApiService.getColorPalette();

      if (!mounted) return;

      setState(() {
        _colorPalette = result;
        _isLoadingColorPalette = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoadingColorPalette = false;
      });
    }
  }

  Future<void> _loadStylePreferences() async {
    try {
      final result = await ApiService.getStylePreferences();

      if (!mounted) return;

      setState(() {
        _stylePreferences = result['preferences'] ?? [];
        _isLoadingStylePreferences = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoadingStylePreferences = false;
      });

      print('STYLE PREFERENCES ERROR: $e');
    }
  }

  Future<File?> _showProfilePhotoEditor(
    File imageFile, {
    required double displayWidth,
    required double displayHeight,
  }) async {
    const double cropSize = 280;

    final GlobalKey cropKey = GlobalKey();

    bool isSaving = false;

    return showDialog<File>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: AppColors.surfaceContainerLow,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.large),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ==========================================
                    // TITLE
                    // ==========================================
                    Text(
                      'Adjust Profile Photo',
                      style: AppTextStyles.headlineSmall.copyWith(
                        color: AppColors.primary,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'Drag to reposition and pinch to zoom.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ==========================================
                    // SQUARE IMAGE EDITOR
                    // ==========================================
                    Center(
                      child: Container(
                        width: cropSize,
                        height: cropSize,
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(AppRadius.large),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: RepaintBoundary(
                          key: cropKey,
                          child: ClipRect(
                            child: SizedBox(
                              width: cropSize,
                              height: cropSize,
                              child: InteractiveViewer(
                                constrained: false,
                                alignment: Alignment.center,
                                minScale: 1.0,
                                maxScale: 4.0,
                                panEnabled: true,
                                scaleEnabled: true,
                                boundaryMargin: EdgeInsets.zero,
                                child: SizedBox(
                                  width: displayWidth,
                                  height: displayHeight,
                                  child: Image.file(
                                    imageFile,
                                    fit: BoxFit.fill,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ==========================================
                    // BUTTONS
                    // ==========================================
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: isSaving
                                ? null
                                : () {
                                    Navigator.pop(dialogContext);
                                  },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              side: BorderSide(color: AppColors.primary),
                              padding: const EdgeInsets.symmetric(vertical: 13),
                            ),
                            child: Text(
                              'CANCEL',
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: ElevatedButton(
                            onPressed: isSaving
                                ? null
                                : () async {
                                    setDialogState(() {
                                      isSaving = true;
                                    });

                                    try {
                                      // Wait for the editor to finish rendering
                                      await WidgetsBinding.instance.endOfFrame;

                                      // Capture only the square preview
                                      final renderObject = cropKey
                                          .currentContext!
                                          .findRenderObject();

                                      final boundary =
                                          renderObject as RenderRepaintBoundary;

                                      final ui.Image capturedImage =
                                          await boundary.toImage(pixelRatio: 3);

                                      final byteData = await capturedImage
                                          .toByteData(
                                            format: ui.ImageByteFormat.png,
                                          );

                                      capturedImage.dispose();

                                      if (byteData == null) {
                                        throw Exception(
                                          'Unable to create cropped image.',
                                        );
                                      }

                                      // Save temporary PNG
                                      final croppedFile = File(
                                        '${Directory.systemTemp.path}/wearly_profile_${DateTime.now().millisecondsSinceEpoch}.png',
                                      );

                                      await croppedFile.writeAsBytes(
                                        byteData.buffer.asUint8List(),
                                      );

                                      if (!dialogContext.mounted) return;

                                      // Return cropped image to upload method
                                      Navigator.pop(dialogContext, croppedFile);
                                    } catch (e) {
                                      print('PHOTO CROP ERROR: $e');

                                      if (!dialogContext.mounted) return;

                                      setDialogState(() {
                                        isSaving = false;
                                      });

                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Unable to crop photo. Please try again.',
                                          ),
                                        ),
                                      );
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: AppColors.white,
                              padding: const EdgeInsets.symmetric(vertical: 13),
                            ),
                            child: isSaving
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.white,
                                    ),
                                  )
                                : Text(
                                    'SAVE PHOTO',
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.white,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildProfileInitialsPreview() {
    return Container(
      width: 220,
      height: 220,
      color: AppColors.primary,
      alignment: Alignment.center,
      child: Text(
        _getInitials(_profile?['name']?.toString()),
        style: AppTextStyles.headlineLarge.copyWith(
          color: AppColors.white,
          fontSize: 64,
        ),
      ),
    );
  }

  void _viewProfileImage() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: AppColors.surfaceContainerLow,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.large),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.large),
                  child: _selectedProfileImagePath != null
                      ? Image.file(
                          File(_selectedProfileImagePath!),
                          width: 220,
                          height: 220,
                          fit: BoxFit.cover,
                        )
                      : (_profile?['profile_image'] != null &&
                            _profile!['profile_image'].toString().isNotEmpty)
                      ? Image.network(
                          '${ApiService.baseUrl}${_profile!['profile_image']}',
                          width: 220,
                          height: 220,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildProfileInitialsPreview();
                          },
                        )
                      : _buildProfileInitialsPreview(),
                ),

                const SizedBox(height: 20),

                Text(
                  _profile?['name'] ?? 'User',
                  style: AppTextStyles.headlineMedium.copyWith(
                    color: AppColors.primary,
                  ),
                ),

                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(dialogContext);
                      _changeProfileImage();
                    },
                    icon: const Icon(Icons.camera_alt_outlined),
                    label: const Text('CHANGE PHOTO'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                    ),
                  ),
                ),

                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('CLOSE'),
                ),
              ],
            ),
          ),
        );
      },
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
                  title: 'PROFILE',
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

                // ==================================================
                // MAIN CONTENT
                // ==================================================
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 38),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _buildProfileHeader(),

                      const SizedBox(height: 12),

                      _buildUtilizationCard(),

                      const SizedBox(height: 24),

                      _buildColorPalette(),

                      const SizedBox(height: 24),

                      _buildSilhouettePreferences(),

                      const SizedBox(height: 24),

                      _buildAIInsight(),

                      const SizedBox(height: 24),

                      _buildPreferencesList(),

                      const SizedBox(height: 24),

                      _buildFooterActions(),
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
  // PROFILE HEADER
  // ============================================================

  Widget _buildProfileHeader() {
    if (_isLoadingProfile) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 50),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_profileError != null || _profile == null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 30),
        child: Column(
          children: [
            const Icon(Icons.error_outline, size: 36, color: AppColors.primary),
            const SizedBox(height: 12),
            Text(
              'Unable to load profile.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                setState(() {
                  _isLoadingProfile = true;
                  _profileError = null;
                });

                _loadProfile();
              },
              child: const Text('TRY AGAIN'),
            ),
          ],
        ),
      );
    }

    final String name = _profile!['name'] ?? 'User';
    final String email = _profile!['email'] ?? '';
    final String initials = _getInitials(name);
    final String memberSince = _getMemberSince(
      _profile!['created_at']?.toString(),
    );

    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Avatar
          Stack(
            clipBehavior: Clip.none,
            children: [
              GestureDetector(
                onTap: _viewProfileImage,
                child: Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(AppRadius.large),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.10),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  clipBehavior: Clip.antiAlias,
                  child: _selectedProfileImagePath != null
                      ? Image.file(
                          File(_selectedProfileImagePath!),
                          width: 84,
                          height: 84,
                          fit: BoxFit.cover,
                        )
                      : (_profile!['profile_image'] != null &&
                            _profile!['profile_image'].toString().isNotEmpty)
                      ? Image.network(
                          '${ApiService.baseUrl}${_profile!['profile_image']}',
                          width: 84,
                          height: 84,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Center(
                              child: Text(
                                initials,
                                style: AppTextStyles.headlineLarge.copyWith(
                                  color: AppColors.white,
                                  fontSize: 32,
                                ),
                              ),
                            );
                          },
                        )
                      : Text(
                          initials,
                          style: AppTextStyles.headlineLarge.copyWith(
                            color: AppColors.white,
                            fontSize: 32,
                          ),
                        ),
                ),
              ),
              // Change profile image
              Positioned(
                right: -4,
                bottom: -4,
                child: GestureDetector(
                  onTap: _changeProfileImage,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: AppColors.secondary,
                      borderRadius: BorderRadius.circular(AppRadius.small),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.camera_alt_outlined,
                      size: 15,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Name from database
          Text(
            name,
            textAlign: TextAlign.center,
            style: AppTextStyles.headlineMedium.copyWith(
              color: AppColors.primary,
            ),
          ),

          const SizedBox(height: 4),

          // Email from database
          if (email.isNotEmpty)
            Text(
              email,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),

          const SizedBox(height: 8),

          // Membership date from database
          Text(
            memberSince,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.onSurfaceVariant,
              letterSpacing: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // UTILIZATION
  // ============================================================

  Widget _buildUtilizationCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.small),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'UTILIZATION',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.onSurfaceVariant,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              const Icon(
                Icons.eco_outlined,
                size: 18,
                color: AppColors.primary,
              ),
            ],
          ),

          const SizedBox(height: 14),

          Text(
            _isLoadingWearIndex ? '...' : '${_wearIndex ?? 0}%',
            style: AppTextStyles.headlineLarge.copyWith(
              color: AppColors.primary,
            ),
          ),

          const SizedBox(height: 2),

          Text(
            'Wear Index',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CORE COLOR PALETTE
  // ============================================================

  Widget _buildColorPalette() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.small),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Heading
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  'CORE COLOR PALETTE',
                  style: AppTextStyles.headlineSmall.copyWith(
                    color: AppColors.primary,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'YOUR WARDROBE',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Text(
            _isLoadingColorPalette
                ? 'Analysing your wardrobe colours...'
                : _colorPalette.isEmpty
                ? 'Add clothing items to discover your wardrobe colour palette.'
                : 'These are the most common colours found in your wardrobe.',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),

          const SizedBox(height: 16),

          // Palette
          if (_isLoadingColorPalette)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(12),
                child: CircularProgressIndicator(),
              ),
            )
          else if (_colorPalette.isEmpty)
            const SizedBox(
              height: 48,
              child: Center(child: Text('No clothing colours available yet.')),
            )
          else
            Row(
              children: _colorPalette.map((item) {
                final String name = item['name'] ?? 'Unknown';
                final String hex = item['color'] ?? '#A0A0A0';

                final colorValue = int.parse(
                  hex.replaceFirst('#', ''),
                  radix: 16,
                );

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Column(
                      children: [
                        Container(
                          width: double.infinity,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Color(0xFF000000 | colorValue),
                            borderRadius: BorderRadius.circular(
                              AppRadius.small,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.06),
                                blurRadius: 3,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 5),

                        Text(
                          name.toUpperCase(),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.onSurfaceVariant,
                            fontSize: 9,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  // ============================================================
  // SILHOUETTE PREFERENCES
  // ============================================================

  Widget _buildSilhouettePreferences() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.small),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'WARDROBE STYLE PREFERENCES',
                  style: AppTextStyles.headlineSmall.copyWith(
                    color: AppColors.primary,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
              Text(
                'STYLE MIX',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          if (_isLoadingStylePreferences)
            const Center(child: CircularProgressIndicator())
          else if (_stylePreferences.isEmpty)
            Text(
              'Add clothing items with recognised styles to discover your wardrobe preferences.',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            )
          else
            ..._stylePreferences.map((item) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 18),
                child: _buildPreferenceBar(
                  title: item['title'],
                  percentage: item['percentage'],
                ),
              );
            }).toList(),
        ],
      ),
    );
  }

  Widget _buildPreferenceBar({required String title, required int percentage}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              '$percentage%',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),

        const SizedBox(height: 6),

        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.small),
          child: Stack(
            children: [
              Container(
                width: double.infinity,
                height: 8,
                color: AppColors.surfaceContainerHigh,
              ),

              FractionallySizedBox(
                widthFactor: percentage / 100,
                child: Container(height: 8, color: AppColors.primary),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // AI STYLIST INSIGHT
  // ============================================================

  Widget _buildAIInsight() {
    final insight = _profileInsights;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(AppRadius.small),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'AI STYLIST INSIGHT',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.primaryDim,
                  letterSpacing: 1.5,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                _isLoadingInsights
                    ? 'Analysing Your Wardrobe'
                    : insight?['title'] ?? 'Your Wardrobe Insight',
                style: AppTextStyles.headlineSmall.copyWith(
                  color: AppColors.white,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                _isLoadingInsights
                    ? 'Preparing insights from your wardrobe data...'
                    : insight?['description'] ??
                          'Unable to generate wardrobe insights at the moment.',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.white.withOpacity(0.80),
                ),
              ),
            ],
          ),

          Positioned(
            right: -8,
            bottom: -12,
            child: Icon(
              Icons.analytics_outlined,
              size: 110,
              color: AppColors.white.withOpacity(0.07),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SETTINGS / PREFERENCES
  // ============================================================

  Widget _buildPreferencesList() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.small),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildPreferenceRow(
            icon: Icons.tune,
            title: 'Style Questionnaire',
            onTap: _openStyleQuestionnaire,
          ),

          _buildDivider(),

          _buildPreferenceRow(
            icon: Icons.palette_outlined,
            title: 'Seasonal Color Analysis',
            onTap: _openColorAnalysis,
          ),

          _buildDivider(),

          _buildToggleRow(
            icon: Icons.notifications_active_outlined,
            title: 'Daily Briefing Notifications',
            value: _dailyBriefingEnabled,
            onChanged: (value) {
              setState(() {
                _dailyBriefingEnabled = value;
              });
            },
          ),

          _buildDivider(),

          _buildToggleRow(
            icon: Icons.cloud_outlined,
            title: 'Local Weather Integration',
            value: _weatherEnabled,
            onChanged: (value) {
              setState(() {
                _weatherEnabled = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPreferenceRow({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppColors.onSurfaceVariant),

            const SizedBox(width: 12),

            Expanded(
              child: Text(
                title,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            const Icon(
              Icons.chevron_right,
              size: 20,
              color: AppColors.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleRow({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.onSurfaceVariant),

          const SizedBox(width: 12),

          Expanded(
            child: Text(
              title,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.white,
            activeTrackColor: AppColors.primary,
            inactiveThumbColor: AppColors.outline,
            inactiveTrackColor: AppColors.surfaceContainerHigh,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: AppColors.surfaceContainerHigh,
    );
  }

  // ============================================================
  // FOOTER ACTIONS
  // ============================================================

  Widget _buildFooterActions() {
    return Column(
      children: [
        GestureDetector(
          onTap: _signOut,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 13),
            decoration: BoxDecoration(
              color: Colors.transparent,
              border: Border.all(color: AppColors.primary, width: 1),
              borderRadius: BorderRadius.circular(AppRadius.small),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.logout, size: 16, color: AppColors.primary),

                const SizedBox(width: 8),

                Text(
                  'SIGN OUT',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.primary,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 14),

        Text(
          'WEARLY • PERSONAL STYLE INTELLIGENCE',
          textAlign: TextAlign.center,
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.onSurfaceVariant,
            letterSpacing: 0.8,
          ),
        ),

        const SizedBox(height: 7),
      ],
    );
  }

  // ============================================================
  // ACTIONS
  // ============================================================

  void _openStyleQuestionnaire() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const OnboardingPage(isEditing: true)),
    );
  }

  Future<void> _openColorAnalysis() async {
    try {
      final result = await ApiService.getSeasonalColor();

      if (!mounted) return;

      if (result != null) {
        // Existing analysis: open saved result
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SeasonalColorResultPage(seasonalColor: result),
          ),
        );
      } else {
        // No previous analysis: open questionnaire
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SeasonalColorPage()),
        );
      }
    } catch (e) {
      debugPrint('OPEN SEASONAL COLOR ERROR: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to load seasonal colour analysis. Please try again.',
          ),
        ),
      );
    }
  }

  void _signOut() {
    _showMessage('Sign out will be connected later.');
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
}
