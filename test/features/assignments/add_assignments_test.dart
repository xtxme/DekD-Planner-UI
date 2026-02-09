import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_first_app/features/assignments/add_assignments/add_assignments.dart';
import 'package:my_first_app/features/assignments/models/assignment_draft.dart';

void main() {
  Future<void> pumpPage(
    WidgetTester tester, {
    List<String>? subjects,
    Future<void> Function(AssignmentDraft draft)? onSave,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: AddAssignmentsPage(
            withNavBar: false,
            availableSubjects: subjects ?? const ['Mathematics', 'Physics'],
            onSave: onSave,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> selectSubject(WidgetTester tester, String subject) async {
    await tester.tap(find.text('Select Subject'));
    await tester.pumpAndSettle();
    await tester.tap(find.text(subject).last);
    await tester.pumpAndSettle();
  }

  Future<void> selectDate(WidgetTester tester) async {
    await tester.tap(find.text('Select Date'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
  }

  ElevatedButton saveButton(WidgetTester tester) {
    return tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, 'Save Assignment'),
    );
  }

  testWidgets('save button is disabled when title is empty', (tester) async {
    await pumpPage(tester);

    expect(saveButton(tester).onPressed, isNull);
  });

  testWidgets('save button becomes enabled when required fields are filled', (
    tester,
  ) async {
    await pumpPage(tester);

    await tester.enterText(
      find.byType(TextField).first,
      'Algebra Worksheet 4.2',
    );
    await tester.pump();

    await selectSubject(tester, 'Mathematics');
    await selectDate(tester);

    expect(saveButton(tester).onPressed, isNotNull);
  });

  testWidgets('default due time is 23:59 when no time is selected', (
    tester,
  ) async {
    AssignmentDraft? savedDraft;
    await pumpPage(
      tester,
      onSave: (draft) async {
        savedDraft = draft;
      },
    );

    await tester.enterText(find.byType(TextField).first, 'Chem Lab Report');
    await tester.pump();
    await selectSubject(tester, 'Mathematics');
    await selectDate(tester);

    await tester.tap(find.widgetWithText(ElevatedButton, 'Save Assignment'));
    await tester.pumpAndSettle();

    expect(savedDraft, isNotNull);
    expect(savedDraft!.dueDateTime.hour, 23);
    expect(savedDraft!.dueDateTime.minute, 59);
  });

  testWidgets('shows discard confirmation when back pressed with dirty form', (
    tester,
  ) async {
    await pumpPage(tester);

    await tester.enterText(find.byType(TextField).first, 'Draft title');
    await tester.pump();

    await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Discard changes?'), findsOneWidget);
    expect(
      find.text('You have unsaved changes. Are you sure you want to leave?'),
      findsOneWidget,
    );
  });

  testWidgets('shows error snackbar and re-enables save when callback fails', (
    tester,
  ) async {
    await pumpPage(
      tester,
      onSave: (_) async {
        throw Exception('save failed');
      },
    );

    await tester.enterText(find.byType(TextField).first, 'History Essay');
    await tester.pump();
    await selectSubject(tester, 'Mathematics');
    await selectDate(tester);

    await tester.tap(find.widgetWithText(ElevatedButton, 'Save Assignment'));
    await tester.pumpAndSettle();

    expect(
      find.text('Failed to save assignment. Please try again.'),
      findsOneWidget,
    );
    expect(saveButton(tester).onPressed, isNotNull);
  });

  testWidgets('uses externally provided subject list in bottom sheet', (
    tester,
  ) async {
    const customSubjects = ['Thai', 'Physics'];
    await pumpPage(tester, subjects: customSubjects);

    await tester.tap(find.text('Select Subject'));
    await tester.pumpAndSettle();

    expect(find.text('Thai'), findsOneWidget);
    expect(find.text('Physics'), findsOneWidget);
    expect(find.text('Mathematics'), findsNothing);
  });
}
