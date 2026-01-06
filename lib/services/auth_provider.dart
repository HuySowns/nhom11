import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_service.dart';
import 'firestore_service.dart';
import '../models/user.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  User? _firebaseUser;
  AppUser? _user;

  User? get firebaseUser => _firebaseUser;
  AppUser? get user => _user;

  AuthProvider() {
    _authService.authStateChanges.listen(_onAuthStateChanged);
  }

  void _onAuthStateChanged(User? firebaseUser) async {
    _firebaseUser = firebaseUser;
    if (firebaseUser != null) {
      try {
        _user = await _firestoreService.getUser(firebaseUser.uid);
      } catch (e) {
        print('Error loading user: $e');
        _user = null;
      }
    } else {
      _user = null;
    }
    notifyListeners();
  }

  Future<void> signInWithEmailPassword(String email, String password) async {
    await _authService.signInWithEmailPassword(email, password);
  }

  Future<void> registerWithEmailPassword(String email, String password, String name) async {
    try {
      UserCredential result = await _authService.registerWithEmailPassword(email, password);
      AppUser newUser = AppUser(
        uid: result.user!.uid,
        name: name,
        email: email,
      );
      await _firestoreService.createUser(newUser);
    } catch (e) {
      print('Error registering: $e');
      rethrow;
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      UserCredential result = await _authService.signInWithGoogle();
      if (result.user != null) {
        AppUser? existingUser = await _firestoreService.getUser(result.user!.uid);
        if (existingUser == null) {
          AppUser newUser = AppUser(
            uid: result.user!.uid,
            name: result.user!.displayName ?? 'User',
            email: result.user!.email ?? '',
            avatarUrl: result.user!.photoURL,
          );
          await _firestoreService.createUser(newUser);
        }
      }
    } catch (e) {
      print('Error signing in with Google: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }
}