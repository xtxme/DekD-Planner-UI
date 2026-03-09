import 'package:my_first_app/features/assignments/data/models/assignment_row.dart';
import 'package:my_first_app/features/assignments/models/assignments_feed_item.dart';
import 'package:my_first_app/features/assignments/presentation/text/canvas_html_text_formatter.dart';
import 'package:my_first_app/features/home/data/models/canvas_assignment.dart';

class AssignmentsUiMapper {
  const AssignmentsUiMapper();

  AssignmentsFeedItem fromLocal(AssignmentRow row) {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final tomorrowStart = todayStart.add(const Duration(days: 1));

    final isToday =
        !row.dueAt.isBefore(todayStart) && row.dueAt.isBefore(tomorrowStart);
    final isOverdue = row.dueAt.isBefore(now) && row.status != 'completed';

    return AssignmentsFeedItem(
      id: row.id ?? 'local-${row.title}-${row.dueAt.toIso8601String()}',
      source: AssignmentFeedSource.local,
      sourceId: row.id ?? 'local-${row.title}-${row.dueAt.toIso8601String()}',
      localAssignmentId: row.id,
      subjectId: row.subjectId,
      subject: row.subject.trim().isNotEmpty ? row.subject.trim() : 'General',
      title: row.title.trim().isNotEmpty
          ? row.title.trim()
          : 'Untitled assignment',
      subtitle: '',
      detailsText: row.notes.trim(),
      detailsHtml: null,
      dueAt: row.dueAt,
      status: row.status,
      highlightLeftAccent: isToday || isOverdue,
    );
  }

  AssignmentsFeedItem? fromCanvas(CanvasAssignment assignment) {
    final dueAt = assignment.dueAt;
    if (dueAt == null) return null;

    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final tomorrowStart = todayStart.add(const Duration(days: 1));

    final isToday =
        !dueAt.isBefore(todayStart) && dueAt.isBefore(tomorrowStart);
    final isOverdue = dueAt.isBefore(now);
    final status = assignment.isCompleted
        ? 'completed'
        : isOverdue
        ? 'late'
        : 'in_progress';

    final subject = _resolveSubject(courseName: assignment.courseName);

    final detailsText = canvasHtmlToReadableMultilineText(
      assignment.description,
    );

    return AssignmentsFeedItem(
      id: 'canvas-${assignment.id}',
      source: AssignmentFeedSource.canvas,
      sourceId: assignment.id.toString(),
      localAssignmentId: null,
      subjectId: null,
      subject: subject,
      title: assignment.name.trim().isNotEmpty
          ? assignment.name.trim()
          : 'Untitled assignment',
      subtitle: '',
      detailsText: detailsText,
      detailsHtml: assignment.description,
      dueAt: dueAt,
      status: status,
      highlightLeftAccent: isToday || isOverdue,
    );
  }

  String _resolveSubject({required String courseName}) {
    final normalizedCourse = courseName.trim();
    if (normalizedCourse.isNotEmpty) {
      return normalizedCourse;
    }

    return 'Unknown Subject';
  }
}
