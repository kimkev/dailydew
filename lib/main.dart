import 'package:flutter/material.dart';
// Import the screens
import 'screens/onboarding.dart';
import 'screens/home.dart';
import 'screens/settings.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Plant Tracker',

      // --- GLOBAL THEME SETTINGS ---
      theme: ThemeData(
        useMaterial3: true,
        // 1. ColorScheme ends here with a closing parenthesis
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          surface: const Color(0xFFF8F9FA),
        ),

        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: BorderSide(color: Colors.grey.shade200),
          ),
        ),

        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF8F9FA),
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      initialRoute: '/',
      routes: {
        '/': (context) => const OnboardingScreen(),
        '/home': (context) => const HomeScreen(),
        '/settings': (context) => const SettingsScreen(), // Add this line
      },
    );
  }
}
