import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../providers/auth_provider.dart';
import '../../../core/utils/snackbar_utils.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/l10n/app_localizations.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _loading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await ref.read(firebaseServiceProvider).signUp(
            _emailController.text.trim(),
            _passwordController.text,
            //_nameController.text.trim(),
          );
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        String message;
        switch (e.code) {
          case 'email-already-in-use': message = 'The account already exists for that email.'; break;
          case 'invalid-email': message = 'The email address is not valid.'; break;
          case 'weak-password': message = 'The password is too weak.'; break;
          default: message = e.message ?? 'An error occurred during sign up.';
        }
        SnackbarUtils.show(message, isError: true);
      }
    } catch (e) {
      if (mounted) {
        SnackbarUtils.show('An error occurred. Please try again.', isError: true);
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent, 
        elevation: 0, 
        leading: const BackButton(color: AppColors.primary)
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l10n.signUp,
                    style: theme.textTheme.displayLarge?.copyWith(color: AppColors.primary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Create your profile to get started",
                    style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: l10n.name,
                      prefixIcon: const Icon(Icons.person_outline_rounded, color: AppColors.primary),
                    ),
                    validator: (v) => v == null || v.isEmpty ? '${l10n.name} required' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: l10n.email,
                      prefixIcon: const Icon(Icons.email_outlined, color: AppColors.primary),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return '${l10n.email} required';
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v)) return 'Enter a valid email';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: l10n.password,
                      prefixIcon: const Icon(Icons.lock_outline, color: AppColors.primary),
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: AppColors.primary),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                    validator: (v) => v == null || v.length < 6 ? 'Password must be at least 6 characters' : null,
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _loading ? null : _signUp,
                    child: _loading
                        ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                        : Text(l10n.signUp),
                  ),
                  const SizedBox(height: 24),
                  TextButton(
                    onPressed: () => context.pop(),
                    child: Text(
                      "Already have an account? ${l10n.signIn}",
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
