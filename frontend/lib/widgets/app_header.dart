// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:frontend/theme/app_colors.dart';
import 'package:frontend/theme/app_text_styles.dart';
import 'package:frontend/theme/app_radius.dart';

class AppHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onProfileTap;

  const AppHeader({
    super.key,
    required this.title,
    this.onNotificationTap,
    this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      automaticallyImplyLeading: false,
      backgroundColor: AppColors.background.withOpacity(0.95),
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      toolbarHeight: 54,
      titleSpacing: 24,

      title: Text(
        title,
        style: AppTextStyles.headlineSmall.copyWith(
          letterSpacing: 2,
          color: AppColors.primary,
        ),
      ),

      actions: [
        IconButton(
          onPressed: onNotificationTap,
          icon: const Icon(
            Icons.notifications_none_outlined,
            color: AppColors.onSurfaceVariant,
          ),
        ),

        Padding(
          padding: const EdgeInsets.only(right: 24, left: 4),
          child: GestureDetector(
            onTap: onProfileTap,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
              child: const Icon(
                Icons.person_outline,
                size: 18,
                color: AppColors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
