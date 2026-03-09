import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_first_app/features/assignments/presentation/text/canvas_html_text_formatter.dart';
import 'package:my_first_app/features/home/data/models/canvas_assignment.dart';
import 'package:my_first_app/shared/theme/app_colors.dart';

class HomeAssignmentCardData {
  const HomeAssignmentCardData({
    required this.subject,
    required this.title,
    required this.subtitle,
    required this.tagBg,
    required this.tagColor,
    required this.dueText,
    required this.dueBg,
    required this.dueColor,
    required this.showDuePill,
    required this.showShadow,
  });

  final String subject;
  final String title;
  final String subtitle;
  final Color tagBg;
  final Color tagColor;
  final String dueText;
  final Color dueBg;
  final Color dueColor;
  final bool showDuePill;
  final bool showShadow;
}

class HomeAssignmentUiMapper {
  const HomeAssignmentUiMapper();

  HomeAssignmentCardData mapAssignment(
    CanvasAssignment assignment, {
    required bool isDueToday,
  }) {
    final subject = _resolveSubject(courseName: assignment.courseName);

    final title = assignment.name.trim().isNotEmpty
        ? assignment.name.trim()
        : 'Untitled assignment';

    final subtitle = _buildSubtitle(
      description: assignment.description,
      fallback: subject,
    );

    final tagColors = _buildTagColors(subject);
    final dueText = _formatDueText(assignment.dueAt);

    final dueBg = isDueToday ? AppColors.cFFFFE7E7 : AppColors.cFFF0E6DE;

    final dueColor = isDueToday ? AppColors.cFFE05A5A : AppColors.cFFA48C7E;

    return HomeAssignmentCardData(
      subject: subject,
      title: title,
      subtitle: subtitle,
      tagBg: tagColors.background,
      tagColor: tagColors.foreground,
      dueText: dueText,
      dueBg: dueBg,
      dueColor: dueColor,
      showDuePill: isDueToday,
      showShadow: isDueToday,
    );
  }

  String _resolveSubject({required String courseName}) {
    final normalizedCourse = courseName.trim();
    if (normalizedCourse.isNotEmpty) {
      return normalizedCourse;
    }

    return 'Unknown Subject';
  }

  String _buildSubtitle({
    required String description,
    required String fallback,
  }) {
    final cleaned = canvasHtmlToReadableMultilineTextWithBoldMarkers(
      description,
    ).trim();
    if (cleaned.isNotEmpty) {
      return cleaned;
    }
    return fallback;
  }

  String _formatDueText(DateTime? dueAt) {
    if (dueAt == null) {
      return 'No due date';
    }
    return 'Due ${DateFormat('h:mm a').format(dueAt)}';
  }

  _TagColors _buildTagColors(String subject) {
    final palettes = <_TagColors>[
      const _TagColors(
        background: AppColors.cFFE7F0FF,
        foreground: AppColors.cFF2E7CF6,
      ),
      const _TagColors(
        background: AppColors.cFFFBF7F1,
        foreground: AppColors.cFFE0B66B,
      ),
      const _TagColors(
        background: AppColors.c335FAF97,
        foreground: AppColors.cFF5FAF97,
      ),
    ];

    final seed = subject.toLowerCase().trim().codeUnits.fold<int>(
      0,
      (sum, unit) => sum + unit,
    );

    return palettes[seed % palettes.length];
  }
}

class _TagColors {
  const _TagColors({required this.background, required this.foreground});

  final Color background;
  final Color foreground;
}
