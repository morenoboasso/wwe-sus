import '../models/match_list_item.dart';
import '../models/match_list_sections.dart';
import '../models/match_model.dart';
import '../models/vote_stats.dart';
import '../models/vote_model.dart';
import '../repositories/match_repository.dart';
import '../repositories/user_repository.dart';
import '../repositories/vote_repository.dart';
import '../repositories/season_repository.dart';

class MatchListController {
  MatchListController({
    MatchRepository? matchRepository,
    UserRepository? userRepository,
    VoteRepository? voteRepository,
    SeasonRepository? seasonRepository,
  })  : _matchRepository = matchRepository ?? MatchRepository(),
        _userRepository = userRepository ?? UserRepository(),
        _voteRepository = voteRepository ?? VoteRepository(),
        _seasonRepository = seasonRepository ?? SeasonRepository();

  final MatchRepository _matchRepository;
  final UserRepository _userRepository;
  final VoteRepository _voteRepository;
  final SeasonRepository _seasonRepository;

  Future<List<MatchListItem>> fetchMatchItems() async {
    final matches = await _matchRepository.fetchMatches();
    final items = <MatchListItem>[];
    for (final match in matches) {
      final vote = await _voteRepository.getCurrentUserVote(match.id);
      final votes = await _voteRepository.fetchMatchVotes(match.id);
      final voteStats = VoteStats.fromVotes(
        votes: votes,
        predictionType: match.predictionType,
      );
      items.add(
        MatchListItem(
          match: match,
          userVote: vote,
          voteStats: voteStats,
        ),
      );
    }
    return items;
  }

  MatchListSections splitSections(List<MatchListItem> items) {
    final nonVotati = <MatchListItem>[];
    final votatiNonConclusi = <MatchListItem>[];
    final completati = <MatchListItem>[];

    for (final item in items) {
      if (item.isCompleted) {
        completati.add(item);
      } else if (item.hasVoted) {
        votatiNonConclusi.add(item);
      } else {
        nonVotati.add(item);
      }
    }

    return MatchListSections(
      nonVotati: nonVotati,
      votatiNonConclusi: votatiNonConclusi,
      completati: completati,
    );
  }

  Future<void> finalizePpv(String ppvName) async {
    final season = await _seasonRepository.fetchLatestOpenSeason();
    final now = DateTime.now();
    final isSeasonActive = season != null &&
        !season.isClosed &&
        !now.isBefore(season.startAt) &&
        !now.isAfter(season.endAt);

    final normalizedPpv = _normalize(ppvName);
    final matches = await _matchRepository.fetchMatches();
    final ppvMatches = matches
        .where((match) => _normalize(match.ppvName) == normalizedPpv)
        .toList();

    if (ppvMatches.isEmpty) return;

    final allClosed = ppvMatches.every((match) => match.status == MatchStatus.closed);
    if (!allClosed) return;

    final votesByMatch = <String, List<Vote>>{};
    final userIds = <String>{};

    for (final match in ppvMatches) {
      final votes = await _voteRepository.fetchMatchVotes(match.id);
      votesByMatch[match.id] = votes;
      userIds.addAll(votes.map((v) => v.userId));
    }

    for (final userId in userIds) {
      final isAllCorrect = ppvMatches.every((match) {
        final vote = votesByMatch[match.id]?.firstWhere(
          (v) => v.userId == userId,
          orElse: () => Vote.empty(userId: userId, matchId: match.id),
        );
        if (vote == null || vote.isEmpty) return false;
        return _isVoteCorrect(match, vote);
      });

      final isAllWrong = ppvMatches.every((match) {
        final vote = votesByMatch[match.id]?.firstWhere(
          (v) => v.userId == userId,
          orElse: () => Vote.empty(userId: userId, matchId: match.id),
        );
        if (vote == null || vote.isEmpty) return false;
        return !_isVoteCorrect(match, vote);
      });

      if (!isAllCorrect && !isAllWrong) continue;

      final bonus = isAllCorrect ? 8 : -8;
      final user = await _userRepository.getUserById(userId);
      if (user == null) continue;

      final updated = user.copyWith(
        points: user.points + bonus,
        seasonPoints: user.seasonPoints + (isSeasonActive ? bonus : 0),
      );
      await _userRepository.upsertUser(updated);
    }

    for (final match in ppvMatches) {
      await _matchRepository.deleteMatch(match.id);
    }
  }

  String _normalize(String value) => value.trim().toLowerCase();

  bool _isVoteCorrect(Match match, Vote vote) {
    if (vote.isStandard) {
      return vote.winnerId != null && _normalize(vote.winnerId!) == _normalize(match.result ?? '');
    }

    final results = match.resultTexts;
    if (results != null && results.map(_normalize).contains(_normalize(vote.winnerText ?? ''))) {
      return true;
    }

    final singleResult = match.resultText;
    if (singleResult != null && _normalize(singleResult) == _normalize(vote.winnerText ?? '')) {
      return true;
    }

    return false;
  }
}
