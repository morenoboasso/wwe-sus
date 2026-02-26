import '../models/match_list_item.dart';
import '../models/match_list_sections.dart';
import '../repositories/match_repository.dart';
import '../repositories/vote_repository.dart';

class MatchListController {
  MatchListController({
    MatchRepository? matchRepository,
    VoteRepository? voteRepository,
  })  : _matchRepository = matchRepository ?? MatchRepository(),
        _voteRepository = voteRepository ?? VoteRepository();

  final MatchRepository _matchRepository;
  final VoteRepository _voteRepository;

  Future<List<MatchListItem>> fetchMatchItems() async {
    final matches = await _matchRepository.fetchMatches();
    final items = <MatchListItem>[];
    for (final match in matches) {
      final vote = await _voteRepository.getCurrentUserVote(match.id);
      items.add(MatchListItem(match: match, userVote: vote));
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
}
