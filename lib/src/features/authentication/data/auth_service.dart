import 'dart:async';
import 'dart:developer' as developer;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../domain/app_user.dart';

class AuthService with ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AppUser? _appUser;

  late StreamSubscription<User?> _authStateChangesSubscription;

  AuthService() {
    _authStateChangesSubscription = _firebaseAuth.authStateChanges().listen(_onAuthStateChanged);
  }

  AppUser? get currentUser => _appUser;

  Future<void> _onAuthStateChanged(User? firebaseUser) async {
    if (firebaseUser == null) {
      _appUser = null;
    } else {
      try {
        // By using a new snapshot, we ensure we get the latest user data
        final doc = await _firestore.collection('user').doc(firebaseUser.uid).get();
        if (doc.exists) {
          _appUser = AppUser.fromFirestore(doc);
        } else {
          _appUser = null;
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
      }
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
