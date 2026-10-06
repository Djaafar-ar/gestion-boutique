import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
  late final Future<Sale> _sale = _load();
  bool _printing = false;

  Future<Sale> _load() async {
    final result = await sl<SaleRepository>().getSale(widget.saleId);
    return result.fold((failure) => throw failure.message, (sale) => sale);
  }

  Future<void> _reprint(Sale sale) async {
    final l10n = AppLocalizations.of(context);
    final shopState = context.read<ShopBloc>().state;
    final shop = shopState is ShopLoaded ? shopState.shop : const Shop();

    setState(() => _printing = true);
    final result = await sl<ReceiptPrinter>().printSale(sale, shop);
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
                        Text(formatDateTime(sale.createdAt),
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
                                  subtitle: Text(
                                      '${line.quantity} × ${formatDAForUi(line.sellPrice)}'),
                                  trailing: Text(formatDAForUi(line.total),
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600)),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
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
