import 'package:flutter/material.dart';
import 'package:pesalistas/core/list_types.dart';

class ListDetailHeader extends StatelessWidget {
  const ListDetailHeader({
    super.key,
    required this.listName,
    required this.config,
  });

  final String listName;
  final AppListTypeConfig config;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(child: Icon(config.icon)),
        title: Text(listName),
        subtitle: Text(config.label),
      ),
    );
  }
}
