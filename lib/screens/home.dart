import 'package:flutter/material.dart';
import '../models/task.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Task> tasks = [
    Task(id: '1', name: 'Your first task! Swipe it left to clear it.'),
  ];

  void _showAddTaskDialog() {
    TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Task'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: "Enter task name..."),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  setState(() {
                    tasks.add(
                      Task(
                        id: DateTime.now().toString(),
                        name: controller.text,
                      ),
                    );
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Logic for the progress bar (Optional, but makes it less bland!)
    int completedCount = tasks.where((t) => t.isDone).length;
    double progress = tasks.isEmpty ? 0 : completedCount / tasks.length;

    return Scaffold(
      // Background is now automatically handled by main.dart (surface color)
      appBar: AppBar(
        title: const Text('My Daily Routine'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
        ],
      ),
      body: Column(
        children: [
          // --- PROGRESS SECTION (Makes it look premium) ---
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
              valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
              minHeight: 8,
              borderRadius: BorderRadius.circular(10),
            ),
          ),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final item = tasks[index];

                // Wrap in a Card to use the CardThemeData from main.dart
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Dismissible(
                    key: Key(item.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Icon(Icons.delete, color: Theme.of(context).colorScheme.error), 
                    ),
                    onDismissed: (direction) {
                      setState(() {
                        tasks.removeAt(index);
                      });
                    },
                    child: ListTile(
                      title: Text(
                        item.name,
                        style: TextStyle(
                          decoration: item.isDone ? TextDecoration.lineThrough : null,
                          // Use theme colors for text
                          color: item.isDone 
                            ? Theme.of(context).colorScheme.outline 
                            : Theme.of(context).colorScheme.onSurface, 
                        ),
                      ),
                      leading: Checkbox( // Using a Checkbox instead of an Icon feels more modern
                        value: item.isDone,
                        activeColor: Theme.of(context).colorScheme.primary,
                        onChanged: (val) {
                          setState(() {
                            item.isDone = val!;
                          });
                        },
                      ),
                      onTap: () {
                        setState(() {
                          item.isDone = !item.isDone;
                        });
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended( // 'extended' allows for a label
        onPressed: _showAddTaskDialog,
        icon: const Icon(Icons.add),
        label: const Text("New Task"),
      ),
    );
  }
}