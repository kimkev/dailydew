import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// models
import '../models/task.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // 1. Start with an empty list (Instead of hardcoding a task here)
  List<Task> tasks = [];

  // 2. This is your 'useEffect' - it runs once when the screen opens
  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  // 3. LOAD: Get data from phone memory
  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final String? tasksString = prefs.getString('saved_tasks');

    if (tasksString != null) {
      setState(() {
        // Use the decoder we built in task.dart
        tasks = Task.decode(tasksString);
      });
    } else {
      // Optional: If first time opening app, add a welcome task
      setState(() {
        tasks = [
          Task(
            id: '1',
            name: 'Welcome! Swipe left to delete.',
            category: 'General',
            frequencyInDays: 1,
            lastCompleted: DateTime.now(), // Sets the date to right now
          ),
        ];
      });
    }
  }

  // 4. SAVE: Write data to phone memory
  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    // Use the encoder we built in task.dart
    final String encodedData = Task.encode(tasks);
    await prefs.setString('saved_tasks', encodedData);
  }

  void _showAddTaskDialog() {
    TextEditingController nameController = TextEditingController();
    TextEditingController freqController = TextEditingController(text: "1");
    String selectedCategory = 'Plant';

    showDialog(
      context: context,
      builder: (context) {
        // 1. You MUST have this line here:
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Add New Item'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: "Name"),
                      autofocus: true,
                    ),
                    const SizedBox(height: 15),
                    DropdownButton<String>(
                      value: selectedCategory,
                      isExpanded: true,
                      items: <String>['Plant', 'Health', 'Home', 'General'].map(
                        (String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        },
                      ).toList(),
                      onChanged: (newValue) {
                        // 2. This call ONLY works because of 'setDialogState' above
                        setDialogState(() {
                          selectedCategory = newValue!;
                        });
                      },
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: freqController,
                      decoration: const InputDecoration(
                        labelText: "Repeat every (days)",
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (nameController.text.isNotEmpty) {
                      // This 'setState' updates the main background screen
                      setState(() {
                        tasks.add(
                          Task(
                            id: DateTime.now().toString(),
                            name: nameController.text,
                            category: selectedCategory,
                            frequencyInDays:
                                int.tryParse(freqController.text) ?? 1,
                            lastCompleted: DateTime.now(),
                          ),
                        );
                      });
                      _saveTasks();
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        ); // <--- Close StatefulBuilder
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    int completedCount = tasks.where((t) => t.isDone).length;
    double progress = tasks.isEmpty ? 0 : completedCount / tasks.length;

    return Scaffold(
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
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Theme.of(
                context,
              ).colorScheme.primaryContainer.withOpacity(0.3),
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.primary,
              ),
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
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Dismissible(
                    key: Key(item.id),
                    direction: DismissDirection.endToStart,
                    onDismissed: (direction) {
                      setState(() {
                        tasks.removeAt(index);
                      });
                      _saveTasks(); // <--- SYNC TO STORAGE
                    },
                    background: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Icon(
                        Icons.delete,
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                    child: ListTile(
                      title: Text(
                        item.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold, // Make it pop
                          decoration: item.isDone
                              ? TextDecoration.lineThrough
                              : null,
                          color: item.isDone
                              ? Theme.of(context).colorScheme.outline
                              : Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      // --- ADD THE SUBTITLE HERE ---
                      subtitle: Row(
                        children: [
                          // Shows the Category (e.g., Plant)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(
                              item.category,
                              style: TextStyle(
                                fontSize: 10,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onPrimaryContainer,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          // Shows the Frequency
                          Text(
                            "Every ${item.frequencyInDays} days",
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                      leading: SizedBox(
                        width: 40, // Give it a set width so it stays aligned
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // 1. THE DYNAMIC EMOJI
                            Text(
                              item.growthLevel < 30
                                  ? '🌱'
                                  : item.growthLevel < 70
                                  ? '🌿'
                                  : '🌳',
                              style: const TextStyle(fontSize: 18),
                            ),

                            // 2. THE CHECKBOX (Your existing logic moved here)
                            SizedBox(
                              height: 24, // Keep it compact
                              child: Checkbox(
                                value: item.isDone,
                                activeColor: Theme.of(
                                  context,
                                ).colorScheme.primary,
                                onChanged: (val) {
                                  setState(() {
                                    item.isDone = val!;
                                    if (item.isDone) {
                                      item.growthLevel += 10;
                                      // item.totalCompletions += 1; // Ensure this is in your task.dart!

                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            "${item.name} grew a bit! 🌱",
                                          ),
                                          duration: const Duration(seconds: 1),
                                        ),
                                      );
                                    }
                                  });
                                  _saveTasks();
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddTaskDialog,
        icon: const Icon(Icons.add),
        label: const Text("New Task"),
      ),
    );
  }
}
