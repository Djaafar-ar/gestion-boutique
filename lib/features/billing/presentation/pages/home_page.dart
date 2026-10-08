import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:vibration/vibration.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../config/routes/app_shell.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/scanner/scan_listener.dart';
import '../../../../core/utils/money.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../billing/presentation/bloc/billing_bloc.dart';
import '../../../product/presentation/bloc/product_bloc.dart';
import '../../domain/entities/cart_item.dart';

/// The Sell tab: camera scanner on top, current cart below.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final MobileScannerController _scannerController = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    returnImage: false,
  );

  bool _isCameraOn = true;
  bool _isFlashOn = false;

  // Cooldown mapping to prevent rapid firing of the same barcode
  final Map<String, DateTime> _lastScanTimes = {};

  @override
  void initState() {
    super.initState();
    currentTabIndex.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    currentTabIndex.removeListener(_onTabChanged);
    _scannerController.dispose();
    super.dispose();
  }

  /// The camera only runs while the Sell tab is visible.
  void _onTabChanged() {
    if (currentTabIndex.value == 0) {
      if (_isCameraOn) _scannerController.start();
    } else {
      _scannerController.stop();
    }
  }

  /// Stops the camera while another full-screen page is open.
  Future<void> _openPage(String location) async {
    _scannerController.stop();
    await context.push(location);
    if (_isCameraOn && mounted && currentTabIndex.value == 0) {
      _scannerController.start();
    }
  }

  void _onDetect(BarcodeCapture capture) async {
    final List<Barcode> barcodes = capture.barcodes;
    final now = DateTime.now();

    for (final barcode in barcodes) {
      if (barcode.rawValue != null) {
        final rawValue = barcode.rawValue!;

        // Cooldown logic: 2 seconds per identical barcode
        if (_lastScanTimes.containsKey(rawValue)) {
          final lastScan = _lastScanTimes[rawValue]!;
          if (now.difference(lastScan).inSeconds < 2) {
            continue;
          }
        }

        _lastScanTimes[rawValue] = now;

        // Vibrate
        final hasVibrator = await Vibration.hasVibrator();
        if (hasVibrator == true) {
          Vibration.vibrate();
        }

        if (mounted) {
          context.read<BillingBloc>().add(ScanBarcodeEvent(rawValue));
        }
        break; // Process one barcode at a time per frame
      }
    }
  }

  /// A barcode from the Bluetooth scanner: into the cart if known.
  bool _onDeviceScan(String code) {
    final product = productByBarcode(context, code);
    if (product == null) {
      showUnknownBarcode(context, code);
      return false;
    }
    context.read<BillingBloc>().add(AddProductToCartEvent(product));
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scannerHeight = MediaQuery.of(context).size.height * 0.36;

    return Scaffold(
      body: BlocListener<BillingBloc, BillingState>(
        listenWhen: (previous, current) =>
            current.error == BillingError.productNotFound &&
            previous.error != current.error,
        listener: (context, state) =>
            showUnknownBarcode(context, state.errorDetail ?? ''),
        // The Bluetooth scanner ("douchette") adds to the cart too.
        child: ScanListener(
          onScan: _onDeviceScan,
          child: Stack(
            children: [
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: scannerHeight,
                child: _buildScannerSection(l10n),
              ),
              Positioned(
                top: scannerHeight - 24, // overlap
                left: 0,
                right: 0,
                bottom: 0,
                child: _buildBottomPanel(l10n),
              ),
            ],
          ),
        ),
      ),
      bottomSheet:
          BlocBuilder<BillingBloc, BillingState>(builder: (context, state) {
        return ColoredBox(
          color: Theme.of(context).colorScheme.surface,
          child: PrimaryButton(
            onPressed: state.cartItems.isEmpty
                ? null
                : () => _openPage('/sell/checkout'),
            icon: Icons.point_of_sale,
            label: l10n.goToCheckout,
          ),
        );
      }),
    );
  }

  Widget _buildScannerSection(AppLocalizations l10n) {
    return Container(
      color: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(
            controller: _scannerController,
            onDetect: _onDetect,
          ),
          if (!_isCameraOn) _buildCameraOffState(l10n),

          // Overlay actions, on the "end" side (right, or left in Arabic)
          PositionedDirectional(
            top: MediaQuery.of(context).padding.top + 12,
            end: 12,
            child: Column(
              children: [
                _buildOverlayButton(
                  icon: Icons.receipt_long,
                  tooltip: l10n.historyTitle,
                  onPressed: () => _openPage('/sell/history'),
                ),
                if (_isCameraOn)
                  _buildOverlayButton(
                    icon:
                        _isFlashOn ? Icons.flashlight_off : Icons.flashlight_on,
                    onPressed: () {
                      setState(() => _isFlashOn = !_isFlashOn);
                      _scannerController.toggleTorch();
                    },
                  ),
                _buildOverlayButton(
                  icon: _isCameraOn ? Icons.videocam : Icons.videocam_off,
                  onPressed: () {
                    setState(() {
                      _isCameraOn = !_isCameraOn;
                    });
                    if (_isCameraOn) {
                      _scannerController.start();
                    } else {
                      _scannerController.stop();
                    }
                  },
                ),
              ],
            ),
          ),

          // Central framing box
          if (_isCameraOn)
            Center(
              child: Container(
                width: 230,
                height: 150,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white54, width: 2),
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCameraOffState(AppLocalizations l10n) {
    return ColoredBox(
      color: const Color(0xFF1E293B),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.videocam_off, color: Colors.white, size: 36),
          const SizedBox(height: 12),
          Text(
            l10n.cameraOffTitle,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              l10n.cameraOffBody,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            style: FilledButton.styleFrom(minimumSize: const Size(0, 44)),
            icon: const Icon(Icons.videocam),
            label: Text(l10n.turnOnCamera),
            onPressed: () {
              setState(() => _isCameraOn = true);
              _scannerController.start();
            },
          )
        ],
      ),
    );
  }

  Widget _buildOverlayButton(
      {required IconData icon,
      required VoidCallback onPressed,
      String? tooltip}) {
    return Container(
      width: 44,
      height: 44,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.black45,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white24),
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white),
        tooltip: tooltip,
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildBottomPanel(AppLocalizations l10n) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag handle indicator
          Container(
            width: 48,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: scheme.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          BlocBuilder<BillingBloc, BillingState>(
            builder: (context, state) {
              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l10n.cartTitle,
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w600)),
                          Text(l10n.itemCount(state.itemCount),
                              style: TextStyle(
                                  fontSize: 12,
                                  color: scheme.onSurfaceVariant)),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(l10n.totalLabel,
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: scheme.onSurfaceVariant,
                                letterSpacing: 1.2)),
                        Text(
                          formatDAForUi(state.totalAmount),
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: scheme.primary),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          const Divider(),

          // List View
          Expanded(
            child: BlocBuilder<BillingBloc, BillingState>(
              builder: (context, state) {
                if (state.cartItems.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 80),
                    child: EmptyState(
                      icon: Icons.shopping_basket_outlined,
                      title: l10n.cartEmptyTitle,
                      message: l10n.cartEmptyBody,
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                  itemCount: state.cartItems.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    return _buildCartItemCard(context, state.cartItems[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItemCard(BuildContext context, CartItem item) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.product.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 14),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formatDAForUi(item.product.sellPrice),
                    style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                        color: scheme.onSurfaceVariant),
                  ),
                  // Stock left; red when selling more than what is there.
                  Builder(builder: (context) {
                    final stock = context
                        .watch<ProductBloc>()
                        .state
                        .stockOf(item.product.id)
                        .quantity;
                    final short = item.quantity > stock;
                    return Text(
                      AppLocalizations.of(context).stockLabel(stock),
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: short ? FontWeight.bold : null,
                          color:
                              short ? scheme.error : scheme.onSurfaceVariant),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.all(2),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    icon: Icon(
                        item.quantity > 1 ? Icons.remove : Icons.delete_outline,
                        size: 20),
                    onPressed: () {
                      context.read<BillingBloc>().add(UpdateQuantityEvent(
                          item.product.id, item.quantity - 1));
                    },
                  ),
                  SizedBox(
                    width: 28,
                    child: Text(
                      '${item.quantity}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(Icons.add, size: 20),
                    onPressed: () {
                      context.read<BillingBloc>().add(UpdateQuantityEvent(
                          item.product.id, item.quantity + 1));
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
