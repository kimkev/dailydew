import 'package:flutter/material.dart';
import 'package:my_first_app/providers/theme_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/task_provider.dart';
import 'package:provider/provider.dart';

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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Reminder time updated!")));
      }
    }
  }

  Future<void> _editName() async {
    TextEditingController nameController = TextEditingController(
      text: _userName,
    );

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Name"),
        content: TextField(
          controller: nameController,
          autofocus: true,
          decoration: const InputDecoration(hintText: "Enter your name"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              String newName = nameController.text.trim();
              if (newName.isNotEmpty) {
                // 1. Update the Global Provider (this handles saving to disk AND notifying Home)
                Provider.of<TaskProvider>(
                  context,
                  listen: false,
                ).updateUserName(newName);

                // 2. Update local state so the settings screen updates immediately
                setState(() {
                  _userName = newName;
                });

                if (mounted) Navigator.pop(context);
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  void _showThemeDialog() {
    // We talk to the ThemeProvider specifically
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Select App Theme"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.settings_suggest),
              title: const Text("System Default"),
              onTap: () {
                themeProvider.updateTheme(ThemeMode.system);
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              leading: const Icon(Icons.light_mode),
              title: const Text("Light Mode"),
              onTap: () {
                themeProvider.updateTheme(ThemeMode.light);
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              leading: const Icon(Icons.dark_mode),
              title: const Text("Dark Mode"),
              onTap: () {
                themeProvider.updateTheme(ThemeMode.dark);
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
      ),
      body: ListView(
        children: [
          // 1. User Name Row
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text("User Name"),
            subtitle: Text(_userName),
            trailing: const Icon(Icons.edit, size: 20),
            onTap: _editName,
          ),

          // 2. notification Time Row
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Daily Reminder Time'),
            subtitle: Text('Reminders at ${_reminderTime.format(context)}'),
            trailing: const Icon(Icons.edit, size: 20),
            onTap: _editTime,
          ),

          const Divider(),

          // 3. Theme Row
          ListTile(
            leading: const Icon(Icons.palette_outlined),
            title: const Text('App Theme'),
            subtitle: Text(
              "Current: ${themeProvider.themeMode.name.toUpperCase()}",
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: _showThemeDialog,
          ),

          // 4.  Reset Row - temp for testing
          ListTile(
            leading: const Icon(Icons.restore),
            title: const Text('Reset App Data'),
            subtitle: const Text('Wipes tasks and onboarding status'),
            onTap: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              if (!context.mounted) return;

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Data Cleared! Restart the app.')),
              );
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
