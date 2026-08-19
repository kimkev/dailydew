import 'package:my_first_app/providers/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'providers/plant_provider.dart';
import 'services/notification_service.dart';
// Import the screens
import 'screens/onboarding.dart';
import 'screens/home.dart';
import 'screens/settings.dart';

void main() async {
  // Required for async work in main
  WidgetsFlutterBinding.ensureInitialized();

  await NotificationService().init();

  final prefs = await SharedPreferences.getInstance();
  final bool seenOnboarding = prefs.getBool('seenOnboarding') ?? false;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PlantProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: MyApp(seenOnboarding: seenOnboarding),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool seenOnboarding;
  const MyApp({super.key, required this.seenOnboarding});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Plant Tracker',
          themeMode: themeProvider.themeMode,

          // --- LIGHT THEME (Clean & Natural) ---
          theme: ThemeData(
            useMaterial3: true,
            scaffoldBackgroundColor: const Color(0xFFF1E8D8),
            colorScheme:
                ColorScheme.fromSeed(
                  seedColor: Colors.green,
                  surface: const Color(0xFFF7F0E4),
                ).copyWith(
                  secondary: Colors.blue,
                  secondaryContainer: const Color(0xFFD1E4FF),
                  onSecondaryContainer: Colors.blue,
                  tertiary: const Color(0xFFDCEDC8),
                  onTertiary: const Color(0xFFAED581),
                  tertiaryContainer: const Color(
                    0xFFE8F5E9,
                  ), // Light Green success
                  onTertiaryContainer: Colors.green.shade700,
                  outlineVariant: Colors.brown.shade400,
                  surfaceContainerHighest: Colors.white.withValues(alpha: 0.8),
                  onSurfaceVariant: Colors.brown,
                  scrim: Colors.brown.withValues(alpha: 0.1),
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
              backgroundColor: Color(0xFFF1E8D8),
              elevation: 0,
              centerTitle: false,
              titleTextStyle: TextStyle(
                color: Colors.black,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // --- DARK THEME (Midnight Forest) ---
          darkTheme: ThemeData(
            useMaterial3: true,
            colorScheme:
                ColorScheme.fromSeed(
                  seedColor: Colors.green,
                  brightness: Brightness.dark,
                ).copyWith(
                  surface: const Color(0xFF121412), // Deep charcoal green
                  secondary: Colors.blueAccent,
                  secondaryContainer: Colors.blue.shade900,
                  onSecondaryContainer: Colors.blue.shade100,
                  tertiary: const Color(0xFF1B5E20), // Dark Night Grass
                  onTertiary: const Color(0xFF003300),
                  tertiaryContainer: const Color(
                    0xFF004D40,
                  ), // Success background
                  onTertiaryContainer: const Color(
                    0xFFB9F6CA,
                  ), // Vibrant Mint text/icon
                  outlineVariant: Colors.black,
                  surfaceContainerHighest: Colors.black.withValues(alpha: 0.7),
                  onSurfaceVariant:
                      Colors.white, // High contrast for garden tags
                  scrim: Colors.black.withValues(alpha: 0.4),
                ),
            cardTheme: CardThemeData(
              color: const Color(0xFF1E211E), // Slightly lighter than surface
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
                side: const BorderSide(color: Colors.white10),
              ),
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF121412),
              elevation: 0,
              centerTitle: false,
              titleTextStyle: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
              iconTheme: IconThemeData(color: Colors.white),
            ),
          ),

          initialRoute: seenOnboarding ? '/home' : '/',
          routes: {
            '/': (context) => const OnboardingScreen(),
            '/home': (context) => const HomeScreen(),
            '/settings': (context) => const SettingsScreen(),
          },
        );
      },
    );
  }
}
