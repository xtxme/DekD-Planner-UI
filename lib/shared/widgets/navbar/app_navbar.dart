import 'package:flutter/material.dart';
import 'package:my_first_app/shared/theme/app_colors.dart';

class AppNavBar extends StatelessWidget {
  const AppNavBar({super.key, required this.currentIndex, required this.onTap});

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const Color _selectedIconColor = AppColors.cFFDEAF5F;
  static const Color _unselectedColor = AppColors.cFFA48C7E;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      selectedItemColor: _selectedIconColor,
      unselectedItemColor: _unselectedColor,
      showUnselectedLabels: true,
      selectedFontSize: 12,
      unselectedFontSize: 12,
      items: [
        _NavItem(icon: Icons.home, label: 'Home'),
        _NavItem(icon: Icons.menu_book, label: 'Subjects'),
        _NavItem(icon: Icons.assignment, label: 'Assignments'),
        _NavItem(icon: Icons.calendar_month, label: 'Calendar'),
        _NavItem(icon: Icons.settings, label: 'Settings'),
      ],
    );
  }
}

class _NavItem extends BottomNavigationBarItem {
  _NavItem({required IconData icon, required String label})
    : super(
        icon: _IconWidget(icon: icon),
        activeIcon: _IconWidget(icon: icon, isActive: true),
        label: label,
      );
}

class _IconWidget extends StatelessWidget {
  const _IconWidget({required this.icon, this.isActive = false});

  final IconData icon;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Icon(
      icon,
      size: 28,
      color: isActive ? AppNavBar._selectedIconColor : null,
    );
  }
}
