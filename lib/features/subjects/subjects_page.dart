import 'package:flutter/material.dart';

class SubjectsPage extends StatefulWidget {
  const SubjectsPage({super.key});

  @override
  State<SubjectsPage> createState() => _SubjectsPageState();
}

class _SubjectsPageState extends State<SubjectsPage> {
  String _query = '';

  static const List<_SubjectItem> _subjects = [
    _SubjectItem(title: 'Mathematics', subtitle: '4 Assignments', icon: Icons.calculate_rounded),
    _SubjectItem(title: 'Physics', subtitle: '2 Assignments', icon: Icons.science_rounded),
    _SubjectItem(title: 'History', subtitle: '1 Assignment', icon: Icons.history_edu_rounded),
    _SubjectItem(title: 'Chemistry', subtitle: '3 Assignments', icon: Icons.biotech_rounded),
    _SubjectItem(title: 'English', subtitle: 'No active tasks', icon: Icons.menu_book_rounded),
    _SubjectItem(title: 'Comp Sci', subtitle: '5 Assignments', icon: Icons.computer_rounded),
    _SubjectItem(title: 'Art', subtitle: 'No active tasks', icon: Icons.palette_rounded),
    _SubjectItem(title: 'Geography', subtitle: '2 Assignments', icon: Icons.public_rounded),
  ];

  List<_SubjectItem> get _filteredSubjects {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return _subjects;
    return _subjects.where((s) => s.title.toLowerCase().contains(q)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F3EF),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: Stack(
                children: [
                  _buildGrid(),
                  _buildAddButton(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

}

class _SubjectItem {
  final String title;
  final String subtitle;
  final IconData icon;

  const _SubjectItem({
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}
