import 'package:flutter/material.dart';
import 'package:frontend/services/api_service.dart';
import 'package:frontend/theme/app_colors.dart';
import 'package:frontend/theme/app_text_styles.dart';
import 'package:frontend/theme/app_radius.dart';
import 'package:frontend/widgets/app_page_header.dart';
import 'package:frontend/models/clothing_item.dart';
import 'dart:io';

class ClothingDetailPage extends StatefulWidget {
  final ClothingItem? item;
  final bool isNewItem;
  final File? previewImage;

  const ClothingDetailPage({
    super.key,
    this.item,
    this.isNewItem = false,
    this.previewImage,
  });

  @override
  State<ClothingDetailPage> createState() => _ClothingDetailPageState();
}

class _ClothingDetailPageState extends State<ClothingDetailPage> {
  // ============================================================
  // ITEM DATA
  // ============================================================

  String _brand = 'Unknown';
  String _title = 'Clothing Item';
  String _colorway = 'Unknown';
  String _material = 'Unknown';
  String _season = 'All Season';

  String _category = 'Unknown';
  String _style = 'Unknown';

  String? _processedImageUrl;

  File? _localImage;

  final List<String> _tags = [];

  String _displayCategory(String category) {
    switch (category.toLowerCase()) {
      case 'upper':
        return 'Top';
      case 'lower':
        return 'Bottom';
      case 'full':
        return 'Full Body';
      case 'top':
        return 'Top';
      case 'pants':
        return 'Bottom';
      case 'skirt':
        return 'Bottom';
      case 'dress':
        return 'Full Body';
      default:
        return category.isEmpty ? 'Unknown' : category;
    }
  }

  @override
  void initState() {
    super.initState();

    final item = widget.item;

    if (item != null) {
      _title = item.name;
      _brand = item.brand ?? 'Unknown';
      _colorway = item.color ?? 'Unknown';
      _material = item.material ?? 'Unknown';
      _category = item.category;
      _style = item.style ?? 'Unknown';

      if (item.processedImagePath != null &&
          item.processedImagePath!.isNotEmpty) {
        _processedImageUrl = '${ApiService.baseUrl}${item.processedImagePath}';
      }

      if (widget.previewImage != null) {
        _localImage = widget.previewImage;
      } else if (item.imagePath != null && item.imagePath!.isNotEmpty) {
        _localImage = File(item.imagePath!);
      }

      if (_style != 'Unknown') {
        _tags.add(_style);
      }
    }
  }

  // ============================================================
  // ACTIONS
  // ============================================================

  void _editCategory() {
    final categories = [
      {'value': 'upper', 'label': 'Top'},
      {'value': 'lower', 'label': 'Bottom'},
      {'value': 'full', 'label': 'Full Body'},
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
                  'SELECT CATEGORY',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.primary,
                    letterSpacing: 1.2,
                  ),
                ),

                const SizedBox(height: 16),

