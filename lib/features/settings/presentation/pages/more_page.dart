import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:app_settings/app_settings.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/service_locator.dart';
import '../../../../core/session/session_cubit.dart';
import '../../../../core/widgets/app_snack.dart';
import '../../../billing/presentation/bloc/billing_bloc.dart';
import '../../../sheet/presentation/sheet_cubit.dart';
import '../../../suppliers/domain/repositories/supplier_repository.dart';
import '../../../users/domain/repositories/user_repository.dart';
import '../../../users/presentation/widgets/user_avatar.dart';
import '../../../shop/presentation/bloc/shop_bloc.dart';
import '../bloc/printer_bloc.dart';
import '../bloc/printer_event.dart';
import '../bloc/printer_state.dart';
import '../cubit/app_preferences_cubit.dart';

/// The "More" tab: profile, shop and team (owner), language, theme,
/// printer and switching user.
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

  /// Whether the owner has made a recovery code (null for workers).
  Future<bool>? _hasRecoveryCode;

  /// Supplier payments waiting for the owner (null for workers).
  Future<int>? _pendingPayments;

  @override
  void initState() {
    super.initState();
    // Re-read the saved printer whenever this page opens
    context.read<PrinterBloc>().add(InitPrinterEvent());
    _checkRecoveryCode();
    _countPending();
  }

  void _countPending() {
    _pendingPayments = context.read<SessionCubit>().state.isOwner
        ? sl<SupplierRepository>().pendingCount()
        : null;
  }

  /// Opens a page, then counts the payments to validate again.
  Future<void> _open(String location) async {
    await context.push(location);
    if (mounted) setState(_countPending);
  }

  void _checkRecoveryCode() {
    _hasRecoveryCode = context.read<SessionCubit>().state.isOwner
        ? sl<UserRepository>().ownerHasRecoveryCode()
        : null;
  }

  /// Opens the profile, then checks again for the recovery code.
  Future<void> _openProfile() async {
    await context.push('/more/profile');
    if (mounted) setState(_checkRecoveryCode);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final prefs = context.watch<AppPreferencesCubit>().state;
    final session = context.watch<SessionCubit>().state;
    final user = session.user;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.moreTitle)),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          _buildShopHeader(l10n),
          if (user != null)
            _Group(children: [
              ListTile(
                leading: UserAvatar(user: user),
                title: Text(user.name,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(
                    '${l10n.myProfile} · ${user.isOwner ? l10n.roleOwner : l10n.roleWorker}'),
                trailing: const Icon(Icons.chevron_right),
                onTap: _openProfile,
              ),
            ]),
          // No backup left the phone for 7 days.
          if (session.isOwner &&
              context.select((SheetCubit c) => c.state.backupWarning))
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Card(
                color: Theme.of(context).colorScheme.errorContainer,
                child: ListTile(
                  leading: Icon(Icons.backup_outlined,
                      color: Theme.of(context).colorScheme.onErrorContainer),
                  title: Text(l10n.backupWarning,
                      style: TextStyle(
                          color: Theme.of(context)
                              .colorScheme
                              .onErrorContainer)),
                  trailing: Icon(Icons.chevron_right,
                      color: Theme.of(context).colorScheme.onErrorContainer),
                  onTap: () => context.push('/more/backup'),
                ),
              ),
            ),
          if (_hasRecoveryCode != null)
            FutureBuilder<bool>(
              future: _hasRecoveryCode,
              builder: (context, snapshot) {
                if (snapshot.data != false) return const SizedBox.shrink();
                final scheme = Theme.of(context).colorScheme;
                return Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Card(
                    color: scheme.errorContainer,
                    child: ListTile(
                      leading: Icon(Icons.key, color: scheme.onErrorContainer),
                      title: Text(l10n.recoveryMissingBanner,
                          style: TextStyle(color: scheme.onErrorContainer)),
                      trailing: Icon(Icons.chevron_right,
                          color: scheme.onErrorContainer),
                      onTap: _openProfile,
                    ),
                  ),
                );
              },
            ),
          _SectionHeader(l10n.syncTitle),
          _Group(children: [
            ListTile(
              leading: const _TileIcon(Icons.wifi_tethering),
              title: Text(l10n.syncTitle),
              subtitle: Text(l10n.syncSub),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/more/sync'),
            ),
            const Divider(indent: 72),
            ListTile(
              leading: const _TileIcon(Icons.table_chart_outlined),
              title: Text(l10n.sheetTitle),
              subtitle: Text(l10n.sheetSub),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/more/sheet'),
            ),
          ]),
          _SectionHeader(l10n.creditSection),
          _Group(children: [
            ListTile(
              leading: const _TileIcon(Icons.menu_book_outlined),
              title: Text(l10n.customersTitle),
              subtitle: Text(l10n.customersSub),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _open('/customers'),
            ),
            const Divider(indent: 72),
            ListTile(
              leading: const _TileIcon(Icons.local_shipping_outlined),
              title: Text(l10n.suppliersTitle),
              subtitle: Text(l10n.suppliersSub),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _open('/suppliers'),
            ),
            if (_pendingPayments != null) ...[
              const Divider(indent: 72),
              FutureBuilder<int>(
                future: _pendingPayments,
                builder: (context, snapshot) {
                  final count = snapshot.data ?? 0;
                  return ListTile(
                    leading: const _TileIcon(Icons.fact_check_outlined),
                    title: Text(l10n.pendingPaymentsTitle),
                    subtitle: Text(l10n.pendingPaymentsSub(count)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (count > 0) Badge(label: Text('$count')),
                        const Icon(Icons.chevron_right),
                      ],
                    ),
                    onTap: () => _open('/payments'),
                  );
                },
              ),
            ],
          ]),
          // Shop details and the team are managed by the owner only.
          if (session.isOwner) ...[
            _SectionHeader(l10n.sectionShop),
            _Group(children: [
              ListTile(
                leading: const _TileIcon(Icons.storefront),
                title: Text(l10n.shopDetails),
                subtitle: Text(l10n.shopDetailsSub),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/more/shop'),
              ),
              const Divider(indent: 72),
              ListTile(
                leading: const _TileIcon(Icons.backup_outlined),
                title: Text(l10n.backupTitle),
                subtitle: Text(l10n.backupSub),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/more/backup'),
              ),
            ]),
            _SectionHeader(l10n.teamSection),
            _Group(children: [
              ListTile(
                leading: const _TileIcon(Icons.groups_outlined),
                title: Text(l10n.workersTitle),
                subtitle: Text(l10n.workersSub),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/more/workers'),
              ),
            ]),
            _SectionHeader(l10n.alertsTitle),
            _Group(children: [
              ListTile(
                leading: const _TileIcon(Icons.notifications_active_outlined),
                title: Text(l10n.notificationsTitle),
                subtitle: Text(l10n.notificationsSub),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/more/notifications'),
              ),
            ]),
            _SectionHeader(l10n.securitySection),
            _Group(children: [
              ListTile(
                leading: const _TileIcon(Icons.shield_outlined),
                title: Text(l10n.failedLoginsTitle),
                subtitle: Text(l10n.failedLoginsSub),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/more/security'),
              ),
            ]),
          ],
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
          _Group(children: [
            ListTile(
              leading: const _TileIcon(Icons.switch_account_outlined),
              title: Text(l10n.switchUser),
              subtitle: Text(l10n.switchUserSub),
              onTap: () {
                // The next person starts with an empty cart.
                context.read<BillingBloc>().add(ClearCartEvent());
                context.read<SessionCubit>().logout();
              },
            ),
          ]),
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
