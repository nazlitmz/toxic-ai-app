import 'package:flutter/material.dart';
import '../widgets/share_card.dart';
import '../services/share_service.dart';
import '../services/app_localizations.dart';

class ShareCardScreen extends StatefulWidget {
  final int toxicity;
  final String passiveAggressive;
  final String gaslighting;
  final String comment;
  final String category;
  final String language;

  const ShareCardScreen({
    super.key,
    required this.toxicity,
    required this.passiveAggressive,
    required this.gaslighting,
    required this.comment,
    this.category = '',
    required this.language,
  });

  @override
  State<ShareCardScreen> createState() => _ShareCardScreenState();
}

class _ShareCardScreenState extends State<ShareCardScreen> {
  final GlobalKey _cardKey = GlobalKey();
  bool _isSaving = false;
  bool _isSharing = false;

  String _t(String key) => AppLocalizations.get(key, widget.language);

  Future<void> _shareCard() async {
    setState(() => _isSharing = true);

    // Kısa bir gecikme ekle ki widget renderlanabilsin
    await Future.delayed(const Duration(milliseconds: 100));

    await ShareService.shareFromKey(_cardKey);

    if (mounted) {
      setState(() => _isSharing = false);
    }
  }

  Future<void> _saveToGallery() async {
    setState(() => _isSaving = true);

    await Future.delayed(const Duration(milliseconds: 100));

    final success = await ShareService.saveToGalleryFromKey(_cardKey);

    if (mounted) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success ? _t('saved_to_gallery') : _t('save_failed'),
          ),
          backgroundColor: success ? const Color(0xFFB26BFF) : Colors.red,
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
          _t('share_card'),
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: RepaintBoundary(
                    key: _cardKey,
                    child: ShareCard(
                      toxicity: widget.toxicity,
                      passiveAggressive: widget.passiveAggressive,
                      gaslighting: widget.gaslighting,
                      comment: widget.comment,
                      category: widget.category,
                      language: widget.language,
                    ),
                  ),
                ),
              ),
            ),

            // Bottom Buttons
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Color(0xFF181820),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  // Share Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isSharing ? null : _shareCard,
                      icon: _isSharing
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.share, color: Colors.white),
                      label: Text(
                        _isSharing
                            ? _t('preparing')
                            : _t('share_instagram_tiktok'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
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

                  const SizedBox(height: 12),

                  // Save to Gallery Button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _isSaving ? null : _saveToGallery,
                      icon: _isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Color(0xFFB26BFF),
                              ),
                            )
                          : const Icon(Icons.download,
                              color: Color(0xFFB26BFF)),
                      label: Text(
                        _isSaving ? _t('saving') : _t('save_to_gallery'),
                        style: const TextStyle(
                          color: Color(0xFFB26BFF),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                        side: const BorderSide(
                            color: Color(0xFFB26BFF), width: 2),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  Text(
                    _t('share_tip'),
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
