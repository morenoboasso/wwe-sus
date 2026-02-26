import 'match_list_item.dart';

class MatchListSections {
  const MatchListSections({
    required this.nonVotati,
    required this.votatiNonConclusi,
    required this.completati,
  });

  final List<MatchListItem> nonVotati;
  final List<MatchListItem> votatiNonConclusi;
  final List<MatchListItem> completati;
}
