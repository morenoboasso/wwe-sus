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
    required this.seasonPoints,
    required this.correctPredictions,
    required this.seasonCorrectPredictions,
    required this.wrongPredictions,
    required this.seasonWrongPredictions,
    required this.streak,
    required this.seasonStreak,
    required this.accuracy,
    required this.seasonAccuracy,
    required this.role,
  });

  final String id;
  final String name;
  final String photo;
  final int points;
  final int seasonPoints;
  final int correctPredictions;
  final int seasonCorrectPredictions;
  final int wrongPredictions;
  final int seasonWrongPredictions;
  final int streak;
  final int seasonStreak;
  final double accuracy;
  final double seasonAccuracy;
  final AppUserRole role;

  factory AppUser.fromMap(String id, Map<String, dynamic> data) {
    return AppUser(
      id: id,
      name: data['name'] as String? ?? '',
      photo: data['photo'] as String? ?? '',
      points: (data['points'] as num?)?.toInt() ?? 0,
      seasonPoints: (data['seasonPoints'] as num?)?.toInt() ?? 0,
      correctPredictions: (data['correctPredictions'] as num?)?.toInt() ?? 0,
      seasonCorrectPredictions: (data['seasonCorrectPredictions'] as num?)?.toInt() ?? 0,
      wrongPredictions: (data['wrongPredictions'] as num?)?.toInt() ?? 0,
      seasonWrongPredictions: (data['seasonWrongPredictions'] as num?)?.toInt() ?? 0,
      streak: (data['streak'] as num?)?.toInt() ?? 0,
      seasonStreak: (data['seasonStreak'] as num?)?.toInt() ?? 0,
      accuracy: (data['accuracy'] as num?)?.toDouble() ?? 0,
      seasonAccuracy: (data['seasonAccuracy'] as num?)?.toDouble() ?? 0,
      role: AppUserRole.fromValue(data['role'] as String?),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'photo': photo,
      'points': points,
      'seasonPoints': seasonPoints,
      'correctPredictions': correctPredictions,
      'seasonCorrectPredictions': seasonCorrectPredictions,
      'wrongPredictions': wrongPredictions,
      'seasonWrongPredictions': seasonWrongPredictions,
      'streak': streak,
      'seasonStreak': seasonStreak,
      'accuracy': accuracy,
      'seasonAccuracy': seasonAccuracy,
      'role': role.value,
    };
  }

  AppUser copyWith({
    String? name,
    String? photo,
    int? points,
    int? seasonPoints,
    int? correctPredictions,
    int? seasonCorrectPredictions,
    int? wrongPredictions,
    int? seasonWrongPredictions,
    int? streak,
    int? seasonStreak,
    double? accuracy,
    double? seasonAccuracy,
    AppUserRole? role,
  }) {
    return AppUser(
      id: id,
      name: name ?? this.name,
      photo: photo ?? this.photo,
      points: points ?? this.points,
      seasonPoints: seasonPoints ?? this.seasonPoints,
      correctPredictions: correctPredictions ?? this.correctPredictions,
      seasonCorrectPredictions: seasonCorrectPredictions ?? this.seasonCorrectPredictions,
      wrongPredictions: wrongPredictions ?? this.wrongPredictions,
      seasonWrongPredictions: seasonWrongPredictions ?? this.seasonWrongPredictions,
      streak: streak ?? this.streak,
      seasonStreak: seasonStreak ?? this.seasonStreak,
      accuracy: accuracy ?? this.accuracy,
      seasonAccuracy: seasonAccuracy ?? this.seasonAccuracy,
      role: role ?? this.role,
    );
  }

  int get totalPredictions => correctPredictions + wrongPredictions;

  int get seasonTotalPredictions => seasonCorrectPredictions + seasonWrongPredictions;

  double get accuracyPercentage => accuracy.clamp(0, 100);

  double get seasonAccuracyPercentage => seasonAccuracy.clamp(0, 100);
}
