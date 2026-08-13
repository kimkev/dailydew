import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.psychology_alt, size: 100, color: Colors.green),
              const SizedBox(height: 40),
              const Text(
                'Master Your Routine',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              const Text(
                'Track your daily habits and grow your virtual garden.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 50),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: () async {
                  // 1. Get the storage instance
                  final prefs = await SharedPreferences.getInstance();
                  // 2. Set the flag to true
                  await prefs.setBool('seenOnboarding', true);

                  // 3. Go to home (using 'if (context.mounted)' is a Flutter best practice for async)
                  if (context.mounted) {
                    Navigator.pushReplacementNamed(context, '/home');
                  }
                },
                child: const Text('Get Started'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
