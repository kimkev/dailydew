import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/plant.dart';
import '../services/notification_service.dart';

class PlantProvider extends ChangeNotifier {
  List<Plant> _plants = [];
  String? _selectedPlantId;
  String _userName = 'Gardener';

  int _reminderHour = 9;
  int _reminderMinute = 0;

  int get reminderHour => _reminderHour;
  int get reminderMinute => _reminderMinute;

  String get userName => _userName;
  List<Plant> get plants => _plants;
  String? get selectedPlantId => _selectedPlantId;

  PlantProvider() {
    loadPlants();
  }

  void selectPlant(String? id) {
    _selectedPlantId = id;
    notifyListeners();
  }

  Future<void> loadPlants() async {
    final prefs = await SharedPreferences.getInstance();

    _reminderHour = prefs.getInt('reminderHour') ?? 9;
    _reminderMinute = prefs.getInt('reminderMinute') ?? 0;
    _userName = prefs.getString('userName') ?? 'Gardener';

    final savedPlants = prefs.getString('saved_tasks');

    if (savedPlants != null) {
      _plants = Plant.decode(savedPlants);
    }

    notifyListeners();
  }

  bool isPlantThirsty(Plant plant) {
    return plant.isThirstyAt(
      now: DateTime.now(),
      reminderHour: _reminderHour,
      reminderMinute: _reminderMinute,
    );
  }

  Future<void> _savePlants() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('saved_tasks', Plant.encode(_plants));
  }

  Future<void> addPlant(Plant plant) async {
    _plants.add(plant);

    await _savePlants();

    final notificationsEnabled = await NotificationService()
        .areNotificationsEnabled();

    if (notificationsEnabled) {
      // If the plant is already thirsty when added, schedule a summary
      if (isPlantThirsty(plant)) {
        final thirstyPlantNames = _plants
            .where(isPlantThirsty)
            .map((p) => p.name)
            .toList();

        await NotificationService().scheduleReminderForCurrentlyThirstyPlants(
          plantNames: thirstyPlantNames,
        );
      } else {
        // If it's NOT thirsty yet, schedule a future reminder using its unique ID
        await NotificationService().schedulePlantReminder(
          id: plant.id.hashCode, // <--- THIS CONVERTS STRING TO INT
          plantName: plant.name,
          days: plant.frequencyInDays,
        );
      }
    }

    notifyListeners();
  }

  Future<void> togglePlant(int index) async {
    final plant = _plants[index];

    if (isPlantThirsty(plant)) {
      plant.water();

      final notificationsEnabled = await NotificationService()
          .areNotificationsEnabled();

      if (notificationsEnabled) {
        // Cancel old per-plant reminder
        await NotificationService().cancelNotification(plant.id.hashCode);

        // Schedule new summary based on this watering
        await NotificationService().scheduleWateringSummary(
          plantNames: [plant.name],
          days: plant.frequencyInDays,
        );
      }
    } else {
      plant.unwater();
    }

    await _savePlants();
    notifyListeners();
  }

  void deletePlant(int index) {
    final plant = _plants[index];

    // Cancel the specific notification for this plant so it doesn't fire
    // after the plant is deleted
    NotificationService().cancelNotification(plant.id.hashCode);

    _plants.removeAt(index);
    _savePlants();
    notifyListeners();
  }

  Future<void> waterAllPlants() async {
    final wateredPlants = <Plant>[];

    for (final plant in _plants) {
      if (isPlantThirsty(plant)) {
        plant.water();
        wateredPlants.add(plant);
      }
    }

    if (wateredPlants.isNotEmpty) {
      final notificationsEnabled = await NotificationService()
          .areNotificationsEnabled();

      if (notificationsEnabled) {
        final shortestFrequency = wateredPlants
            .map((plant) => plant.frequencyInDays)
            .reduce((a, b) => a < b ? a : b);

        await NotificationService().scheduleWateringSummary(
          plantNames: wateredPlants.map((plant) => plant.name).toList(),
          days: shortestFrequency,
        );
      }
    }

    await _savePlants();
    notifyListeners();
  }

  void editPlant(
    String id,
    String newName,
    int newFrequency,
    int newGrowthLevel,
    String newCategory,
  ) {
    final index = _plants.indexWhere((plant) => plant.id == id);
    if (index == -1) return;

    final plant = _plants[index];

    // Cancel old reminder for this plant
    NotificationService().cancelNotification(plant.id.hashCode);

    plant.name = newName;
    plant.category = newCategory;
    plant.frequencyInDays = newFrequency;
    plant.growthLevel = newGrowthLevel.clamp(0, 100);

    _savePlants();
    notifyListeners();

    // Optionally: if it's not thirsty, schedule a new future reminder
    // (you can do this in Settings when time changes, or here if you prefer)
  }

  void updatePlantPosition(String id, double x, double y) {
    final index = _plants.indexWhere((plant) => plant.id == id);

    if (index != -1) {
      _plants[index].positionX = x;
      _plants[index].positionY = y;

      _savePlants();
      notifyListeners();
    }
  }

  Future<void> updateUserName(String newName) async {
    _userName = newName;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userName', newName);

    notifyListeners();
  }

  void movePlant(String id, double x, double y) {
    final index = _plants.indexWhere((plant) => plant.id == id);

    if (index != -1) {
      final clampedX = x.clamp(0.05, 0.95);
      final clampedY = y.clamp(0.03, 0.92);

      if (_plants[index].positionX != clampedX ||
          _plants[index].positionY != clampedY) {
        _plants[index].positionX = clampedX;
        _plants[index].positionY = clampedY;

        notifyListeners();
      }
    }
  }

  void savePositions() {
    _savePlants();
  }

  void undoPlantWatering(String id) {
    final index = _plants.indexWhere((plant) => plant.id == id);

    if (index != -1) {
      _plants[index].unwater();
      _savePlants();
      notifyListeners();
    }
  }

  // Temporary compatibility methods for existing UI files.
  // We will remove these after refactoring the other files.

  Future<void> addTask(Plant plant) => addPlant(plant);

  Future<void> toggleTask(int index) => togglePlant(index);

  void deleteTask(int index) => deletePlant(index);

  Future<void> waterAll() => waterAllPlants();

  void editTask(
    String id,
    String newName,
    int newFrequency,
    int newGrowthLevel,
    String newCategory, 
  ) {
    editPlant(id, newName, newFrequency, newGrowthLevel, newCategory);
  }

  void updateTaskPosition(String id, double x, double y) {
    updatePlantPosition(id, x, y);
  }

  void moveTask(String id, double x, double y) {
    movePlant(id, x, y);
  }

  void undoWatering(String id) {
    undoPlantWatering(id);
  }
}
