import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';

class TaskProvider extends ChangeNotifier {
  List<Task> _tasks = [];
  String? _selectedTaskId;
  String _userName = "Gardener";
  String get userName => _userName;
  // Getter to see tasks from the outside
  List<Task> get tasks => _tasks;
  String? get selectedTaskId => _selectedTaskId;

  // Initialize and Load
  TaskProvider() {
    loadTasks();
  }

  void selectTask(String? id) {
    _selectedTaskId = id;
    notifyListeners();
  }

  Future<void> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();

    // Load the name we saved during onboarding
    // If it's not there, we default to "Gardener"
    _userName = prefs.getString('userName') ?? "Gardener";
    
    final String? tasksString = prefs.getString('saved_tasks');

    if (tasksString != null) {
      // Step A: Decode the string into a list of Tasks
      _tasks = Task.decode(tasksString);

      // Step B: The "Smart Reset" logic
      // We loop through every task we just loaded
      for (var task in _tasks) {
        // If the calculated 'isThirsty' is true, reset the checkmark
        if (task.isThirsty) {
          task.isDone = false;
        }
      }
    }

    // Step C: Tell the UI that we have fresh data
    notifyListeners();
  }

  //  Save Logic
  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('saved_tasks', Task.encode(_tasks));
  }

  // Action: Add
  void addTask(Task task) {
    _tasks.add(task);
    _saveTasks();
    notifyListeners();
  }

  //  Action: Toggle/Growth
  void toggleTask(int index) {
    // 1. Flip the boolean (Checked becomes Unchecked, or vice-versa)
    _tasks[index].isDone = !_tasks[index].isDone;

    // 2. Logic for when the task is marked as "Done"
    if (_tasks[index].isDone) {
      // Record the exact time it was watered
      _tasks[index].lastCompleted = DateTime.now();

      // Increment total completions
      _tasks[index].totalCompletions += 1;

      // Keep your existing growth logic (or adjust as you like)
      _tasks[index].growthLevel += 5;
    }

    // 3. Save to phone and refresh UI
    _saveTasks();
    notifyListeners();
  }

  //  Action: Delete
  void deleteTask(int index) {
    _tasks.removeAt(index);
    _saveTasks();
    notifyListeners();
  }

  // garden position
  void updateTaskPosition(String id, double x, double y) {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index != -1) {
      _tasks[index].positionX = x;
      _tasks[index].positionY = y;
      _saveTasks();
      notifyListeners();
    }
  }
}
