import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthService with ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  User? _user;
  late StreamSubscription<User?> _authStateChangesSubscription;

  AuthService() {
    // Subscribe to the auth state changes stream in the constructor
    _authStateChangesSubscription = _firebaseAuth.authStateChanges().listen(
      (User? user) {
        _user = user;
        // When the auth state changes, notify all the listeners.
        notifyListeners();
      },
    );
  }

  // Override dispose to cancel the subscription
  @override
  void dispose() {
    _authStateChangesSubscription.cancel();
    super.dispose();
  }

  // Getter for the current user
  User? get currentUser => _user;

  // Stream for external use if needed, though provider is preferred
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  // Sign in with Email and Password
  Future<User?> signInWithEmailAndPassword({required String email, required String password}) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException {
      // Re-throw the exception to be caught by the UI
      rethrow;
    }
  }

  // Sign up with Email and Password
  Future<User?> signUpWithEmailAndPassword({required String email, required String password}) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException {
      // Re-throw the exception to be caught by the UI
      rethrow;
    }
  }

  // Sign in Anonymously - ADDED BACK
  Future<User?> signInAnonymously() async {
    try {
      final userCredential = await _firebaseAuth.signInAnonymously();
      return userCredential.user;
    } on FirebaseAuthException {
      // Re-throw the exception to be caught by the UI
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}
