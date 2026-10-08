import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/scanner/scan_listener.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/service_locator.dart';
import '../../../../core/session/session_cubit.dart';
import '../../../../core/utils/money.dart';
import '../../../../core/widgets/app_snack.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../auth/presentation/widgets/owner_approval_dialog.dart';
import '../../../product/domain/entities/product.dart';
import '../../../product/presentation/bloc/product_bloc.dart';
import '../../../stock/presentation/widgets/product_picker.dart';
import '../../domain/entities/cart_item.dart';
import '../../domain/entities/sale.dart';
import '../../domain/repositories/sale_repository.dart';
import 'checkout_page.dart' show showStockShortDialog;

/// A customer brings items back:
/// - from a ticket ([saleId]) or without one (refunded at today's price,
///   the owner must agree when a worker does it);
/// - maybe taking other items instead: an exchange, where the app works
///   out what the customer pays or gets back.
class ReturnPage extends StatefulWidget {
  /// The ticket, or null for a return without a receipt.
  final String? saleId;

  /// Opens with "the customer takes other items" switched on.
  final bool exchange;

  const ReturnPage({super.key, this.saleId, this.exchange = false});

  @override
  State<ReturnPage> createState() => _ReturnPageState();
}

/// A product brought back without a receipt.
class _LooseItem {
  final Product product;
  int quantity = 1;
  bool toShelf = true;
  _LooseItem(this.product);
}

class _ReturnPageState extends State<ReturnPage> {
  late final Future<Sale?> _sale = (widget.saleId == null
          ? Future<Sale?>.value(null)
          : sl<SaleRepository>()
              .getSale(widget.saleId!)
              .then<Sale?>((r) => r.getOrElse((f) => throw f.message)))
      .then((sale) => _loadedSale = sale);
  Sale? _loadedSale;

  /// Exchange: the Bluetooth scanner adds to the items brought back
  /// (false) or to the items taken (true).
  bool _scanToTaken = false;

  /// From a ticket: per sale line, how many come back and whether to the
  /// shelf.
  final Map<String, int> _quantities = {};
  final Map<String, bool> _toShelf = {};

  /// Without a ticket: the products brought back.
  final List<_LooseItem> _loose = [];

  /// Exchange: the items the customer takes instead.
  final List<CartItem> _taken = [];
  late bool _exchange = widget.exchange;

  /// For a credit sale: take the refund off the customer's debt (default)
  /// instead of paying it.
  bool _toCredit = true;
  final _reason = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  int _refund(Sale? sale) => sale == null
      ? _loose.fold(0, (sum, l) => sum + l.product.sellPrice * l.quantity)
      : sale.items.fold(0,
          (sum, line) => sum + sale.refundFor(line, _quantities[line.id] ?? 0));

  int get _takenTotal =>
      _exchange ? _taken.fold(0, (sum, item) => sum + item.total) : 0;

  bool _refundsToDebt(Sale? sale) => (sale?.isCredit ?? false) && _toCredit;

  Future<void> _addLoose() async {
    final product = await pickProduct(context);
    if (product == null || !mounted) return;
    setState(() => _addLooseProduct(product));
  }

  void _addLooseProduct(Product product) {
    final existing =
        _loose.where((l) => l.product.id == product.id).firstOrNull;
    if (existing != null) {
      existing.quantity++;
    } else {
      _loose.add(_LooseItem(product));
    }
  }

  Future<void> _addTaken() async {
    final product = await pickProduct(context);
    if (product == null || !mounted) return;
    setState(() => _addTakenProduct(product));
  }

  void _addTakenProduct(Product product) {
    final index = _taken.indexWhere((t) => t.product.id == product.id);
    if (index >= 0) {
      _taken[index] =
          _taken[index].copyWith(quantity: _taken[index].quantity + 1);
    } else {
      _taken.add(CartItem(product: product));
    }
  }

