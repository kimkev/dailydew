import 'dart:convert';

class Plant {
  final String id;
  String name;
  bool isDone;
  String category; // Plant type: Flower, Houseplant, Cactus, or Tree
  int frequencyInDays; // e.g., 1 for daily, 7 for weekly
  DateTime lastCompleted;
  DateTime dateAdded;
  int growthLevel;
  int totalCompletions;
  double? positionX; // 0.0 to 1.0
  double? positionY; // 0.0 to 1.0
  int currentStreak; // ← ADD THIS
  int longestStreak; // ← ADD THIS

  Plant({
    required this.id,
    required this.name,
    this.isDone = false,
    this.category = 'Flower',
    this.frequencyInDays = 1,
    required this.lastCompleted,
    DateTime? dateAdded,
    this.growthLevel = 0, // Starts at 0
    this.totalCompletions = 0,
    this.positionX,
    this.positionY,
    this.currentStreak = 0, // ← DEFAULT
    this.longestStreak = 0, // ← DEFAULT
  }) : dateAdded = dateAdded ?? DateTime.now();

  bool isThirstyAt({
    required DateTime now,
    required int reminderHour,
    required int reminderMinute,
  }) {
    final minimumDueTime = lastCompleted.add(Duration(days: frequencyInDays));

    final scheduledToday = DateTime(
      now.year,
      now.month,
      now.day,
      reminderHour,
      reminderMinute,
    );

    if (now.isBefore(minimumDueTime)) {
      return false;
    }

    return !now.isBefore(scheduledToday);
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

    switch (category.toLowerCase()) {
      case 'vegetable':
        return vegetableStages[growthStage];
      case 'herb':
        return herbStages[growthStage];
      case 'succulent':
        return succulentStages[growthStage];
      case 'houseplant':
      case 'foliage':
        return houseplantStages[growthStage];
      case 'flower':
      default:
        return flowerStages[growthStage];
    }
  }

  void water() {
    final previousLastCompleted = lastCompleted;
    final now = DateTime.now();

    int progression;
    switch (category.toLowerCase()) {
      case 'flower':
      case 'vegetable':
        progression = 2;
        break;
      case 'houseplant':
      case 'herb':
      case 'succulent':
      default:
        progression = 1;
    }

    growthLevel = (growthLevel + progression).clamp(0, 99);
    lastCompleted = now;
    isDone = true;
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
      default:
        progression = 1;
    }

    growthLevel = (growthLevel - progression).clamp(0, 99);
    isDone = false;
    totalCompletions--;

    // Revert streak
    if (currentStreak > 0) {
      currentStreak--;
    }
  }

  // Convert to Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'isDone': isDone,
      'category': category,
      'frequencyInDays': frequencyInDays,
      'lastCompleted': lastCompleted.toIso8601String(),
      'dateAdded': dateAdded.toIso8601String(),
      'growthLevel': growthLevel,
      'totalCompletions': totalCompletions,
      'positionX': positionX,
      'positionY': positionY,
      'currentStreak': currentStreak, // ← ADD THIS
      'longestStreak': longestStreak, // ← ADD THIS
    };
  }

  // Create from Map
  factory Plant.fromMap(Map<String, dynamic> map) {
    return Plant(
      id: map['id'],
      name: map['name'],
      isDone: map['isDone'],
      category: map['category'] ?? 'Flower',
      frequencyInDays: map['frequencyInDays'] ?? 1,
      lastCompleted: map['lastCompleted'] != null
          ? DateTime.parse(map['lastCompleted'])
          : DateTime.now(), // If missing, just use "now"
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
      currentStreak: map['currentStreak'] ?? 0, // ← ADD THIS
      longestStreak: map['longestStreak'] ?? 0, // ← ADD THIS
    );
  }

  // 3. Stringify: Turns a List of Plants into a single String
  static String encode(List<Plant> plants) => json.encode(
    plants.map<Map<String, dynamic>>((plant) => plant.toMap()).toList(),
  );

  // 4. Parse: Turns a String back into a List of Plants
  static List<Plant> decode(String plants) =>
      (json.decode(plants) as List<dynamic>)
          .map<Plant>((item) => Plant.fromMap(item))
          .toList();
}
