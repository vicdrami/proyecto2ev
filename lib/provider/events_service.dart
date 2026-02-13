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
  List<Event> filteredEvents = [];


  /* Variables de ordenación y filtrado */
    bool? sortDateAsc;
    bool? sortPriceAsc;
    bool showFavoritesOnly = false;
    bool showPastEvents = true;

  EventsService() {
    loadEvents();
  }

  /* Carga los eventos desde el servidor y el almacenamiento local */
  loadEvents() {
    getEvents().then((value) {
      events = value;
      filteredEvents = value;
      applyFilters();
    });
  }

  /* Listar los eventos */
  Future <List<Event>> getEvents() async {
    List<Event> loadedEvents = []; 

    /* Lista los eventos desde el almacenamiento local */
      /*final prefs = await SharedPreferences.getInstance();

      final localJson = prefs.getString('eventos');

      if (localJson != null && localJson.isNotEmpty) {
        final Map<String, dynamic> localMap = jsonDecode(localJson);
        final List<dynamic> localList = localMap['eventos'];

        for (var item in localList) {
          loadedEvents.add(Event.fromJson(item));
        }
      }*/

    /* Lista los eventos desde el servidor (archivo JSON) */
      final uri = Uri.parse('http://localhost:3000/eventos');

      final response = await http.get(uri).timeout(const Duration(seconds: 3));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        List jsonList = jsonDecode(response.body);

        for (var item in jsonList) {
          Event event = Event.fromJson(item);

          // Evitamos duplicados (si ya existe en local, no lo añadimos)
          if (!loadedEvents.any((e) => e.id == event.id)) {
            loadedEvents.add(event);
          }
        }
      } else {
        debugPrint('Error: ${response.statusCode}');
        events = [];
      }

    return loadedEvents;
  }

  /* Crear evento y cargarlos todos */
  Future <Event?> createEvent(Event event) async {
    try {
      final uri = Uri.parse('http://localhost:3000/eventos');

      final response = await http.post(
        uri, 
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(event.toJson())).timeout(const Duration(seconds: 3)
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final createdEvent = Event.fromJson(jsonDecode(response.body)['eventos'][0]);

        // Añadimos el evento nuevo si no existe
        if (!events.any((e) => e.id == createdEvent.id)) {
          events.add(createdEvent);
        }

        await loadEvents();
        notifyListeners();
        return createdEvent;
      } else {
        debugPrint('Error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error: $e');
    }
    return null;
  }

  /* Borrar evento y cargarlos todos*/
  Future <Event?> deleteEvent(Event event) async {
    try {
      final uri = Uri.parse('http://localhost:3000/eventos/${event.id}');

      final response = await http.delete(uri).timeout(const Duration(seconds: 3));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        events.removeWhere((e) => e.id == event.id);
        await loadEvents();
        notifyListeners();
        return event;
      } else {
        debugPrint('Error: ${response.statusCode}');
      }

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
        final json = jsonDecode(response.body)['eventos'];
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


  /// Apartado de filtros

  /* Filtrar solo favoritos */
  void filterFavorites(bool value) {
    showFavoritesOnly = value;
    applyFilters();
  }

  /* Mostrar/ocultar eventos pasados */
  void filterPastEvents(bool value) {
    showPastEvents = value;
    applyFilters();
  }

  /* Ordenar por fecha */
  void sortByDate() {
    sortDateAsc = sortDateAsc == null ? true : !sortDateAsc!;
    resetSortDate();
    applyFilters();
  }

  /* Ordenar por precio */
  void sortByPrice() {
    sortPriceAsc = sortPriceAsc == null ? true : !sortPriceAsc!;
    resetSortPrice();
    applyFilters();
  }

  resetSortDate() => sortDateAsc = null;
  resetSortPrice() => sortPriceAsc = null;

  /* Aplica los filtros y ordenaciones seleccionados */
  void applyFilters() {
    filteredEvents = events.where((event) {
      // Filtrar por favoritos
      if (showFavoritesOnly && !event.isFavorite) return false;

      // Filtrar por eventos pasados
      if (!showPastEvents && event.date.isBefore(DateTime.now())) return false;

      // Si el vento pasa todos los filtros, se incluye en la lista filtrada
      return true;
    }).toList();

    // Ordenar por fecha
    if (sortDateAsc != null) {
      filteredEvents.sort((a, b) => a.date.compareTo(b.date));
      if (!sortDateAsc!) filteredEvents = filteredEvents.reversed.toList();
    }

    // Ordenar por precio
    if (sortPriceAsc != null) {
      filteredEvents.sort((a, b) => a.price.compareTo(b.price));
      if (!sortPriceAsc!) filteredEvents = filteredEvents.reversed.toList();
    }

    notifyListeners();
  }
}