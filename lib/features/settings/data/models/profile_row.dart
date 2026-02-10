class ProfileRow {
  const ProfileRow({
    required this.userId,
    this.displayName,
    required this.bio,
    this.avatarUrl,
  });

  final String userId;
  final String? displayName;
  final String? bio;
  final String? avatarUrl;

  Map<String, dynamic> toUpsertMap() => {
    'user_id': userId,
    'display_name': displayName,
    'bio': bio,
    'avatar_url': avatarUrl,
  };

  factory ProfileRow.fromMap(Map<String, dynamic> map) => ProfileRow(
    userId: map['user_id'] as String, 
    displayName: map['display_name'] as String? ?? '',
    bio: map['bio'] as String? ?? '',
    avatarUrl: map['avatar_url'] as String?,
  );
}
