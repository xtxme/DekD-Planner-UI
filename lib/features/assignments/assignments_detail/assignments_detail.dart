import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:my_first_app/features/assignments/models/assignment_draft.dart';
import 'package:my_first_app/features/assignments/models/assignments_feed_item.dart';
import 'package:my_first_app/shared/theme/app_colors.dart';

import '../../../shared/widgets/navbar/app_navbar.dart';
import 'package:my_first_app/shared/providers/nav_provider.dart';
import '../edit_assignments/edit_assignments.dart';
import 'widgets/assignment_detail_action_buttons.dart';
import 'widgets/assignment_detail_header.dart';
import 'widgets/assignment_detail_notes_section.dart';
import 'widgets/assignment_detail_overview_section.dart';
import 'widgets/assignment_detail_stats_section.dart';

class AssignmentsDetailPage extends ConsumerWidget {
  const AssignmentsDetailPage({
    super.key,
    required this.item,
    this.withNavBar = true,
  });

  final bool withNavBar;
  final AssignmentsFeedItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(currentNavIndexProvider);
    final isLocal = item.source == AssignmentFeedSource.local;
    final localDraft = isLocal ? _toAssignmentDraft(item) : null;
    final dueText =
        'Due: ${DateFormat('MMM dd, yyyy | hh:mm a').format(item.dueAt)}';
    final notesText = item.detailsText.trim().isEmpty
        ? 'No notes or instructions.'
        : item.detailsText;
    final statusText = _formatStatus(item.status, item.source);

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
                    AssignmentDetailOverviewSection(
                      title: item.title,
                      dueText: dueText,
                    ),
                    const SizedBox(height: 28),
                    AssignmentDetailStatsSection(
                      subject: item.subject,
                      status: statusText,
                    ),
                    const SizedBox(height: 28),
                    AssignmentDetailNotesSection(notesText: notesText),
                    const SizedBox(height: 22),
                    AssignmentDetailActionButtons(
                      onComplete: () {},
                      showEdit: isLocal,
                      showDelete: isLocal,
                      onEdit: localDraft == null
                          ? null
                          : () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => EditAssignmentsPage(
                                    initialDraft: localDraft,
                                  ),
                                ),
                              );
                            },
                      onDelete: () {},
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: withNavBar
          ? AppNavBar(
              currentIndex: currentIndex,
              onTap: (index) {
                ref.read(currentNavIndexProvider.notifier).state = index;
              },
            )
          : null,
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
    if (source == AssignmentFeedSource.canvas) {
      return 'Canvas';
    }

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
}
