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

  void _showAddPlantDialog() {
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
    final taskProvider = Provider.of<TaskProvider>(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Calculate progress using data from the provider
    int completedCount = taskProvider.tasks.where((t) => t.isDone).length;
    double progress = taskProvider.tasks.isEmpty
        ? 0
        : completedCount / taskProvider.tasks.length;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Hi, ${taskProvider.userName}! 🌱'),
        actions: [
          // Water All Button
          if (taskProvider.tasks.any((t) => !t.isDone))
            TextButton.icon(
              onPressed: () {
                // Track which plants we're about to water
                final thirstyPlantIds = taskProvider.tasks
                    .where((t) => !t.isDone)
                    .map((t) => t.id)
                    .toList();

                final thirstyCount = thirstyPlantIds.length;

                // Water all thirsty plants
                for (int i = 0; i < taskProvider.tasks.length; i++) {
                  if (!taskProvider.tasks[i].isDone) {
                    taskProvider.toggleTask(i);
                  }
                }

                // Show confirmation with undo
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      "Watered all $thirstyCount plants! 💧",
                      style: TextStyle(color: colorScheme.onSurfaceVariant),
                    ),
                    duration: const Duration(seconds: 3),
                    behavior: SnackBarBehavior.floating,
                    dismissDirection: DismissDirection.horizontal,
                    margin: const EdgeInsets.only(
                      bottom: 90,
                      left: 20,
                      right: 20,
                    ),
                    backgroundColor: colorScheme.surfaceContainerHighest,
                    persist: false,
                    action: SnackBarAction(
                      label: "UNDO",
                      textColor: colorScheme.primary,
                      onPressed: () {
                        // Undo watering for all the plants we just watered
                        final p = Provider.of<TaskProvider>(
                          context,
                          listen: false,
                        );
                        for (var taskId in thirstyPlantIds) {
                          p.undoWatering(taskId);
                        }
                      },
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.water_drop, size: 20),
              label: const Text('Water All'),
              style: TextButton.styleFrom(
                foregroundColor: colorScheme.onSecondaryContainer,
                backgroundColor: colorScheme.secondaryContainer,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),

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
            label: 'Plants',
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
              onPressed: _showAddPlantDialog,
              icon: const Icon(Icons.add),
              label: const Text("Add Plant"),
            )
          : null, // Hide it completely on other tabs
    );
  }
}
