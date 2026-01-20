import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../services/ai_service.dart';
import '../services/language_service.dart';
import '../services/app_localizations.dart';

class CompareScreen extends StatefulWidget {
  const CompareScreen({super.key});

  @override
  State<CompareScreen> createState() => _CompareScreenState();
}

class _CompareScreenState extends State<CompareScreen> {
  final TextEditingController _controller1 = TextEditingController();
  final TextEditingController _controller2 = TextEditingController();
  bool _isLoading = false;
  Map<String, dynamic>? _result;
  String _loadingText = '';
  int _loadingIndex = 0;
  String _language = 'en';
  List<String> _loadingMessages = [];

  @override
  void initState() {
    super.initState();
    _loadLanguage();
    _controller1.addListener(() => setState(() {}));
    _controller2.addListener(() => setState(() {}));
  }

  Future<void> _loadLanguage() async {
    final lang = await LanguageService.getLanguage();
    setState(() {
      _language = lang ?? 'en';
      _loadingMessages = AppLocalizations.getCompareLoadingMessages(_language);
    });
  }

  @override
  void dispose() {
    _controller1.dispose();
    _controller2.dispose();
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

  Future<void> _compareTexts() async {
    if (_controller1.text.trim().isEmpty || _controller2.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_t('enter_both_messages'))),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _result = null;
      _loadingIndex = 0;
    });

    _startLoadingAnimation();

    try {
      final result = await AIService.compareTexts(
        _controller1.text,
        _controller2.text,
      );
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
      final msg1 = _result!['message1'];
      final msg2 = _result!['message2'];
      final winner = _result!['winner'];
      final comparison = _result!['comparison'];

      String winnerText =
          winner == 'message1' ? _t('message_1') : _t('message_2');

      String shareText = _t('share_compare')
          .replaceAll('{t1}', msg1['toxicity'].toString())
          .replaceAll('{t2}', msg2['toxicity'].toString())
          .replaceAll('{winner}', winnerText)
          .replaceAll('{comparison}', comparison);

      Share.share(shareText);
    }
  }

  void _reset() {
    setState(() {
      _controller1.clear();
      _controller2.clear();
      _result = null;
    });
  }

  Color _getToxicityColor(int toxicity) {
    if (toxicity > 70) return const Color(0xFFFF4D6D);
    if (toxicity > 40) return const Color(0xFFFFA07A);
    return const Color(0xFFB26BFF);
  }

  String _translateValue(String value) {
    if (_language != 'tr') return value;

    if (value == 'LOW') return 'DÜŞÜK';
    if (value == 'MEDIUM') return 'ORTA';
    if (value == 'HIGH') return 'YÜKSEK';
    if (value == 'DETECTED') return 'TESPİT EDİLDİ';
    if (value == 'NOT DETECTED') return 'TESPİT EDİLMEDİ';
    return value;
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
          _t('compare_button'),
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
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
        const Text('🥊', style: TextStyle(fontSize: 64)),
        const SizedBox(height: 16),
        Text(
          _t('toxicity_battle'),
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _t('which_more_toxic'),
          style: const TextStyle(fontSize: 14, color: Color(0xFFA1A1AA)),
        ),
        const SizedBox(height: 40),

        // Message 1
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF181820),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
                color: const Color(0xFFB26BFF).withOpacity(0.3), width: 2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  _t('message_1'),
                  style: const TextStyle(
                    color: Color(0xFFB26BFF),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              TextField(
                controller: _controller1,
                maxLines: 4,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: _t('first_message_hint'),
                  hintStyle: const TextStyle(color: Color(0xFFA1A1AA)),
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),

        const SizedBox(height: 20),
        const Text(
          'VS',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFFFF4D6D),
          ),
        ),
        const SizedBox(height: 20),

        // Message 2
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF181820),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
                color: const Color(0xFFFF4D6D).withOpacity(0.3), width: 2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  _t('message_2'),
                  style: const TextStyle(
                    color: Color(0xFFFF4D6D),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              TextField(
                controller: _controller2,
                maxLines: 4,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: _t('second_message_hint'),
                  hintStyle: const TextStyle(color: Color(0xFFA1A1AA)),
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),

        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: (_controller1.text.trim().isEmpty ||
                    _controller2.text.trim().isEmpty)
                ? null
                : _compareTexts,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFB26BFF),
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
              ),
              disabledBackgroundColor: const Color(0xFFB26BFF).withOpacity(0.5),
            ),
            child: Text(
              _t('compare_toxicity'),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingView() {
    return Column(
      children: [
        const Text('🥊', style: TextStyle(fontSize: 80)),
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
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildResultView() {
    final msg1 = _result!['message1'];
    final msg2 = _result!['message2'];
    final winner = _result!['winner'];
    final comparison = _result!['comparison'];

    return Column(
      children: [
        const Text('🏆', style: TextStyle(fontSize: 48)),
        const SizedBox(height: 16),
        Text(
          _t('battle_results'),
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 32),
        _buildMessageCard(
          _t('message_1'),
          msg1,
          winner == 'message1',
          const Color(0xFFB26BFF),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFFF4D6D),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            'VS',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 24),
        _buildMessageCard(
          _t('message_2'),
          msg2,
          winner == 'message2',
          const Color(0xFFFF4D6D),
        ),
        const SizedBox(height: 32),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF181820),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFFFFA07A).withOpacity(0.3),
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Text(
                _t('ai_verdict_compare'),
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFFA1A1AA),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                comparison,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _shareResult,
                icon: const Icon(Icons.share, color: Colors.white),
                label: Text(
                  _t('share_results'),
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB26BFF),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _reset,
                icon: const Icon(Icons.refresh, color: Colors.white),
                label: Text(
                  _t('new_battle'),
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF181820),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMessageCard(String title, Map<String, dynamic> data,
      bool isWinner, Color accentColor) {
    final toxicity = (data['toxicity'] is int)
        ? data['toxicity']
        : (data['toxicity'] as num).toInt();
    final color = _getToxicityColor(toxicity);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF181820),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isWinner ? accentColor : accentColor.withOpacity(0.2),
          width: isWinner ? 3 : 2,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: accentColor,
                ),
              ),
              if (isWinner)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFA07A),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _t('winner'),
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '$toxicity%',
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${_translateValue(data['passive_aggressive'].toString())} ${_t('passive_aggressive').replaceAll(':', '')}',
            style: const TextStyle(fontSize: 12, color: Color(0xFFA1A1AA)),
          ),
          const SizedBox(height: 4),
          Text(
            _translateValue(data['gaslighting'].toString()),
            style: TextStyle(
              fontSize: 12,
              color: data['gaslighting'].toString().contains('DETECTED') ||
                      data['gaslighting'].toString().contains('TESPİT')
                  ? const Color(0xFFFF4D6D)
                  : const Color(0xFFB26BFF),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '"${data['comment']}"',
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFFA1A1AA),
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
