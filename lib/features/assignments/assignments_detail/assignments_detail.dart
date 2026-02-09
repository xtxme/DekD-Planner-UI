import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_first_app/shared/theme/app_colors.dart';

import '../../../shared/widgets/navbar/app_navbar.dart';
import '../../../shared/widgets/navbar/provider.dart';
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
                    const AssignmentDetailOverviewSection(
                      title: 'Algebra Worksheet 4.2',
                      dueText: 'Due: Oct 10, 2023 | 09:00',
                    ),
                    const SizedBox(height: 28),
                    const AssignmentDetailStatsSection(
                      subject: 'Mathematics',
                      status: 'In Progress',
                    ),
                    const SizedBox(height: 28),
                    const AssignmentDetailNotesSection(
                      notesText:
                          'Complete all problems in Chapter 4 section 2. '
                          'Make sure to show your work for the polynomial '
                          'division problems.\n\n'
                          'Remember to check the back of the book for '
                          'odd-numbered answers.\n'
                          'Upload the scan as a single PDF.',
                    ),
                    const SizedBox(height: 22),
                    AssignmentDetailActionButtons(
                      onComplete: () {},
                      onEdit: () {},
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
