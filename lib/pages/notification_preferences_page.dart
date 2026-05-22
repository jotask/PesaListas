import 'package:flutter/material.dart';
import 'package:pesalistas/core/ui_feedback.dart';
import 'package:pesalistas/repositories/notification_preferences_repository.dart';
import 'package:pesalistas/widgets/common/app_message_card.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationPreferencesPage extends StatefulWidget {
  const NotificationPreferencesPage({super.key});

  @override
  State<NotificationPreferencesPage> createState() =>
      _NotificationPreferencesPageState();
}

class _NotificationPreferencesPageState
    extends State<NotificationPreferencesPage> {
  late final NotificationPreferencesRepository repository;

  NotificationPreferences? preferences;
  bool loading = true;
  bool saving = false;
  Object? loadError;

  @override
  void initState() {
    super.initState();

    repository = NotificationPreferencesRepository(Supabase.instance.client);

    loadPreferences();
  }

  Future<void> loadPreferences() async {
    setState(() {
      loading = true;
      loadError = null;
    });

    try {
      final result = await repository.getOrCreateForCurrentUser();

      if (!mounted) return;

      setState(() {
        preferences = result;
        loading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        loadError = error;
        loading = false;
      });
    }
  }

  Future<void> savePreferences(NotificationPreferences next) async {
    if (saving) return;

    setState(() {
      saving = true;
      preferences = next;
    });

    try {
      final saved = await repository.updateForCurrentUser(next);

      if (!mounted) return;

      setState(() {
        preferences = saved;
        saving = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        saving = false;
      });

      showErrorSnackBar(
        context,
        'Failed to update notification preferences.',
        error,
      );

      await loadPreferences();
    }
  }

  @override
  Widget build(BuildContext context) {
    final current = preferences;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification preferences'),
        actions: [
          IconButton(
            tooltip: 'Reload',
            onPressed: loading || saving ? null : loadPreferences,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          if (loading || saving) const LinearProgressIndicator(),
          Expanded(
            child: SafeArea(
              top: false,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const AppMessageCard(
                    icon: Icons.notifications_active_outlined,
                    message:
                        'Choose which notifications you want to receive for this app.',
                  ),
                  const SizedBox(height: 12),
                  if (loading)
                    const AppMessageCard(
                      icon: Icons.sync_outlined,
                      message: 'Loading notification preferences...',
                    ),
                  if (!loading && loadError != null)
                    AppMessageCard(
                      icon: Icons.error_outline,
                      message: loadError.toString(),
                      tone: AppMessageCardTone.error,
                    ),
                  if (!loading && current != null)
                    _PreferencesCard(
                      preferences: current,
                      saving: saving,
                      onChanged: savePreferences,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PreferencesCard extends StatelessWidget {
  const _PreferencesCard({
    required this.preferences,
    required this.saving,
    required this.onChanged,
  });

  final NotificationPreferences preferences;
  final bool saving;
  final Future<void> Function(NotificationPreferences preferences) onChanged;

  bool get childrenEnabled {
    return preferences.enabled && !saving;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          SwitchListTile(
            secondary: const Icon(Icons.notifications_active_outlined),
            title: const Text('All push notifications'),
            subtitle: const Text(
              'Master switch for server-side push notifications.',
            ),
            value: preferences.enabled,
            onChanged: saving
                ? null
                : (value) {
                    onChanged(preferences.copyWith(enabled: value));
                  },
          ),
          const Divider(height: 1),
          SwitchListTile(
            secondary: const Icon(Icons.mail_outline),
            title: const Text('Group invitations'),
            subtitle: const Text('Notify me when I am invited to a group.'),
            value: preferences.invitationsEnabled,
            onChanged: childrenEnabled
                ? (value) {
                    onChanged(preferences.copyWith(invitationsEnabled: value));
                  }
                : null,
          ),
          SwitchListTile(
            secondary: const Icon(Icons.assignment_ind_outlined),
            title: const Text('Item assignments'),
            subtitle: const Text('Notify me when I am assigned a task/chore.'),
            value: preferences.assignmentsEnabled,
            onChanged: childrenEnabled
                ? (value) {
                    onChanged(preferences.copyWith(assignmentsEnabled: value));
                  }
                : null,
          ),
          SwitchListTile(
            secondary: const Icon(Icons.schedule_outlined),
            title: const Text('Due soon reminders'),
            subtitle: const Text('Notify me about items due soon.'),
            value: preferences.dueSoonEnabled,
            onChanged: childrenEnabled
                ? (value) {
                    onChanged(preferences.copyWith(dueSoonEnabled: value));
                  }
                : null,
          ),
          SwitchListTile(
            secondary: const Icon(Icons.alarm_on_outlined),
            title: const Text('Due now reminders'),
            subtitle: const Text('Notify me when items are due now.'),
            value: preferences.dueNowEnabled,
            onChanged: childrenEnabled
                ? (value) {
                    onChanged(preferences.copyWith(dueNowEnabled: value));
                  }
                : null,
          ),
        ],
      ),
    );
  }
}
