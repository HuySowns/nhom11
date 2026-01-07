class AppUser {
  final String uid;
  final String name;
  final String email;
  final String? avatarUrl;
  final String role; // 'user' or 'admin'

  AppUser({
    required this.uid,
    required this.name,
    required this.email,
    this.avatarUrl,
    this.role = 'user',
  });

  factory AppUser.fromMap(Map<String, dynamic> data) {
    return AppUser(
      uid: data['uid'] as String,
      name: data['name'] as String,
      email: data['email'] as String,
      avatarUrl: data['avatarUrl'] as String?,
      role: (data['role'] as String?) ?? 'user',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'avatarUrl': avatarUrl,
      'role': role,
    };
  }

  AppUser copyWith({
    String? uid,
    String? name,
    String? email,
    String? avatarUrl,
    String? role,
  }) {
    return AppUser(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
    );
  }
}