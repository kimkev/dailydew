import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../providers/plant_provider.dart';
import '../providers/theme_provider.dart';
import '../services/notification_service.dart';
import '../screens/achievements_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  TimeOfDay _reminderTime = const TimeOfDay(hour: 9, minute: 0);
  String _userName = "Gardener";
  bool _notificationsEnabled = true;
  bool _soundsEnabled = true;

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
      _notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
      _soundsEnabled = prefs.getBool('soundsEnabled') ?? true;
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
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
            ),
            onPressed: () async {
              String newName = nameController.text.trim();
              if (newName.isNotEmpty) {
                Provider.of<TaskProvider>(
                  context,
                  listen: false,
                ).updateUserName(newName);
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

    if (picked == null || picked == _reminderTime) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('reminderHour', picked.hour);
    await prefs.setInt('reminderMinute', picked.minute);

    if (!mounted) return;

    setState(() => _reminderTime = picked);

    final taskProvider = Provider.of<TaskProvider>(context, listen: false);

    final thirstyPlantNames = taskProvider.tasks
        .where((plant) => !plant.isDone)
        .map((plant) => plant.name)
        .toList();

    if (_notificationsEnabled && thirstyPlantNames.isNotEmpty) {
      await NotificationService().scheduleReminderForCurrentlyThirstyPlants(
        plantNames: thirstyPlantNames,
      );
    }

    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Reminder time updated!')));
  }

  Future<void> _toggleNotifications(bool value) async {
    setState(() => _notificationsEnabled = value);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notificationsEnabled', value);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(value ? "Reminders enabled" : "Reminders disabled"),
          duration: const Duration(seconds: 1),
        ),
      );
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

          // Notification Toggle Switch
          SwitchListTile(
            secondary: Icon(
              Icons.notifications_active,
              color: colorScheme.primary,
            ),
            title: const Text("Enable Reminders"),
            value: _notificationsEnabled,
            onChanged: _toggleNotifications,
          ),

          // Reminder Time (now just for editing the time)
          ListTile(
            leading: Icon(Icons.access_time, color: colorScheme.primary),
            title: const Text('Reminder Time'),
            subtitle: Text(
              'Daily at ${_reminderTime.format(context)}',
              style: TextStyle(color: theme.hintColor),
            ),
            trailing: Icon(Icons.chevron_right, color: theme.hintColor),
            onTap: _editTime,
          ),

          SwitchListTile(
            secondary: Icon(Icons.volume_up, color: colorScheme.primary),
            title: const Text("Garden Sounds"),
            value: _soundsEnabled,
            onChanged: (value) async {
              setState(() => _soundsEnabled = value);

              final prefs = await SharedPreferences.getInstance();
              await prefs.setBool('soundsEnabled', value);
            },
          ),

          ListTile(
            leading: Icon(
              Icons.emoji_events_outlined,
              color: colorScheme.primary,
            ),
            title: const Text('Achievements'),
            subtitle: const Text('Celebrate your garden milestones'),
            trailing: Icon(Icons.chevron_right, color: theme.hintColor),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AchievementsScreen()),
              );
            },
          ),

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

          const Divider(),

          // 4. Upgrade to Pro
          ListTile(
            leading: const Icon(
              Icons.star,
              color: Colors.orange,
            ), // Kept as brand color
            title: const Text('Upgrade to Pro'),
            subtitle: Text(
              'Coming soon',
              style: TextStyle(color: theme.hintColor),
            ),
            onTap: null, // Disabled until Pro features are implemented
          ),
          const Divider(height: 1),

          const Divider(height: 1),

          // === ABOUT SECTION ===
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Text(
              "ABOUT",
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                letterSpacing: 0.8,
              ),
            ),
          ),

          ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 0,
            ),
            leading: const Icon(Icons.info_outline, size: 20),
            title: const Text('Version 1.0.0', style: TextStyle(fontSize: 14)),
            visualDensity: VisualDensity.compact,
          ),

          ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 0,
            ),
            leading: const Icon(Icons.person_outline, size: 20),
            title: const Text(
              'Developed by Kevin Kim',
              style: TextStyle(fontSize: 14),
            ),
            visualDensity: VisualDensity.compact,
          ),

          ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 0,
            ),
            leading: const Icon(Icons.description_outlined, size: 20),
            title: const Text('Privacy Policy', style: TextStyle(fontSize: 14)),
            trailing: const Icon(Icons.open_in_new, size: 16),
            visualDensity: VisualDensity.compact,
            onTap: () async {
              final url = Uri.parse(
                'https://kimkev.github.io/privacypolicies/privacy-PlantSip.html',
              );

              final launched = await launchUrl(
                url,
                mode: LaunchMode.externalApplication,
              );

              if (!launched && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Could not open the Privacy Policy.'),
                  ),
                );
              }
            },
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
