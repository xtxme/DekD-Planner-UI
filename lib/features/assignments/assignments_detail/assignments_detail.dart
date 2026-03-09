import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:my_first_app/features/assignments/data/models/assignment_row.dart';
import 'package:my_first_app/features/assignments/models/assignment_draft.dart';
import 'package:my_first_app/features/assignments/models/assignments_feed_item.dart';
import 'package:my_first_app/features/assignments/presentation/providers/assignment_reminder_provider.dart';
import 'package:my_first_app/features/subjects/data/models/subject_row.dart';
import 'package:my_first_app/features/subjects/presentation/subject_icon_resolver.dart';
import 'package:my_first_app/features/subjects/providers.dart';
import 'package:my_first_app/shared/theme/app_colors.dart';

import '../../../shared/widgets/navbar/app_navbar.dart';
import 'package:my_first_app/shared/providers/nav_provider.dart';
import '../edit_assignments/edit_assignments.dart';
import '../providers.dart';
import 'utils/assignment_detail_helpers.dart';
import 'widgets/assignment_detail_action_buttons.dart';
import 'widgets/assignment_detail_header.dart';
import 'widgets/assignment_detail_hero_section.dart';
import 'widgets/assignment_detail_notes_section.dart';
import 'widgets/assignment_detail_stats_section.dart';

class AssignmentsDetailPage extends ConsumerStatefulWidget {
  const AssignmentsDetailPage({
    super.key,
    required this.item,
    this.withNavBar = true,
  });

  final bool withNavBar;
  final AssignmentsFeedItem item;

  @override
  ConsumerState<AssignmentsDetailPage> createState() =>
      _AssignmentsDetailPageState();
}

class _AssignmentsDetailPageState extends ConsumerState<AssignmentsDetailPage> {
  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(currentNavIndexProvider);
    final isLocal = widget.item.source == AssignmentFeedSource.local;
    final localDraft = isLocal ? _toAssignmentDraft(widget.item) : null;

    final dueText =
        'Due: ${DateFormat('MMM dd, yyyy | hh:mm a').format(widget.item.dueAt)}';
    final notesText = widget.item.detailsText.trim().isEmpty
        ? 'No notes or instructions.'
        : widget.item.detailsText;
    final notesHtml = widget.item.source == AssignmentFeedSource.canvas
        ? widget.item.detailsHtml
        : null;
    final statusText = _formatStatus(widget.item.status, widget.item.source);
    final subjects = ref.watch(subjectListProvider).valueOrNull ?? const [];
    final subjectIcon = _resolveSubjectIcon(
      item: widget.item,
      subjects: subjects,
    );

    final timeRemaining = calculateTimeRemaining(widget.item.dueAt);
    final timeRemainingColor = getTimeRemainingColor(timeRemaining);
    final priority = calculatePriority(widget.item.dueAt, widget.item.status);
    final priorityColor = getPriorityColor(priority);

    final showComplete = isLocal;
    final showEdit = isLocal;
    final showDelete = isLocal;

