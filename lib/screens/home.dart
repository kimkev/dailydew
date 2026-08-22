import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// widgets
import '../widgets/garden_view.dart';
import '../widgets/plant_list.dart';
// models
import '../models/plant.dart';
// providers
import '../providers/plant_provider.dart';
import '../services/sound_service.dart';

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

    final plantProvider = Provider.of<PlantProvider>(context, listen: false);

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
                        startingGrowth = 20;
                        break;
                      case 'months':
                        startingGrowth = 50;
                        break;
                      case 'years':
                        startingGrowth = 80;
                        break;
                      default:
                        startingGrowth = 0;
                    }

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

                    final existingPlants = plantProvider.plants;
                    const xPositions = [0.22, 0.50, 0.76];
                    const yPositions = [
                      0.20,
                      0.32,
                      0.44,
                      0.56,
                      0.68,
                      0.80,
                      0.92,
                      1.04,
                      1.16,
                      1.28,
                    ];

                    final maxSlots = xPositions.length * yPositions.length;
                    final usableSlots = List.generate(maxSlots, (i) => i);
                    final plantNumber = existingPlants.length;
                    final slot = usableSlots[plantNumber % usableSlots.length];
                    final column = slot % 3;
                    final row = slot ~/ 3;
                    final nextX = xPositions[column];
                    final nextY = yPositions[row];

                    // ✅ Pop dialog FIRST, then add plant
                    if (dialogContext.mounted) {
                      Navigator.pop(dialogContext);
                    }

                    await plantProvider.addPlant(
                      Plant(
                        id: DateTime.now().toString(),
                        name: name,
                        category: selectedPlantType,
                        frequencyInDays: frequency,
                        lastCompleted: DateTime.now().subtract(
                          Duration(days: frequency + 1),
                        ),
                        growthLevel: startingGrowth,
                        dateAdded: dateAdded,
                        positionX: nextX.clamp(0.1, 0.9),
                        positionY: nextY.clamp(0.1, 0.9),
                      ),
                    );
                    await SoundService.instance.playPlantAdded();
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
    final plantProvider = Provider.of<PlantProvider>(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final plants = plantProvider.plants;
    final thirstyCount = plants.where(plantProvider.isPlantThirsty).length;
    final completedCount = plants.length - thirstyCount;

    double progress = plants.isEmpty ? 0 : completedCount / plants.length;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Hi, ${plantProvider.userName}! 🌱'),
        actions: [
          // Water All Button
          if (plantProvider.plants.any(plantProvider.isPlantThirsty))
            TextButton.icon(
              onPressed: () async {
                // Water all thirsty plants and get the list of watered plant IDs
                final wateredPlantIds = await plantProvider.waterAll();
                await SoundService.instance.playWaterAll();
                if (!context.mounted) return;

                final thirstyCount = wateredPlantIds.length;

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
                        final p = Provider.of<PlantProvider>(
                          context,
                          listen: false,
                        );
                        for (var plantId in wateredPlantIds) {
                          p.undoPlantWatering(plantId);
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
          ? PlantList(
              plants: plantProvider.plants,
              progress: progress,
              onDelete: (index) => plantProvider.deletePlant(index),
              onToggle: (index, isChecked) {
                plantProvider.togglePlant(index);
                if (isChecked) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "${plantProvider.plants[index].name} grew! 🌱",
                      ),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                }
              },
            )
          : GardenView(),

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

      // Only show the button if _selectedIndex is 0 (the plants tab)
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
