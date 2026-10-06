import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/widgets/app_snack.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../data/sync_protocol.dart';
import '../sync_cubit.dart';
import 'sync_page.dart';

/// First launch on a worker's phone: scan the owner's code, name this
/// phone, and download the shop.
class JoinPage extends StatefulWidget {
  const JoinPage({super.key});

  @override
  State<JoinPage> createState() => _JoinPageState();
}

class _JoinPageState extends State<JoinPage> {
  final _name = TextEditingController();
  PairingInfo? _info;
  bool _joining = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _scan() async {
    final l10n = AppLocalizations.of(context);
    final text = await context.push<String>('/scanner');
    if (text == null || !mounted) return;
    final info = PairingInfo.decode(text);
    setState(() {
      _info = info;
      _error = info == null ? l10n.notPairingCode : null;
    });
  }

  Future<void> _join() async {
    final info = _info;
    if (info == null) return;
    final l10n = AppLocalizations.of(context);
    setState(() {
      _joining = true;
      _error = null;
    });
    try {
      final code = await context
          .read<SyncCubit>()
          .join(info, deviceName: _name.text.trim());
      if (!mounted) return;
      // The session now has the shop's accounts: the PIN screen opens.
      showAppSnack(context, l10n.joined(code), kind: SnackKind.success);
    } on SyncException catch (e) {
      if (mounted) setState(() => _error = syncErrorText(l10n, e.error));
    } catch (_) {
      if (mounted) setState(() => _error = l10n.syncErrOther);
    } finally {
      if (mounted) setState(() => _joining = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final info = _info;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.joinTitle),
        leading: BackButton(onPressed: () => context.go('/setup')),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Icon(Icons.wifi_tethering, size: 48, color: scheme.primary),
          const SizedBox(height: 12),
          Text(l10n.joinIntro,
              style: TextStyle(color: scheme.onSurfaceVariant)),
          const SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: _joining ? null : _scan,
            icon: const Icon(Icons.qr_code_scanner),
            label: Text(l10n.scanPairingCode),
          ),
          if (info != null) ...[
            const SizedBox(height: 20),
            Card(
              child: ListTile(
                leading: const Icon(Icons.storefront),
                title: Text(info.shopName,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text('${info.host}:${info.port}'),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _name,
              enabled: !_joining,
              decoration: InputDecoration(
                  labelText: l10n.deviceNameLabel,
                  hintText: l10n.deviceNameHint),
            ),
          ],
          if (_joining) ...[
            const SizedBox(height: 20),
            const LinearProgressIndicator(),
            const SizedBox(height: 8),
            Text(l10n.joining, textAlign: TextAlign.center),
          ],
          if (_error != null) ...[
            const SizedBox(height: 16),
            Text(_error!, style: TextStyle(color: scheme.error)),
          ],
        ],
      ),
      bottomNavigationBar: info == null
          ? null
          : PrimaryButton(
              onPressed: _joining ? null : _join,
              isLoading: _joining,
              icon: Icons.link,
              label: l10n.joinButton(info.shopName),
            ),
    );
  }
}
