import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/scanner/barcode_scan_service.dart';
import '../../../../core/scanner/scan_listener.dart';
import '../../../../core/scanner/spp_link.dart';
import '../../../../core/service_locator.dart';
import '../../../../core/widgets/app_snack.dart';

/// Plus → Douchette: how to pair a Bluetooth barcode scanner, the scanners
/// in "SPP" mode, and an area to try a scan.
class ScannerDevicePage extends StatefulWidget {
  /// Tests pass their own service.
  final BarcodeScanService? service;
  const ScannerDevicePage({super.key, this.service});

  @override
  State<ScannerDevicePage> createState() => _ScannerDevicePageState();
}

class _ScannerDevicePageState extends State<ScannerDevicePage> {
  late final BarcodeScanService _scanner =
      widget.service ?? sl<BarcodeScanService>();
  List<BtDevice>? _devices;
  bool _loading = false;
  String? _lastCode;
  String? _lastProduct;
  int _count = 0;

  Future<void> _loadDevices() async {
    setState(() => _loading = true);
    final devices = await _scanner.spp.bondedDevices();
    if (!mounted) return;
    setState(() {
      _devices = devices;
      _loading = false;
    });
  }

  Future<void> _connect(BtDevice device) async {
    final l10n = AppLocalizations.of(context);
    final ok = await _scanner.connect(device);
    if (!mounted) return;
    showAppSnack(context,
        ok ? l10n.scannerConnected(device.name) : l10n.scannerConnectFailed,
        kind: ok ? SnackKind.success : SnackKind.error);
  }

  /// The test area takes every barcode while this page is open.
  bool _onTestScan(String code) {
    final product = productByBarcode(context, code);
    setState(() {
      _lastCode = code;
      _lastProduct = product?.name;
      _count++;
    });
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return ScanListener(
      service: _scanner,
      onScan: _onTestScan,
      child: Scaffold(
        appBar: AppBar(title: Text(l10n.scannerTitle)),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            // Try a scan.
            Card(
              color: scheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Icon(Icons.barcode_reader,
                          color: scheme.onPrimaryContainer),
                      const SizedBox(width: 8),
                      Text(l10n.scannerTestTitle,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: scheme.onPrimaryContainer)),
                    ]),
                    const SizedBox(height: 8),
                    Text(
                        _lastCode == null
                            ? l10n.scannerTestWaiting
                            : l10n.scannerTestGot(_count, _lastCode!),
                        style: TextStyle(color: scheme.onPrimaryContainer)),
                    if (_lastCode != null) ...[
                      const SizedBox(height: 4),
                      Text(
                          _lastProduct == null
                              ? l10n.scannerTestUnknown
                              : l10n.scannerTestKnown(_lastProduct!),
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: scheme.onPrimaryContainer)),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(l10n.scannerHowTitle,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(l10n.scannerHowSteps),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () =>
                  AppSettings.openAppSettings(type: AppSettingsType.bluetooth),
              icon: const Icon(Icons.settings_bluetooth),
              label: Text(l10n.bluetoothSettings),
            ),
            const SizedBox(height: 8),
            Text(l10n.scannerEmulatorTip,
                style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
            const Divider(height: 32),
            Text(l10n.scannerSppTitle,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(l10n.scannerSppHelp,
                style: TextStyle(color: scheme.onSurfaceVariant)),
            const SizedBox(height: 8),
            ValueListenableBuilder<SppStatus>(
              valueListenable: _scanner.sppStatus,
              builder: (context, status, _) {
                final name = _scanner.sppName;
                if (name == null) return const SizedBox.shrink();
                return Card(
                  child: ListTile(
                    leading: Icon(
                        status == SppStatus.connected
                            ? Icons.bluetooth_connected
                            : Icons.bluetooth_disabled,
                        color: status == SppStatus.connected
                            ? scheme.primary
                            : scheme.error),
                    title: Text(name),
                    subtitle: Text(switch (status) {
                      SppStatus.connected => l10n.scannerStateConnected,
                      SppStatus.connecting => l10n.scannerStateConnecting,
                      _ => l10n.scannerStateRetrying,
                    }),
                    trailing: TextButton(
                      onPressed: () async {
                        await _scanner.forget();
                        if (mounted) setState(() {});
                      },
                      child: Text(l10n.scannerForget),
                    ),
                  ),
                );
              },
            ),
            OutlinedButton.icon(
              onPressed: _loading ? null : _loadDevices,
              icon: const Icon(Icons.bluetooth_searching),
              label: Text(l10n.scannerShowPaired),
            ),
            if (_devices case final devices?)
              if (devices.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(l10n.printerErrNoPaired),
                )
              else
                Card(
                  child: Column(children: [
                    for (final device in devices)
                      ListTile(
                        leading: const Icon(Icons.bluetooth),
                        title: Text(device.name),
                        subtitle: Text(device.address),
                        onTap: () => _connect(device),
                      ),
                  ]),
                ),
            const Divider(height: 32),
            StatefulBuilder(
              builder: (context, setLocal) => SwitchListTile(
                contentPadding: EdgeInsets.zero,
                secondary: const Icon(Icons.volume_up_outlined),
                title: Text(l10n.scannerFeedback),
                value: _scanner.feedbackOn,
                onChanged: (on) async {
                  await _scanner.setFeedback(on);
                  setLocal(() {});
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
