// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:frontend/models/clothing_item.dart';
import 'package:frontend/pages/clothing_detail_page.dart';
import 'package:frontend/services/api_service.dart';
import 'package:frontend/theme/app_colors.dart';
import 'package:frontend/theme/app_text_styles.dart';
import 'package:frontend/theme/app_radius.dart';
import 'package:frontend/widgets/app_header.dart';
import 'package:frontend/pages/add_clothing_page.dart';

class WardrobePage extends StatefulWidget {
  const WardrobePage({super.key});

  @override
  State<WardrobePage> createState() => _WardrobePageState();
}

class _WardrobePageState extends State<WardrobePage> {
  int _selectedCategory = 0;
  String _searchQuery = '';

  List<String> get _categories {
    final upperCount = _clothingItems
        .where((item) => item.category == 'upper')
        .length;

    final lowerCount = _clothingItems
        .where((item) => item.category == 'lower')
        .length;

    final fullCount = _clothingItems
        .where((item) => item.category == 'full')
        .length;

    return [
      'ALL ITEMS (${_clothingItems.length})',
      'UPPERS ($upperCount)',
      'LOWERS ($lowerCount)',
      'FULL ($fullCount)',
    ];
  }

  List<ClothingItem> _clothingItems = [];

  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadWardrobe();
  }

  void _onCategorySelected(int index) {
    setState(() {
      _selectedCategory = index;
    });
  }

  void _onSearchChanged(String value) {
    setState(() {
      _searchQuery = value;
    });
  }

  void _openFilter() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Filter options will be connected later.')),
    );
  }

  Future<void> _addClothing() async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const AddClothingPage()),
    );

    if (!mounted) return;

    if (saved == true) {
      await _loadWardrobe();
    }
  }

  Future<void> _openItem(ClothingItem item) async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => ClothingDetailPage(item: item, isNewItem: false),
      ),
    );

    if (!mounted) return;

    if (result == 'deleted') {
      await _loadWardrobe();

      if (!mounted) return;

      _showTopSuccessMessage('Clothing item removed.');
    } else if (result == 'updated') {
      await _loadWardrobe();

      if (!mounted) return;

      _showTopSuccessMessage('Clothing item updated.');
    }
  }

  void _showTopSuccessMessage(String message) {
    final overlay = Overlay.of(context);

    final overlayEntry = OverlayEntry(
      builder: (context) {
        return Positioned(
          top: MediaQuery.of(context).padding.top + 16,
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
                    Text(
                      message,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
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

  List<ClothingItem> get _filteredItems {
    List<ClothingItem> items = List.from(_clothingItems);

    if (_selectedCategory != 0) {
      final category = switch (_selectedCategory) {
        1 => 'upper',
        2 => 'lower',
        3 => 'full',
        _ => null,
      };

      if (category != null) {
        items = items.where((item) => item.category == category).toList();
      }
    }

    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();

      items = items.where((item) {
        return (item.name).toLowerCase().contains(query) ||
            (item.brand ?? '').toLowerCase().contains(query) ||
            (item.category).toLowerCase().contains(query) ||
            (item.color ?? '').toLowerCase().contains(query) ||
            (item.style ?? '').toLowerCase().contains(query);
      }).toList();
    }

    return items;
  }

  Future<void> _loadWardrobe() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final items = await ApiService.getWardrobe();

      if (!mounted) return;

      setState(() {
        _clothingItems = items;
        _isLoading = false;
      });

      print('✓ Loaded ${items.length} wardrobe items');
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });

      print('❌ Failed to load wardrobe: $e');
    }
  }

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
                  title: 'WARDROBE',
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

                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 38),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _buildSearchBar(),
                      const SizedBox(height: 16),
                      _buildCategoryFilters(),
                      const SizedBox(height: 32),
                      _buildWardrobeGrid(),
                    ]),
                  ),
                ),
              ],
            ),

            // Floating Add Button
            Positioned(
              right: 24,
              bottom: 40,
              child: _buildFloatingActionButton(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.medium),
      ),
      child: TextField(
        onChanged: _onSearchChanged,
        style: AppTextStyles.bodyMedium,
        decoration: InputDecoration(
          hintText: 'Search your wardrobe...',
          hintStyle: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.outlineVariant,
          ),
          prefixIcon: const Icon(
            Icons.search,
            color: AppColors.outline,
            size: 22,
          ),
          suffixIcon: IconButton(
            onPressed: _openFilter,
            icon: const Icon(
              Icons.tune,
              color: AppColors.onSurfaceVariant,
              size: 20,
            ),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryFilters() {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final selected = _selectedCategory == index;

          return GestureDetector(
            onTap: () => _onCategorySelected(index),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.primary
                    : AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(AppRadius.small),
              ),
              child: Text(
                _categories[index],
                style: AppTextStyles.labelMedium.copyWith(
                  color: selected ? AppColors.white : AppColors.onSurface,
                  letterSpacing: 0.8,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildWardrobeGrid() {
    final items = _filteredItems;

    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 80),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 80),
        child: Column(
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.outline),

            const SizedBox(height: 12),

            Text(
              'Unable to load your wardrobe.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.primary,
              ),
            ),

            const SizedBox(height: 12),

            ElevatedButton(
              onPressed: _loadWardrobe,
              child: const Text('TRY AGAIN'),
            ),
          ],
        ),
      );
    }

    if (items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 80),
        child: Column(
          children: [
            const Icon(
              Icons.checkroom_outlined,
              size: 56,
              color: AppColors.outline,
            ),

            const SizedBox(height: 16),

            Text(
              _searchQuery.isEmpty
                  ? 'Your wardrobe is empty.'
                  : 'No clothing found.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.72,
      ),
      itemBuilder: (context, index) {
        return _buildStandardCard(items[index]);
      },
    );
  }

  // Widget _buildFeaturedCard(ClothingItem item) {
  //   return GestureDetector(
  //     onTap: () => _openItem(item.name),
  //     child: Container(
  //       padding: const EdgeInsets.all(24),
  //       decoration: BoxDecoration(
  //         color: AppColors.surfaceContainerMedium,
  //         borderRadius: BorderRadius.circular(AppRadius.medium),
  //         boxShadow: [
  //           BoxShadow(
  //             color: AppColors.primary.withOpacity(0.03),
  //             blurRadius: 20,
  //             offset: const Offset(0, 4),
  //           ),
  //         ],
  //       ),
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Text(
  //             _displayCategory(item.category),
  //             style: AppTextStyles.labelSmall.copyWith(
  //               color: AppColors.onSurfaceVariant,
  //               letterSpacing: 1.5,
  //             ),
  //           ),

  //           const SizedBox(height: 4),

  //           Text(
  //             item.name,
  //             style: AppTextStyles.headlineSmall.copyWith(
  //               color: AppColors.primary,
  //             ),
  //           ),

  //           const SizedBox(height: 16),

  //           ClipRRect(
  //             borderRadius: BorderRadius.circular(AppRadius.medium),
  //             child: Container(
  //               height: 240,
  //               width: double.infinity,
  //               decoration: BoxDecoration(
  //                 gradient: LinearGradient(
  //                   colors: [
  //                     AppColors.surfaceContainerHigh.withOpacity(0.5),
  //                     Colors.transparent,
  //                   ],
  //                   begin: Alignment.bottomLeft,
  //                   end: Alignment.topRight,
  //                 ),
  //               ),
  //               child: _buildClothingImage(item),
  //             ),
  //           ),

  //           const SizedBox(height: 12),

  //           Align(
  //             alignment: Alignment.centerRight,
  //             child: _buildTag(item.isFavorite ? 'FAVORITE' : 'IN WARDROBE'),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Widget _buildStandardCard(ClothingItem item) {
    return GestureDetector(
      onTap: () => _openItem(item),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerMedium,
          borderRadius: BorderRadius.circular(AppRadius.medium),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.03),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _displayCategory(item.category),
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.onSurfaceVariant,
                letterSpacing: 1.5,
              ),
            ),

            const SizedBox(height: 8),

            Expanded(
              child: Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.medium),
                  child: Container(
                    width: 130,
                    height: 170,
                    color: AppColors.background,
                    child: _buildClothingImage(item),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),

            Text(
              item.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.primary,
              ),
            ),

            const SizedBox(height: 2),

            Text(
              item.brand == null ||
                      item.brand!.isEmpty ||
                      item.brand == 'unknown'
                  ? '${item.color ?? ''} • ${item.style ?? ''}'
                  : item.brand!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClothingImage(ClothingItem item) {
    final String? path = item.processedImagePath ?? item.imagePath;

    if (path == null || path.isEmpty) {
      return const Center(
        child: Icon(
          Icons.checkroom_outlined,
          size: 48,
          color: AppColors.outline,
        ),
      );
    }

    final String imageUrl = '${ApiService.baseUrl}$path';

    return Image.network(
      imageUrl,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) {
        return const Center(
          child: Icon(
            Icons.checkroom_outlined,
            size: 48,
            color: AppColors.outline,
          ),
        );
      },
    );
  }

  String _displayCategory(String? category) {
    switch (category) {
      case 'upper':
        return 'UPPERS';

      case 'lower':
        return 'LOWERS';

      case 'full':
        return 'FULL';

      default:
        return (category ?? 'CLOTHING').toUpperCase();
    }
  }

  // Widget _buildWideFeatureCard() {
  //   return GestureDetector(
  //     onTap: () => _openItem('Glazed Leather Loafers'),
  //     child: Container(
  //       padding: const EdgeInsets.all(24),
  //       decoration: BoxDecoration(
  //         color: AppColors.surfaceContainerMedium,
  //         borderRadius: BorderRadius.circular(AppRadius.medium),
  //         boxShadow: [
  //           BoxShadow(
  //             color: AppColors.primary.withOpacity(0.03),
  //             blurRadius: 20,
  //             offset: const Offset(0, 4),
  //           ),
  //         ],
  //       ),
  //       child: Column(
  //         children: [
  //           ClipRRect(
  //             borderRadius: BorderRadius.circular(AppRadius.medium),
  //             child: Container(
  //               height: 190,
  //               width: double.infinity,
  //               decoration: BoxDecoration(
  //                 gradient: LinearGradient(
  //                   colors: [
  //                     AppColors.surfaceContainerHigh.withOpacity(0.5),
  //                     Colors.transparent,
  //                   ],
  //                   begin: Alignment.bottomLeft,
  //                   end: Alignment.topRight,
  //                 ),
  //               ),
  //               child: Image.network(
  //                 _loaferImage,
  //                 fit: BoxFit.contain,
  //                 errorBuilder: (_, __, ___) {
  //                   return const Icon(
  //                     Icons.shopping_bag_outlined,
  //                     size: 56,
  //                     color: AppColors.outline,
  //                   );
  //                 },
  //               ),
  //             ),
  //           ),

  //           const SizedBox(height: 16),

  //           Align(
  //             alignment: Alignment.centerLeft,
  //             child: Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 Text(
  //                   'SHOES',
  //                   style: AppTextStyles.labelSmall.copyWith(
  //                     color: AppColors.onSurfaceVariant,
  //                     letterSpacing: 1.5,
  //                   ),
  //                 ),
  //                 const SizedBox(height: 4),
  //                 Text(
  //                   'Glazed Leather Loafers',
  //                   style: AppTextStyles.headlineSmall.copyWith(
  //                     color: AppColors.primary,
  //                   ),
  //                 ),
  //                 const SizedBox(height: 4),
  //                 Text(
  //                   'Prada • Classic Collection',
  //                   style: AppTextStyles.bodySmall.copyWith(
  //                     color: AppColors.onSurfaceVariant,
  //                   ),
  //                 ),

  //                 const SizedBox(height: 16),

  //                 Row(
  //                   children: [
  //                     _buildTag('VERSATILE'),
  //                     const SizedBox(width: 8),
  //                     _buildTag('FORMAL'),
  //                   ],
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Widget _buildFloatingActionButton() {
    return GestureDetector(
      onTap: _addClothing,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.8),
          borderRadius: BorderRadius.circular(AppRadius.full),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.18),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: const Icon(Icons.add, size: 26, color: AppColors.white),
      ),
    );
  }
}
