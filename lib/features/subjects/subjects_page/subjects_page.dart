import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_first_app/features/subjects/data/models/canvas_course.dart';
import 'package:my_first_app/features/subjects/data/models/subject_row.dart';
import 'package:my_first_app/features/subjects/presentation/providers/subject_providers.dart';
import 'package:my_first_app/shared/theme/app_colors.dart';

import '../../../shared/widgets/add_button.dart';
import '../../../shared/widgets/navbar/app_navbar.dart';
import 'package:my_first_app/shared/providers/nav_provider.dart';
import '../add_subjects/add_subjects.dart';
import '../subjects_detail/subjects_detail.dart';
import 'widgets/header.dart';
import 'widgets/subjects_tab_switch.dart';

enum SubjectsTab { mySubjects, canvasCourses }

class SubjectsPage extends ConsumerStatefulWidget {
  const SubjectsPage({super.key, this.withNavBar = true});

  final bool withNavBar;

  @override
  ConsumerState<SubjectsPage> createState() => _SubjectsPageState();
}

class _SubjectsPageState extends ConsumerState<SubjectsPage> {
  String _query = '';
  SubjectsTab _activeTab = SubjectsTab.mySubjects;
  final Set<int> _importingCourseIds = <int>{};
  final Set<int> _dismissedCourseIds = <int>{};

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(currentNavIndexProvider);
    final subjectsAsync = ref.watch(subjectListProvider);
    final canvasCoursesAsync = ref.watch(canvasCoursesProvider);
    final importedNames =
        subjectsAsync.valueOrNull
            ?.map((subject) => subject.name.trim().toLowerCase())
            .toSet() ??
        <String>{};