                ...categories.map(
                  (category) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    visualDensity: const VisualDensity(vertical: -2),
                    title: Text(
                      category['label']!,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    trailing: _category == category['value']
                        ? const Icon(Icons.check, color: AppColors.primary)
                        : null,
                    onTap: () {
                      setState(() {
                        _category = category['value']!;
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

  void _editColor() {
    final colors = [
      'black',
      'white',
      'light gray',
      'dark gray',
      'beige',
      'brown',
      'navy blue',
      'blue',
      'green',
      'red',
      'orange',
      'yellow',
      'pink',
      'purple',
      'multicolor',
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      isScrollControlled: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SELECT COLOUR',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.primary,
                    letterSpacing: 1.2,
                  ),
                ),

                const SizedBox(height: 12),

                SizedBox(
                  height: 360,
                  child: ListView.separated(
                    itemCount: colors.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 0),
                    itemBuilder: (context, index) {
                      final color = colors[index];

                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        visualDensity: const VisualDensity(vertical: -2),
                        title: Text(
                          _capitalizeWords(color),
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                        trailing: _colorway.toLowerCase() == color
                            ? const Icon(Icons.check, color: AppColors.primary)
                            : null,
                        onTap: () {
                          setState(() {
                            _colorway = color;
                          });

                          Navigator.pop(context);
                        },
                      );
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

  void _editStyle() {
    final styles = [
      'casual',
      'smart casual',
      'formal',
      'sporty',
      'streetwear',
      'minimalist',
      'elegant',
      'vintage',
      'preppy',
      'relaxed',
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      isScrollControlled: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SELECT STYLE',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.primary,
                    letterSpacing: 1.2,
                  ),
                ),

                const SizedBox(height: 12),

                SizedBox(
                  height: 360,
                  child: ListView.separated(
                    itemCount: styles.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 0),
                    itemBuilder: (context, index) {
                      final style = styles[index];

                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        visualDensity: const VisualDensity(vertical: -2),
                        title: Text(
                          _capitalizeWords(style),
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                        trailing: _style.toLowerCase() == style
                            ? const Icon(Icons.check, color: AppColors.primary)
                            : null,
                        onTap: () {
                          setState(() {
                            _style = style;
                          });

                          _tags.removeWhere(
                            (tag) => styles.contains(tag.toLowerCase()),
                          );

                          if (!_tags.contains(style)) {
                            _tags.add(style);
                          }

                          Navigator.pop(context);
                        },
                      );
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

  void _editMaterial() {
    final materials = [
      'cotton',
      'polyester',
      'linen',
      'wool',
      'cashmere',
      'denim',
      'nylon',
      'rayon',
      'viscose',
      'silk',
      'leather',
      'suede',
      'acrylic',
      'spandex / elastane',
      'cotton blend',
      'synthetic blend',
      'other',
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      isScrollControlled: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SELECT MATERIAL',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.primary,
                    letterSpacing: 1.2,
                  ),
                ),

                const SizedBox(height: 12),

                SizedBox(
                  height: 360,
                  child: ListView.separated(
                    itemCount: materials.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 0),
                    itemBuilder: (context, index) {
                      final material = materials[index];

                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        visualDensity: const VisualDensity(vertical: -2),
                        title: Text(
                          _capitalizeWords(material),
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                        trailing: _material.toLowerCase() == material
                            ? const Icon(Icons.check, color: AppColors.primary)
                            : null,
                        onTap: () {
                          setState(() {
                            _material = material;
                          });

                          Navigator.pop(context);
                        },
                      );
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
  // HELPER
  // ============================================================

  String _capitalizeWords(String text) {
    return text
        .split(' ')
        .map(
          (word) =>
              word.isEmpty ? word : word[0].toUpperCase() + word.substring(1),
        )
        .join(' ');
  }

  Color _colorForName(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'black':
        return Colors.black;

      case 'white':
        return Colors.white;

      case 'light gray':
        return Colors.grey.shade300;

      case 'dark gray':
        return Colors.grey.shade700;

      case 'beige':
        return const Color(0xFFD8C3A5);

      case 'brown':
        return Colors.brown;

      case 'navy blue':
        return const Color(0xFF1E3A5F);

      case 'blue':
        return Colors.blue;

      case 'green':
        return Colors.green;

      case 'red':
        return Colors.red;

      case 'orange':
        return Colors.orange;

      case 'yellow':
        return Colors.yellow;

      case 'pink':
        return Colors.pink;

      case 'purple':
        return Colors.purple;

      case 'multicolor':
        return Colors.grey;

      default:
        return AppColors.outlineVariant;
    }
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
                    if (widget.isNewItem)
                      _buildSaveButton()
                    else
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
          Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.medium),
            ),
            child: _processedImageUrl != null
                ? Image.network(
                    _processedImageUrl!,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) {
                      return _localImage != null
                          ? Image.file(_localImage!, fit: BoxFit.contain)
                          : const Center(
                              child: Icon(
                                Icons.checkroom_outlined,
                                size: 64,
                                color: AppColors.outline,
                              ),
                            );
                    },
                  )
                : _localImage != null
                ? Image.file(_localImage!, fit: BoxFit.contain)
                : const Center(
                    child: Icon(
                      Icons.checkroom_outlined,
                      size: 64,
                      color: AppColors.outline,
                    ),
                  ),
          ),
          const SizedBox(height: 20),

          // Auto-save status
          // Container(
          //   padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          //   decoration: BoxDecoration(
          //     color: AppColors.background,
          //     borderRadius: BorderRadius.circular(AppRadius.full),
          //     border: Border.all(
          //       color: AppColors.outlineVariant.withOpacity(0.3),
          //     ),
          //   ),
          //   child: Row(
          //     mainAxisSize: MainAxisSize.min,
          //     children: [
          //       const Icon(Icons.sync, size: 13, color: AppColors.primary),
          //       const SizedBox(width: 5),
          //       Text(
          //         'DIRECT EDIT MODE • AUTO-SAVING',
          //         style: AppTextStyles.labelSmall.copyWith(
          //           color: AppColors.onSurfaceVariant,
          //           letterSpacing: 0.8,
          //         ),
          //       ),
          //     ],
          //   ),
          // ),

          // const SizedBox(height: 12),

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
              Row(
                children: [
                  const Icon(
                    Icons.auto_awesome,
                    size: 18,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'ITEM DETAILS',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.primary,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
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

          // ========================================================
          // CATEGORY
          // ========================================================
          _buildDetailRow(
            label: 'Category',
            child: GestureDetector(
              onTap: _editCategory,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(AppRadius.small),
                  border: Border.all(
                    color: AppColors.outlineVariant.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _displayCategory(_category),
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

          const SizedBox(height: 16),

          // ========================================================
          // COLOUR
          // ========================================================
          _buildDetailRow(
            label: 'Colour',
            child: GestureDetector(
              onTap: _editColor,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(AppRadius.small),
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
                        color: _colorForName(_colorway),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.outlineVariant.withOpacity(0.6),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _capitalizeWords(_colorway),
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

          // ========================================================
          // STYLE
          // ========================================================
          _buildDetailRow(
            label: 'Style',
            child: GestureDetector(
              onTap: _editStyle,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(AppRadius.small),
                  border: Border.all(
                    color: AppColors.outlineVariant.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _capitalizeWords(_style),
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

          const SizedBox(height: 16),

          // ========================================================
          // MATERIAL
          // ========================================================
          _buildDetailRow(
            label: 'Material',
            child: GestureDetector(
              onTap: _editMaterial,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(AppRadius.small),
                  border: Border.all(
                    color: AppColors.outlineVariant.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _capitalizeWords(_material),
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

          const SizedBox(height: 16),

          // ========================================================
          // SEASON
          // ========================================================
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
                  borderRadius: BorderRadius.circular(AppRadius.small),
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

          // ========================================================
          // TAGS
          // ========================================================
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
                      'TAGS',
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
          borderRadius: BorderRadius.circular(AppRadius.small),
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
          borderRadius: BorderRadius.circular(AppRadius.small),
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
                    visualDensity: const VisualDensity(vertical: -2),
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

  // ============================================================
  // SAVE
  // ============================================================

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton.icon(
        onPressed: _saveItem,
        icon: const Icon(Icons.check, size: 20),
        label: Text(
          'SAVE TO WARDROBE',
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.white,
            letterSpacing: 1.0,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.medium),
          ),
        ),
      ),
    );
  }

  Future<void> _saveItem() async {
    final item = widget.item;

    if (item == null) {
      _showError('Unable to save this clothing item.');
      return;
    }

    try {
      await ApiService.saveClothingItem(
        item: item,
        name: _title,
        brand: _brand,
        category: _category,
        color: _colorway,
        style: _style,
        material: _material,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Clothing saved to your wardrobe.'),
            behavior: SnackBarBehavior.floating,
          ),
        );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      _showError(e.toString().replaceFirst('Exception: ', ''));
    }
  }
}
