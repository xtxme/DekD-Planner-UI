import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_first_app/features/subjects/data/models/canvas_course.dart';
import 'package:my_first_app/features/subjects/data/models/subject_row.dart';
import 'package:my_first_app/features/subjects/presentation/providers/subject_providers.dart';
import 'package:my_first_app/features/subjects/subjects_page/subjects_page.dart';

void main() {
  Future<void> pumpSubjectsPage(
    WidgetTester tester, {
    required Override subjectOverride,
    required Override canvasOverride,
    Override? importerOverride,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          subjectOverride,
          canvasOverride,
          if (importerOverride != null) importerOverride,
        ],
        child: const MaterialApp(home: SubjectsPage(withNavBar: false)),
      ),
    );
    await tester.pumpAndSettle();
  }

  CanvasCourse buildCourse({
    required int id,
    required String name,
    required String code,
  }) {
    return CanvasCourse(
      id: id,
      name: name,
      courseCode: code,
      sisCourseId: '',
      teacherName: '',
    );
  }

  SubjectRow buildSubject({
    required String id,
    required String name,
    required String code,
  }) {
    return SubjectRow(
      id: id,
      name: name,
      code: code,
      description: 'Local subject',
      colorValue: 0xFFE2D4C7,
      iconCodepoint: 0xe80c,
      isArchived: false,
    );
  }

  testWidgets('shows imported state for Canvas course already in subjects', (
    tester,
  ) async {
    await pumpSubjectsPage(
      tester,
      subjectOverride: subjectListProvider.overrideWith(
        (ref) async => [
          buildSubject(id: 'subject-1', name: 'Intro to AI', code: 'CS101'),
        ],
      ),
      canvasOverride: canvasCoursesProvider.overrideWith(
        (ref) async => [
          buildCourse(id: 42, name: 'Intro to AI', code: 'CS101'),
          buildCourse(id: 43, name: 'Discrete Math', code: 'MTH120'),
        ],
      ),
    );

    expect(find.text('MY SUBJECTS'), findsOneWidget);
    expect(find.text('CANVAS COURSES'), findsOneWidget);
    expect(find.text('Intro to AI'), findsNWidgets(2));
    expect(find.text('Discrete Math'), findsOneWidget);
    expect(find.text('Imported'), findsOneWidget);
    expect(find.text('Import'), findsOneWidget);
  });

  testWidgets('dismiss removes a Canvas course from the visible list', (
    tester,
  ) async {
    await pumpSubjectsPage(
      tester,
      subjectOverride: subjectListProvider.overrideWith(
        (ref) async => const [],
      ),
      canvasOverride: canvasCoursesProvider.overrideWith(
        (ref) async => [
          buildCourse(id: 1, name: 'Operating Systems', code: 'OS201'),
          buildCourse(id: 2, name: 'Computer Networks', code: 'NW202'),
        ],
      ),
    );

    expect(find.text('Operating Systems'), findsOneWidget);
    expect(find.text('Computer Networks'), findsOneWidget);

    final dismissButton = find.byIcon(Icons.close_rounded).first;
    await tester.ensureVisible(dismissButton);
    await tester.tap(dismissButton);
    await tester.pumpAndSettle();
    expect(find.text('Hide this course?'), findsOneWidget);
    await tester.tap(find.text('Hide course'));
    await tester.pumpAndSettle();

    expect(find.text('Operating Systems'), findsNothing);
    expect(find.text('Computer Networks'), findsOneWidget);
    expect(
      find.text('Hidden for now. Sync Canvas anytime to bring it back.'),
      findsOneWidget,
    );
  });

  testWidgets('sync restores dismissed Canvas courses', (tester) async {
    await pumpSubjectsPage(
      tester,
      subjectOverride: subjectListProvider.overrideWith(
        (ref) async => const [],
      ),
      canvasOverride: canvasCoursesProvider.overrideWith(
        (ref) async => [
          buildCourse(id: 1, name: 'Operating Systems', code: 'OS201'),
          buildCourse(id: 2, name: 'Computer Networks', code: 'NW202'),
        ],
      ),
    );

    final dismissButton = find.byIcon(Icons.close_rounded).first;
    await tester.ensureVisible(dismissButton);
    await tester.tap(dismissButton);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Hide course'));
    await tester.pumpAndSettle();
    expect(find.text('Operating Systems'), findsNothing);

    final syncButton = find.text('Sync Canvas');
    await tester.ensureVisible(syncButton);
    await tester.tap(syncButton);
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('Operating Systems'), findsOneWidget);
    expect(find.text('Computer Networks'), findsOneWidget);
  });

  testWidgets('import still works after redesign', (tester) async {
    final importedCourseIds = <int>[];

    await pumpSubjectsPage(
      tester,
      subjectOverride: subjectListProvider.overrideWith(
        (ref) async => const [],
      ),
      canvasOverride: canvasCoursesProvider.overrideWith(
        (ref) async => [
          buildCourse(id: 8, name: 'Data Structures', code: 'CS220'),
        ],
      ),
      importerOverride: canvasCourseImporterProvider.overrideWith(
        (ref) => _FakeCanvasCourseImporter(
          ref,
          onImport: (course) async {
            importedCourseIds.add(course.id);
            return const CanvasImportResult(
              status: CanvasImportStatus.imported,
              subjectName: 'Data Structures',
            );
          },
        ),
      ),
    );

    final importButton = find.widgetWithText(FilledButton, 'Import');
    await tester.ensureVisible(importButton);
    await tester.tap(importButton);
    await tester.pump();
    await tester.pumpAndSettle();

    expect(importedCourseIds, [8]);
    expect(find.text('Imported Data Structures'), findsOneWidget);
  });

  testWidgets('search filters both local subjects and Canvas courses', (
    tester,
  ) async {
    await pumpSubjectsPage(
      tester,
      subjectOverride: subjectListProvider.overrideWith(
        (ref) async => [
          buildSubject(
            id: 'subject-1',
            name: 'Discrete Mathematics',
            code: 'MTH120',
          ),
          buildSubject(
            id: 'subject-2',
            name: 'Operating Systems',
            code: 'CS301',
          ),
        ],
      ),
      canvasOverride: canvasCoursesProvider.overrideWith(
        (ref) async => [
          buildCourse(id: 1, name: 'Discrete Math Lab', code: 'MTH120L'),
          buildCourse(id: 2, name: 'Signals', code: 'EE210'),
        ],
      ),
    );

    await tester.enterText(find.byType(TextField), 'Discrete');
    await tester.pumpAndSettle();

    expect(find.text('Discrete Mathematics'), findsOneWidget);
    expect(find.text('Operating Systems'), findsNothing);
    expect(find.text('Discrete Math Lab'), findsOneWidget);
    expect(find.text('Signals'), findsNothing);
  });

  testWidgets(
    'shows informational empty state when all Canvas cards are dismissed',
    (tester) async {
      await pumpSubjectsPage(
        tester,
        subjectOverride: subjectListProvider.overrideWith(
          (ref) async => const [],
        ),
        canvasOverride: canvasCoursesProvider.overrideWith(
          (ref) async => [
            buildCourse(id: 1, name: 'Operating Systems', code: 'OS201'),
          ],
        ),
      );

      final dismissButton = find.byIcon(Icons.close_rounded);
      await tester.ensureVisible(dismissButton);
      await tester.tap(dismissButton);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Hide course'));
      await tester.pumpAndSettle();

      expect(find.text('Canvas list cleared for now'), findsOneWidget);
      expect(
        find.textContaining('Sync Canvas to show dismissed courses again'),
        findsOneWidget,
      );
    },
  );

  testWidgets('shows Canvas error state and retry action', (tester) async {
    await pumpSubjectsPage(
      tester,
      subjectOverride: subjectListProvider.overrideWith(
        (ref) async => const [],
      ),
      canvasOverride: canvasCoursesProvider.overrideWith(
        (ref) => Future<List<CanvasCourse>>.error(Exception('boom')),
      ),
    );

    expect(find.text('Canvas sync failed'), findsOneWidget);
    expect(find.textContaining('Exception: boom'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });
}

class _FakeCanvasCourseImporter extends CanvasCourseImporter {
  _FakeCanvasCourseImporter(super.ref, {required this.onImport});

  final Future<CanvasImportResult> Function(CanvasCourse course) onImport;

  @override
  Future<CanvasImportResult> importCourse(CanvasCourse course) {
    return onImport(course);
  }
}
