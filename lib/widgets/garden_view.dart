import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import 'package:flutter/services.dart';

class GardenView extends StatelessWidget {
  const GardenView({super.key});

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    final tasks = taskProvider.tasks;

    return LayoutBuilder(
      builder: (context, constraints) {
        double padding = 20.0;
        double availableWidth = constraints.maxWidth - (padding * 2);
        double availableHeight = constraints.maxHeight - (padding * 2);

        return Container(
          color: const Color(0xFFF1F8E9), // Light background
          padding: EdgeInsets.all(padding),
          child: Container(
            decoration: BoxDecoration(
              // 1. IMPROVED GRASS (Gradient)
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFDCEDC8), Color(0xFFAED581)],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.brown.shade400, width: 6),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(4, 4),
                ),
              ],
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // 2. ADD SOME DECOR (Static background details)
                ..._buildBackgroundDecor(),

                // 3. THE PLANTS
                ...tasks.map((plant) {
                  double x = plant.positionX ?? 0.5;
                  double y = plant.positionY ?? 0.5;
                  bool isSelected = taskProvider.selectedTaskId == plant.id;

                  return Positioned(
                    left: x * availableWidth - 40,
                    top: y * availableHeight - 40,
                    child: GestureDetector(
                      // 1. Detect the start of a drag + light vibration
                      onPanStart: (_) {
                        taskProvider.selectTask(plant.id);
                        // This gives a tiny "click" vibration when you touch the plant
                        HapticFeedback.lightImpact();
                      },
                      // 2. While dragging, update position based on finger movement
                      onPanUpdate: (details) {
                        // 1. Get the "RenderBox" of the garden (the parent container)
                        // This allows us to know exactly where the garden is on the screen
                        final RenderBox box =
                            context.findRenderObject() as RenderBox;

                        // 2. Convert the global finger position to a position inside the garden
                        final Offset localOffset = box.globalToLocal(
                          details.globalPosition,
                        );

                        // 3. Convert that pixel position into a percentage (0.0 to 1.0)
                        // We subtract the 20px padding we added to the garden
                        double newX = (localOffset.dx - 20) / availableWidth;
                        double newY = (localOffset.dy - 20) / availableHeight;

                        // 4. Update the provider
                        taskProvider.moveTask(plant.id, newX, newY);
                      },

                      // 3. When finger lifts up, save to disk and deselect
                      onPanEnd: (_) {
                        taskProvider.savePositions();
                        taskProvider.selectTask(null);
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // 4. THE DIRT / SELECTION GLOW
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.white.withValues(alpha: 0.5)
                                  : Colors.brown.withValues(
                                      alpha: 0.1,
                                    ), // Subtle dirt spot
                              shape: BoxShape.circle,
                              border: isSelected
                                  ? Border.all(color: Colors.white, width: 2)
                                  : null,
                            ),
                            child: Text(
                              plant.emoji,
                              // 5. SCALING LOGIC
                              style: TextStyle(
                                fontSize: 40 + (plant.growthLevel * 0.5),
                              ),
                            ),
                          ),
                          // 6. BETTER NAME TAG
                          Container(
                            margin: const EdgeInsets.only(top: 2),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.8),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              plant.name,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.brown,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildBackgroundDecor() {
    return [
      Positioned(
        top: 20,
        left: 30,
        child: Opacity(
          opacity: 0.5,
          child: const Text("🌼", style: TextStyle(fontSize: 12)),
        ),
      ),
      Positioned(
        bottom: 40,
        right: 50,
        child: Opacity(
          opacity: 0.4,
          child: const Text("🍀", style: TextStyle(fontSize: 14)),
        ),
      ),
      Positioned(
        top: 100,
        right: 30,
        child: Opacity(
          opacity: 0.3,
          child: const Text("🌸", style: TextStyle(fontSize: 10)),
        ),
      ),
    ];
  }
}
