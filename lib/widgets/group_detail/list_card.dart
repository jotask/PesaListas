import 'package:flutter/material.dart';
import 'package:pesalistas/l10n/l10n_extensions.dart';
import 'package:pesalistas/core/fields/list_fields.dart';
import 'package:pesalistas/core/list_types.dart';

class ListCard extends StatelessWidget {
  const ListCard({super.key, required this.list, required this.onTap});

  final Map<String, dynamic> list;
  final VoidCallback onTap;

  String? textOrNull(dynamic value) {
    final text = value?.toString().trim();

    if (text == null || text.isEmpty) {
      return null;
    }

    return text;
  }

  @override
  Widget build(BuildContext context) {
    final name =
        textOrNull(list[AppListFields.name]) ?? context.l10n.untitledList;

    final description = textOrNull(list[AppListFields.description]);

    final listType = list[AppListFields.listType]?.toString();
    final config = AppListTypes.fromValue(listType);

    return Card(
      child: ListTile(
        leading: CircleAvatar(child: Icon(config.icon)),
        title: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(
          description ?? config.label(context),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
