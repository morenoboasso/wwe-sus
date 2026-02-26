import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/match_model.dart';
import '../models/vote_model.dart';
import '../repositories/vote_repository.dart';

class VoteController {
  VoteController({VoteRepository? voteRepository})
      : _voteRepository = voteRepository ?? VoteRepository();

  final VoteRepository _voteRepository;

  Future<void> submitStandardVote({
    required String matchId,
    required String winnerId,
  }) async {
    await _voteRepository.submitVoteData(matchId, {
      'type': PredictionType.standard.value,
      'winnerId': winnerId,
      'winnerText': null,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<void> submitFreeTextVote({
    required String matchId,
    required String winnerText,
  }) async {
    await _voteRepository.submitVoteData(matchId, {
      'type': PredictionType.freeText.value,
      'winnerId': null,
      'winnerText': winnerText.trim(),
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<List<Vote>> fetchMatchVotes({required String matchId}) {
    return _voteRepository.fetchMatchVotes(matchId);
  }
}
