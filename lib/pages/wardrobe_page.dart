import 'package:flutter/material.dart';
import 'package:frontend/pages/history_page.dart';
import 'package:frontend/pages/profile_page.dart';
import 'package:frontend/pages/stylist_page.dart';
import 'package:frontend/theme/app_colors.dart';
import 'package:frontend/theme/app_text_styles.dart';
import 'package:frontend/theme/app_radius.dart';
import 'package:frontend/widgets/app_header.dart';
import 'package:frontend/widgets/bottom_nav_bar.dart';
import 'package:frontend/pages/home_page.dart';
import 'package:frontend/pages/add_clothing_page.dart';

class WardrobePage extends StatefulWidget {
  const WardrobePage({super.key});

  @override
  State<WardrobePage> createState() => _WardrobePageState();
}

class _WardrobePageState extends State<WardrobePage> {
  int _selectedCategory = 0;
  String _searchQuery = '';

  final List<String> _categories = [
    'ALL ITEMS (42)',
    'TOPS (14)',
    'BOTTOMS (9)',
    'OUTERWEAR (7)',
    'SHOES (12)',
  ];

  final List<Map<String, String>> _clothingItems = [
    {
      'category': 'Tops',
      'name': 'Silk Poplin Shirt',
      'brand': 'The Row',
      'image':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuAwu2mDo2VTgzIrnaYDBRfdKxWhhliXCj-yCjqd-EzFKsIhsvjPqGKUMSmBWzQ-558YPjxt_CyociJek-7Mi5uJe7GDVluhfvkWPzPUjWZWNOZ1tKIMucn5CPcVpkvkZUyJ5_m5dSyLtvaJEIVfxGpqwwEWmKS5gJxKMkhiw5ihf1EvcrObgHIBwA5r3onOw47vSCywAy5pw7-QwAY8O8VFX3M2GbaDBCtNR5f1SjMRBvbhMCe3y4R1',
    },
    {
      'category': 'Bottoms',
      'name': 'Pleated Wool Trousers',
      'brand': 'Lemaire',
      'image':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuCctWbczbGxgo68uhP9tyBxrh6_uc0Jo8nTdN-ZlOOXyx0gFsSXsKFNTKrVFONnUcW24icaRiuabEMvsFJl0e0LKtLuy9QUZ6U-JynhfOh7CoB_PrZuWRsP6R-nWfoMJmOnK8zj4i0ShOPGo9Se_PpN63r9QyllpVcO2qPluak4MkH3II4DgaTFqHWSL0oBYCuDl2Wi6A4QhTee-kS1xd0Kou_7SUFYUY-p_AZx9YG4u0wKxFqn9izs',
    },
    {
      'category': 'Tops',
      'name': 'Ribbed Cashmere Rollneck',
      'brand': 'COS Atelier',
      'image':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuCQ7meMv6DexZzBkv_fU3edM7__UCIzxZrt2bKHR2adpEpmg2Q4snPQsdtD96Hr0-vhhpD7gfYfZxxNBlCPXQ7aoOdgkSqZ9XF1gNmy6pX_YxmiGRdzbSVDExJcwUSsRuVjSM_d3pnGvGp7EgyTOOHvobUVHqOKMtARaDxLAilWN07Z_Pwc6Ry8XsJ9IcWjd25v-Y3GNof-Tk2C46F6Q33ZKPtmgz2WiL8Jk53_i6yQllu9kBkgfF-Y',
    },
    {
      'category': 'Outerwear',
      'name': 'Structured Leather Blazer',
      'brand': 'Acne Studios',
      'image':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuAIRBdcaWASkQq-Kzy311yxsK7VEtuB98VQOFaHQPrismdlBEVtqeDKhg3xgdS6sOZQ7DsfpWvJNO9F0T8BFX1x-C1OeNVFfS5GU898NxTSwnKecKL22QmoSNT2kocWBylSeN-xidLDk1q7zx1FfI34nO9lOGM57-8CGUY43KFlGetAbycJsxVIkEmZPXr7S6pCvwEiT62FXfusGhwPIs_YCrEkKzXlHSldptfKcUszr6g7Zyxz2qRt',
    },
  ];

  final String _overcoatImage =
      'https://lh3.googleusercontent.com/aida-public/AB6AXuCPfQ9CZ_QSmJNg7YbOha_O9Abp6VNUETrVAGNzvTiuDdmX8azXjWB27K2UPUHbJEf1rFQgXYbCDFt0oeaacXC1I54767lC-SNRgcYyIrlV0JQ6dmUTj1YYADi039K5BZ0gbbOu8PSkHIarsZ4sNMtkRe7sr4wqKFP33q7ClR9PqRNSDVF3A0K1TnBgDvz_X05DjVploukVZ6WAq5LbItWJ1WzL6TNtim2tGcZ0lCkVrTDYFvxBYcrX';

