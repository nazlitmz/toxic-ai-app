class LeaderboardEntry {
  final String id;
  final String messagePreview;
  final int toxicity;
  final String category;
  final DateTime timestamp;
  final int likes;

  LeaderboardEntry({
    required this.id,
    required this.messagePreview,
    required this.toxicity,
    required this.category,
    required this.timestamp,
    this.likes = 0,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'messagePreview': messagePreview,
        'toxicity': toxicity,
        'category': category,
        'timestamp': timestamp.toIso8601String(),
        'likes': likes,
      };

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      id: json['id'] ?? '',
      messagePreview: json['messagePreview'] ?? '',
      toxicity: json['toxicity'] ?? 0,
      category: json['category'] ?? 'general',
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
      likes: json['likes'] ?? 0,
    );
  }
}

class UserStats {
  final int totalAnalyses;
  final int currentStreak;
  final int longestStreak;
  final int highestToxicity;
  final DateTime? lastAnalysisDate;
  final List<int> weeklyScores;

  UserStats({
    this.totalAnalyses = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.highestToxicity = 0,
    this.lastAnalysisDate,
    this.weeklyScores = const [],
  });

  Map<String, dynamic> toJson() => {
        'totalAnalyses': totalAnalyses,
        'currentStreak': currentStreak,
        'longestStreak': longestStreak,
        'highestToxicity': highestToxicity,
        'lastAnalysisDate': lastAnalysisDate?.toIso8601String(),
        'weeklyScores': weeklyScores,
      };

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      totalAnalyses: json['totalAnalyses'] ?? 0,
      currentStreak: json['currentStreak'] ?? 0,
      longestStreak: json['longestStreak'] ?? 0,
      highestToxicity: json['highestToxicity'] ?? 0,
      lastAnalysisDate: json['lastAnalysisDate'] != null
          ? DateTime.tryParse(json['lastAnalysisDate'])
          : null,
      weeklyScores: List<int>.from(json['weeklyScores'] ?? []),
    );
  }

  UserStats copyWith({
    int? totalAnalyses,
    int? currentStreak,
    int? longestStreak,
    int? highestToxicity,
    DateTime? lastAnalysisDate,
    List<int>? weeklyScores,
  }) {
    return UserStats(
      totalAnalyses: totalAnalyses ?? this.totalAnalyses,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      highestToxicity: highestToxicity ?? this.highestToxicity,
      lastAnalysisDate: lastAnalysisDate ?? this.lastAnalysisDate,
      weeklyScores: weeklyScores ?? this.weeklyScores,
    );
  }
}

class DailyChallenge {
  final String id;
  final String title;
  final String description;
  final String type;
  final String? targetCategory;
  final DateTime date;

  DailyChallenge({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    this.targetCategory,
    required this.date,
  });
}
