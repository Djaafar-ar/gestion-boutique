import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/utils/money.dart';
import '../../../../core/widgets/app_snack.dart';
import '../../../shop/domain/entities/shop.dart';
import '../../../shop/presentation/bloc/shop_bloc.dart';
import '../../data/receipt_printer.dart';
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
            (current.error == BillingError.saveFailed &&
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
    final sale = state.completedSale;
    if (sale == null) return;

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
