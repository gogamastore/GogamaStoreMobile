import 'dart:async';
import 'dart:developer' as developer;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../domain/app_user.dart';

enum AuthStatus {
  unknown,
  authenticated,
  unauthenticated,
}

class AuthService with ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AppUser? _appUser;
  AuthStatus _authStatus = AuthStatus.unknown;

  // --- FIX: Add a completer to signal when the initial auth state is ready ---
  final Completer<void> _readyCompleter = Completer<void>();

  late StreamSubscription<User?> _authStateChangesSubscription;

  AuthService() {
    // Listen to auth state changes and update our own status
    _authStateChangesSubscription = _firebaseAuth.authStateChanges().listen(_onAuthStateChanged);
    // Check the initial user state immediately
    _onAuthStateChanged(_firebaseAuth.currentUser);
  }

  // --- FIX: Public Future to await the initial auth state ---
  Future<void> get isReady => _readyCompleter.future;

  AppUser? get currentUser => _appUser;
  AuthStatus get authStatus => _authStatus;

  Future<void> _onAuthStateChanged(User? firebaseUser) async {
    if (firebaseUser == null) {
      _appUser = null;
      _authStatus = AuthStatus.unauthenticated;
    } else {
      try {
        final doc = await _firestore.collection('user').doc(firebaseUser.uid).get();
        if (doc.exists) {
          _appUser = AppUser.fromFirestore(doc);
          _authStatus = AuthStatus.authenticated;
        } else {
          _appUser = null;
          _authStatus = AuthStatus.unauthenticated; // User exists in Auth but not Firestore
          developer.log(
            'Firestore document for user ${firebaseUser.uid} not found.',
            name: 'AuthService',
            level: 900, // Warning
          );
        }
      } catch (e, s) {
        developer.log(
          'Error fetching user from Firestore.',
          name: 'AuthService',
          level: 1000, // Severe
          error: e,
          stackTrace: s,
        );
        _appUser = null;
        _authStatus = AuthStatus.unauthenticated; // Treat errors as unauthenticated
      }
    }
    
    // --- FIX: Complete the future only once when the first auth state is known ---
    if (!_readyCompleter.isCompleted) {
      _readyCompleter.complete();
    }

    notifyListeners();
  }

  @override
  void dispose() {
    _authStateChangesSubscription.cancel();
    super.dispose();
  }

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<User?> signInWithEmailAndPassword({required String email, required String password}) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException {
      rethrow;
    }
  }

  Future<User?> signUpWithEmailAndPassword({required String email, required String password}) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user != null) {
        await _firestore.collection('user').doc(user.uid).set({
          'email': user.email,
          'displayName': '', // Initially empty, to be set in profile
          'photoURL': '', // Initially empty
          'whatsapp': '', // Initially empty
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      return user;
    } on FirebaseAuthException {
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  /// Manually refetches user data from Firestore and notifies listeners.
  Future<void> reloadUser() async {
    final firebaseUser = _firebaseAuth.currentUser;
    if (firebaseUser != null) {
      await _onAuthStateChanged(firebaseUser);
    }
  }
}
