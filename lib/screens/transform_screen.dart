import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/ai_service.dart';
import '../services/app_localizations.dart';

class TransformScreen extends StatefulWidget {
  final String originalMessage;
  final String language;

  const TransformScreen({
    super.key,
    required this.originalMessage,
    required this.language,
  });

  @override
  State<TransformScreen> createState() => _TransformScreenState();
}

class _TransformScreenState extends State<TransformScreen> {
  String? _transformedMessage;
  String? _selectedType;
  bool _isLoading = false;

  String _t(String key) => AppLocalizations.get(key, widget.language);

  Future<void> _transform(String type) async {
    setState(() {
      _isLoading = true;
      _selectedType = type;
      _transformedMessage = null;
    });

    try {
      final result = await AIService.transformMessage(
        widget.originalMessage,
        type,
        widget.language,
      );
      if (mounted) {
        setState(() {
          _transformedMessage = result;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_t('transform_error'))),
        );
      }
    }
  }

  void _copyToClipboard() {
    if (_transformedMessage != null) {
      Clipboard.setData(ClipboardData(text: _transformedMessage!));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_t('copied')),
          backgroundColor: const Color(0xFFB26BFF),
          duration: const Duration(seconds: 1),
        ),
      );
    }
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
          _t('transform_message'),
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Original Message
              Text(
                _t('original_message'),
                style: const TextStyle(
                  color: Color(0xFFA1A1AA),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF181820),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: Text(
                  widget.originalMessage,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),

              const SizedBox(height: 24),

              // Transform Options
              Text(
                _t('transform_message'),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Transform Buttons Grid
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                childAspectRatio: 2.2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: [
                  _buildTransformButton(
                    'less_toxic',
                    _t('make_less_toxic'),
                    const Color(0xFF4CAF50),
                    Icons.sentiment_satisfied,
                  ),
                  _buildTransformButton(
                    'more_toxic',
                    _t('make_more_toxic'),
                    const Color(0xFFFF4D6D),
                    Icons.sentiment_very_dissatisfied,
                  ),
                  _buildTransformButton(
                    'professional',
                    _t('rewrite_professional'),
                    const Color(0xFF2196F3),
                    Icons.business,
                  ),
                  _buildTransformButton(
                    'friendly',
                    _t('rewrite_friendly'),
                    const Color(0xFFFFA07A),
                    Icons.favorite,
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Loading or Result
              if (_isLoading)
                Center(
                  child: Column(
                    children: [
                      const CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Color(0xFFB26BFF)),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _t('transforming'),
                        style: const TextStyle(color: Color(0xFFA1A1AA)),
                      ),
                    ],
                  ),
                ),

              if (_transformedMessage != null && !_isLoading) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _t('transformed_message'),
                      style: const TextStyle(
                        color: Color(0xFFA1A1AA),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: _copyToClipboard,
                      icon: const Icon(Icons.copy,
                          color: Color(0xFFB26BFF), size: 20),
                      tooltip: _t('copy_message'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFB26BFF).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: const Color(0xFFB26BFF).withOpacity(0.3)),
                  ),
                  child: Text(
                    _transformedMessage!,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _copyToClipboard,
                    icon: const Icon(Icons.copy, color: Colors.white),
                    label: Text(
                      _t('copy_message'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFB26BFF),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransformButton(
    String type,
    String label,
    Color color,
    IconData icon,
  ) {
    final isSelected = _selectedType == type && _isLoading;

    return GestureDetector(
      onTap: _isLoading ? null : () => _transform(type),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.3) : const Color(0xFF181820),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : color.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
