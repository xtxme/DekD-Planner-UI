class HomeTask {
  const HomeTask({
    required this.id,
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

  final int? id;
  final String subject;
  final String title;
  final String subtitle;
  final DateTime dueAt;
  final int tagBg;     // store Color as int
  final int tagColor;
  final int dueBg;
  final int dueColor;
  final bool showDuePill;

  Map<String, Object?> toMap() => { //แปลง Object → SQLite(ใส่ Database)
    'id': id,
    'subject': subject,
    'title': title,
    'subtitle': subtitle,
    'due_at': dueAt.microsecondsSinceEpoch,
    'tag_Bg': tagBg,
    'tag_color': tagColor,
    'due_bg': dueBg,
    'due_color': dueColor,
    'show_due_pill': showDuePill ? 1 : 0,
  };

  factory HomeTask.fromMap(Map<String, Object?> map) => HomeTask( //เอาข้อมูลจาก Database → สร้าง Object
    id: map['id'] as int?, 
    subject: map['subject'] as String, 
    title: map['title'] as String, 
    subtitle: map['subtitle'] as String,
    dueAt: DateTime.fromMicrosecondsSinceEpoch(map['due_at'] as int),
    tagBg: map['tag_bg'] as int,
    tagColor: map['tag_Color'] as int,
    dueBg: map['due_Bg'] as int,
    dueColor: map['due_color'] as int,
    showDuePill: (map['show_due_pill'] as int) == 1,
    );
}