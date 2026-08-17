import 'package:flutter/material.dart';
import '../models/task.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';

class TaskList extends StatelessWidget {
  final List<Task> tasks;
  final double progress;
  final Function(int) onDelete;
  final Function(int, bool) onToggle;

  const TaskList({
    super.key,
    required this.tasks,
    required this.progress,
    required this.onDelete,
    required this.onToggle,
  });

  // --- Helper: Edit Dialog ---
  void _showEditPlantDialog(BuildContext context, Task plant) {
    TextEditingController nameController = TextEditingController(
      text: plant.name,
    );
    TextEditingController freqController = TextEditingController(
      text: plant.frequencyInDays.toString(),
    );
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Edit ${plant.name}"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Plant Name"),
                autofocus: true,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: freqController,
                decoration: const InputDecoration(
                  labelText: "Water every (days)",
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                taskProvider.editTask(
                  plant.id,
                  nameController.text,
                  int.tryParse(freqController.text) ?? 1,
                );
                Navigator.pop(ctx);
              }
            },
            child: const Text("Save Changes"),
          ),
        ],
      ),
    );
  }

  // --- Helper: Delete Confirmation ---
  void _showDeleteConfirmation(BuildContext context, Task item, int index) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Remove Plant?"),
        content: Text(
          "Are you sure you want to remove ${item.name}? All growth progress will be lost.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              // Uses the standard 'Error' color defined in the theme
              backgroundColor: theme.colorScheme.error,
              foregroundColor: theme.colorScheme.onError,
            ),
            onPressed: () {
              onDelete(index);
              Navigator.pop(ctx);
            },
            child: const Text("Remove"),
          ),
        ],
      ),
    );
  }

  // --- Helper: The Leading Emoji ---
  // Added BuildContext here so we can access the theme
  Widget _buildLeadingIcon(BuildContext context, Task item) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        // Uses the seed color (Green) at low opacity
        color: theme.colorScheme.primary.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Text(item.emoji, style: const TextStyle(fontSize: 24)),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Access the global theme once at the top of build
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("🌱", style: TextStyle(fontSize: 80)),
            const SizedBox(height: 20),
            const Text(
              "Your garden is empty!",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              "Tap 'New Task' to add a plant.\nTap the 💧 to water them and watch them grow!",
              textAlign: TextAlign.center,
              // Uses the theme's secondary text color
              style: TextStyle(color: theme.hintColor, height: 1.5),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // --- Progress Section ---
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: colorScheme.primaryContainer.withValues(
              alpha: 0.3,
            ),
            valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
            minHeight: 8,
            borderRadius: BorderRadius.circular(10),
          ),
        ),

        // --- List Section ---
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: tasks.length,
            itemBuilder: (ctx, index) {
              final item = tasks[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                // Note: Background and shape are handled by CardTheme in main.dart
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      // 1. LEFT: Plant Identity
                      _buildLeadingIcon(context, item),

                      const SizedBox(width: 16),

                      // 2. MIDDLE: Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              item.name,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                decoration: item.isDone
                                    ? TextDecoration.lineThrough
                                    : null,
                                // Uses theme colors instead of black/grey
                                color: item.isDone
                                    ? theme.disabledColor
                                    : colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              "Water every ${item.frequencyInDays} days",
                              style: TextStyle(
                                fontSize: 13,
                                color: theme.hintColor,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // 3. RIGHT: Action Buttons
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // WATERING BUTTON
                          GestureDetector(
                            onTap: item.isDone
                                ? null
                                : () {
                                    onToggle(index, true);
                                    ScaffoldMessenger.of(
                                      context,
                                    ).hideCurrentSnackBar();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          "Watered ${item.name}! 🌱",
                                          style: TextStyle(
                                            color: theme
                                                .colorScheme
                                                .onSurfaceVariant,
                                          ),
                                        ),
                                        duration: const Duration(seconds: 3),
                                        behavior: SnackBarBehavior
                                            .floating, // Makes it hover instead of sticking to bottom
                                        // This allows the user to flick it off the screen to the left or right
                                        dismissDirection:
                                            DismissDirection.horizontal,

                                        margin: const EdgeInsets.only(
                                          bottom: 90,
                                          left: 20,
                                          right: 20,
                                        ),

                                        backgroundColor: theme
                                            .colorScheme
                                            .surfaceContainerHighest,

                                        persist: false,
                                        action: SnackBarAction(
                                          label: "UNDO",
                                          textColor: theme.colorScheme.primary,
                                          onPressed: () {
                                            final p = Provider.of<TaskProvider>(
                                              context,
                                              listen: false,
                                            );
                                            p.undoWatering(item.id);
                                          },
                                        ),
                                      ),
                                    );
                                  },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                // 1. Thirsty = Blue (Secondary), Watered = Green (Tertiary/Success)
                                color: item.isDone
                                    ? colorScheme
                                          .tertiaryContainer // This will be a light green (Success)
                                    : colorScheme
                                          .secondaryContainer, // This is now our Light Blue
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: item.isDone
                                    ? []
                                    : [
                                        BoxShadow(
                                          color: colorScheme.secondary
                                              .withValues(
                                                alpha: 0.2,
                                              ), // Blue shadow
                                          blurRadius: 8,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                              ),
                              child: Icon(
                                item.isDone
                                    ? Icons.check_circle
                                    : Icons.water_drop,
                                color: item.isDone
                                    ? colorScheme
                                          .onTertiaryContainer // Dark Green icon
                                    : colorScheme
                                          .onSecondaryContainer, // Dark Blue icon
                                size: 32,
                              ),
                            ),
                          ),

                          // TRIPLE DOT MENU
                          PopupMenuButton<String>(
                            icon: Icon(Icons.more_vert, color: theme.hintColor),
                            onSelected: (val) {
                              if (val == 'edit') {
                                _showEditPlantDialog(context, item);
                              }
                              if (val == 'delete') {
                                _showDeleteConfirmation(context, item, index);
                              }
                            },
                            itemBuilder: (ctx) => [
                              const PopupMenuItem(
                                value: 'edit',
                                child: Text("Edit Plant"),
                              ),
                              PopupMenuItem(
                                value: 'delete',
                                child: Text(
                                  "Remove",
                                  style: TextStyle(color: colorScheme.error),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
