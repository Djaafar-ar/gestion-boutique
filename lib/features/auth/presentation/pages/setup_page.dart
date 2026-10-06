import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/service_locator.dart';
import '../../../../core/session/session_cubit.dart';
import '../../../../core/utils/app_validators.dart';
import '../../../../core/widgets/app_snack.dart';
import '../../../shop/domain/entities/shop.dart';
import '../../../shop/domain/repositories/shop_repository.dart';
import '../../../shop/presentation/bloc/shop_bloc.dart';
import '../../../users/domain/repositories/user_repository.dart';
import '../widgets/pin_field.dart';
import '../widgets/recovery_code_dialog.dart';

/// First launch: shop details, owner name, owner PIN (3 small steps).
/// Phones updated from Phase 1 see the same screens with their shop
/// details already filled in.
class SetupPage extends StatefulWidget {
  const SetupPage({super.key});

  @override
  State<SetupPage> createState() => _SetupPageState();
}

class _SetupPageState extends State<SetupPage> {
  static const _steps = 3;

  final _formKeys = List.generate(_steps, (_) => GlobalKey<FormState>());
  final _shopName = TextEditingController();
  final _shopPhone = TextEditingController();
  final _shopAddress = TextEditingController();
  final _ownerName = TextEditingController();
  final _ownerPhone = TextEditingController();
  final _pin = TextEditingController();
  final _pinConfirm = TextEditingController();

  Shop _existingShop = const Shop();
  int _step = 0;
  int _pinLength = 4;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    sl<ShopRepository>().getShop().then((result) {
      final shop = result.getOrElse((_) => const Shop());
      if (!mounted) return;
      setState(() {
        _existingShop = shop;
        _shopName.text = shop.name;
        _shopPhone.text = shop.phoneNumber;
        _shopAddress.text = shop.addressLine1;
      });
    });
  }

  @override
  void dispose() {
    for (final c in [
      _shopName,
      _shopPhone,
      _shopAddress,
      _ownerName,
      _ownerPhone,
      _pin,
      _pinConfirm
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _next() async {
    if (!_formKeys[_step].currentState!.validate()) return;
    if (_step < _steps - 1) {
      setState(() => _step++);
      return;
    }
    await _finish();
  }

  Future<void> _finish() async {
    final l10n = AppLocalizations.of(context);
    setState(() => _saving = true);

    final shopSaved =
        await sl<ShopRepository>().updateShop(_existingShop.copyWith(
      name: _shopName.text.trim(),
      phoneNumber: _shopPhone.text.trim(),
      addressLine1: _shopAddress.text.trim(),
    ));
    var error = shopSaved.getLeft().toNullable()?.message;
    OwnerSetup? setup;
    if (error == null) {
      final created = await sl<UserRepository>().createOwner(
        name: _ownerName.text,
        phone: _ownerPhone.text,
        pin: _pin.text,
      );
      error = created.getLeft().toNullable()?.message;
      setup = created.toNullable();
    }
    if (!mounted) return;
    setState(() => _saving = false);

    if (setup == null) {
      showAppSnack(context, l10n.errorWithDetail(error ?? ''),
          kind: SnackKind.error);
      return;
    }
    // Shown once: the owner must write it down before going on.
    await showRecoveryCode(context, setup.recoveryCode);
    if (!mounted) return;
    final owner = setup.owner;
    context.read<ShopBloc>().add(LoadShopEvent());
    // The router now opens the Sell tab.
    context.read<SessionCubit>().ownerCreated(owner);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final titles = [l10n.setupStepShop, l10n.setupStepOwner, l10n.setupStepPin];
    final isUpdate = _existingShop.name.isNotEmpty;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            LinearProgressIndicator(value: (_step + 1) / _steps),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                children: [
                  Text(l10n.setupWelcomeTitle,
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(
                      isUpdate ? l10n.setupExistingBody : l10n.setupWelcomeBody,
                      style: TextStyle(color: scheme.onSurfaceVariant)),
                  const SizedBox(height: 32),
                  Text('${_step + 1}/$_steps · ${titles[_step]}',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: scheme.primary)),
                  const SizedBox(height: 16),
                  Form(
                    key: _formKeys[_step],
                    child: switch (_step) {
                      0 => _shopStep(l10n),
                      1 => _ownerStep(l10n),
                      _ => _pinStep(l10n),
                    },
                  ),
                ],
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Row(
                  children: [
                    if (_step > 0) ...[
                      Expanded(
                        child: OutlinedButton(
                          onPressed:
                              _saving ? null : () => setState(() => _step--),
                          child: Text(l10n.previousStep),
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      flex: 2,
                      child: FilledButton(
                        onPressed: _saving ? null : _next,
                        child: _saving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2))
                            : Text(_step == _steps - 1
                                ? l10n.finishSetup
                                : l10n.nextStep),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _shopStep(AppLocalizations l10n) => Column(
        children: [
          TextFormField(
            controller: _shopName,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
                labelText: l10n.shopNameLabel, hintText: l10n.shopNameHint),
            validator: AppValidators.required(l10n.commonRequired),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _shopAddress,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
                labelText: l10n.address1Label, hintText: l10n.address1Hint),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _shopPhone,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
                labelText: l10n.phoneOptionalLabel, hintText: l10n.phoneHint),
          ),
        ],
      );

  Widget _ownerStep(AppLocalizations l10n) => Column(
        children: [
          TextFormField(
            controller: _ownerName,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
                labelText: l10n.ownerNameLabel, hintText: l10n.ownerNameHint),
            validator: AppValidators.required(l10n.commonRequired),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _ownerPhone,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
                labelText: l10n.phoneOptionalLabel, hintText: l10n.phoneHint),
          ),
        ],
      );

  Widget _pinStep(AppLocalizations l10n) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PinLengthPicker(
            value: _pinLength,
            onChanged: (length) => setState(() {
              _pinLength = length;
              _pin.clear();
              _pinConfirm.clear();
            }),
          ),
          const SizedBox(height: 16),
          PinField(
              controller: _pin,
              length: _pinLength,
              label: l10n.pinLabelN(_pinLength),
              helper: l10n.pinHelp),
          const SizedBox(height: 16),
          PinField(
            controller: _pinConfirm,
            length: _pinLength,
            label: l10n.pinConfirmLabel,
            mustMatch: () => _pin.text,
          ),
        ],
      );
}
