import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart' show Either;
import 'package:go_router/go_router.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/service_locator.dart';
import '../../../../core/session/session_cubit.dart';
import '../../../../core/utils/app_validators.dart';
import '../../../../core/widgets/app_snack.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../auth/data/login_service.dart';
import '../../../auth/presentation/widgets/pin_field.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/user_repository.dart';

/// Owner only: add a worker, or edit an account.
///
/// - A worker's PIN can be reset here (it also unlocks the account), but
///   never shown.
/// - The owner's own PIN is changed from the profile, with the current PIN.
/// - The owner account can never be switched off.
class UserFormPage extends StatefulWidget {
  /// Null to add a new worker.
  final AppUser? user;

  const UserFormPage({super.key, this.user});

  @override
  State<UserFormPage> createState() => _UserFormPageState();
}

class _UserFormPageState extends State<UserFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.user?.name);
  late final _phone = TextEditingController(text: widget.user?.phone);
  final _pin = TextEditingController();
  late bool _active = widget.user?.active ?? true;
  late bool _locked = widget.user?.lockedOut ?? false;
  bool _saving = false;

  bool get _isNew => widget.user == null;
  bool get _isWorker => widget.user == null || !widget.user!.isOwner;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _pin.dispose();
    super.dispose();
  }

  String get _actorId => context.read<SessionCubit>().userId!;

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final l10n = AppLocalizations.of(context);
    setState(() => _saving = true);

    final repo = sl<UserRepository>();
    final pin = _pin.text;
    Either<Failure, AppUser> result;
    if (_isNew) {
      result = await repo.addWorker(
          actorId: _actorId, name: _name.text, phone: _phone.text, pin: pin);
    } else {
      result = await repo.updateUser(
          actorId: _actorId,
          user: widget.user!
              .copyWith(name: _name.text, phone: _phone.text, active: _active));
      if (result.isRight() && _isWorker && pin.isNotEmpty) {
        result = await sl<LoginService>().resetWorkerPin(
            actorId: _actorId, workerId: widget.user!.id, newPin: pin);
      }
    }
    if (!mounted) return;
    setState(() => _saving = false);

    result.fold(
      (failure) => showAppSnack(context, l10n.errorWithDetail(failure.message),
          kind: SnackKind.error),
      (user) {
        context.read<SessionCubit>().userUpdated(user);
        showAppSnack(context, l10n.accountSaved, kind: SnackKind.success);
        context.pop();
      },
    );
  }

  Future<void> _unlock() async {
    final l10n = AppLocalizations.of(context);
    final result = await sl<LoginService>()
        .unlockWorker(actorId: _actorId, workerId: widget.user!.id);
    if (!mounted) return;
    result.fold(
      (failure) => showAppSnack(context, l10n.errorWithDetail(failure.message),
          kind: SnackKind.error),
      (_) {
        setState(() => _locked = false);
        showAppSnack(context, l10n.accountUnlocked, kind: SnackKind.success);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(_isNew ? l10n.addWorker : l10n.editAccount)),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            if (_locked) ...[
              Card(
                color: scheme.errorContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.lock, color: scheme.onErrorContainer),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(l10n.lockedWorkerCard,
                                style:
                                    TextStyle(color: scheme.onErrorContainer)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      FilledButton.icon(
                        onPressed: _unlock,
                        icon: const Icon(Icons.lock_open),
                        label: Text(l10n.unlockAccount),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            TextFormField(
              controller: _name,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                  labelText: l10n.nameLabel, hintText: l10n.workerNameHint),
              validator: AppValidators.required(l10n.commonRequired),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phone,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                  labelText: l10n.phoneOptionalLabel, hintText: l10n.phoneHint),
            ),
            const SizedBox(height: 16),
            if (_isWorker)
              PinField(
                controller: _pin,
                label: _isNew ? l10n.pinLabel : l10n.resetPinLabel,
                helper: _isNew ? null : l10n.pinKeepHint,
                optional: !_isNew,
              )
            else
              Text(l10n.ownerPinFromProfile,
                  style: TextStyle(color: scheme.onSurfaceVariant)),
            if (!_isNew && _isWorker) ...[
              const SizedBox(height: 16),
              Card(
                child: SwitchListTile(
                  title: Text(l10n.activeLabel),
                  subtitle: Text(l10n.activeHelp),
                  value: _active,
                  onChanged: (value) => setState(() => _active = value),
                ),
              ),
            ],
          ],
        ),
      ),
      bottomNavigationBar: PrimaryButton(
        onPressed: _save,
        isLoading: _saving,
        icon: Icons.save,
        label: l10n.commonSave,
      ),
    );
  }
}
