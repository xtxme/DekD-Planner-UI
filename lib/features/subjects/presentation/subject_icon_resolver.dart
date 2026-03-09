import 'package:flutter/material.dart';

IconData resolveSubjectIconCodepoint(int iconCodepoint) {
  if (iconCodepoint == 0) {
    return Icons.menu_book_rounded;
  }

  return IconData(iconCodepoint, fontFamily: 'MaterialIcons');
}
