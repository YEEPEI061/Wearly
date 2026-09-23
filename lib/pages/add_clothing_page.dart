import 'package:flutter/material.dart';
import 'package:frontend/theme/app_colors.dart';
import 'package:frontend/theme/app_text_styles.dart';
import 'package:frontend/theme/app_radius.dart';
import 'package:frontend/widgets/app_header_back.dart';

class AddClothingPage extends StatefulWidget {
  const AddClothingPage({super.key});

  @override
  State<AddClothingPage> createState() => _AddClothingPageState();
}

class _AddClothingPageState extends State<AddClothingPage> {
  bool _flashOn = false;

  // ============================================================
  // IMAGES
  // ============================================================

  final String _scanImage =
      'https://lh3.googleusercontent.com/aida-public/AB6AXuDEG_U13NF_Iw8pRwFjd4XRt6O_aHPRvJXLWgX5J3CR8gGJ_R7UkN7gHnJYyP_AkWB_FLuV_A79pijoxlXu3fk9aLrJDnxynlfi3CrVgMxYb1BwQTuju1sQrIf0xha1XpOQ6-K-EheDuB-wMgIxu_VvBbFEu1gOFsXnEv7VWpJZOO_ShrEQDTuiiWGFw4PjbfaM006HM47vlkeYBE3MfwpLj1zmnERcx5CxsGR5zWDgrHkt5QRTd410';

  final List<String> _recentScans = [
    'https://lh3.googleusercontent.com/aida-public/AB6AXuBeqw-u8cAZnOf8OY_bSuJLQsZvBqa-sMzxftFNV_FNdAtDGw5KecWKHMO5bpM4tYZynQ9QufzhiwIWvuiNfPaH3Qcd5zijKFmnCZSocf4cyz0VpKEg8BDqHLTEEUzo7ewr5ECVx-T45JotbwSr0vfAfeZqOybUCAIvn8UJa-0k8i4h21HGOs0YPg72tm1ThdMnUfX9QloxxSfw95J2_L9j0C1MKEGNNJ0ZuQ0-NvMupsGKLn27DGR-',
    'https://lh3.googleusercontent.com/aida-public/AB6AXuDiuTtVeEH2AoeI5m8zV-kPq-a5_XwYXSrmeI0iTtn0d7DFwBiKY-1G3ejOkQgta-xcxvm2FhpoJGbf4Vq4OOZEJZdNqHIzrnBT02SxDBtLiQMyutONtnZXqYAeCDCK8wL-2Y08bVZOLvwQNcHq4oaIHwTRRQGpefza9CWmdm6UZgCHhtcM_hqIVNB4udcaO9zxkBO1LeSoRFmvlxzHoJ1_G_Wl5kYlXI_pc-1lBeD1aixm9W3H2nvX',
    'https://lh3.googleusercontent.com/aida-public/AB6AXuA-xvRhsrbKQNr5N8qC3sOYjHvS6nY_RgtMn5oc1ZQIiI6JQPXQQAusyV7tg05ZLxY4LKCi93BxVQto2P7laE94S1ZQAYhOGi9TZRDX0p9qy2uKmByMLhZRWbLqz0ywdGpuMi-OdlNdMXfrDjTb5Yf5gqpGQbTMDvy3bLUYlE4YufBLNx9zjU85ZzbfJWJlVfb5llRJbu-5QMBPx1xnGIdZ_RKIXuiYNgQJoEY7eGjiQv8qaS2OAx_k',
  ];

  // ============================================================
  // ACTIONS
  // ============================================================

  void _openGallery() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Photo library will be connected later.')),
    );
  }

  void _captureGarment() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Capturing garment...')));
  }

  void _toggleFlash() {
    setState(() {
      _flashOn = !_flashOn;
    });
  }

  void _openRecentScan(int index) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Recent scan ${index + 1} selected.')),
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
        child: Column(
          children: [
            AppPageHeader(title: 'ADD CLOTHING'),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 48),
                child: Column(
                  children: [
                    _buildIntro(),

                    const SizedBox(height: 24),

                    _buildScanArea(),

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
  // HEADER
  // ============================================================

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
            // Background image
            Positioned.fill(
              child: Image.network(
                _scanImage,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) {
                  return Container(
                    color: AppColors.primaryContainer,
                    child: const Center(
                      child: Icon(
                        Icons.checkroom_outlined,
                        size: 64,
                        color: AppColors.primaryDim,
                      ),
                    ),
                  );
                },
              ),
            ),

            // Dark overlay
            Positioned.fill(
              child: Container(color: AppColors.primary.withOpacity(0.25)),
            ),

            // AI scanning line
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

            // Optical guide
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
                          'AI ACTIVE',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.white,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // AI result card
            // Positioned(
            //   left: 16,
            //   right: 16,
            //   bottom: 16,
            //   child: _buildAiResult(),
            // ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // AI RESULT
  // ============================================================

  // Widget _buildAiResult() {
  //   return Container(
  //     padding: const EdgeInsets.all(14),
  //     decoration: BoxDecoration(
  //       color: AppColors.background.withOpacity(0.96),
  //       borderRadius: BorderRadius.circular(AppRadius.medium),
  //       boxShadow: [
  //         BoxShadow(
  //           color: Colors.black.withOpacity(0.16),
  //           blurRadius: 16,
  //           offset: const Offset(0, 4),
  //         ),
  //       ],
  //     ),
  //     child: Row(
  //       children: [
  //         Container(
  //           width: 36,
  //           height: 36,
  //           decoration: BoxDecoration(
  //             color: AppColors.primary,
  //             borderRadius: BorderRadius.circular(AppRadius.small),
  //           ),
  //           child: Center(
  //             child: Text(
  //               'AI',
  //               style: AppTextStyles.labelMedium.copyWith(
  //                 color: AppColors.white,
  //               ),
  //             ),
  //           ),
  //         ),

  //         const SizedBox(width: 12),

  //         Expanded(
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               Text(
  //                 'Structured Wool Coat',
  //                 style: AppTextStyles.labelMedium.copyWith(
  //                   color: AppColors.primary,
  //                 ),
  //               ),

  //               const SizedBox(height: 2),

  //               Text(
  //                 'Confidence 98.4% • Camel',
  //                 style: AppTextStyles.bodySmall.copyWith(
  //                   color: AppColors.secondary,
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),

  //         const Icon(Icons.check_circle, size: 24, color: AppColors.primary),
  //       ],
  //     ),
  //   );
  // }

  // ============================================================
  // CAMERA CONTROLS
  // ============================================================

  Widget _buildCameraControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Gallery
        GestureDetector(
          onTap: _openGallery,
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

        // Camera
        GestureDetector(
          onTap: _captureGarment,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primary,
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

        // Flash
        GestureDetector(
          onTap: _toggleFlash,
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _flashOn
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
              _flashOn ? Icons.flash_on : Icons.flash_off_outlined,
              size: 22,
              color: AppColors.primary,
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
              '3 items pending',
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
          child: Image.network(
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
      onTap: _openGallery,
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
