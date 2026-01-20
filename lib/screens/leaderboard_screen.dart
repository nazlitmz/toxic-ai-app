import 'package:flutter/material.dart';
import '../services/leaderboard_service.dart';
import '../services/language_service.dart';
import '../services/app_localizations.dart';
import '../models/leaderboard_entry.dart';
import 'category_screen.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _language = 'en';
  List<LeaderboardEntry> _todayEntries = [];
  List<LeaderboardEntry> _weeklyEntries = [];
  UserStats _userStats = UserStats();
  DailyChallenge? _todayChallenge;
  Set<String> _likedEntries = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    final lang = await LanguageService.getLanguage();
    final today = await LeaderboardService.getTodayTop();
    final weekly = await LeaderboardService.getWeeklyTop();
    final stats = await LeaderboardService.getUserStats();
    final liked = await LeaderboardService.getLikedEntries();
    final challenge = LeaderboardService.getTodayChallenge(lang ?? 'en');

    setState(() {
      _language = lang ?? 'en';
      _todayEntries = today;
      _weeklyEntries = weekly;
      _userStats = stats;
      _likedEntries = liked;
      _todayChallenge = challenge;
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _t(String key) => AppLocalizations.get(key, _language);

  Future<void> _likeEntry(String entryId) async {
    if (_likedEntries.contains(entryId)) return;
    await LeaderboardService.likeEntry(entryId);
    setState(() => _likedEntries.add(entryId));
    await _loadData();
  }

  Color _getScoreColor(int score) {
    if (score > 70) return const Color(0xFFFF4D6D);
    if (score > 40) return const Color(0xFFFFA07A);
    return const Color(0xFFB26BFF);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F14),
      appBar: AppBar(
        backgroundColor: const Color(0xFF181820),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(_t('leaderboard'),
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFFB26BFF),
          labelColor: const Color(0xFFB26BFF),
          unselectedLabelColor: Colors.white54,
          tabs: [
            Tab(text: _t('daily_challenge')),
            Tab(text: _t('weekly_top')),
            Tab(text: _t('your_stats')),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFB26BFF))))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildChallengeTab(),
                _buildWeeklyTab(),
                _buildStatsTab()
              ],
            ),
    );
  }

  Widget _buildChallengeTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_todayChallenge != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFB26BFF).withOpacity(0.3),
                    const Color(0xFFFF4D6D).withOpacity(0.3)
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: const Color(0xFFB26BFF).withOpacity(0.5), width: 2),
              ),
              child: Column(
                children: [
                  Text(_todayChallenge!.title,
                      style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                  const SizedBox(height: 8),
                  Text(_todayChallenge!.description,
                      style: TextStyle(
                          fontSize: 14, color: Colors.white.withOpacity(0.8)),
                      textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const CategoryScreen())),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFB26BFF),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50))),
                    child: Text(_t('join_challenge'),
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 24),
          Text(_t('today_top'),
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
          const SizedBox(height: 12),
          if (_todayEntries.isEmpty)
            _buildEmptyState()
          else
            ..._todayEntries.take(10).toList().asMap().entries.map(
                (entry) => _buildLeaderboardItem(entry.key + 1, entry.value)),
        ],
      ),
    );
  }

  Widget _buildWeeklyTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_t('weekly_top'),
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
          const SizedBox(height: 12),
          if (_weeklyEntries.isEmpty)
            _buildEmptyState()
          else
            ..._weeklyEntries.take(20).toList().asMap().entries.map(
                (entry) => _buildLeaderboardItem(entry.key + 1, entry.value)),
        ],
      ),
    );
  }

  Widget _buildStatsTab() {
    double weeklyAverage = 0;
    if (_userStats.weeklyScores.isNotEmpty) {
      weeklyAverage = _userStats.weeklyScores.reduce((a, b) => a + b) /
          _userStats.weeklyScores.length;
    }

    String trend = _t('stable');
    if (_userStats.weeklyScores.length >= 2) {
      final recent = _userStats.weeklyScores.last;
      final previous =
          _userStats.weeklyScores[_userStats.weeklyScores.length - 2];
      if (recent < previous - 5)
        trend = _t('improving');
      else if (recent > previous + 5) trend = _t('worsening');
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_t('your_stats'),
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 1.5,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            children: [
              _buildStatCard('📊', _userStats.totalAnalyses.toString(),
                  _t('total_analyses')),
              _buildStatCard('🔥', '${_userStats.currentStreak} ${_t('days')}',
                  _t('current_streak')),
              _buildStatCard('🏆', '${_userStats.longestStreak} ${_t('days')}',
                  _t('longest_streak')),
              _buildStatCard('☠️', '${_userStats.highestToxicity}%',
                  _t('highest_toxicity')),
            ],
          ),
          const SizedBox(height: 24),
          Text(_t('weekly_report'),
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
                color: const Color(0xFF181820),
                borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_t('average_toxicity'),
                          style: const TextStyle(color: Color(0xFFA1A1AA))),
                      Text('${weeklyAverage.toStringAsFixed(1)}%',
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18)),
                    ]),
                const SizedBox(height: 12),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_t('trend'),
                          style: const TextStyle(color: Color(0xFFA1A1AA))),
                      Text(trend,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                    ]),
                const SizedBox(height: 16),
                if (_userStats.weeklyScores.isNotEmpty)
                  SizedBox(
                    height: 60,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: _userStats.weeklyScores
                          .map((score) => Expanded(
                                child: Container(
                                  margin:
                                      const EdgeInsets.symmetric(horizontal: 2),
                                  height: (score / 100) * 60,
                                  decoration: BoxDecoration(
                                      color: _getScoreColor(score),
                                      borderRadius: BorderRadius.circular(4)),
                                ),
                              ))
                          .toList(),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          const Text('🏆', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 16),
          Text(_t('no_entries'),
              style: const TextStyle(color: Color(0xFFA1A1AA), fontSize: 14),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildLeaderboardItem(int rank, LeaderboardEntry entry) {
    final isLiked = _likedEntries.contains(entry.id);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF181820),
        borderRadius: BorderRadius.circular(16),
        border: rank <= 3
            ? Border.all(
                color: rank == 1
                    ? const Color(0xFFFFD700)
                    : rank == 2
                        ? const Color(0xFFC0C0C0)
                        : const Color(0xFFCD7F32),
                width: 2)
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: rank <= 3
                  ? (rank == 1
                      ? const Color(0xFFFFD700)
                      : rank == 2
                          ? const Color(0xFFC0C0C0)
                          : const Color(0xFFCD7F32))
                  : const Color(0xFF2A2A35),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
                child: Text(
                    rank <= 3 ? ['🥇', '🥈', '🥉'][rank - 1] : rank.toString(),
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: rank <= 3 ? Colors.black : Colors.white,
                        fontSize: rank <= 3 ? 16 : 14))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    entry.messagePreview.length > 50
                        ? '${entry.messagePreview.substring(0, 50)}...'
                        : entry.messagePreview,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text(_t('anonymous'),
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.5), fontSize: 11)),
              ],
            ),
          ),
          Column(
            children: [
              Text('${entry.toxicity}%',
                  style: TextStyle(
                      color: _getScoreColor(entry.toxicity),
                      fontWeight: FontWeight.bold,
                      fontSize: 18)),
              const SizedBox(height: 4),
              GestureDetector(
                onTap: () => _likeEntry(entry.id),
                child: Row(children: [
                  Icon(isLiked ? Icons.favorite : Icons.favorite_border,
                      color: isLiked ? const Color(0xFFFF4D6D) : Colors.white54,
                      size: 16),
                  const SizedBox(width: 4),
                  Text(entry.likes.toString(),
                      style:
                          const TextStyle(color: Colors.white54, fontSize: 12)),
                ]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String emoji, String value, String label) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: const Color(0xFF181820),
          borderRadius: BorderRadius.circular(16)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 8),
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18)),
          Text(label,
              style: const TextStyle(color: Color(0xFFA1A1AA), fontSize: 11),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
