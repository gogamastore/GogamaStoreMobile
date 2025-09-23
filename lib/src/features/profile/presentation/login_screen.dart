import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../authentication/data/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    String? errorMessage;
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final user = await authService.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (user != null) {
        // User is authenticated, now check Firestore role in the correct 'user' collection.
        final userDoc = await FirebaseFirestore.instance
            .collection('user') // <<< CORRECTED from 'users' to 'user'
            .doc(user.uid)
            .get();

        if (!userDoc.exists || userDoc.data()?['role'] != 'reseller') {
          await authService.signOut();
          errorMessage = 'Hanya akun reseller yang diizinkan masuk.';
        }
      }
    } on FirebaseException catch (e) {
        if (e.code == 'user-not-found' || e.code == 'wrong-password' || e.code == 'invalid-credential') {
            errorMessage = 'Email atau kata sandi salah.';
        } else if (e.code == 'invalid-email') {
            errorMessage = 'Format email tidak valid.';
        } else {
            errorMessage = 'Terjadi kesalahan. Silakan coba lagi.';
        }
    } catch (e) {
        errorMessage = 'Terjadi kesalahan yang tidak diketahui.';
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      if (errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Masuk Reseller')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Selamat Datang Kembali', style: textTheme.headlineSmall),
                const SizedBox(height: 8),
                Text('Masuk ke akun reseller Anda', style: textTheme.bodyMedium),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty || !value.contains('@')) {
                      return 'Masukkan email yang valid';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Masukkan kata sandi Anda';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _signIn,
                        style: ElevatedButton.styleFrom(minimumSize: const Size(0, 50)),
                        child: const Text('Masuk'),
                      ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Belum punya akun? ', style: textTheme.bodyMedium),
                    TextButton(
                      onPressed: () {
                        context.go('/signup');
                      },
                      child: const Text('Daftar di sini'),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
