import 'package:flutter/material.dart';
import 'package:pesalistas/core/recipe_ingredient_fields.dart';
import 'package:pesalistas/l10n/l10n_extensions.dart';
import 'package:pesalistas/widgets/common/form_page_layout.dart';

class RecipeIngredientFormPageResult {
  const RecipeIngredientFormPageResult({
    required this.name,
    this.quantity,
    this.unit,
    this.note,
    this.estimatedUnitPrice,
    this.priceCurrency = 'EUR',
  });

  final String name;
  final double? quantity;
  final String? unit;
  final String? note;
  final double? estimatedUnitPrice;
  final String priceCurrency;
}

class RecipeIngredientFormPage extends StatefulWidget {
  const RecipeIngredientFormPage({super.key, this.ingredient});

  final Map<String, dynamic>? ingredient;

  @override
  State<RecipeIngredientFormPage> createState() =>
      _RecipeIngredientFormPageState();
}

class _RecipeIngredientFormPageState extends State<RecipeIngredientFormPage> {
  late final TextEditingController nameController;
  late final TextEditingController quantityController;
  late final TextEditingController unitController;
  late final TextEditingController noteController;
  late final TextEditingController priceController;

  String? validationMessage;

  bool get isEditing => widget.ingredient != null;

  String get priceCurrency {
    return textOrNull(
          widget.ingredient?[AppRecipeIngredientFields.priceCurrency],
        ) ??
        'EUR';
  }

  @override
  void initState() {
    super.initState();

    final ingredient = widget.ingredient;

    nameController = TextEditingController(
      text: ingredient?[AppRecipeIngredientFields.name]?.toString() ?? '',
    );

    quantityController = TextEditingController(
      text: ingredient?[AppRecipeIngredientFields.quantity]?.toString() ?? '',
    );

    unitController = TextEditingController(
      text: ingredient?[AppRecipeIngredientFields.unit]?.toString() ?? '',
    );

    noteController = TextEditingController(
      text: ingredient?[AppRecipeIngredientFields.note]?.toString() ?? '',
    );

    priceController = TextEditingController(
      text:
          ingredient?[AppRecipeIngredientFields.estimatedUnitPrice]
              ?.toString() ??
          '',
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    quantityController.dispose();
    unitController.dispose();
    noteController.dispose();
    priceController.dispose();
    super.dispose();
  }

  void clearValidation() {
    if (validationMessage == null) return;

    setState(() => validationMessage = null);
  }

  double? parseOptionalDouble(String value) {
    final text = value.trim();

    if (text.isEmpty) {
      return null;
    }

    return double.tryParse(text.replaceAll(',', '.'));
  }

  double? currentQuantity() {
    return parseOptionalDouble(quantityController.text);
  }

  double? currentPrice() {
    return parseOptionalDouble(priceController.text);
  }

  double? currentEstimatedTotal() {
    final price = currentPrice();

    if (price == null) {
      return null;
    }

    final quantity = currentQuantity();

    if (quantity == null) {
      return price;
    }

    return quantity * price;
  }

  void submit() {
    final name = nameController.text.trim();
    final quantityText = quantityController.text.trim();
    final unit = unitController.text.trim();
    final note = noteController.text.trim();
    final priceText = priceController.text.trim();

    setState(() => validationMessage = null);

    if (name.isEmpty) {
      setState(() => validationMessage = context.l10n.ingredientNameIsRequired);
      return;
    }

    final quantity = parseOptionalDouble(quantityText);

    if (quantityText.isNotEmpty && quantity == null) {
      setState(() => validationMessage = context.l10n.quantityMustBeANumber);
      return;
    }

    final estimatedUnitPrice = parseOptionalDouble(priceText);

    if (priceText.isNotEmpty && estimatedUnitPrice == null) {
      setState(() => validationMessage = 'Price must be a valid number.');
      return;
    }

    if (estimatedUnitPrice != null && estimatedUnitPrice < 0) {
      setState(() => validationMessage = 'Price cannot be negative.');
      return;
    }

    Navigator.of(context).pop(
      RecipeIngredientFormPageResult(
        name: name,
        quantity: quantity,
        unit: unit.isEmpty ? null : unit,
        note: note.isEmpty ? null : note,
        estimatedUnitPrice: estimatedUnitPrice,
        priceCurrency: priceCurrency,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final estimatedTotal = currentEstimatedTotal();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing ? context.l10n.editIngredient : context.l10n.addIngredient,
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
              icon: Icons.kitchen_outlined,
              title: context.l10n.ingredient,
              subtitle: isEditing
                  ? context.l10n.updateThisRecipeIngredient
                  : context.l10n.addOneIngredientForThisRecipe,
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
                    prefixIcon: const Icon(Icons.kitchen_outlined),
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
                        onChanged: (_) {
                          clearValidation();
                          setState(() {});
                        },
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
                        textInputAction: TextInputAction.next,
                        onChanged: (_) => clearValidation(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: priceController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Estimated unit price',
                    hintText: '0.50',
                    prefixIcon: const Icon(Icons.euro_outlined),
                    suffixText: priceCurrency,
                  ),
                  textInputAction: TextInputAction.next,
                  onChanged: (_) {
                    clearValidation();
                    setState(() {});
                  },
                ),
                if (estimatedTotal != null) ...[
                  const SizedBox(height: 12),
                  _EstimatedTotalCard(
                    total: estimatedTotal,
                    currency: priceCurrency,
                  ),
                ],
                const SizedBox(height: 16),
                TextField(
                  controller: noteController,
                  decoration: InputDecoration(
                    labelText: context.l10n.note,
                    hintText: context.l10n.optional,
                    prefixIcon: const Icon(Icons.notes_outlined),
                  ),
                  minLines: 3,
                  maxLines: 6,
                  textInputAction: TextInputAction.newline,
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

class _EstimatedTotalCard extends StatelessWidget {
  const _EstimatedTotalCard({required this.total, required this.currency});

  final double total;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.receipt_long_outlined,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Estimated ingredient total: ${total.toStringAsFixed(2)} $currency',
              style: TextStyle(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String? textOrNull(dynamic value) {
  final text = value?.toString().trim();

  if (text == null || text.isEmpty) {
    return null;
  }

  return text;
}
