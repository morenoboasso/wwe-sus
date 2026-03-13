import '../models/match_model.dart';
import '../repositories/match_repository.dart';
import '../repositories/vote_repository.dart';
import '../services/user_stats_service.dart';

class MatchCloseController {
  MatchCloseController({
    MatchRepository? matchRepository,
    VoteRepository? voteRepository,
    UserStatsService? userStatsService,
  })  : _matchRepository = matchRepository ?? MatchRepository(),
        _voteRepository = voteRepository ?? VoteRepository(),
        _userStatsService = userStatsService ?? UserStatsService();

  final MatchRepository _matchRepository;
  final VoteRepository _voteRepository;
  final UserStatsService _userStatsService;

  Future<void> closeStandardMatch({
    required String matchId,
    required String result,
  }) {
    return _closeAndScore(
      matchId: matchId,
      updateData: {
        'status': MatchStatus.closed.value,
        'result': result,
        'resultText': null,
      },
    );
  }

  Future<void> closeFreeTextMatch({
    required String matchId,
    required String resultText,
  }) {
    return _closeAndScore(
      matchId: matchId,
      updateData: {
        'status': MatchStatus.closed.value,
        'result': null,
        'resultText': resultText,
        'resultTexts': null,
      },
    );
  }

  Future<void> closeFreeTextMatchWithResults({
    required String matchId,
    required List<String> resultTexts,
  }) {
    return _closeAndScore(
      matchId: matchId,
      updateData: {
        'status': MatchStatus.closed.value,
        'result': null,
        'resultText': null,
        'resultTexts': resultTexts,
      },
    );
  }

  Future<void> _closeAndScore({
    required String matchId,
    required Map<String, dynamic> updateData,
  }) async {
    final existingMatch = await _matchRepository.fetchMatch(matchId);
    if (existingMatch == null) return;

    final matchForScoring = existingMatch.copyWith(
      status: MatchStatus.closed,
      result: updateData['result'] as String?,
      resultText: updateData['resultText'] as String?,
      resultTexts: (updateData['resultTexts'] as List?)?.whereType<String>().toList(),
    );

    final votes = await _voteRepository.fetchMatchVotes(matchId);
    if (votes.isNotEmpty) {
      await _userStatsService.applyMatchResults(match: matchForScoring, votes: votes);
    }

    await _matchRepository.updateMatch(matchId, updateData);
  }
}
