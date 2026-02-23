enum AppUserRole {
  admin('admin'),
  user('user');

  const AppUserRole(this.value);

  final String value;

  static AppUserRole fromValue(String? value) {
    return AppUserRole.values.firstWhere(
      (role) => role.value == value,
      orElse: () => AppUserRole.user,
    );
  }
}

class AppUser {
  const AppUser({
    required this.id,
    required this.name,
    required this.photo,
    required this.points,
    required this.correctPredictions,
    required this.wrongPredictions,
    required this.streak,
    required this.accuracy,
    required this.role,
  });

  final String id;
  final String name;
  final String photo;
  final int points;
  final int correctPredictions;
  final int wrongPredictions;
  final int streak;
  final double accuracy;
  final AppUserRole role;

  factory AppUser.fromMap(String id, Map<String, dynamic> data) {
    return AppUser(
      id: id,
      name: data['name'] as String? ?? '',
      photo: data['photo'] as String? ?? '',
      points: (data['points'] as num?)?.toInt() ?? 0,
      correctPredictions: (data['correctPredictions'] as num?)?.toInt() ?? 0,
      wrongPredictions: (data['wrongPredictions'] as num?)?.toInt() ?? 0,
      streak: (data['streak'] as num?)?.toInt() ?? 0,
      accuracy: (data['accuracy'] as num?)?.toDouble() ?? 0,
      role: AppUserRole.fromValue(data['role'] as String?),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'photo': photo,
      'points': points,
      'correctPredictions': correctPredictions,
      'wrongPredictions': wrongPredictions,
      'streak': streak,
      'accuracy': accuracy,
      'role': role.value,
    };
  }

  AppUser copyWith({
    String? name,
    String? photo,
    int? points,
    int? correctPredictions,
    int? wrongPredictions,
    int? streak,
    double? accuracy,
    AppUserRole? role,
  }) {
    return AppUser(
      id: id,
      name: name ?? this.name,
      photo: photo ?? this.photo,
      points: points ?? this.points,
      correctPredictions: correctPredictions ?? this.correctPredictions,
      wrongPredictions: wrongPredictions ?? this.wrongPredictions,
      streak: streak ?? this.streak,
      accuracy: accuracy ?? this.accuracy,
      role: role ?? this.role,
    );
  }

  int get totalPredictions => correctPredictions + wrongPredictions;

  double get accuracyPercentage => accuracy.clamp(0, 100);
}
