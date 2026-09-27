import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../models/incident_report.dart';
import '../../../providers/auth_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/snackbar_utils.dart';

class IncidentReportScreen extends ConsumerStatefulWidget {
  const IncidentReportScreen({super.key});

  @override
  ConsumerState<IncidentReportScreen> createState() => _IncidentReportScreenState();
}

class _IncidentReportScreenState extends ConsumerState<IncidentReportScreen> {
  String _selectedType = 'crime';
  final _descController = TextEditingController();
  bool _loading = false;

  final _types = [
    {'value': 'crime', 'label': 'Crime', 'icon': Icons.gavel_rounded, 'color': AppColors.error},
    {'value': 'unsafe_area', 'label': 'Unsafe Area', 'icon': Icons.warning_rounded, 'color': AppColors.warning},
    {'value': 'poor_lighting', 'label': 'Poor Lighting', 'icon': Icons.lightbulb_outline_rounded, 'color': AppColors.warningDark},
    {'value': 'other', 'label': 'Other', 'icon': Icons.report_problem_rounded, 'color': AppColors.textSecondary},
  ];

  @override
  void dispose() {
    _descController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_descController.text.trim().isEmpty) {
      SnackbarUtils.show('Please describe the incident', isError: true);
      return;
    }

    final uid = ref.read(currentUserProvider)?.uid;
    if (uid == null) return;

    setState(() => _loading = true);

    try {
      final report = IncidentReport(
        id: const Uuid().v4(),
        userId: uid,
        type: _selectedType,
        description: _descController.text.trim(),
        latitude: 0.0, // Would use geolocator in production
        longitude: 0.0,
        timestamp: DateTime.now(),
      );

      await ref.read(firebaseServiceProvider).addIncidentReport(report);

      if (mounted) {
        SnackbarUtils.show('Incident reported successfully');
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        SnackbarUtils.show('Failed to submit report', isError: true);
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Report Incident')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('What happened?', style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              'Your report helps keep the community safe.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),

            // Type selector
            Text('Incident Type', style: theme.textTheme.titleSmall),
            const SizedBox(height: 12),
            Builder(
              builder: (context) {
                return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: _types.map((t) {
                    final isSelected = _selectedType == t['value'];
                    final color = t['color'] as Color;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedType = t['value'] as String),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected ? color.withAlpha(25) : cs.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected ? color : cs.outline,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(t['icon'] as IconData, color: isSelected ? color : cs.onSurfaceVariant, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              t['label'] as String,
                              style: TextStyle(
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                color: isSelected ? color : cs.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
            const SizedBox(height: 24),

            // Description
            Text('Description', style: theme.textTheme.titleSmall),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Describe what happened...',
              ),
            ),
            const SizedBox(height: 24),

            // Location info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cs.primaryContainer.withAlpha(30),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: cs.outline.withAlpha(50)),
              ),
              child: Row(
                children: [
                  Icon(Icons.location_on_rounded, color: cs.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Current Location', style: theme.textTheme.titleSmall),
                        Text('Will be attached to the report', style: theme.textTheme.bodySmall),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Submit button
            ElevatedButton.icon(
              onPressed: _loading ? null : _submit,
              icon: _loading
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.send_rounded),
              label: const Text('Submit Report'),
            ),
          ],
        ),
      ),
    );
  }
}
