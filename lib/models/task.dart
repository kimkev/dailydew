import 'dart:convert';

class Task {
  final String id;
  String name;
  bool isDone;
  String category; // Plant type: Flower, Houseplant, Cactus, or Tree
  int frequencyInDays; // e.g., 1 for daily, 7 for weekly
  DateTime lastCompleted;
  int growthLevel;
  int totalCompletions;
  double? positionX; // 0.0 to 1.0
  double? positionY; // 0.0 to 1.0

  Task({
    required this.id,
    required this.name,
    this.isDone = false,
    this.category = 'General',
    this.frequencyInDays = 1,
    required this.lastCompleted,
    this.growthLevel = 0, // Starts at 0
    this.totalCompletions = 0,
    this.positionX,
    this.positionY,
  });

  // This check ignores the specific time and only cares about calendar dates
  bool get isThirsty {
    // 1. Get today's date at midnight (00:00:00)
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // 2. Get the date it was last completed at midnight
    final lastDate = DateTime(
      lastCompleted.year,
      lastCompleted.month,
      lastCompleted.day,
    );

    // 3. Calculate the difference in days
    final daysSinceLast = today.difference(lastDate).inDays;

    // It's "thirsty" if the days passed is greater or equal to frequency
    return daysSinceLast >= frequencyInDays;
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

    const cactusStages = [
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

    const treeStages = [
      '🌰',
      '🌱',
      '🌱',
      '🌿',
      '🌿',
      '🌲',
      '🌲',
      '🌲',
      '🌳',
      '🌳',
    ];

    switch (category.toLowerCase()) {
      case 'cactus':
        return cactusStages[growthStage];
      case 'tree':
        return treeStages[growthStage];
      case 'houseplant':
      case 'foliage':
        return houseplantStages[growthStage];
      case 'flower':
      default:
        return flowerStages[growthStage];
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
      'lastCompleted': lastCompleted
          .toIso8601String(), // Dates must be strings in JSON
      'growthLevel': growthLevel,
      'totalCompletions': totalCompletions,
      'positionX': positionX,
      'positionY': positionY,
    };
  }

  // Create from Map
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      name: map['name'],
      isDone: map['isDone'],
      category: map['category'] ?? 'General',
      frequencyInDays: map['frequencyInDays'] ?? 1,
      lastCompleted: map['lastCompleted'] != null
          ? DateTime.parse(map['lastCompleted'])
          : DateTime.now(), // If missing, just use "now"
      growthLevel: map['growthLevel'] ?? 0,
      totalCompletions: map['totalCompletions'] ?? 0,
      positionX: map['positionX'] != null
          ? (map['positionX'] as num).toDouble()
          : null,
      positionY: map['positionY'] != null
          ? (map['positionY'] as num).toDouble()
          : null,
    );
  }

  // 3. Stringify: Turns a List of Tasks into a single String
  static String encode(List<Task> tasks) => json.encode(
    tasks.map<Map<String, dynamic>>((task) => task.toMap()).toList(),
  );

  // 4. Parse: Turns a String back into a List of Tasks
  static List<Task> decode(String tasks) =>
      (json.decode(tasks) as List<dynamic>)
          .map<Task>((item) => Task.fromMap(item))
          .toList();
}
