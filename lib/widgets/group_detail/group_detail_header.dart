import 'package:flutter/material.dart';

class GroupDetailHeader extends StatelessWidget {
  const GroupDetailHeader({
    super.key,
    required this.groupName,
    this.description,
  });

  final String groupName;
  final String? description;

  @override
  Widget build(BuildContext context) {
    final subtitle = description == null || description!.trim().isEmpty
        ? 'Shared space'
        : description!.trim();

    return Card(
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.groups)),
        title: Text(groupName),
        subtitle: Text(subtitle),
      ),
    );
  }
}
