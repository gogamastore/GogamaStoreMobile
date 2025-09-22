import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../services/auth_service.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    String? errorMessage;
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      // The service returns a User object directly.
      final user = await authService.signUpWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (user != null) {
        // After successful sign-up, create a user document in Firestore.
        await FirebaseFirestore.instance
            .collection('users')
            // Access uid and email directly from the user object.
            .doc(user.uid)
            .set({
          'email': user.email,
          'role': 'reseller',
          'createdAt': FieldValue.serverTimestamp(),
        });
        // The auth state listener will automatically navigate the user in.
      }
    } on FirebaseException catch (e) {
      if (e.code == 'email-already-in-use') {
        errorMessage = 'Email ini sudah terdaftar. Silakan masuk.';
      } else if (e.code == 'weak-password') {
        errorMessage = 'Kata sandi terlalu lemah. Gunakan minimal 6 karakter.';
      } else {
        errorMessage = 'Terjadi kesalahan saat pendaftaran.';
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
      appBar: AppBar(title: const Text('Daftar Akun Reseller')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Buat Akun Baru', style: textTheme.headlineSmall),
                const SizedBox(height: 8),
                Text('Isi detail di bawah untuk mendaftar', style: textTheme.bodyMedium),
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
                    if (value == null || value.length < 6) {
                      return 'Kata sandi harus terdiri dari minimal 6 karakter';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _signUp,
                        style: ElevatedButton.styleFrom(minimumSize: const Size(0, 50)),
                        child: const Text('Daftar'),
                      ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Sudah punya akun? ', style: textTheme.bodyMedium),
                    TextButton(
                      onPressed: () {
                        // Navigate back to the login screen
                        context.go('/'); // Assuming login is at the root or another defined path
                      },
                      child: const Text('Masuk di sini'),
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
