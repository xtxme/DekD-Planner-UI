class SubjectRow {
  static const int _signedInt32Max = 0x7FFFFFFF;
  static const int _unsignedInt32Mask = 0xFFFFFFFF;
  static const int _unsignedInt32Range = 0x100000000;

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
    'color_value': _encodeColorValue(colorValue),
    'icon_codepoint': iconCodepoint,
    'is_archived': isArchived,
  };

  Map<String, dynamic> toUpdateMap() => {
    'name': name,
    'code': code,
    'description': description,
    'color_value': _encodeColorValue(colorValue),
    'icon_codepoint': iconCodepoint,
    'is_archived': isArchived,
  };

  factory SubjectRow.fromMap(Map<String, dynamic> map) => SubjectRow(
    id: map['id'] as String?,
    name: map['name'] as String? ?? '',
    code: map['code'] as String? ?? '',
    description: map['description'] as String? ?? '',
    colorValue: _decodeColorValue(map['color_value'] as int? ?? 0),
    iconCodepoint: map['icon_codepoint'] as int? ?? 0,
    isArchived: map['is_archived'] as bool? ?? false,
  );

  static int _encodeColorValue(int value) {
    final normalized = value & _unsignedInt32Mask;
    if (normalized > _signedInt32Max) {
      return normalized - _unsignedInt32Range;
    }
    return normalized;
  }

  static int _decodeColorValue(int value) => value & _unsignedInt32Mask;
}
