import 'package:firebase_database/firebase_database.dart';
import '../models/user.dart' as app_user;
import '../models/destination.dart';
import '../models/favorite.dart';
import '../models/booking.dart';

class RealtimeService {
  final FirebaseDatabase _db = FirebaseDatabase.instance;

  // Users
  Future<void> createUser(app_user.AppUser user) async {
    try {
      await _db.ref('users/${user.uid}').set(user.toMap());
    } catch (e) {
      // print('Error creating user: $e');
      rethrow;
    }
  }

  Future<app_user.AppUser?> getUser(String uid) async {
    try {
      DataSnapshot snapshot = await _db.ref('users/$uid').get();
      if (snapshot.exists) {
        Map<String, dynamic> data = (snapshot.value as Map<dynamic, dynamic>).map((key, value) => MapEntry(key.toString(), value));
        return app_user.AppUser.fromMap(data);
      }
      return null;
    } catch (e) {
      // print('Error getting user: $e');
      return null;
    }
  }

  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    await _db.ref('users/$uid').update(data);
  }

  // Destinations
  Future<List<Destination>> getDestinations() async {
    DataSnapshot snapshot = await _db.ref('destinations').get();
    if (snapshot.exists) {
      Map<String, dynamic> data = (snapshot.value as Map<dynamic, dynamic>).map((key, value) {
        Map<String, dynamic> valueMap = (value as Map<dynamic, dynamic>).map((k, v) => MapEntry(k.toString(), v));
        return MapEntry(key.toString(), valueMap);
      });
      return data.entries.map((entry) => Destination.fromMap(entry.key, entry.value)).toList();
    }
    return [];
  }

  Future<Destination?> getDestination(String id) async {
    DataSnapshot snapshot = await _db.ref('destinations/$id').get();
    if (snapshot.exists) {
      Map<String, dynamic> data = (snapshot.value as Map<dynamic, dynamic>).map((key, value) => MapEntry(key.toString(), value));
      return Destination.fromMap(id, data);
    }
    return null;
  }

  Future<void> addDestination(Destination destination) async {
    DatabaseReference ref = _db.ref('destinations').push();
    await ref.set(destination.toMap());
  }

  Future<void> updateDestination(String id, Map<String, dynamic> data) async {
    await _db.ref('destinations/$id').update(data);
  }

  Future<void> deleteDestination(String id) async {
    await _db.ref('destinations/$id').remove();
  }

  // Favorites
  Future<List<Favorite>> getUserFavorites(String userId) async {
    DataSnapshot snapshot = await _db.ref('favorites').get();
    if (snapshot.exists) {
      List<Favorite> favorites = [];
      Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;
      data.forEach((key, value) {
        Map<String, dynamic> favoriteData = (value as Map<dynamic, dynamic>).map((k, v) => MapEntry(k.toString(), v));
        if (favoriteData['userId'] == userId) {
          favorites.add(Favorite.fromMap(key.toString(), favoriteData));
        }
      });
      return favorites;
    }
    return [];
  }

  Future<void> addFavorite(Favorite favorite) async {
    DatabaseReference ref = _db.ref('favorites').push();
    await ref.set(favorite.toMap()..['id'] = ref.key);
  }

  Future<void> removeFavorite(String favoriteId) async {
    await _db.ref('favorites/$favoriteId').remove();
  }

  Future<bool> isFavorite(String userId, String destinationId) async {
    DataSnapshot snapshot = await _db.ref('favorites').get();
    if (snapshot.exists) {
      Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;
      for (var value in data.values) {
        Map<String, dynamic> fav = (value as Map<dynamic, dynamic>).map((k, v) => MapEntry(k.toString(), v));
        if (fav['userId'] == userId && fav['destinationId'] == destinationId) {
          return true;
        }
      }
    }
    return false;
  }

  // Bookings
  Future<List<Booking>> getUserBookings(String userId) async {
    DataSnapshot snapshot = await _db.ref('bookings').get();
    if (snapshot.exists) {
      List<Booking> bookings = [];
      Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;
      data.forEach((key, value) {
        Map<String, dynamic> bookingData = (value as Map<dynamic, dynamic>).map((k, v) => MapEntry(k.toString(), v));
        if (bookingData['userId'] == userId) {
          bookings.add(Booking.fromMap(key.toString(), bookingData));
        }
      });
      return bookings;
    }
    return [];
  }

  Future<void> addBooking(Booking booking) async {
    DatabaseReference ref = _db.ref('bookings').push();
    await ref.set(booking.toMap()..['id'] = ref.key);
  }
}