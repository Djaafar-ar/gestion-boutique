import 'package:flutter/material.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/service_locator.dart';
import '../../../../core/utils/app_validators.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../data/login_service.dart';
import '../widgets/pin_field.dart';
import '../widgets/recovery_code_dialog.dart';

/// The owner types the recovery code and a new PIN. On success the page
/// closes with the owner, who is then logged in.
class RecoveryPage extends StatefulWidget {
  const RecoveryPage({super.key});

  @override
  State<RecoveryPage> createState() => _RecoveryPageState();
}

class _RecoveryPageState extends State<RecoveryPage> {
  final _formKey = GlobalKey<FormState>();
  final _code = TextEditingController();
  final _pin = TextEditingController();
  final _confirm = TextEditingController();
  int _pinLength = 4;
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _code.dispose();
    _pin.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _recover() async {
    if (!_formKey.currentState!.validate()) return;
    final l10n = AppLocalizations.of(context);
    setState(() {
      _saving = true;
      _error = null;
    });
    final result = await sl<LoginService>()
        .recoverOwner(code: _code.text, newPin: _pin.text);
    if (!mounted) return;
    setState(() => _saving = false);

    final setup = result.toNullable();
    if (setup == null) {
      final failure = result.getLeft().toNullable();
      setState(() => _error = failure is WrongSecretFailure
          ? l10n.recoveryCodeWrong
          : l10n.errorWithDetail(failure?.message ?? ''));
      return;
    }
    // The used code no longer works: show the new one once.
    await showRecoveryCode(context, setup.recoveryCode, replacedOld: true);
    if (mounted) Navigator.pop(context, setup.owner);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.recoveryTitle)),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(l10n.recoveryIntro,
                style: TextStyle(color: scheme.onSurfaceVariant)),
            const SizedBox(height: 20),
            TextFormField(
              controller: _code,
              textCapitalization: TextCapitalization.characters,
              autocorrect: false,
              decoration: InputDecoration(
                labelText: l10n.recoveryCodeLabel,
                hintText: l10n.recoveryCodeHint,
                prefixIcon: const Icon(Icons.key),
              ),
              validator: AppValidators.required(l10n.commonRequired),
            ),
            const SizedBox(height: 20),
            PinLengthPicker(
              value: _pinLength,
              onChanged: (length) => setState(() {
                _pinLength = length;
                _pin.clear();
                _confirm.clear();
              }),
            ),
            const SizedBox(height: 16),
            PinField(
                controller: _pin,
                length: _pinLength,
                label: l10n.newPinLabelN(_pinLength)),
            const SizedBox(height: 16),
            PinField(
              controller: _confirm,
              length: _pinLength,
              label: l10n.pinConfirmLabel,
              mustMatch: () => _pin.text,
            ),
            if (_error != null) ...[
              const SizedBox(height: 16),
              Text(_error!, style: TextStyle(color: scheme.error)),
            ],
          ],
        ),
      ),
      bottomNavigationBar: PrimaryButton(
        onPressed: _recover,
        isLoading: _saving,
        icon: Icons.lock_open,
        label: l10n.recoveryTitle,
      ),
    );
  }
}
