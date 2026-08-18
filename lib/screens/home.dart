import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// widgets
import '../widgets/garden_view.dart';
import '../widgets/plant_list.dart';
// models
import '../models/plant.dart';
// providers
import '../providers/plant_provider.dart';

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
    String selectedAgeOption = 'new';

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
                          value: 'Vegetable',
                          child: Text('Vegetable 🥬'),
                        ),
                        DropdownMenuItem(value: 'Herb', child: Text('Herb 🌿')),
                        DropdownMenuItem(
                          value: 'Succulent',
                          child: Text('Succulent 🌵'),
                        ),
                        DropdownMenuItem(
                          value: 'Other',
                          child: Text('Other 🌱'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value == null) return;

                        setDialogState(() {
                          selectedPlantType = value;
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    DropdownButtonFormField<String>(
                      initialValue: selectedAgeOption,
                      decoration: const InputDecoration(labelText: 'Plant Age'),
                      items: const [
                        DropdownMenuItem(
                          value: 'new',
                          child: Text('🌱 New plant (seed/seedling)'),
                        ),
                        DropdownMenuItem(
                          value: 'weeks',
                          child: Text('🌿 Few weeks old'),
                        ),
                        DropdownMenuItem(
                          value: 'months',
                          child: Text('🪴 Few months old'),
                        ),
                        DropdownMenuItem(
                          value: 'years',
                          child: Text('🌳 Mature plant'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value == null) return;
                        setDialogState(() {
                          selectedAgeOption = value;
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
                  onPressed: () async {
                    final name = nameController.text.trim();
                    final frequency = int.tryParse(freqController.text) ?? 1;

                    if (name.isEmpty) {
                      return;
                    }
                    int startingGrowth = 0;
                    switch (selectedAgeOption) {
                      case 'weeks':
                        startingGrowth = 20; // 20% grown
                        break;
                      case 'months':
                        startingGrowth = 50; // 50% grown
                        break;
                      case 'years':
                        startingGrowth = 80; // 80% grown (mature)
                        break;
                      default:
                        startingGrowth = 0; // New plant
                    }

                    // Calculate dateAdded based on age
                    DateTime dateAdded;
                    switch (selectedAgeOption) {
                      case 'weeks':
                        dateAdded = DateTime.now().subtract(
                          const Duration(days: 21),
                        );
                        break;
                      case 'months':
                        dateAdded = DateTime.now().subtract(
                          const Duration(days: 90),
                        );
                        break;
                      case 'years':
                        dateAdded = DateTime.now().subtract(
                          const Duration(days: 365),
                        );
                        break;
                      default:
                        dateAdded = DateTime.now();
                    }

                    // Calculate position: 3 columns, auto-place from top to bottom
                    final existingTasks = taskProvider.tasks;
                    // 3 columns × 3 rows.
                    // The bottom-right corner is intentionally left open for the pond.
                    const xPositions = [0.22, 0.50, 0.76];
                    const yPositions = [0.20, 0.43, 0.68];

                    // Nine normal slots, except index 8: lower-right pond space.
                    const usableSlots = [
                      0, // top-left
                      1, // top-center
                      2, // top-right
                      3, // middle-left
                      4, // middle-center
                      5, // middle-right
                      6, // bottom-left
                      7, // bottom-center
                    ];

                    final plantNumber = existingTasks.length;
                    final slot = usableSlots[plantNumber % usableSlots.length];

                    final column = slot % 3;
                    final row = slot ~/ 3;

                    final nextX = xPositions[column];
                    final nextY = yPositions[row];

                    await taskProvider.addTask(
                      Task(
                        id: DateTime.now().toString(),
                        name: name,
                        category: selectedPlantType,
                        frequencyInDays: frequency,
                        lastCompleted: DateTime.now(),
                        growthLevel: startingGrowth,
                        dateAdded: dateAdded,
                        positionX: nextX.clamp(0.1, 0.9),
                        positionY: nextY.clamp(0.1, 0.9),
                      ),
                    );

                    if (dialogContext.mounted) {
                      Navigator.pop(dialogContext);
                    }
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
              onPressed: () async {
                // Track which plants we're about to water
                final thirstyPlantIds = taskProvider.tasks
                    .where((t) => !t.isDone)
                    .map((t) => t.id)
                    .toList();

                final thirstyCount = thirstyPlantIds.length;

                // Water all thirsty plants
                await taskProvider.waterAll();

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
