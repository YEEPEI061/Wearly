import 'package:flutter/material.dart';
import 'package:frontend/theme/app_colors.dart';
import 'package:frontend/theme/app_text_styles.dart';
import 'package:frontend/theme/app_radius.dart';
import 'package:frontend/widgets/app_header_back.dart';

class ClothingDetailPage extends StatefulWidget {
  const ClothingDetailPage({super.key});

  @override
  State<ClothingDetailPage> createState() => _ClothingDetailPageState();
}

class _ClothingDetailPageState extends State<ClothingDetailPage> {
  // ============================================================
  // ITEM DATA
  // ============================================================

  final String _clothingImage =
      'https://lh3.googleusercontent.com/aida-public/AB6AXuDoXbYiKghvBHiIgDEgTS1gjFV1hsx_bE1-bwjRUMukeiWyHs5DlQvVpn_OyCLi6stpDNDhgmAam1QZLMuYRZpMKQScQ8aNUREa1mKJGf91fBhG9uU1oUPk9mZLC-13VVSN8wB2qmk_Dw2WvP82fgJHwmN-5RdY5jb_jigA_n1u_P8cL0b0aCahHjjs0R8qilBAEObe7nqVeEcq2L0PEXaPhSAQl_SV9-uGU0FZ3ml3A5Q9UjP1YAdZ';

  String _brand = 'THE ROW';
  String _title = 'Oversized Cashmere Turtleneck';
  String _colorway = 'Camel Melange';
  String _material = '100% Mongolian Cashmere';
  String _season = "Fall / Winter '23";

  final List<String> _tags = ['Minimalist', 'Monochrome', 'Luxury Basics'];

  // ============================================================
  // ACTIONS
  // ============================================================

