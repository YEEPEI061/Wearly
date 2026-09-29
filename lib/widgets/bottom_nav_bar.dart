import 'package:flutter/material.dart';
import 'package:frontend/theme/app_colors.dart';
import 'package:frontend/theme/app_text_styles.dart';
import 'package:frontend/theme/app_radius.dart';

class BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const BottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background.withOpacity(0.97),
        borderRadius: BorderRadius.circular(AppRadius.large),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: SafeArea(
        top: false,
        minimum: const EdgeInsets.only(top: 12, bottom: 12),

        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,

          children: [
            _buildNavItem(icon: Icons.home_outlined, label: 'HOME', index: 0),

            _buildNavItem(
              icon: Icons.checkroom_outlined,
              label: 'WARDROBE',
              index: 1,
            ),

            _buildNavItem(icon: Icons.auto_awesome, label: 'STYLIST', index: 2),

            _buildNavItem(icon: Icons.history, label: 'HISTORY', index: 3),

            _buildNavItem(
              icon: Icons.person_outline,
              label: 'PROFILE',
              index: 4,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final bool selected = selectedIndex == index;

    return GestureDetector(
      onTap: () => onItemSelected(index),
      behavior: HitTestBehavior.opaque,

      child: SizedBox(
        width: 64,

        child: Column(
          mainAxisSize: MainAxisSize.min,

          children: [
            Icon(
              icon,
              size: 21,
              color: selected ? AppColors.primary : AppColors.onSurfaceVariant,
            ),

            const SizedBox(height: 5),

            Text(
              label,
              style: AppTextStyles.labelSmall.copyWith(
                color: selected
                    ? AppColors.primary
                    : AppColors.onSurfaceVariant,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
