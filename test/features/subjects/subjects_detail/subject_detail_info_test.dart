import 'package:flutter_test/flutter_test.dart';
import 'package:my_first_app/features/subjects/data/models/canvas_course.dart';
import 'package:my_first_app/features/subjects/data/models/subject_row.dart';
import 'package:my_first_app/features/subjects/subjects_detail/subject_detail_info.dart';

void main() {
  group('resolveSubjectDetailInfo', () {
    const importedRow = SubjectRow(
      id: 'subject-1',
      name: 'Operating Systems',
      code: 'CS301',
      description:
          'Imported from Canvas (course_id: 12429) | Instructor: Ajarn Nicha',
      colorValue: 0xFFE2D4C7,
      iconCodepoint: 0,
      isArchived: false,
    );

    test(
      'shows instructor and hides import description when instructor exists',
      () {
        final info = resolveSubjectDetailInfo(
          subject: importedRow,
          canvasCourses: const [],
        );

        expect(info.teacherInfo, 'Instructor: Ajarn Nicha');
        expect(info.description, '');
      },
    );

    test('prefers latest instructor from canvas course by course_id', () {
      const canvasCourses = [
        CanvasCourse(
          id: 12429,
          name: 'Operating Systems',
          courseCode: 'CS301',
          sisCourseId: '',
          teacherName: 'Assoc. Prof. Tana',
        ),
      ];

      final info = resolveSubjectDetailInfo(
        subject: importedRow,
        canvasCourses: canvasCourses,
      );

      expect(info.teacherInfo, 'Instructor: Assoc. Prof. Tana');
      expect(info.description, '');
    });

    test('keeps import description when instructor cannot be resolved', () {
      const row = SubjectRow(
        id: 'subject-2',
        name: 'Math',
        code: 'MATH101',
        description: 'Imported from Canvas (course_id: 9999)',
        colorValue: 0xFFE2D4C7,
        iconCodepoint: 0,
        isArchived: false,
      );

      final info = resolveSubjectDetailInfo(
        subject: row,
        canvasCourses: const [],
      );

      expect(info.teacherInfo, '');
      expect(info.description, 'Imported from Canvas (course_id: 9999)');
    });
  });
}
