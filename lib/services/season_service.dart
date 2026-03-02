import '../models/season_model.dart';
import '../models/user_model.dart';
import '../repositories/match_repository.dart';
import '../repositories/season_repository.dart';
import '../repositories/user_repository.dart';
import '../repositories/vote_repository.dart';

class SeasonService {
  SeasonService({
    UserRepository? userRepository,
    SeasonRepository? seasonRepository,
    MatchRepository? matchRepository,
    VoteRepository? voteRepository,
  })  : _userRepository = userRepository ?? UserRepository(),
        _seasonRepository = seasonRepository ?? SeasonRepository(),
        _matchRepository = matchRepository ?? MatchRepository(),
        _voteRepository = voteRepository ?? VoteRepository();

  final UserRepository _userRepository;
  final SeasonRepository _seasonRepository;
  final MatchRepository _matchRepository;
  final VoteRepository _voteRepository;

  Future<Season> closeSeason(Season season) async {
    final users = await _userRepository.fetchAllUsers(orderBy: 'seasonPoints', descending: true);
    final winners = users.take(3).map(winnerFromUser).toList();

    final closedSeason = season.copyWith(
      isClosed: true,
      winners: winners,
    );
    await _seasonRepository.closeSeason(closedSeason);

    await _resetUsersSeasonStats(users);
    await _deleteAllVotes();

    return closedSeason;
  }

  Future<void> _resetUsersSeasonStats(List<AppUser> users) async {
    for (final user in users) {
      final reset = user.copyWith(
        seasonPoints: 0,
        seasonCorrectPredictions: 0,
        seasonWrongPredictions: 0,
        seasonStreak: 0,
        seasonAccuracy: 0,
      );
      await _userRepository.upsertUser(reset);
    }
  }

  Future<void> _deleteAllVotes() async {
    final matches = await _matchRepository.fetchMatches();
    for (final match in matches) {
      await _voteRepository.deleteVotesForMatch(match.id);
    }
  }
}
