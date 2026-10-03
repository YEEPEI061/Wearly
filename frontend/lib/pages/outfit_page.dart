import 'package:flutter/material.dart';

import '../services/api_service.dart';

class OutfitPage extends StatefulWidget {
  const OutfitPage({super.key});

  @override
  State<OutfitPage> createState() => _OutfitPageState();
}

class _OutfitPageState extends State<OutfitPage> {
  Map<String, dynamic>? outfit;

  bool loading = true;

  String? error;

  int outfitNumber = 0;

  // Current feedback for the displayed outfit.
  // null = no feedback yet
  String? feedback;

  // Prevent multiple feedback requests at the same time.
  bool feedbackLoading = false;

  @override
  void initState() {
    super.initState();

    generateOutfit();
  }

  // ========================================================
  // GENERATE OUTFIT
  // ========================================================

  Future<void> generateOutfit() async {
    if (mounted) {
      setState(() {
        loading = true;
        error = null;
      });
    }

    try {
      final result = await ApiService.generateOutfit();

      if (!mounted) return;

      setState(() {
        outfit = result;
        outfitNumber++;
        loading = false;
        feedback = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        error = e.toString();
        loading = false;
      });
    }
  }

  // ========================================================
  // UI
  // ========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Stylist'),
        actions: [
          IconButton(
            onPressed: loading ? null : generateOutfit,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error != null
          ? buildError()
          : buildOutfit(),
    );
  }

  // ========================================================
  // ERROR
  // ========================================================

