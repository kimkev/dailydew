import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/plant_provider.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final plants = context.watch<PlantProvider>().plants;

    final totalWaterings = plants.fold<int>(
      0,
      (total, plant) => total + plant.totalCompletions,
    );

    final highestStreak = plants.fold<int>(
      0,
      (highest, plant) =>
          plant.longestStreak > highest ? plant.longestStreak : highest,
    );

    final highestGrowth = plants.fold<int>(
      0,
      (highest, plant) =>
          plant.growthLevel > highest ? plant.growthLevel : highest,
    );

    final achievements = <_Achievement>[
      _Achievement(
        icon: '💧',
        title: 'First Drop',
        description: 'Water your first plant.',
        unlocked: totalWaterings >= 1,
        progress: totalWaterings,
        target: 1,
      ),

      _Achievement(
        icon: '💦',
        title: 'Getting Started',
        description: 'Water plants 3 times.',
        unlocked: totalWaterings >= 3,
        progress: totalWaterings,
        target: 3,
      ),
      _Achievement(
        icon: '🚿',
        title: 'Helpful Hands',
        description: 'Water plants 10 times.',
        unlocked: totalWaterings >= 10,
        progress: totalWaterings,
        target: 10,
      ),
      _Achievement(
        icon: '🪣',
        title: 'Garden Routine',
        description: 'Water plants 25 times.',
        unlocked: totalWaterings >= 25,
        progress: totalWaterings,
        target: 25,
      ),
      _Achievement(
        icon: '🌧️',
        title: 'Rainmaker',
        description: 'Water plants 50 times.',
        unlocked: totalWaterings >= 50,
        progress: totalWaterings,
        target: 50,
      ),
      _Achievement(
        icon: '💧',
        title: 'Water Wise',
        description: 'Water plants 100 times.',
        unlocked: totalWaterings >= 100,
        progress: totalWaterings,
        target: 100,
      ),
      _Achievement(
        icon: '🏞️',
        title: 'Garden Guardian',
        description: 'Water plants 250 times.',
        unlocked: totalWaterings >= 250,
        progress: totalWaterings,
        target: 250,
      ),
      _Achievement(
        icon: '👑',
        title: 'Master Gardener',
        description: 'Water plants 500 times.',
        unlocked: totalWaterings >= 500,
        progress: totalWaterings,
        target: 500,
      ),
      _Achievement(
        icon: '🌱',
        title: 'First Seedling',
        description: 'Add your first plant to the garden.',
        unlocked: plants.isNotEmpty,
        progress: plants.length,
        target: 1,
      ),
      _Achievement(
        icon: '🌿',
        title: 'Garden Growing',
        description: 'Add 5 plants to your garden.',
        unlocked: plants.length >= 5,
        progress: plants.length,
        target: 5,
      ),
      _Achievement(
        icon: '🏡',
        title: 'Garden Keeper',
        description: 'Add 10 plants to your garden.',
        unlocked: plants.length >= 10,
        progress: plants.length,
        target: 10,
      ),
      _Achievement(
        icon: '🔥',
        title: 'On a Roll',
        description: 'Reach a 3-watering streak with one plant.',
        unlocked: highestStreak >= 3,
        progress: highestStreak,
        target: 3,
      ),
      _Achievement(
        icon: '🌱',
        title: 'Steady Gardener',
        description: 'Reach a 7-watering streak with one plant.',
        unlocked: highestStreak >= 7,
        progress: highestStreak,
        target: 7,
      ),
      _Achievement(
        icon: '🌿',
        title: 'Two-Week Tender',
        description: 'Reach a 14-watering streak with one plant.',
        unlocked: highestStreak >= 14,
        progress: highestStreak,
        target: 14,
      ),
      _Achievement(
        icon: '🌼',
        title: 'Dedicated Care',
        description: 'Reach a 21-watering streak with one plant.',
        unlocked: highestStreak >= 21,
        progress: highestStreak,
        target: 21,
      ),
      _Achievement(
        icon: '🏅',
        title: 'Routine Builder',
        description: 'Reach a 30-watering streak with one plant.',
        unlocked: highestStreak >= 30,
        progress: highestStreak,
        target: 30,
      ),
      _Achievement(
        icon: '🌳',
        title: 'Seasoned Grower',
        description: 'Reach a 60-watering streak with one plant.',
        unlocked: highestStreak >= 60,
        progress: highestStreak,
        target: 60,
      ),
      _Achievement(
        icon: '🏆',
        title: 'Garden Champion',
        description: 'Reach a 90-watering streak with one plant.',
        unlocked: highestStreak >= 90,
        progress: highestStreak,
        target: 90,
      ),
      _Achievement(
        icon: '💎',
        title: 'Evergreen Dedication',
        description: 'Reach a 180-watering streak with one plant.',
        unlocked: highestStreak >= 180,
        progress: highestStreak,
        target: 180,
      ),
      _Achievement(
        icon: '👑',
        title: 'Legendary Gardener',
        description: 'Reach a 365-watering streak with one plant.',
        unlocked: highestStreak >= 365,
        progress: highestStreak,
        target: 365,
      ),
      _Achievement(
        icon: '🌻',
        title: 'Full Bloom',
        description: 'Grow one plant to 90%.',
        unlocked: highestGrowth >= 90,
        progress: highestGrowth,
        target: 90,
      ),
    ];

    final unlockedCount = achievements
        .where((achievement) => achievement.unlocked)
        .length;

    return Scaffold(
      appBar: AppBar(title: const Text('Achievements')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                const Text('🏆', style: TextStyle(fontSize: 48)),
                const SizedBox(height: 8),
                Text(
                  '$unlockedCount of ${achievements.length} unlocked',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Celebrate every bit of care you give your garden.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: colorScheme.onPrimaryContainer.withValues(
                      alpha: 0.8,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                LinearProgressIndicator(
                  value: achievements.isEmpty
                      ? 0
                      : unlockedCount / achievements.length,
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(10),
                  backgroundColor: colorScheme.onPrimaryContainer.withValues(
                    alpha: 0.18,
                  ),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          ...achievements.map(
            (achievement) => _AchievementCard(achievement: achievement),
          ),
        ],
      ),
    );
  }
}

