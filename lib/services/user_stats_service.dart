import '../models/match_model.dart';
import '../models/season_model.dart';
import '../models/user_model.dart';
import '../models/vote_model.dart';
import '../repositories/vote_repository.dart';
import '../repositories/user_repository.dart';
import '../repositories/season_repository.dart';
import 'points_service.dart';

class UserStatsService {
  UserStatsService({
    UserRepository? userRepository,
    VoteRepository? voteRepository,
    SeasonRepository? seasonRepository,
    PointsService? pointsService,
  })
      : _userRepository = userRepository ?? UserRepository(),
        _voteRepository = voteRepository ?? VoteRepository(),
        _seasonRepository = seasonRepository ?? SeasonRepository(),
        _pointsService = pointsService ?? PointsService();

  final UserRepository _userRepository;
  final VoteRepository _voteRepository;
  final SeasonRepository _seasonRepository;
  final PointsService _pointsService;

  Future<void> applyMatchResults({
    required Match match,
    required List<Vote> votes,
  }) async {
    Season? season;
    try {
      season = await _seasonRepository.fetchLatestOpenSeason();
    } catch (_) {
      season = null;
    }
    final now = DateTime.now();
    final isSeasonActive = season != null && _isSeasonActive(season, now);

    for (final vote in votes) {
      if (vote.scoredAt != null) {
        continue;
      }
      final points = _pointsService.calculatePoints(match, vote);
      final isCorrect = _isVoteCorrect(match, vote);
      final currentUser = await _userRepository.getUserById(vote.userId);
      if (currentUser == null) {
        continue;
      }

      final updated = _computeUpdatedUser(
        currentUser,
        points,
        isCorrect,
        applyToSeason: isSeasonActive,
      );
      await _userRepository.upsertUser(updated);

      await _voteRepository.markVoteScored(
        matchId: vote.matchId,
        userId: vote.userId,
        points: points,
        isCorrect: isCorrect,
      );
    }
  }

  bool _isSeasonActive(Season season, DateTime now) {
    if (season.isClosed) return false;
    final nowDate = _dateOnly(now);
    final startDate = _dateOnly(season.startAt);
    final endDate = _dateOnly(season.endAt);
    return !nowDate.isBefore(startDate) && !nowDate.isAfter(endDate);
  }

  DateTime _dateOnly(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }

  bool _isVoteCorrect(Match match, Vote vote) {
    if (vote.isStandard) {
      return vote.winnerId != null && vote.winnerId == match.result;
    }

    final voteText = vote.winnerText?.trim().toLowerCase();
    if (voteText == null || voteText.isEmpty) return false;

    final results = match.resultTexts?.map((e) => e.trim().toLowerCase()).where((e) => e.isNotEmpty).toList();
    if (results != null && results.contains(voteText)) {
      return true;
    }

    final singleResult = match.resultText?.trim().toLowerCase();
    if (singleResult != null && singleResult.isNotEmpty && singleResult == voteText) {
      return true;
    }

    return false;
  }

  AppUser _computeUpdatedUser(
    AppUser user,
    int points,
    bool isCorrect, {
    required bool applyToSeason,
  }) {
    final newCorrect = user.correctPredictions + (isCorrect ? 1 : 0);
    final newWrong = user.wrongPredictions + (isCorrect ? 0 : 1);
    final newStreak = isCorrect ? user.streak + 1 : 0;
    final total = newCorrect + newWrong;
    final newAccuracy = total == 0 ? 0.0 : newCorrect / total;

    final newSeasonCorrect = user.seasonCorrectPredictions + (applyToSeason ? (isCorrect ? 1 : 0) : 0);
    final newSeasonWrong = user.seasonWrongPredictions + (applyToSeason ? (isCorrect ? 0 : 1) : 0);
    final newSeasonStreak = applyToSeason ? (isCorrect ? user.seasonStreak + 1 : 0) : user.seasonStreak;
    final seasonTotal = newSeasonCorrect + newSeasonWrong;
    final newSeasonAccuracy = seasonTotal == 0 ? 0.0 : newSeasonCorrect / seasonTotal;

    return user.copyWith(
      // global
      points: user.points + points,
      correctPredictions: newCorrect,
      wrongPredictions: newWrong,
      streak: newStreak,
      accuracy: newAccuracy,
      // season
      seasonPoints: user.seasonPoints + (applyToSeason ? points : 0),
      seasonCorrectPredictions: newSeasonCorrect,
      seasonWrongPredictions: newSeasonWrong,
      seasonStreak: newSeasonStreak,
      seasonAccuracy: newSeasonAccuracy,
    );
  }
}
