import '../models/user_model.dart';

class ProfileGenerator {
  /// Build a single AppUser with defaults for stats and avatar.
  static AppUser build({
    required String id,
    required String name,
    String? photoUrl,
    int points = 0,
    int correctPredictions = 0,
    int wrongPredictions = 0,
    int streak = 0,
    double accuracy = 0.0,
    AppUserRole role = AppUserRole.user,
  }) {
    return AppUser(
      id: id,
      name: name,
      photo: photoUrl ?? _avatarFromName(name),
      points: points,
      correctPredictions: correctPredictions,
      wrongPredictions: wrongPredictions,
      streak: streak,
      accuracy: accuracy,
      role: role,
    );
  }

  /// Generate users from a list of names. IDs are slugified from the name by default.
  static List<AppUser> fromNames(
    List<String> names, {
    String Function(String name)? idBuilder,
  }) {
    return names.map((name) {
      final trimmed = name.trim();
      final id = idBuilder?.call(trimmed) ?? _slugify(trimmed);
      return build(id: id, name: trimmed);
    }).toList();
  }

  /// Convert a list of users to a map ready for Firestore batch write.
  static Map<String, Map<String, dynamic>> toFirestoreBatch(List<AppUser> users) {
    return {for (final user in users) user.id: user.toMap()};
  }

  static String _slugify(String value) {
    final lower = value.toLowerCase().trim();
    final normalized = lower.replaceAll(RegExp(r'[^a-z0-9]+'), '_');
    return normalized.replaceAll(RegExp(r'_+'), '_').replaceAll(RegExp(r'^_|_$'), '');
  }

  static String _avatarFromName(String name) {
    final encoded = Uri.encodeComponent(name);
    return 'https://ui-avatars.com/api/?name=$encoded&background=0D8ABC&color=fff';
  }
}
