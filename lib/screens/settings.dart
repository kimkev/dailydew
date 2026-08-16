import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  TimeOfDay _reminderTime = const TimeOfDay(hour: 9, minute: 0);
  String _userName = "Gardener";

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  // Load the current values from SharedPreferences
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('userName') ?? "Gardener";
      final int hour = prefs.getInt('reminderHour') ?? 9;
      final int minute = prefs.getInt('reminderMinute') ?? 0;
      _reminderTime = TimeOfDay(hour: hour, minute: minute);
    });
  }

  // The function to pick and save a new time
  Future<void> _editTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
    );

    if (picked != null && picked != _reminderTime) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('reminderHour', picked.hour);
      await prefs.setInt('reminderMinute', picked.minute);
      
      setState(() {
        _reminderTime = picked;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Reminder time updated!")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white, // Ensures back arrow is visible
      ),
      body: ListView(
        children: [
          // 1. User Name Row
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text("User Name"),
            subtitle: Text(_userName),
          ),
          
          // 2. THE NEW FUNCTIONAL NOTIFICATION ROW
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Daily Reminder Time'),
            subtitle: Text('Reminders at ${_reminderTime.format(context)}'),
            trailing: const Icon(Icons.edit, size: 20),
            onTap: _editTime,
          ),

          const Divider(),

          // 3. Your existing Theme Row
          ListTile(
            leading: const Icon(Icons.palette),
            title: const Text('Theme'),
            subtitle: const Text('Light / Dark Mode'),
            onTap: () => print('Theme tapped'),
          ),

          // 4. Your existing Reset Row
          ListTile(
            leading: const Icon(Icons.restore),
            title: const Text('Reset App Data'),
            subtitle: const Text('Wipes tasks and onboarding status'),
            onTap: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Data Cleared! Restart the app.')),
                );
              }
            },
          ),
          
          const Divider(),

          // 5. Your existing Pro Row
          ListTile(
            leading: const Icon(Icons.star, color: Colors.orange),
            title: const Text('Upgrade to Pro'),
            subtitle: const Text('Unlock all features'),
            onTap: () => print('Pro tapped'),
          ),
        ],
      ),
    );
  }
}