import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_service.dart';
import 'realtime_service.dart';
import '../models/user.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final RealtimeService _realtimeService = RealtimeService();

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
        _user = await _realtimeService.getUser(firebaseUser.uid);
        // Ensure admin role for admin@example.com
        if (_user != null && firebaseUser.email == 'admin@example.com' && _user!.role != 'admin') {
          _user = _user!.copyWith(role: 'admin');
          await _realtimeService.updateUser(firebaseUser.uid, {'role': 'admin'});
        }
      } catch (e) {
        // print('Error loading user: $e');
        // If user not found, create new user
        if (e.toString().contains('not found') || e.toString().contains('null')) {
          String role = firebaseUser.email == 'admin@example.com' ? 'admin' : 'user';
          AppUser newUser = AppUser(
            uid: firebaseUser.uid,
            name: firebaseUser.displayName ?? 'User',
            email: firebaseUser.email ?? '',
            avatarUrl: firebaseUser.photoURL,
            role: role,
          );
          try {
            await _realtimeService.createUser(newUser);
            _user = newUser;
          } catch (createError) {
            print('Error creating user: $createError');
            _user = null;
          }
        } else {
          _user = null;
        }
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
      String role = email == 'admin@example.com' ? 'admin' : 'user'; // Simple admin check
      AppUser newUser = AppUser(
        uid: result.user!.uid,
        name: name,
        email: email,
        role: role,
      );
      await _realtimeService.createUser(newUser);
    } catch (e) {
      print('Error registering: $e');
      rethrow;
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      UserCredential result = await _authService.signInWithGoogle();
      if (result.user != null) {
        AppUser? existingUser = await _realtimeService.getUser(result.user!.uid);
        if (existingUser == null) {
          String role = result.user!.email == 'admin@example.com' ? 'admin' : 'user';
          AppUser newUser = AppUser(
            uid: result.user!.uid,
            name: result.user!.displayName ?? 'User',
            email: result.user!.email ?? '',
            avatarUrl: result.user!.photoURL,
            role: role,
          );
          await _realtimeService.createUser(newUser);
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