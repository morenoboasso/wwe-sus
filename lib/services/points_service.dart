import '../models/match_model.dart';
import '../models/vote_model.dart';

class PointsService {
  int calculatePoints(Match match, Vote vote) {
    if (match.predictionType == PredictionType.standard) {
      return _calculateStandardPoints(match, vote);
    }
    return _calculateFreeTextPoints(match, vote);
  }

  int _calculateStandardPoints(Match match, Vote vote) {
    final winnerId = vote.winnerId;
    final result = match.result;
    if (winnerId == null || result == null) return 0;
    if (winnerId != result) return 0;

    var points = 2;
    if (match.isTitleMatch) {
      points += 1;
    }
    if (match.isMainEvent) {
      points += 1;
    }
    return points;
  }

  int _calculateFreeTextPoints(Match match, Vote vote) {
    final voteText = vote.winnerText;
    if (voteText == null) return 0;

    final resultTexts = match.resultTexts;
    if (resultTexts != null && resultTexts.contains(voteText)) {
      return 5;
    }

    final singleResultText = match.resultText;
    if (singleResultText != null && singleResultText == voteText) {
      return 5;
    }

    return 0;
  }
}
