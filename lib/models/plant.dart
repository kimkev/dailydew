import 'dart:convert';

class Plant {
  final String id;
  String name;
  String category; // Plant type: Flower, Houseplant, Cactus, or Tree
  int frequencyInDays; // e.g., 1 for daily, 7 for weekly
  DateTime lastCompleted;
  DateTime dateAdded;
  int growthLevel;
  int totalCompletions;
  double? positionX; // 0.0 to 1.0
  double? positionY; // 0.0 to 1.0
  int currentStreak;
  int longestStreak;

  Plant({
    required this.id,
    required this.name,
    this.category = 'Flower',
    this.frequencyInDays = 1,
    required this.lastCompleted,
    DateTime? dateAdded,
    this.growthLevel = 0,
    this.totalCompletions = 0,
    this.positionX,
    this.positionY,
    this.currentStreak = 0,
    this.longestStreak = 0,
  }) : dateAdded = dateAdded ?? DateTime.now();

  bool isThirstyAt({
    required DateTime now,
    required int reminderHour,
    required int reminderMinute,
  }) {
    // Treat as "new plant" only if:
    // - added today, AND
    // - never watered before (totalCompletions == 0)
    final addedToday =
        dateAdded.year == now.year &&
        dateAdded.month == now.month &&
        dateAdded.day == now.day;

    final neverWatered = totalCompletions == 0;

    if (addedToday && neverWatered) {
      return true;
    }

    // Compute due date (date part only)
    final dueDate = lastCompleted.add(Duration(days: frequencyInDays));

    // Combine due date with current scheduled time
    final dueMoment = DateTime(
      dueDate.year,
      dueDate.month,
      dueDate.day,
      reminderHour,
      reminderMinute,
    );

    // Thirsty only on/after the scheduled time on the due day
    return !now.isBefore(dueMoment);
  }

  int get growthStage => (growthLevel.clamp(0, 99) ~/ 10);

  String get emoji {
    const flowerStages = [
      '🌰',
      '🌱',
      '🌱',
      '🌿',
      '☘️',
      '🌷',
      '🌷',
      '🌸',
      '🌼',
      '🌻',
    ];

    const houseplantStages = [
      '🌰',
      '🌱',
      '🌱',
      '🌿',
      '🍀',
      '🍀',
      '🪴',
      '🪴',
      '🪴',
      '🌴',
    ];

    const vegetableStages = [
      '🌰',
      '🌱',
      '🌿',
      '🥬',
      '🥬',
      '🥦',
      '🥕',
      '🍅',
      '🌽',
      '🥗',
    ];

    const herbStages = [
      '🌰',
      '🌱',
      '🌿',
      '🌿',
      '🌿',
      '🍃',
      '🍃',
      '🌿',
      '🌿',
      '🌿',
    ];

    const succulentStages = [
      '🌰',
      '🌱',
      '🌵',
      '🌵',
      '🌵',
      '🌵',
      '🌵',
      '🌵',
      '🌵',
      '🌵',
    ];

    const otherStages = [
      '🌰',
      '🌱',
      '🌿',
      '🌿',
      '🍀',
      '🪴',
      '🪴',
      '🌳',
      '🌳',
      '🌲',
    ];

    switch (category.toLowerCase()) {
      case 'flower':
        return flowerStages[growthStage];
      case 'houseplant':
        return houseplantStages[growthStage];
      case 'vegetable':
        return vegetableStages[growthStage];
      case 'herb':
        return herbStages[growthStage];
      case 'succulent':
        return succulentStages[growthStage];
      case 'other':
      default:
        return otherStages[growthStage];
    }
  }

  void water({required int reminderHour, required int reminderMinute}) {
    final now = DateTime.now();

    // Anchor lastCompleted to today's scheduled time
    final scheduledToday = DateTime(
      now.year,
      now.month,
      now.day,
      reminderHour,
      reminderMinute,
    );

    final previousLastCompleted = lastCompleted;

    int progression;
    switch (category.toLowerCase()) {
      case 'flower':
      case 'vegetable':
        progression = 2;
        break;
      case 'houseplant':
      case 'herb':
      case 'succulent':
      case 'other':
      default:
        progression = 1;
    }

    growthLevel = (growthLevel + progression).clamp(0, 99);
    lastCompleted = scheduledToday;
    totalCompletions++;

    final daysSinceLast = now.difference(previousLastCompleted).inDays;

    if (daysSinceLast <= frequencyInDays) {
      currentStreak++;
      if (currentStreak > longestStreak) {
        longestStreak = currentStreak;
      }
    } else {
      currentStreak = 1;
    }
  }

  void unwater() {
    int progression;
    switch (category.toLowerCase()) {
      case 'flower':
      case 'vegetable':
        progression = 2;
        break;
      case 'houseplant':
      case 'herb':
      case 'succulent':
      case 'other':
      default:
        progression = 1;
    }

    growthLevel = (growthLevel - progression).clamp(0, 99);
    totalCompletions = totalCompletions > 0 ? totalCompletions - 1 : 0;

    if (currentStreak > 0) {
      currentStreak--;
    }

    lastCompleted = DateTime.now().subtract(
      Duration(days: frequencyInDays + 1),
    );
  }

  // Convert to Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'frequencyInDays': frequencyInDays,
      'lastCompleted': lastCompleted.toIso8601String(),
      'dateAdded': dateAdded.toIso8601String(),
      'growthLevel': growthLevel,
      'totalCompletions': totalCompletions,
      'positionX': positionX,
      'positionY': positionY,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
    };
  }

  // Create from Map
  factory Plant.fromMap(Map<String, dynamic> map) {
    return Plant(
      id: map['id'],
      name: map['name'],
      category: map['category'] ?? 'Flower',
      frequencyInDays: map['frequencyInDays'] ?? 1,
      lastCompleted: map['lastCompleted'] != null
          ? DateTime.parse(map['lastCompleted'])
          : DateTime.now().subtract(const Duration(days: 365)),
      dateAdded: map['dateAdded'] != null
          ? DateTime.parse(map['dateAdded'])
          : DateTime.now(),
      growthLevel: map['growthLevel'] ?? 0,
      totalCompletions: map['totalCompletions'] ?? 0,
      positionX: map['positionX'] != null
          ? (map['positionX'] as num).toDouble()
          : null,
      positionY: map['positionY'] != null
          ? (map['positionY'] as num).toDouble()
          : null,
      currentStreak: map['currentStreak'] ?? 0,
      longestStreak: map['longestStreak'] ?? 0,
    );
  }

  // Stringify / Parse
  static String encode(List<Plant> plants) => json.encode(
    plants.map<Map<String, dynamic>>((plant) => plant.toMap()).toList(),
  );

  static List<Plant> decode(String plants) =>
      (json.decode(plants) as List<dynamic>)
          .map<Plant>((item) => Plant.fromMap(item))
          .toList();
}
