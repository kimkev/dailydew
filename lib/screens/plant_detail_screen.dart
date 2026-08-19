import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/plant.dart';
import '../providers/plant_provider.dart';

class PlantDetailScreen extends StatelessWidget {
  final Plant plant;

  const PlantDetailScreen({super.key, required this.plant});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final plantProvider = Provider.of<PlantProvider>(context);

    // Find the latest plant data from provider
    final currentPlant = plantProvider.plants.firstWhere(
      (t) => t.id == plant.id,
      orElse: () => plant,
    );

    final canWater = plantProvider.isPlantThirsty(currentPlant);

    // Calculate days since last watered
    final daysSinceWatered = DateTime.now()
        .difference(currentPlant.lastCompleted)
        .inDays;

    return Scaffold(
      appBar: AppBar(title: Text(currentPlant.name)),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Plant Emoji Header
              Center(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    currentPlant.emoji,
                    style: const TextStyle(fontSize: 64),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Stats Cards
              _buildStatCard(
                context,
                icon: Icons.water_drop,
                title: 'Last Watered',
                value: daysSinceWatered == 0
                    ? 'Today'
                    : '$daysSinceWatered days ago',
                subtitle: 'Water every ${currentPlant.frequencyInDays} days',
              ),
              const SizedBox(height: 16),

              _buildStatCard(
                context,
                icon: Icons.trending_up,
                title: 'Growth Level',
                value: '${currentPlant.growthLevel}%',
                subtitle: _getGrowthStageText(currentPlant.growthLevel),
              ),
              const SizedBox(height: 16),

              _buildStatCard(
                context,
                icon: Icons.check_circle_outline,
                title: 'Total Waterings',
                value: '${currentPlant.totalCompletions}',
                subtitle: 'Keep it up!',
              ),
              const SizedBox(height: 16),

              _buildStatCard(
                context,
                icon: Icons.local_fire_department,
                title: 'Current Streak',
                value: '${currentPlant.currentStreak} 🔥',
                subtitle:
                    currentPlant.currentStreak > currentPlant.longestStreak
                    ? 'New personal best!'
                    : 'Best: ${currentPlant.longestStreak}',
              ),
              const SizedBox(height: 16),

              _buildStatCard(
                context,
                icon: Icons.category,
                title: 'Plant Type',
                value: currentPlant.category,
                subtitle: '',
              ),
              const SizedBox(height: 16),

              _buildStatCard(
                context,
                icon: Icons.calendar_today,
                title: 'Date Added',
                value:
                    '${currentPlant.dateAdded.month}/${currentPlant.dateAdded.day}/${currentPlant.dateAdded.year}',
                subtitle: '',
              ),
              const SizedBox(height: 16),

              _buildStatCard(
                context,
                icon: Icons.timer,
                title: 'Plant Age',
                value: _getPlantAge(currentPlant.dateAdded),
                subtitle: 'Keep nurturing it!',
              ),
              const SizedBox(height: 24),

              // Water Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: !canWater
                      ? null
                      : () {
                          final index = plantProvider.plants.indexWhere(
                            (t) => t.id == currentPlant.id,
                          );

                          if (index == -1) return;

                          plantProvider.togglePlant(index);

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Watered ${currentPlant.name}! 🌱'),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                  icon: Icon(canWater ? Icons.water_drop : Icons.check_circle),
                  label: Text(canWater ? 'Water Now' : 'Not Due Yet'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    disabledBackgroundColor:
                        colorScheme.surfaceContainerHighest,
                    disabledForegroundColor: colorScheme.onSurfaceVariant,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 32, color: colorScheme.primary),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 12, color: theme.hintColor),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: theme.hintColor),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getGrowthStageText(int growthLevel) {
    if (growthLevel < 25) {
      return 'Seedling';
    } else if (growthLevel < 50) {
      return 'Growing';
    } else if (growthLevel < 75) {
      return 'Mature';
    } else {
      return 'Thriving';
    }
  }

  String _getPlantAge(DateTime dateAdded) {
    final now = DateTime.now();
    final difference = now.difference(dateAdded);

    if (difference.inDays < 7) {
      return '${difference.inDays} days';
    } else if (difference.inDays < 30) {
      final weeks = difference.inDays ~/ 7;
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'}';
    } else if (difference.inDays < 365) {
      final months = difference.inDays ~/ 30;
      return '$months ${months == 1 ? 'month' : 'months'}';
    } else {
      final years = difference.inDays ~/ 365;
      final remainingMonths = (difference.inDays % 365) ~/ 30;
      if (remainingMonths > 0) {
        return '$years ${years == 1 ? 'year' : 'years'}, $remainingMonths ${remainingMonths == 1 ? 'month' : 'months'}';
      }
      return '$years ${years == 1 ? 'year' : 'years'}';
    }
  }
}
