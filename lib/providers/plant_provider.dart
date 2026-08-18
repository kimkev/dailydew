import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/notification_service.dart';
import '../models/plant.dart';

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
  Future<void> addTask(Task task) async {
    _tasks.add(task);

    await _saveTasks();

    final notificationsEnabled = await NotificationService()
        .areNotificationsEnabled();

    if (notificationsEnabled && !task.isDone) {
      final thirstyPlantNames = _tasks
          .where((plant) => !plant.isDone)
          .map((plant) => plant.name)
          .toList();

      await NotificationService().scheduleReminderForCurrentlyThirstyPlants(
        plantNames: thirstyPlantNames,
      );
    }

    notifyListeners();
  }

  //  Action: Toggle/Growth
  Future<void> toggleTask(int index) async {
    final task = _tasks[index];

    if (task.isDone) {
      task.unwater();
    } else {
      task.water();

      final notificationsEnabled = await NotificationService()
          .areNotificationsEnabled();

      if (notificationsEnabled) {
        await NotificationService().scheduleWateringSummary(
          plantNames: [task.name],
          days: task.frequencyInDays,
        );
      }
    }

    await _saveTasks();
    notifyListeners();
  }

  //  Action: Delete
  void deleteTask(int index) {
    _tasks.removeAt(index);
    _saveTasks();
    notifyListeners();
  }

  // Action: Water All Plants
  Future<void> waterAll() async {
    final wateredTasks = <Task>[];

    for (final task in _tasks) {
      if (!task.isDone) {
        task.water();
        wateredTasks.add(task);
      }
    }

    if (wateredTasks.isNotEmpty) {
      final notificationsEnabled = await NotificationService()
          .areNotificationsEnabled();

      if (notificationsEnabled) {
        final shortestFrequency = wateredTasks
            .map((task) => task.frequencyInDays)
            .reduce((a, b) => a < b ? a : b);

        await NotificationService().scheduleWateringSummary(
          plantNames: wateredTasks.map((task) => task.name).toList(),
          days: shortestFrequency,
        );
      }
    }

    await _saveTasks();
    notifyListeners();
  }

  // Action: Edit an existing plant
  void editTask(String id, String newName, int newFrequency) {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index != -1) {
      _tasks[index].name = newName;
      _tasks[index].frequencyInDays = newFrequency;

      // If we change the frequency, we should reschedule the notification
      NotificationService().schedulePlantReminder(
        id: _tasks[index].id.hashCode,
        plantName: newName,
        days: newFrequency,
      );

      _saveTasks();
      notifyListeners();
    }
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

  // Update the user name and save to disk
  Future<void> updateUserName(String newName) async {
    _userName = newName;

    // Save to SharedPreferences so it persists after restart
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userName', newName);

    // Tell all listening widgets (like HomeScreen) to rebuild
    notifyListeners();
  }

  // Update position in real-time (smooth)
  void moveTask(String id, double x, double y) {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index != -1) {
      // 1. Horizontal Clamping (0.05 is ~5% from the fence)
      double clampedX = x.clamp(0.05, 0.95);
      // 2. Vertical Clamping
      // 0.03 (Top) allows the plant to sit much closer to the top fence
      // 0.92 (Bottom) leaves a tiny bit of extra room for the name label
      double clampedY = y.clamp(0.03, 0.92);

      // 2. ONLY update and notify if the position is actually different
      if (_tasks[index].positionX != clampedX ||
          _tasks[index].positionY != clampedY) {
        _tasks[index].positionX = clampedX;
        _tasks[index].positionY = clampedY;
        notifyListeners(); // The "broadcast" to the UI
      }
    }
  }

  // Save the final position to disk (only called when finger lifts up)
  void savePositions() {
    _saveTasks();
  }

  void undoWatering(String id) {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index != -1) {
      _tasks[index].unwater();
      _saveTasks();
      notifyListeners();
    }
  }
}
