import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/match_model.dart';
import '../repositories/vote_repository.dart';
import 'app_env.dart';
import 'gemini_service.dart';
import 'roster_service.dart';

class AiVoteResult {
  const AiVoteResult({this.winnerId, this.winnerText});

  final String? winnerId;
  final String? winnerText;
}

class AiVoteService {
  AiVoteService({
    GeminiService? geminiService,
    VoteRepository? voteRepository,
    RosterService? rosterService,
  })
      : _geminiService = geminiService ?? GeminiService(),
        _voteRepository = voteRepository ?? VoteRepository(),
        _rosterService = rosterService ?? RosterService();

  final GeminiService _geminiService;
  final VoteRepository _voteRepository;
  final RosterService _rosterService;
  final Random _random = Random();

  bool get isConfigured => AppEnv.aiUserId.isNotEmpty && _geminiService.isConfigured;

  Future<void> submitAiVote({
    required String matchId,
    required String type,
    required String ppvName,
    required PredictionType predictionType,
    required List<String> wrestlers,
    required bool isTitleMatch,
    required bool isMainEvent,
  }) async {
    if (!isConfigured) {
      debugPrint('[AI] Config missing. Set GEMINI_API_KEY and AI_USER_ID.');
      return;
    }
    if (predictionType == PredictionType.standard && wrestlers.isEmpty) return;

    final candidates = await _resolveCandidates(predictionType, wrestlers);
    if (predictionType == PredictionType.freeText && candidates.isEmpty) {
      debugPrint('[AI] No roster candidates available for free_text.');
      return;
    }

    final prompt = _buildPrompt(
      type: type,
      ppvName: ppvName,
      predictionType: predictionType,
      wrestlers: candidates,
      isTitleMatch: isTitleMatch,
      isMainEvent: isMainEvent,
    );

    final response = await _geminiService.generateContent(prompt);
    final result = _parseResult(response, predictionType, candidates);
    if (result == null) return;

    try {
      await _voteRepository.submitVoteForUser(matchId, AppEnv.aiUserId, {
        'type': predictionType.value,
        'winnerId': result.winnerId,
        'winnerText': result.winnerText,
        'timestamp': FieldValue.serverTimestamp(),
      });
      debugPrint('[AI] Vote saved for match $matchId');
    } catch (e) {
      debugPrint('[AI] Failed to save vote: $e');
    }
  }

  Future<List<String>> _resolveCandidates(
    PredictionType predictionType,
    List<String> wrestlers,
  ) async {
    if (predictionType == PredictionType.standard) {
      return wrestlers;
    }
    if (wrestlers.isNotEmpty) {
      return wrestlers;
    }
    try {
      return await _rosterService.fetchWweRoster();
    } catch (_) {
      return [];
    }
  }

  String _buildPrompt({
    required String type,
    required String ppvName,
    required PredictionType predictionType,
    required List<String> wrestlers,
    required bool isTitleMatch,
    required bool isMainEvent,
  }) {
    final matchLine = type.isNotEmpty ? type : 'Match';
    final ppvLine = ppvName.isNotEmpty ? ppvName : 'PPV';
    final participants = wrestlers.join(', ');
    final titleLine = isTitleMatch ? 'Titolo in palio: SI' : 'Titolo in palio: NO';
    final mainEventLine = isMainEvent ? 'Main Event: SI' : 'Main Event: NO';

    if (predictionType == PredictionType.freeText) {
      final rosterLine = wrestlers.isNotEmpty ? 'Roster WWE: ${wrestlers.join(', ')}' : '';
      return [
        'Sei un giocatore AI di un’app di scommesse WWE.',
        'Scegli un vincitore dal roster WWE attuale qui sotto.',
        'Rispondi solo con JSON: {"winnerText":"NOME_ESATTO"}',
        'PPV: $ppvLine',
        'Match: $matchLine',
        titleLine,
        mainEventLine,
        if (participants.isNotEmpty) 'Partecipanti: $participants',
        if (rosterLine.isNotEmpty) rosterLine,
      ].join('\n');
    }

    return [
      'Sei un giocatore AI di un’app di scommesse WWE.',
      'Scegli un vincitore tra i partecipanti.',
      'Rispondi solo con JSON: {"winnerId":"NOME_ESATTO"}',
      'PPV: $ppvLine',
      'Match: $matchLine',
      titleLine,
      mainEventLine,
      'Partecipanti: $participants',
    ].join('\n');
  }

  AiVoteResult? _parseResult(
    String raw,
    PredictionType predictionType,
    List<String> wrestlers,
  ) {
    final parsed = _extractJson(raw);

    if (predictionType == PredictionType.freeText) {
      final text = parsed?['winnerText']?.toString().trim() ?? '';
      if (text.isNotEmpty) {
        final match = wrestlers.firstWhere(
          (name) => name.toLowerCase() == text.toLowerCase(),
          orElse: () => '',
        );
        if (match.isNotEmpty) {
          return AiVoteResult(winnerText: match);
        }
      }
      if (wrestlers.isNotEmpty) {
        final fallback = wrestlers[_random.nextInt(wrestlers.length)];
        return AiVoteResult(winnerText: fallback);
      }
      return null;
    }

    final candidate = parsed?['winnerId']?.toString().trim() ?? '';
    if (candidate.isNotEmpty) {
      final match = wrestlers.firstWhere(
        (name) => name.toLowerCase() == candidate.toLowerCase(),
        orElse: () => '',
      );
      if (match.isNotEmpty) return AiVoteResult(winnerId: match);
    }

    if (wrestlers.isNotEmpty) {
      return AiVoteResult(winnerId: wrestlers[_random.nextInt(wrestlers.length)]);
    }
    return null;
  }

  Map<String, dynamic>? _extractJson(String raw) {
    if (raw.trim().isEmpty) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      final match = RegExp(r'\{[\s\S]*\}').firstMatch(raw);
      if (match == null) return null;
      try {
        return jsonDecode(match.group(0)!) as Map<String, dynamic>;
      } catch (_) {
        return null;
      }
    }
  }
}
