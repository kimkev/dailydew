import 'package:flutter/material.dart';
import '../models/task.dart';

class GardenView extends StatelessWidget {
  final List<Task> tasks;

  const GardenView({super.key, required this.tasks});

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
      return const Center(
        child: Text("Your garden is empty. Add some habits!"),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // 2 items per row looks cleaner for "cards"
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
        childAspectRatio: 0.85, // Makes the cards slightly taller
      ),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final plant = tasks[index];
        
        // Calculate a scale factor: starts at 1.0, grows slightly with each point
        // Every 10 points adds 5% size.
        double scale = 1.0 + (plant.growthLevel % 20) / 100;

        return Card(
          elevation: 0,
          color: Colors.green.withOpacity(0.05),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: Colors.green.withOpacity(0.1)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // TRANSFORM/SCALE: This makes the emoji grow smoothly
                Transform.scale(
                  scale: scale,
                  child: Text(
                    plant.emoji,
                    style: const TextStyle(fontSize: 45),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  plant.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                
                // GROWTH BAR: Shows progress to next stage
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: (plant.growthLevel % 20) / 20, // Progress within current stage
                    backgroundColor: Colors.green.withOpacity(0.1),
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Level ${plant.growthLevel}",
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}