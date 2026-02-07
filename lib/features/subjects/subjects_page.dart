import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/widgets/navbar/app_navbar.dart';
import '../../shared/widgets/navbar/provider.dart';
import 'widgets/header.dart';
import 'widgets/grid.dart';
import '../../shared/widgets/add_button.dart';

class SubjectsPage extends ConsumerStatefulWidget {
  const SubjectsPage({
    super.key,
    this.withNavBar = true,
  });

  final bool withNavBar;

  @override
  ConsumerState<SubjectsPage> createState() => _SubjectsPageState();
}

class _SubjectsPageState extends ConsumerState<SubjectsPage> {
  String _query = '';

  static const List<SubjectGridItem> _subjects = [
    SubjectGridItem(
      title: 'Mathematics',
      subtitle: '4 Assignments',
      icon: Icons.calculate_rounded,
    ),
    SubjectGridItem(
      title: 'Physics',
      subtitle: '2 Assignments',
      icon: Icons.science_rounded,
    ),
    SubjectGridItem(
      title: 'History',
      subtitle: '1 Assignment',
      icon: Icons.history_edu_rounded,
    ),
    SubjectGridItem(
      title: 'Chemistry',
      subtitle: '3 Assignments',
      icon: Icons.biotech_rounded,
    ),
    SubjectGridItem(
      title: 'English',
      subtitle: 'No active tasks',
      icon: Icons.menu_book_rounded,
    ),
    SubjectGridItem(
      title: 'Comp Sci',
      subtitle: '5 Assignments',
      icon: Icons.computer_rounded,
    ),
    SubjectGridItem(
      title: 'Art',
      subtitle: 'No active tasks',
      icon: Icons.palette_rounded,
    ),
    SubjectGridItem(
      title: 'Geography',
      subtitle: '2 Assignments',
      icon: Icons.public_rounded,
    ),
  ];

  List<SubjectGridItem> get _filteredSubjects {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) {
      return _subjects;
    }

    return _subjects.where((s) => s.title.toLowerCase().contains(q)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(currentNavIndexProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F3EF),
      body: SafeArea(
        child: Column(
          children: [
            SubjectsHeader(
              onQueryChanged: (value) {
                setState(() {
                  _query = value;
                });
              },
            ),
            Expanded(
              child: Stack(
                children: [
                  SubjectsGrid(items: _filteredSubjects),
                  const AddButton(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: widget.withNavBar
          ? AppNavBar(
              currentIndex: currentIndex,
              onTap: (index) {
                ref.read(currentNavIndexProvider.notifier).state = index;
              },
            )
          : null,
    );
  }
}
