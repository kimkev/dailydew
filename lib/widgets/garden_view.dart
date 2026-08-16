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

    // Grab the global theme
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        double padding = 20.0;
        double availableWidth = constraints.maxWidth - (padding * 2);
        double availableHeight = constraints.maxHeight - (padding * 2);

        return Container(
          color: theme.scaffoldBackgroundColor, // Uses the theme's background
          padding: EdgeInsets.all(padding),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [colorScheme.tertiary, colorScheme.onTertiary],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: colorScheme.outlineVariant, width: 6),
              boxShadow: [
                BoxShadow(
                  color: theme.shadowColor.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(4, 4),
                ),
              ],
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                ..._buildBackgroundDecor(),
                ...tasks.map((plant) {
                  double x = plant.positionX ?? 0.5;
                  double y = plant.positionY ?? 0.5;
                  bool isSelected = taskProvider.selectedTaskId == plant.id;

                  return Positioned(
                    left: x * availableWidth - 40,
                    top: y * availableHeight - 40,
                    child: GestureDetector(
                      onPanStart: (_) {
                        taskProvider.selectTask(plant.id);
                        HapticFeedback.lightImpact();
                      },
                      onPanUpdate: (details) {
                        final RenderBox box =
                            context.findRenderObject() as RenderBox;
                        final Offset localOffset = box.globalToLocal(
                          details.globalPosition,
                        );
                        taskProvider.moveTask(
                          plant.id,
                          (localOffset.dx - 20) / availableWidth,
                          (localOffset.dy - 20) / availableHeight,
                        );
                      },
                      onPanEnd: (_) {
                        taskProvider.savePositions();
                        taskProvider.selectTask(null);
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              // THE DIRT SLOT
                              color: isSelected
                                  ? Colors.white.withValues(alpha: 0.5)
                                  : colorScheme.scrim,
                              shape: BoxShape.circle,
                              border: isSelected
                                  ? Border.all(color: Colors.white, width: 2)
                                  : null,
                            ),
                            child: Text(
                              plant.emoji,
                              style: TextStyle(
                                fontSize: 40 + (plant.growthLevel * 0.5),
                              ),
                            ),
                          ),
                          // THE TAG SLOTS
                          Container(
                            margin: const EdgeInsets.only(top: 2),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              plant.name,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                if (tasks.isEmpty)
                  Positioned.fill(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.yard_outlined,
                            size: 60,
                            color: colorScheme.onSurface.withValues(alpha: 0.2),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "Plants you add will appear here!",
                            style: TextStyle(
                              color: colorScheme.onSurface.withValues(
                                alpha: 0.4,
                              ),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
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
          opacity: 0.3,
          child: const Text("🌼", style: TextStyle(fontSize: 12)),
        ),
      ),
      Positioned(
        bottom: 40,
        right: 50,
        child: Opacity(
          opacity: 0.2,
          child: const Text("🍀", style: TextStyle(fontSize: 14)),
        ),
      ),
      Positioned(
        top: 100,
        right: 30,
        child: Opacity(
          opacity: 0.2,
          child: const Text("🌸", style: TextStyle(fontSize: 10)),
        ),
      ),
    ];
  }
}
