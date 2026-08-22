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

class _GardenViewState extends State<GardenView>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _beeAnim;
  late Animation<double> _butterflyAnim;
  late Animation<double> _rippleAnim;
  late Animation<double> _wormAnim;
  final GlobalKey _gardenStackKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      SoundService.instance.playGardenChirp();
    });

    // Animation controller: 4-second loop
    _animController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );
    // Bee: moves left→right, oscillating
    _beeAnim = Tween<double>(begin: -6.0, end: 6.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );

    // Butterfly: moves right→left (opposite direction)
    _butterflyAnim = Tween<double>(begin: 6.0, end: -6.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );

    // Ripples: gentle up-down
    _rippleAnim = Tween<double>(begin: -2.0, end: 2.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );

    // Worm: small, gentle up-and-down movement.
    _wormAnim = Tween<double>(begin: -3.0, end: 3.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );

    _animController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
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
                      colors: [
                        const Color(0xFFD7CCC8), // light warm wood
                        const Color(0xFFA1887F), // medium wood
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFF4E342E), // dark brown frame
                      width: 12,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.25),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: const Color(0xFF6D4C41),
                        width: 2,
                      ),
                    ),
                    child: Stack(
                      key: _gardenStackKey,
                      clipBehavior: Clip.none,
                      children: [
                        ..._buildBackgroundDecor(),

                        ...plants.map((plant) {
                          final x = plant.positionX ?? 0.5;
                          final y = plant.positionY ?? 0.5;
                          final isSelected =
                              plantProvider.selectedPlantId == plant.id;
                          final isThirsty = plantProvider.isPlantThirsty(plant);

                          // Base soil size + small growth scaling
                          final soilWidth =
                              56 +
                              (plant.growthLevel *
                                  0.4); // e.g., 56 → ~96 at max growth
                          final soilHeight =
                              18 +
                              (plant.growthLevel *
                                  0.15); // subtle vertical growth

                          final plantEmojiSize = 30 + (plant.growthLevel * 0.4);

                          // Includes the soil width plus enough vertical room for emoji + name tag.
                          final plantHitWidth = soilWidth > plantEmojiSize
                              ? soilWidth
                              : plantEmojiSize;

                          final plantHitHeight =
                              plantEmojiSize + soilHeight + 24;

                          final halfPlantWidth = plantHitWidth / 2;
                          final halfPlantHeight = plantHitHeight / 2;

                          return Positioned(
                            left: x * availableWidth - halfPlantWidth,
                            top: y * availableHeight - halfPlantHeight,
                            child: GestureDetector(
                              onPanStart: (_) {
                                plantProvider.selectPlant(plant.id);
                                HapticFeedback.lightImpact();
                              },
                              onPanUpdate: (details) {
                                final RenderBox? box =
                                    _gardenStackKey.currentContext
                                            ?.findRenderObject()
                                        as RenderBox?;

                                if (box == null) return;

                                final localOffset = box.globalToLocal(
                                  details.globalPosition,
                                );

                                final minX = halfPlantWidth;
                                final maxX = box.size.width - halfPlantWidth;
                                // Allow the plant crown to approach the top inner fence.
                                // Keep a small safety inset so it does not disappear behind the frame.
                                final minY = (halfPlantHeight - 22).clamp(
                                  0.0,
                                  double.infinity,
                                );
                                final maxY = box.size.height - halfPlantHeight;
                                final clampedX = localOffset.dx.clamp(
                                  minX,
                                  maxX,
                                );
                                final clampedY = localOffset.dy.clamp(
                                  minY,
                                  maxY,
                                );

                                plantProvider.movePlant(
                                  plant.id,
                                  clampedX / box.size.width,
                                  clampedY / box.size.height,
                                );
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
                                    clipBehavior: Clip.hardEdge,
                                    children: [
                                      // Soil patch: light when thirsty, dark after watering.
                                      AnimatedContainer(
                                        duration: const Duration(
                                          milliseconds: 300,
                                        ),
                                        curve: Curves.easeInOut,
                                        width: soilWidth,
                                        height: soilHeight,
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? colorScheme.primary.withValues(
                                                  alpha: 0.55,
                                                )
                                              : isThirsty
                                              ? const Color(
                                                  0xFF9A7058,
                                                ) // light, dry soil
                                              : const Color(
                                                  0xFF4E342E,
                                                ), // dark, moist soil
                                          borderRadius: BorderRadius.circular(
                                            30,
                                          ),
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
                                        padding: const EdgeInsets.only(
                                          bottom: 3,
                                        ),
                                        child: Text(
                                          _getGrowthEmoji(plant),
                                          style: TextStyle(
                                            fontSize:
                                                30 + (plant.growthLevel * 0.4),
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
                                      color:
                                          colorScheme.surfaceContainerHighest,
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
            AnimatedBuilder(
              animation: _rippleAnim,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _rippleAnim.value),
                  child: const Text('〰️  〰️', style: TextStyle(fontSize: 17)),
                );
              },
            ),
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

      // Bee hovering near the top-left flowers.
      AnimatedBuilder(
        animation: _beeAnim,
        builder: (context, child) {
          return Positioned(
            top: 35 + _beeAnim.value,
            left: 60,
            child: Opacity(
              opacity: 0.35,
              child: const Text('🐝', style: TextStyle(fontSize: 18)),
            ),
          );
        },
      ),

      // Bee #2 - top left, slightly lower
      AnimatedBuilder(
        animation: _beeAnim,
        builder: (context, child) {
          return Positioned(
            top: 65 + _beeAnim.value,
            left: 40,
            child: Opacity(
              opacity: 0.30,
              child: const Text('🐝', style: TextStyle(fontSize: 16)),
            ),
          );
        },
      ),

      // Bee #3 - top left, near the corner
      AnimatedBuilder(
        animation: _beeAnim,
        builder: (context, child) {
          return Positioned(
            top: 25 + _beeAnim.value * 0.8,
            left: 80,
            child: Opacity(
              opacity: 0.28,
              child: const Text('🐝', style: TextStyle(fontSize: 17)),
            ),
          );
        },
      ),

      // Butterfly drifting near the center-right.
      AnimatedBuilder(
        animation: _butterflyAnim,
        builder: (context, child) {
          return Positioned(
            top: 200 + _butterflyAnim.value,
            right: 80,
            child: Opacity(
              opacity: 0.30,
              child: const Text('🦋', style: TextStyle(fontSize: 20)),
            ),
          );
        },
      ),

      // Butterfly #2 - lower left area
      AnimatedBuilder(
        animation: _butterflyAnim,
        builder: (context, child) {
          return Positioned(
            top: 180 + _butterflyAnim.value * 0.8,
            left: 100,
            child: Opacity(
              opacity: 0.25,
              child: const Text('🦋', style: TextStyle(fontSize: 18)),
            ),
          );
        },
      ),

      // Butterfly #3 - bottom center
      AnimatedBuilder(
        animation: _butterflyAnim,
        builder: (context, child) {
          return Positioned(
            bottom: 100,
            left: 140 + _butterflyAnim.value * 0.5,
            child: Opacity(
              opacity: 0.28,
              child: const Text('🦋', style: TextStyle(fontSize: 19)),
            ),
          );
        },
      ),

      // Butterfly #3 - bottom right
      AnimatedBuilder(
        animation: _butterflyAnim,
        builder: (context, child) {
          return Positioned(
            bottom: 100,
            right: 100 + _butterflyAnim.value * 0.6,
            child: Opacity(
              opacity: 0.28,
              child: const Text('🦋', style: TextStyle(fontSize: 19)),
            ),
          );
        },
      ),
      // Flower #1
      Positioned(
        top: 38,
        left: 32,
        child: Opacity(
          opacity: 0.25,
          child: const Text('🌸', style: TextStyle(fontSize: 20)),
        ),
      ),
      // Flower #2
      Positioned(
        top: 38,
        left: 62,
        child: Opacity(
          opacity: 0.25,
          child: const Text('🌸', style: TextStyle(fontSize: 20)),
        ),
      ),
      // Flower #3
      Positioned(
        top: 65,
        left: 55,
        child: Opacity(
          opacity: 0.28,
          child: const Text('🌻', style: TextStyle(fontSize: 15)),
        ),
      ),
      // Flower #4 - white/yellow daisy near bees
      Positioned(
        top: 50,
        left: 45,
        child: Opacity(
          opacity: 0.26,
          child: const Text('🌼', style: TextStyle(fontSize: 17)),
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
      // Wide, heavy-soil ripple lines.
      Positioned(
        top: 244,
        left: 24,
        child: Opacity(
          opacity: 0.62,
          child: Transform.scale(
            scaleX: 2.15,
            scaleY: 0.72,
            alignment: Alignment.centerLeft,
            child: Text(
              '〰',
              style: TextStyle(
                fontSize: 28,
                color: Color(0xFF2B1712), // deep, heavy soil brown
                fontWeight: FontWeight.w900,
                height: 0.8,
              ),
            ),
          ),
        ),
      ),

      Positioned(
        top: 260,
        left: 40,
        child: Opacity(
          opacity: 0.52,
          child: Transform.scale(
            scaleX: 2.45,
            scaleY: 0.65,
            alignment: Alignment.centerLeft,
            child: Text(
              '〰',
              style: TextStyle(
                fontSize: 26,
                color: Color(0xFF2B1712),
                fontWeight: FontWeight.w900,
                height: 0.8,
              ),
            ),
          ),
        ),
      ),

      Positioned(
        top: 276,
        left: 22,
        child: Opacity(
          opacity: 0.44,
          child: Transform.scale(
            scaleX: 2.0,
            scaleY: 0.60,
            alignment: Alignment.centerLeft,
            child: Text(
              '〰',
              style: TextStyle(
                fontSize: 23,
                color: Color(0xFF2B1712),
                fontWeight: FontWeight.w900,
                height: 0.8,
              ),
            ),
          ),
        ),
      ),

      // Caterpillar #1: gently bobbing over the upper soil ridge.
      AnimatedBuilder(
        animation: _wormAnim,
        builder: (context, child) {
          return Positioned(
            top: 230 + _wormAnim.value,
            left: 62,
            child: Opacity(
              opacity: 0.44,
              child: Transform.rotate(
                angle: -0.16,
                child: const Text('🐛', style: TextStyle(fontSize: 24)),
              ),
            ),
          );
        },
      ),

      // Caterpillar #2: smaller, moving slightly opposite to the first.
      AnimatedBuilder(
        animation: _wormAnim,
        builder: (context, child) {
          return Positioned(
            top: 265 - (_wormAnim.value * 0.7),
            left: 32,
            child: Opacity(
              opacity: 0.36,
              child: Transform.rotate(
                angle: 0.20,
                child: const Text('🐛', style: TextStyle(fontSize: 18)),
              ),
            ),
          );
        },
      ),
    ];
  }
}
