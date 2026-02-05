import 'dart:collection';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:proyecto2ev/models/event.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class EventsService extends ChangeNotifier {
  List<Event> events = [];   

  EventsService() {
    loadEvents();
  }

  Future <void> loadEvents() async {
    events = [];

    final prefs = await SharedPreferences.getInstance();
      final localJson = prefs.getString('eventos');

      if (localJson != null && localJson.isNotEmpty) {
        final Map<String, dynamic> decoded = jsonDecode(localJson);
        final List<dynamic> localList = decoded['eventos'];
        events.addAll(localList.map((e) => Event.fromJson(e)));

        for (var item in localList) {
          events.add(Event.fromJson(item));
        }
      }


    final uri = Uri.parse('http://localhost:3000/events');
    final response = await http.get(uri).timeout(const Duration(seconds: 3));

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final Map<String, dynamic> decoded = jsonDecode(response.body);
      final List<dynamic> jsonList = decoded['eventos'];

      for (var item in jsonList) {
        Event event = Event.fromJson(item);
        events.add(event);
      }
    } else {
      debugPrint('Error: ${response.statusCode}');
      events = [];
    }

    notifyListeners();
  }

  Future pickImage() async {
    final XFile? image;
    try {
      image = await ImagePicker().pickImage(source: ImageSource.gallery);

      return image;
    } on PlatformException catch (e) {
      print('Failed to pick image:$e');
    }
  }

/*
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