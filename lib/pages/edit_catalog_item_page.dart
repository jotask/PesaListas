import 'package:flutter/material.dart';
import 'package:pesalistas/core/app_units.dart';
import 'package:pesalistas/core/fields/catalog_item_fields.dart';
import 'package:pesalistas/core/value_parsing.dart';
import 'package:pesalistas/widgets/common/app_unit_dropdown_field.dart';

class EditCatalogItemPageResult {
  const EditCatalogItemPageResult({
    required this.name,
    this.category,
    this.defaultUnit,
  });

  final String name;
  final String? category;
  final String? defaultUnit;
}

class EditCatalogItemPage extends StatefulWidget {
  const EditCatalogItemPage({super.key, required this.catalogItem});

  final Map<String, dynamic> catalogItem;

  @override
  State<EditCatalogItemPage> createState() => _EditCatalogItemPageState();
}

class _EditCatalogItemPageState extends State<EditCatalogItemPage> {
  late final TextEditingController nameController;
  late final TextEditingController categoryController;
  late final TextEditingController defaultUnitController;

  String? validationMessage;

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController(
      text:
          AppValueParsing.textOrNull(
            widget.catalogItem[AppCatalogItemFields.name],
          ) ??
          '',
    );

    categoryController = TextEditingController(
      text:
          AppValueParsing.textOrNull(
            widget.catalogItem[AppCatalogItemFields.category],
          ) ??
          '',
    );

    defaultUnitController = TextEditingController(
      text:
          AppUnitType.valueOrNull(
            AppValueParsing.textOrNull(
              widget.catalogItem[AppCatalogItemFields.defaultUnit],
            ),
          ) ??
          '',
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    categoryController.dispose();
    defaultUnitController.dispose();
    super.dispose();
  }

  void clearValidation() {
    if (validationMessage == null) return;
    setState(() => validationMessage = null);
  }

  void submit() {
    final name = nameController.text.trim();

    if (name.isEmpty) {
      setState(() => validationMessage = 'Name is required.');
      return;
    }

    Navigator.of(context).pop(
      EditCatalogItemPageResult(
        name: name,
        category: AppValueParsing.textOrNull(categoryController.text),
        defaultUnit: AppUnitType.valueOrNull(defaultUnitController.text),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Edit generic item')),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: submit,
                  icon: const Icon(Icons.save_outlined),
                  label: const Text('Save'),
                ),
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: theme.colorScheme.primaryContainer,
                      child: Icon(
                        Icons.category_outlined,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Generic catalog item',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Edit the reusable item name, category and default unit.',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (validationMessage != null) ...[
              Text(
                validationMessage!,
                style: TextStyle(
                  color: theme.colorScheme.error,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
            ],
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                hintText: 'Tomatoes, Milk, Eggs...',
                prefixIcon: Icon(Icons.label_outline),
              ),
              textInputAction: TextInputAction.next,
              onChanged: (_) => clearValidation(),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: categoryController,
              decoration: const InputDecoration(
                labelText: 'Category',
                hintText: 'Vegetables, Dairy, Pantry...',
                prefixIcon: Icon(Icons.folder_outlined),
              ),
              textInputAction: TextInputAction.next,
              onChanged: (_) => clearValidation(),
            ),
            const SizedBox(height: 12),
            AppUnitDropdownField(
              controller: defaultUnitController,
              labelText: 'Default unit',
              hintText: 'Optional',
              prefixIcon: Icons.scale_outlined,
              onChanged: () {
                clearValidation();
                setState(() {});
              },
            ),
            const SizedBox(height: 96),
          ],
        ),
      ),
    );
  }
}
