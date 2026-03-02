import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

class AuthProvider with ChangeNotifier {
  AppUser? _user;
  bool _isLoading = false;
  String? _error;

  AppUser? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    _initializeAuth();
  }

  void _initializeAuth() {
    AuthService.authStateChanges.listen((User? firebaseUser) async {
      if (firebaseUser != null) {
        try {
          _isLoading = true;
          notifyListeners();
          
          _user = await FirestoreService.getUser(firebaseUser.uid);
          _error = null;
        } catch (e) {
          _error = e.toString();
          _user = null;
        } finally {
          _isLoading = false;
          notifyListeners();
        }
      } else {
        _user = null;
        _error = null;
        _isLoading = false;
        notifyListeners();
      }
    });
  }

  Future<bool> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _user = await AuthService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (_user != null) {
        _error = null;
        return true;
      } else {
        _error = 'Sign in failed';
        return false;
      }
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _user = await AuthService.registerWithEmailAndPassword(
        email: email,
        password: password,
        displayName: displayName,
      );

      if (_user != null) {
        _error = null;
        return true;
      } else {
        _error = 'Registration failed';
        return false;
      }
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signInWithGoogle() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _user = await AuthService.signInWithGoogle();

      if (_user != null) {
        _error = null;
        return true;
      } else {
        _error = 'Google sign in failed';
        return false;
      }
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await AuthService.signOut();
      _user = null;
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> resetPassword(String email) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await AuthService.resetPassword(email);
      _error = null;
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
