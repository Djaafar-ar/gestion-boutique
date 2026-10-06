import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/utils/money.dart';
import '../../../../core/widgets/app_snack.dart';
import '../../../shop/domain/entities/shop.dart';
import '../../../shop/presentation/bloc/shop_bloc.dart';
import '../../../../core/service_locator.dart';
import '../../../product/presentation/bloc/product_bloc.dart';
import '../../data/receipt_printer.dart';
import '../../domain/entities/cart_item.dart';
import '../../domain/entities/sale.dart';
import '../../domain/repositories/sale_repository.dart';
import '../bloc/billing_bloc.dart';

class CheckoutPage extends StatelessWidget {
  const CheckoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    // Going back keeps the cart, so the cashier can add more items.
    return Scaffold(
      appBar: AppBar(title: Text(l10n.checkoutTitle)),
      body: BlocConsumer<BillingBloc, BillingState>(
        listenWhen: (previous, current) =>
            current.completedSale != previous.completedSale ||
            (current.error != null &&
                current.error != BillingError.productNotFound &&
                previous.error != current.error),
        listener: (context, state) => _onResult(context, l10n, state),
        builder: (context, billingState) {
          final scheme = Theme.of(context).colorScheme;
          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Card(
                      clipBehavior: Clip.antiAlias,
                      child: Table(
                        columnWidths: const {
                          0: FlexColumnWidth(),
                          1: IntrinsicColumnWidth(),
                          2: IntrinsicColumnWidth(),
                        },
                        border: TableBorder(
                          horizontalInside:
                              BorderSide(color: scheme.outlineVariant),
                        ),
                        children: [
                          TableRow(
                            decoration: BoxDecoration(
                                color: scheme.surfaceContainerHighest),
                            children: [
                              _headerCell(context, l10n.columnProduct),
                              _headerCell(context, l10n.columnPrice, end: true),
                              _headerCell(context, l10n.columnTotal, end: true),
                            ],
                          ),
                          ...billingState.cartItems.map((item) {
                            return TableRow(
                              children: [
                                _dataCell(context,
                                    '${item.quantity} × ${item.product.name}'),
                                _dataCell(context,
                                    formatDAForUi(item.product.sellPrice),
                                    end: true, subtle: true),
                                _dataCell(context, formatDAForUi(item.total),
                                    end: true, bold: true),
                              ],
                            );
                          }),
                        ],
                      ),
                    ),
                    _StockWarning(items: billingState.cartItems),
                  ],
                ),
              ),

              // Bottom bar: total and the two ways to confirm.
              Material(
                color: scheme.surfaceContainer,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (billingState.discountAmount > 0) ...[
                          _AmountRow(
                              label: l10n.subtotalLabel,
                              amount: billingState.subtotal),
                          _AmountRow(
                              label: l10n.discountLabel,
                              amount: -billingState.discountAmount),
                        ],
                        Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: TextButton.icon(
                            onPressed: billingState.isProcessing
                                ? null
                                : () => _editDiscount(context, billingState),
                            icon: const Icon(Icons.sell_outlined, size: 18),
                            label: Text(billingState.discount == null
                                ? l10n.addDiscount
                                : l10n.discountLabel),
                          ),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                l10n.amountToPay,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: scheme.onSurfaceVariant,
                                  letterSpacing: 1.1,
                                ),
                              ),
                            ),
                            Text(
                              formatDAForUi(billingState.totalAmount),
                              style: const TextStyle(
                                  fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          onPressed: billingState.isProcessing
                              ? null
                              : () => _checkout(context, print: true),
                          icon: billingState.isProcessing
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2))
                              : const Icon(Icons.print),
                          label: Text(l10n.confirmAndPrint),
                        ),
                        const SizedBox(height: 10),
                        OutlinedButton.icon(
                          onPressed: billingState.isProcessing
                              ? null
                              : () => _checkout(context, print: false),
                          icon: const Icon(Icons.check),
                          label: Text(l10n.confirmWithoutPrint),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _editDiscount(BuildContext context, BillingState state) async {
    final maxPercent = await sl<SaleRepository>().maxDiscountPercent();
    if (!context.mounted) return;
    final result = await showDialog<_DiscountChoice>(
      context: context,
      builder: (_) => _DiscountDialog(
          initial: state.discount,
          subtotal: state.subtotal,
          maxPercent: maxPercent),
    );
    if (result != null && context.mounted) {
      context.read<BillingBloc>().add(SetDiscountEvent(result.discount));
    }
  }

  void _checkout(BuildContext context, {required bool print}) {
    final shopState = context.read<ShopBloc>().state;
    final shop = shopState is ShopLoaded ? shopState.shop : const Shop();
    context.read<BillingBloc>().add(CheckoutEvent(print: print, shop: shop));
  }

  void _onResult(
      BuildContext context, AppLocalizations l10n, BillingState state) {
    if (state.error == BillingError.saveFailed) {
      showAppSnack(context, l10n.saleSaveFailed, kind: SnackKind.error);
      return;
    }
    if (state.error == BillingError.discountTooHigh) {
      showAppSnack(
          context, l10n.discountTooHigh(int.parse(state.errorDetail ?? '0')),
          kind: SnackKind.error);
      return;
    }
    final sale = state.completedSale;
    if (sale == null) return;
    // The stock went down: refresh the numbers everywhere.
    context.read<ProductBloc>().add(LoadProducts());

    switch (state.printOutcome) {
      case null:
        showAppSnack(context, l10n.saleSaved(sale.number),
            kind: SnackKind.success);
      case PrintOutcome.printed:
        showAppSnack(context, l10n.saleSavedAndPrinted(sale.number),
            kind: SnackKind.success);
      case PrintOutcome.noSavedPrinter:
        _printProblem(context, l10n, sale.number, l10n.printNoPrinter);
      case PrintOutcome.connectFailed:
        _printProblem(context, l10n, sale.number, l10n.printConnectFailed);
      case PrintOutcome.failed:
        _printProblem(context, l10n, sale.number, l10n.printFailed);
    }
    context.pop();
  }

  void _printProblem(
      BuildContext context, AppLocalizations l10n, int number, String problem) {
    showAppSnack(
        context, '${l10n.saleSaved(number)}. $problem ${l10n.printReprintHint}',
        kind: SnackKind.error);
  }

  Widget _headerCell(BuildContext context, String text, {bool end = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Text(
        text.toUpperCase(),
        textAlign: end ? TextAlign.end : TextAlign.start,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.8,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _dataCell(BuildContext context, String text,
      {bool end = false, bool bold = false, bool subtle = false}) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      child: Text(
        text,
        textAlign: end ? TextAlign.end : TextAlign.start,
        style: TextStyle(
          fontSize: subtle ? 12 : 14,
          fontWeight: bold ? FontWeight.bold : FontWeight.w500,
          color: subtle ? scheme.onSurfaceVariant : scheme.onSurface,
        ),
      ),
    );
  }
}

class _AmountRow extends StatelessWidget {
  final String label;
  final int amount;

  const _AmountRow({required this.label, required this.amount});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(formatDAForUi(amount),
              style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

/// Lines selling more than what is in stock. The sale is still allowed.
class _StockWarning extends StatelessWidget {
  final List<CartItem> items;

  const _StockWarning({required this.items});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final stock = context.watch<ProductBloc>().state;
    final short = items
        .where((i) => i.quantity > stock.stockOf(i.product.id).quantity)
        .toList();
    if (short.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Card(
        color: scheme.errorContainer,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.warning_amber_rounded,
                      color: scheme.onErrorContainer),
                  const SizedBox(width: 8),
                  Text(l10n.stockWarningTitle,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: scheme.onErrorContainer)),
                ],
              ),
              const SizedBox(height: 6),
              for (final item in short)
                Text(
                    '${item.product.name} : ${l10n.stockLabel(stock.stockOf(item.product.id).quantity)}',
                    style: TextStyle(color: scheme.onErrorContainer)),
              const SizedBox(height: 4),
              Text(l10n.stockWarningBody,
                  style:
                      TextStyle(fontSize: 12, color: scheme.onErrorContainer)),
            ],
          ),
        ),
      ),
    );
  }
}

