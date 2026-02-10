class SubjectRow {
  const SubjectRow({
    this.id,
    required this.name,
    required this.code,
    required this.description,
    required this.colorValue,
    required this.iconCodepoint,
    required this.isArchived,
  });

  final String? id;
  final String name;
  final String code;
  final String description;
  final int colorValue;
  final int iconCodepoint;
  final bool isArchived;

  Map<String, dynamic> toInsertMap({required String userId}) => {
    'user_id': userId,
    'name': name,
    'code': code,
    'description': description,
    'color_value': colorValue,
    'icon_codepoint': iconCodepoint,
    'is_archived': isArchived,
  };

  Map<String, dynamic> toUpdateMap() => {
    'name': name,
    'code': code,
    'description': description,
    'color_value': colorValue,
    'icon_codepoint': iconCodepoint,
    'is_archived': isArchived,
  };

  factory SubjectRow.fromMap(Map<String, dynamic> map) => SubjectRow(
    id: map['id'] as String?, 
    name: map['name'] as String? ?? '', 
    code: map['code'] as String? ?? '', 
    description: map['description'] as String? ?? '',
    colorValue: map['color_value'] as int? ?? 0, 
    iconCodepoint: map['icon_codepoint'] as int? ?? 0,
    isArchived: map['is_archived'] as bool? ?? false,
    );
}
