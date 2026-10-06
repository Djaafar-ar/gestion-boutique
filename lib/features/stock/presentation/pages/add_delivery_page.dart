import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/service_locator.dart';
import '../../../../core/utils/app_validators.dart';
import '../../../../core/utils/date_format.dart';
import '../../../../core/utils/money.dart';
import '../../../../core/widgets/app_snack.dart';
import '../../../../core/widgets/input_label.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../product/domain/entities/product.dart';
import '../../../product/presentation/bloc/product_bloc.dart';
import '../../../suppliers/domain/entities/supplier.dart';
import '../../../suppliers/presentation/widgets/supplier_picker.dart';
import '../../domain/repositories/stock_repository.dart';
import '../widgets/product_picker.dart';

/// "Réception de stock": quantity, buying price, expiry date and supplier
/// of a delivery. Who received it is saved automatically.
class AddDeliveryPage extends StatefulWidget {
  /// Product already chosen (from its page), or null to pick one.
  final String? productId;

  const AddDeliveryPage({super.key, this.productId});

  @override
  State<AddDeliveryPage> createState() => _AddDeliveryPageState();
}

class _AddDeliveryPageState extends State<AddDeliveryPage> {
  final _formKey = GlobalKey<FormState>();
  final _quantity = TextEditingController();
  final _buyPrice = TextEditingController();
  final _note = TextEditingController();
  Product? _product;
  Supplier? _supplier;
  DateTime? _expiry;
  bool _updateBuyPrice = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final id = widget.productId;
    if (id != null) {
      _choose(context
          .read<ProductBloc>()
          .state
          .products
          .where((p) => p.id == id)
          .firstOrNull);
    }
  }

  @override
  void dispose() {
    _quantity.dispose();
    _buyPrice.dispose();
    _note.dispose();
    super.dispose();
  }

  void _choose(Product? product) {
    if (product == null) return;
    setState(() {
      _product = product;
      // The usual buying price is filled in; change it if it went up.
      _buyPrice.text =
          product.buyPrice == 0 ? '' : centimesToInput(product.buyPrice);
    });
  }

  Future<void> _pickExpiry() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _expiry ?? now.add(const Duration(days: 30)),
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 3650)),
    );
    if (picked != null) setState(() => _expiry = picked);
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    final product = _product;
    if (product == null) {
      showAppSnack(context, l10n.chooseProduct, kind: SnackKind.error);
      return;
    }
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final quantity = int.parse(_quantity.text);
    final buyPrice = parseDA(_buyPrice.text) ?? 0;
    final result = await sl<StockRepository>().addDelivery(
      productId: product.id,
      quantity: quantity,
      buyPrice: buyPrice,
      expiryDate: _expiry,
      note: _note.text,
      supplierId: _supplier?.id,
      updateProductBuyPrice: _updateBuyPrice && buyPrice > 0,
    );
    if (!mounted) return;
    setState(() => _saving = false);
    result.fold(
      (failure) => showAppSnack(context, l10n.errorWithDetail(failure.message),
          kind: SnackKind.error),
      (_) {
        context.read<ProductBloc>().add(LoadProducts());
        showAppSnack(context, l10n.deliverySaved(quantity, product.name),
            kind: SnackKind.success);
        context.pop(true);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final product = _product;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.addDelivery)),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            InputLabel(text: l10n.columnProduct),
            Card(
              child: ListTile(
                leading:
                    Icon(Icons.inventory_2_outlined, color: scheme.primary),
                title: Text(product?.name ?? l10n.chooseProduct,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: product == null ? null : Text(product.barcode),
                trailing: const Icon(Icons.search),
                onTap: () async => _choose(await pickProduct(context)),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InputLabel(text: l10n.quantityLabel),
                      TextFormField(
                        controller: _quantity,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        decoration: const InputDecoration(hintText: '0'),
                        validator: (value) =>
                            (int.tryParse(value ?? '') ?? 0) < 1
                                ? l10n.quantityRequired
                                : null,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InputLabel(text: l10n.buyPriceUnitLabel),
                      TextFormField(
                        controller: _buyPrice,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        onChanged: (_) => setState(() {}),
                        decoration: const InputDecoration(
                            hintText: '0,00', suffixText: 'DA'),
                        validator: (value) => (value ?? '').trim().isEmpty
                            ? null
                            : AppValidators.price(l10n)(value),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (product != null &&
                parseDA(_buyPrice.text) != product.buyPrice) ...[
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: _updateBuyPrice,
                title: Text(l10n.updateBuyPrice),
                onChanged: (value) =>
                    setState(() => _updateBuyPrice = value ?? false),
              ),
            ],
            const SizedBox(height: 12),
            InputLabel(text: l10n.expiryLabel),
            Card(
              child: ListTile(
                leading: Icon(Icons.event, color: scheme.primary),
                title: Text(
                    _expiry == null ? l10n.pickDate : formatDate(_expiry!)),
                subtitle: Text(l10n.noExpiryHelp),
                trailing: _expiry == null
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => setState(() => _expiry = null),
                      ),
                onTap: _pickExpiry,
              ),
            ),
            const SizedBox(height: 20),
            InputLabel(text: l10n.supplierOptional),
            Card(
              child: ListTile(
                leading:
                    Icon(Icons.local_shipping_outlined, color: scheme.primary),
                title: Text(_supplier?.name ?? l10n.noSupplier),
                trailing: _supplier == null
                    ? const Icon(Icons.search)
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => setState(() => _supplier = null),
                      ),
                onTap: () async {
                  final picked = await pickSupplier(context);
                  if (picked != null && mounted) {
                    setState(() => _supplier = picked);
                  }
                },
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _note,
              decoration: InputDecoration(labelText: l10n.noteOptional),
            ),
          ],
        ),
      ),
      bottomNavigationBar: PrimaryButton(
        onPressed: _save,
        isLoading: _saving,
        icon: Icons.add_box_outlined,
        label: l10n.saveDelivery,
      ),
    );
  }
}
