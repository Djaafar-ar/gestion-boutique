import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/service_locator.dart';
import '../../../../core/utils/money.dart';
import '../../../../core/widgets/app_snack.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../product/presentation/bloc/product_bloc.dart';
import '../../domain/entities/sale.dart';
import '../../domain/repositories/sale_repository.dart';

/// A customer brings items back: how many of each, back on the shelf or
/// damaged, and how much money to give back.
class ReturnPage extends StatefulWidget {
  final String saleId;

  const ReturnPage({super.key, required this.saleId});

  @override
  State<ReturnPage> createState() => _ReturnPageState();
}

class _ReturnPageState extends State<ReturnPage> {
  late final Future<Sale> _sale = sl<SaleRepository>()
      .getSale(widget.saleId)
      .then((r) => r.getOrElse((f) => throw f.message));

  /// Per sale line: how many come back, and whether to the shelf.
  final Map<String, int> _quantities = {};
  final Map<String, bool> _toShelf = {};
  final _reason = TextEditingController();
  bool _saving = false;

  /// For a credit sale: take the refund off the customer's debt (default)
  /// instead of giving cash back.
  bool _toCredit = true;

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  int _refund(Sale sale) => sale.items.fold(
      0, (sum, line) => sum + sale.refundFor(line, _quantities[line.id] ?? 0));

  Future<void> _save(Sale sale) async {
    final l10n = AppLocalizations.of(context);
    final lines = [
      for (final line in sale.items)
        if ((_quantities[line.id] ?? 0) > 0)
          ReturnLine(
            saleItemId: line.id,
            quantity: _quantities[line.id]!,
            backToStock: _toShelf[line.id] ?? true,
          ),
    ];
    if (lines.isEmpty) {
      showAppSnack(context, l10n.returnNothing, kind: SnackKind.error);
      return;
    }
    setState(() => _saving = true);
    final toCredit = sale.isCredit && _toCredit;
    final result = await sl<SaleRepository>().createReturn(
        saleId: sale.id,
        lines: lines,
        reason: _reason.text,
        toCredit: toCredit);
    if (!mounted) return;
    setState(() => _saving = false);
    result.fold(
      (failure) => showAppSnack(context, l10n.errorWithDetail(failure.message),
          kind: SnackKind.error),
      (refund) {
        context.read<ProductBloc>().add(LoadProducts());
        showAppSnack(
            context,
            toCredit
                ? l10n.returnSavedCredit(formatDA(refund))
                : l10n.returnSaved(formatDA(refund)),
            kind: SnackKind.success);
        context.pop(true);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;

    return FutureBuilder<Sale>(
      future: _sale,
      builder: (context, snapshot) {
        final sale = snapshot.data;
        return Scaffold(
          appBar: AppBar(
              title: Text(sale == null ? '' : l10n.returnTitle(sale.number))),
          body: snapshot.hasError
              ? EmptyState(
                  icon: Icons.error_outline,
                  title: l10n.errorWithDetail('${snapshot.error}'))
              : sale == null
                  ? const Center(child: CircularProgressIndicator())
                  : ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        Text(l10n.returnIntro,
                            style: TextStyle(color: scheme.onSurfaceVariant)),
                        const SizedBox(height: 12),
                        for (final line
                            in sale.items.where((l) => l.returnable > 0))
                          _LineCard(
                            line: line,
                            quantity: _quantities[line.id] ?? 0,
                            toShelf: _toShelf[line.id] ?? true,
                            onQuantity: (q) =>
                                setState(() => _quantities[line.id] = q),
                            onShelf: (v) =>
                                setState(() => _toShelf[line.id] = v),
                          ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _reason,
                          decoration: InputDecoration(
                              labelText: l10n.returnReasonLabel),
                        ),
                        if (sale.isCredit) ...[
                          const SizedBox(height: 16),
                          Text(l10n.refundModeLabel,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          SegmentedButton<bool>(
                            showSelectedIcon: false,
                            segments: [
                              ButtonSegment(
                                  value: true,
                                  icon: const Icon(Icons.menu_book_outlined,
                                      size: 18),
                                  label: Text(l10n.refundToCredit)),
                              ButtonSegment(
                                  value: false,
                                  icon: const Icon(Icons.payments_outlined,
                                      size: 18),
                                  label: Text(l10n.refundCash)),
                            ],
                            selected: {_toCredit},
                            onSelectionChanged: (s) =>
                                setState(() => _toCredit = s.first),
                          ),
                        ],
                        const SizedBox(height: 16),
                        Card(
                          color: scheme.primaryContainer,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              sale.isCredit && _toCredit
                                  ? l10n.refundToAccount(
                                      sale.customerName ?? '',
                                      formatDAForUi(_refund(sale)))
                                  : l10n.refundToGive(
                                      formatDAForUi(_refund(sale))),
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: scheme.onPrimaryContainer),
                            ),
                          ),
                        ),
                      ],
                    ),
          bottomNavigationBar: sale == null
              ? null
              : PrimaryButton(
                  onPressed: () => _save(sale),
                  isLoading: _saving,
                  icon: Icons.assignment_return_outlined,
                  label: l10n.confirmReturn,
                ),
        );
      },
    );
  }
}

class _LineCard extends StatelessWidget {
  final SaleLine line;
  final int quantity;
  final bool toShelf;
  final ValueChanged<int> onQuantity;
  final ValueChanged<bool> onShelf;

  const _LineCard({
    required this.line,
    required this.quantity,
    required this.toShelf,
    required this.onQuantity,
    required this.onShelf,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(line.productName,
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                      Text(
                          '${line.returnable} × ${formatDAForUi(line.sellPrice)}'
                          '${line.returned > 0 ? ' · ${l10n.returnedQty(line.returned)}' : ''}',
                          style: TextStyle(
                              fontSize: 12, color: scheme.onSurfaceVariant)),
                    ],
                  ),
                ),
                IconButton(
                  onPressed:
                      quantity > 0 ? () => onQuantity(quantity - 1) : null,
                  icon: const Icon(Icons.remove_circle_outline),
                ),
                Text('$quantity',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                IconButton(
                  onPressed: quantity < line.returnable
                      ? () => onQuantity(quantity + 1)
                      : null,
                  icon: const Icon(Icons.add_circle_outline),
                ),
              ],
            ),
            if (quantity > 0)
              SegmentedButton<bool>(
                showSelectedIcon: false,
                segments: [
                  ButtonSegment(
                      value: true,
                      icon: const Icon(Icons.shelves, size: 18),
                      label: Text(l10n.backOnShelf)),
                  ButtonSegment(
                      value: false,
                      icon: const Icon(Icons.broken_image_outlined, size: 18),
                      label: Text(l10n.reasonDamaged)),
                ],
                selected: {toShelf},
                onSelectionChanged: (s) => onShelf(s.first),
              ),
          ],
        ),
      ),
    );
  }
}
