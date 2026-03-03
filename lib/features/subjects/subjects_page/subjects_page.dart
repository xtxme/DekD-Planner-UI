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
import 'widgets/grid.dart';
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
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionLabel('MY SUBJECTS'),
                        const SizedBox(height: 12),
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
                        const SizedBox(height: 28),
                        _buildCanvasSectionHeader(),
                        const SizedBox(height: 12),
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
                            onAction: () =>
                                ref.invalidate(canvasCoursesProvider),
                          ),
                        ),
                      ],
                    ),
                  ),
                  AddButton(
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
    if (filteredSubjects.isEmpty) {
      return const _MessageCard(
        title: 'No subjects yet',
        message: 'Add a subject manually or import one from Canvas below.',
      );
    }

    final items = filteredSubjects
        .map(
          (subject) => SubjectGridItem(
            title: subject.name,
            subtitle: _subjectSubtitle(subject),
            icon: _subjectIcon(subject),
          ),
        )
        .toList();

    return SubjectsGrid(
      items: items,
      onItemTap: (_) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const SubjectsDetailPage(withNavBar: false),
          ),
        );
      },
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
    );
  }

  Widget _buildCanvasSectionHeader() {
    return Row(
      children: [
        Expanded(child: _buildSectionLabel('CANVAS COURSES')),
        TextButton.icon(
          onPressed: () => ref.invalidate(canvasCoursesProvider),
          icon: const Icon(Icons.sync_rounded, size: 18),
          label: const Text('Sync Canvas'),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.cFF7A5A4A,
            textStyle: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
      ],
    );
  }

  Widget _buildCanvasCoursesSection({
    required List<CanvasCourse> courses,
    required Set<String> importedNames,
  }) {
    final filteredCourses = _filterCourses(courses);
    if (filteredCourses.isEmpty) {
      return const _MessageCard(
        title: 'No Canvas courses found',
        message: 'Try syncing again or check your Canvas connection settings.',
      );
    }

    return Column(
      children: filteredCourses
          .map(
            (course) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _CanvasCourseCard(
                course: course,
                isImported: importedNames.contains(
                  course.name.trim().toLowerCase(),
                ),
                isImporting: _importingCourseIds.contains(course.id),
                onImport: () => _handleImportCourse(course),
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

  Widget _buildSectionLabel(String title) {
    return Text(
      title,
      style: const TextStyle(
        letterSpacing: 1.3,
        fontSize: 15,
        fontWeight: FontWeight.w900,
        color: AppColors.cFF9A7E70,
      ),
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
  });

  final CanvasCourse course;
  final bool isImported;
  final bool isImporting;
  final VoidCallback onImport;

  @override
  Widget build(BuildContext context) {
    final code = course.courseCode.trim();
    final subtitle = code.isNotEmpty ? code : 'Canvas course';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cFFE6DBD2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.cFFF3ECE5,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.school_rounded,
              color: AppColors.cFF7A5A4A,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  course.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: AppColors.cFF8B6758,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.cFFA48C7E,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          FilledButton(
            onPressed: isImported || isImporting ? null : onImport,
            style: FilledButton.styleFrom(
              backgroundColor: isImported
                  ? AppColors.cFFD9CEC3
                  : AppColors.cFFE0B35D,
              foregroundColor: isImported ? AppColors.cFF876557 : Colors.white,
              disabledBackgroundColor: isImported
                  ? AppColors.cFFD9CEC3
                  : AppColors.cFFE2D8CF,
              disabledForegroundColor: isImported
                  ? AppColors.cFF876557
                  : AppColors.cFFB7A79D,
            ),
            child: Text(
              isImported
                  ? 'Imported'
                  : (isImporting ? 'Importing...' : 'Import'),
            ),
          ),
        ],
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
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cFFE6DBD2),
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
            const SizedBox(height: 12),
            TextButton(onPressed: onAction, child: Text(actionLabel!)),
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
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cFFE6DBD2),
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
