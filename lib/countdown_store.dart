import 'package:flutter/foundation.dart';

import 'countdown_event.dart';

class CountdownStore extends ChangeNotifier {
  CountdownStore({List<CountdownEvent>? initialEvents})
      : _events = [...?initialEvents] {
    _sortByTarget();
  }

  final List<CountdownEvent> _events;

  List<CountdownEvent> get events => List.unmodifiable(_events);

  int get length => _events.length;

  CountdownEvent? nextAfter(DateTime now) {
    for (final event in _events) {
      if (event.target.isAfter(now)) {
        return event;
      }
    }
    return null;
  }

  void add(CountdownEvent event) {
    _events.add(event);
    _sortByTarget();
    notifyListeners();
  }

  void remove(String id) {
    final previousLength = _events.length;
    _events.removeWhere((event) => event.id == id);
    if (_events.length != previousLength) {
      notifyListeners();
    }
  }

  void _sortByTarget() {
    _events.sort((a, b) => a.target.compareTo(b.target));
  }
}