    return Scaffold(
      backgroundColor: AppColors.cFFF7F3EF,
      body: SafeArea(
        child: Column(
          children: [
            SubjectsHeader(
              onQueryChanged: (value) {
                setState(() {
                  _query = value;
                });
              },
            ),
            Expanded(
              child: Stack(
                children: [
                  SingleChildScrollView(
                    physics: _scrollPhysics(context),
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 144),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTabToggle(),
                        const SizedBox(height: 24),
                        _buildActiveTabContent(
                          subjectsAsync: subjectsAsync,
                          canvasCoursesAsync: canvasCoursesAsync,
                          importedNames: importedNames,
                        ),
                      ],
                    ),
                  ),
                  if (_activeTab == SubjectsTab.mySubjects)
                    AddButton(
                      right: 24,
                      bottom: widget.withNavBar ? 28 : 20,
                      size: 60,
                      iconSize: 32,
                      shadowBlur: 18,
                      shadowOffset: const Offset(0, 8),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                const AddSubjectsPage(withNavBar: false),
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

  Widget _buildTabToggle() {
    return SubjectsTabSwitch(
      selectedIndex: _activeTab == SubjectsTab.mySubjects ? 0 : 1,
      onSelected: (index) {
        setState(() {
          _activeTab = index == 0
              ? SubjectsTab.mySubjects
              : SubjectsTab.canvasCourses;
        });
      },
    );
  }

  Widget _buildActiveTabContent({
    required AsyncValue<List<SubjectRow>> subjectsAsync,
    required AsyncValue<List<CanvasCourse>> canvasCoursesAsync,
    required Set<String> importedNames,
  }) {
    switch (_activeTab) {
      case SubjectsTab.mySubjects:
        return subjectsAsync.when(
          data: _buildMySubjectsTab,
          loading: () => const _SectionLoadingCard(),
          error: (error, _) =>
              _MessageCard(title: 'Could not load subjects', message: '$error'),
        );
      case SubjectsTab.canvasCourses:
        return canvasCoursesAsync.when(
          data: (courses) => _buildCanvasCoursesTab(
            courses: courses,
            importedNames: importedNames,
          ),
          loading: () =>
              _buildCanvasTabShell(child: const _SectionLoadingCard()),
          error: (error, _) => _buildCanvasTabShell(
            child: _MessageCard(
              title: 'Canvas sync failed',
              message: '$error',
              actionLabel: 'Retry',
              onAction: _syncCanvasCourses,
            ),
          ),
        );
    }
  }

  Widget _buildMySubjectsTab(List<SubjectRow> subjects) {
    final filteredSubjects = _filterSubjects(subjects);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          title: 'MY SUBJECTS',
          count: filteredSubjects.length,
        ),
        const SizedBox(height: 16),
        if (subjects.isEmpty)
          _MessageCard(
            title: 'No subjects yet',
            message:
                'Create your first subject to start tracking assignments and deadlines.',
            actionLabel: 'Add Subject',
            onAction: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const AddSubjectsPage(withNavBar: false),
              ),
            ),
            actionType: 'create',
          )
        else if (filteredSubjects.isEmpty)
          const _MessageCard(
            title: 'No results found',
            message:
                'Try adjusting your search or clearing filters to see all subjects.',
          )
        else
          Column(
            children: filteredSubjects
                .map(
                  (subject) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _SubjectListCard(
                      subject: subject,
                      subtitle: _subjectSubtitle(subject),
                      icon: _subjectIcon(subject),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                const SubjectsDetailPage(withNavBar: false),
                          ),
                        );
                      },
                    ),
                  ),
                )
                .toList(),
          ),
      ],
    );
  }

  Widget _buildCanvasCoursesTab({
    required List<CanvasCourse> courses,
    required Set<String> importedNames,
  }) {
    final searchedCourses = _filterCourses(courses);
    final visibleCourses = searchedCourses
        .where((course) => !_dismissedCourseIds.contains(course.id))
        .toList();

    Widget child;
    if (courses.isEmpty) {
      child = _MessageCard(
        title: 'No Canvas courses',
        message: 'Sync with Canvas to import your courses and assignments.',
        actionLabel: 'Sync Canvas',
        onAction: _syncCanvasCourses,
        actionType: 'import',
      );
    } else if (searchedCourses.isEmpty) {
      child = const _MessageCard(
        title: 'No Canvas courses to show',
        message:
            'Nothing matches the current search. Try another keyword or course code.',
      );
    } else if (visibleCourses.isEmpty) {
      child = const _MessageCard(
        title: 'Canvas list cleared for now',
        message:
            'You hid every visible Canvas course. Tap Sync Canvas to show dismissed courses again.',
      );
    } else {
      child = Column(
        children: visibleCourses
            .map(
              (course) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _CanvasCourseCard(
                  course: course,
                  isImported: importedNames.contains(
                    course.name.trim().toLowerCase(),
                  ),
                  isImporting: _importingCourseIds.contains(course.id),
                  onImport: () => _handleImportCourse(course),
                  onDismiss: () => _dismissCanvasCourse(course),
                ),
              ),
            )
            .toList(),
      );
    }

    return _buildCanvasTabShell(count: visibleCourses.length, child: child);
  }

  Widget _buildCanvasTabShell({int? count, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'CANVAS COURSES',
                style: TextStyle(
                  letterSpacing: 1.3,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: AppColors.cFF9A7E70,
                ),
              ),
            ),
            if (count != null) _CountPill(count: count),
            const SizedBox(width: 12),
            FilledButton.icon(
              onPressed: _syncCanvasCourses,
              icon: const Icon(Icons.sync_rounded, size: 18),
              label: const Text('Sync Canvas'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.cFFE0B35D,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          'Available from your Canvas account',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.cFFA48C7E,
          ),
        ),
        const SizedBox(height: 16),
        child,
      ],
    );
  }

  Future<void> _handleImportCourse(CanvasCourse course) async {
    if (_importingCourseIds.contains(course.id)) {
      return;
    }

    setState(() {
      _importingCourseIds.add(course.id);
    });

    try {
      final result = await ref
          .read(canvasCourseImporterProvider)
          .importCourse(course);
      if (!mounted) return;

      setState(() {
        _dismissedCourseIds.clear();
      });

      final message = result.status == CanvasImportStatus.imported
          ? 'Imported ${result.subjectName}'
          : '${result.subjectName} is already in your subjects';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Import failed: $error')));
    } finally {
      if (mounted) {
        setState(() {
          _importingCourseIds.remove(course.id);
        });
      }
    }
  }

  void _dismissCanvasCourse(CanvasCourse course) {
    if (_importingCourseIds.contains(course.id)) {
      return;
    }

    final subtitle = course.courseCode.trim();
    final courseLabel = subtitle.isEmpty
        ? course.name
        : '${course.name}\n$subtitle';

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.cFFFFFCF8,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          titlePadding: const EdgeInsets.fromLTRB(22, 22, 22, 0),
          contentPadding: const EdgeInsets.fromLTRB(22, 14, 22, 0),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          title: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.cFFF3ECE5,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.visibility_off_rounded,
                  color: AppColors.cFF8B6758,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Hide this course?',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: AppColors.cFF8B6758,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'You can remove this course from the current Canvas list for now. It will come back the next time you sync Canvas.',
                style: TextStyle(
                  fontSize: 15,
                  height: 1.45,
                  color: AppColors.cFFA48C7E,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.cFFFFFAF5,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.cFFE6DBD2),
                ),
                child: Text(
                  courseLabel,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.4,
                    fontWeight: FontWeight.w700,
                    color: AppColors.cFF8B6758,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.cFFA48C7E,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
              ),
              child: const Text(
                'Keep it',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                if (!mounted) return;
                setState(() {
                  _dismissedCourseIds.add(course.id);
                });

                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Hidden for now. Sync Canvas anytime to bring it back.',
                      ),
                    ),
                  );
              },
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.cFF8B6758,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              child: const Text(
                'Hide course',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ],
        );
      },
    );
  }

  void _syncCanvasCourses() {
    setState(() {
      _dismissedCourseIds.clear();
    });
    ref.invalidate(canvasCoursesProvider);
  }

  List<SubjectRow> _filterSubjects(List<SubjectRow> subjects) {
    final normalizedQuery = _normalizedQuery;
    if (normalizedQuery.isEmpty) {
      return subjects;
    }

    return subjects.where((subject) {
      return subject.name.toLowerCase().contains(normalizedQuery) ||
          subject.code.toLowerCase().contains(normalizedQuery);
    }).toList();
  }

  List<CanvasCourse> _filterCourses(List<CanvasCourse> courses) {
    final normalizedQuery = _normalizedQuery;
    if (normalizedQuery.isEmpty) {
      return courses;
    }

    return courses.where((course) {
      return course.name.toLowerCase().contains(normalizedQuery) ||
          course.courseCode.toLowerCase().contains(normalizedQuery);
    }).toList();
  }

  String get _normalizedQuery => _query.trim().toLowerCase();

  String _subjectSubtitle(SubjectRow subject) {
    final code = subject.code.trim();
    if (code.isNotEmpty) {
      return code;
    }

    final description = subject.description.trim();
    if (description.isNotEmpty) {
      return description;
    }

    return 'Ready to track assignments';
  }

  IconData _subjectIcon(SubjectRow subject) {
    final codePoint = subject.iconCodepoint;
    if (codePoint == 0) {
      return Icons.menu_book_rounded;
    }

    return IconData(codePoint, fontFamily: 'MaterialIcons');
  }

  Widget _buildSectionHeader({required String title, int? count}) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              letterSpacing: 1.3,
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: AppColors.cFF9A7E70,
            ),
          ),
        ),
        if (count != null) _CountPill(count: count),
      ],
    );
  }

  ScrollPhysics _scrollPhysics(BuildContext context) {
    final platform = Theme.of(context).platform;
    if (platform == TargetPlatform.iOS || platform == TargetPlatform.macOS) {
      return const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      );
    }

    return const ClampingScrollPhysics();
  }
}

