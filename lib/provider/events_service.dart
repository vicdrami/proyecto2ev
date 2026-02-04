import 'dart:collection';
import 'dart:convert';
import 'package:proyecto2ev/models/event.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
//import 'package:http/http.dart' as http;

class EventsService extends ChangeNotifier {
  Future isFavorite() async{
    
  }

  /*EventsService() {
    loadTasks();
  }*/

  //List<Event> tasks = [];   

  /*Future <void> loadTasks() async {
    try {
      final uri = Uri.parse('http://localhost:3000/tasks');

      final response = await http.get(uri).timeout(const Duration(seconds: 3));
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final List jsonList = jsonDecode(response.body);

        tasks = [];
        for (var item in jsonList) {
          Task task = Task.fromJson(item);
          tasks.add(task);
        }
      } else {
        debugPrint('Error: ${response.statusCode}');
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  Future <void> createTask(Task task) async {
    try {
      final uri = Uri.parse('http://localhost:3000/tasks');

      final response = await http.post(
        uri, 
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(task.toJson())).timeout(const Duration(seconds: 3));
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final json = jsonDecode(response.body);
        final createdTask = Task.fromJson(json);

        tasks.add(createdTask);
        await loadTasks();
      } else {
        debugPrint('Error: ${response.statusCode}');
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  Future <Task?> deleteTask(Task task) async {
    try {
      final uri = Uri.parse('http://localhost:3000/tasks/${task.id}');

      final response = await http.delete(uri).timeout(const Duration(seconds: 3));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        tasks.removeWhere((t) => t.id == task.id);
        notifyListeners();
        return null;
      } else {
        debugPrint('Error: ${response.statusCode}');
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error: $e');
    }
    return null;
  }

  Future <void> updateTask(Task task) async {
    try {
      if (task.id == null) return;

      final uri = Uri.parse('http://localhost:3000/tasks/${task.id}');

      final response = await http.put(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(task.toJson()),
      )
      .timeout(const Duration(seconds: 3));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final json = jsonDecode(response.body);
        final updateTask = Task.fromJson(json);

        final index = tasks.indexWhere((t) => t.id == task.id);

        if (index != -1) {
          tasks[index] = updateTask;
          notifyListeners();
        }
      } else {
        debugPrint('Error: ${response.statusCode}');
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error: $e');
    }
    return null;
  }*/
}