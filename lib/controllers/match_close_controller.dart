import '../models/match_model.dart';
import '../repositories/match_repository.dart';

class MatchCloseController {
  MatchCloseController({MatchRepository? matchRepository})
      : _matchRepository = matchRepository ?? MatchRepository();

  final MatchRepository _matchRepository;

  Future<void> closeStandardMatch({
    required String matchId,
    required String result,
  }) {
    return _matchRepository.updateMatch(matchId, {
      'status': MatchStatus.closed.value,
      'result': result,
      'resultText': null,
    });
  }

  Future<void> closeFreeTextMatch({
    required String matchId,
    required String resultText,
  }) {
    return _matchRepository.updateMatch(matchId, {
      'status': MatchStatus.closed.value,
      'result': null,
      'resultText': resultText,
      'resultTexts': null,
    });
  }

  Future<void> closeFreeTextMatchWithResults({
    required String matchId,
    required List<String> resultTexts,
  }) {
    return _matchRepository.updateMatch(matchId, {
      'status': MatchStatus.closed.value,
      'result': null,
      'resultText': null,
      'resultTexts': resultTexts,
    });
  }
}
