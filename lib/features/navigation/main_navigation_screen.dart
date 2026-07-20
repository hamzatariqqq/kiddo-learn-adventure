import 'package:flutter/material.dart';

import '../../shared/widgets/app_bottom_navigation.dart';
import '../badges/badges_screen.dart';
import '../home/home_screen.dart';
import '../learn/learn_screen.dart';
import '../play/play_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int selectedIndex = 0;

  final List<Widget> screens = const [
    HomeScreen(),
    LearnScreen(),
    PlayScreen(),
    BadgesScreen(),
  ];

  void changeTab(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: selectedIndex, children: screens),
      bottomNavigationBar: AppBottomNavigation(
        selectedIndex: selectedIndex,
        onTap: changeTab,
      ),
    );
  }
}
