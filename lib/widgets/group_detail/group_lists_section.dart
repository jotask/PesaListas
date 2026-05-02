import 'package:flutter/material.dart';
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ListsHeader(creatingList: creatingList, onCreateList: onCreateList),
        const SizedBox(height: 12),
        if (loading)
          const Center(child: CircularProgressIndicator())
        else if (lists.isEmpty)
          EmptyInfoCard(
            icon: Icons.list_alt,
            title: 'No lists yet',
            subtitle: 'Create your first shared list here.',
            trailing: const Icon(Icons.add),
            onTap: creatingList ? null : onCreateList,
          )
        else
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

class _ListsHeader extends StatelessWidget {
  const _ListsHeader({required this.creatingList, required this.onCreateList});

  final bool creatingList;
  final VoidCallback onCreateList;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Lists',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        IconButton(
          onPressed: creatingList ? null : onCreateList,
          icon: const Icon(Icons.add),
          tooltip: 'Create list',
        ),
      ],
    );
  }
}
