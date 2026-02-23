import 'package:cloud_firestore/cloud_firestore.dart';

enum PredictionType {
  standard('standard'),
  freeText('free_text');

  const PredictionType(this.value);

  final String value;

  static PredictionType fromValue(String? value) {
    return PredictionType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => PredictionType.standard,
    );
  }
}

enum MatchStatus {
  open('open'),
  closed('closed');

  const MatchStatus(this.value);

  final String value;

  static MatchStatus fromValue(String? value) {
    return MatchStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => MatchStatus.open,
    );
  }
}

class Match {
  const Match({
    required this.id,
    required this.title,
    required this.type,
    required this.isTitleMatch,
    required this.isMainEvent,
    required this.ppvName,
    required this.wrestlers,
    required this.predictionType,
    required this.status,
    required this.createdBy,
    required this.createdAt,
    this.result,
    this.resultText,
  });

  final String id;
  final String title;
  final String type;
  final bool isTitleMatch;
  final bool isMainEvent;
  final String ppvName;
  final List<String> wrestlers;
  final PredictionType predictionType;
  final MatchStatus status;
  final String createdBy;
  final DateTime? createdAt;
  final String? result;
  final String? resultText;

  factory Match.fromMap(String id, Map<String, dynamic> data) {
    return Match(
      id: id,
      title: data['title'] as String? ?? '',
      type: data['type'] as String? ?? '',
      isTitleMatch: data['isTitleMatch'] as bool? ?? false,
      isMainEvent: data['isMainEvent'] as bool? ?? false,
      ppvName: data['ppvName'] as String? ?? '',
      wrestlers: List<String>.from((data['wrestlers'] as List?) ?? const []),
      predictionType: PredictionType.fromValue(data['predictionType'] as String?),
      status: MatchStatus.fromValue(data['status'] as String?),
      createdBy: data['createdBy'] as String? ?? '',
      createdAt: _toDateTime(data['createdAt']),
      result: data['result'] as String?,
      resultText: data['resultText'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'type': type,
      'isTitleMatch': isTitleMatch,
      'isMainEvent': isMainEvent,
      'ppvName': ppvName,
      'wrestlers': wrestlers,
      'predictionType': predictionType.value,
      'status': status.value,
      'createdBy': createdBy,
      'createdAt': createdAt,
      'result': result,
      'resultText': resultText,
    };
  }

  Match copyWith({
    String? title,
    String? type,
    bool? isTitleMatch,
    bool? isMainEvent,
    String? ppvName,
    List<String>? wrestlers,
    PredictionType? predictionType,
    MatchStatus? status,
    String? createdBy,
    DateTime? createdAt,
    String? result,
    String? resultText,
  }) {
    return Match(
      id: id,
      title: title ?? this.title,
      type: type ?? this.type,
      isTitleMatch: isTitleMatch ?? this.isTitleMatch,
      isMainEvent: isMainEvent ?? this.isMainEvent,
      ppvName: ppvName ?? this.ppvName,
      wrestlers: wrestlers ?? this.wrestlers,
      predictionType: predictionType ?? this.predictionType,
      status: status ?? this.status,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      result: result ?? this.result,
      resultText: resultText ?? this.resultText,
    );
  }

  bool get isOpen => status == MatchStatus.open;

  bool get hasResult => (result != null && result!.isNotEmpty) || (resultText != null && resultText!.isNotEmpty);

  static DateTime? _toDateTime(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }
}