  final String _loaferImage =
      'https://lh3.googleusercontent.com/aida-public/AB6AXuDLEOo987cCBnChntM9NDbpw6d2gzQdq537uKfZbJXRxTgKvzOOXq7nFSnHQNkLMxn-Vsa2yreeBSXhKd8R8gexRptMNHNpVoArNsDUuvURe9QAzcdX6eWOxduupWfV8JCAeExeFjVYU212xPUKdOwItXWwS3irRDF0G2Lad-ykNXmImFe1glAHbbwvpGWVfnP0US1Mfq62yztLci01LyqVRSWR2sOttp7T9XbGPiMEbgGWYUtksxOG';

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

  void _addClothing() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddClothingPage()),
    );
  }

  void _openItem(String name) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$name will open here.')));
  }

  void _onNavigationSelected(int index) {
    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
        break;

      case 1:
        // Already on Wardrobe
        break;

      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const StylistPage()),
        );
        break;

      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const HistoryPage()),
        );
        break;

      case 4:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ProfilePage()),
        );
        break;
    }
  }

  List<Map<String, String>> get _filteredItems {
    List<Map<String, String>> items = _clothingItems;

    if (_selectedCategory != 0) {
      final category = _categories[_selectedCategory]
          .split(' ')
          .first
          .toLowerCase();

      items = items.where((item) {
        return item['category']!.toLowerCase() == category;
      }).toList();
    }

    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();

      items = items.where((item) {
        return item['name']!.toLowerCase().contains(query) ||
            item['brand']!.toLowerCase().contains(query) ||
            item['category']!.toLowerCase().contains(query);
      }).toList();
    }

    return items;
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
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 90),
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
              bottom: 100,
              child: _buildFloatingActionButton(),
            ),

            // Reusable Bottom Navigation
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: BottomNavBar(
                selectedIndex: 1,
                onItemSelected: _onNavigationSelected,
              ),
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
          hintText: 'Search your curated archive...',
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

    return Column(
      children: [
        _buildFeaturedCard(),
        const SizedBox(height: 16),

        // Two-column grid
        if (items.isNotEmpty)
          GridView.builder(
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
          ),

        const SizedBox(height: 16),

        _buildWideFeatureCard(),
      ],
    );
  }

  Widget _buildFeaturedCard() {
    return GestureDetector(
      onTap: () => _openItem('Cashmere Overcoat'),
      child: Container(
        padding: const EdgeInsets.all(24),
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
              'OUTERWEAR',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.onSurfaceVariant,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Cashmere Overcoat',
              style: AppTextStyles.headlineMedium.copyWith(
                color: AppColors.primary,
              ),
            ),

            const SizedBox(height: 16),

            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.medium),
              child: Container(
                height: 240,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.surfaceContainerHigh.withOpacity(0.5),
                      Colors.transparent,
                    ],
                    begin: Alignment.bottomLeft,
                    end: Alignment.topRight,
                  ),
                ),
                child: Image.network(
                  _overcoatImage,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) {
                    return const Icon(
                      Icons.checkroom_outlined,
                      size: 64,
                      color: AppColors.outline,
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 12),

            Align(
              alignment: Alignment.centerRight,
              child: _buildTag('WORN 4 TIMES'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStandardCard(Map<String, String> item) {
    return GestureDetector(
      onTap: () => _openItem(item['name']!),
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
              item['category']!.toUpperCase(),
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.onSurfaceVariant,
                letterSpacing: 1.5,
              ),
            ),

            const SizedBox(height: 8),

            Expanded(
              child: Image.network(
                item['image']!,
                width: double.infinity,
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
              ),
            ),

            const SizedBox(height: 8),

            Text(
              item['name']!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.headlineSmall.copyWith(
                color: AppColors.primary,
              ),
            ),

            const SizedBox(height: 2),

            Text(
              item['brand']!,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWideFeatureCard() {
    return GestureDetector(
      onTap: () => _openItem('Glazed Leather Loafers'),
      child: Container(
        padding: const EdgeInsets.all(24),
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
          children: [
            SizedBox(
              height: 190,
              width: double.infinity,
              child: Image.network(
                _loaferImage,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) {
                  return const Icon(
                    Icons.shopping_bag_outlined,
                    size: 56,
                    color: AppColors.outline,
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SHOES',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.onSurfaceVariant,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Glazed Leather Loafers',
                    style: AppTextStyles.headlineMedium.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Prada • Classic Collection',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),

                  const SizedBox(height: 16),

                  Row(
                    children: [
                      _buildTag('VERSATILE'),
                      const SizedBox(width: 8),
                      _buildTag('FORMAL'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppRadius.small),
      ),
      child: Text(
        text,
        style: AppTextStyles.labelSmall.copyWith(
          color: AppColors.primary,
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return GestureDetector(
      onTap: _addClothing,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: AppColors.primary,
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
