import 'package:flutter/material.dart';
import 'package:frontend/pages/wardrobe_page.dart';

// import 'pages/wardrobe_page.dart';

void main() {
  runApp(const WardrobeApp());
}

class WardrobeApp extends StatelessWidget {
  const WardrobeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      title: 'AI Wardrobe',

      theme: ThemeData(
        useMaterial3: true,

        scaffoldBackgroundColor: const Color(0xFFF8F7F4),

        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6E6259)),
      ),

      home: const WardrobePage(),
    );
  }
}
