import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/widgets/app_navbar.dart';
import 'providers.dart';
import '../subjects/subjects_page.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  static const List<String> _titles = [
    'Home',
    'Subjects',
    'Assignments',
    'Calendar',
    'Settings',
  ];

  static const List<Widget> _pages = [
    _HomeTab(),
    SubjectsPage(),
    _PlaceholderTab(title: 'Assignments Page'),
    _PlaceholderTab(title: 'Calendar Page'),
    _PlaceholderTab(title: 'Settings Page'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(currentNavIndexProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[currentIndex]),
      ),
      body: IndexedStack(
        index: currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: AppNavBar(
        currentIndex: currentIndex,
        onTap: (index) =>
            ref.read(currentNavIndexProvider.notifier).state = index,
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Home Page'),
    );
  }
}

class _PlaceholderTab extends StatelessWidget {
  const _PlaceholderTab({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(title),
    );
  }
}
