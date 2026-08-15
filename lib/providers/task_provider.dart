import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';

class TaskProvider extends ChangeNotifier {
  List<Task> _tasks = [];

  // Getter to see tasks from the outside
  List<Task> get tasks => _tasks;

  // 1. Initialize and Load
  TaskProvider() {
    loadTasks();
  }

  Future<void> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
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

  // 2. Save Logic
  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('saved_tasks', Task.encode(_tasks));
  }

  // 3. Action: Add
  void addTask(Task task) {
    _tasks.add(task);
    _saveTasks();
    notifyListeners();
  }

  // 4. Action: Toggle/Growth
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

  // 5. Action: Delete
  void deleteTask(int index) {
    _tasks.removeAt(index);
    _saveTasks();
    notifyListeners();
  }
}
