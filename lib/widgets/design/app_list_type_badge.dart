import 'package:flutter/material.dart';
import 'package:pesalistas/core/design/app_radius.dart';
import 'package:pesalistas/core/design/list_type_style.dart';
import 'package:pesalistas/core/list_types.dart';

class AppListTypeBadge extends StatelessWidget {
  const AppListTypeBadge({
    super.key,
    required this.listType,
    this.compact = false,
  });

  final String listType;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final config = AppListTypes.fromValue(listType);
    final style = ListTypeStyle.of(listType);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: style.soft,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(config.icon, size: compact ? 13 : 15, color: style.onSoft),
          const SizedBox(width: 5),
          Text(
            config.label(context),
            style: TextStyle(
              color: style.onSoft,
              fontSize: compact ? 11 : 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
