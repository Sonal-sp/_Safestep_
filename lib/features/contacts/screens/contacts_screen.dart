import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/auth_provider.dart';
import '../../../providers/data_providers.dart';
import '../../../core/utils/ui_utils.dart';
import '../../../core/utils/snackbar_utils.dart';
import 'contact_form_screen.dart';
import 'package:safestep/core/l10n/app_localizations.dart';

class ContactsScreen extends ConsumerWidget {
  const ContactsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final contactsAsync = ref.watch(contactsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.primaryContact),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ContactFormScreen()),
            ),
          ),
        ],
      ),
      body: contactsAsync.when(
        data: (contacts) {
          if (contacts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(l10n.noContacts),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ContactFormScreen()),
                    ),
                    icon: const Icon(Icons.add),
                    label: Text(l10n.addContact),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: contacts.length,
            itemBuilder: (_, i) {
              final c = contacts[i];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: CircleAvatar(
                    child: Text(c.name.isNotEmpty ? c.name[0].toUpperCase() : '?'),
                  ),
                  title: Row(
                    children: [
                      Text(c.name, style: const TextStyle(fontSize: 18)),
                      if (c.isPrimary)
                        Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Chip(
                            label: Text(l10n.primaryContact, style: const TextStyle(fontSize: 12)),
                            padding: EdgeInsets.zero,
                          ),
                        ),
                    ],
                  ),
                  subtitle: Text('${c.phone} • ${c.relationship}'),
                  trailing: PopupMenuButton<String>(
                    onSelected: (v) async {
                      if (v == 'edit') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ContactFormScreen(contact: c),
                          ),
                        );
                      }
                      if (v == 'primary' && !c.isPrimary) {
                        try {
                          await ref
                              .read(firebaseServiceProvider)
                              .setPrimaryContact(c.userId, c.id);
                        } catch (e) {
                          SnackbarUtils.showFirestoreError(e);
                        }
                      }
                      if (v == 'delete') {
                        if (!context.mounted) return;
                        final ok = await UiUtils.showConfirmDialog(
                          context,
                          title: l10n.delete,
                          message: l10n.confirmDelete,
                          confirmText: l10n.delete,
                          isDestructive: true,
                        );
                        if (ok) {
                          try {
                            await ref.read(firebaseServiceProvider).deleteContact(c.id);
                          } catch (e) {
                            SnackbarUtils.showFirestoreError(e);
                          }
                        }
                      }
                    },
                    itemBuilder: (_) => [
                      PopupMenuItem(value: 'edit', child: Text(l10n.editContact)),
                      if (!c.isPrimary)
                        PopupMenuItem(value: 'primary', child: Text(l10n.primaryContact)),
                      PopupMenuItem(value: 'delete', child: Text(l10n.delete, style: const TextStyle(color: Colors.red))),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) {
          // ✅ HANDLE INDEX ERROR IN RIVERPOD ASYNC VALUE
          WidgetsBinding.instance.addPostFrameCallback((_) {
            SnackbarUtils.showFirestoreError(e);
          });
          return Center(child: Text(l10n.networkError));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ContactFormScreen()),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}
