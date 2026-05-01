import 'package:flutter/material.dart';
import 'package:pesalistas/repositories/item_repository.dart';
import 'package:pesalistas/tools/create_item_dialog.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ListDetailPage extends StatefulWidget {
  const ListDetailPage({super.key, required this.list});

  final Map<String, dynamic> list;

  @override
  State<ListDetailPage> createState() => _ListDetailPageState();
}

class _ListDetailPageState extends State<ListDetailPage> {
  late final ItemRepository itemRepository;

  bool loadingItems = true;
  List<Map<String, dynamic>> items = [];

  @override
  void initState() {
    super.initState();
    itemRepository = ItemRepository(Supabase.instance.client);
    loadItems();
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

  Future<void> createItemDialog() async {
    final result = await showDialog<CreateItemDialogResult>(
      context: context,
      builder: (_) => const CreateItemDialog(),
    );

    if (result == null) return;

    try {
      await itemRepository.createItem(
        listId: widget.list['id'],
        title: result.title,
        description: result.description,
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

            if (loadingItems)
              const Center(child: CircularProgressIndicator())
            else if (items.isEmpty)
              Card(
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.add_task)),
                  title: const Text('No items yet'),
                  subtitle: const Text('Add your first item.'),
                  trailing: const Icon(Icons.add),
                  onTap: createItemDialog,
                ),
              )
            else
              for (final item in items)
                Card(
                  child: ListTile(
                    leading: IconButton(
                      icon: Icon(
                        item['status'] == 'done'
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                      ),
                      onPressed: item['status'] == 'done'
                          ? null
                          : () => completeItem(item['id']),
                    ),
                    title: Text(
                      item['title'] ?? 'Untitled item',
                      style: TextStyle(
                        decoration: item['status'] == 'done'
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    subtitle: Text(
                      item['description'] ?? item['status'] ?? 'Open',
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}
