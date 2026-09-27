import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

import '../../../models/medication.dart';
import '../../../core/utils/snackbar_utils.dart';
import '../../../services/notification_service.dart';

class MedicineFormScreen extends ConsumerStatefulWidget {
  const MedicineFormScreen({super.key, this.medication});
  final Medication? medication;

  @override
  ConsumerState<MedicineFormScreen> createState() => _MedicineFormScreenState();
}

class _MedicineFormScreenState extends ConsumerState<MedicineFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _dosageController;
  late TimeOfDay _time;
  late String _frequency;
  late DateTime _selectedDate;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final m = widget.medication;

    _nameController = TextEditingController(text: m?.name ?? '');
    _dosageController = TextEditingController(text: m?.dosage ?? '');
    _frequency = m?.frequency ?? 'Daily';

    if (m != null) {
      final parts = m.time.split(':');
      _time = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
      _selectedDate = m.createdAt ?? DateTime.now();
    } else {
      _time = TimeOfDay.now();
      _selectedDate = DateTime.now();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) SnackbarUtils.show('Please login first', isError: true);
      return;
    }

    setState(() => _loading = true);

    final formattedTime =
        '${_time.hour.toString().padLeft(2, '0')}:${_time.minute.toString().padLeft(2, '0')}';

    final formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate);

    final Map<String, dynamic> data = {
      'userId': user.uid,
      'name': _nameController.text.trim(),
      'dosage': _dosageController.text.trim(),
      'time': formattedTime,
      'frequency': _frequency,
      'scheduleDate': formattedDate,
    };

    final isNew = widget.medication == null;
    if (isNew) {
      data['createdAt'] = FieldValue.serverTimestamp();
    }

    final id = widget.medication?.id ?? const Uuid().v4();

    try {
      if (widget.medication != null) {
        await NotificationService().cancelMedicineReminder(
          widget.medication!.id,
        );
        await FirebaseFirestore.instance
            .collection('medications')
            .doc(id)
            .update(data);
      } else {
        await FirebaseFirestore.instance
            .collection('medications')
            .doc(id)
            .set(data);
      }

      final med = Medication(
        id: id,
        userId: user.uid,
        name: _nameController.text.trim(),
        dosage: _dosageController.text.trim(),
        time: formattedTime,
        frequency: _frequency,
        scheduleDate: formattedDate,
      );

      try {
        await NotificationService().scheduleMedicineWithPreReminder(med);
      } catch (e) {
        // Silent fail - non-blocking
      }

      if (mounted) {
        SnackbarUtils.show(
          widget.medication != null
              ? 'Medicine updated successfully'
              : 'Medicine added successfully',
        );
        Navigator.pop(context, true); // Pass result back
      }
    } catch (e) {
      if (mounted) {
        SnackbarUtils.show('Failed to save medicine', isError: true);
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _delete() async {
    if (widget.medication == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Medicine'),
        content: Text(
          'Are you sure you want to delete ${widget.medication!.name}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(ctx).colorScheme.error,
            ),
            child: const Text('DELETE'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await FirebaseFirestore.instance
          .collection('medications')
          .doc(widget.medication!.id)
          .delete();
      await NotificationService().cancelMedicineReminder(widget.medication!.id);
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isEdit = widget.medication != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Medicine' : 'Add Medicine'),
        actions: [
          if (isEdit)
            IconButton(
              icon: Icon(Icons.delete_outline_rounded, color: cs.error),
              onPressed: _delete,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 64,
                height: 64,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: cs.primaryContainer.withAlpha(40),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.medication_rounded,
                  color: cs.primary,
                  size: 32,
                ),
              ),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Medicine Name',
                  prefixIcon: Icon(Icons.medical_services_outlined),
                ),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _dosageController,
                decoration: const InputDecoration(
                  labelText: 'Dosage (e.g., 1 tablet, 5ml)',
                  prefixIcon: Icon(Icons.science_outlined),
                ),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Icon(Icons.access_time_rounded, color: cs.primary),
                title: const Text('Reminder Time'),
                subtitle: Text(
                  '${_time.hour.toString().padLeft(2, '0')}:${_time.minute.toString().padLeft(2, '0')}',
                ),
                trailing: Icon(
                  Icons.chevron_right_rounded,
                  color: cs.onSurfaceVariant,
                ),
                onTap: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: _time,
                  );
                  if (picked != null) setState(() => _time = picked);
                },
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Icon(Icons.calendar_today_rounded, color: cs.primary),
                title: const Text('Select Date'),
                subtitle: Text(DateFormat('yyyy-MM-dd').format(_selectedDate)),
                trailing: Icon(
                  Icons.chevron_right_rounded,
                  color: cs.onSurfaceVariant,
                ),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime.now().subtract(
                      const Duration(days: 365),
                    ),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null) setState(() => _selectedDate = picked);
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _frequency,
                decoration: const InputDecoration(
                  labelText: 'Frequency',
                  prefixIcon: Icon(Icons.repeat_rounded),
                ),
                items: const [
                  DropdownMenuItem(value: 'Daily', child: Text('Daily')),
                  DropdownMenuItem(value: 'Weekly', child: Text('Weekly')),
                  DropdownMenuItem(
                    value: 'As needed',
                    child: Text('As needed'),
                  ),
                ],
                onChanged: (v) => setState(() => _frequency = v!),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _loading ? null : _save,
                child: _loading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        widget.medication != null
                            ? 'Update Medication'
                            : 'Save Medication',
                      ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
