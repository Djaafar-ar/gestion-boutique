import 'package:flutter/material.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/service_locator.dart';
import '../../../../core/utils/date_format.dart';
import '../../../../core/utils/money.dart';
import '../../domain/entities/product_change.dart';
import '../../domain/repositories/product_repository.dart';

/// "Who changed what, when" for one product, newest first.
class ProductHistory extends StatefulWidget {
  final String productId;

  const ProductHistory({super.key, required this.productId});

  @override
  State<ProductHistory> createState() => _ProductHistoryState();
}

class _ProductHistoryState extends State<ProductHistory> {
  late final Future<List<ProductChange>> _changes = sl<ProductRepository>()
      .getHistory(widget.productId)
      .then((result) => result.getOrElse((_) => []));

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    // "old -> new" reads the other way round in Arabic.
    final arrow = Directionality.of(context) == TextDirection.rtl ? '←' : '→';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.historySection,
            style:
                TextStyle(fontWeight: FontWeight.bold, color: scheme.primary)),
        const SizedBox(height: 8),
        FutureBuilder<List<ProductChange>>(
          future: _changes,
          builder: (context, snapshot) {
            final changes = snapshot.data;
            if (changes == null) {
              return const Center(child: CircularProgressIndicator());
            }
            if (changes.isEmpty) {
              return Text(l10n.historyNoChanges,
                  style: TextStyle(color: scheme.onSurfaceVariant));
            }
            return Card(
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  for (final (index, change) in changes.indexed) ...[
                    if (index > 0) const Divider(),
                    ListTile(
                      dense: true,
                      title: Text(
                          '${_fieldLabel(l10n, change.field)} : '
                          '${_value(l10n, change.field, change.oldValue)} $arrow '
                          '${_value(l10n, change.field, change.newValue)}',
                          style: const TextStyle(fontWeight: FontWeight.w500)),
                      subtitle: Text('${change.userName ?? l10n.unknownUser} · '
                          '${formatDateTime(change.at)}'),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  String _fieldLabel(AppLocalizations l10n, ProductField field) =>
      switch (field) {
        ProductField.name => l10n.nameLabel,
        ProductField.barcode => l10n.barcodeLabel,
        ProductField.sellPrice => l10n.sellPriceLabel,
        ProductField.buyPrice => l10n.fieldBuyPrice,
        ProductField.category => l10n.categoryLabel,
        ProductField.lowStockThreshold => l10n.fieldLowStock,
        ProductField.archived => l10n.fieldArchived,
      };

  String _value(AppLocalizations l10n, ProductField field, String? raw) {
    if (field == ProductField.category && raw == null) return l10n.noCategory;
    if (raw == null) return '—';
    if (field.isMoney) {
      final centimes = int.tryParse(raw);
      return centimes == null ? raw : formatDAForUi(centimes);
    }
    if (field == ProductField.archived) {
      return raw == 'true' ? l10n.commonYes : l10n.commonNo;
    }
    return raw;
  }
}
