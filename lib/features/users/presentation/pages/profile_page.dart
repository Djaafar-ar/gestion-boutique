import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/service_locator.dart';
import '../../../../core/session/session_cubit.dart';
import '../../../../core/utils/date_format.dart';
import '../../../../core/utils/money.dart';
import '../../../../core/widgets/app_snack.dart';
import '../../../auth/presentation/widgets/pin_field.dart';
import '../../../auth/presentation/widgets/recovery_code_dialog.dart';
import '../../../billing/domain/entities/sale.dart';
import '../../../billing/domain/repositories/sale_repository.dart';
import '../../../billing/presentation/bloc/billing_bloc.dart';
import '../../../stock/domain/entities/loss.dart';
import '../../../stock/domain/repositories/stock_repository.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/user_repository.dart';
import '../widgets/user_avatar.dart';

enum _Period { today, week, month }

/// The logged-in person's own figures, PIN change and "switch user".
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  _Period _period = _Period.today;
  late Future<(SalesSummary, LossSummary)> _summary;

  @override
  void initState() {
    super.initState();
    _summary = _load();
  }

  Future<(SalesSummary, LossSummary)> _load() async {
    final now = DateTime.now();
    final from = switch (_period) {
      _Period.today => startOfDay(now),
      _Period.week => startOfWeek(now),
      _Period.month => startOfMonth(now),
    };
    final userId = context.read<SessionCubit>().userId;
    final sales =
        await sl<SaleRepository>().getSummary(from: from, userId: userId);
    final losses =
        await sl<StockRepository>().getLossSummary(from: from, userId: userId);
    return (
      sales.getOrElse((_) => SalesSummary.empty),
      losses.getOrElse((_) => LossSummary.empty),
    );
  }

  void _switchUser() {
    // The next person starts with an empty cart.
    context.read<BillingBloc>().add(ClearCartEvent());
    context.read<SessionCubit>().logout();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final user = context.watch<SessionCubit>().state.user;
    if (user == null) return const Scaffold();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.myProfile)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          Center(child: UserAvatar(user: user, radius: 40)),
          const SizedBox(height: 12),
          Text(user.name,
              textAlign: TextAlign.center,
              style:
                  const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Text(user.isOwner ? l10n.roleOwner : l10n.roleWorker,
              textAlign: TextAlign.center,
              style: TextStyle(color: scheme.onSurfaceVariant)),
          const SizedBox(height: 24),
          Text(l10n.myStatsTitle,
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: scheme.primary)),
          const SizedBox(height: 8),
          SegmentedButton<_Period>(
            showSelectedIcon: false,
            segments: [
              ButtonSegment(value: _Period.today, label: Text(l10n.today)),
              ButtonSegment(value: _Period.week, label: Text(l10n.periodWeek)),
              ButtonSegment(
                  value: _Period.month, label: Text(l10n.periodMonth)),
            ],
            selected: {_period},
            onSelectionChanged: (selection) => setState(() {
              _period = selection.first;
              _summary = _load();
            }),
          ),
          const SizedBox(height: 12),
          FutureBuilder<(SalesSummary, LossSummary)>(
            future: _summary,
            builder: (context, snapshot) {
              final summary = snapshot.data?.$1;
              final losses = snapshot.data?.$2;
              String show(String Function(SalesSummary s) value) =>
                  summary == null ? '…' : value(summary);
              return GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 1.6,
                children: [
                  _StatTile(
                      icon: Icons.payments_outlined,
                      label: l10n.statRevenue,
                      value: show((s) => formatDAForUi(s.revenue))),
                  _StatTile(
                      icon: Icons.receipt_long_outlined,
                      label: l10n.statSales,
                      value: show((s) => '${s.salesCount}')),
                  _StatTile(
                      icon: Icons.shopping_basket_outlined,
                      label: l10n.statItems,
                      value: show((s) => '${s.itemsSold}')),
                  _StatTile(
                      icon: Icons.report_gmailerrorred_outlined,
                      label: l10n.statLosses,
                      value: losses == null ? '…' : '${losses.count}',
                      note: losses == null || losses.value == 0
                          ? null
                          : formatDAForUi(losses.value)),
                ],
              );
            },
          ),
          const SizedBox(height: 24),
          Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.password),
                  title: Text(l10n.changePin),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _changePin(user),
                ),
                if (user.isOwner) ...[
                  const Divider(indent: 56),
                  _RecoveryCodeTile(owner: user),
                ],
                const Divider(indent: 56),
                ListTile(
                  leading: const Icon(Icons.switch_account_outlined),
                  title: Text(l10n.switchUser),
                  subtitle: Text(l10n.switchUserSub),
                  onTap: _switchUser,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _changePin(AppUser user) async {
    final l10n = AppLocalizations.of(context);
    final changed = await showDialog<bool>(
      context: context,
      builder: (_) => _ChangePinDialog(user: user),
    );
    if (changed == true && mounted) {
      showAppSnack(context, l10n.pinChanged, kind: SnackKind.success);
    }
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String? note;

  const _StatTile(
      {required this.icon,
      required this.label,
      required this.value,
      this.note});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: scheme.primary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 12, color: scheme.onSurfaceVariant)),
                ),
              ],
            ),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: AlignmentDirectional.centerStart,
              child: Text(value,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            if (note != null)
              Text(note!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style:
                      TextStyle(fontSize: 10, color: scheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}

/// Asks for the current PIN, then the new one twice. Only ever changes
/// the logged-in person's own PIN.
class _ChangePinDialog extends StatefulWidget {
  final AppUser user;
  const _ChangePinDialog({required this.user});

  @override
  State<_ChangePinDialog> createState() => _ChangePinDialogState();
}

class _ChangePinDialogState extends State<_ChangePinDialog> {
  final _formKey = GlobalKey<FormState>();
  final _current = TextEditingController();
  final _pin = TextEditingController();
  final _confirm = TextEditingController();
  late int _length = widget.user.pinLength;
  String? _error;

  @override
  void dispose() {
    _current.dispose();
    _pin.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final l10n = AppLocalizations.of(context);
    final result = await sl<UserRepository>().changeOwnPin(
        userId: widget.user.id, currentPin: _current.text, newPin: _pin.text);
    if (!mounted) return;
    result.fold(
      (failure) => setState(() => _error = failure is WrongSecretFailure
          ? l10n.currentPinWrong
          : l10n.errorWithDetail(failure.message)),
      (user) {
        // The PIN length may have changed: keep the session up to date.
        context.read<SessionCubit>().userUpdated(user);
        Navigator.pop(context, true);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.changePin),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PinField(
                  controller: _current,
                  length: widget.user.pinLength,
                  label: l10n.currentPinLabel),
              const SizedBox(height: 12),
              if (widget.user.isOwner) ...[
                PinLengthPicker(
                  value: _length,
                  onChanged: (length) => setState(() {
                    _length = length;
                    _pin.clear();
                    _confirm.clear();
                  }),
                ),
                const SizedBox(height: 12),
              ],
              PinField(
                  controller: _pin,
                  length: _length,
                  label: l10n.newPinLabelN(_length)),
              const SizedBox(height: 12),
              PinField(
                controller: _confirm,
                length: _length,
                label: l10n.pinConfirmLabel,
                mustMatch: () => _pin.text,
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!,
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.error)),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(l10n.commonCancel),
        ),
        FilledButton(
          style: FilledButton.styleFrom(minimumSize: const Size(88, 40)),
          onPressed: _save,
          child: Text(l10n.commonSave),
        ),
      ],
    );
  }
}

