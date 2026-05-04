import 'package:flutter/material.dart';
import 'package:pesalistas/l10n/app_strings.dart';
import 'package:pesalistas/pages/list_detail_page.dart';
import 'package:pesalistas/widgets/common/empty_info_card.dart';
import 'package:pesalistas/widgets/group_detail/list_card.dart';

class GroupListsSection extends StatelessWidget {
  const GroupListsSection({
    super.key,
    required this.lists,
    required this.loading,
    required this.creatingList,
    required this.onCreateList,
  });

  final List<Map<String, dynamic>> lists;
  final bool loading;
  final bool creatingList;
  final VoidCallback onCreateList;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (lists.isEmpty) {
      return EmptyInfoCard(
        icon: Icons.list_alt,
        title: S.noListsYet,
        subtitle: S.createYourFirstSharedListHere,
        trailing: Icon(Icons.add_circle_outline),
        onTap: creatingList ? null : onCreateList,
      );
    }

    return Column(
      children: [
        for (final list in lists)
          ListCard(
            list: list,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => ListDetailPage(list: list)),
              );
            },
          ),
      ],
    );
  }
}
