import 'dart:convert';

class Task {
  final String id;
  String name;
  bool isDone;
  String category; // e.g., "Plant", "Health", "Home"
  int frequencyInDays; // e.g., 1 for daily, 7 for weekly
  DateTime lastCompleted;
  int growthLevel;
  int totalCompletions;

  Task({
    required this.id,
    required this.name,
    this.isDone = false,
    this.category = 'General',
    this.frequencyInDays = 1,
    required this.lastCompleted,
    this.growthLevel = 0, // Starts at 0
    this.totalCompletions = 0,
  });

  // This check tells us if the time since last completed is greater than the frequency
  bool get isThirsty {
    final nextWateringDate = lastCompleted.add(Duration(days: frequencyInDays));
    return DateTime.now().isAfter(nextWateringDate);
  }

  // Centralized emoji logic
  String get emoji {
    if (growthLevel < 20) return '🌱';
    if (growthLevel < 40) return '🪴';
    if (growthLevel < 60) return '🌿';
    if (growthLevel < 80) return '☘️';
    return '🌸';
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
