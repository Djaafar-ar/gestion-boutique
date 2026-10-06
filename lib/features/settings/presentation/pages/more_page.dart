import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:app_settings/app_settings.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/widgets/app_snack.dart';
import '../../../shop/presentation/bloc/shop_bloc.dart';
import '../bloc/printer_bloc.dart';
import '../bloc/printer_event.dart';
import '../bloc/printer_state.dart';
import '../cubit/app_preferences_cubit.dart';

/// The "More" tab: shop, language, theme and printer settings.
class MorePage extends StatefulWidget {
  const MorePage({super.key});

  @override
  State<MorePage> createState() => _MorePageState();
}

class _MorePageState extends State<MorePage> {
  /// Language names are always written in their own language.
  static const _languageNames = {
    'fr': 'Français',
    'ar': 'العربية',
    'en': 'English',
  };

  @override
  void initState() {
    super.initState();
    // Re-read the saved printer whenever this page opens
    context.read<PrinterBloc>().add(InitPrinterEvent());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final prefs = context.watch<AppPreferencesCubit>().state;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.moreTitle)),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          _buildShopHeader(l10n),
          _SectionHeader(l10n.sectionShop),
          _Group(children: [
            ListTile(
              leading: const _TileIcon(Icons.storefront),
              title: Text(l10n.shopDetails),
              subtitle: Text(l10n.shopDetailsSub),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/more/shop'),
            ),
          ]),
          _SectionHeader(l10n.sectionPreferences),
          _Group(children: [
            ListTile(
              leading: const _TileIcon(Icons.translate),
              title: Text(l10n.language),
              subtitle: Text(prefs.language == 'system'
                  ? l10n.languageSystem
                  : _languageNames[prefs.language]!),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _pickLanguage(l10n, prefs.language),
            ),
            const Divider(indent: 72),
            ListTile(
              leading: const _TileIcon(Icons.dark_mode_outlined),
              title: Text(l10n.theme),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: SegmentedButton<ThemeMode>(
                  showSelectedIcon: false,
                  segments: [
                    ButtonSegment(
                        value: ThemeMode.system,
                        icon: const Icon(Icons.brightness_auto, size: 18),
                        tooltip: l10n.themeSystem),
                    ButtonSegment(
                        value: ThemeMode.light,
                        icon: const Icon(Icons.light_mode, size: 18),
                        tooltip: l10n.themeLight),
                    ButtonSegment(
                        value: ThemeMode.dark,
                        icon: const Icon(Icons.dark_mode, size: 18),
                        tooltip: l10n.themeDark),
                  ],
                  selected: {prefs.themeMode},
                  onSelectionChanged: (selection) => context
                      .read<AppPreferencesCubit>()
                      .setThemeMode(selection.first),
                ),
              ),
            ),
          ]),
          _SectionHeader(l10n.sectionPrinter),
          _buildPrinterGroup(l10n),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Text(
              l10n.printerHelp,
              style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShopHeader(AppLocalizations l10n) {
    final scheme = Theme.of(context).colorScheme;
    return BlocBuilder<ShopBloc, ShopState>(
      builder: (context, state) {
        var shopName = l10n.shopNameFallback;
        if (state is ShopLoaded && state.shop.name.isNotEmpty) {
          shopName = state.shop.name;
        }
        final initials = shopName
            .split(' ')
            .where((p) => p.isNotEmpty)
            .take(2)
            .map((p) => p.characters.first.toUpperCase())
            .join();

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
          child: Column(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: scheme.primaryContainer,
                foregroundColor: scheme.onPrimaryContainer,
                child: Text(initials,
                    style: const TextStyle(
                        fontSize: 28, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 12),
              Text(shopName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPrinterGroup(AppLocalizations l10n) {
    return BlocConsumer<PrinterBloc, PrinterState>(
      listenWhen: (previous, current) =>
          previous.status != current.status || previous.error != current.error,
      listener: (context, state) {
        final error = state.error;
        if (error != null) {
          final message = switch (error) {
            PrinterError.noPairedDevices => l10n.printerErrNoPaired,
            PrinterError.connectAllFailed => l10n.printerErrConnectAll,
            PrinterError.connectFailed => l10n.printerErrConnect,
            PrinterError.permissionDenied => l10n.printerErrPermission,
            PrinterError.other =>
              l10n.errorWithDetail(state.errorMessage ?? ''),
          };
          showAppSnack(context, message, kind: SnackKind.error);
        } else if (state.status == PrinterStatus.connected) {
          showAppSnack(context, l10n.printerConnected, kind: SnackKind.success);
        }
      },
      builder: (context, state) {
        final scheme = Theme.of(context).colorScheme;
        final busy = state.status == PrinterStatus.scanning ||
            state.status == PrinterStatus.connecting;
        final hasPrinter = state.connectedMac != null;

        return _Group(children: [
          ListTile(
            leading: const _TileIcon(Icons.print),
            title: Text(l10n.printerDevice),
            subtitle: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              children: [
                Text(hasPrinter
                    ? (state.connectedName ?? l10n.printerConnected)
                    : l10n.printerNone),
                if (hasPrinter)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: scheme.tertiaryContainer,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      l10n.printerConnectedBadge,
                      style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: scheme.onTertiaryContainer),
                    ),
                  ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (busy)
                  const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2)),
                  )
                else
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    tooltip: l10n.refresh,
                    onPressed: () =>
                        context.read<PrinterBloc>().add(RefreshPrinterEvent()),
                  ),
                IconButton(
                  icon: const Icon(Icons.settings_bluetooth),
                  tooltip: l10n.bluetoothSettings,
                  onPressed: () {
                    AppSettings.openAppSettings(
                        type: AppSettingsType.bluetooth);
                  },
                ),
              ],
            ),
          ),
          if (hasPrinter) ...[
            const Divider(indent: 72),
            ListTile(
              leading: const _TileIcon(Icons.receipt_long),
              title: Text(l10n.testPrint),
              enabled: state.status != PrinterStatus.testPrinting,
              onTap: () {
                final shopState = context.read<ShopBloc>().state;
                final name = shopState is ShopLoaded
                    ? shopState.shop.name
                    : l10n.shopNameFallback;
                context.read<PrinterBloc>().add(TestPrintEvent(name));
              },
            ),
          ],
        ]);
      },
    );
  }

  Future<void> _pickLanguage(AppLocalizations l10n, String current) async {
    final picked = await showDialog<String>(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: Text(l10n.language),
        children: [
          for (final code in ['system', ...supportedLanguageCodes])
            ListTile(
              leading: Icon(code == current
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked),
              title: Text(code == 'system'
                  ? l10n.languageSystem
                  : _languageNames[code]!),
              onTap: () => Navigator.pop(dialogContext, code),
            ),
        ],
      ),
    );
    if (picked != null && mounted) {
      await context.read<AppPreferencesCubit>().setLanguage(picked);
    }
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(24, 20, 24, 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
            letterSpacing: 1.1),
      ),
    );
  }
}

class _Group extends StatelessWidget {
  final List<Widget> children;
  const _Group({required this.children});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(children: children),
      ),
    );
  }
}

class _TileIcon extends StatelessWidget {
  final IconData icon;
  const _TileIcon(this.icon);

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: scheme.primaryContainer.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: scheme.onPrimaryContainer, size: 20),
    );
  }
}