  void _editText({
    required String title,
    required String currentValue,
    required Function(String) onSave,
  }) {
    final controller = TextEditingController(text: currentValue);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.background,
          title: Text(
            title,
            style: AppTextStyles.headlineSmall.copyWith(
              color: AppColors.primary,
            ),
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.surfaceContainerLow,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.medium),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'CANCEL',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  onSave(controller.text.trim());
                }

                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                elevation: 0,
              ),
              child: Text(
                'SAVE',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  void _addTag() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.background,
          title: Text(
            'Add Tag',
            style: AppTextStyles.headlineSmall.copyWith(
              color: AppColors.primary,
            ),
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              hintText: 'e.g. Casual',
              filled: true,
              fillColor: AppColors.surfaceContainerLow,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.medium),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCEL'),
            ),
            ElevatedButton(
              onPressed: () {
                final tag = controller.text.trim();

                if (tag.isNotEmpty && !_tags.contains(tag)) {
                  setState(() {
                    _tags.add(tag);
                  });
                }

                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                elevation: 0,
              ),
              child: const Text('ADD'),
            ),
          ],
        );
      },
    );
  }

  void _deleteItem() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.background,
          title: Text(
            'Remove Clothing?',
            style: AppTextStyles.headlineSmall.copyWith(
              color: AppColors.primary,
            ),
          ),
          content: Text(
            'Are you sure you want to remove this piece from your digital wardrobe?',
            style: AppTextStyles.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCEL'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Clothing item removed.')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                elevation: 0,
              ),
              child: const Text('REMOVE'),
            ),
          ],
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
        child: Column(
          children: [
            const AppPageHeader(title: 'CLOTHING DETAIL'),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 48),
                child: Column(
                  children: [
                    _buildHeroSection(),
                    const SizedBox(height: 24),
                    _buildItemDetails(),
                    const SizedBox(height: 24),
                    _buildDeleteButton(),
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
  // HERO SECTION
  // ============================================================

  Widget _buildHeroSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Clothing image
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.medium),
            child: Container(
              width: 256,
              height: 320,
              color: AppColors.surfaceContainerMedium,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Image.network(
                      _clothingImage,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) {
                        return const Center(
                          child: Icon(
                            Icons.checkroom_outlined,
                            size: 64,
                            color: AppColors.outline,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Auto-save status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(AppRadius.full),
              border: Border.all(
                color: AppColors.outlineVariant.withOpacity(0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.sync, size: 13, color: AppColors.primary),
                const SizedBox(width: 5),
                Text(
                  'DIRECT EDIT MODE • AUTO-SAVING',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.onSurfaceVariant,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Brand
          GestureDetector(
            onTap: () {
              _editText(
                title: 'Edit Brand',
                currentValue: _brand,
                onSave: (value) {
                  setState(() {
                    _brand = value.toUpperCase();
                  });
                },
              );
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _brand,
                  style: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.secondary,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(
                  Icons.edit_outlined,
                  size: 14,
                  color: AppColors.secondary,
                ),
              ],
            ),
          ),

          const SizedBox(height: 4),

          // Clothing title
          GestureDetector(
            onTap: () {
              _editText(
                title: 'Edit Garment Title',
                currentValue: _title,
                onSave: (value) {
                  setState(() {
                    _title = value;
                  });
                },
              );
            },
            child: SizedBox(
              width: double.infinity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      _title,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.headlineSmall.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(
                    Icons.edit_outlined,
                    size: 16,
                    color: AppColors.primary,
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
  // ITEM DETAILS
  // ============================================================

  Widget _buildItemDetails() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ITEM DETAILS',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.primary,
                  letterSpacing: 1.5,
                ),
              ),
              Row(
                children: [
                  const Icon(
                    Icons.touch_app_outlined,
                    size: 14,
                    color: AppColors.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'TAP TO EDIT',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.onSurfaceVariant,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),

          Divider(height: 1, color: AppColors.outlineVariant.withOpacity(0.3)),

          const SizedBox(height: 16),

          // Colorway
          _buildDetailRow(
            label: 'Colorway',
            child: GestureDetector(
              onTap: () {
                _editText(
                  title: 'Edit Colorway',
                  currentValue: _colorway,
                  onSave: (value) {
                    setState(() {
                      _colorway = value;
                    });
                  },
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  border: Border.all(
                    color: AppColors.outlineVariant.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: const Color(0xFFB89774),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.outlineVariant.withOpacity(0.4),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _colorway,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.unfold_more,
                      size: 16,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Material
          _buildDetailRow(
            label: 'Material',
            child: GestureDetector(
              onTap: () {
                _editText(
                  title: 'Edit Material',
                  currentValue: _material,
                  onSave: (value) {
                    setState(() {
                      _material = value;
                    });
                  },
                );
              },
              child: Container(
                constraints: const BoxConstraints(maxWidth: 220),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  border: Border.all(
                    color: AppColors.outlineVariant.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        _material,
                        textAlign: TextAlign.right,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 5),
                    const Icon(
                      Icons.edit_outlined,
                      size: 15,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Season
          _buildDetailRow(
            label: 'Season',
            child: GestureDetector(
              onTap: _showSeasonPicker,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  border: Border.all(
                    color: AppColors.outlineVariant.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _season,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.expand_more,
                      size: 16,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Tags
          Container(
            padding: const EdgeInsets.only(top: 16),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: AppColors.outlineVariant.withOpacity(0.2),
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Tags',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      '${_tags.length} TAGS ACTIVE',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.secondary,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [..._tags.map(_buildTag), _buildAddTagButton()],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DETAIL ROW
  // ============================================================

  Widget _buildDetailRow({required String label, required Widget child}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 72,
          child: Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Align(alignment: Alignment.centerRight, child: child),
        ),
      ],
    );
  }

  // ============================================================
  // TAG
  // ============================================================

  Widget _buildTag(String tag) {
    return GestureDetector(
      onTap: () => _removeTag(tag),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.background,
          border: Border.all(color: AppColors.outlineVariant.withOpacity(0.4)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              tag.toUpperCase(),
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.primary,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(width: 6),
            const Icon(
              Icons.close,
              size: 14,
              color: AppColors.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // ADD TAG
  // ============================================================

  Widget _buildAddTagButton() {
    return GestureDetector(
      onTap: _addTag,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerMedium,
          border: Border.all(
            color: AppColors.outlineVariant.withOpacity(0.6),
            style: BorderStyle.solid,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.add, size: 14, color: AppColors.secondary),
            const SizedBox(width: 4),
            Text(
              'TAG',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.secondary,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // SEASON PICKER
  // ============================================================

  void _showSeasonPicker() {
    final seasons = [
      "Fall / Winter '23",
      'Spring / Summer \'24',
      'Resort / Pre-Fall',
      'All Season',
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SELECT SEASON',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.primary,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 16),
                ...seasons.map(
                  (season) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      season,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    trailing: _season == season
                        ? const Icon(Icons.check, color: AppColors.primary)
                        : null,
                    onTap: () {
                      setState(() {
                        _season = season;
                      });
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // DELETE
  // ============================================================

  Widget _buildDeleteButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton.icon(
        onPressed: _deleteItem,
        icon: const Icon(Icons.delete_outline, size: 19),
        label: Text(
          'REMOVE FROM WARDROBE',
          style: AppTextStyles.labelMedium.copyWith(letterSpacing: 1.0),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.onSurfaceVariant,
          side: BorderSide(color: AppColors.outlineVariant.withOpacity(0.7)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.medium),
          ),
        ),
      ),
    );
  }
}
