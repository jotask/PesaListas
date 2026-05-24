import 'package:flutter/material.dart';
import 'package:pesalistas/repositories/activity_repository.dart';

class UnreadItemHighlight extends StatelessWidget {
  const UnreadItemHighlight({
    super.key,
    required this.item,
    required this.child,
  });

  static const activityKey = '__unread_item_activity';

  final Map<String, dynamic> item;
  final Widget child;

  static ItemUnreadActivity? activityFor(Map<String, dynamic> item) {
    final value = item[activityKey];

    if (value is ItemUnreadActivity) {
      return value;
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final activity = activityFor(item);

    if (activity == null || !activity.hasUnread) {
      return child;
    }

    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final body = activity.latestBody?.trim();

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: colors.errorContainer.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.error.withValues(alpha: 0.45)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
            child: Row(
              children: [
                Icon(Icons.fiber_manual_record, size: 12, color: colors.error),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    body == null || body.isEmpty ? 'New update' : body,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: colors.error,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                if (activity.unreadCount > 1)
                  Text(
                    '+${activity.unreadCount}',
                    style: TextStyle(
                      color: colors.error,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
              ],
            ),
          ),
          child,
        ],
      ),
    );
  }
}
