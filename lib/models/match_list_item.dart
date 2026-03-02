import 'match_model.dart';
import 'vote_model.dart';
import 'vote_stats.dart';

class MatchListItem {
  const MatchListItem({
    required this.match,
    required this.userVote,
    required this.voteStats,
  });

  final Match match;
  final Vote? userVote;
  final VoteStats voteStats;

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
