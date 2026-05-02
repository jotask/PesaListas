import 'package:flutter/material.dart';
import 'package:pesalistas/dialogs/vote_dialog.dart';
import 'package:pesalistas/repositories/item_repository.dart';
import 'package:pesalistas/dialogs/create_item_dialog.dart';
import 'package:pesalistas/dialogs/edit_item_dialog.dart';
import 'package:pesalistas/repositories/vote_repository.dart';
import 'package:pesalistas/widgets/list_detail/generic_items_view.dart';
import 'package:pesalistas/widgets/list_detail/item_card.dart';
import 'package:pesalistas/widgets/list_detail/items_view_factory.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ListDetailPage extends StatefulWidget {
  const ListDetailPage({super.key, required this.list});

  final Map<String, dynamic> list;

  @override
  State<ListDetailPage> createState() => _ListDetailPageState();
}

class _ListDetailPageState extends State<ListDetailPage> {
  late final ItemRepository itemRepository;
  late final VoteRepository voteRepository;

  bool loadingItems = true;
  List<Map<String, dynamic>> items = [];

  @override
  void initState() {
    super.initState();
    itemRepository = ItemRepository(Supabase.instance.client);
    voteRepository = VoteRepository(Supabase.instance.client);
    loadItems();
  }

  Future<void> voteItem(Map<String, dynamic> item) async {
    try {
      final existingVote = await voteRepository.getMyVote(item['id']);

      final result = await showDialog<VoteDialogResult>(
        context: context,
        builder: (_) => VoteDialog(
          initialPoints: existingVote?['points'] ?? 5,
          initialComment: existingVote?['comment'],
        ),
      );

      if (result == null) return;

      await voteRepository.upsertVote(
        itemId: item['id'],
        points: result.points,
        comment: result.comment,
      );
    } catch (error, stackTrace) {
      debugPrint('VOTE ITEM ERROR: $error');
      debugPrint('STACK TRACE: $stackTrace');
    }
  }

  Future<void> deleteItem(String itemId) async {
    try {
      await itemRepository.deleteItem(itemId);
      await loadItems();
    } catch (error, stackTrace) {
      debugPrint('DELETE ITEM ERROR: $error');
      debugPrint('STACK TRACE: $stackTrace');
    }
  }

  Future<void> loadItems() async {
    setState(() => loadingItems = true);

    try {
      final result = await itemRepository.getItemsForList(widget.list['id']);

      if (!mounted) return;

      setState(() {
        items = result;
        loadingItems = false;
      });
    } catch (error, stackTrace) {
      debugPrint('LOAD ITEMS ERROR: $error');
      debugPrint('STACK TRACE: $stackTrace');

      if (!mounted) return;
      setState(() => loadingItems = false);
    }
  }

  Future<void> completeItem(String itemId) async {
    try {
      await itemRepository.completeItem(itemId);
      await loadItems();
    } catch (error, stackTrace) {
      debugPrint('COMPLETE ITEM ERROR: $error');
      debugPrint('STACK TRACE: $stackTrace');
    }
  }

  Future<void> editItem(Map<String, dynamic> item) async {
    final result = await showDialog<EditItemDialogResult>(
      context: context,
      builder: (_) => EditItemDialog(item: item),
    );

    if (result == null) return;

    try {
      await itemRepository.updateItem(
        itemId: item['id'],
        title: result.title,
        description: result.description,
      );

      await loadItems();
    } catch (error, stackTrace) {
      debugPrint('EDIT ITEM ERROR: $error');
      debugPrint('STACK TRACE: $stackTrace');
    }
  }

  Future<void> createItemDialog() async {
    final result = await showDialog<CreateItemDialogResult>(
      context: context,
      builder: (_) =>
          CreateItemDialog(listType: widget.list['list_type'] ?? 'generic'),
    );

    if (result == null) return;

    try {
      await itemRepository.createItem(
        listId: widget.list['id'],
        title: result.title,
        description: result.description,
        priority: result.priority,
        deadlineAt: result.deadlineAt,
        recurrenceType: result.recurrenceType,
        recurrenceInterval: result.recurrenceInterval,
        nextDueAt: result.nextDueAt,
      );

      await loadItems();
    } catch (error, stackTrace) {
      debugPrint('CREATE ITEM ERROR: $error');
      debugPrint('STACK TRACE: $stackTrace');
    }
  }

  @override
  Widget build(BuildContext context) {
    final listName = widget.list['name'] ?? 'List';
    final listType = widget.list['list_type'] ?? 'generic';

    return Scaffold(
      appBar: AppBar(
        title: Text(listName),
        actions: [
          IconButton(onPressed: createItemDialog, icon: const Icon(Icons.add)),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: loadItems,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: ListTile(
                leading: const CircleAvatar(child: Icon(Icons.list_alt)),
                title: Text(listName),
                subtitle: Text('Type: $listType'),
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              'Items',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            ItemsViewFactory(
              listType: listType,
              items: items,
              loading: loadingItems,
              onCreate: createItemDialog,
              onComplete: completeItem,
              onEdit: editItem,
              onDelete: deleteItem,
              onVote: voteItem,
            ),
          ],
        ),
      ),
    );
  }
}
