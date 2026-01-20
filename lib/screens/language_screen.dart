import 'package:flutter/material.dart';
import '../services/language_service.dart';
import 'home_screen.dart';

class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

  void _selectLanguage(BuildContext context, String language) async {
    await LanguageService.setLanguage(language);
    if (context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F14),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('☠️', style: TextStyle(fontSize: 80)),
                const SizedBox(height: 24),
                const Text(
                  'AI Toxicity Check',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 48),
                const Text(
                  'Select your language',
                  style: TextStyle(
                    fontSize: 18,
                    color: Color(0xFFA1A1AA),
                  ),
                ),
                const Text(
                  'Dilinizi seçin',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFFA1A1AA),
                  ),
                ),
                const SizedBox(height: 40),

                // English Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _selectLanguage(context, 'en'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFB26BFF),
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('🇬🇧', style: TextStyle(fontSize: 24)),
                        SizedBox(width: 12),
                        Text(
                          'English',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Turkish Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _selectLanguage(context, 'tr'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF181820),
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                        side: const BorderSide(
                          color: Color(0xFFB26BFF),
                          width: 2,
                        ),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('🇹🇷', style: TextStyle(fontSize: 24)),
                        SizedBox(width: 12),
                        Text(
                          'Türkçe',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
