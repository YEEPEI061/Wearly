import 'package:flutter/material.dart';
import 'package:frontend/pages/home_page.dart';
import 'package:frontend/pages/wardrobe_page.dart';
import 'package:frontend/pages/stylist_start_page.dart';
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

  final GlobalKey<HistoryPageState> _historyKey = GlobalKey<HistoryPageState>();

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();

    _pages = [
      HomePage(onNavigateToTab: _onBottomNavTap),
      const WardrobePage(),
      const StylistStartPage(),
      HistoryPage(key: _historyKey),
      const ProfilePage(),
    ];
  }

  void _onBottomNavTap(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 3) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _historyKey.currentState?.resetToToday();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      body: IndexedStack(index: _selectedIndex, children: _pages),

      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onItemSelected: _onBottomNavTap,
      ),
    );
  }
}
