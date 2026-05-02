import 'package:flutter/material.dart';

class BaseItemCard extends StatelessWidget {
  const BaseItemCard({
    super.key,
    required this.title,
    required this.fallbackTitle,
    required this.icon,
    required this.onTap,
    required this.actions,
    this.subtitle,
    this.completed = false,
    this.leadingAction,
  });

  final String? title;
  final String fallbackTitle;
  final String? subtitle;
  final IconData icon;
  final bool completed;
  final VoidCallback onTap;
  final Widget? leadingAction;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final displayTitle = title == null || title!.trim().isEmpty
        ? fallbackTitle
        : title!;

    final displaySubtitle = subtitle == null || subtitle!.trim().isEmpty
        ? null
        : subtitle!;

    return Card(
      child: ListTile(
        onTap: onTap,
        leading: leadingAction ?? CircleAvatar(child: Icon(icon)),
        title: Text(
          displayTitle,
          style: TextStyle(
            decoration: completed ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: displaySubtitle == null ? null : Text(displaySubtitle),
        trailing: actions.isEmpty ? null : Wrap(spacing: 4, children: actions),
      ),
    );
  }
}
