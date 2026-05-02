import 'package:flutter/material.dart';

class GroupListCard extends StatelessWidget {
  const GroupListCard({super.key, required this.list, required this.onTap});

  final Map<String, dynamic> list;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.list_alt)),
        title: Text(list['name'] ?? 'Untitled list'),
        subtitle: Text(list['list_type'] ?? 'generic'),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
