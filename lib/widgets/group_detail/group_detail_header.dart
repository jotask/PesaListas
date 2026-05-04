import 'package:flutter/material.dart';
import 'package:pesalistas/l10n/app_strings.dart';

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
        ? S.sharedSpace
        : description!.trim();

    return Card(
      child: ListTile(
        leading: CircleAvatar(child: Icon(Icons.groups)),
        title: Text(groupName),
        subtitle: Text(subtitle),
      ),
    );
  }
}
