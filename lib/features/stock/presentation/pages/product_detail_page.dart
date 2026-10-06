import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/service_locator.dart';
import '../../../../core/session/session_cubit.dart';
import '../../../../core/widgets/app_snack.dart';
import '../../../../core/widgets/confirm_merge.dart';
import '../../../sync/data/merge_service.dart';
import '../widgets/product_picker.dart';
import '../../../../core/utils/date_format.dart';
import '../../../../core/utils/money.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../product/domain/entities/product.dart';
import '../../../product/presentation/bloc/product_bloc.dart';
import '../../domain/entities/stock_batch.dart';
import '../../domain/repositories/stock_repository.dart';
import '../widgets/stock_badges.dart';

/// One product: price, stock now, each batch with its expiry colour,
/// and buttons to add stock, record a loss or edit.
class ProductDetailPage extends StatefulWidget {
  final String productId;

  const ProductDetailPage({super.key, required this.productId});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  late Future<({List<StockBatch> batches, int stock})> _batches = _load();
  bool _showEmpty = false;

  Future<({List<StockBatch> batches, int stock})> _load() async =>
      (await sl<StockRepository>().getBatches(widget.productId))
          .getOrElse((_) => (batches: <StockBatch>[], stock: 0));

  /// Opens a page, then reloads the batches when coming back.
  Future<void> _open(String location, {Object? extra}) async {
    await context.push(location, extra: extra);
    if (mounted) {
      setState(() {
        _batches = _load();
      });
    }
  }

  /// Owner: this product is the same as another one (a duplicate made on
  /// two phones): everything moves to the other, this one is archived.
  Future<void> _mergeInto(Product product) async {
    final l10n = AppLocalizations.of(context);
    final into = await pickProduct(context);
    if (into == null || into.id == product.id || !mounted) return;
    final ok = await confirmMerge(context,
        into: into.name, body: l10n.mergeProductBody(product.name, into.name));
    if (!ok || !mounted) return;
    final result = await sl<MergeService>()
        .mergeProducts(keepId: into.id, dropId: product.id);
    if (!mounted) return;
    result.fold(
      (failure) => showAppSnack(context, l10n.errorWithDetail(failure.message),
          kind: SnackKind.error),
      (_) {
        context.read<ProductBloc>().add(LoadProducts());
        showAppSnack(context, l10n.merged, kind: SnackKind.success);
        context.pop();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final isOwner = context.watch<SessionCubit>().state.isOwner;
    final product = context
        .watch<ProductBloc>()
        .state
        .products
        .where((p) => p.id == widget.productId)
        .firstOrNull;
    if (product == null) {
      return Scaffold(
        appBar: AppBar(),
        body: EmptyState(
            icon: Icons.search_off_rounded, title: l10n.productsNoMatch),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(product.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: l10n.editProduct,
            onPressed: () => _open('/stock/edit/${product.id}', extra: product),
          ),
          if (isOwner)
            PopupMenuButton<void>(
              itemBuilder: (_) => [
                PopupMenuItem(
                  onTap: () => _mergeInto(product),
                  child: Text(l10n.mergeInto),
                ),
              ],
            ),
        ],
      ),
      body: FutureBuilder<({List<StockBatch> batches, int stock})>(
        future: _batches,
        builder: (context, snapshot) {
          final data = snapshot.data;
          if (data == null) {
            return const Center(child: CircularProgressIndicator());
          }
          final shown = _showEmpty
              ? data.batches
              : data.batches.where((b) => b.remaining > 0).toList();
          final onShelf = data.batches.fold<int>(0, (s, b) => s + b.remaining);
          final missing = onShelf - data.stock;

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            children: [
              _Header(product: product, stock: data.stock),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () =>
                          _open('/stock/delivery', extra: product.id),
                      icon: const Icon(Icons.add_box_outlined),
                      label: Text(l10n.addDelivery),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _open('/stock/loss', extra: product.id),
                      icon: const Icon(Icons.report_outlined),
                      label: Text(l10n.recordLoss),
                    ),
                  ),
                ],
              ),
              if (missing > 0) ...[
                const SizedBox(height: 12),
                Card(
                  color: scheme.errorContainer,
                  child: ListTile(
                    leading: Icon(Icons.warning_amber_rounded,
                        color: scheme.onErrorContainer),
                    title: Text(l10n.missingStock(missing),
                        style: TextStyle(color: scheme.onErrorContainer)),
                  ),
                ),
              ],
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Text(l10n.batchesTitle,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: scheme.primary)),
                  ),
                  if (data.batches.any((b) => b.remaining == 0))
                    TextButton(
                      onPressed: () => setState(() => _showEmpty = !_showEmpty),
                      child: Text(l10n.showEmptyBatches),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              if (shown.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(l10n.batchesEmpty,
                      style: TextStyle(color: scheme.onSurfaceVariant)),
                )
              else
                Card(
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      for (final (index, batch) in shown.indexed) ...[
                        if (index > 0) const Divider(),
                        _BatchTile(batch: batch),
                      ],
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final Product product;
  final int stock;

  const _Header({required this.product, required this.stock});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.barcode,
                      style: TextStyle(color: scheme.onSurfaceVariant)),
                  const SizedBox(height: 4),
                  Text(formatDAForUi(product.sellPrice),
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: scheme.primary)),
                  if (product.buyPrice > 0)
                    Text(
                        '${l10n.fieldBuyPrice} : ${formatDAForUi(product.buyPrice)}',
                        style: TextStyle(
                            fontSize: 12, color: scheme.onSurfaceVariant)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(l10n.inStockLabel,
                    style: TextStyle(
                        fontSize: 12, color: scheme.onSurfaceVariant)),
                Text('$stock',
                    style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: stock <= 0 ? scheme.error : null)),
                StockBadge(
                    quantity: stock, lowThreshold: product.lowStockThreshold),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BatchTile extends StatelessWidget {
  final StockBatch batch;

  const _BatchTile({required this.batch});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final date = formatDate(batch.receivedAt);
    return ListTile(
      title: Align(
        alignment: AlignmentDirectional.centerStart,
        child: ExpiryBadge(expiry: batch.expiryDate, showWords: true),
      ),
      subtitle: Text([
        batch.receivedByName == null
            ? l10n.receivedOn(date)
            : l10n.receivedBy(date, batch.receivedByName!),
        if (batch.buyPrice > 0)
          '${l10n.fieldBuyPrice} : ${formatDAForUi(batch.buyPrice)}',
        if (batch.note != null) batch.note!,
      ].join('\n')),
      trailing: Text(l10n.batchRemaining(batch.remaining, batch.quantity),
          style: TextStyle(
              fontWeight: FontWeight.bold,
              color: batch.remaining == 0 ? scheme.onSurfaceVariant : null)),
    );
  }
}
