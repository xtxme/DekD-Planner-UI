import 'package:flutter_test/flutter_test.dart';
import 'package:my_first_app/features/subjects/data/models/canvas_course.dart';

void main() {
  group('CanvasCourse.fromMap', () {
    test('extracts teacher from teachers[].display_name', () {
      final course = CanvasCourse.fromMap({
        'id': 12429,
        'name': 'Operating Systems',
        'course_code': 'CS301',
        'teachers': [
          {'display_name': 'Ajarn Nicha'},
        ],
      });

      expect(course.teacherName, 'Ajarn Nicha');
      expect(
        course.importDescription,
        'Imported from Canvas (course_id: 12429) | Instructor: Ajarn Nicha',
      );
    });

    test('extracts teacher from instructors[] when teachers[] is missing', () {
      final course = CanvasCourse.fromMap({
        'id': 2001,
        'name': 'Discrete Math',
        'instructors': [
          {'name': 'Assoc. Prof. Tana'},
        ],
      });

      expect(course.teacherName, 'Assoc. Prof. Tana');
    });

    test('extracts teacher from teacher object as fallback', () {
      final course = CanvasCourse.fromMap({
        'id': 2002,
        'name': 'Signals',
        'teacher': {'short_name': 'Dr. Bee'},
      });

      expect(course.teacherName, 'Dr. Bee');
    });
  });
}
