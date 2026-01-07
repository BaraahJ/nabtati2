class AppUser {
  final String uid;
  final String username; // ❗ ثابت
  final String name;     // ✅ قابل للتغيير
  final String email;
  final String provider;

  final String photoUrl;
  final String bio;

  final int points;
  final int level;

  AppUser({
    required this.uid,
    required this.username,
    required this.name,
    required this.email,
    required this.provider,
    required this.photoUrl,
    required this.bio,
    required this.points,
    required this.level,
  });

  factory AppUser.fromFirestore(Map<String, dynamic> data) {
    return AppUser(
      uid: data['uid'],
      username: data['username'] ?? '', // username ثابت
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      provider: data['provider'] ?? '',
      photoUrl: data['photoUrl'] ?? '',
      bio: data['bio'] ?? '',
      points: data['points'] ?? 0,
      level: data['level'] ?? 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'username': username, // مهم
      'name': name,
      'email': email,
      'provider': provider,
      'photoUrl': photoUrl,
      'bio': bio,
      'points': points,
      'level': level,
    };
  }
}
