import '../models/match_model.dart';
import '../models/user_model.dart';
import '../models/vote_model.dart';
import '../repositories/user_repository.dart';
import 'points_service.dart';

class UserStatsService {
  UserStatsService({UserRepository? userRepository, PointsService? pointsService})
      : _userRepository = userRepository ?? UserRepository(),
        _pointsService = pointsService ?? PointsService();

  final UserRepository _userRepository;
  final PointsService _pointsService;

  Future<void> applyMatchResults({
    required Match match,
    required List<Vote> votes,
  }) async {
    for (final vote in votes) {
      final points = _pointsService.calculatePoints(match, vote);
      final isCorrect = _isVoteCorrect(match, vote);
      final currentUser = await _userRepository.getUserById(vote.userId);
      if (currentUser == null) {
        continue;
      }

      final updated = _computeUpdatedUser(currentUser, points, isCorrect);
      await _userRepository.upsertUser(updated);
    }
  }

  bool _isVoteCorrect(Match match, Vote vote) {
    if (vote.isStandard) {
      return vote.winnerId != null && vote.winnerId == match.result;
    }

    final results = match.resultTexts;
    if (results != null && results.contains(vote.winnerText)) {
      return true;
    }

    if (match.resultText != null && match.resultText == vote.winnerText) {
      return true;
    }

    return false;
  }

  AppUser _computeUpdatedUser(AppUser user, int points, bool isCorrect) {
    final newCorrect = user.correctPredictions + (isCorrect ? 1 : 0);
    final newWrong = user.wrongPredictions + (isCorrect ? 0 : 1);
    final newStreak = isCorrect ? user.streak + 1 : 0;
    final total = newCorrect + newWrong;
    final newAccuracy = total == 0 ? 0.0 : newCorrect / total;

    return user.copyWith(
      points: user.points + points,
      correctPredictions: newCorrect,
      wrongPredictions: newWrong,
      streak: newStreak,
      accuracy: newAccuracy,
    );
  }
}
