import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// widgets
import '../widgets/garden_view.dart';
import '../widgets/task_list.dart';
// models
import '../models/task.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
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

      // The "Single Widget" in the body is now a switcher
      body: _selectedIndex == 0
          ? TaskList(
              tasks: tasks,
              progress: progress,
              // Handle the deletion logic here in the Boss file
              onDelete: (index) {
                setState(() {
                  tasks.removeAt(index);
                });
                _saveTasks();
              },
              // Handle the checkmark/growth logic here
              onToggle: (index, isChecked) {
                setState(() {
                  tasks[index].isDone = isChecked;
                  if (isChecked) {
                    tasks[index].growthLevel += 10;
                    tasks[index].totalCompletions += 1;

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("${tasks[index].name} grew! 🌱"),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  }
                });
                _saveTasks();
              },
            )
          : GardenView(tasks: tasks),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.check_circle_outline),
            label: 'Tasks',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.yard_outlined),
            label: 'Garden',
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
