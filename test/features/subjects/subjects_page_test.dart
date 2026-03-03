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
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [subjectOverride, canvasOverride],
        child: const MaterialApp(home: SubjectsPage(withNavBar: false)),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('shows imported state for Canvas course already in subjects', (
    tester,
  ) async {
    await pumpSubjectsPage(
      tester,
      subjectOverride: subjectListProvider.overrideWith(
        (ref) async => const [
          SubjectRow(
            id: 'subject-1',
            name: 'Intro to AI',
            code: 'CS101',
            description: 'Local subject',
            colorValue: 0xFFE2D4C7,
            iconCodepoint: 0xe80c,
            isArchived: false,
          ),
        ],
      ),
      canvasOverride: canvasCoursesProvider.overrideWith(
        (ref) async => const [
          CanvasCourse(
            id: 42,
            name: 'Intro to AI',
            courseCode: 'CS101',
            sisCourseId: '',
          ),
          CanvasCourse(
            id: 43,
            name: 'Discrete Math',
            courseCode: 'MTH120',
            sisCourseId: '',
          ),
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
