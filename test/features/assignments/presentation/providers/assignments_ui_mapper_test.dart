import 'package:my_first_app/features/assignments/presentation/providers/assignments_ui_mapper.dart';
import 'package:my_first_app/features/home/data/models/canvas_assignment.dart';
import 'package:test/test.dart';

void main() {
  group('AssignmentsUiMapper.fromCanvas', () {
    test('keeps line breaks from html and decodes common entities', () {
      const mapper = AssignmentsUiMapper();
      final assignment = CanvasAssignment(
        id: 12,
        name: 'Static Security Scan',
        dueAt: DateTime(2026, 3, 9, 23, 59),
        courseId: 777,
        courseName: 'Software Engineering',
        description:
            '<p>Line 1<br>Line&nbsp;2 &amp; Line 3</p>'
            '<p>Instructions:</p>'
            '<ul><li>Scan code</li><li>Build image</li></ul>',
      );

      final item = mapper.fromCanvas(assignment);

      expect(item, isNotNull);
      expect(
        item!.detailsText,
        'Line 1\n'
        'Line 2 & Line 3\n'
        '\n'
        'Instructions:\n'
        '\n'
        '• Scan code\n'
        '• Build image',
      );
      expect(item.detailsHtml, assignment.description);
    });

    test('renders ordered list as numbered lines', () {
      const mapper = AssignmentsUiMapper();
      final assignment = CanvasAssignment(
        id: 13,
        name: 'Release Checklist',
        dueAt: DateTime(2026, 3, 10, 12),
        courseId: 888,
        courseName: 'DevOps',
        description:
            '<p>Before release:</p>'
            '<ol start="2"><li>Run tests</li><li>Build image</li></ol>',
      );

      final item = mapper.fromCanvas(assignment);

      expect(item, isNotNull);
      expect(
        item!.detailsText,
        'Before release:\n'
        '\n'
        '2. Run tests\n'
        '3. Build image',
      );
    });

    test('maps overdue canvas assignment to late status', () {
      const mapper = AssignmentsUiMapper();
      final assignment = CanvasAssignment(
        id: 14,
        name: 'Bug Bash',
        dueAt: DateTime.now().subtract(const Duration(minutes: 5)),
        courseId: 999,
        courseName: 'QA',
        description: '',
      );

      final item = mapper.fromCanvas(assignment);

      expect(item, isNotNull);
      expect(item!.status, 'late');
    });

    test('maps upcoming canvas assignment to in_progress status', () {
      const mapper = AssignmentsUiMapper();
      final assignment = CanvasAssignment(
        id: 15,
        name: 'Sprint Plan',
        dueAt: DateTime.now().add(const Duration(minutes: 5)),
        courseId: 1000,
        courseName: 'Agile',
        description: '',
      );

      final item = mapper.fromCanvas(assignment);

      expect(item, isNotNull);
      expect(item!.status, 'in_progress');
    });

    test('maps completed canvas assignment to completed status', () {
      const mapper = AssignmentsUiMapper();
      final assignment = CanvasAssignment(
        id: 16,
        name: 'Final Report',
        dueAt: DateTime.now().add(const Duration(days: 1)),
        courseId: 1001,
        courseName: 'Project',
        description: '',
        isCompleted: true,
        submissionState: 'submitted',
      );

      final item = mapper.fromCanvas(assignment);

      expect(item, isNotNull);
      expect(item!.status, 'completed');
    });
  });
}
