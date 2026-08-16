import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../providers/theme_provider.dart';

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

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('userName') ?? "Gardener";
      final int hour = prefs.getInt('reminderHour') ?? 9;
      final int minute = prefs.getInt('reminderMinute') ?? 0;
      _reminderTime = TimeOfDay(hour: hour, minute: minute);
    });
  }

  // --- THEME DIALOG ---
  void _showThemeDialog() {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("App Theme"),
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

  // --- EDIT NAME DIALOG ---
  Future<void> _editName() async {
    final theme = Theme.of(context);
    TextEditingController nameController = TextEditingController(text: _userName);

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
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
            ),
            onPressed: () async {
              String newName = nameController.text.trim();
              if (newName.isNotEmpty) {
                Provider.of<TaskProvider>(context, listen: false).updateUserName(newName);
                setState(() => _userName = newName);
                if (mounted) Navigator.pop(context);
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  // --- EDIT TIME PICKER ---
  Future<void> _editTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
    );

    if (picked != null && picked != _reminderTime) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('reminderHour', picked.hour);
      await prefs.setInt('reminderMinute', picked.minute);

      setState(() => _reminderTime = picked);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Reminder time updated!")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Settings'),
        // Automatically uses AppBarTheme from main.dart
        backgroundColor: theme.appBarTheme.backgroundColor,
        foregroundColor: theme.appBarTheme.titleTextStyle?.color,
      ),
      body: ListView(
        children: [
          // 1. User Name
          ListTile(
            leading: Icon(Icons.person_outline, color: colorScheme.primary),
            title: const Text("User Name"),
            subtitle: Text(_userName, style: TextStyle(color: theme.hintColor)),
            trailing: Icon(Icons.edit, size: 18, color: theme.hintColor),
            onTap: _editName,
          ),

          // 2. Notification Time
          ListTile(
            leading: Icon(Icons.notifications_outlined, color: colorScheme.primary),
            title: const Text('Daily Reminder Time'),
            subtitle: Text(
              'Reminders at ${_reminderTime.format(context)}',
              style: TextStyle(color: theme.hintColor),
            ),
            trailing: Icon(Icons.edit, size: 18, color: theme.hintColor),
            onTap: _editTime,
          ),

          const Divider(),

          // 3. App Theme
          ListTile(
            leading: Icon(Icons.palette_outlined, color: colorScheme.primary),
            title: const Text('App Theme'),
            subtitle: Text(
              "Current: ${themeProvider.themeMode.name.toUpperCase()}",
              style: TextStyle(color: theme.hintColor),
            ),
            trailing: Icon(Icons.chevron_right, color: theme.hintColor),
            onTap: _showThemeDialog,
          ),

          // 4. Reset App Data
          ListTile(
            leading: Icon(Icons.restore, color: colorScheme.error),
            title: const Text('Reset App Data'),
            subtitle: Text(
              'Wipes tasks and onboarding status',
              style: TextStyle(color: theme.hintColor),
            ),
            onTap: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              
              if (!context.mounted) return;

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Data Cleared! Please restart the app.'),
                  backgroundColor: colorScheme.errorContainer,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),

          const Divider(),

          // 5. Upgrade to Pro
          ListTile(
            leading: const Icon(Icons.star, color: Colors.orange), // Kept as brand color
            title: const Text('Upgrade to Pro'),
            subtitle: Text('Unlock all features', style: TextStyle(color: theme.hintColor)),
            onTap: () => print('Pro tapped'),
          ),
        ],
      ),
    );
  }
}