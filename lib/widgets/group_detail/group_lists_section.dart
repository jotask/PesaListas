import 'package:flutter/material.dart';
import 'package:pesalistas/l10n/l10n_extensions.dart';
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
    required this.onListsChanged,
  });

  final List<Map<String, dynamic>> lists;
  final bool loading;
  final bool creatingList;
  final VoidCallback onCreateList;
  final VoidCallback onListsChanged;

  Future<void> openList(BuildContext context, Map<String, dynamic> list) async {
    final changed = await Navigator.of(
      context,
    ).push<bool>(MaterialPageRoute(builder: (_) => ListDetailPage(list: list)));

    if (changed == true) {
      onListsChanged();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (lists.isEmpty) {
      return EmptyInfoCard(
        icon: Icons.list_alt,
        title: context.l10n.noListsYet,
        subtitle: context.l10n.createYourFirstSharedListHere,
        trailing: Icon(Icons.add_circle_outline),
        onTap: creatingList ? null : onCreateList,
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        final crossAxisCount = width >= 1200
            ? 4
            : width >= 760
            ? 3
            : 2;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: lists.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: width < 380 ? 0.88 : 0.95,
          ),
          itemBuilder: (context, index) {
            final list = lists[index];
            return ListCard(list: list, onTap: () => openList(context, list));
          },
        );
      },
    );
  }
}
