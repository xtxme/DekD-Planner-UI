import 'package:my_first_app/features/home/data/models/canvas_assignment.dart';
import 'package:test/test.dart';

void main() {
  group('CanvasAssignment.fromMap', () {
    test('parses explicit completion signal', () {
      final assignment = CanvasAssignment.fromMap({
        'id': 101,
        'name': 'Lab 1',
        'due_at': '2026-03-09T10:00:00Z',
        'course_id': 88,
        'course_name': 'Physics',
        'description': 'Submit lab report',
        'is_completed': true,
      });

      expect(assignment.isCompleted, isTrue);
      expect(assignment.submissionState, isEmpty);
    });

    test('infers completion from submission state', () {
      final assignment = CanvasAssignment.fromMap({
        'id': 102,
        'name': 'Lab 2',
        'due_at': '2026-03-10T10:00:00Z',
        'course_id': 89,
        'course_name': 'Chemistry',
        'description': 'Submit worksheet',
        'submission_state': 'submitted',
      });

      expect(assignment.isCompleted, isTrue);
      expect(assignment.submissionState, 'submitted');
    });
  });
}
