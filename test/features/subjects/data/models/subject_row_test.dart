import 'package:flutter_test/flutter_test.dart';
import 'package:my_first_app/features/subjects/data/models/subject_row.dart';

void main() {
  group('SubjectRow color persistence', () {
    test(
      'encodes opaque ARGB colors into signed 32-bit integers for Postgres',
      () {
        const row = SubjectRow(
          name: 'Imported subject',
          code: 'SUBJ101',
          description: 'Imported from Canvas',
          colorValue: 0xFFE2D4C7,
          iconCodepoint: 0xE86E,
          isArchived: false,
        );

        final insertMap = row.toInsertMap(userId: 'user-1');

        expect(insertMap['color_value'], -1911609);
      },
    );

    test('decodes signed 32-bit integers back into Flutter ARGB values', () {
      final row = SubjectRow.fromMap({
        'id': 'subject-1',
        'name': 'Imported subject',
        'code': 'SUBJ101',
        'description': 'Imported from Canvas',
        'color_value': -1911609,
        'icon_codepoint': 0xE86E,
        'is_archived': false,
      });

      expect(row.colorValue, 0xFFE2D4C7);
    });
  });
}
