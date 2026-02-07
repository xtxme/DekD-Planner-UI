import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_first_app/shared/widgets/assignments_card.dart';

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
      dueText: 'Due 16:00 PM',
      dueBg: Color(0xFFFFE7E7),
      dueColor: Color(0xFFE05A5A),
      showDuePill: true,
      showShadow: true,
    ),
    _AssignmentItem(
      subject: 'HISTORY',
      title: 'Algebra Worksheet 4.2',
      subtitle: 'Chapter 4: Polynomials',
      tagBg: Color(0xFFFBF7F1),
      tagColor: Color(0xFFE0B66B),
      dueText: 'Due 11:59 PM',
      dueColor: Color(0xFFA48C7E),
      showDuePill: false,
      showShadow: true,
    ),
  ];

  static const List<_AssignmentItem> _tomorrowAssignments = [
    _AssignmentItem(
      subject: 'CHEMISTRY',
      title: 'Algebra Worksheet 4.2',
      subtitle: 'Chapter 4: Polynomials',
      tagBg: Color(0x335FAF97),
      tagColor: Color(0xFF5FAF97),
      dueText: 'Due 11:59 PM',
      dueColor: Color(0xFFA48C7E),
      showDuePill: false,
    ),
    _AssignmentItem(
      subject: 'CHEMISTRY',
      title: 'Lab Report Draft',
      subtitle: 'Experiment 12: Titration',
      tagBg: Color(0x335FAF97),
      tagColor: Color(0xFF5FAF97),
      dueText: 'Due 11:59 PM',
      dueColor: Color(0xFFA48C7E),
      showDuePill: false,
    ),
  ];

  List<Widget> _buildAssignmentCards(List<_AssignmentItem> items) {
    final widgets = <Widget>[];
    for (var i = 0; i < items.length; i++) {
      final item = items[i];
      widgets.add(
        AssignmentsCard(
          subject: item.subject,
          title: item.title,
          subtitle: item.subtitle,
          tagBg: item.tagBg,
          tagColor: item.tagColor,
          dueText: item.dueText,
          dueColor: item.dueColor,
          dueBg: item.dueBg,
          showDuePill: item.showDuePill,
          showShadow: item.showShadow,
        ),
      );
      if (i != items.length - 1) {
        widgets.add(const SizedBox(height: 12));
      }
    }
    return widgets;
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
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: const Text(
                'Assignments',
                style: TextStyle(
                  fontSize: 28,
                  color: Color(0xFF826559),
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            Expanded(
              child: Stack(
                children: [
                  SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SectionHeader(
                          title: 'Today',
                          accentColor: const Color(0xFFDBBA7C),
                          trailingText: '${_todayAssignments.length} Tasks',
                        ),
                        const SizedBox(height: 12),
                        ..._buildAssignmentCards(_todayAssignments),
                        const SizedBox(height: 24),
                        const _SectionHeader(
                          title: 'Tomorrow',
                          accentColor: Color(0xFFD9C9BD),
                        ),
                        const SizedBox(height: 12),
                        ..._buildAssignmentCards(_tomorrowAssignments),
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

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.accentColor,
    this.trailingText,
  });

  final String title;
  final Color accentColor;
  final String? trailingText;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 6,
          height: 28,
          decoration: BoxDecoration(
            color: accentColor,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: Color(0xFF826559),
          ),
        ),
        if (trailingText != null) ...[
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFE2D3C6),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              trailingText!,
              style: const TextStyle(
                fontSize: 15,
                color: Color(0xFF826559),
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
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
    this.showShadow = false,
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
  final bool showShadow;
}
