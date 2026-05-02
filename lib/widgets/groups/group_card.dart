import 'package:flutter/material.dart';
import 'package:pesalistas/core/group_fields.dart';

class GroupCard extends StatelessWidget {
  const GroupCard({super.key, required this.group, required this.onTap});

  final Map<String, dynamic> group;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final name = group[AppGroupFields.name]?.toString() ?? 'Untitled group';
    final description = group[AppGroupFields.description]?.toString();

    return Card(
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.groups)),
        title: Text(name),
        subtitle: Text(
          description == null || description.trim().isEmpty
              ? 'Shared space'
              : description.trim(),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
