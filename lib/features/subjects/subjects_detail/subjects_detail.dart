import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_first_app/shared/theme/app_colors.dart';

import '../../../shared/widgets/add_button.dart';
import '../../../shared/widgets/navbar/app_navbar.dart';
import '../../../shared/widgets/navbar/provider.dart';
import '../widgets/segmented_tabs.dart';
import '../widgets/subject_card.dart';
import '../widgets/top_bar.dart';

enum _AssignmentStatus { toDo, inProgress, late, completed }

class _AssignmentItem {
  const _AssignmentItem({
    required this.title,
    required this.dueText,
    required this.icon,
    required this.status,
    required this.completed,
  });

  final String title;
  final String dueText;
  final IconData icon;
  final _AssignmentStatus status;
  final bool completed;
}

class SubjectsDetailPage extends ConsumerStatefulWidget {
  const SubjectsDetailPage({super.key, this.withNavBar = true});

  final bool withNavBar;

  @override
  ConsumerState<SubjectsDetailPage> createState() => _SubjectsDetailPageState();
}

class _SubjectsDetailPageState extends ConsumerState<SubjectsDetailPage> {
  bool _showUpcoming = true;

  static const List<_AssignmentItem> _allAssignments = [
    _AssignmentItem(
      title: 'Calculus Homework ...',
      dueText: 'Due: Oct 12, 2023 | 14:00',
      icon: Icons.assignment_outlined,
      status: _AssignmentStatus.toDo,
      completed: false,
    ),
    _AssignmentItem(
      title: 'Midterm Project ...',
      dueText: 'Due: Oct 19, 2023 | 23:59',
      icon: Icons.menu_book_outlined,
      status: _AssignmentStatus.inProgress,
      completed: false,
    ),
    _AssignmentItem(
      title: 'Quiz 3 Review',
      dueText: 'Due: Oct 10, 2023 | 09:00',
      icon: Icons.quiz_outlined,
      status: _AssignmentStatus.late,
      completed: false,
    ),
    _AssignmentItem(
      title: 'Chapter Summary',
      dueText: 'Submitted: Oct 01, 2023 | 10:00',
      icon: Icons.check_circle_outline,
      status: _AssignmentStatus.completed,
      completed: true,
    ),
  ];

  List<_AssignmentItem> get _visibleAssignments => _allAssignments
      .where((item) => _showUpcoming ? !item.completed : item.completed)
      .toList();

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(currentNavIndexProvider);

    return Scaffold(
      backgroundColor: AppColors.cFFF7F2EE,
      body: SafeArea(
        child: Column(
          children: [
            SubjectsDetailTopBar(
              onBack: () => Navigator.of(context).pop(),
              onEdit: () {},
              onDelete: () {},
            ),
            Expanded(
              child: Stack(
                children: [
                  SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 110),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SubjectInfoCard(
                          category: 'Science',
                          title: 'Advanced\nMathematics',
                          code: 'MAT101',
                          teacherInfo: 'Mr. Smith - Room 302.',
                          description: 'Focus on Calculus and Linear Algebra.',
                          icon: Icons.calculate_rounded,
                        ),
                        const SizedBox(height: 16),
                        SubjectSegmentedTabs(
                          isUpcoming: _showUpcoming,
                          onUpcomingTap: () =>
                              setState(() => _showUpcoming = true),
                          onCompletedTap: () =>
                              setState(() => _showUpcoming = false),
                        ),
                        const SizedBox(height: 20),
                        _buildSectionTitle(),
                        const SizedBox(height: 14),
                        ..._visibleAssignments.map(
                          (item) => Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: _buildAssignmentCard(item),
                          ),
                        ),
                      ],
                    ),
                  ),
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

  Widget _buildSectionTitle() {
    return const Text(
      'ASSIGNMENTS FOR THIS SUBJECT',
      style: TextStyle(
        letterSpacing: 3,
        fontSize: 15,
        fontWeight: FontWeight.w900,
        color: AppColors.cFF9A7E70,
      ),
    );
  }

  Widget _buildAssignmentCard(_AssignmentItem item) {
    final dueColor = item.status == _AssignmentStatus.late
        ? AppColors.cFFE54A4A
        : AppColors.cFFA48C7E;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.cFFF0E6DE),
      ),
      child: Row(
        children: [
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: AppColors.cFFF1ECE7,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(item.icon, size: 34, color: AppColors.cFF8B6758),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: AppColors.cFF8B6758,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      item.status == _AssignmentStatus.late
                          ? Icons.error_rounded
                          : Icons.calendar_today_outlined,
                      size: 18,
                      color: dueColor,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item.dueText,
                        style: TextStyle(
                          fontSize: 16,
                          color: dueColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: _statusBg(item.status),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              _statusText(item.status),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: _statusFg(item.status),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _statusText(_AssignmentStatus status) {
    switch (status) {
      case _AssignmentStatus.toDo:
        return 'To Do';
      case _AssignmentStatus.inProgress:
        return 'In Progress';
      case _AssignmentStatus.late:
        return 'Late';
      case _AssignmentStatus.completed:
        return 'Done';
    }
  }

  Color _statusBg(_AssignmentStatus status) {
    switch (status) {
      case _AssignmentStatus.toDo:
        return AppColors.cFFF4E3CD;
      case _AssignmentStatus.inProgress:
        return AppColors.cFFDCE7FF;
      case _AssignmentStatus.late:
        return AppColors.cFFF9DDE0;
      case _AssignmentStatus.completed:
        return AppColors.cFFDFF2EA;
    }
  }

  Color _statusFg(_AssignmentStatus status) {
    switch (status) {
      case _AssignmentStatus.toDo:
        return AppColors.cFFD45C14;
      case _AssignmentStatus.inProgress:
        return AppColors.cFF2E64D4;
      case _AssignmentStatus.late:
        return AppColors.cFFD64545;
      case _AssignmentStatus.completed:
        return AppColors.cFF1C9E73;
    }
  }
}
