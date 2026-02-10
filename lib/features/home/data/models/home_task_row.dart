class HomeTask {
  const HomeTask({
    this.id,
    required this.subject,
    required this.title,
    required this.subtitle,
    required this.dueAt,
    required this.tagBg,
    required this.tagColor,
    required this.dueBg,
    required this.dueColor,
    required this.showDuePill,
  });

  final String? id;
  final String subject;
  final String title;
  final String subtitle;
  final DateTime dueAt;
  final int tagBg;
  final int tagColor;
  final int dueBg;
  final int dueColor;
  final bool showDuePill;

  Map<String, dynamic> toInsertMap({required String userId}) =>
      <String, dynamic>{
        'user_id': userId,
        'subject': subject,
        'title': title,
        'subtitle': subtitle,
        'due_at': dueAt.toUtc().toIso8601String(),
        'tag_bg': tagBg,
        'tag_color': tagColor,
        'due_bg': dueBg,
        'due_color': dueColor,
        'show_due_pill': showDuePill,
      };

  Map<String, dynamic> toUpdateMap() => <String, dynamic>{
        'subject': subject,
        'title': title,
        'subtitle': subtitle,
        'due_at': dueAt.toUtc().toIso8601String(),
        'tag_bg': tagBg,
        'tag_color': tagColor,
        'due_bg': dueBg,
        'due_color': dueColor,
        'show_due_pill': showDuePill,
      };

  factory HomeTask.fromMap(Map<String, dynamic> map) => HomeTask(
        id: map['id'] as String?,
        subject: map['subject'] as String? ?? '',
        title: map['title'] as String? ?? '',
        subtitle: map['subtitle'] as String? ?? '',
        dueAt: DateTime.parse(map['due_at'] as String).toLocal(),
        tagBg: map['tag_bg'] as int? ?? 0,
        tagColor: map['tag_color'] as int? ?? 0,
        dueBg: map['due_bg'] as int? ?? 0,
        dueColor: map['due_color'] as int? ?? 0,
        showDuePill: map['show_due_pill'] as bool? ?? false,
      );
}
