import 'package:flutter/material.dart';
import '../models/task.dart';

class TaskList extends StatelessWidget {
  final List<Task> tasks;
  final double progress;
  final Function(int) onDelete;    // Callback for deletion
  final Function(int, bool) onToggle; // Callback for checkmark

  const TaskList({
    super.key,
    required this.tasks,
    required this.progress,
    required this.onDelete,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // --- Progress Section ---
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
            valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
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
                child: Dismissible(
                  key: Key(item.id),
                  direction: DismissDirection.endToStart,
                  onDismissed: (direction) => onDelete(index), // Trigger callback
                  background: _buildDeleteBackground(context),
                  child: ListTile(
                    title: Text(
                      item.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        decoration: item.isDone ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    subtitle: Text("${item.category} • Every ${item.frequencyInDays} days"),
                    leading: _buildLeadingIcon(context, item, index),
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
          Text(
            item.growthLevel < 30 ? '🌱' : item.growthLevel < 70 ? '🌿' : '🌳',
            style: const TextStyle(fontSize: 18),
          ),
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

  // --- Helper: The Delete Background ---
  Widget _buildDeleteBackground(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Icon(Icons.delete, color: Theme.of(context).colorScheme.error),
    );
  }
}