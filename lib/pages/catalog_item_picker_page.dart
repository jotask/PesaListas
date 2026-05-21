import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pesalistas/core/app_units.dart';
import 'package:pesalistas/core/fields/catalog_item_fields.dart';
import 'package:pesalistas/core/value_parsing.dart';
import 'package:pesalistas/l10n/l10n_extensions.dart';
import 'package:pesalistas/pages/edit_catalog_item_page.dart';
import 'package:pesalistas/pages/generic_item_detail_page.dart';
import 'package:pesalistas/repositories/catalog_item_repository.dart';
import 'package:pesalistas/widgets/common/app_unit_dropdown_field.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CatalogItemPickerPage extends StatefulWidget {
  const CatalogItemPickerPage({
    super.key,
    this.selectionMode = true,
    this.groupId,
  });

  final bool selectionMode;
  final String? groupId;

  @override
  State<CatalogItemPickerPage> createState() => _CatalogItemPickerPageState();
}

class _CatalogItemPickerPageState extends State<CatalogItemPickerPage> {
  late final CatalogItemRepository catalogItemRepository;

  final TextEditingController searchController = TextEditingController();
  final TextEditingController defaultUnitController = TextEditingController();

  Timer? searchDebounce;

  bool loading = true;
  bool creating = false;
  String? errorMessage;
  String query = '';

  List<Map<String, dynamic>> items = [];

  @override
  void initState() {
    super.initState();

    catalogItemRepository = CatalogItemRepository(Supabase.instance.client);

    loadItems();
  }

  @override
  void dispose() {
    searchDebounce?.cancel();
    searchController.dispose();
    defaultUnitController.dispose();
    super.dispose();
  }

  Future<void> loadItems() async {
    setState(() {
      loading = true;
      errorMessage = null;
    });

    try {
      final result = query.trim().isEmpty
          ? await catalogItemRepository.getRecentCatalogItems(limit: 100)
          : await catalogItemRepository.searchCatalogItems(query, limit: 100);

      if (!mounted) return;

      setState(() {
        items = result;
        loading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        errorMessage = error.toString();
        loading = false;
      });
    }
  }

  void updateSearch(String value) {
    setState(() => query = value);

    searchDebounce?.cancel();
    searchDebounce = Timer(const Duration(milliseconds: 250), loadItems);
  }

  void clearSearch() {
    searchDebounce?.cancel();
    searchController.clear();

    defaultUnitController.clear();

    setState(() => query = '');

    loadItems();
  }

  String itemName(Map<String, dynamic> item) {
    return AppValueParsing.textOrNull(item[AppCatalogItemFields.name]) ??
        'Unnamed item';
  }

  String? itemCategory(Map<String, dynamic> item) {
    return AppValueParsing.textOrNull(item[AppCatalogItemFields.category]);
  }

  String? itemDefaultUnit(Map<String, dynamic> item) {
    return AppValueParsing.textOrNull(item[AppCatalogItemFields.defaultUnit]);
  }

  Future<void> selectItem(Map<String, dynamic> item) async {
    if (widget.selectionMode) {
      Navigator.of(context).pop(item);
      return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute(
        settings: const RouteSettings(name: '/generic_item_detail'),
        builder: (_) =>
            GenericItemDetailPage(catalogItem: item, groupId: widget.groupId),
      ),
    );

    if (!mounted) return;

    await loadItems();
  }

  Future<void> createFromSearch() async {
    final name = query.trim();

    if (name.isEmpty || creating) return;

    FocusScope.of(context).unfocus();

    setState(() {
      creating = true;
      errorMessage = null;
    });

    try {
      final defaultUnit = AppUnitType.valueOrNull(defaultUnitController.text);

      final created = await catalogItemRepository.findOrCreateCatalogItem(
        name: name,
        defaultUnit: defaultUnit,
      );

      if (!mounted) return;

      if (widget.selectionMode) {
        Navigator.of(context).pop(created);
        return;
      }

      searchController.clear();
      defaultUnitController.clear();

      setState(() {
        query = '';
      });

      await loadItems();

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Generic item created.')));
    } catch (error) {
      if (!mounted) return;

      setState(() {
        errorMessage = error.toString();
      });
    } finally {
      if (mounted) {
        setState(() => creating = false);
      }
    }
  }

