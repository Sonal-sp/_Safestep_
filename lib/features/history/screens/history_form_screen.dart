import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../models/medical_history_entry.dart';
import '../../../providers/auth_provider.dart';
import '../../../core/utils/snackbar_utils.dart';
import 'package:safestep/core/l10n/app_localizations.dart';
import 'package:uuid/uuid.dart';

class HistoryFormScreen extends ConsumerStatefulWidget {
  const HistoryFormScreen({super.key, this.entry});

  final MedicalHistoryEntry? entry;

  @override
  ConsumerState<HistoryFormScreen> createState() => _HistoryFormScreenState();
}

class _HistoryFormScreenState extends ConsumerState<HistoryFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _medicationsController;
  late TextEditingController _notesController;
  late DateTime _dateTime;
  late String _type;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final e = widget.entry;
    _titleController = TextEditingController(text: e?.title ?? '');
    _medicationsController = TextEditingController(text: e?.medications ?? '');
    _notesController = TextEditingController(text: e?.notes ?? '');
    _dateTime = e?.dateTime ?? DateTime.now();
    _type = e?.type ?? 'condition';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _medicationsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateTime,
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _dateTime = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final uid = ref.read(currentUserProvider)?.uid;
    if (uid == null) return;

    setState(() => _loading = true);
    try {
      final id = widget.entry?.id ?? const Uuid().v4();
      final entry = MedicalHistoryEntry(
        id: id,
        userId: uid,
        title: _titleController.text.trim(),
        medications: _medicationsController.text.trim(),
        notes: _notesController.text.trim(),
        dateTime: _dateTime,
        type: _type,
      );

      if (widget.entry != null) {
        await ref.read(firebaseServiceProvider).updateMedicalHistory(entry);
      } else {
        await ref.read(firebaseServiceProvider).addMedicalHistory(entry);
      }

      if (mounted) {
        SnackbarUtils.show(widget.entry != null ? 'Record updated' : 'Record added');
        context.pop(); // Use GoRouter's pop
      }
    } catch (e) {
      if (mounted) {
        SnackbarUtils.show('Failed to save: ${e.toString()}', isError: true);
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(widget.entry != null ? l10n.edit : l10n.addEntry)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButtonFormField<String>(
                initialValue: _type,
                decoration: const InputDecoration(labelText: 'Entry Type'),
                items: const [
                  DropdownMenuItem(value: 'condition', child: Text('Chronic Condition')),
                  DropdownMenuItem(value: 'prescription', child: Text('Active Prescription')),
                  DropdownMenuItem(value: 'report', child: Text('Diagnostic Report')),
                ],
                onChanged: (v) => setState(() => _type = v!),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Disease / Condition'),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _medicationsController,
                decoration: const InputDecoration(labelText: 'Medications'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Notes (Optional)'),
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Date'),
                subtitle: Text('${_dateTime.year}-${_dateTime.month.toString().padLeft(2, '0')}-${_dateTime.day.toString().padLeft(2, '0')}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: _pickDate,
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _loading ? null : _save,
                child: _loading
                    ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('SAVE RECORD'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
