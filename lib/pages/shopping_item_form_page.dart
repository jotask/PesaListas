import 'package:flutter/material.dart';
import 'package:pesalistas/core/shopping_item_fields.dart';
import 'package:pesalistas/l10n/l10n_extensions.dart';
import 'package:pesalistas/widgets/common/form_page_layout.dart';

class ShoppingItemFormPageResult {
  const ShoppingItemFormPageResult({
    required this.name,
    this.quantity,
    this.unit,
  });

  final String name;
  final double? quantity;
  final String? unit;
}

class ShoppingItemFormPage extends StatefulWidget {
  const ShoppingItemFormPage({super.key, this.item});

  final Map<String, dynamic>? item;

  @override
  State<ShoppingItemFormPage> createState() => _ShoppingItemFormPageState();
}

class _ShoppingItemFormPageState extends State<ShoppingItemFormPage> {
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

  void clearValidation() {
    if (validationMessage == null) return;

    setState(() => validationMessage = null);
  }

  void submit() {
    final name = nameController.text.trim();
    final quantityText = quantityController.text.trim();
    final unit = unitController.text.trim();

    setState(() => validationMessage = null);

    if (name.isEmpty) {
      setState(() => validationMessage = context.l10n.itemNameIsRequired);
      return;
    }

    final quantity = quantityText.isEmpty
        ? null
        : double.tryParse(quantityText.replaceAll(',', '.'));

    if (quantityText.isNotEmpty && quantity == null) {
      setState(() => validationMessage = context.l10n.quantityMustBeANumber);
      return;
    }

    Navigator.of(context).pop(
      ShoppingItemFormPageResult(
        name: name,
        quantity: quantity,
        unit: unit.isEmpty ? null : unit,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing
              ? context.l10n.editShoppingItem
              : context.l10n.addShoppingItem,
        ),
      ),
      bottomNavigationBar: AppFormBottomActions(
        cancelLabel: context.l10n.cancel,
        primaryLabel: isEditing ? context.l10n.save : context.l10n.add,
        primaryIcon: isEditing ? Icons.save_outlined : Icons.add,
        onCancel: () => Navigator.of(context).pop(),
        onPrimary: submit,
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            AppFormPageHeaderCard(
              icon: Icons.shopping_cart_outlined,
              title: context.l10n.shoppingItem,
              subtitle: context.l10n.addAnItemQuantityAndUnit,
            ),
            const SizedBox(height: 16),
            AppFormSectionCard(
              children: [
                TextField(
                  controller: nameController,
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: context.l10n.name,
                    hintText: context.l10n.tomatoes,
                    prefixIcon: const Icon(Icons.shopping_basket_outlined),
                  ),
                  textInputAction: TextInputAction.next,
                  onChanged: (_) => clearValidation(),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: quantityController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: InputDecoration(
                          labelText: context.l10n.quantity,
                          hintText: '2',
                          prefixIcon: const Icon(Icons.numbers_outlined),
                        ),
                        textInputAction: TextInputAction.next,
                        onChanged: (_) => clearValidation(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: unitController,
                        decoration: InputDecoration(
                          labelText: context.l10n.unit,
                          hintText: context.l10n.pcsGMl,
                          prefixIcon: const Icon(Icons.scale_outlined),
                        ),
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => submit(),
                        onChanged: (_) => clearValidation(),
                      ),
                    ),
                  ],
                ),
                if (validationMessage != null) ...[
                  const SizedBox(height: 16),
                  AppFormValidationMessage(message: validationMessage!),
                ],
              ],
            ),
            const SizedBox(height: 96),
          ],
        ),
      ),
    );
  }
}
