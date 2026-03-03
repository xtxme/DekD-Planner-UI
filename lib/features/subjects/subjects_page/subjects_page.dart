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

class SubjectsPage extends ConsumerStatefulWidget {
  const SubjectsPage({super.key, this.withNavBar = true});

  final bool withNavBar;

  @override
  ConsumerState<SubjectsPage> createState() => _SubjectsPageState();
}

class _SubjectsPageState extends ConsumerState<SubjectsPage> {
  String _query = '';
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
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 144),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        subjectsAsync.when(
                          data: _buildSubjectsSection,
                          loading: () => const _SectionLoadingCard(
                            message: 'Loading your subjects...',
                          ),
                          error: (error, _) => _MessageCard(
                            title: 'Could not load subjects',
                            message: '$error',
                          ),
                        ),
                        const SizedBox(height: 32),
                        _buildCanvasSectionHeader(),
                        const SizedBox(height: 14),
                        canvasCoursesAsync.when(
                          data: (courses) => _buildCanvasCoursesSection(
                            courses: courses,
                            importedNames: importedNames,
                          ),
                          loading: () => const _SectionLoadingCard(
                            message: 'Syncing Canvas courses...',
                          ),
                          error: (error, _) => _MessageCard(
                            title: 'Canvas sync failed',
                            message: '$error',
                            actionLabel: 'Retry',
                            onAction: _syncCanvasCourses,
                          ),
                        ),
                      ],
                    ),
                  ),
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

  Widget _buildSubjectsSection(List<SubjectRow> subjects) {
    final filteredSubjects = _filterSubjects(subjects);
    final title = _normalizedQuery.isEmpty
        ? 'MY SUBJECTS'
        : 'MATCHING SUBJECTS';

    if (subjects.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(title: title, count: 0),
          const SizedBox(height: 14),
          const _MessageCard(
            title: 'No subjects yet',
            message:
                'Create one manually or pull in a course from Canvas below to start your collection.',
          ),
        ],
      );
    }

    if (filteredSubjects.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(title: title, count: 0),
          const SizedBox(height: 14),
          const _MessageCard(
            title: 'No subjects match your search',
            message:
                'Try a different subject name or course code to narrow the list.',
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(title: title, count: filteredSubjects.length),
        const SizedBox(height: 14),
        SizedBox(
          height: 186,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: _scrollPhysics(context),
            itemCount: filteredSubjects.length,
            separatorBuilder: (_, _) => const SizedBox(width: 14),
            itemBuilder: (context, index) {
              final subject = filteredSubjects[index];
              return _SubjectHighlightCard(
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
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCanvasSectionHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: _buildSectionHeader(title: 'CANVAS COURSES')),
            TextButton.icon(
              onPressed: _syncCanvasCourses,
              icon: const Icon(Icons.sync_rounded, size: 18),
              label: const Text('Sync Canvas'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.cFF7A5A4A,
                backgroundColor: AppColors.cFFFFFAF5,
                textStyle: const TextStyle(fontWeight: FontWeight.w800),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                  side: const BorderSide(color: AppColors.cFFE6DBD2),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        const Text(
          'Available from your Canvas account',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.cFFA48C7E,
          ),
        ),
      ],
    );
  }

  Widget _buildCanvasCoursesSection({
    required List<CanvasCourse> courses,
    required Set<String> importedNames,
  }) {
    final searchedCourses = _filterCourses(courses);
    final visibleCourses = searchedCourses
        .where((course) => !_dismissedCourseIds.contains(course.id))
        .toList();

    if (courses.isEmpty) {
      return const _MessageCard(
        title: 'No Canvas courses found',
        message: 'Try syncing again or check your Canvas connection settings.',
      );
    }

    if (searchedCourses.isEmpty) {
      return const _MessageCard(
        title: 'No Canvas courses to show',
        message:
            'Nothing matches the current search. Try another keyword or course code.',
      );
    }

    if (visibleCourses.isEmpty) {
      return const _MessageCard(
        title: 'Canvas list cleared for now',
        message:
            'You hid every visible Canvas course. Tap Sync Canvas to show dismissed courses again.',
      );
    }

    return Column(
      children: visibleCourses
          .map(
            (course) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
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
              Text(
                'You can remove this course from the current Canvas list for now. It will come back the next time you sync Canvas.',
                style: const TextStyle(
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
                    SnackBar(
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

    return LayoutBuilder(
      builder: (context, constraints) {
        final stackedActions = constraints.maxWidth >= 360;

        return Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.cFFFFFCF8,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.cFFE6DBD2),
            boxShadow: const [
              BoxShadow(
                color: AppColors.c1A000000,
                blurRadius: 22,
                offset: Offset(0, 12),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.cFFF3ECE5,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.school_rounded,
                  color: AppColors.cFF7A5A4A,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.name,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.25,
                        fontWeight: FontWeight.w900,
                        color: AppColors.cFF8B6758,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.4,
                        fontWeight: FontWeight.w600,
                        color: AppColors.cFFA48C7E,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              if (stackedActions)
                SizedBox(
                  width: 96,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _ImportButton(
                        isImported: isImported,
                        isImporting: isImporting,
                        onPressed: onImport,
                      ),
                      const SizedBox(height: 12),
                      _DismissButton(enabled: canDismiss, onPressed: onDismiss),
                    ],
                  ),
                )
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _ImportButton(
                      isImported: isImported,
                      isImporting: isImporting,
                      onPressed: onImport,
                    ),
                    const SizedBox(height: 18),
                    _DismissButton(enabled: canDismiss, onPressed: onDismiss),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }
}

class _SubjectHighlightCard extends StatelessWidget {
  const _SubjectHighlightCard({
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
    final subjectColor = Color(subject.colorValue);

    return SizedBox(
      width: 262,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: onTap,
          child: Ink(
            decoration: BoxDecoration(
              color: Color.alphaBlend(
                AppColors.cFFFFFCF8.withValues(alpha: 0.86),
                subjectColor,
              ),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: subjectColor.withValues(alpha: 0.26)),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.c1A000000,
                  blurRadius: 22,
                  offset: Offset(0, 12),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.cFFFFFAF5.withValues(
                                alpha: 0.78,
                              ),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: const Text(
                              'LOCAL SUBJECT',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11,
                                letterSpacing: 1.1,
                                fontWeight: FontWeight.w900,
                                color: AppColors.cFF9A8476,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.cFFFFFCF8.withValues(alpha: 0.84),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(icon, color: AppColors.cFF7A5A4A, size: 24),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    subject.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 24,
                      height: 1.08,
                      fontWeight: FontWeight.w900,
                      color: AppColors.cFF7A5A4A,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.35,
                      fontWeight: FontWeight.w700,
                      color: AppColors.cFF9A8476,
                    ),
                  ),
                ],
              ),
            ),
          ),
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
  });

  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cFFFFFCF8,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.cFFE6DBD2),
        boxShadow: const [
          BoxShadow(
            color: AppColors.c1A000000,
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: AppColors.cFF8B6758,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: const TextStyle(
              fontSize: 15,
              height: 1.4,
              color: AppColors.cFFA48C7E,
            ),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: onAction,
              icon: const Icon(Icons.sync_rounded, size: 18),
              label: Text(actionLabel!),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.cFF7A5A4A,
                backgroundColor: AppColors.cFFFFFAF5,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
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
  const _SectionLoadingCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cFFFFFCF8,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.cFFE6DBD2),
        boxShadow: const [
          BoxShadow(
            color: AppColors.c1A000000,
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2.4),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.cFFA48C7E,
              ),
            ),
          ),
        ],
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
        width: 44,
        height: 44,
        child: IconButton(
          onPressed: enabled ? onPressed : null,
          style: IconButton.styleFrom(
            backgroundColor: AppColors.cFFFFFAF5,
            disabledBackgroundColor: AppColors.cFFFFFAF5,
            foregroundColor: AppColors.cFF9A8476,
            disabledForegroundColor: AppColors.cFFB8A99A,
            side: const BorderSide(color: AppColors.cFFE6DBD2),
          ),
          icon: const Icon(Icons.close_rounded, size: 20),
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
        minimumSize: const Size(96, 44),
        backgroundColor: isImported ? AppColors.cFFD9CEC3 : AppColors.cFFE0B35D,
        foregroundColor: isImported ? AppColors.cFF876557 : Colors.white,
        disabledBackgroundColor: isImported
            ? AppColors.cFFD9CEC3
            : AppColors.cFFE2D8CF,
        disabledForegroundColor: isImported
            ? AppColors.cFF876557
            : AppColors.cFFB7A79D,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      ),
      child: isImporting
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2.2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : Text(isImported ? 'Imported' : 'Import'),
    );
  }
}
