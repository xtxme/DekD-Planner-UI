import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../features/assignments/assignments_page.dart';
import '../../../features/home/home_page.dart';
import '../../../features/settings/settings_page.dart';
import '../../../features/subjects/subjects_page.dart';
import 'app_navbar.dart';
import 'provider.dart';

class NavbarShell extends ConsumerWidget {
  const NavbarShell({super.key});

  static const List<Widget> _pages = [
    HomePage(),
    SubjectsPage(withNavBar: false),
    AssignmentsPage(withNavBar: false),
    _PlaceholderTab(title: 'Calendar Page'),
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

class _PlaceholderTab extends StatelessWidget {
  const _PlaceholderTab({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Center(child: Text(title));
  }
}