  Future<void> editCatalogItem(Map<String, dynamic> item) async {
    final itemId = item[AppCatalogItemFields.id]?.toString();

    if (itemId == null || itemId.isEmpty) {
      return;
    }

    final result = await Navigator.of(context).push<EditCatalogItemPageResult>(
      MaterialPageRoute(settings: const RouteSettings(name: '/edit_catalog_item'), builder: (_) => EditCatalogItemPage(catalogItem: item)),
    );

    if (result == null) {
      return;
    }

    setState(() => creating = true);

    try {
      await catalogItemRepository.updateCatalogItem(
        catalogItemId: itemId,
        name: result.name,
        category: result.category,
        defaultUnit: result.defaultUnit,
      );

      await loadItems();
    } finally {
      if (mounted) {
        setState(() => creating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final canCreate = query.trim().isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.selectionMode ? 'Select generic item' : 'Generic items',
        ),
        actions: [
          IconButton(
            onPressed: loading ? null : loadItems,
            icon: const Icon(Icons.refresh),
            tooltip: context.l10n.refresh,
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          onRefresh: loadItems,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _CatalogItemPickerHeaderCard(totalCount: items.length),
              const SizedBox(height: 12),
              SearchBar(
                controller: searchController,
                leading: const Icon(Icons.search),
                hintText: 'Search generic item',
                onChanged: updateSearch,
                trailing: [
                  if (query.isNotEmpty)
                    IconButton(
                      onPressed: clearSearch,
                      icon: const Icon(Icons.close),
                      tooltip: context.l10n.clearSearch,
                    ),
                ],
              ),
              const SizedBox(height: 12),
              if (errorMessage != null) ...[
                _CatalogItemPickerErrorCard(message: errorMessage!),
                const SizedBox(height: 12),
              ],
              if (canCreate) ...[
                _CreateCatalogItemCard(
                  name: query.trim(),
                  loading: creating,
                  defaultUnitController: defaultUnitController,
                  onUnitChanged: () => setState(() {}),
                  onCreate: createFromSearch,
                ),
                const SizedBox(height: 12),
              ],
              if (loading)
                const _CatalogItemLoadingCard()
              else if (items.isEmpty)
                _CatalogItemEmptyCard(
                  hasQuery: query.trim().isNotEmpty,
                  onCreate: canCreate ? createFromSearch : null,
                )
              else
                for (final item in items)
                  _CatalogItemCard(
                    item: item,
                    selectionMode: widget.selectionMode,
                    onTap: () => selectItem(item),
                    onEdit: () => editCatalogItem(item),
                  ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _CatalogItemPickerHeaderCard extends StatelessWidget {
  const _CatalogItemPickerHeaderCard({required this.totalCount});

  final int totalCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: theme.colorScheme.primaryContainer,
              child: Icon(
                Icons.category_outlined,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Generic items',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$totalCount loaded from catalog',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CreateCatalogItemCard extends StatelessWidget {
  const _CreateCatalogItemCard({
    required this.name,
    required this.loading,
    required this.defaultUnitController,
    required this.onUnitChanged,
    required this.onCreate,
  });

  final String name;
  final bool loading;
  final TextEditingController defaultUnitController;
  final VoidCallback onUnitChanged;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    final selectedUnit = defaultUnitController.text.trim();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const CircleAvatar(child: Icon(Icons.add)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Create "$name"',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                if (loading)
                  const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              selectedUnit.isEmpty
                  ? 'Add this as a reusable generic item.'
                  : 'Add this as a reusable generic item using "$selectedUnit" by default.',
            ),
            const SizedBox(height: 12),
            AppUnitDropdownField(
              controller: defaultUnitController,
              labelText: 'Default unit',
              hintText: 'Optional',
              prefixIcon: Icons.scale_outlined,
              enabled: !loading,
              onChanged: onUnitChanged,
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: loading ? null : onCreate,
              icon: const Icon(Icons.add),
              label: const Text('Create generic item'),
            ),
          ],
        ),
      ),
    );
  }
}

class _CatalogItemCard extends StatelessWidget {
  const _CatalogItemCard({
    required this.item,
    required this.selectionMode,
    required this.onTap,
    required this.onEdit,
  });

  final Map<String, dynamic> item;
  final bool selectionMode;
  final VoidCallback onTap;
  final VoidCallback onEdit;

  String get name {
    return AppValueParsing.textOrNull(item[AppCatalogItemFields.name]) ??
        'Unnamed item';
  }

  String? get category {
    return AppValueParsing.textOrNull(item[AppCatalogItemFields.category]);
  }

  String? get defaultUnit {
    return AppUnitType.valueOrNull(
      AppValueParsing.textOrNull(item[AppCatalogItemFields.defaultUnit]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final subtitleParts = <String>[
      ?category,
      if (defaultUnit != null)
        'Default unit: ${AppUnitType.displayLabel(defaultUnit)}',
    ];

    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.surfaceContainerHighest,
          child: Icon(
            Icons.category_outlined,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.w800)),
        subtitle: subtitleParts.isEmpty
            ? null
            : Text(subtitleParts.join(' • ')),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: onEdit,
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Edit generic item',
            ),
            Icon(
              selectionMode ? Icons.check_circle_outline : Icons.chevron_right,
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}

class _CatalogItemLoadingCard extends StatelessWidget {
  const _CatalogItemLoadingCard();

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(18),
        child: Row(
          children: [
            SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 12),
            Expanded(child: Text('Loading generic items...')),
          ],
        ),
      ),
    );
  }
}

class _CatalogItemEmptyCard extends StatelessWidget {
  const _CatalogItemEmptyCard({required this.hasQuery, required this.onCreate});

  final bool hasQuery;
  final VoidCallback? onCreate;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            const CircleAvatar(child: Icon(Icons.search_off_outlined)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                hasQuery
                    ? 'No generic items match this search.'
                    : 'No generic items yet.',
              ),
            ),
            if (onCreate != null) ...[
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: onCreate,
                icon: const Icon(Icons.add),
                label: const Text('Create'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CatalogItemPickerErrorCard extends StatelessWidget {
  const _CatalogItemPickerErrorCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: theme.colorScheme.errorContainer,
              child: Icon(
                Icons.error_outline,
                color: theme.colorScheme.onErrorContainer,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }
}
