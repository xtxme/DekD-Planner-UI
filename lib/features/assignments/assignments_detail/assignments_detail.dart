import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:my_first_app/shared/theme/app_colors.dart';

import '../../../shared/widgets/navbar/app_navbar.dart';
import 'package:my_first_app/shared/providers/nav_provider.dart';
import '../providers.dart';
import '../edit_assignments/edit_assignments.dart';
import 'widgets/assignment_detail_action_buttons.dart';
import 'widgets/assignment_detail_header.dart';
import 'widgets/assignment_detail_notes_section.dart';
import 'widgets/assignment_detail_overview_section.dart';
import 'widgets/assignment_detail_stats_section.dart';

class AssignmentsDetailPage extends ConsumerWidget {
  const AssignmentsDetailPage({super.key, this.withNavBar = true});

  final bool withNavBar;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(currentNavIndexProvider);
    final draft = ref.watch(assignmentDraftProvider);
    final dueText = draft == null
        ? ''
        : 'Due: ${DateFormat('MMM dd, yyyy | hh:mm a').format(draft.dueDateTime)}';

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
                    if (draft == null) ...[
                      const Text(
                        'Assignment not found',
                        style: TextStyle(
                          fontSize: 26,
                          height: 1.15,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'This assignment may have been deleted.',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ] else ...[
                      AssignmentDetailOverviewSection(
                        title: draft.title,
                        dueText: dueText,
                      ),
                      const SizedBox(height: 28),
                      AssignmentDetailStatsSection(
                        subject: draft.subject,
                        status: 'In Progress',
                      ),
                      const SizedBox(height: 28),
                      AssignmentDetailNotesSection(notesText: draft.notes),
                    ],
                    const SizedBox(height: 22),
                    AssignmentDetailActionButtons(
                      onComplete: () {},
                      onEdit: draft == null
                          ? null
                          : () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      EditAssignmentsPage(initialDraft: draft),
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
}
