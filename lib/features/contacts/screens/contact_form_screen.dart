import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/emergency_contact.dart';
import '../../../providers/auth_provider.dart';
import '../../../core/utils/snackbar_utils.dart';
import 'package:safestep/core/l10n/app_localizations.dart';
import 'package:uuid/uuid.dart';

class ContactFormScreen extends ConsumerStatefulWidget {
  const ContactFormScreen({super.key, this.contact});

  final EmergencyContact? contact;

  @override
  ConsumerState<ContactFormScreen> createState() => _ContactFormScreenState();
}

class _ContactFormScreenState extends ConsumerState<ContactFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _relationshipController;
  bool _isPrimary = false;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final c = widget.contact;
    _nameController = TextEditingController(text: c?.name ?? '');
    _phoneController = TextEditingController(text: c?.phone ?? '');
    _relationshipController = TextEditingController(text: c?.relationship ?? '');
    _isPrimary = c?.isPrimary ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _relationshipController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final uid = ref.read(currentUserProvider)?.uid;
    if (uid == null) return;

    setState(() => _loading = true);
    try {
      final id = widget.contact?.id ?? const Uuid().v4();
      final contact = EmergencyContact(
        id: id,
        userId: uid,
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        relationship: _relationshipController.text.trim(),
        isPrimary: _isPrimary,
      );
      if (widget.contact != null) {
        await ref.read(firebaseServiceProvider).updateContact(contact);
      } else {
        await ref.read(firebaseServiceProvider).addContact(contact);
      }
      if (_isPrimary) {
        await ref.read(firebaseServiceProvider).setPrimaryContact(uid, id);
      }
      if (mounted) {
        SnackbarUtils.show('Saved');
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        // ✅ HANDLE INDEX ERROR
        SnackbarUtils.showFirestoreError(e);
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.contact != null ? l10n.editContact : l10n.addContact),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: l10n.name),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(labelText: l10n.phone),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _relationshipController,
                decoration: InputDecoration(labelText: l10n.relationship),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: Text(l10n.primaryContact),
                value: _isPrimary,
                onChanged: (v) => setState(() => _isPrimary = v),
              ),
              const SizedBox(height: 32),
              FilledButton(
                onPressed: _loading ? null : _save,
                child: _loading
                    ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(l10n.save),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
