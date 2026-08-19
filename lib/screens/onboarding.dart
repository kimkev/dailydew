import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/notification_service.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  final TextEditingController _nameController = TextEditingController();
  int _currentPage = 0;
  TimeOfDay _selectedTime = const TimeOfDay(hour: 9, minute: 0);
  bool _remindersEnabled = false;
  String? _permissionDeniedMessage;

  void _finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seenOnboarding', true);
    await prefs.setString('userName', _nameController.text);
    await prefs.setInt('reminderHour', _selectedTime.hour);
    await prefs.setInt('reminderMinute', _selectedTime.minute);
    await prefs.setBool('notificationsEnabled', _remindersEnabled);

    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: (int page) {
              setState(() => _currentPage = page);
            },
            children: [
              // Page 1: Intro
              _buildPage(
                context: context,
                icon: Icons.water_drop,
                title: "Your Plant Companion",
                description:
                    "Never forget to water your plants again. Build healthy habits for you and your green friends.",
                iconColor: colorScheme.primary,
              ),

              // Page 2: Name Input
              Padding(
                padding: const EdgeInsets.all(40.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.person_outline,
                      size: 100,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(height: 40),
                    Text(
                      "What's your name?",
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _nameController,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 20),
                      decoration: InputDecoration(
                        hintText: "Enter your name",
                        filled: true,
                        fillColor: colorScheme.surfaceContainerHighest,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Page 3: Notifications
              Padding(
                padding: const EdgeInsets.all(40.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.notifications_active_outlined,
                      size: 100,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(height: 30),
                    Text(
                      "Stay Notified",
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      "We'll send gentle reminders so your plants never go thirsty.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        color: theme.hintColor,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 50),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _remindersEnabled
                            ? _finishOnboarding
                            : () async {
                                // Step 1: Pick time
                                final picked = await showTimePicker(
                                  context: context,
                                  initialTime: _selectedTime,
                                );

                                if (picked == null || !context.mounted) return;

                                final formattedTime = picked.format(context);

                                setState(() {
                                  _selectedTime = picked;
                                });

                                final permissionGranted =
                                    await NotificationService()
                                        .requestPermissions();

                                if (!mounted) return;

                                if (!permissionGranted) {
                                  setState(() {
                                    _permissionDeniedMessage =
                                        'Notifications disabled. You can enable them in settings later.';
                                  });
                                  return;
                                }

                                await NotificationService()
                                    .showInstantNotification(
                                      id: 1,
                                      title: 'Reminders Enabled! 🎉',
                                      body:
                                          "We'll remind you at $formattedTime",
                                    );

                                if (!mounted) return;

                                setState(() {
                                  _remindersEnabled = true;
                                  _permissionDeniedMessage = null;
                                });
                              },

                        icon: Icon(
                          _remindersEnabled
                              ? Icons.check_circle
                              : Icons.access_time,
                        ),
                        label: Text(
                          _remindersEnabled
                              ? 'Get Started'
                              : 'Set Reminder & Continue',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                      ),
                    ),
                    // Skip button - only show if reminders not enabled AND no permission denied
                    if (!_remindersEnabled &&
                        _permissionDeniedMessage == null) ...[
                      const SizedBox(height: 15),
                      TextButton(
                        onPressed: _finishOnboarding,
                        child: Text(
                          'Skip for now',
                          style: TextStyle(
                            color: theme.hintColor,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],

                    // Show message if permission was denied
                    if (_permissionDeniedMessage != null &&
                        !_remindersEnabled) ...[
                      const SizedBox(height: 15),
                      TextButton(
                        onPressed: _finishOnboarding,
                        child: const Text(
                          'Continue Anyway',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _permissionDeniedMessage!,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: theme.hintColor, fontSize: 13),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),

          // Bottom Navigation - Only show on pages 0 and 1
          if (_currentPage < 2)
            Positioned(
              bottom: 50,
              left: 30,
              right: 30,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      3,
                      (index) => _buildDot(index, colorScheme),
                    ),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 55),
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    onPressed: () {
                      if (_currentPage == 1 &&
                          _nameController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Please enter your name to continue!',
                            ),
                          ),
                        );
                        return;
                      }
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeIn,
                      );
                    },
                    child: const Text("Next"),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPage({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String description,
    required Color iconColor,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 120, color: iconColor),
          const SizedBox(height: 40),
          Text(
            title,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: theme.hintColor, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index, ColorScheme colorScheme) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(right: 8),
      height: 8,
      width: _currentPage == index ? 24 : 8,
      decoration: BoxDecoration(
        color: _currentPage == index
            ? colorScheme.primary
            : colorScheme.outlineVariant.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
