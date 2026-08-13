import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'providers/task_provider.dart';
// Import the screens
import 'screens/onboarding.dart';
import 'screens/home.dart';
import 'screens/settings.dart';

void main() async {
  // This line is REQUIRED if you do any async work in main()
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final bool seenOnboarding = prefs.getBool('seenOnboarding') ?? false;
  runApp(
    ChangeNotifierProvider(
      create: (context) => TaskProvider(),
      child: MyApp(seenOnboarding: seenOnboarding),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool seenOnboarding;

  const MyApp({super.key, required this.seenOnboarding});

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

      // If they've seen onboarding, start at /home, otherwise start at /
      initialRoute: seenOnboarding ? '/home' : '/',
      routes: {
        '/': (context) => const OnboardingScreen(),
        '/home': (context) => const HomeScreen(),
        '/settings': (context) => const SettingsScreen(), // Add this line
      },
    );
  }
}
