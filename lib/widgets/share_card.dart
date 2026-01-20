import 'package:flutter/material.dart';

class ShareCard extends StatelessWidget {
  final int toxicity;
  final String passiveAggressive;
  final String gaslighting;
  final String comment;
  final String category;
  final String language;

  const ShareCard({
    super.key,
    required this.toxicity,
    required this.passiveAggressive,
    required this.gaslighting,
    required this.comment,
    this.category = '',
    required this.language,
  });

  Color _getToxicityColor() {
    if (toxicity > 70) return const Color(0xFFFF4D6D);
    if (toxicity > 40) return const Color(0xFFFFA07A);
    return const Color(0xFFB26BFF);
  }

  String _getToxicityEmoji() {
    if (toxicity > 80) return '☠️';
    if (toxicity > 60) return '😈';
    if (toxicity > 40) return '😏';
    if (toxicity > 20) return '😊';
    return '😇';
  }

  String _getToxicityTitle() {
    if (language == 'tr') {
      if (toxicity > 80) return 'TOKSİK KRAL/KRALİÇE';
      if (toxicity > 60) return 'ŞEYTAN ÇIRAĞI';
      if (toxicity > 40) return 'ŞÜPHELİ';
      if (toxicity > 20) return 'MASUM';
      return 'MELEK';
    } else {
      if (toxicity > 80) return 'TOXIC KING/QUEEN';
      if (toxicity > 60) return 'DEVIL\'S APPRENTICE';
      if (toxicity > 40) return 'SUSPICIOUS';
      if (toxicity > 20) return 'INNOCENT';
      return 'ANGEL';
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getToxicityColor();

    return Container(
      width: 350,
      height: 620,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF0F0F14),
            const Color(0xFF1a1a2e),
            color.withOpacity(0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withOpacity(0.5), width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '☠️ TOXIC AI',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: color, width: 1),
                  ),
                  child: Text(
                    category.isNotEmpty
                        ? category
                        : (language == 'tr' ? 'ANALİZ' : 'ANALYSIS'),
                    style: TextStyle(
                      color: color,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Big Emoji
            Text(
              _getToxicityEmoji(),
              style: const TextStyle(fontSize: 80),
            ),

            const SizedBox(height: 16),

            // Toxicity Title
            Text(
              _getToxicityTitle(),
              style: TextStyle(
                color: color,
                fontSize: 24,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
              ),
            ),

            const SizedBox(height: 24),

            // Toxicity Percentage with circular indicator
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 140,
                  height: 140,
                  child: CircularProgressIndicator(
                    value: toxicity / 100,
                    strokeWidth: 12,
                    backgroundColor: Colors.white.withOpacity(0.1),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
                Column(
                  children: [
                    Text(
                      '$toxicity%',
                      style: TextStyle(
                        color: color,
                        fontSize: 42,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      language == 'tr' ? 'TOKSİK' : 'TOXIC',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Stats Row
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStat(
                    language == 'tr' ? 'Pasif-Agresif' : 'Passive-Agg.',
                    passiveAggressive,
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: Colors.white.withOpacity(0.2),
                  ),
                  _buildStat(
                    'Gaslighting',
                    gaslighting.contains('DETECTED') ||
                            gaslighting.contains('TESPİT')
                        ? '🚩'
                        : '✅',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Comment
            Expanded(
              child: Center(
                child: Text(
                  '"$comment"',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),

            // Footer
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'toxicai.app',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '•',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.3),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  language == 'tr'
                      ? 'Senin toksisite seviyen ne?'
                      : 'What\'s your toxicity?',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.4),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    Color valueColor = const Color(0xFFB26BFF);
    if (value == 'HIGH' || value == 'YÜKSEK') {
      valueColor = const Color(0xFFFF4D6D);
    } else if (value == 'MEDIUM' || value == 'ORTA') {
      valueColor = const Color(0xFFFFA07A);
    }

    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.5),
            fontSize: 10,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
