import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

class AppBottomNavigation extends StatelessWidget {
  const AppBottomNavigation({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  final int selectedIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: onTap,
      height: 76,
      elevation: 0,
      backgroundColor: AppColors.white,
      indicatorColor: AppColors.primaryBlue.withValues(alpha: 0.15),
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_rounded),
          selectedIcon: Icon(Icons.home_rounded),
          label: 'Home',
        ),
        NavigationDestination(
          icon: Icon(Icons.menu_book_rounded),
          selectedIcon: Icon(Icons.menu_book_rounded),
          label: 'Learn',
        ),
        NavigationDestination(
          icon: Icon(Icons.sports_esports_rounded),
          selectedIcon: Icon(Icons.sports_esports_rounded),
          label: 'Play',
        ),
        NavigationDestination(
          icon: Icon(Icons.workspace_premium_rounded),
          selectedIcon: Icon(Icons.workspace_premium_rounded),
          label: 'Badges',
        ),
      ],
    );
  }
}