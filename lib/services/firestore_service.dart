import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart' as app_user;
import '../models/destination.dart';
import '../models/favorite.dart';
import '../models/booking.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Users
  Future<void> createUser(app_user.AppUser user) async {
    try {
      await _db.collection('users').doc(user.uid).set(user.toMap());
    } catch (e) {
      print('Error creating user: $e');
      rethrow;
    }
  }

  Future<app_user.AppUser?> getUser(String uid) async {
    try {
      DocumentSnapshot doc = await _db.collection('users').doc(uid).get();
      if (doc.exists) {
        return app_user.AppUser.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print('Error getting user: $e');
      return null;
    }
  }

  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    await _db.collection('users').doc(uid).update(data);
  }

  // Destinations
  Future<List<Destination>> getDestinations() async {
    QuerySnapshot snapshot = await _db.collection('destinations').get();
    return snapshot.docs.map((doc) => Destination.fromMap(doc.id, doc.data() as Map<String, dynamic>)).toList();
  }

  Future<Destination?> getDestination(String id) async {
    DocumentSnapshot doc = await _db.collection('destinations').doc(id).get();
    if (doc.exists) {
      return Destination.fromMap(doc.id, doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  Future<void> addDestination(Destination destination) async {
    await _db.collection('destinations').add(destination.toMap());
  }

  Future<void> updateDestination(String id, Map<String, dynamic> data) async {
    await _db.collection('destinations').doc(id).update(data);
  }

  Future<void> deleteDestination(String id) async {
    await _db.collection('destinations').doc(id).delete();
  }

  // Favorites
  Future<List<Favorite>> getUserFavorites(String userId) async {
    QuerySnapshot snapshot = await _db.collection('favorites').where('userId', isEqualTo: userId).get();
    return snapshot.docs.map((doc) => Favorite.fromMap(doc.id, doc.data() as Map<String, dynamic>)).toList();
  }

  Future<void> addFavorite(Favorite favorite) async {
    await _db.collection('favorites').add(favorite.toMap());
  }

  Future<void> removeFavorite(String favoriteId) async {
    await _db.collection('favorites').doc(favoriteId).delete();
  }

  Future<bool> isFavorite(String userId, String destinationId) async {
    QuerySnapshot snapshot = await _db.collection('favorites')
        .where('userId', isEqualTo: userId)
        .where('destinationId', isEqualTo: destinationId)
        .get();
    return snapshot.docs.isNotEmpty;
  }

  // Bookings
  Future<List<Booking>> getUserBookings(String userId) async {
    QuerySnapshot snapshot = await _db.collection('bookings').where('userId', isEqualTo: userId).get();
    return snapshot.docs.map((doc) => Booking.fromMap(doc.id, doc.data() as Map<String, dynamic>)).toList();
  }

  Future<void> addBooking(Booking booking) async {
    await _db.collection('bookings').add(booking.toMap());
  }
}