import 'package:flutter/material.dart';
import 'package:proyecto2ev/models/event.dart';
import 'package:proyecto2ev/models/event.dart';

class SelectedEventNotifier extends ChangeNotifier {
  static Event? _selectedEvent;

  Event? get selectedEvent => _selectedEvent;

  set selectedEvent(Event? event) {
    _selectedEvent = event;
    notifyListeners();
  }

  void clear() {
    _selectedEvent = null;
    notifyListeners();
  }

  bool get hasEvent => _selectedEvent != null;
}