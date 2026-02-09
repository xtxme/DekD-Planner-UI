import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_first_app/shared/theme/app_colors.dart';

import '../../../shared/widgets/navbar/app_navbar.dart';
import 'package:my_first_app/shared/providers/nav_provider.dart';
import '../edit_subjects/edit_subjects.dart';
import 'widgets/segmented_tabs.dart';
import 'widgets/subject_card.dart';
import 'widgets/top_bar.dart';

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
    final visibleAssignments = _visibleAssignments;

    return Scaffold(
      backgroundColor: AppColors.cFFF7F2EE,
      body: SafeArea(
        child: Column(
          children: [
            SubjectsDetailTopBar(
              onBack: () => Navigator.of(context).pop(),
              onEdit: _openEditSubjectsPage,
              onDelete: _showDeletePlaceholderDialog,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SubjectInfoCard(
                      title: 'Advanced Mathematics',
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
                    if (visibleAssignments.isEmpty)
                      _buildEmptyState()
                    else
                      ...visibleAssignments.map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: _buildAssignmentCard(item),
                        ),
                      ),
                  ],
                ),
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
        letterSpacing: 1.5,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 65,
            height: 65,
            decoration: BoxDecoration(
              color: AppColors.cFFF1ECE7,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(item.icon, size: 30, color: AppColors.cFF8B6758),
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
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16,
                          color: dueColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _buildStatusChip(item),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(_AssignmentItem item) {
    return Container(
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
    );
  }

  Widget _buildEmptyState() {
    final title = _showUpcoming
        ? 'No upcoming assignments'
        : 'No completed assignments yet';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.cFFF0E6DE),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.inbox_outlined,
            size: 30,
            color: AppColors.cFFA48C7E,
          ),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: AppColors.cFF8B6758,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Tap + to add your next assignment.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.cFFA48C7E,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openEditSubjectsPage() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const EditSubjectsPage(withNavBar: false),
      ),
    );
  }

  void _showEditPlaceholderSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.cFFFDF9F4,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Edit Subject',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: AppColors.cFF8B6758,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Edit subject coming soon',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.cFFA48C7E,
                ),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showDeletePlaceholderDialog() async {
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Subject'),
          content: const Text(
            'Delete flow is not available yet. This is a placeholder dialog.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Understood'),
            ),
          ],
        );
      },
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
