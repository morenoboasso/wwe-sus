import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'package:wwe_bets/models/match_list_item.dart';
import 'package:wwe_bets/models/match_list_sections.dart';
import 'package:wwe_bets/models/match_model.dart';
import 'package:wwe_bets/models/ppv_finalize_result.dart';
import 'package:wwe_bets/models/season_model.dart';
import 'package:wwe_bets/models/vote_model.dart';
import 'package:wwe_bets/models/vote_stats.dart';
import 'package:wwe_bets/repositories/match_repository.dart';
import 'package:wwe_bets/repositories/season_repository.dart';
import 'package:wwe_bets/repositories/vote_repository.dart';
import 'package:wwe_bets/services/firebase/firebase_auth_service.dart';
import 'package:wwe_bets/services/firebase/firebase_firestore_service.dart';

class MatchListController {
  MatchListController({
    MatchRepository? matchRepository,
    VoteRepository? voteRepository,
    SeasonRepository? seasonRepository,
    FirebaseAuthService? authService,
    FirebaseFirestoreService? firestoreService,
  })  : _matchRepository = matchRepository ?? MatchRepository(),
        _voteRepository = voteRepository ?? VoteRepository(),
        _seasonRepository = seasonRepository ?? SeasonRepository(),
        _authService = authService ?? FirebaseAuthService(),
        _firestoreService = firestoreService ?? FirebaseFirestoreService();

  final MatchRepository _matchRepository;
  final VoteRepository _voteRepository;
  final SeasonRepository _seasonRepository;
  final FirebaseAuthService _authService;
  final FirebaseFirestoreService _firestoreService;

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

  Future<PpvFinalizeResult> finalizePpv(String ppvName) async {
    Season? season;
    try {
      season = await _seasonRepository.fetchLatestOpenSeason();
    } catch (_) {
      season = null;
    }
    final now = DateTime.now();
    final isSeasonActive = season != null && _isSeasonActive(season, now);

    final normalizedPpv = _normalize(ppvName);
    final matches = await _matchRepository.fetchMatches();
    final ppvMatches = matches
        .where((match) => _normalize(match.ppvName) == normalizedPpv)
        .toList();

    if (ppvMatches.isEmpty) {
      return const PpvFinalizeResult(executed: false, outcome: PpvUserOutcome.none);
    }

    final allClosed = ppvMatches.every((match) => match.status == MatchStatus.closed);
    if (!allClosed) {
      return const PpvFinalizeResult(executed: false, outcome: PpvUserOutcome.none);
    }

    final normalizedId = normalizedPpv.replaceAll(' ', '_');
    final matchIds = ppvMatches.map((m) => m.id).toList()..sort();
    final signature = matchIds.join('|');
    final hash = _fnv1aHex(signature); // already padded, no substring to avoid RangeError
    final bonusDocId = '${normalizedId}_$hash';
    final bonusDocRef = _firestoreService.instance.collection('ppv_bonus').doc(bonusDocId);
    final bonusDoc = await bonusDocRef.get();
    if (bonusDoc.exists) {
      return const PpvFinalizeResult(executed: false, outcome: PpvUserOutcome.none);
    }

    final votesByMatch = <String, List<Vote>>{};
    final userIds = <String>{};

    for (final match in ppvMatches) {
      final votes = await _voteRepository.fetchMatchVotes(match.id);
      votesByMatch[match.id] = votes;
      userIds.addAll(votes.map((v) => v.userId));
    }

    final batch = _firestoreService.instance.batch();

    final currentUserId = _authService.currentUser?.uid;
    var currentUserOutcome = PpvUserOutcome.none;

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

      if (currentUserId != null && userId == currentUserId) {
        currentUserOutcome = isAllCorrect ? PpvUserOutcome.allCorrect : PpvUserOutcome.allWrong;
      }

      final bonus = isAllCorrect ? 8 : -8;
      final userRef = _firestoreService.instance.collection('users').doc(userId);
      final userDoc = await userRef.get();
      if (!userDoc.exists) {
        continue;
      }
      batch.set(userRef, {
        'points': FieldValue.increment(bonus),
        if (isSeasonActive) 'seasonPoints': FieldValue.increment(bonus),
      }, SetOptions(merge: true));
    }

    for (final match in ppvMatches) {
      final matchRef = _firestoreService.instance.collection('matches').doc(match.id);
      batch.delete(matchRef);
    }

    batch.set(bonusDocRef, {
      'ppvName': normalizedPpv,
      'processedAt': FieldValue.serverTimestamp(),
      'matchIds': ppvMatches.map((m) => m.id).toList(),
    });

    await batch.commit();
    return PpvFinalizeResult(executed: true, outcome: currentUserOutcome);
  }

  bool _isSeasonActive(Season season, DateTime now) {
    if (season.isClosed) return false;
    final nowDate = _dateOnly(now);
    final startDate = _dateOnly(season.startAt);
    final endDate = _dateOnly(season.endAt);
    return !nowDate.isBefore(startDate) && !nowDate.isAfter(endDate);
  }

  DateTime _dateOnly(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }

  String _fnv1aHex(String input) {
    const int fnvPrime = 0x01000193;
    const int fnvOffsetBasis = 0x811C9DC5;
    var hash = fnvOffsetBasis;
    final bytes = utf8.encode(input);
    for (final b in bytes) {
      hash ^= b;
      hash = (hash * fnvPrime) & 0xFFFFFFFF;
    }
    return hash.toRadixString(16).padLeft(8, '0');
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
