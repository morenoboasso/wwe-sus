enum PpvUserOutcome {
  allCorrect,
  allWrong,
  none,
}

class PpvFinalizeResult {
  const PpvFinalizeResult({
    required this.executed,
    required this.outcome,
  });

  final bool executed;
  final PpvUserOutcome outcome;
}
