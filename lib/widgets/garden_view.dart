import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/plant.dart';
import '../providers/plant_provider.dart';
import '../services/sound_service.dart';

class GardenView extends StatefulWidget {
  const GardenView({super.key});

  @override
  State<GardenView> createState() => _GardenViewState();
}

class _GardenViewState extends State<GardenView> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      SoundService.instance.playGardenChirp();
    });
  }

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
                                    // Soil patch: light when thirsty, dark after watering.
                                    AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 300,
                                      ),
                                      curve: Curves.easeInOut,
                                      width: 78,
                                      height: 26,
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? colorScheme.primary.withValues(
                                                alpha: 0.55,
                                              )
                                            : plant.isDone
                                            ? const Color(
                                                0xFF4E342E,
                                              ) // Dark, moist soil
                                            : const Color(
                                                0xFF9A7058,
                                              ), // Light, dry soil
                                        borderRadius: BorderRadius.circular(30),
                                        border: isSelected
                                            ? Border.all(
                                                color: Colors.white,
                                                width: 2,
                                              )
                                            : null,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withValues(
                                              alpha: 0.12,
                                            ),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Plant floats just above its soil.
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 6),
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
      // Horizontal riverbed across the middle of the garden.
      Positioned(
        bottom: 22,
        right: 20,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Outer bank / rocks
            Container(
              width: 112,
              height: 78,
              decoration: BoxDecoration(
                color: const Color(0xFF8C6B57).withValues(alpha: 0.40),
                borderRadius: BorderRadius.circular(50),
              ),
            ),

            // Pond water
            Container(
              width: 96,
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFF83CDEA).withValues(alpha: 0.72),
                borderRadius: BorderRadius.circular(45),
                border: Border.all(
                  color: const Color(0xFF4AA8D0).withValues(alpha: 0.45),
                  width: 2,
                ),
              ),
            ),

            // Water ripples
            const Text('〰️ 〰️', style: TextStyle(fontSize: 13)),

            // Lily-pad / pond life accent
            const Positioned(
              right: 15,
              bottom: 10,
              child: Text('🪷', style: TextStyle(fontSize: 16)),
            ),

            // Rocks overlap the pond edge.
            const Positioned(
              left: -7,
              bottom: 4,
              child: Text('🪨', style: TextStyle(fontSize: 18)),
            ),
            const Positioned(
              right: -6,
              top: 4,
              child: Text('🪨', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),

      // Small clusters of natural garden decoration.
      Positioned(
        top: 28,
        left: 22,
        child: Opacity(
          opacity: 0.25,
          child: const Text('🌼', style: TextStyle(fontSize: 15)),
        ),
      ),
      Positioned(
        top: 82,
        right: 24,
        child: Opacity(
          opacity: 0.20,
          child: const Text('🌿', style: TextStyle(fontSize: 17)),
        ),
      ),
      Positioned(
        bottom: 34,
        left: 26,
        child: Opacity(
          opacity: 0.22,
          child: const Text('🍀', style: TextStyle(fontSize: 15)),
        ),
      ),
      Positioned(
        bottom: 88,
        right: 30,
        child: Opacity(
          opacity: 0.20,
          child: const Text('🌸', style: TextStyle(fontSize: 13)),
        ),
      ),
    ];
  }
}
