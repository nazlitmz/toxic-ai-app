import 'package:flutter/material.dart';
import '../services/ai_service.dart';
import '../services/language_service.dart';
import '../services/app_localizations.dart';
import '../models/analysis_result.dart';
import 'compare_screen.dart';
import 'language_screen.dart';
import 'share_card_screen.dart';
import 'category_screen.dart';
import 'transform_screen.dart';
import 'leaderboard_screen.dart';
import '../services/leaderboard_service.dart';
import '../models/leaderboard_entry.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = false;
  AnalysisResult? _result;
  String _loadingText = '';
  int _loadingIndex = 0;
  String _language = 'en';
  List<String> _loadingMessages = [];

  @override
  void initState() {
    super.initState();
    _loadLanguage();
    _controller.addListener(() {
      setState(() {});
    });
  }

  Future<void> _loadLanguage() async {
    final lang = await LanguageService.getLanguage();
    setState(() {
      _language = lang ?? 'en';
      _loadingMessages = AppLocalizations.getLoadingMessages(_language);
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

  Future<void> _analyzeText() async {
    if (_controller.text.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
      _result = null;
      _loadingIndex = 0;
    });

    _startLoadingAnimation();

    try {
      final result = await AIService.analyzeText(_controller.text);
      if (mounted) {
        setState(() {
          _result = result;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
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
            language: _language,
          ),
        ),
      );
    }
  }

  void _reset() {
    setState(() {
      _controller.clear();
      _result = null;
    });
  }

  void _navigateToCompare() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CompareScreen()),
    );
  }

  void _navigateToCategory() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CategoryScreen()),
    );
  }

  void _navigateToTransform() {
    if (_controller.text.trim().isNotEmpty) {
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
  }

  void _changeLanguage() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LanguageScreen()),
    );
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
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.language, color: Colors.white),
            onPressed: _changeLanguage,
            tooltip: _t('change_language'),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: _buildContent(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) return _buildLoadingView();
    if (_result != null) return _buildResultView();
    return _buildInputView();
  }

  Widget _buildInputView() {
    return Column(
      children: [
        const Text('☠️', style: TextStyle(fontSize: 64)),
        const SizedBox(height: 16),
        Text(
          _t('app_title'),
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          _t('app_subtitle'),
          style: const TextStyle(fontSize: 14, color: Color(0xFFA1A1AA)),
        ),
        const SizedBox(height: 40),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF181820),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.transparent, width: 2),
          ),
          child: TextField(
            controller: _controller,
            maxLines: 8,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: _t('input_hint'),
              hintStyle: const TextStyle(color: Color(0xFFA1A1AA)),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(20),
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Analyze Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _controller.text.trim().isEmpty ? null : _analyzeText,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFB26BFF),
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
              ),
              disabledBackgroundColor: const Color(0xFFB26BFF).withOpacity(0.5),
            ),
            child: Text(
              _t('analyze_button'),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Compare Button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _navigateToCompare,
            icon: const Icon(Icons.compare_arrows, color: Color(0xFFB26BFF)),
            label: Text(
              _t('compare_button'),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFFB26BFF),
              ),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
              ),
              side: const BorderSide(color: Color(0xFFB26BFF), width: 2),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Category Analysis Button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _navigateToCategory,
            icon: const Icon(Icons.category, color: Color(0xFFFFA07A)),
            label: Text(
              _t('categories'),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFFA07A),
              ),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
              ),
              side: const BorderSide(color: Color(0xFFFFA07A), width: 2),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Transform Message Button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed:
                _controller.text.trim().isEmpty ? null : _navigateToTransform,
            icon: Icon(
              Icons.auto_fix_high,
              color: _controller.text.trim().isEmpty
                  ? Colors.white38
                  : const Color(0xFF4CAF50),
            ),
            label: Text(
              _t('transform_message'),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: _controller.text.trim().isEmpty
                    ? Colors.white38
                    : const Color(0xFF4CAF50),
              ),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
              ),
              side: BorderSide(
                color: _controller.text.trim().isEmpty
                    ? Colors.white24
                    : const Color(0xFF4CAF50),
                width: 2,
              ),
            ),
          ),
        ), // <-- BU PARANTEZ EKSİKTİ
        const SizedBox(height: 12),

        // Leaderboard Button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const LeaderboardScreen()),
              );
            },
            icon: const Icon(Icons.leaderboard, color: Color(0xFFFFD700)),
            label: Text(
              _t('leaderboard'),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFFD700),
              ),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
              ),
              side: const BorderSide(color: Color(0xFFFFD700), width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingView() {
    return Column(
      children: [
        const Text('☠️', style: TextStyle(fontSize: 80)),
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
        Text(
          _loadingText,
          style: const TextStyle(color: Color(0xFFA1A1AA)),
        ),
      ],
    );
  }

  Widget _buildResultView() {
    final toxicity = _result!.toxicity;
    final color = _getToxicityColor(toxicity);

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: const Color(0xFF181820),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
                color: const Color(0xFFB26BFF).withOpacity(0.2), width: 2),
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
              const SizedBox(height: 24),
              Text(
                '$toxicity%',
                style: TextStyle(
                    fontSize: 72, fontWeight: FontWeight.w900, color: color),
              ),
              Text(
                _getToxicityLabel(toxicity),
                style: TextStyle(
                    fontSize: 24, fontWeight: FontWeight.bold, color: color),
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.only(top: 24),
                decoration: const BoxDecoration(
                  border: Border(
                      top: BorderSide(color: Color(0xFFA1A1AA), width: 0.2)),
                ),
                child: Column(
                  children: [
                    _buildMetric(
                        _t('passive_aggressive'), _result!.passiveAggressive),
                    const SizedBox(height: 16),
                    _buildMetric(_t('gaslighting'), _result!.gaslighting),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.only(top: 24),
                decoration: const BoxDecoration(
                  border: Border(
                      top: BorderSide(color: Color(0xFFA1A1AA), width: 0.2)),
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

        // Share & Try Another Row
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _shareResult,
                icon: const Icon(Icons.share, color: Colors.white),
                label: Text(_t('share'),
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB26BFF),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _reset,
                icon: const Icon(Icons.refresh, color: Colors.white),
                label: Text(_t('try_another'),
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF181820),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50)),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Transform Button in Result View
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TransformScreen(
                    originalMessage: _controller.text,
                    language: _language,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.auto_fix_high, color: Color(0xFF4CAF50)),
            label: Text(
              _t('transform_message'),
              style: const TextStyle(
                color: Color(0xFF4CAF50),
                fontWeight: FontWeight.bold,
              ),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
              ),
              side: const BorderSide(color: Color(0xFF4CAF50), width: 2),
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text('toxicai.app',
            style: TextStyle(fontSize: 10, color: Color(0xFFA1A1AA))),
      ],
    );
  }

  Widget _buildMetric(String label, String value) {
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

    String emoji = '';
    if (label.contains('Passive') || label.contains('Pasif')) {
      if (value == 'HIGH' || value == 'YÜKSEK') {
        emoji = ' 😬';
      } else if (value == 'MEDIUM' || value == 'ORTA') {
        emoji = ' 😐';
      } else {
        emoji = ' 😊';
      }
    } else {
      emoji = (value == 'DETECTED' || value == 'TESPİT EDİLDİ') ? ' 🚩' : ' ✅';
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 14, color: Color(0xFFA1A1AA))),
        Text(
          displayValue + emoji,
          style: TextStyle(
              fontSize: 14, fontWeight: FontWeight.bold, color: valueColor),
        ),
      ],
    );
  }
}
