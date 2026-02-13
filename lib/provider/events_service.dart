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

  /* Carga los eventos */
  Future <void> loadEvents() async {
    events = [];
 
    /* Carga los eventos desde el almacenamiento local */
      final prefs = await SharedPreferences.getInstance();

      final localJson = prefs.getString('eventos');

      if (localJson != null && localJson.isNotEmpty) {
        final List<dynamic> localList = jsonDecode(localJson);

        for (var item in localList) {
          events.add(Event.fromJson(item));
        }
      }

    /* Carga los eventos desde el servidor (archivo JSON) */
      final uri = Uri.parse('http://localhost:3000/eventos');

      final response = await http.get(uri).timeout(const Duration(seconds: 3));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final List<dynamic> jsonList = jsonDecode(response.body);

        for (var item in jsonList) {
          Event event = Event.fromJson(item);

          // Evitamos duplicados: si ya existe en local, no lo añadimos
          if (!events.any((e) => e.id == event.id)) {
            events.add(event);
          }
        }
      } else {
        debugPrint('Error: ${response.statusCode}');
        events = [];
      }

    notifyListeners();
  }

  /* Crear evento y cargarlos todos*/
  Future <void> createEvent(Event event) async {
    try {
      final uri = Uri.parse('http://localhost:3000/eventos');

      final response = await http.post(
        uri, 
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(event.toJson())).timeout(const Duration(seconds: 3)
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final json = jsonDecode(response.body);
        final createdEvent = Event.fromJson(json);

        // Añadimos el evento nuevo si no existe
        if (!events.any((e) => e.id == createdEvent.id)) {
          events.add(createdEvent);
        }

        await loadEvents();
      } else {
        debugPrint('Error: ${response.statusCode}');
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  /* Borrar evento y cargarlos todos*/
  Future <Event?> deleteEvent(Event event) async {
    try {
      final uri = Uri.parse('http://localhost:3000/eventos/${events.id}');

      final response = await http.delete(uri).timeout(const Duration(seconds: 3));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        events.removeWhere((e) => e.id == event.id);
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

  /* Modificar evento y cargarlos todos */
  Future<Event?> modifyEvent(Event event) async {
    try {
      final uri = Uri.parse('http://localhost:3000/eventos/${event.id}');

      final response = await http.put(
        uri, 
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(event.toJson())).timeout(const Duration(seconds: 3)
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final json = jsonDecode(response.body);
        final modifiedEvent = Event.fromJson(json);

        // Actualizamos el evento modificado en la lista local
        final index = events.indexWhere((e) => e.id == event.id);
        if (index != -1) {
          events[index] = modifiedEvent;
        } else {
          events.add(modifiedEvent);
        }

        notifyListeners();
        return modifiedEvent;
      } else {
        debugPrint('Error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error: $e');
    }
    return null; 
  }

   /* Guarda la imagen seleccionada en el almacenamiento local */
  Future pickImage() async {
    final XFile? image;
    try {
      image = await ImagePicker().pickImage(source: ImageSource.gallery);
      return image;
    } on PlatformException catch (e) {
      print('Failed to pick image:$e');
    }
  }

  /* Marca o desmarca un evento como favorito y guarda la lista de favoritos */
  Future<void> markFavorite(Event event) async {
    final prefs = await SharedPreferences.getInstance();

    final favorites = prefs.getStringList('favorites') ?? [];

    if (favorites.contains(event.id.toString())) {
      favorites.remove(event.id.toString());
      event.isFavorite = false;
    } else {
      favorites.add(event.id.toString());
      event.isFavorite = true;
    }

    await prefs.setStringList('favorites', favorites);
  }

}