import 'package:flutter/material.dart';
import '../models/destination.dart';
import '../services/realtime_service.dart';

class DestinationProvider with ChangeNotifier {
  final RealtimeService _realtimeService = RealtimeService();
  List<Destination> _destinations = [];

  List<Destination> get destinations => _destinations;

  Future<void> loadDestinations() async {
    _destinations = await _realtimeService.getDestinations();
    notifyListeners();
  }

  Future<void> addDestination(Destination destination) async {
    try {
      await _realtimeService.addDestination(destination);
      await loadDestinations(); // Reload list
    } catch (e) {
      // Handle error, perhaps notify user
      rethrow;
    }
  }

  Future<void> updateDestination(String id, Map<String, dynamic> data) async {
    await _realtimeService.updateDestination(id, data);
    await loadDestinations();
  }

  Future<void> deleteDestination(String id) async {
    await _realtimeService.deleteDestination(id);
    await loadDestinations();
  }
}