import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/service_locator.dart';
import '../../../../core/utils/date_format.dart';
import '../../../../core/utils/money.dart';
import '../../../../core/widgets/app_snack.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../shop/domain/entities/shop.dart';
import '../../../shop/presentation/bloc/shop_bloc.dart';
import '../../data/receipt_printer.dart';
import '../../domain/entities/sale.dart';
import '../../domain/repositories/sale_repository.dart';

/// One saved sale with its lines, and a button to print it again.
class SaleDetailPage extends StatefulWidget {
  final String saleId;

  const SaleDetailPage({super.key, required this.saleId});

  @override
  State<SaleDetailPage> createState() => _SaleDetailPageState();
}

class _SaleDetailPageState extends State<SaleDetailPage> {
  late Future<Sale> _sale = _load();
  bool _printing = false;

  Future<Sale> _load() async {
    final result = await sl<SaleRepository>().getSale(widget.saleId);
    return result.fold((failure) => throw failure.message, (sale) => sale);
  }

  Future<void> _openReturn(Sale sale) async {
    final done = await context.push<bool>('/sell/history/${sale.id}/return');
    if (done == true && mounted) {
      setState(() {
        _sale = _load();
      });
    }
  }

  Future<void> _reprint(Sale sale) async {
    final l10n = AppLocalizations.of(context);
    final shopState = context.read<ShopBloc>().state;
    final shop = shopState is ShopLoaded ? shopState.shop : const Shop();

    setState(() => _printing = true);
    final customerId = sale.customerId;
    final debt = customerId == null
        ? null
        : await sl<SaleRepository>().customerDebt(customerId);
    final result =
        await sl<ReceiptPrinter>().printSale(sale, shop, customerDebt: debt);
    if (!mounted) return;
    setState(() => _printing = false);

    switch (result.outcome) {
      case PrintOutcome.printed:
        showAppSnack(context, l10n.receiptPrinted, kind: SnackKind.success);
      case PrintOutcome.noSavedPrinter:
        showAppSnack(context, l10n.printNoPrinter, kind: SnackKind.error);
      case PrintOutcome.connectFailed:
        showAppSnack(context, l10n.printConnectFailed, kind: SnackKind.error);
      case PrintOutcome.failed:
        showAppSnack(context, l10n.printFailed, kind: SnackKind.error);
    }
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
              title: Text(sale == null ? '' : l10n.saleTitle(sale.number))),
          body: snapshot.hasError
              ? EmptyState(
                  icon: Icons.error_outline,
                  title: l10n.errorWithDetail('${snapshot.error}'))
              : sale == null
                  ? const Center(child: CircularProgressIndicator())
                  : ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        Text(
                            [
                              formatDateTime(sale.createdAt),
                              if (sale.sellerName != null)
                                l10n.soldBy(sale.sellerName!),
                            ].join(' · '),
                            style: TextStyle(color: scheme.onSurfaceVariant)),
                        const SizedBox(height: 12),
                        Card(
                          child: Column(
                            children: [
                              for (final (index, line)
                                  in sale.items.indexed) ...[
                                if (index > 0) const Divider(),
                                ListTile(
                                  title: Text(line.productName),
                                  subtitle: Text([
                                    '${line.quantity} × ${formatDAForUi(line.sellPrice)}',
                                    if (line.returned > 0)
                                      l10n.returnedQty(line.returned),
                                  ].join(' · ')),
                                  trailing: Text(formatDAForUi(line.total),
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600)),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (sale.discount > 0) ...[
                          _AmountRow(
                              label: l10n.subtotalLabel, amount: sale.subtotal),
                          _AmountRow(
                              label: l10n.discountLabel,
                              amount: -sale.discount),
                        ],
                        Row(
                          children: [
                            Expanded(
                              child: Text(l10n.totalLabel,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                            ),
                            Text(formatDAForUi(sale.total),
                                style: const TextStyle(
                                    fontSize: 22, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        if (sale.refunded > 0)
                          _AmountRow(
                              label: l10n.refundedLabel,
                              amount: -sale.refunded,
                              color: scheme.error),
                        if (sale.isCredit) ...[
                          const SizedBox(height: 12),
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.menu_book_outlined,
                                          color: scheme.primary),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                            '${l10n.customerLabel} : ${sale.customerName ?? '?'}',
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w600)),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  _AmountRow(
                                      label: l10n.paidLabel,
                                      amount: sale.paidNow),
                                  _AmountRow(
                                      label: l10n.onCreditLabel,
                                      amount: sale.onCredit,
                                      color: scheme.error),
                                ],
                              ),
                            ),
                          ),
                        ],
                        if (sale.hasReturnableItems) ...[
                          const SizedBox(height: 20),
                          OutlinedButton.icon(
                            onPressed: () => _openReturn(sale),
                            icon: const Icon(Icons.assignment_return_outlined),
                            label: Text(l10n.returnButton),
                          ),
                        ],
                      ],
                    ),
          bottomNavigationBar: sale == null
              ? null
              : PrimaryButton(
                  onPressed: () => _reprint(sale),
                  isLoading: _printing,
                  icon: Icons.print,
                  label: l10n.reprint,
                ),
        );
      },
    );
  }
}

class _AmountRow extends StatelessWidget {
  final String label;
  final int amount;
  final Color? color;

  const _AmountRow({required this.label, required this.amount, this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Expanded(child: Text(label, style: TextStyle(color: color))),
          Text(formatDAForUi(amount),
              style: TextStyle(fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }
}