  /// A barcode from the Bluetooth scanner: an item brought back (on the
  /// ticket, or without a ticket), or with an exchange an item taken.
  bool _onDeviceScan(String code) {
    final l10n = AppLocalizations.of(context);
    final product = productByBarcode(context, code);
    if (product == null) {
      showUnknownBarcode(context, code);
      return false;
    }
    if (_exchange && _scanToTaken) {
      setState(() => _addTakenProduct(product));
      return true;
    }
    final sale = _loadedSale;
    if (sale == null) {
      if (widget.saleId != null) return false; // still loading
      setState(() => _addLooseProduct(product));
      return true;
    }
    final line = sale.items
        .where((l) =>
            l.productId == product.id &&
            (_quantities[l.id] ?? 0) < l.returnable)
        .firstOrNull;
    if (line == null) {
      showAppSnack(context, l10n.scanNotOnTicket(product.name),
          kind: SnackKind.error);
      return false;
    }
    setState(() => _quantities[line.id] = (_quantities[line.id] ?? 0) + 1);
    return true;
  }

  Future<void> _save(Sale? sale) async {
    final l10n = AppLocalizations.of(context);
    final lines = [
      if (sale != null)
        for (final line in sale.items)
          if ((_quantities[line.id] ?? 0) > 0)
            ReturnLine(
              saleItemId: line.id,
              quantity: _quantities[line.id]!,
              backToStock: _toShelf[line.id] ?? true,
            ),
    ];
    final loose = [
      for (final item in _loose)
        LooseReturnLine(
            productId: item.product.id,
            quantity: item.quantity,
            backToStock: item.toShelf),
    ];
    if (lines.isEmpty && loose.isEmpty) {
      showAppSnack(context, l10n.returnNothing, kind: SnackKind.error);
      return;
    }
    if (_exchange && _taken.isEmpty) {
      showAppSnack(context, l10n.exchangeNothingTaken, kind: SnackKind.error);
      return;
    }

    // Without a receipt, a worker needs the owner's PIN.
    String? ownerPin;
    if (sale == null && !context.read<SessionCubit>().state.isOwner) {
      ownerPin = await askOwnerApproval(context);
      if (ownerPin == null || !mounted) return;
    }

    setState(() => _saving = true);
    final result = await sl<SaleRepository>().processReturn(
      saleId: sale?.id,
      lines: lines,
      looseLines: loose,
      takes: _exchange ? _taken : const [],
      reason: _reason.text,
      toCredit: _refundsToDebt(sale),
      ownerPin: ownerPin,
    );
    if (!mounted) return;
    setState(() => _saving = false);
    if (result.getLeft().toNullable() case final StockShortFailure short) {
      await showStockShortDialog(context, short);
      return;
    }
    result.fold(
      (failure) => showAppSnack(
          context,
          failure is OwnerApprovalFailure
              ? l10n.ownerApprovalRefused
              : l10n.errorWithDetail(failure.message),
          kind: SnackKind.error),
      (done) {
        context.read<ProductBloc>().add(LoadProducts());
        final newSale = done.exchangeSale;
        if (newSale != null) {
          showAppSnack(context, l10n.exchangeSaved(newSale.ticket),
              kind: SnackKind.success);
          // The exchange ticket, ready to print.
          context.pushReplacement('/sell/history/${newSale.id}');
          return;
        }
        showAppSnack(
            context,
            done.toCredit
                ? l10n.returnSavedCredit(formatDA(done.refund))
                : l10n.returnSaved(formatDA(done.refund)),
            kind: SnackKind.success);
        context.pop(true);
      },
    );
  }

