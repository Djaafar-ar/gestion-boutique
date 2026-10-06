import 'package:billing_app/core/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../bloc/product_bloc.dart';
import '../widgets/product_form_fields.dart';
import '../widgets/product_history.dart';
import '../../domain/entities/product.dart';
import '../../../../core/l10n/app_localizations.dart';

class EditProductPage extends StatefulWidget {
  final Product product;
  const EditProductPage({super.key, required this.product});

  @override
  State<EditProductPage> createState() => _EditProductPageState();
}

class _EditProductPageState extends State<EditProductPage> {
  final _formKey = GlobalKey<FormState>();
  final _values = ProductFormValues();

  void _submit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // copyWith keeps the fields this screen does not show.
      final updatedProduct = widget.product.copyWith(
        name: _values.name,
        sellPrice: _values.sellPrice,
        buyPrice: _values.buyPrice,
        categoryId: _values.categoryId,
        clearCategory: _values.categoryId == null,
        lowStockThreshold: _values.lowStockThreshold,
      );

      context.read<ProductBloc>().add(UpdateProduct(updatedProduct));
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
        appBar: AppBar(title: Text(l10n.editProduct)),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // The barcode cannot be changed.
                  Card(
                    margin: const EdgeInsets.only(bottom: 20),
                    child: ListTile(
                      leading: Icon(Icons.qr_code_2,
                          color: scheme.primary, size: 28),
                      title: Text(l10n.barcodeLabel,
                          style: TextStyle(
                              fontSize: 12, color: scheme.onSurfaceVariant)),
                      subtitle: Text(widget.product.barcode,
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: scheme.onSurface)),
                    ),
                  ),
                  ProductFormFields(initial: widget.product, values: _values),
                  const SizedBox(height: 28),
                  ProductHistory(productId: widget.product.id),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: PrimaryButton(
          onPressed: _submit,
          icon: Icons.save,
          label: l10n.saveChanges,
        ));
  }
}
