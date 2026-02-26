import 'match_model.dart';
import 'vote_model.dart';

class MatchListItem {
  const MatchListItem({
    required this.match,
    required this.userVote,
  });

  final Match match;
  final Vote? userVote;

  bool get isCompleted => match.status == MatchStatus.closed;

  bool get hasVoted => userVote != null;

  String? get userSelection => userVote?.winnerId ?? userVote?.winnerText;

  String? get matchResult {
    if (match.resultTexts != null && match.resultTexts!.isNotEmpty) {
      return match.resultTexts!.join(', ');
    }
    return match.result ?? match.resultText;
  }

  List<String> get selectableWrestlers => [...match.wrestlers, 'Nessun Vincitore'];
}