class _CanvasCourseCard extends StatelessWidget {
  const _CanvasCourseCard({
    required this.course,
    required this.isImported,
    required this.isImporting,
    required this.onImport,
    required this.onDismiss,
  });

  final CanvasCourse course;
  final bool isImported;
  final bool isImporting;
  final VoidCallback onImport;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final code = course.courseCode.trim();
    final subtitle = code.isNotEmpty ? code : 'Canvas course';
    final canDismiss = !isImporting;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: AppColors.c1A000000,
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.surfaceSoft,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.school_rounded,
              color: AppColors.textPrimary,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  course.name,
                  softWrap: true,
                  style: const TextStyle(
                    fontSize: 18,
                    height: 1.2,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSoft,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      height: 1,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _ImportButton(
                      isImported: isImported,
                      isImporting: isImporting,
                      onPressed: onImport,
                    ),
                    if (canDismiss) ...[
                      const SizedBox(width: 8),
                      _DismissButton(enabled: true, onPressed: onDismiss),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SubjectListCard extends StatelessWidget {
  const _SubjectListCard({
    required this.subject,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final SubjectRow subject;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final badgeParts = _subjectBadgeParts(subtitle);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        splashColor: AppColors.accent.withValues(alpha: 0.1),
        highlightColor: AppColors.accent.withValues(alpha: 0.05),
        child: Ink(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
            boxShadow: const [
              BoxShadow(
                color: AppColors.c1A000000,
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSoft,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: AppColors.textPrimary, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        subject.name,
                        softWrap: true,
                        style: const TextStyle(
                          fontSize: 18,
                          height: 1.2,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (badgeParts.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        _SubjectMetaBadge(
                          label: badgeParts[0],
                          backgroundColor: AppColors.surfaceSoft,
                          borderColor: AppColors.border,
                          textColor: AppColors.textPrimary,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.iconMuted,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<String> _subjectBadgeParts(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return const <String>[];
    }

    final pattern = RegExp(r'^([A-Za-z0-9]+)\s*[-–]\s*([A-Za-z0-9.]+)$');
    final match = pattern.firstMatch(trimmed);
    if (match == null) {
      return <String>[trimmed];
    }

    final leading = match.group(1)?.trim() ?? '';
    final trailing = match.group(2)?.trim() ?? '';
    if (leading.isEmpty || trailing.isEmpty) {
      return <String>[trimmed];
    }

    return <String>[leading, trailing];
  }
}

class _SubjectMetaBadge extends StatelessWidget {
  const _SubjectMetaBadge({
    required this.label,
    required this.backgroundColor,
    required this.borderColor,
    required this.textColor,
  });

  final String label;
  final Color backgroundColor;
  final Color borderColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: borderColor),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 12,
          height: 1,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
          color: textColor,
        ),
      ),
    );
  }
}

class _MessageCard extends StatelessWidget {
  const _MessageCard({
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.actionType,
  });

  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final String? actionType;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: AppColors.c1A000000,
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.surfaceSoft,
              shape: BoxShape.circle,
            ),
            child: Icon(
              actionType == 'create'
                  ? Icons.add_circle_outline_rounded
                  : Icons.inbox_outlined,
              size: 32,
              color: AppColors.accent,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              height: 1.4,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onAction,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: Text(actionLabel!),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SectionLoadingCard extends StatelessWidget {
  const _SectionLoadingCard();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'LOADING',
                style: TextStyle(
                  letterSpacing: 1.3,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: AppColors.cFF9A7E70,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Column(
          children: List.generate(
            3,
            (index) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: const _SkeletonLoadingCard(),
            ),
          ),
        ),
      ],
    );
  }
}

class _SkeletonLoadingCard extends StatefulWidget {
  const _SkeletonLoadingCard();

  @override
  State<_SkeletonLoadingCard> createState() => _SkeletonLoadingCardState();
}

class _SkeletonLoadingCardState extends State<_SkeletonLoadingCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _animation = Tween<double>(
      begin: 0.3,
      end: 0.7,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final opacity = 0.3 + (_animation.value - 0.3) * 0.4;
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              _SkeletonBox(
                width: 48,
                height: 48,
                borderRadius: 14,
                opacity: opacity,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SkeletonBox(
                      width: double.infinity,
                      height: 18,
                      borderRadius: 4,
                      opacity: opacity,
                    ),
                    const SizedBox(height: 8),
                    _SkeletonBox(
                      width: 80,
                      height: 12,
                      borderRadius: 4,
                      opacity: opacity,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _SkeletonBox(
                width: 24,
                height: 24,
                borderRadius: 4,
                opacity: opacity,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SkeletonBox extends StatelessWidget {
  const _SkeletonBox({
    required this.width,
    required this.height,
    required this.borderRadius,
    required this.opacity,
  });

  final double width;
  final double height;
  final double borderRadius;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft.withValues(alpha: opacity),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

class _CountPill extends StatelessWidget {
  const _CountPill({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.cFFFFFAF5,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.cFFE6DBD2),
      ),
      child: Text(
        '$count',
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w900,
          color: AppColors.cFF8B6758,
        ),
      ),
    );
  }
}

class _DismissButton extends StatelessWidget {
  const _DismissButton({required this.enabled, required this.onPressed});

  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Hide this Canvas course',
      child: SizedBox(
        width: 40,
        height: 40,
        child: IconButton(
          onPressed: enabled ? onPressed : null,
          style: IconButton.styleFrom(
            backgroundColor: AppColors.surfaceSoft,
            disabledBackgroundColor: AppColors.surfaceSoft,
            foregroundColor: AppColors.iconMuted,
            disabledForegroundColor: AppColors.iconMuted.withValues(alpha: 0.5),
            side: const BorderSide(color: AppColors.border),
          ),
          icon: const Icon(Icons.close_rounded, size: 18),
        ),
      ),
    );
  }
}

class _ImportButton extends StatelessWidget {
  const _ImportButton({
    required this.isImported,
    required this.isImporting,
    required this.onPressed,
  });

  final bool isImported;
  final bool isImporting;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: isImported || isImporting ? null : onPressed,
      style: FilledButton.styleFrom(
        minimumSize: const Size(44, 40),
        backgroundColor: isImported ? AppColors.surfaceSoft : AppColors.accent,
        foregroundColor: isImported ? AppColors.textSecondary : Colors.white,
        disabledBackgroundColor: AppColors.surfaceSoft,
        disabledForegroundColor: AppColors.iconMuted,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
      ),
      child: isImporting
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : Text(isImported ? 'Imported' : 'Import'),
    );
  }
}
