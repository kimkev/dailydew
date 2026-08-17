import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// widgets
import '../widgets/garden_view.dart';
import '../widgets/task_list.dart';
// models
import '../models/task.dart';
// providers
import '../providers/task_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // We keep this because Tab selection is "UI State," not "Global Data"
  int _selectedIndex = 0;

  void _showAddTaskDialog() {
    final nameController = TextEditingController();
    final freqController = TextEditingController(text: '1');
    String selectedPlantType = 'Flower';

    final taskProvider = Provider.of<TaskProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Add New Plant'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Plant Name',
                        hintText: 'e.g. Monstera',
                      ),
                      autofocus: true,
                    ),
                    const SizedBox(height: 20),
                    DropdownButtonFormField<String>(
                      initialValue: selectedPlantType,
                      decoration: const InputDecoration(
                        labelText: 'Plant Type',
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'Flower',
                          child: Text('Flower 🌸'),
                        ),
                        DropdownMenuItem(
                          value: 'Houseplant',
                          child: Text('Houseplant 🪴'),
                        ),
                        DropdownMenuItem(
                          value: 'Cactus',
                          child: Text('Cactus 🌵'),
                        ),
                        DropdownMenuItem(value: 'Tree', child: Text('Tree 🌳')),
                      ],
                      onChanged: (value) {
                        if (value == null) return;

                        setDialogState(() {
                          selectedPlantType = value;
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: freqController,
                      decoration: const InputDecoration(
                        labelText: 'Water every (days)',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final name = nameController.text.trim();
                    final frequency = int.tryParse(freqController.text) ?? 1;

                    if (name.isEmpty) {
                      return;
                    }

                    taskProvider.addTask(
                      Task(
                        id: DateTime.now().toString(),
                        name: name,
                        category: selectedPlantType,
                        frequencyInDays: frequency,
                        lastCompleted: DateTime.now(),
                      ),
                    );

                    Navigator.pop(dialogContext);
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // This is like 'useContext' in React.
    // It tells this widget: "Watch the TaskProvider. If it changes, rebuild this screen."
    final taskProvider = Provider.of<TaskProvider>(context);

    // Calculate progress using data from the provider
    int completedCount = taskProvider.tasks.where((t) => t.isDone).length;
    double progress = taskProvider.tasks.isEmpty
        ? 0
        : completedCount / taskProvider.tasks.length;

    return Scaffold(
      appBar: AppBar(
        title: Text('Hi, ${taskProvider.userName}! 🌱'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
        ],
      ),

      body: _selectedIndex == 0
          ? TaskList(
              tasks: taskProvider.tasks,
              progress: progress,
              onDelete: (index) => taskProvider.deleteTask(index),
              onToggle: (index, isChecked) {
                taskProvider.toggleTask(index);
                if (isChecked) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "${taskProvider.tasks[index].name} grew! 🌱",
                      ),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                }
              },
            )
          : const GardenView(),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
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

      // Only show the button if _selectedIndex is 0 (the Tasks tab)
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton.extended(
              onPressed: _showAddTaskDialog,
              icon: const Icon(Icons.add),
              label: const Text("New Task"),
            )
          : null, // Hide it completely on other tabs
    );
  }
}
