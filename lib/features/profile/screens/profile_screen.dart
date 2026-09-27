import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/data_providers.dart';
import '../../../services/fall_detection_service.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _notificationsEnabled = true;
  bool _locationSharingEnabled = true;
  bool _fallDetectionEnabled = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
        final profile = ref.watch(profileProvider).valueOrNull;
    final contactsAsync = ref.watch(contactsProvider);
    final themeMode = ref.watch(themeModeProvider);
    final displayName = profile?.name ?? 'User';

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
          child: Column(
            children: [
              // 1. PROFILE CARD
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [cs.primary, cs.primary.withAlpha(180)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: cs.primary.withAlpha(40),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: CircleAvatar(
                        radius: 44,
                        backgroundColor: cs.primaryContainer,
                        child: Text(
                          displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w800,
                            color: cs.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      displayName,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    if (profile?.bloodType != null && profile!.bloodType.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(30),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Blood: ${profile.bloodType} • Age: ${profile.age}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.white70,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: profile == null
                          ? null
                          : () => context.push('/profile-edit', extra: profile),
                      icon: const Icon(Icons.edit_rounded, size: 16, color: Colors.white),
                      label: const Text('Edit Profile', style: TextStyle(color: Colors.white)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white54),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        minimumSize: const Size(160, 42),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // 2. EMERGENCY CONTACTS
              _SectionHeader(
                title: 'Emergency Contacts',
                action: 'Manage',
                onAction: () => context.push('/contacts'),
              ),
              const SizedBox(height: 12),
              contactsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Text('Error loading contacts', style: theme.textTheme.bodyMedium),
                data: (contacts) {
                  if (contacts.isEmpty) {
                    return _EmptyState(
                      icon: Icons.person_add_rounded,
                      message: 'No contacts added',
                      actionLabel: 'Add Contact',
                      onAction: () => context.push('/contact-form'),
                    );
                  }
                  return Column(
                    children: contacts.map((c) => _ContactTile(
                      name: c.name,
                      phone: c.phone,
                      relationship: c.relationship,
                      isPrimary: c.isPrimary,
                    )).toList(),
                  );
                },
              ),
              const SizedBox(height: 28),

              // 3. APPEARANCE SETTINGS
              _SectionHeader(title: 'Appearance'),
              const SizedBox(height: 12),
              _SettingsTile(
                icon: Icons.palette_rounded,
                title: 'Theme',
                trailing: SegmentedButton<ThemeMode>(
                  segments: const [
                    ButtonSegment(value: ThemeMode.system, icon: Icon(Icons.brightness_auto, size: 18)),
                    ButtonSegment(value: ThemeMode.light, icon: Icon(Icons.light_mode, size: 18)),
                    ButtonSegment(value: ThemeMode.dark, icon: Icon(Icons.dark_mode, size: 18)),
                  ],
                  selected: {themeMode},
                  onSelectionChanged: (modes) {
                    ref.read(themeModeProvider.notifier).setThemeMode(modes.first);
                  },
                  style: SegmentedButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // 4. SAFETY FEATURES
              _SectionHeader(title: 'Safety Features'),
              const SizedBox(height: 12),
              _ToggleTile(
                title: 'Push Notifications',
                subtitle: 'Medicine reminders & alerts',
                icon: Icons.notifications_rounded,
                value: _notificationsEnabled,
                onChanged: (v) => setState(() => _notificationsEnabled = v),
              ),
              _ToggleTile(
                title: 'Location Sharing',
                subtitle: 'Share location with contacts',
                icon: Icons.location_on_rounded,
                value: _locationSharingEnabled,
                onChanged: (v) => setState(() => _locationSharingEnabled = v),
              ),
              _ToggleTile(
                title: 'Fall Detection',
                subtitle: 'Auto-detect falls & trigger SOS',
                icon: Icons.accessibility_new_rounded,
                value: _fallDetectionEnabled,
                onChanged: (v) {
                  setState(() => _fallDetectionEnabled = v);
                  if (v) {
                    FallDetectionService().enable();
                  } else {
                    FallDetectionService().disable();
                  }
                },
              ),
              const SizedBox(height: 28),

              // 5. PRIVACY SECTION
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cs.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: cs.outlineVariant),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.shield_rounded, color: cs.primary, size: 22),
                        const SizedBox(width: 12),
                        Text('Privacy & Security', style: theme.textTheme.titleSmall),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Your data is encrypted and only shared with your emergency contacts when an alert is triggered.',
                      style: theme.textTheme.bodySmall?.copyWith(height: 1.6),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 6. SIGN OUT
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => ref.read(firebaseServiceProvider).signOut(),
                  icon: const Icon(Icons.logout_rounded, color: AppColors.error),
                  label: const Text('Sign Out', style: TextStyle(color: AppColors.error)),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.error.withAlpha(80)),
                    minimumSize: const Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.action, this.onAction});
  final String title;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        if (action != null)
          TextButton(onPressed: onAction, child: Text(action!)),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });
  final IconData icon;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        children: [
          Icon(icon, size: 36, color: cs.onSurfaceVariant.withAlpha(100)),
          const SizedBox(height: 8),
          Text(message, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: onAction,
            icon: const Icon(Icons.add, size: 18),
            label: Text(actionLabel),
          ),
        ],
      ),
    );
  }
}

class _ContactTile extends StatelessWidget {
  const _ContactTile({
    required this.name,
    required this.phone,
    this.relationship = '',
    this.isPrimary = false,
  });
  final String name;
  final String phone;
  final String relationship;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPrimary ? AppColors.error.withAlpha(60) : cs.outlineVariant,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isPrimary ? AppColors.errorLight : cs.primaryContainer.withAlpha(40),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : '?',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  color: isPrimary ? AppColors.error : cs.primary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(name, style: theme.textTheme.titleSmall?.copyWith(fontSize: 15)),
                    if (isPrimary) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.errorLight,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'Primary',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.error,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  '$phone${relationship.isNotEmpty ? ' • $relationship' : ''}',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Icon(Icons.phone_rounded, color: cs.primary, size: 20),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({required this.icon, required this.title, required this.trailing});
  final IconData icon;
  final String title;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Row(
        children: [
          Icon(icon, color: cs.primary, size: 22),
          const SizedBox(width: 14),
          Expanded(child: Text(title, style: theme.textTheme.titleSmall)),
          trailing,
        ],
      ),
    );
  }
}

class _ToggleTile extends StatelessWidget {
  const _ToggleTile({
    required this.title,
    required this.icon,
    required this.value,
    required this.onChanged,
    this.subtitle,
  });
  final String title;
  final String? subtitle;
  final IconData icon;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Row(
        children: [
          Icon(icon, color: cs.primary, size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.titleSmall),
                if (subtitle != null)
                  Text(subtitle!, style: theme.textTheme.bodySmall),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}
