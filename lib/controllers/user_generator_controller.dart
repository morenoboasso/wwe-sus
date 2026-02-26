import '../repositories/user_repository.dart';
import '../tools/profile_generator.dart';

class UserGeneratorResult {
  const UserGeneratorResult({required this.createdCount});
  final int createdCount;
}

class UserGeneratorController {
  UserGeneratorController({UserRepository? userRepository})
      : _userRepository = userRepository ?? UserRepository();

  final UserRepository _userRepository;

  Future<UserGeneratorResult> createUsersFromRawNames(String rawNames) async {
    final names = _splitNames(rawNames);
    if (names.isEmpty) {
      return const UserGeneratorResult(createdCount: 0);
    }

    final users = ProfileGenerator.fromNames(names);
    for (final user in users) {
      await _userRepository.upsertUser(user);
    }

    return UserGeneratorResult(createdCount: users.length);
  }

  List<String> _splitNames(String input) {
    return input
        .split(RegExp(r'[\n,]'))
        .map((name) => name.trim())
        .where((name) => name.isNotEmpty)
        .toList();
  }
}
