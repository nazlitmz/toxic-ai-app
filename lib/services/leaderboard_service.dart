import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/leaderboard_entry.dart';

class LeaderboardService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _userStatsKey = 'user_stats';
  static const String _likedEntriesKey = 'liked_entries';

  // ==================== FIREBASE LEADERBOARD ====================

  // Leaderboard'a entry ekle (Firebase'e)
  static Future<void> addEntry(LeaderboardEntry entry) async {
    try {
      await _firestore.collection('leaderboard').doc(entry.id).set({
        'id': entry.id,
        'messagePreview': entry.messagePreview,
        'toxicity': entry.toxicity,
        'category': entry.category,
        'timestamp': Timestamp.fromDate(entry.timestamp),
        'likes': entry.likes,
      });
      print('✅ Entry added to Firebase: ${entry.id}');
    } catch (e) {
      print('❌ Firebase addEntry error: $e');
    }
  }

  // Bugünün en toksik mesajlarını getir - BASİT VERSİYON (index gerektirmez)
  static Future<List<LeaderboardEntry>> getTodayTop() async {
    try {
      // Tüm verileri çek, sonra Dart'ta filtrele
      final snapshot = await _firestore
          .collection('leaderboard')
          .orderBy('toxicity', descending: true)
          .limit(50)
          .get();

      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);

      final entries = snapshot.docs
          .map((doc) {
            final data = doc.data();
            return LeaderboardEntry(
              id: data['id'] ?? doc.id,
              messagePreview: data['messagePreview'] ?? '',
              toxicity: data['toxicity'] ?? 0,
              category: data['category'] ?? 'general',
              timestamp:
                  (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
              likes: data['likes'] ?? 0,
            );
          })
          .where((entry) => entry.timestamp.isAfter(startOfDay))
          .toList();

      // Toxicity'ye göre sırala
      entries.sort((a, b) => b.toxicity.compareTo(a.toxicity));

      print('✅ getTodayTop: ${entries.length} entries found');
      return entries;
    } catch (e) {
      print('❌ Firebase getTodayTop error: $e');
      return [];
    }
  }

  // Bu haftanın en toksik mesajlarını getir - BASİT VERSİYON
  static Future<List<LeaderboardEntry>> getWeeklyTop() async {
    try {
      final snapshot = await _firestore
          .collection('leaderboard')
          .orderBy('toxicity', descending: true)
          .limit(100)
          .get();

      final now = DateTime.now();
      final weekAgo = now.subtract(const Duration(days: 7));

      final entries = snapshot.docs
          .map((doc) {
            final data = doc.data();
            return LeaderboardEntry(
              id: data['id'] ?? doc.id,
              messagePreview: data['messagePreview'] ?? '',
              toxicity: data['toxicity'] ?? 0,
              category: data['category'] ?? 'general',
              timestamp:
                  (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
              likes: data['likes'] ?? 0,
            );
          })
          .where((entry) => entry.timestamp.isAfter(weekAgo))
          .toList();

      entries.sort((a, b) => b.toxicity.compareTo(a.toxicity));

      print('✅ getWeeklyTop: ${entries.length} entries found');
      return entries;
    } catch (e) {
      print('❌ Firebase getWeeklyTop error: $e');
      return [];
    }
  }

  // Entry beğen
  static Future<void> likeEntry(String entryId) async {
    try {
      final likedSet = await getLikedEntries();
      if (likedSet.contains(entryId)) return;

      await _firestore.collection('leaderboard').doc(entryId).update({
        'likes': FieldValue.increment(1),
      });

      likedSet.add(entryId);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_likedEntriesKey, likedSet.toList());

      print('✅ Entry liked: $entryId');
    } catch (e) {
      print('❌ Firebase likeEntry error: $e');
    }
  }

  // Beğenilen entry'leri getir (local)
  static Future<Set<String>> getLikedEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final liked = prefs.getStringList(_likedEntriesKey) ?? [];
    return liked.toSet();
  }

  // ==================== USER STATS (LOCAL) ====================

  static Future<UserStats> getUserStats() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_userStatsKey);
    if (jsonString == null) return UserStats();
    return UserStats.fromJson(jsonDecode(jsonString));
  }

  static Future<void> updateUserStats(int toxicity) async {
    final prefs = await SharedPreferences.getInstance();
    final stats = await getUserStats();
    final now = DateTime.now();

    int newStreak = stats.currentStreak;
    if (stats.lastAnalysisDate != null) {
      final lastDate = stats.lastAnalysisDate!;
      final difference = now.difference(lastDate).inDays;

      if (difference == 1) {
        newStreak = stats.currentStreak + 1;
      } else if (difference > 1) {
        newStreak = 1;
      }
    } else {
      newStreak = 1;
    }

    List<int> weeklyScores = List.from(stats.weeklyScores);
    weeklyScores.add(toxicity);
    if (weeklyScores.length > 7) {
      weeklyScores = weeklyScores.sublist(weeklyScores.length - 7);
    }

    final newStats = stats.copyWith(
      totalAnalyses: stats.totalAnalyses + 1,
      currentStreak: newStreak,
      longestStreak:
          newStreak > stats.longestStreak ? newStreak : stats.longestStreak,
      highestToxicity:
          toxicity > stats.highestToxicity ? toxicity : stats.highestToxicity,
      lastAnalysisDate: now,
      weeklyScores: weeklyScores,
    );

    await prefs.setString(_userStatsKey, jsonEncode(newStats.toJson()));
  }

  // ==================== DAILY CHALLENGE ====================

  static DailyChallenge getTodayChallenge(String language) {
    final now = DateTime.now();
    final dayOfWeek = now.weekday;

    final challenges = language == 'tr'
        ? [
            DailyChallenge(
                id: 'monday',
                title: '💔 Ex Günü',
                description: 'En toksik ex mesajını paylaş!',
                type: 'specific_category',
                targetCategory: 'ex',
                date: now),
            DailyChallenge(
                id: 'tuesday',
                title: '👔 Patron Günü',
                description: 'En sinir bozucu patron mesajını analiz et!',
                type: 'specific_category',
                targetCategory: 'boss',
                date: now),
            DailyChallenge(
                id: 'wednesday',
                title: '☠️ Maksimum Toksisite',
                description: 'En yüksek toksisite skorunu al!',
                type: 'most_toxic',
                date: now),
            DailyChallenge(
                id: 'thursday',
                title: '👨‍👩‍👧 Aile Günü',
                description: 'Anne/baba mesajlarını analiz et!',
                type: 'specific_category',
                targetCategory: 'parent',
                date: now),
            DailyChallenge(
                id: 'friday',
                title: '😇 Masumiyet Günü',
                description: 'En düşük toksisite skorunu almaya çalış!',
                type: 'least_toxic',
                date: now),
            DailyChallenge(
                id: 'saturday',
                title: '👥 Arkadaş Grubu',
                description: 'Grup sohbetindeki dramayı analiz et!',
                type: 'specific_category',
                targetCategory: 'friend',
                date: now),
            DailyChallenge(
                id: 'sunday',
                title: '🏆 Şampiyon Günü',
                description: 'Haftanın en toksik mesajı için yarış!',
                type: 'most_toxic',
                date: now),
          ]
        : [
            DailyChallenge(
                id: 'monday',
                title: '💔 Ex Day',
                description: 'Share the most toxic ex message!',
                type: 'specific_category',
                targetCategory: 'ex',
                date: now),
            DailyChallenge(
                id: 'tuesday',
                title: '👔 Boss Day',
                description: 'Analyze the most annoying boss message!',
                type: 'specific_category',
                targetCategory: 'boss',
                date: now),
            DailyChallenge(
                id: 'wednesday',
                title: '☠️ Maximum Toxicity',
                description: 'Get the highest toxicity score!',
                type: 'most_toxic',
                date: now),
            DailyChallenge(
                id: 'thursday',
                title: '👨‍👩‍👧 Family Day',
                description: 'Analyze parent messages!',
                type: 'specific_category',
                targetCategory: 'parent',
                date: now),
            DailyChallenge(
                id: 'friday',
                title: '😇 Innocence Day',
                description: 'Try to get the lowest toxicity score!',
                type: 'least_toxic',
                date: now),
            DailyChallenge(
                id: 'saturday',
                title: '👥 Friend Group',
                description: 'Analyze the drama in group chats!',
                type: 'specific_category',
                targetCategory: 'friend',
                date: now),
            DailyChallenge(
                id: 'sunday',
                title: '🏆 Champion Day',
                description: 'Compete for the most toxic message of the week!',
                type: 'most_toxic',
                date: now),
          ];

    return challenges[dayOfWeek - 1];
  }
}
