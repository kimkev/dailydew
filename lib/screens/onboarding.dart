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

  Future<void> _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seenOnboarding', true);
    await prefs.setString('userName', _nameController.text);

    // Save the reminder time as well
    await prefs.setInt('reminderHour', _selectedTime.hour);
    await prefs.setInt('reminderMinute', _selectedTime.minute);

    if (mounted) {
      // THE NUCLEAR OPTION:
      // This says: "Go to /home, and REMOVE every single screen that was there before."
      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
    }
  }

  // Clean up the controller when the screen is destroyed
  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
                icon: Icons.psychology_alt,
                title: "Master Your Routine",
                description:
                    "Science shows that tracking habits helps you stick to them.",
                color: Colors.green,
              ),
              // Page 2: NAME INPUT (This is the new part)
              Padding(
                padding: const EdgeInsets.all(40.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.badge_outlined,
                      size: 100,
                      color: Colors.lightGreen,
                    ),
                    const SizedBox(height: 40),
                    const Text(
                      "What's your name?",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller:
                          _nameController, // This links to your variable above
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 20),
                      decoration: InputDecoration(
                        hintText: "Enter your name",
                        filled: true,
                        fillColor: Colors.grey.shade100,
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
                  mainAxisAlignment:
                      MainAxisAlignment.center, // Keeps it centered vertically
                  children: [
                    const Icon(
                      Icons.notifications_active_outlined,
                      size: 100,
                      color: Colors.orange,
                    ),
                    const SizedBox(height: 30),
                    const Text(
                      "Stay Notified",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      "We'll send gentle reminders so your plants never go thirsty.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 40),

                    // 1. WHAT TIME QUESTION FIRST
                    const Text(
                      "What time works best for you?",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: _pickTime,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.orange.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.access_time,
                              color: Colors.orange,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              _selectedTime.format(context),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // 2. ENHANCED ENABLE BUTTON
                    SizedBox(
                      width: double.infinity, // Makes it a nice wide button
                      child: ElevatedButton.icon(
                        onPressed: _remindersEnabled
                            ? null // Disables the button if already enabled
                            : () async {
                                await NotificationService()
                                    .requestPermissions();
                                await NotificationService().showInstantNotification(
                                  id: 1,
                                  title: "Reminders Enabled! 🎉",
                                  body:
                                      "We'll remind you at ${_selectedTime.format(context)}",
                                );
                                setState(() {
                                  _remindersEnabled = true;
                                });
                              },
                        icon: Icon(
                          _remindersEnabled
                              ? Icons.check_circle
                              : Icons.notifications_active,
                        ),
                        label: Text(
                          _remindersEnabled
                              ? "Reminders Ready!"
                              : "Enable Reminders",
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _remindersEnabled
                              ? Colors.green.shade100
                              : Colors.orange,
                          foregroundColor: _remindersEnabled
                              ? Colors.green
                              : Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Bottom Navigation Area
          Positioned(
            bottom: 50,
            left: 30,
            right: 30,
            child: Column(
              children: [
                // Page Indicators (Dots)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (index) => _buildDot(index)),
                ),
                const SizedBox(height: 30),

                // Button
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 55),
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  onPressed: () {
                    // --- NEW VALIDATION CHECK ---
                    // If we are on the Name Page (index 1) and the text is empty...
                    if (_currentPage == 1 &&
                        _nameController.text.trim().isEmpty) {
                      // Show a little warning message
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter your name to continue!'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                      return; // This "return" stops the function so we don't go to the next page
                    }

                    // --- EXISTING NAVIGATION LOGIC ---
                    if (_currentPage < 2) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeIn,
                      );
                    } else {
                      _finishOnboarding();
                    }
                  },
                  child: Text(_currentPage == 2 ? "Get Started" : "Next"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 120, color: color),
          const SizedBox(height: 40),
          Text(
            title,
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(right: 8),
      height: 8,
      width: _currentPage == index ? 24 : 8,
      decoration: BoxDecoration(
        color: _currentPage == index ? Colors.green : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
