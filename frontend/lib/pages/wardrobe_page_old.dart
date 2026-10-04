import 'package:flutter/material.dart';

import '../models/clothing_item.dart';
import '../services/api_service.dart';
import 'add_clothing_page_old.dart';
import 'outfit_page.dart';

class WardrobePage extends StatefulWidget {
  const WardrobePage({super.key});

  @override
  State<WardrobePage> createState() => _WardrobePageState();
}

class _WardrobePageState extends State<WardrobePage> {
  List<ClothingItem> items = [];

  bool loading = true;

  @override
  void initState() {
    super.initState();

    loadWardrobe();
  }

  // ========================================================
  // LOAD
  // ========================================================

  Future<void> loadWardrobe() async {
    setState(() {
      loading = true;
    });

    try {
      final result = await ApiService.getWardrobe();

      if (!mounted) return;

      setState(() {
        items = result;
      });
    } catch (e) {
      showMessage('Could not load wardrobe:\n$e');
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  // ========================================================
  // ADD
  // ========================================================

  Future<void> addClothing() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddClothingPage()),
    );

    loadWardrobe();
  }

  // ========================================================
  // DELETE
  // ========================================================

  Future<void> deleteItem(ClothingItem item) async {
    try {
      await ApiService.deleteClothing(item.id);

      loadWardrobe();
    } catch (e) {
      showMessage('Could not delete item:\n$e');
    }
  }

  // ========================================================
  // MESSAGE
  // ========================================================

  void showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  // ========================================================
  // UI
  // ========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Wardrobe',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),

        actions: [
          IconButton(onPressed: loadWardrobe, icon: const Icon(Icons.refresh)),
        ],
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : items.isEmpty
          ? buildEmptyState()
          : buildWardrobe(),

      // 👇 ADD THIS
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          // Open Add Clothing page
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddClothingPage()),
          );

          // Refresh wardrobe after coming back
          loadWardrobe();
        },

        icon: const Icon(Icons.add),

        label: const Text('Add Clothing'),
      ),
    );
  }
  // ========================================================
  // EMPTY
  // ========================================================

  Widget buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            const Icon(
              Icons.checkroom_outlined,
              size: 90,
              color: Colors.black26,
            ),

            const SizedBox(height: 20),

            const Text(
              'Your wardrobe is empty',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            const Text(
              'Add your clothes and let AI build outfits from them.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54),
            ),

            const SizedBox(height: 24),

            FilledButton.icon(
              onPressed: addClothing,
              icon: const Icon(Icons.add),
              label: const Text('Add Clothing'),
            ),
          ],
        ),
      ),
    );
  }

  // ========================================================
  // WARDROBE GRID
  // ========================================================

  Widget buildWardrobe() {
    return Column(
      children: [
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16),

            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 0.78,
            ),

            itemCount: items.length,

            itemBuilder: (_, index) {
              final item = items[index];

              return buildClothingCard(item);
            },
          ),
        ),

        // --------------------------------------------------
        // GENERATE OUTFIT
        // --------------------------------------------------
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),

            child: SizedBox(
              width: double.infinity,

              child: FilledButton.icon(
                onPressed: items.length < 2
                    ? null
                    : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const OutfitPage()),
                        );
                      },

                icon: const Icon(Icons.auto_awesome),

                label: const Text('Generate Outfit'),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ========================================================
  // CLOTHING CARD
  // ========================================================

  Widget buildClothingCard(ClothingItem item) {
    final imageUrl = '${ApiService.baseUrl}${item.imagePath}';

    return Card(
      clipBehavior: Clip.antiAlias,

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Expanded(
            child: Container(
              width: double.infinity,

              color: const Color(0xFFF8F7F4),

              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,

                errorBuilder: (_, __, ___) {
                  return const Center(child: Icon(Icons.broken_image_outlined));
                },
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(10),

            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      Text(
                        item.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),

                      const SizedBox(height: 3),

                      Text(
                        item.category,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),

                IconButton(
                  onPressed: () => deleteItem(item),

                  icon: const Icon(Icons.delete_outline, size: 21),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
