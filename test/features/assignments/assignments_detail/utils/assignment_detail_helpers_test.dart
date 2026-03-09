import 'package:flutter_test/flutter_test.dart';
import 'package:my_first_app/features/assignments/assignments_detail/utils/assignment_detail_helpers.dart';

void main() {
  group('calculateTimeRemaining', () {
    test('returns "X days left" when due date is in future', () {
      final now = DateTime(2026, 3, 9, 10, 0);
      final dueDate = DateTime(2026, 3, 12, 10, 0);

      final result = calculateTimeRemaining(dueDate, now);

      expect(result, '3 days left');
    });

    test('returns "X hours left" when less than 24 hours remaining', () {
      final now = DateTime(2026, 3, 9, 10, 0);
      final dueDate = DateTime(2026, 3, 10, 2, 0);

      final result = calculateTimeRemaining(dueDate, now);

      expect(result, '16 hours left');
    });

    test('returns "Overdue by X days" when past due date', () {
      final now = DateTime(2026, 3, 12, 10, 0);
      final dueDate = DateTime(2026, 3, 9, 10, 0);

      final result = calculateTimeRemaining(dueDate, now);

      expect(result, 'Overdue by 3 days');
    });
  });

  group('calculatePriority', () {
    test('returns "High" when overdue', () {
      final now = DateTime(2026, 3, 12, 10, 0);
      final dueDate = DateTime(2026, 3, 9, 10, 0);

      final result = calculatePriority(dueDate, 'to_do', now);

      expect(result, 'High');
    });

    test('returns "High" when due within 2 days', () {
      final now = DateTime(2026, 3, 9, 10, 0);
      final dueDate = DateTime(2026, 3, 10, 10, 0);

      final result = calculatePriority(dueDate, 'to_do', now);

      expect(result, 'High');
    });

    test('returns "Medium" when due within 7 days', () {
      final now = DateTime(2026, 3, 9, 10, 0);
      final dueDate = DateTime(2026, 3, 14, 10, 0);

      final result = calculatePriority(dueDate, 'to_do', now);

      expect(result, 'Medium');
    });

    test('returns "Low" when due after 7 days', () {
      final now = DateTime(2026, 3, 9, 10, 0);
      final dueDate = DateTime(2026, 3, 20, 10, 0);

      final result = calculatePriority(dueDate, 'to_do', now);

      expect(result, 'Low');
    });

    test('returns "Low" when status is completed', () {
      final now = DateTime(2026, 3, 9, 10, 0);
      final dueDate = DateTime(2026, 3, 10, 10, 0);

      final result = calculatePriority(dueDate, 'completed', now);

      expect(result, 'Low');
    });
  });

  group('calculateProgress', () {
    test('returns 0 for to_do status', () {
      expect(calculateProgress('to_do'), 0);
    });

    test('returns 50 for in_progress status', () {
      expect(calculateProgress('in_progress'), 50);
    });

    test('returns 100 for completed status', () {
      expect(calculateProgress('completed'), 100);
    });

    test('returns 0 for unknown status', () {
      expect(calculateProgress('unknown'), 0);
    });
  });

  group('shouldCollapseNotes', () {
    test('returns false for notes under 200 characters', () {
      expect(shouldCollapseNotes('Short notes'), false);
    });

    test('returns true for notes over 200 characters', () {
      final longNotes = 'a' * 201;
      expect(shouldCollapseNotes(longNotes), true);
    });

    test('returns false for empty notes', () {
      expect(shouldCollapseNotes(''), false);
    });
  });
}
