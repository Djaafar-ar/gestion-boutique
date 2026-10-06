import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/session/session_cubit.dart';
import '../../../../core/utils/money.dart';
import '../../../../core/widgets/app_snack.dart';
import '../../../../core/widgets/empty_state.dart';
import '../bloc/product_bloc.dart';
import '../../domain/entities/product.dart';
import '../../../stock/domain/entities/stock_batch.dart';
import '../../../stock/presentation/widgets/stock_badges.dart';

/// The Stock tab: every product, with search and scan.
class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _scanQR(List<Product> products) async {
    final barcode = await context.push<String>('/scanner');
    if (barcode != null && barcode.isNotEmpty) {
      final matchedProduct =
          products.where((p) => p.barcode == barcode).firstOrNull;
      // Show the product found, or the barcode itself if unknown.
      _searchController.text = matchedProduct?.name ?? barcode;
    }
  }

  String _actionMessage(AppLocalizations l10n, ProductAction action) =>
      switch (action) {
        ProductAction.added => l10n.productAdded,
        ProductAction.updated => l10n.productUpdated,
        ProductAction.archived => l10n.productArchived,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.productsTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.trending_down),
            tooltip: l10n.lossesTitle,
            onPressed: () => context.push('/stock/losses'),
          ),
        ],
      ),
      body: BlocConsumer<ProductBloc, ProductState>(
        listener: (context, state) {
          if (state.status == ProductStatus.success && state.action != null) {
            showAppSnack(context, _actionMessage(l10n, state.action!),
                kind: SnackKind.success);
          } else if (state.status == ProductStatus.error &&
              state.message != null) {
            showAppSnack(context, l10n.errorWithDetail(state.message!),
                kind: SnackKind.error);
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: l10n.productSearchHint,
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.qr_code_scanner),
                      tooltip: l10n.scanBarcodeTitle,
                      onPressed: () => _scanQR(state.products),
                    ),
                  ),
                ),
              ),
              Expanded(child: _buildList(context, l10n, state)),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showActions(context, l10n),
        icon: const Icon(Icons.add),
        label: Text(l10n.addDelivery),
      ),
    );
  }

  /// The "+" button: receive stock, record a loss or add a product.
  void _showActions(BuildContext context, AppLocalizations l10n) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final (icon, label, location) in [
              (Icons.add_box_outlined, l10n.addDelivery, '/stock/delivery'),
              (Icons.report_outlined, l10n.recordLoss, '/stock/loss'),
              (Icons.add_circle_outline, l10n.addProduct, '/stock/add'),
            ])
              ListTile(
                leading: Icon(icon),
                title: Text(label),
                onTap: () {
                  Navigator.pop(sheetContext);
                  context.push(location);
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildList(
      BuildContext context, AppLocalizations l10n, ProductState state) {
    if (state.status == ProductStatus.loading && state.products.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.products.isEmpty) {
      return EmptyState(
        icon: Icons.inventory_2_outlined,
        title: l10n.productsEmptyTitle,
        message: l10n.productsEmptyBody,
      );
    }

    final filteredProducts = state.products
        .where((product) =>
            product.name.toLowerCase().contains(_searchQuery) ||
            product.barcode.toLowerCase().contains(_searchQuery))
        .toList();

    if (filteredProducts.isEmpty) {
      return EmptyState(
          icon: Icons.search_off_rounded, title: l10n.productsNoMatch);
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
      itemCount: filteredProducts.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) => _ProductCard(
          product: filteredProducts[index],
          stock: state.stockOf(filteredProducts[index].id)),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Product product;
  final ProductStock stock;

  const _ProductCard({required this.product, required this.stock});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/stock/product/${product.id}'),
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 4, 12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 15),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        StockBadge(
                            quantity: stock.quantity,
                            lowThreshold: product.lowStockThreshold),
                        if (stock.nextExpiry != null)
                          ExpiryBadge(expiry: stock.nextExpiry),
                      ],
                    ),
                  ],
                ),
              ),
              Text(
                formatDAForUi(product.sellPrice),
                style: TextStyle(
                    fontWeight: FontWeight.w700, color: scheme.primary),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') {
                    context.push('/stock/edit/${product.id}', extra: product);
                  } else {
                    _confirmArchive(context, l10n);
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'edit',
                    child: ListTile(
                      leading: const Icon(Icons.edit_outlined),
                      title: Text(l10n.editProduct),
                    ),
                  ),
                  // Only the owner can hide a product.
                  if (context.read<SessionCubit>().state.isOwner)
                    PopupMenuItem(
                      value: 'archive',
                      child: ListTile(
                        leading: const Icon(Icons.archive_outlined),
                        title: Text(l10n.archive),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmArchive(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (innerContext) {
        return AlertDialog(
          title: Text(l10n.archiveProductTitle),
          content: Text(l10n.archiveProductBody(product.name)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(innerContext),
              child: Text(l10n.commonCancel),
            ),
            FilledButton.tonal(
              onPressed: () {
                context.read<ProductBloc>().add(ArchiveProduct(product.id));
                Navigator.pop(innerContext);
              },
              child: Text(l10n.archive),
            ),
          ],
        );
      },
    );
  }
}
