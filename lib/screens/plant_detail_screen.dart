import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/plant.dart';
import '../providers/plant_provider.dart';


class PlantDetailScreen extends StatelessWidget {
  final Task plant;

  const PlantDetailScreen({super.key, required this.plant});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);

    // Calculate days since last watered
    final daysSinceWatered = DateTime.now()
        .difference(plant.lastCompleted)
        .inDays;

    return Scaffold(
      appBar: AppBar(
        title: Text(plant.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
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
                  plant.emoji,
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
              value: plant.isDone
                  ? 'Today'
                  : '$daysSinceWatered days ago',
              subtitle: 'Water every ${plant.frequencyInDays} days',
            ),
            const SizedBox(height: 16),

            _buildStatCard(
              context,
              icon: Icons.trending_up,
              title: 'Growth Level',
              value: '${plant.growthLevel}%',
              subtitle: _getGrowthStageText(plant.growthLevel),
            ),
            const SizedBox(height: 16),

            _buildStatCard(
              context,
              icon: Icons.check_circle_outline,
              title: 'Total Waterings',
              value: '${plant.totalCompletions}',
              subtitle: 'Keep it up!',
            ),
            const SizedBox(height: 16),

            _buildStatCard(
              context,
              icon: Icons.category,
              title: 'Plant Type',
              value: plant.category,
              subtitle: '',
            ),

            const Spacer(),

            // Water Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: plant.isDone
                    ? null
                    : () {
                        // Find the index of this plant
                        final index = taskProvider.tasks
                            .indexWhere((t) => t.id == plant.id);
                        
                        if (index != -1) {
                          taskProvider.toggleTask(index);
                          
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "Watered ${plant.name}! 🌱",
                                ),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                            Navigator.pop(context);
                          }
                        }
                      },
                icon: Icon(
                  plant.isDone ? Icons.check_circle : Icons.water_drop,
                ),
                label: Text(
                  plant.isDone ? 'Already Watered' : 'Water Now',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
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
          Icon(
            icon,
            size: 32,
            color: colorScheme.primary,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.hintColor,
                  ),
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
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.hintColor,
                    ),
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
}