import 'package:flutter/material.dart';
import 'package:pesalistas/core/shopping_item_fields.dart';

class ShoppingItemDialogResult {
  const ShoppingItemDialogResult({
    required this.name,
    this.quantity,
    this.unit,
  });

  final String name;
  final double? quantity;
  final String? unit;
}

class ShoppingItemDialog extends StatefulWidget {
  const ShoppingItemDialog({super.key, this.item});

  final Map<String, dynamic>? item;

  @override
  State<ShoppingItemDialog> createState() => _ShoppingItemDialogState();
}

class _ShoppingItemDialogState extends State<ShoppingItemDialog> {
  late final TextEditingController nameController;
  late final TextEditingController quantityController;
  late final TextEditingController unitController;

  String? validationMessage;

  bool get isEditing => widget.item != null;

  @override
  void initState() {
    super.initState();

    final item = widget.item;

    nameController = TextEditingController(
      text: item?[AppShoppingItemFields.name]?.toString() ?? '',
    );

    quantityController = TextEditingController(
      text: item?[AppShoppingItemFields.quantity]?.toString() ?? '',
    );

    unitController = TextEditingController(
      text: item?[AppShoppingItemFields.unit]?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    quantityController.dispose();
    unitController.dispose();
    super.dispose();
  }

  void submit() {
    final name = nameController.text.trim();
    final quantityText = quantityController.text.trim();
    final unit = unitController.text.trim();

    setState(() => validationMessage = null);

    if (name.isEmpty) {
      setState(() => validationMessage = 'Item name is required.');
      return;
    }

    final quantity = quantityText.isEmpty
        ? null
        : double.tryParse(quantityText.replaceAll(',', '.'));

    if (quantityText.isNotEmpty && quantity == null) {
      setState(() => validationMessage = 'Quantity must be a number.');
      return;
    }

    Navigator.of(context).pop(
      ShoppingItemDialogResult(
        name: name,
        quantity: quantity,
        unit: unit.isEmpty ? null : unit,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(isEditing ? 'Edit shopping item' : 'Add shopping item'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(child: Icon(Icons.shopping_cart_outlined)),
              title: Text('Shopping item'),
              subtitle: Text('Add an item, quantity, and unit.'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: nameController,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Name',
                hintText: 'Tomatoes',
              ),
              textInputAction: TextInputAction.next,
              onChanged: (_) {
                if (validationMessage != null) {
                  setState(() => validationMessage = null);
                }
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: quantityController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Quantity',
                      hintText: '2',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: unitController,
                    decoration: const InputDecoration(
                      labelText: 'Unit',
                      hintText: 'pcs / g / ml',
                    ),
                  ),
                ),
              ],
            ),
            if (validationMessage != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.error_outline, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      validationMessage!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: submit,
          child: Text(isEditing ? 'Save' : 'Add'),
        ),
      ],
    );
  }
}
