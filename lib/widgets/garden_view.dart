import 'package:flutter/material.dart';
import '../models/task.dart';

class GardenView extends StatelessWidget {
  final List<Task> tasks; // This is like 'props' in React

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
        crossAxisCount: 3, // 3 items per row
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
      ),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final plant = tasks[index];
        return Container(
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.green.withOpacity(0.2)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                plant.growthLevel < 30
                    ? '🌱'
                    : plant.growthLevel < 70
                    ? '🌿'
                    : '🌳',
                style: const TextStyle(fontSize: 35),
              ),
              const SizedBox(height: 5),
              Text(
                plant.name,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
    );
  }
}
