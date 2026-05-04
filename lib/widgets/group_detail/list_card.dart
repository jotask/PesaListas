import 'package:flutter/material.dart';
import 'package:pesalistas/l10n/app_strings.dart';
import 'package:pesalistas/core/list_fields.dart';
import 'package:pesalistas/core/list_types.dart';

class ListCard extends StatelessWidget {
  const ListCard({super.key, required this.list, required this.onTap});

  final Map<String, dynamic> list;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final name = list[AppListFields.name]?.toString() ?? S.untitledList;
    final listType = list[AppListFields.listType]?.toString();

    final config = AppListTypes.fromValue(listType);

    return Card(
      child: ListTile(
        leading: CircleAvatar(child: Icon(config.icon)),
        title: Text(name),
        subtitle: Text(config.label),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
