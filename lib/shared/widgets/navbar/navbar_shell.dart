import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_first_app/shared/providers/nav_provider.dart';

import '../../../features/assignments/assignments_page/assignments_page.dart';
import '../../../features/home/home_page.dart';
import '../../../features/settings/settings_page.dart';
import '../../../features/subjects/subjects_page/subjects_page.dart';
import 'app_navbar.dart';

class NavbarShell extends ConsumerWidget {
  const NavbarShell({super.key});

  static const List<Widget> _pages = [
    HomePage(),
    SubjectsPage(withNavBar: false),
    AssignmentsPage(withNavBar: false),
    SettingsPage(withNavBar: false),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(currentNavIndexProvider);
    return Scaffold(
      body: IndexedStack(index: currentIndex, children: _pages),
      bottomNavigationBar: AppNavBar(
        currentIndex: currentIndex,
        onTap: (index) =>
            ref.read(currentNavIndexProvider.notifier).state = index,
      ),
    );
  }
}
