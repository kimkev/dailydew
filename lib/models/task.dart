import 'dart:convert';

class Task {
  final String id;
  String name;
  bool isDone;

  Task({
    required this.id,
    required this.name,
    this.isDone = false,
  });

  // 1. Convert Task object to a Map 
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'isDone': isDone,
    };
  }

  // 2. Create a Task object from a Map
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      name: map['name'],
      isDone: map['isDone'],
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