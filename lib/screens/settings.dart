import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.green,
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.palette),
            title: const Text('Theme'),
            subtitle: const Text('Light / Dark Mode'),
            onTap: () => print('Theme tapped'),
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Notifications'),
            subtitle: const Text('Manage reminders'),
            onTap: () => print('Notifications tapped'),
          ),
          const Divider(), // Adds a horizontal line
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