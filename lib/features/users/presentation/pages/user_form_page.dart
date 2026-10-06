import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/service_locator.dart';
import '../../../../core/session/session_cubit.dart';
import '../../../../core/utils/app_validators.dart';
import '../../../../core/widgets/app_snack.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../auth/presentation/widgets/pin_field.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/user_repository.dart';

/// Owner only: add a worker, or edit any account (name, phone, PIN,
/// active). The owner account can never be switched off.
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
  bool _saving = false;

  bool get _isNew => widget.user == null;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _pin.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final l10n = AppLocalizations.of(context);
    setState(() => _saving = true);

    final repo = sl<UserRepository>();
    final pin = _pin.text;
    final result = _isNew
        ? await repo.addWorker(name: _name.text, phone: _phone.text, pin: pin)
        : await repo.updateUser(
            widget.user!.copyWith(
                name: _name.text, phone: _phone.text, active: _active),
            newPin: pin.isEmpty ? null : pin,
          );
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final user = widget.user;

    return Scaffold(
      appBar: AppBar(title: Text(_isNew ? l10n.addWorker : l10n.editAccount)),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
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
            PinField(
              controller: _pin,
              label: _isNew ? l10n.pinLabel : l10n.newPinLabel,
              helper: _isNew ? null : l10n.pinKeepHint,
              optional: !_isNew,
            ),
            if (user != null && !user.isOwner) ...[
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
