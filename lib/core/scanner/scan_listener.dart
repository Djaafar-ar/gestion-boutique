import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/product/domain/entities/product.dart';
import '../../features/product/presentation/bloc/product_bloc.dart';
import '../l10n/app_localizations.dart';
import '../service_locator.dart';
import 'barcode_scan_service.dart';

/// Gives this screen the barcodes of the Bluetooth scanner while it is the
/// screen the person sees (not hidden behind another page, a dialog or
/// another tab). [onScan] returns true when it accepted the barcode.
class ScanListener extends StatefulWidget {
  final bool Function(String code) onScan;
  final bool enabled;
  final Widget child;

  /// Tests pass their own service.
  final BarcodeScanService? service;

  const ScanListener({
    super.key,
    required this.onScan,
    required this.child,
    this.enabled = true,
    this.service,
  });

  @override
  State<ScanListener> createState() => _ScanListenerState();
}

class _ScanListenerState extends State<ScanListener> implements ScanTarget {
  late final BarcodeScanService? _service = widget.service ??
      (sl.isRegistered<BarcodeScanService>() ? sl<BarcodeScanService>() : null);

  @override
  void initState() {
    super.initState();
    _service?.register(this);
  }

  @override
  void dispose() {
    _service?.unregister(this);
    super.dispose();
  }

  @override
  bool get acceptsScans =>
      mounted &&
      widget.enabled &&
      TickerMode.valuesOf(context).enabled &&
      isOnTop(context);

  @override
  bool onScan(String code) => widget.onScan(code);

  @override
  Widget build(BuildContext context) => widget.child;
}

/// True when the page holding [context] is the top page of its navigator,
/// and so on up to the app's main navigator (a page opened above the tabs
/// hides them).
bool isOnTop(BuildContext context) {
  var current = context;
  for (var depth = 0; depth < 8; depth++) {
    final route = ModalRoute.of(current);
    if (route != null && !route.isCurrent) return false;
    final navigator = current.findAncestorStateOfType<NavigatorState>();
    if (navigator == null) return true;
    current = navigator.context;
  }
  return true;
}

/// The product with this barcode (not archived), from the product list.
Product? productByBarcode(BuildContext context, String code) => context
    .read<ProductBloc>()
    .state
    .products
    .where((p) => p.barcode == code && !p.archived)
    .firstOrNull;

/// "Code-barres inconnu", with a button to create the product.
void showUnknownBarcode(BuildContext context, String code) {
  final l10n = AppLocalizations.of(context);
  final scheme = Theme.of(context).colorScheme;
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      backgroundColor: scheme.error,
      duration: const Duration(seconds: 6),
      content:
          Text(l10n.scanUnknown(code), style: TextStyle(color: scheme.onError)),
      action: SnackBarAction(
        label: l10n.scanCreateProduct,
        textColor: scheme.onError,
        onPressed: () => context.push('/stock/add', extra: code),
      ),
    ));
}
