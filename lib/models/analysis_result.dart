class AnalysisResult {
  final int toxicity;
  final String passiveAggressive;
  final String gaslighting;
  final String comment;

  AnalysisResult({
    required this.toxicity,
    required this.passiveAggressive,
    required this.gaslighting,
    required this.comment,
  });
}
