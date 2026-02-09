import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_first_app/shared/widgets/assignments_card.dart';

import 'add_assignments.dart';
import '../../shared/widgets/navbar/app_navbar.dart';
import '../../shared/widgets/navbar/provider.dart';
import '../../shared/widgets/add_button.dart';

class AssignmentsPage extends ConsumerWidget {
  const AssignmentsPage({super.key, this.withNavBar = true});

  final bool withNavBar;

  static const List<_AssignmentItem> _todayAssignments = [
    _AssignmentItem(
      subject: 'MATH',
      title: 'Algebra Worksheet 4.2',
      subtitle: 'Chapter 4: Polynomials',
      tagBg: Color(0xFFE7F0FF),
      tagColor: Color(0xFF2E7CF6),
      dueText: 'Due 4:00 PM',
      dueBg: Color(0xFFFFECEC),
      dueColor: Color(0xFFE65757),
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
      tagBg: Color(0xFFFBF7F1),
      tagColor: Color(0xFFE0B66B),
      dueText: '11:59 PM',
      dueColor: Color(0xFFA48C7E),
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
      tagBg: Color(0xFFDFF2EA),
      tagColor: Color(0xFF1C9E73),
      dueText: 'Wed, Oct 26',
      dueColor: Color(0xFFA48C7E),
      showDuePill: false,
      showDueIcon: false,
      showShadow: true,
      hideLeadingCircle: true,
    ),
    _AssignmentItem(
      subject: 'ENGLISH',
      title: 'Essay Outline',
      subtitle: 'Submit to Canvas',
      tagBg: Color(0xFFF0E9FF),
      tagColor: Color(0xFF9A5CFF),
      dueText: 'Fri, Oct 28',
      dueColor: Color(0xFFA48C7E),
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
      tagBg: Color(0xFFE7F0FF),
      tagColor: Color(0xFF2E7CF6),
      dueText: 'Mon, Oct 31',
      dueColor: Color(0xFFA48C7E),
      showDuePill: false,
      showDueIcon: false,
      showShadow: true,
      hideLeadingCircle: true,
    ),
  ];

  List<Widget> _buildAssignmentCards(List<_AssignmentItem> items) {
    final widgets = <Widget>[];
    for (var i = 0; i < items.length; i++) {
      widgets.add(_buildAssignmentCard(items[i]));
      if (i != items.length - 1) {
        widgets.add(const SizedBox(height: 14));
      }
    }
    return widgets;
  }

  Widget _buildAssignmentCard(_AssignmentItem item) {
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
          border: Border(left: BorderSide(color: Color(0xFFFF6B77), width: 4)),
        ),
        child: ClipRRect(borderRadius: BorderRadius.circular(16), child: card),
      );
    }

    return card;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(currentNavIndexProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F2EE),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              color: const Color(0xFFE2D3C6),
              padding: const EdgeInsets.fromLTRB(22, 14, 22, 18),
              child: Row(
                children: [
                  const Text(
                    'Assignments',
                    style: TextStyle(
                      fontSize: 24,
                      color: Color(0xFF8B6758),
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
                      color: const Color(0xFFF7F2EE),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xFFE5DBCF)),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.tune_rounded,
                          size: 20,
                          color: Color(0xFF8B6758),
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Subject',
                          style: TextStyle(
                            color: Color(0xFF8B6758),
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: Color(0xFF8B6758),
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
                        _TimelineSectionHeader(
                          title: 'TODAY',
                          taskCount: _todayAssignments.length,
                        ),
                        const SizedBox(height: 12),
                        ..._buildAssignmentCards(_todayAssignments),
                        const SizedBox(height: 28),
                        _TimelineSectionHeader(
                          title: 'THIS WEEK',
                          taskCount: _thisWeekAssignments.length,
                        ),
                        const SizedBox(height: 12),
                        ..._buildAssignmentCards(_thisWeekAssignments),
                        const SizedBox(height: 28),
                        _TimelineSectionHeader(
                          title: 'THIS WEEK',
                          taskCount: _nextWeekAssignments.length,
                        ),
                        const SizedBox(height: 12),
                        ..._buildAssignmentCards(_nextWeekAssignments),
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

class _TimelineSectionHeader extends StatelessWidget {
  const _TimelineSectionHeader({required this.title, required this.taskCount});

  final String title;
  final int taskCount;

  @override
  Widget build(BuildContext context) {
    final taskLabel = '$taskCount ${taskCount == 1 ? 'Task' : 'Tasks'}';

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFE2D9D0),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              letterSpacing: 1.4,
              fontWeight: FontWeight.w900,
              color: Color(0xFF8B6758),
            ),
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(child: Divider(thickness: 1, color: Color(0xFFE3DBD3))),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFF0E5D5),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Text(
            taskLabel,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: Color(0xFF8B6758),
            ),
          ),
        ),
      ],
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
