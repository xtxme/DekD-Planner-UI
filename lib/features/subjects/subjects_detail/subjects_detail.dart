import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:my_first_app/features/assignments/data/models/assignment_row.dart';
import 'package:my_first_app/features/assignments/presentation/providers/assignment_list_provider.dart';
import 'package:my_first_app/features/home/data/models/canvas_assignment.dart';
import 'package:my_first_app/features/home/presentation/providers/home_tasks_provider.dart';
import 'package:my_first_app/features/subjects/data/models/canvas_course.dart';
import 'package:my_first_app/features/subjects/data/models/subject_row.dart';
import 'package:my_first_app/features/subjects/presentation/subject_icon_resolver.dart';
import 'package:my_first_app/features/subjects/presentation/providers/subject_providers.dart';
import 'package:my_first_app/features/subjects/subjects_detail/subject_detail_info.dart';
import 'package:my_first_app/shared/theme/app_colors.dart';

import '../../../shared/widgets/navbar/app_navbar.dart';
import 'package:my_first_app/shared/providers/nav_provider.dart';
import '../edit_subjects/edit_subjects.dart';
import 'widgets/segmented_tabs.dart';
import 'widgets/subject_card.dart';
import 'widgets/top_bar.dart';

enum _AssignmentStatus { toDo, inProgress, late, completed }

enum _AssignmentSource { local, canvas }

class _AssignmentItem {
  const _AssignmentItem({
    required this.title,
    required this.dueAt,
    required this.completedAt,
    required this.icon,
    required this.status,
    required this.source,
  });

  final String title;
  final DateTime dueAt;
  final DateTime? completedAt;
  final IconData icon;
  final _AssignmentStatus status;
  final _AssignmentSource source;

  bool get completed => status == _AssignmentStatus.completed;
}

class SubjectsDetailPage extends ConsumerStatefulWidget {
  const SubjectsDetailPage({
    super.key,
    this.withNavBar = true,
    required this.subject,
  });

  final bool withNavBar;
  final SubjectRow subject;

  @override
  ConsumerState<SubjectsDetailPage> createState() => _SubjectsDetailPageState();
}

class _SubjectsDetailPageState extends ConsumerState<SubjectsDetailPage> {
  bool _showUpcoming = true;
  late SubjectRow _subject;