    void onComplete() async {
      final draft = localDraft;
      if (draft?.id == null) return;

      try {
        final dao = ref.read(assignmentDaoProvider);
        final assignment = await dao.getAll().then(
          (rows) => rows.firstWhere(
            (r) => r.id == draft!.id,
            orElse: () => rows.first,
          ),
        );

        final updated = AssignmentRow(
          id: assignment.id,
          title: assignment.title,
          subject: assignment.subject,
          subjectId: assignment.subjectId,
          dueAt: assignment.dueAt,
          notes: assignment.notes,
          status: 'completed',
          completedAt: DateTime.now(),
        );

        await dao.update(updated);
        ref.invalidate(assignmentListProvider);
        await ref
            .read(assignmentReminderSyncServiceProvider)
            .resyncIfAuthenticated();

        if (!mounted) return;
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Assignment completed!')),
          );
          Navigator.of(context).pop();
        }
      } catch (_) {
        if (!mounted) return;
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to complete assignment')),
          );
        }
      }
    }

    void onEdit() {
      if (localDraft == null) return;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => EditAssignmentsPage(initialDraft: localDraft),
        ),
      );
    }

    void onDelete() async {
      final draft = localDraft;
      if (draft?.id == null) return;

      try {
        await ref.read(assignmentDaoProvider).delete(draft!.id!);
        ref.invalidate(assignmentListProvider);
      } catch (error, stackTrace) {
        debugPrint('ASSIGNMENT_DETAIL_DEBUG: delete failed: $error');
        debugPrintStack(stackTrace: stackTrace);

        if (!mounted) return;
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to delete assignment')),
          );
        }
        return;
      }

      try {
        await ref
            .read(assignmentReminderSyncServiceProvider)
            .resyncIfAuthenticated();
      } catch (error, stackTrace) {
        debugPrint(
          'ASSIGNMENT_DETAIL_DEBUG: reminder resync failed after delete: $error',
        );
        debugPrintStack(stackTrace: stackTrace);
      }

      if (!mounted) return;
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Assignment deleted')));
        Navigator.of(context).pop();
      }
    }

    return Scaffold(
      backgroundColor: AppColors.cFFF7F2EE,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AssignmentDetailHeader(
              title: 'Assignment Details',
              onBack: () => Navigator.of(context).pop(),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 26, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AssignmentDetailHeroSection(
                      title: widget.item.title,
                      timeRemaining: timeRemaining,
                      timeRemainingColor: timeRemainingColor,
                      dueText: dueText,
                    ),
                    const SizedBox(height: 20),
                    AssignmentDetailStatsSection(
                      subject: widget.item.subject,
                      status: statusText,
                      subjectIcon: subjectIcon,
                      priority: priority,
                      priorityColor: priorityColor,
                    ),
                    const SizedBox(height: 20),
                    AssignmentDetailNotesSection(
                      notesText: notesText,
                      notesHtml: notesHtml,
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: (showComplete || showEdit || showDelete)
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  color: AppColors.cFFF7F2EE,
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 8),
                  child: SafeArea(
                    top: false,
                    bottom: !widget.withNavBar,
                    child: AssignmentDetailActionButtons(
                      onComplete: onComplete,
                      onEdit: onEdit,
                      onDelete: onDelete,
                      showComplete: showComplete,
                      showEdit: showEdit,
                      showDelete: showDelete,
                    ),
                  ),
                ),
                if (widget.withNavBar)
                  AppNavBar(
                    currentIndex: currentIndex,
                    onTap: (index) {
                      ref.read(currentNavIndexProvider.notifier).state = index;
                    },
                  ),
              ],
            )
          : (widget.withNavBar
                ? AppNavBar(
                    currentIndex: currentIndex,
                    onTap: (index) {
                      ref.read(currentNavIndexProvider.notifier).state = index;
                    },
                  )
                : null),
    );
  }

  AssignmentDraft? _toAssignmentDraft(AssignmentsFeedItem item) {
    if (item.source != AssignmentFeedSource.local) {
      return null;
    }

    return AssignmentDraft(
      id: item.localAssignmentId,
      subjectId: item.subjectId,
      title: item.title,
      subject: item.subject,
      dueDateTime: item.dueAt,
      notes: item.detailsText,
    );
  }

  String _formatStatus(String status, AssignmentFeedSource source) {
    switch (status) {
      case 'to_do':
        return 'To Do';
      case 'in_progress':
        return 'In Progress';
      case 'late':
        return 'Late';
      case 'completed':
        return 'Completed';
      default:
        return status.trim().isEmpty ? 'Unknown' : status;
    }
  }

  IconData _resolveSubjectIcon({
    required AssignmentsFeedItem item,
    required List<SubjectRow> subjects,
  }) {
    final subjectId = item.subjectId?.trim();

    if (subjectId != null && subjectId.isNotEmpty) {
      for (final subject in subjects) {
        if (subject.id == subjectId) {
          return resolveSubjectIconCodepoint(subject.iconCodepoint);
        }
      }
    }

    final normalizedSubjectName = item.subject.trim().toLowerCase();
    if (normalizedSubjectName.isNotEmpty) {
      for (final subject in subjects) {
        if (subject.name.trim().toLowerCase() == normalizedSubjectName) {
          return resolveSubjectIconCodepoint(subject.iconCodepoint);
        }
      }
    }

    return resolveSubjectIconCodepoint(0);
  }
}
