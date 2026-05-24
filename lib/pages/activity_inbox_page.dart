import 'package:flutter/material.dart';
import 'package:pesalistas/pages/list_detail_page.dart';
import 'package:pesalistas/repositories/activity_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ActivityInboxPage extends StatefulWidget {
  const ActivityInboxPage({super.key});

  @override
  State<ActivityInboxPage> createState() => _ActivityInboxPageState();
}

class _ActivityInboxPageState extends State<ActivityInboxPage> {
  late final ActivityRepository activityRepository;

  bool loading = true;
  Object? loadError;
  List<ActivityInboxEvent> events = [];

  @override
  void initState() {
    super.initState();

    activityRepository = ActivityRepository(Supabase.instance.client);
    loadEvents();
  }

  Future<void> loadEvents() async {
    setState(() {
      loading = true;
      loadError = null;
    });

    try {
      final loadedEvents = await activityRepository.getActivityInbox();

      if (!mounted) return;

      setState(() {
        events = loadedEvents;
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

  Future<void> openEvent(ActivityInboxEvent event) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        settings: const RouteSettings(name: '/list_detail'),
        builder: (_) => ListDetailPage(list: event.list),
      ),
    );

    if (!mounted) return;

    await loadEvents();
  }

  String relativeTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'Just now';
    }

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    }

    if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    }

    if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    }

    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  IconData iconForEvent(ActivityInboxEvent event) {
    final type = event.eventType;

    if (type.contains('shopping')) {
      return Icons.shopping_basket_outlined;
    }

    if (type.contains('recipe')) {
      return Icons.restaurant_menu_outlined;
    }

    if (type.contains('meal_plan')) {
      return Icons.calendar_month_outlined;
    }

    if (type.contains('vote')) {
      return Icons.how_to_vote_outlined;
    }

    if (type.contains('completed') || type.contains('checked')) {
      return Icons.check_circle_outline;
    }

    if (type.contains('deleted')) {
      return Icons.delete_outline;
    }

    if (type.contains('updated')) {
      return Icons.edit_outlined;
    }

    return Icons.notifications_none_outlined;
  }

  @override
  Widget build(BuildContext context) {
    final error = loadError;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: loading ? null : loadEvents,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          if (loading) const LinearProgressIndicator(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: loadEvents,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (!loading && error != null)
                    _ActivityMessageCard(
                      icon: Icons.error_outline,
                      title: 'Could not load activity',
                      message: error.toString(),
                    ),
                  if (!loading && error == null && events.isEmpty)
                    const _ActivityMessageCard(
                      icon: Icons.inbox_outlined,
                      title: 'No activity yet',
                      message:
                          'Changes from your shared lists will appear here.',
                    ),
                  for (final event in events)
                    _ActivityInboxTile(
                      event: event,
                      icon: iconForEvent(event),
                      timeText: relativeTime(event.createdAt),
                      onTap: () => openEvent(event),
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

class _ActivityInboxTile extends StatelessWidget {
  const _ActivityInboxTile({
    required this.event,
    required this.icon,
    required this.timeText,
    required this.onTap,
  });

  final ActivityInboxEvent event;
  final IconData icon;
  final String timeText;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final body = event.body.trim();

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        onTap: onTap,
        leading: Stack(
          clipBehavior: Clip.none,
          children: [
            CircleAvatar(
              backgroundColor: event.isUnread
                  ? theme.colorScheme.errorContainer
                  : theme.colorScheme.surfaceContainerHighest,
              child: Icon(
                icon,
                color: event.isUnread
                    ? theme.colorScheme.onErrorContainer
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (event.isUnread)
              Positioned(
                right: -1,
                top: -1,
                child: Container(
                  width: 11,
                  height: 11,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.error,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: theme.scaffoldBackgroundColor,
                      width: 2,
                    ),
                  ),
                ),
              ),
          ],
        ),
        title: Text(
          body.isEmpty ? event.title : body,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontWeight: event.isUnread ? FontWeight.w900 : FontWeight.w700,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            '${event.groupName} • ${event.listName} • $timeText',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        trailing: event.isOwnEvent
            ? const Text(
                'You',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
              )
            : const Icon(Icons.chevron_right),
      ),
    );
  }
}

class _ActivityMessageCard extends StatelessWidget {
  const _ActivityMessageCard({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              child: Icon(icon, color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(message),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