class _Achievement {
  final String icon;
  final String title;
  final String description;
  final bool unlocked;
  final int progress;
  final int target;

  const _Achievement({
    required this.icon,
    required this.title,
    required this.description,
    required this.unlocked,
    required this.progress,
    required this.target,
  });
}

class _AchievementCard extends StatelessWidget {
  final _Achievement achievement;

  const _AchievementCard({required this.achievement});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final displayedProgress = achievement.progress.clamp(0, achievement.target);
    final progressValue = achievement.target == 0
        ? 0.0
        : displayedProgress / achievement.target;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: achievement.unlocked
          ? colorScheme.secondaryContainer
          : colorScheme.surfaceContainerHighest,
      child: Opacity(
        opacity: achievement.unlocked ? 1.0 : 0.65,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: achievement.unlocked
                      ? colorScheme.secondary
                      : colorScheme.outlineVariant,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  achievement.unlocked ? achievement.icon : '🔒',
                  style: const TextStyle(fontSize: 25),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      achievement.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      achievement.description,
                      style: TextStyle(color: theme.hintColor, fontSize: 13),
                    ),
                    const SizedBox(height: 10),
                    LinearProgressIndicator(
                      value: progressValue,
                      minHeight: 6,
                      borderRadius: BorderRadius.circular(10),
                      backgroundColor: colorScheme.onSurface.withValues(
                        alpha: 0.10,
                      ),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        achievement.unlocked
                            ? colorScheme.secondary
                            : colorScheme.outline,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '$displayedProgress/${achievement.target}',
                      style: TextStyle(color: theme.hintColor, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
