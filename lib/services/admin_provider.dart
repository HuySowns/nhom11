import 'package:flutter/material.dart';
import '../models/destination.dart';
import '../models/booking.dart';
import '../models/user.dart';
import 'realtime_service.dart';

class AdminProvider with ChangeNotifier {
  final RealtimeService _realtimeService = RealtimeService();

  List<Destination> _destinations = [];
  List<Booking> _bookings = [];
  List<AppUser> _users = [];
  bool _isLoading = true;

  List<Destination> get destinations => _destinations;
  List<Booking> get bookings => _bookings;
  List<AppUser> get users => _users;
  bool get isLoading => _isLoading;

  int get totalDestinations => _destinations.length;
  int get totalBookings => _bookings.length;
  int get totalUsers => _users.length;

  double get totalRevenue =>
      _bookings.fold(0.0, (sum, booking) {
        final destination = _destinations
            .firstWhere((d) => d.id == booking.destinationId, orElse: () => Destination(
              id: '',
              name: '',
              location: '',
              description: '',
              price: 0,
              rating: 0,
              imageUrls: [],
            ));
        return sum + destination.price;
      });

  double get averageRating {
    if (_destinations.isEmpty) return 0;
    double totalRating = _destinations.fold(0.0, (sum, d) => sum + d.rating);
    return totalRating / _destinations.length;
  }

  Future<void> loadAllStats() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      await Future.wait([
        _loadDestinations(),
        _loadBookings(),
        _loadUsers(),
      ]);
    } catch (e) {
      print('Error loading stats: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadDestinations() async {
    _destinations = await _realtimeService.getDestinations();
  }

  Future<void> _loadBookings() async {
    _bookings = await _realtimeService.getBookings();
  }

  Future<void> _loadUsers() async {
    _users = await _realtimeService.getUsers();
  }

  Map<String, int> getBookingsByDestination() {
    Map<String, int> stats = {};
    for (var booking in _bookings) {
      final destination = _destinations
          .firstWhere((d) => d.id == booking.destinationId, orElse: () => Destination(
            id: '',
            name: 'Unknown',
            location: '',
            description: '',
            price: 0,
            rating: 0,
            imageUrls: [],
          ));
      stats[destination.name] = (stats[destination.name] ?? 0) + 1;
    }
    return stats;
  }

  List<MapEntry<String, int>> getTopDestinations(int limit) {
    var stats = getBookingsByDestination();
    var sorted = stats.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(limit).toList();
  }

  int getBookingsByMonth(int month) {
    return _bookings
        .where((b) => b.date.month == month && b.date.year == DateTime.now().year)
        .length;
  }
}
