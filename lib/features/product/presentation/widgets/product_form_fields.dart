import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/service_locator.dart';
import '../../../../core/utils/app_validators.dart';
import '../../../../core/utils/money.dart';
import '../../../../core/widgets/input_label.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';

/// What the person typed, filled in when the form is saved.
class ProductFormValues {
  String name = '';
  int sellPrice = 0;
  int buyPrice = 0;
  String? categoryId;
  int lowStockThreshold = 0;
}

/// The fields shared by "Add product" and "Edit product". Put it inside a
/// [Form]; the values land in [values] when the form is saved.
class ProductFormFields extends StatefulWidget {
  final Product? initial;
  final ProductFormValues values;

  const ProductFormFields({super.key, this.initial, required this.values});

  @override
  State<ProductFormFields> createState() => _ProductFormFieldsState();
}

class _ProductFormFieldsState extends State<ProductFormFields> {
  static const _newCategory = '__new__';

  List<Category> _categories = [];
  late String? _categoryId = widget.initial?.categoryId;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final result = await sl<ProductRepository>().getCategories();
    if (mounted) setState(() => _categories = result.getOrElse((_) => []));
  }

  Future<void> _createCategory() async {
    final l10n = AppLocalizations.of(context);
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.categoryLabel),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(hintText: l10n.categoryNameHint),
          onSubmitted: (value) => Navigator.pop(dialogContext, value),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(l10n.commonCancel)),
          FilledButton(
              style: FilledButton.styleFrom(minimumSize: const Size(88, 40)),
              onPressed: () => Navigator.pop(dialogContext, controller.text),
              child: Text(l10n.commonAdd)),
        ],
      ),
    );
    controller.dispose();
    if (name == null || name.trim().isEmpty) return;

    final result = await sl<ProductRepository>().addCategory(name);
    final category = result.toNullable();
    if (category == null || !mounted) return;
    await _loadCategories();
    setState(() => _categoryId = category.id);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final initial = widget.initial;
    final values = widget.values;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InputLabel(text: l10n.productNameLabel),
        TextFormField(
          initialValue: initial?.name,
          decoration: InputDecoration(hintText: l10n.productNameHint),
          textCapitalization: TextCapitalization.sentences,
          validator: AppValidators.required(l10n.productNameRequired),
          onSaved: (value) => values.name = value!.trim(),
        ),
        const SizedBox(height: 20),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InputLabel(text: l10n.sellPriceLabel),
                  TextFormField(
                    initialValue: initial == null
                        ? null
                        : centimesToInput(initial.sellPrice),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                        hintText: '0,00', suffixText: 'DA'),
                    validator: AppValidators.price(l10n),
                    onSaved: (value) => values.sellPrice = parseDA(value)!,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InputLabel(text: l10n.buyPriceLabel),
                  TextFormField(
                    initialValue: initial == null || initial.buyPrice == 0
                        ? null
                        : centimesToInput(initial.buyPrice),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                        hintText: '0,00', suffixText: 'DA'),
                    // Empty is fine: the buying price is optional.
                    validator: (value) => (value ?? '').trim().isEmpty
                        ? null
                        : AppValidators.price(l10n)(value),
                    onSaved: (value) => values.buyPrice = parseDA(value) ?? 0,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        InputLabel(text: l10n.categoryLabel),
        DropdownButtonFormField<String?>(
          // A new key rebuilds the field after a category is created.
          key: ValueKey('category-$_categoryId-${_categories.length}'),
          initialValue: _categoryId,
          isExpanded: true,
          items: [
            DropdownMenuItem(value: null, child: Text(l10n.noCategory)),
            for (final category in _categories)
              DropdownMenuItem(value: category.id, child: Text(category.name)),
            DropdownMenuItem(
              value: _newCategory,
              child: Text(l10n.newCategory,
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.primary)),
            ),
          ],
          onChanged: (value) {
            if (value == _newCategory) {
              _createCategory();
            } else {
              setState(() => _categoryId = value);
            }
          },
          onSaved: (_) => values.categoryId = _categoryId,
        ),
        const SizedBox(height: 20),
        InputLabel(text: l10n.lowStockLabel),
        TextFormField(
          initialValue: '${initial?.lowStockThreshold ?? 0}',
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(helperText: l10n.lowStockHelp),
          validator: (value) =>
              int.tryParse(value ?? '') == null ? l10n.quantityInvalid : null,
          onSaved: (value) => values.lowStockThreshold = int.parse(value!),
        ),
      ],
    );
  }
}
