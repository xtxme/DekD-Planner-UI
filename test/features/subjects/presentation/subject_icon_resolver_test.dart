import 'package:flutter/material.dart';
import 'package:my_first_app/features/subjects/presentation/subject_icon_resolver.dart';
import 'package:test/test.dart';

void main() {
  group('resolveSubjectIconCodepoint', () {
    test('uses default subject icon when codepoint is zero', () {
      final icon = resolveSubjectIconCodepoint(0);

      expect(icon, Icons.menu_book_rounded);
    });

    test('builds icon from stored codepoint for non-zero values', () {
      final icon = resolveSubjectIconCodepoint(Icons.science_rounded.codePoint);

      expect(icon.codePoint, Icons.science_rounded.codePoint);
      expect(icon.fontFamily, 'MaterialIcons');
    });
  });
}