/// Owner only: says whether a recovery code exists and makes a new one
/// after checking the current PIN.
class _RecoveryCodeTile extends StatefulWidget {
  final AppUser owner;
  const _RecoveryCodeTile({required this.owner});

  @override
  State<_RecoveryCodeTile> createState() => _RecoveryCodeTileState();
}

class _RecoveryCodeTileState extends State<_RecoveryCodeTile> {
  late Future<bool> _hasCode = sl<UserRepository>().ownerHasRecoveryCode();

  Future<void> _create() async {
    final l10n = AppLocalizations.of(context);
    final pin = await _askPin(l10n);
    if (pin == null || !mounted) return;
    final result = await sl<UserRepository>()
        .createRecoveryCode(ownerId: widget.owner.id, currentPin: pin);
    if (!mounted) return;
    await result.fold(
      (failure) async => showAppSnack(
          context,
          failure is WrongSecretFailure
              ? l10n.currentPinWrong
              : l10n.errorWithDetail(failure.message),
          kind: SnackKind.error),
      (code) => showRecoveryCode(context, code),
    );
    if (mounted) {
      setState(() {
        _hasCode = sl<UserRepository>().ownerHasRecoveryCode();
      });
    }
  }

  Future<String?> _askPin(AppLocalizations l10n) {
    return showDialog<String>(
      context: context,
      builder: (_) => _AskPinDialog(
          title: l10n.recoveryTile, pinLength: widget.owner.pinLength),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return FutureBuilder<bool>(
      future: _hasCode,
      builder: (context, snapshot) {
        final missing = snapshot.data == false;
        return ListTile(
          leading: Icon(Icons.key, color: missing ? scheme.error : null),
          title: Text(l10n.recoveryTile),
          subtitle: Text(missing ? l10n.recoveryMissing : l10n.recoveryExists,
              style: missing ? TextStyle(color: scheme.error) : null),
          trailing: const Icon(Icons.chevron_right),
          onTap: _create,
        );
      },
    );
  }
}

/// Asks for the current PIN. The dialog owns its controller, so it is only
/// thrown away after the closing animation (disposing it earlier crashes).
class _AskPinDialog extends StatefulWidget {
  final String title;
  final int pinLength;
  const _AskPinDialog({required this.title, required this.pinLength});

  @override
  State<_AskPinDialog> createState() => _AskPinDialogState();
}

class _AskPinDialogState extends State<_AskPinDialog> {
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(widget.title),
      content: Form(
        key: _formKey,
        child: PinField(
          controller: _controller,
          length: widget.pinLength,
          label: l10n.confirmWithPin,
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.commonCancel)),
        FilledButton(
          style: FilledButton.styleFrom(minimumSize: const Size(88, 40)),
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.pop(context, _controller.text);
            }
          },
          child: Text(l10n.continueLabel),
        ),
      ],
    );
  }
}
