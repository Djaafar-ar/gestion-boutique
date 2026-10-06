import 'package:flutter/material.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/service_locator.dart';
import '../../../users/domain/entities/app_user.dart';
import '../../../users/domain/repositories/user_repository.dart';
import '../../data/login_service.dart';
import 'pin_field.dart';

/// The owner types their PIN on a worker's screen to allow something.
/// Returns the PIN once it is right, or null if cancelled.
///
/// Wrong PINs follow the login rules: they are recorded, and too many
/// make the owner wait or lock the account.
Future<String?> askOwnerApproval(BuildContext context) async {
  final users = (await sl<UserRepository>().getUsers()).getOrElse((_) => []);
  final owner = users.where((u) => u.isOwner).firstOrNull;
  if (owner == null || !context.mounted) return null;
  return showDialog<String>(
    context: context,
    builder: (_) => _OwnerApprovalDialog(owner: owner),
  );
}

class _OwnerApprovalDialog extends StatefulWidget {
  final AppUser owner;
  const _OwnerApprovalDialog({required this.owner});

  @override
  State<_OwnerApprovalDialog> createState() => _OwnerApprovalDialogState();
}

class _OwnerApprovalDialogState extends State<_OwnerApprovalDialog> {
  final _formKey = GlobalKey<FormState>();
  final _pin = TextEditingController();
  String? _error;
  bool _checking = false;

  @override
  void dispose() {
    _pin.dispose();
    super.dispose();
  }

  Future<void> _check() async {
    if (!_formKey.currentState!.validate()) return;
    final l10n = AppLocalizations.of(context);
    setState(() => _checking = true);
    final result = await sl<LoginService>().tryPin(widget.owner.id, _pin.text);
    if (!mounted) return;
    setState(() => _checking = false);
    switch (result) {
      case LoginSuccess():
        Navigator.pop(context, _pin.text);
      case LoginWrongPin(:final triesLeft):
        setState(() => _error = l10n.loginWrongPin(triesLeft));
        _pin.clear();
      case LoginMustWait(:final wait):
        final seconds = wait.inSeconds + 1;
        setState(() => _error = l10n.loginWait(
            '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}'));
      case LoginLockedOut():
        setState(() => _error = l10n.loginLockedOwner);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.ownerApprovalTitle),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.ownerApprovalBody(widget.owner.name)),
            const SizedBox(height: 12),
            PinField(
              controller: _pin,
              length: widget.owner.pinLength,
              label: l10n.loginEnterPin,
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(_error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.commonCancel)),
        FilledButton(
          style: FilledButton.styleFrom(minimumSize: const Size(88, 40)),
          onPressed: _checking ? null : _check,
          child: Text(l10n.continueLabel),
        ),
      ],
    );
  }
}
