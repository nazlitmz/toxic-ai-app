import 'package:flutter/material.dart';
import '../models/category_model.dart';
import '../services/ai_service.dart';
import '../services/language_service.dart';
import '../services/app_localizations.dart';
import '../services/leaderboard_service.dart';
import '../models/analysis_result.dart';
import '../models/leaderboard_entry.dart';
import 'share_card_screen.dart';
import 'transform_screen.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final TextEditingController _controller = TextEditingController();
  String _language = 'en';
  MessageCategory? _selectedCategory;
  bool _isLoading = false;
  AnalysisResult? _result;
  String _loadingText = '';
  int _loadingIndex = 0;
  List<String> _loadingMessages = [];
  bool _isSubmitted = false;

  @override
  void initState() {
    super.initState();
    _loadLanguage();
    _controller.addListener(() => setState(() {}));
  }

  Future<void> _loadLanguage() async {
    final lang = await LanguageService.getLanguage();
    setState(() {
      _language = lang ?? 'en';
      _loadingMessages = AppLocalizations.getLoadingMessages(_language);
      _selectedCategory = MessageCategory.categories.first;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _t(String key) => AppLocalizations.get(key, _language);

  void _startLoadingAnimation() {
    Future.doWhile(() async {
      if (!_isLoading) return false;
      await Future.delayed(const Duration(milliseconds: 800));
      if (mounted && _isLoading) {
        setState(() {
          _loadingText =
              _loadingMessages[_loadingIndex % _loadingMessages.length];
          _loadingIndex++;
        });
      }
      return _isLoading;
    });
  }

  Future<void> _analyze() async {
    if (_controller.text.trim().isEmpty || _selectedCategory == null) return;

    setState(() {
      _isLoading = true;
      _result = null;
      _loadingIndex = 0;
      _isSubmitted = false;
    });

    _startLoadingAnimation();

    try {
      final result = await AIService.analyzeWithCategory(
        _controller.text,
        _selectedCategory!.getContext(_language),
        _language,
      );
      if (mounted) {
        setState(() {
          _result = result;
          _isLoading = false;
        });

        // User stats güncelle
        await LeaderboardService.updateUserStats(result.toxicity);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _submitToLeaderboard() async {
    if (_result == null || _isSubmitted) return;

    final entry = LeaderboardEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      messagePreview: _controller.text,
      toxicity: _result!.toxicity,
      category: _selectedCategory?.id ?? 'general',
      timestamp: DateTime.now(),
    );

    await LeaderboardService.addEntry(entry);

    setState(() => _isSubmitted = true);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_t('submitted')),
          backgroundColor: const Color(0xFFB26BFF),
        ),
      );
    }
  }

  void _reset() {
    setState(() {
      _controller.clear();
      _result = null;
      _isSubmitted = false;
    });
  }

  void _openTransform() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TransformScreen(
          originalMessage: _controller.text,
          language: _language,
        ),
      ),
    );
  }

  void _shareResult() {
    if (_result != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ShareCardScreen(
            toxicity: _result!.toxicity,
            passiveAggressive: _result!.passiveAggressive,
            gaslighting: _result!.gaslighting,
            comment: _result!.comment,
            category: _t(_selectedCategory!.nameKey),
            language: _language,
          ),
        ),
      );
    }
  }

  Color _getToxicityColor(int toxicity) {
    if (toxicity > 70) return const Color(0xFFFF4D6D);
    if (toxicity > 40) return const Color(0xFFFFA07A);
    return const Color(0xFFB26BFF);
  }

  String _getToxicityLabel(int toxicity) {
    if (toxicity > 70) return _t('toxic');
    if (toxicity > 40) return _t('questionable');
    return _t('mild');
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
        title: Text(
          _t('categories'),
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: _isLoading
            ? _buildLoadingView()
            : _result != null
                ? _buildResultView()
                : _buildInputView(),
      ),
    );
  }

  Widget _buildInputView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _t('category_subtitle'),
            style:
                TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 1.1,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: MessageCategory.categories.length,
            itemBuilder: (context, index) {
              final category = MessageCategory.categories[index];
              final isSelected = _selectedCategory?.id == category.id;

              return GestureDetector(
                onTap: () => setState(() => _selectedCategory = category),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFFB26BFF).withOpacity(0.2)
                        : const Color(0xFF181820),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFFB26BFF)
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(category.emoji,
                          style: const TextStyle(fontSize: 28)),
                      const SizedBox(height: 6),
                      Text(
                        _t(category.nameKey),
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.white70,
                          fontSize: 11,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF181820),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: const Color(0xFFB26BFF).withOpacity(0.3), width: 1),
            ),
            child: TextField(
              controller: _controller,
              maxLines: 6,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: _t('input_hint'),
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _controller.text.trim().isEmpty ? null : _analyze,
              icon: const Icon(Icons.psychology, color: Colors.white),
              label: Text(
                _t('analyze_button'),
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB26BFF),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50)),
                disabledBackgroundColor:
                    const Color(0xFFB26BFF).withOpacity(0.5),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed:
                  _controller.text.trim().isEmpty ? null : _openTransform,
              icon: Icon(
                Icons.auto_fix_high,
                color: _controller.text.trim().isEmpty
                    ? Colors.white38
                    : const Color(0xFFFFA07A),
              ),
              label: Text(
                _t('transform_message'),
                style: TextStyle(
                  color: _controller.text.trim().isEmpty
                      ? Colors.white38
                      : const Color(0xFFFFA07A),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50)),
                side: BorderSide(
                  color: _controller.text.trim().isEmpty
                      ? Colors.white24
                      : const Color(0xFFFFA07A),
                  width: 2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(_selectedCategory?.emoji ?? '💬',
              style: const TextStyle(fontSize: 80)),
          const SizedBox(height: 40),
          Container(
            width: 200,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFF181820),
              borderRadius: BorderRadius.circular(2),
            ),
            child: const LinearProgressIndicator(
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFB26BFF)),
            ),
          ),
          const SizedBox(height: 16),
          Text(_loadingText, style: const TextStyle(color: Color(0xFFA1A1AA))),
        ],
      ),
    );
  }

  Widget _buildResultView() {
    final toxicity = _result!.toxicity;
    final color = _getToxicityColor(toxicity);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color, width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_selectedCategory?.emoji ?? '💬',
                    style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                Text(
                  _t(_selectedCategory!.nameKey),
                  style: TextStyle(color: color, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: const Color(0xFF181820),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: color.withOpacity(0.3), width: 2),
            ),
            child: Column(
              children: [
                Text(
                  _t('ai_verdict'),
                  style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFFA1A1AA),
                      fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 20),
                Text(
                  '$toxicity%',
                  style: TextStyle(
                      fontSize: 64, fontWeight: FontWeight.w900, color: color),
                ),
                Text(
                  _getToxicityLabel(toxicity),
                  style: TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold, color: color),
                ),
                const SizedBox(height: 24),
                _buildMetricRow(
                    _t('passive_aggressive'), _result!.passiveAggressive),
                const SizedBox(height: 12),
                _buildMetricRow(_t('gaslighting'), _result!.gaslighting),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '"${_result!.comment}"',
                    style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFFA1A1AA),
                        fontStyle: FontStyle.italic),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Submit to Leaderboard Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isSubmitted ? null : _submitToLeaderboard,
              icon: Icon(
                _isSubmitted ? Icons.check : Icons.leaderboard,
                color: _isSubmitted ? Colors.white54 : Colors.black,
              ),
              label: Text(
                _isSubmitted ? _t('submitted') : _t('submit_to_leaderboard'),
                style: TextStyle(
                  color: _isSubmitted ? Colors.white54 : Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _isSubmitted
                    ? const Color(0xFF181820)
                    : const Color(0xFFFFD700),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50)),
              ),
            ),
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _shareResult,
                  icon: const Icon(Icons.share, color: Colors.white, size: 20),
                  label: Text(
                    _t('share'),
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB26BFF),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _openTransform,
                  icon: const Icon(Icons.auto_fix_high,
                      color: Colors.white, size: 20),
                  label: Text(
                    _t('transform_message'),
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 11),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFA07A),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50)),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _reset,
              icon: const Icon(Icons.refresh, color: Color(0xFFB26BFF)),
              label: Text(
                _t('try_another'),
                style: const TextStyle(
                    color: Color(0xFFB26BFF), fontWeight: FontWeight.bold),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50)),
                side: const BorderSide(color: Color(0xFFB26BFF), width: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricRow(String label, String value) {
    Color valueColor = const Color(0xFFB26BFF);
    if (value == 'HIGH' ||
        value == 'YÜKSEK' ||
        value == 'DETECTED' ||
        value == 'TESPİT EDİLDİ') {
      valueColor = const Color(0xFFFF4D6D);
    } else if (value == 'MEDIUM' || value == 'ORTA') {
      valueColor = const Color(0xFFFFA07A);
    }

    String displayValue = value;
    if (_language == 'tr') {
      if (value == 'LOW') displayValue = 'DÜŞÜK';
      if (value == 'MEDIUM') displayValue = 'ORTA';
      if (value == 'HIGH') displayValue = 'YÜKSEK';
      if (value == 'DETECTED') displayValue = 'TESPİT EDİLDİ';
      if (value == 'NOT DETECTED') displayValue = 'TESPİT EDİLMEDİ';
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(color: Color(0xFFA1A1AA), fontSize: 14)),
        Text(displayValue,
            style: TextStyle(
                color: valueColor, fontWeight: FontWeight.bold, fontSize: 14)),
      ],
    );
  }
}
