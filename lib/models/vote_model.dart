import 'package:cloud_firestore/cloud_firestore.dart';

import 'match_model.dart';

class Vote {
  const Vote({
    required this.matchId,
    required this.userId,
    required this.type,
    this.winnerId,
    this.winnerText,
    required this.timestamp,
  });

  final String matchId;
  final String userId;
  final PredictionType type;
  final String? winnerId;
  final String? winnerText;
  final DateTime? timestamp;

  bool get isStandard => type == PredictionType.standard;

  bool get isFreeText => type == PredictionType.freeText;

  factory Vote.fromMap({
    required String matchId,
    required String userId,
    required Map<String, dynamic> data,
  }) {
    return Vote(
      matchId: matchId,
      userId: userId,
      type: PredictionType.fromValue(data['type'] as String?),
      winnerId: data['winnerId'] as String?,
      winnerText: data['winnerText'] as String?,
      timestamp: _toDateTime(data['timestamp']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type.value,
      'winnerId': winnerId,
      'winnerText': winnerText,
      'timestamp': timestamp,
    };
  }

  Vote copyWith({
    PredictionType? type,
    String? winnerId,
    String? winnerText,
    DateTime? timestamp,
  }) {
    return Vote(
      matchId: matchId,
      userId: userId,
      type: type ?? this.type,
      winnerId: winnerId ?? this.winnerId,
      winnerText: winnerText ?? this.winnerText,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  static DateTime? _toDateTime(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }
}
