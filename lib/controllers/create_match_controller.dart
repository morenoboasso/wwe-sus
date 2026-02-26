import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/match_model.dart';
import '../repositories/match_repository.dart';
import '../services/firebase/firebase_auth_service.dart';

class CreateMatchController {
  CreateMatchController({
    MatchRepository? matchRepository,
    FirebaseAuthService? authService,
  })  : _matchRepository = matchRepository ?? MatchRepository(),
        _authService = authService ?? FirebaseAuthService();

  final MatchRepository _matchRepository;
  final FirebaseAuthService _authService;

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
