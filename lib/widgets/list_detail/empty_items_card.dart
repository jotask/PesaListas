import 'package:flutter/material.dart';
import 'package:pesalistas/widgets/common/empty_info_card.dart';

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
    return EmptyInfoCard(
      icon: icon,
      title: title,
      subtitle: subtitle,
      trailing: const Icon(Icons.add_circle_outline),
      onTap: onCreate,
    );
  }
}
