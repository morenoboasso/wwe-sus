import 'match_model.dart';
import 'vote_model.dart';

class VoteStats {
  const VoteStats({
    required this.totalVotes,
    required this.wrestlerVotes,
  });

  final int totalVotes;
  final Map<String, int> wrestlerVotes;

  factory VoteStats.fromVotes({
    required List<Vote> votes,
    required PredictionType predictionType,
  }) {
    if (votes.isEmpty) {
      return const VoteStats(totalVotes: 0, wrestlerVotes: {});
    }

    if (predictionType == PredictionType.freeText) {
      return VoteStats(
        totalVotes: votes.length,
        wrestlerVotes: const {},
      );
    }

    final counts = <String, int>{};
    for (final vote in votes) {
      final winnerId = vote.winnerId;
      if (winnerId == null || winnerId.isEmpty) continue;
      counts[winnerId] = (counts[winnerId] ?? 0) + 1;
    }

    return VoteStats(
      totalVotes: votes.length,
      wrestlerVotes: counts,
    );
  }

  double percentageFor(String wrestlerId) {
    if (totalVotes == 0) return 0;
    final votes = wrestlerVotes[wrestlerId] ?? 0;
    return votes / totalVotes;
  }
}
