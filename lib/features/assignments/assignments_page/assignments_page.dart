import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_first_app/shared/widgets/assignments_card.dart';
import 'package:my_first_app/shared/theme/app_colors.dart';

import '../add_assignments/add_assignments.dart';
import '../assignments_detail/assignments_detail.dart';
import 'widgets/timeline_section_header.dart';
import '../../../shared/widgets/navbar/app_navbar.dart';
import 'package:my_first_app/shared/providers/nav_provider.dart';
import '../../../shared/widgets/add_button.dart';

class AssignmentsPage extends ConsumerWidget {
  const AssignmentsPage({super.key, this.withNavBar = true});

  final bool withNavBar;

  static const List<_AssignmentItem> _todayAssignments = [
    _AssignmentItem(
      subject: 'MATH',
      title: 'Algebra Worksheet 4.2',
      subtitle: 'Chapter 4: Polynomials',
      tagBg: AppColors.cFFE7F0FF,
      tagColor: AppColors.cFF2E7CF6,
      dueText: 'Due 4:00 PM',
      dueBg: AppColors.cFFFFECEC,
      dueColor: AppColors.cFFE65757,
      showDuePill: true,
      showDueIcon: true,
      showShadow: true,
      highlightLeftAccent: true,
      hideLeadingCircle: true,
    ),
    _AssignmentItem(
      subject: 'HISTORY',
      title: 'Read Chapter 4',
      subtitle: 'The Industrial Revolution',
      tagBg: AppColors.cFFFBF7F1,
      tagColor: AppColors.cFFE0B66B,
      dueText: '11:59 PM',
      dueColor: AppColors.cFFA48C7E,
      showDuePill: false,
      showDueIcon: false,
      showShadow: true,
      hideLeadingCircle: true,
      highlightLeftAccent: true,
    ),
  ];

  static const List<_AssignmentItem> _thisWeekAssignments = [
    _AssignmentItem(
      subject: 'CHEMISTRY',
      title: 'Lab Report: Titration',
      subtitle: 'Experiment 12',
      tagBg: AppColors.cFFDFF2EA,
      tagColor: AppColors.cFF1C9E73,
      dueText: 'Wed, Oct 26',
      dueColor: AppColors.cFFA48C7E,
      showDuePill: false,
      showDueIcon: false,
      showShadow: true,
      hideLeadingCircle: true,
    ),
    _AssignmentItem(
      subject: 'ENGLISH',
      title: 'Essay Outline',
      subtitle: 'Submit to Canvas',
      tagBg: AppColors.cFFF0E9FF,
      tagColor: AppColors.cFF9A5CFF,
      dueText: 'Fri, Oct 28',
      dueColor: AppColors.cFFA48C7E,
      showDuePill: false,
      showDueIcon: false,
      showShadow: true,
      hideLeadingCircle: true,
    ),
  ];

  static const List<_AssignmentItem> _nextWeekAssignments = [
    _AssignmentItem(
      subject: 'MATH',
      title: 'Midterm Review Packet',
      subtitle: 'Problems 1-50',
      tagBg: AppColors.cFFE7F0FF,
      tagColor: AppColors.cFF2E7CF6,
      dueText: 'Mon, Oct 31',
      dueColor: AppColors.cFFA48C7E,
      showDuePill: false,
      showDueIcon: false,
      showShadow: true,
      hideLeadingCircle: true,
    ),
  ];

  List<Widget> _buildAssignmentCards(
    BuildContext context,
    List<_AssignmentItem> items,
  ) {
    final widgets = <Widget>[];
    for (var i = 0; i < items.length; i++) {
      widgets.add(_buildAssignmentCard(context, items[i]));
      if (i != items.length - 1) {
        widgets.add(const SizedBox(height: 14));
      }
    }
    return widgets;
  }

  Widget _buildAssignmentCard(BuildContext context, _AssignmentItem item) {
    Widget card = AssignmentsCard(
      subject: item.subject,
      title: item.title,
      subtitle: item.subtitle,
      tagBg: item.tagBg,
      tagColor: item.tagColor,
      dueText: item.dueText,
      dueColor: item.dueColor,
      dueBg: item.dueBg,
      showDuePill: item.showDuePill,
      showDueIcon: item.showDueIcon,
      showLeadingCircle: !item.hideLeadingCircle,
      showShadow: item.showShadow,
    );

    if (item.highlightLeftAccent) {
      card = Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          border: Border(
            left: BorderSide(color: AppColors.cFFFF6B77, width: 4),
          ),
        ),
        child: ClipRRect(borderRadius: BorderRadius.circular(16), child: card),
      );
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const AssignmentsDetailPage(withNavBar: false),
            ),
          );
        },
        child: card,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(currentNavIndexProvider);

    return Scaffold(
      backgroundColor: AppColors.cFFF7F2EE,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              color: AppColors.cFFE2D3C6,
              padding: const EdgeInsets.fromLTRB(22, 14, 22, 18),
              child: Row(
                children: [
                  const Text(
                    'Assignments',
                    style: TextStyle(
                      fontSize: 24,
                      color: AppColors.cFF8B6758,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.cFFF7F2EE,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.cFFE5DBCF),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.tune_rounded,
                          size: 20,
                          color: AppColors.cFF8B6758,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Subject',
                          style: TextStyle(
                            color: AppColors.cFF8B6758,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: AppColors.cFF8B6758,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Stack(
                children: [
                  SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 110),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TimelineSectionHeader(
                          title: 'TODAY',
                          taskCount: _todayAssignments.length,
                        ),
                        const SizedBox(height: 12),
                        ..._buildAssignmentCards(context, _todayAssignments),
                        const SizedBox(height: 28),
                        TimelineSectionHeader(
                          title: 'THIS WEEK',
                          taskCount: _thisWeekAssignments.length,
                        ),
                        const SizedBox(height: 12),
                        ..._buildAssignmentCards(context, _thisWeekAssignments),
                        const SizedBox(height: 28),
                        TimelineSectionHeader(
                          title: 'THIS WEEK',
                          taskCount: _nextWeekAssignments.length,
                        ),
                        const SizedBox(height: 12),
                        ..._buildAssignmentCards(context, _nextWeekAssignments),
                      ],
                    ),
                  ),
                  AddButton(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              const AddAssignmentsPage(withNavBar: false),
                        ),
                      );
                    },
                  ),
                ],
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

class _AssignmentItem {
  const _AssignmentItem({
    required this.subject,
    required this.title,
    required this.subtitle,
    required this.tagBg,
    required this.tagColor,
    required this.dueText,
    required this.dueColor,
    this.dueBg,
    this.showDuePill = true,
    this.showDueIcon = true,
    this.showShadow = false,
    this.highlightLeftAccent = false,
    this.hideLeadingCircle = false,
  });

  final String subject;
  final String title;
  final String subtitle;
  final Color tagBg;
  final Color tagColor;
  final String dueText;
  final Color dueColor;
  final Color? dueBg;
  final bool showDuePill;
  final bool showDueIcon;
  final bool showShadow;
  final bool highlightLeftAccent;
  final bool hideLeadingCircle;
}
