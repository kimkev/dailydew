import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';

class GardenView extends StatelessWidget {
  const GardenView({super.key});

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    final tasks = taskProvider.tasks;

    return LayoutBuilder(
      builder: (context, constraints) {
        // --- CALCULATION FOR BOUNDARIES ---
        // We define a 20px "Safe Zone" so plants don't hit the fence
        double padding = 20.0;
        double availableWidth = constraints.maxWidth - (padding * 2);
        double availableHeight = constraints.maxHeight - (padding * 2);

        return GestureDetector(
          onTapUp: (details) {
            if (taskProvider.selectedTaskId != null) {
              // We "clamp" the tap so it stays inside the safe zone
              // .clamp ensures the number stays between a min and max
              double xRaw = details.localPosition.dx - padding;
              double yRaw = details.localPosition.dy - padding;
              
              double xPercent = (xRaw / availableWidth).clamp(0.05, 0.95);
              double yPercent = (yRaw / availableHeight).clamp(0.05, 0.95);

              taskProvider.updateTaskPosition(
                taskProvider.selectedTaskId!,
                xPercent,
                yPercent,
              );
              taskProvider.selectTask(null);
            }
          },
          child: Container(
            color: const Color(0xFFF1F8E9), // Outer background
            padding: EdgeInsets.all(padding),
            child: Container(
              // --- THE FENCE / BORDER ---
              decoration: BoxDecoration(
                color: const Color(0xFFDCEDC8), // Inner grass color
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: Colors.brown.shade300, // Wooden fence color
                  width: 8,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    spreadRadius: 2,
                  )
                ],
              ),
              child: Stack(
                clipBehavior: Clip.none, // Allows us to see the glow if it's near edge
                children: [
                  ...tasks.map((plant) {
                    double x = plant.positionX ?? 0.5;
                    double y = plant.positionY ?? 0.5;
                    bool isSelected = taskProvider.selectedTaskId == plant.id;

                    return Positioned(
                      // Position relative to the inner garden bed
                      left: x * availableWidth - 30,
                      top: y * availableHeight - 30,
                      child: GestureDetector(
                        onTap: () => taskProvider.selectTask(plant.id),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.white.withValues(alpha: 0.4) : Colors.transparent,
                            shape: BoxShape.circle,
                            border: isSelected ? Border.all(color: Colors.white, width: 2) : null,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(plant.emoji, style: const TextStyle(fontSize: 40)),
                              Text(
                                plant.name,
                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.brown),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}