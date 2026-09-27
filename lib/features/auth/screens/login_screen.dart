import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../providers/auth_provider.dart';
import '../../../core/utils/snackbar_utils.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/l10n/app_localizations.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _loading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await ref.read(firebaseServiceProvider).signIn(
            _emailController.text.trim(),
            _passwordController.text,
          );
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        String message;
        switch (e.code) {
          case 'invalid-email': message = 'Invalid email address format.'; break;
          case 'user-disabled': message = 'This user has been disabled.'; break;
          case 'user-not-found': message = 'No user found for that email.'; break;
          case 'wrong-password': message = 'Wrong password provided.'; break;
          case 'invalid-credential': message = 'Invalid email or password.'; break;
          default: message = e.message ?? AppLocalizations.of(context)!.loginError;
        }
        SnackbarUtils.show(message, isError: true);
      }
    } catch (e) {
      if (mounted) {
        SnackbarUtils.show(AppLocalizations.of(context)!.loginError, isError: true);
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
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.health_and_safety_rounded, size: 80, color: AppColors.primary),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    l10n.appName,
                    style: theme.textTheme.displayLarge?.copyWith(color: AppColors.primary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Your Intelligent Safety Companion",
                    style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),
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
                    validator: (v) => v == null || v.isEmpty ? '${l10n.password} required' : null,
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _loading ? null : _signIn,
                    child: _loading
                        ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                        : Text(l10n.signIn),
                  ),
                  const SizedBox(height: 24),
                  TextButton(
                    onPressed: () => context.push('/register'),
                    child: Text(
                      "Don't have an account? ${l10n.signUp}",
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