  Widget buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 60),

            const SizedBox(height: 16),

            Text(error!, textAlign: TextAlign.center),

            const SizedBox(height: 20),

            FilledButton(
              onPressed: generateOutfit,
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  // ========================================================
  // OUTFIT
  // ========================================================

  Widget buildOutfit() {
    if (outfit == null) {
      return const Center(child: Text('No outfit generated.'));
    }

    final List items = outfit!['items'] ?? [];

    if (items.isEmpty) {
      return const Center(child: Text('No suitable outfit found.'));
    }

    final String title = outfit!['title'] ?? 'AI Outfit';

    final String reason = outfit!['reason'] ?? '';

    final String style = outfit!['style'] ?? '';

    final String occasion = outfit!['occasion'] ?? '';

    return RefreshIndicator(
      onRefresh: generateOutfit,

      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),

        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            // ==================================================
            // HEADER
            // ==================================================
            Text(
              title,
              style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            if (style.isNotEmpty)
              Text(
                style,
                style: const TextStyle(fontSize: 18, color: Colors.black54),
              ),

            if (occasion.isNotEmpty) ...[
              const SizedBox(height: 6),

              Text(
                'Best for $occasion',
                style: const TextStyle(color: Colors.black54),
              ),
            ],

            const SizedBox(height: 24),

            // ==================================================
            // OUTFIT PREVIEW
            // ==================================================
            buildOutfitPreview(items),

            const SizedBox(height: 24),

            // ==================================================
            // ITEMS
            // ==================================================
            const Text(
              'Pieces',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            ...items.map((item) => buildClothingCard(item)),

            const SizedBox(height: 12),

            buildReasonCard(reason),

            const SizedBox(height: 20),

            // ==================================================
            // OUTFIT FEEDBACK
            // ==================================================
            buildFeedbackCard(),

            const SizedBox(height: 24),

            // ==================================================
            // GENERATE ANOTHER
            // ==================================================
            SizedBox(
              width: double.infinity,

              child: FilledButton.icon(
                onPressed: loading ? null : generateOutfit,

                icon: const Icon(Icons.auto_awesome),

                label: const Text('Generate Another Outfit'),
              ),
            ),

            const SizedBox(height: 12),

            Center(
              child: Text(
                'Outfit #$outfitNumber',
                style: const TextStyle(color: Colors.black45),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ========================================================
  // OUTFIT PREVIEW
  // ========================================================

  Widget buildOutfitPreview(List items) {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: const Color(0xFFF8F7F4),

        borderRadius: BorderRadius.circular(24),
      ),

      child: Column(
        children: [
          const Row(
            children: [
              Icon(Icons.auto_awesome),

              SizedBox(width: 8),

              Text(
                'Styled together',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ],
          ),

          const SizedBox(height: 16),

          ...items.map((item) {
            final imageUrl = '${ApiService.baseUrl}${item['image_url']}';

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),

              child: Container(
                height: 180,

                width: double.infinity,

                decoration: BoxDecoration(
                  color: Colors.white,

                  borderRadius: BorderRadius.circular(16),
                ),

                child: Image.network(
                  imageUrl,

                  fit: BoxFit.contain,

                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Icon(Icons.image_not_supported, size: 40),
                    );
                  },
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // ========================================================
  // CLOTHING CARD
  // ========================================================

  Widget buildClothingCard(dynamic item) {
    final imageUrl = '${ApiService.baseUrl}${item['image_url']}';

    final name = item['name'] ?? 'Clothing';

    final color = item['color'] ?? '';

    final category = item['category'] ?? '';

    return Card(
      margin: const EdgeInsets.only(bottom: 14),

      clipBehavior: Clip.antiAlias,

      child: SizedBox(
        height: 150,

        child: Row(
          children: [
            // =================================================
            // IMAGE
            // =================================================
            SizedBox(
              width: 150,

              child: Container(
                color: const Color(0xFFF8F7F4),

                child: Image.network(
                  imageUrl,

                  fit: BoxFit.contain,

                  errorBuilder: (context, error, stackTrace) {
                    return const Center(child: Icon(Icons.image_not_supported));
                  },
                ),
              ),
            ),

            // =================================================
            // INFORMATION
            // =================================================
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),

                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,

                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text(
                      name,

                      style: const TextStyle(
                        fontSize: 18,

                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 8),

                    if (color.isNotEmpty)
                      Text(
                        color,

                        style: const TextStyle(color: Colors.black54),
                      ),

                    const SizedBox(height: 4),

                    Text(
                      formatCategory(category),

                      style: const TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ========================================================
  // CATEGORY NAME
  // ========================================================

  String formatCategory(String category) {
    switch (category) {
      case 'upper':
        return 'Upper body';

      case 'lower':
        return 'Lower body';

      case 'full':
        return 'Full body';

      default:
        return category;
    }
  }

  // ========================================================
  // AI REASON
  // ========================================================

  Widget buildReasonCard(String reason) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            const Row(
              children: [
                Icon(Icons.auto_awesome),

                SizedBox(width: 8),

                Text(
                  'Why this outfit?',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Text(
              reason.isEmpty
                  ? 'These pieces were selected because their colors, categories and style work well together.'
                  : reason,

              style: const TextStyle(color: Colors.black54, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  // ========================================================
  // OUTFIT FEEDBACK
  // ========================================================

  Future sendFeedback(String type) async {
    if (outfit == null || feedbackLoading) {
      return;
    }

    final List items = outfit!['items'] ?? [];

    if (items.isEmpty) {
      return;
    }

    final List<String> outfitKey = items
        .map<String>((item) => item['id'].toString())
        .toList();

    setState(() {
      feedbackLoading = true;
    });

    try {
      await ApiService.sendOutfitFeedback(outfitKey: outfitKey, feedback: type);

      if (!mounted) return;

      setState(() {
        feedback = type;
        feedbackLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            type == 'like' ? 'You liked this outfit ❤️' : 'Feedback saved',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        feedbackLoading = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not save feedback: $e')));
    }
  }

  // ========================================================
  // FEEDBACK CARD
  // ========================================================

  Widget buildFeedbackCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            const Row(
              children: [
                Icon(Icons.psychology_outlined),

                SizedBox(width: 8),

                Text(
                  'What do you think?',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ],
            ),

            const SizedBox(height: 8),

            const Text(
              'Your feedback helps AI understand your style preferences.',
              style: TextStyle(color: Colors.black54),
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: feedbackLoading
                        ? null
                        : () => sendFeedback('like'),

                    icon: Icon(
                      feedback == 'like'
                          ? Icons.thumb_up
                          : Icons.thumb_up_outlined,
                    ),

                    label: const Text('Like'),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: feedbackLoading
                        ? null
                        : () => sendFeedback('dislike'),

                    icon: Icon(
                      feedback == 'dislike'
                          ? Icons.thumb_down
                          : Icons.thumb_down_outlined,
                    ),

                    label: const Text('Dislike'),
                  ),
                ),
              ],
            ),

            if (feedback != null) ...[
              const SizedBox(height: 12),

              Center(
                child: Text(
                  feedback == 'like'
                      ? 'You liked this outfit.'
                      : 'You disliked this outfit.',
                  style: const TextStyle(color: Colors.black54),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
