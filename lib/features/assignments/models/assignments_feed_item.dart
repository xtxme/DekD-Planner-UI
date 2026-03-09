enum AssignmentFeedSource { local, canvas }

class AssignmentsFeedItem {
  const AssignmentsFeedItem({
    required this.id,
    required this.source,
    required this.sourceId,
    required this.localAssignmentId,
    required this.subjectId,
    required this.subject,
    required this.title,
    required this.subtitle,
    required this.detailsText,
    this.detailsHtml,
    required this.dueAt,
    required this.status,
    required this.highlightLeftAccent,
  });

  final String id;
  final AssignmentFeedSource source;
  final String sourceId;
  final String? localAssignmentId;
  final String? subjectId;
  final String subject;
  final String title;
  final String subtitle;
  final String detailsText;
  final String? detailsHtml;
  final DateTime dueAt;
  final String status;
  final bool highlightLeftAccent;
}

class AssignmentsFeedSections {
  const AssignmentsFeedSections({
    required this.today,
    required this.thisWeek,
    required this.later,
  });

  final List<AssignmentsFeedItem> today;
  final List<AssignmentsFeedItem> thisWeek;
  final List<AssignmentsFeedItem> later;
}
