import 'package:flutter/material.dart';
import 'package:frontend/pages/home_page.dart';
import 'package:frontend/pages/wardrobe_page.dart';
import 'package:frontend/pages/stylist_page.dart';
import 'package:frontend/pages/history_page.dart';
import 'package:frontend/pages/profile_page.dart';
import 'package:frontend/widgets/bottom_nav_bar.dart';
import 'package:frontend/theme/app_colors.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    HomePage(),
    WardrobePage(),
    StylistPage(),
    HistoryPage(),
    ProfilePage(),
  ];

  void _onBottomNavTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),

      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onItemSelected: _onBottomNavTap,
      ),
    );
  }
}