  String _title(AppLocalizations l10n, Sale? sale) {
    if (sale == null) {
      return _exchange ? l10n.noReceiptExchange : l10n.noReceiptReturn;
    }
    return _exchange
        ? l10n.exchangeTitle(sale.ticket)
        : l10n.returnTitle(sale.ticket);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return ScanListener(
      onScan: _onDeviceScan,
      child: FutureBuilder<Sale?>(
        future: _sale,
        builder: (context, snapshot) {
          final sale = snapshot.data;
          final loading = widget.saleId != null && sale == null;
          return Scaffold(
            appBar: AppBar(title: Text(loading ? '' : _title(l10n, sale))),
            body: snapshot.hasError
                ? EmptyState(
                    icon: Icons.error_outline,
                    title: l10n.errorWithDetail('${snapshot.error}'))
                : loading
                    ? const Center(child: CircularProgressIndicator())
                    : _form(context, l10n, sale),
            bottomNavigationBar: loading
                ? null
                : PrimaryButton(
                    onPressed: () => _save(sale),
                    isLoading: _saving,
                    icon: _exchange
                        ? Icons.swap_horiz
                        : Icons.assignment_return_outlined,
                    label:
                        _exchange ? l10n.confirmExchange : l10n.confirmReturn,
                  ),
          );
        },
      ),
    );
  }

  Widget _form(BuildContext context, AppLocalizations l10n, Sale? sale) {
    final scheme = Theme.of(context).colorScheme;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        Text(sale == null ? l10n.noReceiptPriceNote : l10n.returnIntro,
            style: TextStyle(color: scheme.onSurfaceVariant)),
        const SizedBox(height: 12),
        _Header(l10n.returnedItemsSection),
        if (sale != null)
          for (final line in sale.items.where((l) => l.returnable > 0))
            _LineCard(
              name: line.productName,
              detail:
                  '${line.returnable} × ${formatDAForUi(line.sellPrice)}${line.returned > 0 ? ' · ${l10n.returnedQty(line.returned)}' : ''}',
              quantity: _quantities[line.id] ?? 0,
              max: line.returnable,
              toShelf: _toShelf[line.id] ?? true,
              onQuantity: (q) => setState(() => _quantities[line.id] = q),
              onShelf: (v) => setState(() => _toShelf[line.id] = v),
            )
        else ...[
          for (final item in _loose)
            _LineCard(
              name: item.product.name,
              detail: formatDAForUi(item.product.sellPrice),
              quantity: item.quantity,
              toShelf: item.toShelf,
              onQuantity: (q) => setState(() {
                if (q == 0) {
                  _loose.remove(item);
                } else {
                  item.quantity = q;
                }
              }),
              onShelf: (v) => setState(() => item.toShelf = v),
            ),
          OutlinedButton.icon(
            onPressed: _addLoose,
            icon: const Icon(Icons.add),
            label: Text(l10n.addReturnedProduct),
          ),
        ],
        const SizedBox(height: 8),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          secondary: const Icon(Icons.swap_horiz),
          title: Text(l10n.exchangeSwitch),
          value: _exchange,
          onChanged: (on) => setState(() => _exchange = on),
        ),
        if (_exchange) ...[
          // Where a scan from the Bluetooth scanner goes.
          Row(children: [
            const Icon(Icons.barcode_reader, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(l10n.scanGoesTo)),
          ]),
          const SizedBox(height: 6),
          SegmentedButton<bool>(
            showSelectedIcon: false,
            segments: [
              ButtonSegment(value: false, label: Text(l10n.scanToReturned)),
              ButtonSegment(value: true, label: Text(l10n.scanToTaken)),
            ],
            selected: {_scanToTaken},
            onSelectionChanged: (v) => setState(() => _scanToTaken = v.first),
          ),
          _Header(l10n.takenItemsSection),
          for (final (index, item) in _taken.indexed)
            _LineCard(
              name: item.product.name,
              detail: formatDAForUi(item.product.sellPrice),
              quantity: item.quantity,
              onQuantity: (q) => setState(() {
                if (q == 0) {
                  _taken.removeAt(index);
                } else {
                  _taken[index] = item.copyWith(quantity: q);
                }
              }),
            ),
          OutlinedButton.icon(
            onPressed: _addTaken,
            icon: const Icon(Icons.add_shopping_cart),
            label: Text(l10n.addTakenProduct),
          ),
        ],
        if (sale?.isCredit ?? false) ...[
          const SizedBox(height: 16),
          Text(l10n.refundModeLabel,
              style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          SegmentedButton<bool>(
            showSelectedIcon: false,
            segments: [
              ButtonSegment(
                  value: true,
                  icon: const Icon(Icons.menu_book_outlined, size: 18),
                  label: Text(l10n.refundToCredit)),
              ButtonSegment(
                  value: false,
                  icon: const Icon(Icons.payments_outlined, size: 18),
                  label: Text(l10n.refundCash)),
            ],
            selected: {_toCredit},
            onSelectionChanged: (s) => setState(() => _toCredit = s.first),
          ),
        ],
        const SizedBox(height: 12),
        TextField(
          controller: _reason,
          decoration: InputDecoration(labelText: l10n.returnReasonLabel),
        ),
        const SizedBox(height: 16),
        _Summary(
          refund: _refund(sale),
          taken: _takenTotal,
          exchange: _exchange,
          toDebt: _refundsToDebt(sale),
          customerName: sale?.customerName,
        ),
      ],
    );
  }
}

