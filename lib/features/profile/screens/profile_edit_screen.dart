import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/user_profile.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/locale_provider.dart';

import 'package:safestep/core/utils/snackbar_utils.dart';

class ProfileEditScreen extends ConsumerStatefulWidget {
  const ProfileEditScreen({super.key, required this.profile});
  final UserProfile profile;

  @override
  ConsumerState<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends ConsumerState<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _ageController;
  late TextEditingController _bloodTypeController;
  late String _language;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.name);
    _ageController = TextEditingController(text: widget.profile.age.toString());
    _bloodTypeController = TextEditingController(
      text: widget.profile.bloodType,
    );
    _language = widget.profile.language;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _bloodTypeController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final profile = widget.profile.copyWith(
        name: _nameController.text.trim(),
        age: int.tryParse(_ageController.text.trim()) ?? 0,
        bloodType: _bloodTypeController.text.trim(),
        language: _language,
      );
      await ref.read(firebaseServiceProvider).createOrUpdateProfile(profile);
      // Force locale update
      ref.read(localeProvider.notifier).setLocale(_language);
      if (mounted) {
        SnackbarUtils.show('Profile saved');
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) SnackbarUtils.show('Error saving profile', isError: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Avatar
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: cs.primaryContainer.withAlpha(40),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.person_rounded,
                    size: 40,
                    color: cs.primary,
                  ),
                ),
              ),

              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: Icon(Icons.person_outline_rounded),
                ),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _ageController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Age',
                  prefixIcon: Icon(Icons.cake_outlined),
                ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _bloodTypeController,
                decoration: const InputDecoration(
                  labelText: 'Blood Type',
                  prefixIcon: Icon(Icons.bloodtype_outlined),
                ),
                textCapitalization: TextCapitalization.characters,
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                initialValue: _language,
                decoration: const InputDecoration(
                  labelText: 'Language',
                  prefixIcon: Icon(Icons.language_rounded),
                ),
                items: const [
                  DropdownMenuItem(value: 'en', child: Text('English')),
                  DropdownMenuItem(value: 'hi', child: Text('हिंदी')),
                  DropdownMenuItem(value: 'mr', child: Text('मराठी')),
                ],
                onChanged: (v) => setState(() => _language = v ?? 'en'),
              ),
              const SizedBox(height: 32),

              ElevatedButton(
                onPressed: _loading ? null : _save,
                child: _loading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
