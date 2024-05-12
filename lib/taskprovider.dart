import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'task.dart';

class TaskProvider with ChangeNotifier {
  List<Task> _tasks = [];

  TaskProvider() {
    loadTasks();
  }

  List<Task> get tasks => _tasks;

  void addTask(String title) {
    final newTask = Task(id: DateTime.now().toString(), title: title);
    _tasks.add(newTask);
    saveTasks();
    notifyListeners();
  }

  void editTask(String id, String newTitle) {
    final index = _tasks.indexWhere((task) => task.id == id);
    if (index != -1) {
      _tasks[index] = Task(
        id: _tasks[index].id,
        title: newTitle,
        isCompleted: _tasks[index].isCompleted,
      );
      saveTasks();
      notifyListeners();
    }
  }

  void deleteTask(String id) {
    _tasks.removeWhere((task) => task.id == id);
    saveTasks();
    notifyListeners();
  }

  void toggleTaskCompletion(String id) {
    final index = _tasks.indexWhere((task) => task.id == id);
    if (index != -1) {
      _tasks[index].isCompleted = !_tasks[index].isCompleted;
      saveTasks();
      notifyListeners();
    }
  }

  Future<void> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('tasks');
    if (data != null) {
      final List<dynamic> jsonTasks = jsonDecode(data);
      _tasks = jsonTasks.map((task) => Task(
        id: task['id'],
        title: task['title'],
        isCompleted: task['isCompleted'],
      )).toList();
      notifyListeners();
    }
  }

  Future<void> saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final data = jsonEncode(_tasks.map((task) => {
      'id': task.id,
      'title': task.title,
      'isCompleted': task.isCompleted,
    }).toList());
    await prefs.setString('tasks', data);
  }
}