  @override
  void initState() {
    super.initState();
    _subject = widget.subject;
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(currentNavIndexProvider);
    final localAssignmentsAsync = ref.watch(assignmentListProvider);
    final canvasAssignmentsAsync = ref.watch(canvasAssignmentsWithUserProvider);
    final canvasCourses = ref
        .watch(canvasCoursesProvider)
        .maybeWhen(
          data: (courses) => courses,
          orElse: () => const <CanvasCourse>[],
        );
    final subjectDetailInfo = resolveSubjectDetailInfo(
      subject: _subject,
      canvasCourses: canvasCourses,
    );

    return Scaffold(
      backgroundColor: AppColors.cFFF7F2EE,
      body: SafeArea(
        child: Column(
          children: [
            SubjectsDetailTopBar(
              onBack: () => Navigator.of(context).pop(),
              onEdit: _openEditSubjectsPage,
              onDelete: _showDeleteDialog,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SubjectInfoCard(
                      title: _subject.name,
                      code: _subject.code,
                      teacherInfo: subjectDetailInfo.teacherInfo,
                      description: subjectDetailInfo.description,
                      icon: resolveSubjectIconCodepoint(_subject.iconCodepoint),
                      subjectColor: Color(_subject.colorValue),
                    ),
                    const SizedBox(height: 16),
                    SubjectSegmentedTabs(
                      isUpcoming: _showUpcoming,
                      onUpcomingTap: () => setState(() => _showUpcoming = true),
                      onCompletedTap: () =>
                          setState(() => _showUpcoming = false),
                    ),
                    const SizedBox(height: 20),
                    _buildSectionTitle(),
                    const SizedBox(height: 14),
                    _buildAssignmentsList(
                      localAssignmentsAsync: localAssignmentsAsync,
                      canvasAssignmentsAsync: canvasAssignmentsAsync,
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

  Widget _buildAssignmentsList({
    required AsyncValue<List<AssignmentRow>> localAssignmentsAsync,
    required AsyncValue<CanvasAssignmentsResponse> canvasAssignmentsAsync,
  }) {
    return localAssignmentsAsync.when(
      loading: _buildLoadingState,
      error: (error, _) =>
          _buildErrorState('Failed to load local assignments: $error'),
      data: (localRows) {
        return canvasAssignmentsAsync.when(
          loading: _buildLoadingState,
          error: (error, _) =>
              _buildErrorState('Failed to load Canvas assignments: $error'),
          data: (canvasResponse) {
            final allItems = _buildItems(
              localRows: localRows,
              canvasAssignments: canvasResponse.assignments,
            );

            final upcomingItems =
                allItems
                    .where((item) => !item.completed)
                    .toList(growable: false)
                  ..sort((a, b) => a.dueAt.compareTo(b.dueAt));

            final completedItems =
                allItems.where((item) => item.completed).toList(growable: false)
                  ..sort(
                    (a, b) => (b.completedAt ?? b.dueAt).compareTo(
                      a.completedAt ?? a.dueAt,
                    ),
                  );

            final visibleAssignments = _showUpcoming
                ? upcomingItems
                : completedItems;

            if (visibleAssignments.isEmpty) {
              return _buildEmptyState();
            }

            return Column(
              children: visibleAssignments
                  .map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: _buildAssignmentCard(item),
                    ),
                  )
                  .toList(growable: false),
            );
          },
        );
      },
    );
  }

  List<_AssignmentItem> _buildItems({
    required List<AssignmentRow> localRows,
    required List<CanvasAssignment> canvasAssignments,
  }) {
    final subjectId = _subject.id;
    final subjectNameNormalized = _subject.name.trim().toLowerCase();

    final localItems = localRows
        .where((row) {
          if (subjectId != null &&
              subjectId.isNotEmpty &&
              row.subjectId != null) {
            return row.subjectId == subjectId;
          }

          return row.subject.trim().toLowerCase() == subjectNameNormalized;
        })
        .map(_mapLocalAssignment);

    final canvasItems = canvasAssignments
        .where((assignment) {
          return assignment.dueAt != null &&
              assignment.courseName.trim().toLowerCase() ==
                  subjectNameNormalized;
        })
        .map(_mapCanvasAssignment);

    return [...localItems, ...canvasItems];
  }

  _AssignmentItem _mapLocalAssignment(AssignmentRow row) {
    final status = _mapLocalStatus(row.status);

    return _AssignmentItem(
      title: row.title.trim().isNotEmpty
          ? row.title.trim()
          : 'Untitled assignment',
      dueAt: row.dueAt,
      completedAt: row.completedAt,
      icon: _iconForStatus(status, _AssignmentSource.local),
      status: status,
      source: _AssignmentSource.local,
    );
  }

  _AssignmentItem _mapCanvasAssignment(CanvasAssignment assignment) {
    final now = DateTime.now();
    final status = assignment.isCompleted
        ? _AssignmentStatus.completed
        : assignment.dueAt!.isBefore(now)
        ? _AssignmentStatus.late
        : _AssignmentStatus.inProgress;

    return _AssignmentItem(
      title: assignment.name.trim().isNotEmpty
          ? assignment.name.trim()
          : 'Untitled assignment',
      dueAt: assignment.dueAt!,
      completedAt: null,
      icon: _iconForStatus(status, _AssignmentSource.canvas),
      status: status,
      source: _AssignmentSource.canvas,
    );
  }

  _AssignmentStatus _mapLocalStatus(String status) {
    switch (status) {
      case 'to_do':
        return _AssignmentStatus.toDo;
      case 'in_progress':
        return _AssignmentStatus.inProgress;
      case 'late':
        return _AssignmentStatus.late;
      case 'completed':
        return _AssignmentStatus.completed;
      default:
        return _AssignmentStatus.inProgress;
    }
  }

  IconData _iconForStatus(_AssignmentStatus status, _AssignmentSource source) {
    if (source == _AssignmentSource.canvas) {
      return Icons.cloud_done_outlined;
    }

    switch (status) {
      case _AssignmentStatus.toDo:
        return Icons.assignment_outlined;
      case _AssignmentStatus.inProgress:
        return Icons.menu_book_outlined;
      case _AssignmentStatus.late:
        return Icons.quiz_outlined;
      case _AssignmentStatus.completed:
        return Icons.check_circle_outline;
    }
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

    final dueLabel = _buildDueLabel(item);

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
                        dueLabel,
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

  String _buildDueLabel(_AssignmentItem item) {
    final date = item.completed ? (item.completedAt ?? item.dueAt) : item.dueAt;
    final prefix = item.completed ? 'Submitted:' : 'Due:';
    return '$prefix ${DateFormat('MMM d, y | HH:mm').format(date)}';
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

  Widget _buildLoadingState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: CircularProgressIndicator(color: AppColors.cFFE0B35D),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.cFFF0E6DE),
      ),
      child: Text(
        message,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.cFF8B6758,
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
        ],
      ),
    );
  }

  Future<void> _openEditSubjectsPage() async {
    final updated = await Navigator.of(context).push<SubjectRow>(
      MaterialPageRoute(
        builder: (_) => EditSubjectsPage(withNavBar: false, subject: _subject),
      ),
    );

    if (!mounted || updated == null) {
      return;
    }

    setState(() {
      _subject = updated;
    });
  }

  Future<void> _showDeleteDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Subject'),
          content: Text('Are you sure you want to delete "${_subject.name}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.cFFE54A4A,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed == true && mounted) {
      final subjectId = _subject.id;
      if (subjectId != null && subjectId.isNotEmpty) {
        await ref.read(subjectDeleterProvider).delete(subjectId);
        if (mounted) {
          Navigator.of(context).pop();
        }
      }
    }
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
