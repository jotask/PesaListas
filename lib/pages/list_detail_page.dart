import 'package:flutter/material.dart';
import 'package:pesalistas/core/item_fields.dart';
import 'package:pesalistas/core/list_fields.dart';
import 'package:pesalistas/core/list_types.dart';
import 'package:pesalistas/core/ui_feedback.dart';
import 'package:pesalistas/core/vote_fields.dart';
import 'package:pesalistas/dialogs/confirm_delete_dialog.dart';
import 'package:pesalistas/dialogs/create_item_dialog.dart';
import 'package:pesalistas/dialogs/edit_item_dialog.dart';
import 'package:pesalistas/dialogs/vote_dialog.dart';
import 'package:pesalistas/repositories/item_repository.dart';
import 'package:pesalistas/repositories/vote_repository.dart';
import 'package:pesalistas/widgets/list_detail/list_detail_header.dart';
import 'package:pesalistas/widgets/list_detail/list_items_section.dart';
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
  bool creatingItem = false;
  bool editingItem = false;
  bool deletingItem = false;
  bool completingItem = false;
  bool votingItem = false;

  List<Map<String, dynamic>> items = [];

  String get listId => widget.list[AppListFields.id].toString();

  String get listName => widget.list[AppListFields.name]?.toString() ?? 'List';

  String get listType =>
      widget.list[AppListFields.listType]?.toString() ??
      AppListTypes.generic.value;

  AppListTypeConfig get listTypeConfig => AppListTypes.fromValue(listType);

  bool get isTaskList => listType == AppListTypes.tasks.value;

  bool get isChoreList => listType == AppListTypes.chores.value;

  bool get isBusy =>
      creatingItem ||
      editingItem ||
      deletingItem ||
      completingItem ||
      votingItem;

  @override
  void initState() {
    super.initState();

    final client = Supabase.instance.client;

    itemRepository = ItemRepository(client);
    voteRepository = VoteRepository(client);

    loadItems();
  }

  Future<void> loadItems() async {
    if (!mounted) return;

    setState(() => loadingItems = true);

    try {
      final result = await itemRepository.getItemsForList(listId);

      if (!mounted) return;

      setState(() {
        items = result;
        loadingItems = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() => loadingItems = false);
      showErrorSnackBar(context, 'Failed to load items', error);
    }
  }

  Future<void> createItemDialog() async {
    if (creatingItem) return;

    final result = await showDialog<CreateItemDialogResult>(
      context: context,
      builder: (_) => CreateItemDialog(listType: listType),
    );

    if (result == null) return;

    setState(() => creatingItem = true);

    try {
      await itemRepository.createItem(
        listId: listId,
        title: result.title,
        description: result.description,
        priority: result.priority,
        deadlineAt: result.deadlineAt,
        recurrenceType: result.recurrenceType,
        recurrenceInterval: result.recurrenceInterval,
        nextDueAt: result.nextDueAt,
      );

      await loadItems();

      if (!mounted) return;

      showSuccessSnackBar(context, 'Item created');
    } catch (error) {
      if (!mounted) return;

      showErrorSnackBar(context, 'Failed to create item', error);
    } finally {
      if (!mounted) return;

      setState(() => creatingItem = false);
    }
  }

  Future<void> editItem(Map<String, dynamic> item) async {
    if (editingItem) return;

    final result = await showDialog<EditItemDialogResult>(
      context: context,
      builder: (_) => EditItemDialog(item: item, listType: listType),
    );

    if (result == null) return;

    setState(() => editingItem = true);

    try {
      await itemRepository.updateItem(
        itemId: item[AppItemFields.id].toString(),
        title: result.title,
        description: result.description,
        updateTaskFields: isTaskList,
        priority: result.priority,
        deadlineAt: result.deadlineAt,
        updateChoreFields: isChoreList,
        recurrenceType: result.recurrenceType,
        recurrenceInterval: result.recurrenceInterval,
        nextDueAt: result.nextDueAt,
      );

      await loadItems();

      if (!mounted) return;

      showSuccessSnackBar(context, 'Item updated');
    } catch (error) {
      if (!mounted) return;

      showErrorSnackBar(context, 'Failed to update item', error);
    } finally {
      if (!mounted) return;

      setState(() => editingItem = false);
    }
  }

  Future<void> completeItem(String itemId) async {
    if (completingItem) return;

    setState(() => completingItem = true);

    try {
      await itemRepository.completeItem(itemId);
      await loadItems();

      if (!mounted) return;

      showSuccessSnackBar(context, 'Item completed');
    } catch (error) {
      if (!mounted) return;

      showErrorSnackBar(context, 'Failed to complete item', error);
    } finally {
      if (!mounted) return;

      setState(() => completingItem = false);
    }
  }

  Future<void> deleteItem(String itemId) async {
    if (deletingItem) return;

    final confirmed = await showConfirmDeleteDialog(
      context: context,
      title: 'Delete item?',
      message: 'This will permanently delete the item from this list.',
    );

    if (!confirmed) return;

    setState(() => deletingItem = true);

    try {
      await itemRepository.deleteItem(itemId);
      await loadItems();

      if (!mounted) return;

      showSuccessSnackBar(context, 'Item deleted');
    } catch (error) {
      if (!mounted) return;

      showErrorSnackBar(context, 'Failed to delete item', error);
    } finally {
      if (!mounted) return;

      setState(() => deletingItem = false);
    }
  }

  Future<void> voteItem(Map<String, dynamic> item) async {
    if (votingItem) return;

    setState(() => votingItem = true);

    try {
      final existingVote = await voteRepository.getMyVote(
        item[AppItemFields.id].toString(),
      );

      if (!mounted) return;

      final existingPoints = existingVote?[AppVoteFields.points];
      final initialPoints = existingPoints is int
          ? existingPoints
          : int.tryParse(existingPoints?.toString() ?? '') ?? 5;

      final result = await showDialog<VoteDialogResult>(
        context: context,
        builder: (_) => VoteDialog(
          initialPoints: initialPoints,
          initialComment: existingVote?[AppVoteFields.comment]?.toString(),
        ),
      );

      if (result == null) return;

      await voteRepository.upsertVote(
        itemId: item[AppItemFields.id].toString(),
        points: result.points,
        comment: result.comment,
      );

      await loadItems();

      if (!mounted) return;

      showSuccessSnackBar(context, 'Vote saved');
    } catch (error) {
      if (!mounted) return;

      showErrorSnackBar(context, 'Failed to save vote', error);
    } finally {
      if (!mounted) return;

      setState(() => votingItem = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final config = listTypeConfig;

    return Scaffold(
      appBar: AppBar(
        title: Text(listName),
        actions: [
          IconButton(
            onPressed: creatingItem ? null : createItemDialog,
            icon: const Icon(Icons.add),
            tooltip: 'Add item',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: loadItems,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ListDetailHeader(listName: listName, config: config),
            if (isBusy) ...[
              const SizedBox(height: 12),
              const LinearProgressIndicator(),
            ],
            const SizedBox(height: 24),
            ListItemsSection(
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
