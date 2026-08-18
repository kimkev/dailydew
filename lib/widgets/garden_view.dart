import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/plant.dart';
import '../providers/plant_provider.dart';

class GardenView extends StatelessWidget {
  const GardenView({super.key});

  String _getGrowthEmoji(Task plant) {
    return plant.emoji;
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    final tasks = taskProvider.tasks;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    const pagePadding = 20.0;

    return Container(
      color: theme.scaffoldBackgroundColor,
      padding: const EdgeInsets.all(pagePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Page heading: intentionally outside the garden fence.
          Padding(
            padding: const EdgeInsets.only(left: 6, right: 6, bottom: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'My Garden',
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${tasks.length} ${tasks.length == 1 ? 'plant' : 'plants'}',
                    style: TextStyle(
                      color: colorScheme.onPrimaryContainer,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Fenced garden area.
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final availableWidth = constraints.maxWidth;
                final availableHeight = constraints.maxHeight;

                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [colorScheme.tertiary, colorScheme.onTertiary],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: colorScheme.outlineVariant,
                      width: 6,
                    ),
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
                        final x = plant.positionX ?? 0.5;
                        final y = plant.positionY ?? 0.5;
                        final isSelected =
                            taskProvider.selectedTaskId == plant.id;

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

                              final localOffset = box.globalToLocal(
                                details.globalPosition,
                              );

                              final newX = localOffset.dx / availableWidth;
                              final newY = localOffset.dy / availableHeight;

                              taskProvider.moveTask(plant.id, newX, newY);
                            },
                            onPanEnd: (_) {
                              taskProvider.savePositions();
                              taskProvider.selectTask(null);
                            },
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Stack(
                                  alignment: Alignment.bottomCenter,
                                  clipBehavior: Clip.none,
                                  children: [
                                    // Soft soil/shadow patch behind the plant.
                                    Container(
                                      width: 72,
                                      height: 20,
                                      margin: const EdgeInsets.only(bottom: 2),
                                      decoration: BoxDecoration(
                                        color: const Color(
                                          0xFF5D4037,
                                        ).withValues(alpha: 0.30),
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                    ),

                                    // Existing plant circle, placed above the soil patch.
                                    AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 300,
                                      ),
                                      curve: Curves.easeInOut,
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? Colors.white.withValues(
                                                alpha: 0.5,
                                              )
                                            : plant.isDone
                                            ? const Color(0xFF4E342E)
                                            : const Color(0xFF8D6E63),
                                        shape: BoxShape.circle,
                                        border: isSelected
                                            ? Border.all(
                                                color: Colors.white,
                                                width: 2,
                                              )
                                            : null,
                                      ),
                                      child: Text(
                                        _getGrowthEmoji(plant),
                                        style: TextStyle(
                                          fontSize:
                                              40 + (plant.growthLevel * 0.5),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
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
                                  color: colorScheme.onSurface.withValues(
                                    alpha: 0.2,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'Plants you add will appear here!',
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
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildBackgroundDecor() {
    return [
      Positioned(
        top: 20,
        left: 30,
        child: Opacity(
          opacity: 0.3,
          child: const Text('🌼', style: TextStyle(fontSize: 12)),
        ),
      ),
      Positioned(
        bottom: 40,
        right: 50,
        child: Opacity(
          opacity: 0.2,
          child: const Text('🍀', style: TextStyle(fontSize: 14)),
        ),
      ),
      Positioned(
        top: 100,
        right: 30,
        child: Opacity(
          opacity: 0.2,
          child: const Text('🌸', style: TextStyle(fontSize: 10)),
        ),
      ),
    ];
  }
}
