import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'services/language_service.dart';
import 'screens/language_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'AIzaSyCPXKF4EkT7MtL2gA-3JvCmyNs5RniYu3k',
      appId: '1:841807553459:android:dfa631dff2e162e64a21c6',
      messagingSenderId: '841807553459',
      projectId: 'toxic-ai-app-786ee',
      storageBucket: 'toxic-ai-app-786ee.firebasestorage.app',
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Toxicity Check',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFB26BFF),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLanguage();
  }

  Future<void> _checkLanguage() async {
    final hasLanguage = await LanguageService.hasLanguage();

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              hasLanguage ? const HomeScreen() : const LanguageScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF0F0F14),
      body: Center(
        child: Text('☠️', style: TextStyle(fontSize: 64)),
      ),
    );
  }
}