/// What the discount dialog returns: a discount, or null to remove it.
class _DiscountChoice {
  final Discount? discount;
  const _DiscountChoice(this.discount);
}

/// Amount or percentage for the whole ticket. A worker cannot go over
/// the owner's limit ([maxPercent]).
class _DiscountDialog extends StatefulWidget {
  final Discount? initial;
  final int subtotal;
  final int? maxPercent;

  const _DiscountDialog(
      {required this.initial,
      required this.subtotal,
      required this.maxPercent});

  @override
  State<_DiscountDialog> createState() => _DiscountDialogState();
}

class _DiscountDialogState extends State<_DiscountDialog> {
  late bool _percent = widget.initial?.isPercent ?? true;
  late final _value = TextEditingController(
      text: widget.initial == null
          ? ''
          : widget.initial!.isPercent
              ? '${widget.initial!.value}'
              : centimesToInput(widget.initial!.value));
  String? _error;

  @override
  void dispose() {
    _value.dispose();
    super.dispose();
  }

  Discount? _parse() {
    final text = _value.text.trim();
    if (_percent) {
      final value = int.tryParse(text);
      if (value == null || value < 0 || value > 100) return null;
      return Discount.percent(value);
    }
    final value = parseDA(text);
    if (value == null || value < 0) return null;
    return Discount.amount(value);
  }

  void _apply() {
    final l10n = AppLocalizations.of(context);
    final discount = _parse();
    if (discount == null) {
      setState(() => _error = l10n.discountInvalid);
      return;
    }
    final max = widget.maxPercent;
    if (max != null &&
        discount.centimesOf(widget.subtotal) * 100 > widget.subtotal * max) {
      setState(() => _error = l10n.discountTooHigh(max));
      return;
    }
    Navigator.pop(context, _DiscountChoice(discount));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final discount = _parse();
    final amount = discount?.centimesOf(widget.subtotal) ?? 0;
    return AlertDialog(
      title: Text(l10n.discountLabel),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SegmentedButton<bool>(
            showSelectedIcon: false,
            segments: [
              ButtonSegment(value: true, label: Text(l10n.discountPercent)),
              ButtonSegment(value: false, label: Text(l10n.discountAmount)),
            ],
            selected: {_percent},
            onSelectionChanged: (s) => setState(() {
              _percent = s.first;
              _value.clear();
              _error = null;
            }),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _value,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              suffixText: _percent ? '%' : 'DA',
              errorText: _error,
              errorMaxLines: 2,
            ),
            onChanged: (_) => setState(() => _error = null),
          ),
          const SizedBox(height: 12),
          Text('${l10n.discountLabel} : ${formatDAForUi(amount)}',
              style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
      actions: [
        if (widget.initial != null)
          TextButton(
            onPressed: () =>
                Navigator.pop(context, const _DiscountChoice(null)),
            child: Text(l10n.removeDiscount),
          ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.commonCancel),
        ),
        FilledButton(
          style: FilledButton.styleFrom(minimumSize: const Size(88, 40)),
          onPressed: _apply,
          child: Text(l10n.applyLabel),
        ),
      ],
    );
  }
}
