import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:safestep/providers/shell_provider.dart';

import '../../../providers/auth_provider.dart';
import '../../../providers/data_providers.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final historyAsync = ref.watch(medicalHistoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Medical History"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/history-form'),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              historyAsync.when(
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 100),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (e, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 100),
                    child: Text(
                      "Error loading history: $e",
                      style: TextStyle(
                        color: theme.textTheme.bodyMedium?.color,
                      ),
                    ),
                  ),
                ),
                data: (entries) {
                  if (entries.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 80),
                        child: Column(
                          children: [
                            Icon(
                              Icons.history_edu_rounded,
                              size: 80,
                              color: theme.colorScheme.primary.withValues(alpha: 0.2),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "No medical history added yet",
                              style: TextStyle(
                                color: theme.textTheme.bodyMedium?.color
                                    ?.withValues(alpha: 0.7),
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextButton(
                              onPressed: () => context.push('/history-form'),
                              child: const Text("Add Your First Record"),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final conditions = entries
                      .where((e) => e.type == 'condition' || e.type == '')
                      .toList();
                  final prescriptions = entries
                      .where((e) => e.type == 'prescription')
                      .toList();
                  final reports = entries
                      .where((e) => e.type == 'report')
                      .toList();
                  final others = entries
                      .where(
                        (e) => ![
                          'condition',
                          'prescription',
                          'report',
                          '',
                        ].contains(e.type),
                      )
                      .toList();

                  return Column(
                    children: [
                      if (conditions.isNotEmpty)
                        Builder(
                          builder: (context) {
                            
                            return _HistorySection(
                              title: "Chronic Conditions",
                              items: conditions
                                  .map(
                                    (e) => _HistoryItem(
                                      title: e.title,
                                      subtitle: e.subtitle,
                                      icon: Icons.favorite_rounded,
                                      onTap: () => context.push(
                                        '/history-form',
                                        extra: e,
                                      ),
                                      onDelete: () =>
                                          _confirmDelete(context, ref, e.id),
                                    ),
                                  )
                                  .toList(),
                            );
                          },
                        ),
                      if (conditions.isNotEmpty &&
                          (prescriptions.isNotEmpty ||
                              reports.isNotEmpty ||
                              others.isNotEmpty))
                        const SizedBox(height: 32),

                      if (prescriptions.isNotEmpty)
                        Builder(
                          builder: (context) {
                            
                            return _HistorySection(
                              title: "Active Prescriptions",
                              items: prescriptions
                                  .map(
                                    (e) => _HistoryItem(
                                      title: e.title,
                                      subtitle: e.subtitle,
                                      icon: Icons.medication_rounded,
                                      onTap: () => context.push(
                                        '/history-form',
                                        extra: e,
                                      ),
                                      onDelete: () =>
                                          _confirmDelete(context, ref, e.id),
                                    ),
                                  )
                                  .toList(),
                            );
                          },
                        ),
                      if (prescriptions.isNotEmpty &&
                          (reports.isNotEmpty || others.isNotEmpty))
                        const SizedBox(height: 32),

                      if (reports.isNotEmpty)
                        Builder(
                          builder: (context) {
                            
                            return _HistorySection(
                              title: "Diagnostic Reports",
                              items: reports
                                  .map(
                                    (e) => _HistoryItem(
                                      title: e.title,
                                      subtitle: e.subtitle,
                                      icon: Icons.description_rounded,
                                      onTap: () => context.push(
                                        '/history-form',
                                        extra: e,
                                      ),
                                      onDelete: () =>
                                          _confirmDelete(context, ref, e.id),
                                    ),
                                  )
                                  .toList(),
                            );
                          },
                        ),
                      if (reports.isNotEmpty && others.isNotEmpty)
                        const SizedBox(height: 32),

                      if (others.isNotEmpty)
                        Builder(
                          builder: (context) {
                            
                            return _HistorySection(
                              title: "Other Records",
                              items: others
                                  .map(
                                    (e) => _HistoryItem(
                                      title: e.title,
                                      subtitle: e.subtitle,
                                      icon: Icons.history_rounded,
                                      onTap: () => context.push(
                                        '/history-form',
                                        extra: e,
                                      ),
                                      onDelete: () =>
                                          _confirmDelete(context, ref, e.id),
                                    ),
                                  )
                                  .toList(),
                            );
                          },
                        ),
                      if (others.isNotEmpty) const SizedBox(height: 32),
                    ],
                  );
                },
              ),

              const SizedBox(height: 8),
              _EmergencyInfoCard(
                onEdit: () =>
                    ref.read(selectedTabIndexProvider.notifier).state = 4,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    String id,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Record"),
        content: const Text(
          "Are you sure you want to delete this medical history entry?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("CANCEL"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text("DELETE"),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(firebaseServiceProvider).deleteMedicalHistory(id);
    }
  }
}

class _HistorySection extends StatelessWidget {
  const _HistorySection({required this.title, required this.items});
  final String title;
  final List<Widget> items;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: theme.textTheme.bodyLarge?.color,
          ),
        ),
        const SizedBox(height: 16),
        ...items,
      ],
    );
  }
}

class _HistoryItem extends StatelessWidget {
  const _HistoryItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    required this.onDelete,
  });
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: theme.colorScheme.primary, size: 22),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: theme.textTheme.bodyLarge?.color,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                Icons.delete_outline,
                color: theme.colorScheme.error,
                size: 20,
              ),
              onPressed: onDelete,
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: theme.textTheme.bodyMedium?.color,
            ),
          ],
        ),
      ),
    );
  }
}

class _EmergencyInfoCard extends StatelessWidget {
  const _EmergencyInfoCard({this.onEdit});
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardColor.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: theme.colorScheme.error.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: theme.colorScheme.error),
              const SizedBox(width: 12),
              Text(
                "Emergency Info",
                style: TextStyle(
                  color: theme.colorScheme.error,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            "Blood Type: O+\nAllergies: Penicillin, Peanuts\nOrgan Donor: Yes",
            style: TextStyle(
              color: theme.textTheme.bodyMedium?.color,
              fontSize: 14,
              height: 1.6,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: onEdit,
            style: TextButton.styleFrom(padding: EdgeInsets.zero),
            child: Text(
              "Edit Emergency Info",
              style: TextStyle(
                color: theme.colorScheme.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
