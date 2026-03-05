import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:my_first_app/features/assignments/models/assignments_feed_item.dart';
import 'package:my_first_app/features/assignments/presentation/providers/assignment_list_provider.dart';
import 'package:my_first_app/shared/widgets/assignments_card.dart';
import 'package:my_first_app/shared/theme/app_colors.dart';

import '../add_assignments/add_assignments.dart';
import '../assignments_detail/assignments_detail.dart';
import 'widgets/timeline_section_header.dart';
import '../../../shared/widgets/navbar/app_navbar.dart';
import 'package:my_first_app/shared/providers/nav_provider.dart';
import '../../../shared/widgets/add_button.dart';
import 'package:my_first_app/features/subjects/providers.dart';

class AssignmentsPage extends ConsumerWidget {
  const AssignmentsPage({super.key, this.withNavBar = true});

  final bool withNavBar;

  List<Widget> _buildAssignmentCards(
    BuildContext context,
    List<AssignmentsFeedItem> items,
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

  Widget _buildAssignmentCard(BuildContext context, AssignmentsFeedItem item) {
    final isDueToday = _isToday(item.dueAt);
    final tagColors = _tagColorsFor(item.subject);

    Widget card = AssignmentsCard(
      subject: item.subject.toUpperCase(),
      title: item.title,
      subtitle: item.subtitle,
      tagBg: tagColors.background,
      tagColor: tagColors.foreground,
      dueText: isDueToday
          ? 'Due ${DateFormat('h:mm a').format(item.dueAt)}'
          : DateFormat('EEE, MMM d').format(item.dueAt),
      dueColor: isDueToday ? AppColors.cFFE65757 : AppColors.cFFA48C7E,
      dueBg: isDueToday ? AppColors.cFFFFECEC : AppColors.cFFF7F2EE,
      showDuePill: isDueToday,
      showDueIcon: isDueToday,
      showLeadingCircle: false,
      showShadow: true,
    );

    if (item.highlightLeftAccent || isDueToday) {
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
              builder: (_) =>
                  AssignmentsDetailPage(item: item, withNavBar: false),
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
    final sectionsAsync = ref.watch(assignmentsFeedSectionsProvider);
    final filterSubjectsAsync = ref.watch(assignmentFilterSubjectsProvider);
    final selectedSubject = ref.watch(selectedAssignmentSubjectProvider);
    //ส่ง subjects จริงให้ Add form
    final subjectsAsync = ref.watch(subjectListProvider);
    final availableSubjectNames = subjectsAsync.maybeWhen(
      data: (rows) => rows.map((e) => e.name).toList(),
      orElse: () => const <String>[],
    );

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
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(24),
                      onTap: () => _showSubjectFilterSheet(
                        context,
                        ref,
                        filterSubjectsAsync,
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.cFFF7F2EE,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: AppColors.cFFE5DBCF),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.tune_rounded,
                              size: 20,
                              color: AppColors.cFF8B6758,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              selectedSubject ?? 'Subject',
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.cFF8B6758,
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: AppColors.cFF8B6758,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Stack(
                children: [
                  sectionsAsync.when(
                    loading: () => const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.cFFE0B35D,
                      ),
                    ),
                    error: (error, stackTrace) => Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          'Unable to load assignments.\n$error',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.cFF8B6758,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    data: (sections) {
                      final isEmpty =
                          sections.today.isEmpty &&
                          sections.thisWeek.isEmpty &&
                          sections.later.isEmpty;

                      if (isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32),
                            child: Text(
                              selectedSubject == null
                                  ? 'No assignments yet.'
                                  : 'No assignments for $selectedSubject.',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: AppColors.cFF8B6758,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        );
                      }

                      return SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(20, 18, 20, 110),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (sections.today.isNotEmpty) ...[
                              TimelineSectionHeader(
                                title: 'TODAY',
                                taskCount: sections.today.length,
                              ),
                              const SizedBox(height: 12),
                              ..._buildAssignmentCards(context, sections.today),
                              const SizedBox(height: 28),
                            ],
                            if (sections.thisWeek.isNotEmpty) ...[
                              TimelineSectionHeader(
                                title: 'THIS WEEK',
                                taskCount: sections.thisWeek.length,
                              ),
                              const SizedBox(height: 12),
                              ..._buildAssignmentCards(
                                context,
                                sections.thisWeek,
                              ),
                              const SizedBox(height: 28),
                            ],
                            if (sections.later.isNotEmpty) ...[
                              TimelineSectionHeader(
                                title: 'LATER',
                                taskCount: sections.later.length,
                              ),
                              const SizedBox(height: 12),
                              ..._buildAssignmentCards(context, sections.later),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
                  AddButton(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => AddAssignmentsPage(
                            withNavBar: false,
                            availableSubjects: availableSubjectNames,
                          ),
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

  bool _isToday(DateTime value) {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final tomorrowStart = todayStart.add(const Duration(days: 1));
    return !value.isBefore(todayStart) && value.isBefore(tomorrowStart);
  }

  _AssignmentTagColors _tagColorsFor(String subject) {
    const palettes = <_AssignmentTagColors>[
      _AssignmentTagColors(
        background: AppColors.cFFE7F0FF,
        foreground: AppColors.cFF2E7CF6,
      ),
      _AssignmentTagColors(
        background: AppColors.cFFFBF7F1,
        foreground: AppColors.cFFE0B66B,
      ),
      _AssignmentTagColors(
        background: AppColors.cFFDFF2EA,
        foreground: AppColors.cFF1C9E73,
      ),
      _AssignmentTagColors(
        background: AppColors.cFFF0E9FF,
        foreground: AppColors.cFF9A5CFF,
      ),
    ];

    final seed = subject.toLowerCase().trim().codeUnits.fold<int>(
      0,
      (sum, unit) => sum + unit,
    );
    return palettes[seed % palettes.length];
  }

  Future<void> _showSubjectFilterSheet(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<String>> filterSubjectsAsync,
  ) async {
    final subjects = filterSubjectsAsync.maybeWhen(
      data: (items) => items,
      orElse: () => const <String>[],
    );

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.cFFFFFDFC,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        final selectedSubject = ref.read(selectedAssignmentSubjectProvider);

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Filter by subject',
                  style: TextStyle(
                    color: AppColors.cFF8B6758,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 16),
                if (selectedSubject != null) ...[
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        ref
                                .read(
                                  selectedAssignmentSubjectProvider.notifier,
                                )
                                .state =
                            null;
                        Navigator.of(context).pop();
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.cFFE0B35D,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      child: const Text(
                        'Clear filter',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                _SubjectFilterTile(
                  label: 'All Subjects',
                  isSelected: selectedSubject == null,
                  onTap: () {
                    ref.read(selectedAssignmentSubjectProvider.notifier).state =
                        null;
                    Navigator.of(context).pop();
                  },
                ),
                if (subjects.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 12),
                    child: Text(
                      'No subjects available yet.',
                      style: TextStyle(
                        color: AppColors.cFFA48C7E,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )
                else
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: subjects.length,
                      separatorBuilder: (_, index) =>
                          const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final subject = subjects[index];
                        return _SubjectFilterTile(
                          label: subject,
                          isSelected: selectedSubject == subject,
                          onTap: () {
                            ref
                                    .read(
                                      selectedAssignmentSubjectProvider
                                          .notifier,
                                    )
                                    .state =
                                subject;
                            Navigator.of(context).pop();
                          },
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _AssignmentTagColors {
  const _AssignmentTagColors({
    required this.background,
    required this.foreground,
  });

  final Color background;
  final Color foreground;
}

class _SubjectFilterTile extends StatelessWidget {
  const _SubjectFilterTile({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.cFFF7F2EE : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? AppColors.cFFE0B35D : AppColors.cFFF0E6DE,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: AppColors.cFF8B6758,
                    fontSize: 16,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  ),
                ),
              ),
              if (isSelected)
                const Icon(
                  Icons.check_rounded,
                  color: AppColors.cFFE0B35D,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
