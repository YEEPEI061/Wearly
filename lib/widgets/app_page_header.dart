import 'package:flutter/material.dart';
import 'package:frontend/theme/app_colors.dart';
import 'package:frontend/theme/app_text_styles.dart';
import 'package:frontend/theme/app_radius.dart';

class AppPageHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onProfileTap;

  const AppPageHeader({super.key, required this.title, this.onProfileTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(color: AppColors.background.withOpacity(0.95)),
      child: Row(
        children: [
          // Back button
          Transform.translate(
            offset: const Offset(-14, 0),
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              behavior: HitTestBehavior.opaque,
              child: const SizedBox(
                width: 44,
                height: 44,
                child: Icon(
                  Icons.arrow_back_ios_new,
                  size: 20,
                  color: AppColors.onSurface,
                ),
              ),
            ),
          ),

          Transform.translate(
            offset: const Offset(-14, 0),
            child: Text(
              title,
              style: AppTextStyles.headlineSmall.copyWith(
                letterSpacing: 2,
                color: AppColors.primary,
              ),
            ),
          ),

          const Spacer(),

          // Profile
          GestureDetector(
            onTap: onProfileTap,
            behavior: HitTestBehavior.opaque,
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
        ],
      ),
    );
  }
}
