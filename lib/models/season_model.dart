import 'package:cloud_firestore/cloud_firestore.dart';

import 'user_model.dart';

class SeasonWinner {
  const SeasonWinner({
    required this.userId,
    required this.userName,
    required this.points,
  });

  final String userId;
  final String userName;
  final int points;

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'points': points,
    };
  }

  factory SeasonWinner.fromMap(Map<String, dynamic> data) {
    return SeasonWinner(
      userId: data['userId'] as String? ?? '',
      userName: data['userName'] as String? ?? '',
      points: (data['points'] as num?)?.toInt() ?? 0,
    );
  }
}

class Season {
  const Season({
    required this.id,
    required this.name,
    required this.startAt,
    required this.endAt,
    required this.isClosed,
    required this.winners,
  });

  final String id;
  final String name;
  final DateTime startAt;
  final DateTime endAt;
  final bool isClosed;
  final List<SeasonWinner> winners;

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'startAt': startAt,
      'endAt': endAt,
      'isClosed': isClosed,
      'winners': winners.map((w) => w.toMap()).toList(),
    };
  }

  factory Season.fromMap(String id, Map<String, dynamic> data) {
    final rawWinners = (data['winners'] as List?) ?? [];
    return Season(
      id: id,
      name: data['name'] as String? ?? '',
      startAt: _toDateTime(data['startAt']) ?? DateTime.now(),
      endAt: _toDateTime(data['endAt']) ?? DateTime.now(),
      isClosed: data['isClosed'] as bool? ?? false,
      winners: rawWinners
          .whereType<Map<String, dynamic>>()
          .map(SeasonWinner.fromMap)
          .toList(),
    );
  }

  Season copyWith({
    String? id,
    String? name,
    DateTime? startAt,
    DateTime? endAt,
    bool? isClosed,
    List<SeasonWinner>? winners,
  }) {
    return Season(
      id: id ?? this.id,
      name: name ?? this.name,
      startAt: startAt ?? this.startAt,
      endAt: endAt ?? this.endAt,
      isClosed: isClosed ?? this.isClosed,
      winners: winners ?? this.winners,
    );
  }

  static DateTime? _toDateTime(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}

SeasonWinner winnerFromUser(AppUser user) {
  return SeasonWinner(
    userId: user.id,
    userName: user.name,
    points: user.seasonPoints,
  );
}
