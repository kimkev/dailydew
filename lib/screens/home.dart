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
        tasks = [Task(id: '1', name: 'Welcome! Swipe left to delete me.')];
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
    TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Task'),
          content: TextField(controller: controller, autofocus: true),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  setState(() {
                    tasks.add(Task(id: DateTime.now().toString(), name: controller.text));
                  });
                  _saveTasks(); // <--- SYNC TO STORAGE
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
                      child: Icon(Icons.delete, color: Theme.of(context).colorScheme.error),
                    ),
                    child: ListTile(
                      title: Text(
                        item.name,
                        style: TextStyle(
                          decoration: item.isDone ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      leading: Checkbox(
                        value: item.isDone,
                        onChanged: (val) {
                          setState(() {
                            item.isDone = val!;
                          });
                          _saveTasks(); // <--- SYNC TO STORAGE
                        },
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