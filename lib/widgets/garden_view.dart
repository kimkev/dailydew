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

  String _getGrowthEmoji(Plant plant) {
    return plant.emoji;
  }

  @override
  Widget build(BuildContext context) {
    final plantProvider = Provider.of<PlantProvider>(context);
    final plants = plantProvider.plants;
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
                    '${plants.length} ${plants.length == 1 ? 'plant' : 'plants'}',
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

                      ...plants.map((plant) {
                        final x = plant.positionX ?? 0.5;
                        final y = plant.positionY ?? 0.5;
                        final isSelected =
                            plantProvider.selectedPlantId == plant.id;
                        final isThirsty = plantProvider.isPlantThirsty(plant);

                        return Positioned(
                          left: x * availableWidth - 40,
                          top: y * availableHeight - 40,
                          child: GestureDetector(
                            onPanStart: (_) {
                              plantProvider.selectPlant(plant.id);
                              HapticFeedback.lightImpact();
                            },
                            onPanUpdate: (details) {
                              final RenderBox box =
                                  context.findRenderObject() as RenderBox;

                              final localOffset = box.globalToLocal(
                                details.globalPosition,
                              );

                              final double newX =
                                  localOffset.dx / availableWidth;
                              final double newY =
                                  localOffset.dy / availableHeight;

                              plantProvider.movePlant(plant.id, newX, newY);
                            },
                            onPanEnd: (_) {
                              plantProvider.savePositions();
                              plantProvider.selectPlant(null);
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
                                            : isThirsty
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

                      if (plants.isEmpty)
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
      // Larger pond in the upper-middle/right garden area.
      Positioned(
        top: 74,
        right: 18,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            // Outer bank / rocks.
            Container(
              width: 156,
              height: 108,
              decoration: BoxDecoration(
                color: const Color(0xFF8C6B57).withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(64),
              ),
            ),

            // Pond water.
            Container(
              width: 136,
              height: 86,
              decoration: BoxDecoration(
                color: const Color(0xFF83CDEA).withValues(alpha: 0.76),
                borderRadius: BorderRadius.circular(54),
                border: Border.all(
                  color: const Color(0xFF4AA8D0).withValues(alpha: 0.55),
                  width: 2,
                ),
              ),
            ),

            // Water ripples.
            const Text('〰️  〰️', style: TextStyle(fontSize: 17)),

            // Lily pad and rocks.
            const Positioned(
              right: 24,
              bottom: 12,
              child: Text('🪷', style: TextStyle(fontSize: 22)),
            ),
            const Positioned(
              left: -8,
              bottom: 5,
              child: Text('🪨', style: TextStyle(fontSize: 21)),
            ),
            const Positioned(
              right: -8,
              top: 6,
              child: Text('🪨', style: TextStyle(fontSize: 19)),
            ),

            // Three birds sitting directly along the pond edge.
            const Positioned(
              left: 10,
              top: -16,
              child: Text('🐦', style: TextStyle(fontSize: 21)),
            ),
            const Positioned(
              right: 20,
              top: -18,
              child: Text('🐦', style: TextStyle(fontSize: 19)),
            ),
            const Positioned(
              left: -10,
              bottom: 8,
              child: Text('🐦', style: TextStyle(fontSize: 18)),
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
