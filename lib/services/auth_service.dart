import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<User> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (userCredential.user == null) {
        throw 'Gagal mendapatkan data pengguna setelah login.';
      }
      return userCredential.user!;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw 'Pengguna dengan email tersebut tidak ditemukan.';
      } else if (e.code == 'wrong-password') {
        throw 'Kata sandi salah.';
      } else {
        throw 'Terjadi kesalahan saat login: ${e.message}';
      }
    }
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}
