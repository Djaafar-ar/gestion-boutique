import 'package:billing_app/core/widgets/input_label.dart';
import 'package:billing_app/core/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../bloc/product_bloc.dart';
import '../../domain/entities/product.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/utils/app_validators.dart';
import '../../../../core/utils/money.dart';
import '../../../../core/widgets/app_snack.dart';

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _formKey = GlobalKey<FormState>();
  final _barcodeController = TextEditingController();
  String _name = '';
  int _sellPrice = 0;

  @override
  void dispose() {
    _barcodeController.dispose();
    super.dispose();
  }

  void _scanBarcode() async {
    final result = await context.push<String>('/scanner');
    if (result != null && result.isNotEmpty) {
      _barcodeController.text = result;
    }
  }

  void _submit() {
    final l10n = AppLocalizations.of(context);
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final barcode = _barcodeController.text.trim();

      final productState = context.read<ProductBloc>().state;
      final existingProduct =
          productState.products.where((p) => p.barcode == barcode).firstOrNull;

      if (existingProduct != null) {
        showAppSnack(context, l10n.barcodeExists(barcode),
            kind: SnackKind.error);
        return;
      }

      final product = Product(
        id: const Uuid().v4(),
        name: _name.trim(),
        barcode: barcode,
        sellPrice: _sellPrice,
      );

      context.read<ProductBloc>().add(AddProduct(product));
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
        appBar: AppBar(title: Text(l10n.addProduct)),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InputLabel(text: l10n.barcodeLabel),
                  TextFormField(
                    controller: _barcodeController,
                    decoration: InputDecoration(
                      hintText: l10n.barcodeHint,
                      suffixIcon: IconButton(
                        icon:
                            Icon(Icons.qr_code_scanner, color: scheme.primary),
                        tooltip: l10n.scanBarcodeTitle,
                        onPressed: _scanBarcode,
                      ),
                    ),
                    validator: AppValidators.required(l10n.barcodeRequired),
                  ),
                  const SizedBox(height: 6),
                  Text(l10n.scanHelp,
                      style: TextStyle(
                          fontSize: 12, color: scheme.onSurfaceVariant)),
                  const SizedBox(height: 24),
                  InputLabel(text: l10n.productNameLabel),
                  TextFormField(
                    decoration: InputDecoration(hintText: l10n.productNameHint),
                    textCapitalization: TextCapitalization.sentences,
                    validator: AppValidators.required(l10n.productNameRequired),
                    onSaved: (value) => _name = value!,
                  ),
                  const SizedBox(height: 24),
                  InputLabel(text: l10n.sellPriceLabel),
                  TextFormField(
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      hintText: '0,00',
                      suffixText: 'DA',
                    ),
                    validator: AppValidators.price(l10n),
                    onSaved: (value) => _sellPrice = parseDA(value)!,
                  ),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: PrimaryButton(
          onPressed: _submit,
          icon: Icons.add_circle,
          label: l10n.addProduct,
        ));
  }
}
