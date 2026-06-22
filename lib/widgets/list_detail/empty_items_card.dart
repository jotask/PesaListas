import 'package:flutter/material.dart';
import 'package:pesalistas/widgets/design/app_empty_state.dart';

class EmptyItemsCard extends StatelessWidget {
  const EmptyItemsCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onCreate,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return AppEmptyState(
      icon: icon,
      title: title,
      subtitle: subtitle,
      action: FilledButton.icon(
        onPressed: onCreate,
        icon: const Icon(Icons.add),
        label: Text(title),
      ),
    );
  }
}