/// What the customer pays or gets back.
class _Summary extends StatelessWidget {
  final int refund;
  final int taken;
  final bool exchange;
  final bool toDebt;
  final String? customerName;

  const _Summary(
      {required this.refund,
      required this.taken,
      required this.exchange,
      required this.toDebt,
      this.customerName});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final style = TextStyle(color: scheme.onPrimaryContainer);
    final bold = style.copyWith(fontSize: 16, fontWeight: FontWeight.bold);

    final lines = <Widget>[];
    if (!exchange) {
      lines.add(Text(
          toDebt
              ? l10n.refundToAccount(customerName ?? '', formatDAForUi(refund))
              : l10n.refundToGive(formatDAForUi(refund)),
          style: bold));
    } else {
      final difference = taken - (toDebt ? 0 : refund);
      lines
        ..add(_row(l10n.returnValueLabel, refund, style))
        ..add(_row(l10n.takenValueLabel, taken, style));
      if (toDebt) {
        lines.add(Text(l10n.debtReduced(formatDAForUi(refund)), style: style));
      }
      lines
        ..add(Divider(color: scheme.onPrimaryContainer.withValues(alpha: 0.3)))
        ..add(Text(
            difference > 0
                ? l10n.customerPays(formatDAForUi(difference))
                : difference < 0
                    ? l10n.giveBack(formatDAForUi(-difference))
                    : l10n.nothingToSettle,
            style: bold));
    }
    return Card(
      color: scheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, children: lines),
      ),
    );
  }

  Widget _row(String label, int amount, TextStyle style) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Row(
          children: [
            Expanded(child: Text(label, style: style)),
            Text(formatDAForUi(amount), style: style),
          ],
        ),
      );
}

class _Header extends StatelessWidget {
  final String text;
  const _Header(this.text);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text, style: Theme.of(context).textTheme.titleMedium),
      );
}

/// One product: how many, and (for items brought back) whether they go
/// back on the shelf or are damaged.
class _LineCard extends StatelessWidget {
  final String name;
  final String detail;
  final int quantity;

  /// Highest quantity allowed, or null for no limit.
  final int? max;

  /// Null for items taken in an exchange (no shelf/damaged choice).
  final bool? toShelf;
  final ValueChanged<int> onQuantity;
  final ValueChanged<bool>? onShelf;

  const _LineCard({
    required this.name,
    required this.detail,
    required this.quantity,
    this.max,
    this.toShelf,
    required this.onQuantity,
    this.onShelf,
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
                      Text(name,
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                      Text(detail,
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
                  onPressed: max == null || quantity < max!
                      ? () => onQuantity(quantity + 1)
                      : null,
                  icon: const Icon(Icons.add_circle_outline),
                ),
              ],
            ),
            if (toShelf != null && quantity > 0)
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
                selected: {toShelf!},
                onSelectionChanged: (s) => onShelf?.call(s.first),
              ),
          ],
        ),
      ),
    );
  }
}
