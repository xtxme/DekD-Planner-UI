import 'package:flutter/material.dart';

import '../edit_subjects/material_all_icons_pack.dart' as material_all_icons_pack;

final Map<int, IconData> _materialIconsByCodePoint = {
  for (final icon in material_all_icons_pack.allIcons.values)
    icon.data.codePoint: icon.data,
};

IconData resolveSubjectIconCodepoint(int iconCodepoint) {
  if (iconCodepoint == 0) {
    return Icons.menu_book_rounded;
  }

  return _materialIconsByCodePoint[iconCodepoint] ?? Icons.menu_book_rounded;
}
