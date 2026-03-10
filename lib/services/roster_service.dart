import 'dart:convert';

import 'package:http/http.dart' as http;

class RosterService {
  static const String _apiKey = '123';
  static const String _baseUrl = 'https://www.thesportsdb.com/api/v1/json/$_apiKey';
  static const String _leagueUrl = 'https://www.thesportsdb.com/league/4444-wwe';

  Future<List<String>> fetchWweRoster() async {
    final teamIds = await _fetchTeamIdsFromLeaguePage();
    if (teamIds.isEmpty) return [];

    final names = <String>{};
    for (final teamId in teamIds) {
      final players = await _fetchPlayers(teamId);
      names.addAll(players);
    }

    final roster = names.toList()..sort();
    return roster;
  }

  Future<List<String>> _fetchTeamIdsFromLeaguePage() async {
    final url = Uri.parse(_leagueUrl);
    final response = await http.get(url).timeout(const Duration(seconds: 10));
    if (response.statusCode != 200) return [];

    final html = response.body;
    final matches = RegExp(r'/team/(\d+)').allMatches(html);
    final ids = <String>{};
    for (final match in matches) {
      final id = match.group(1);
      if (id != null && id.isNotEmpty) {
        ids.add(id);
      }
    }
    return ids.toList();
  }

  Future<List<String>> _fetchPlayers(String teamId) async {
    final url = Uri.parse('$_baseUrl/lookup_all_players.php?id=$teamId');
    final response = await http.get(url).timeout(const Duration(seconds: 10));
    if (response.statusCode != 200) return [];

    final data = json.decode(response.body);
    final players = data is Map<String, dynamic> ? data['player'] as List? : null;
    if (players == null) return [];

    return players
        .map((player) => (player as Map<String, dynamic>)['strPlayer']?.toString() ?? '')
        .map((name) => name.trim())
        .where((name) => name.isNotEmpty)
        .toList();
  }
}
