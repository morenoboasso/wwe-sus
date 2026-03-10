import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/match_model.dart';
import '../repositories/match_repository.dart';
import '../services/firebase/firebase_auth_service.dart';
import '../services/roster_service.dart';

class CreateMatchController {
  CreateMatchController({
    MatchRepository? matchRepository,
    FirebaseAuthService? authService,
    RosterService? rosterService,
  })  : _matchRepository = matchRepository ?? MatchRepository(),
        _authService = authService ?? FirebaseAuthService(),
        _rosterService = rosterService ?? RosterService();

  final MatchRepository _matchRepository;
  final FirebaseAuthService _authService;
  final RosterService _rosterService;
  List<String>? _rosterCache;

  bool canSubmit({
    required String type,
    required String ppvName,
    required PredictionType predictionType,
    required List<String> wrestlers,
  }) {
    if (type.trim().isEmpty) {
      return false;
    }
    if (ppvName.trim().isEmpty) {
      return false;
    }
    if (predictionType == PredictionType.standard &&
        normalizeWrestlers(wrestlers).length < 2) {
      return false;
    }
    return true;
  }

  List<String> normalizeWrestlers(List<String> wrestlers) {
    return wrestlers
        .map((wrestler) => (wrestler.trim()))
        .where((wrestler) => wrestler.isNotEmpty)
        .toList();
  }

  Future<List<String>> fetchRosterSuggestions() async {
    if (_rosterCache != null) return _rosterCache!;
    final roster = await _rosterService.fetchWweRoster();
    _rosterCache = roster;
    return roster;
  }

  Future<List<String>> fetchPpvSuggestions() async {
    final matches = await _matchRepository.fetchMatches();
    final counts = <String, int>{};
    final displayNames = <String, String>{};

    for (final match in matches) {
      final name = match.ppvName.trim();
      if (name.isEmpty) continue;
      final key = name.toLowerCase();
      counts[key] = (counts[key] ?? 0) + 1;
      displayNames.putIfAbsent(key, () => name);
    }

    final keys = counts.keys.toList()
      ..sort((a, b) {
        final countCompare = counts[b]!.compareTo(counts[a]!);
        if (countCompare != 0) return countCompare;
        return displayNames[a]!.compareTo(displayNames[b]!);
      });

    return keys.map((key) => displayNames[key]!).toList();
  }


  Future<void> createMatch({
    required String type,
    required String ppvName,
    required bool isTitleMatch,
    required bool isMainEvent,
    required PredictionType predictionType,
    required List<String> wrestlers,
  }) async {
    final userId = _authService.currentUser?.uid;
    if (userId == null) {
      throw StateError('Utente non autenticato');
    }

    final normalizedWrestlers = normalizeWrestlers(wrestlers);
    final matchData = <String, dynamic>{
      'type': type.trim().toUpperCase(),
      'ppvName': ppvName.trim().toUpperCase(),
      'isTitleMatch': isTitleMatch,
      'isMainEvent': isMainEvent,
      'predictionType': predictionType.value,
      'status': MatchStatus.open.value,
      'createdBy': userId,
      'createdAt': FieldValue.serverTimestamp(),
      'result': null,
      'resultText': null,
      'wrestlers': predictionType == PredictionType.standard
          ? normalizedWrestlers
          : <String>[],
    };

    await _matchRepository.createMatchWithData(matchData);
  }
}
