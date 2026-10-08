import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/scanner/scan_listener.dart';
import '../../../product/domain/entities/product.dart';
import '../../../product/presentation/bloc/product_bloc.dart';
import 'stock_badges.dart';

/// A sheet to pick a product by name, barcode or camera scan.
Future<Product?> pickProduct(BuildContext context) {
  return showModalBottomSheet<Product>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => const _ProductPickerSheet(),
  );
}

class _ProductPickerSheet extends StatefulWidget {
  const _ProductPickerSheet();

  @override
  State<_ProductPickerSheet> createState() => _ProductPickerSheetState();
}

class _ProductPickerSheetState extends State<_ProductPickerSheet> {
  final _search = TextEditingController();
  String get _query => _search.text;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _scan(List<Product> products) async {
    final barcode = await context.push<String>('/scanner');
    if (barcode == null || !mounted) return;
    final match = products.where((p) => p.barcode == barcode).firstOrNull;
    if (match != null) {
      Navigator.pop(context, match);
    } else {
      setState(() => _search.text = barcode);
    }
  }

  /// A barcode from the Bluetooth scanner, or typed then Enter.
  bool _useBarcode(String code) {
    final match = productByBarcode(context, code.trim());
    if (match != null) {
      Navigator.pop(context, match);
      return true;
    }
    setState(() => _search.text = code.trim());
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = context.watch<ProductBloc>().state;
    final query = _query.toLowerCase();
    final products = state.products
        .where((p) =>
            p.name.toLowerCase().contains(query) || p.barcode.contains(query))
        .toList();

    return ScanListener(
      onScan: _useBarcode,
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.8,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: TextField(
                autofocus: true,
                controller: _search,
                decoration: InputDecoration(
                  hintText: l10n.productSearchHint,
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.qr_code_scanner),
                    tooltip: l10n.scanBarcodeTitle,
                    onPressed: () => _scan(state.products),
                  ),
                ),
                onChanged: (_) => setState(() {}),
                // A keyboard scanner types the barcode here, then Enter.
                onSubmitted: _useBarcode,
              ),
            ),
            Expanded(
              child: products.isEmpty
                  ? Center(child: Text(l10n.productsNoMatch))
                  : ListView.builder(
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = products[index];
                        return ListTile(
                          title: Text(product.name),
                          subtitle: Text(product.barcode),
                          trailing: StockBadge(
                            quantity: state.stockOf(product.id).quantity,
                            lowThreshold: product.lowStockThreshold,
                          ),
                          onTap: () => Navigator.pop(context, product),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
