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
      _tasks = Task.decode(tasksString);
    }
    notifyListeners(); // This is the "Magic" - it tells all UI to rebuild
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
    _tasks[index].isDone = !_tasks[index].isDone;
    if (_tasks[index].isDone) {
      _tasks[index].growthLevel += 10;
    }
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