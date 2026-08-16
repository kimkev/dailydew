import 'package:flutter/material.dart';
import '../models/task.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';

class TaskList extends StatelessWidget {
  final List<Task> tasks;
  final double progress;
  final Function(int) onDelete; // Callback for deletion
  final Function(int, bool) onToggle; // Callback for checkmark

  const TaskList({
    super.key,
    required this.tasks,
    required this.progress,
    required this.onDelete,
    required this.onToggle,
  });

  void _showEditPlantDialog(BuildContext context, Task plant) {
    // 1. Pre-fill the controllers with the current values
    TextEditingController nameController = TextEditingController(
      text: plant.name,
    );
    TextEditingController freqController = TextEditingController(
      text: plant.frequencyInDays.toString(),
    );

    // 2. Get the provider (listen: false because we are just calling a function)
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

  // --- Helper: Show Confirmation Dialog ---
  void _showDeleteConfirmation(BuildContext context, Task item, int index) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Remove Plant?"),
        content: Text(
          "Are you sure you want to remove ${item.name} from your garden? All its growth progress will be lost.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx), // Close dialog
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade400,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              onDelete(index); // Call the delete function
              Navigator.pop(ctx); // Close dialog
            },
            child: const Text("Remove"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 1. Check if there are no tasks
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
              "Tap 'New Task' to add your first plant.",
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    // 2. If there ARE tasks, show the existing list
    return Column(
      children: [
        // --- Progress Section ---
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Theme.of(
              context,
            ).colorScheme.primaryContainer.withValues(alpha: 0.3),
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).colorScheme.primary,
            ),
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
                child: ListTile(
                  leading: _buildLeadingIcon(context, item, index),
                  title: Text(
                    item.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      decoration: item.isDone
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  subtitle: Text("Water every ${item.frequencyInDays} days"),

                  // --- NEW: Triple Dot Menu ---
                  trailing: PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert),
                    onSelected: (value) {
                      if (value == 'edit') {
                        // Placeholder for later
                        _showEditPlantDialog(context, item);
                      } else if (value == 'delete') {
                        _showDeleteConfirmation(context, item, index);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 18),
                            SizedBox(width: 8),
                            Text("Edit Plant"),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 18, color: Colors.red),
                            const SizedBox(width: 8),
                            const Text(
                              "Remove",
                              style: TextStyle(color: Colors.red),
                            ),
                          ],
                        ),
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

  // --- Helper: The Plant Icon & Checkbox ---
  Widget _buildLeadingIcon(BuildContext context, Task item, int index) {
    return SizedBox(
      width: 40,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(item.emoji, style: const TextStyle(fontSize: 18)),
          SizedBox(
            height: 24,
            child: Checkbox(
              value: item.isDone,
              onChanged: (val) => onToggle(index, val!), // Trigger callback
            ),
          ),
        ],
      ),
    );
  }
}
