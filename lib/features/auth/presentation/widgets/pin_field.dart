import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/security/pin_hasher.dart';

/// A hidden 4-digit PIN input.
///
/// When [optional] is true an empty field is accepted (used to keep the
/// current PIN). [mustMatch] returns the other field's text for "confirm".
class PinField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? helper;
  final bool optional;
  final String Function()? mustMatch;

  const PinField({
    super.key,
    required this.controller,
    required this.label,
    this.helper,
    this.optional = false,
    this.mustMatch,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return TextFormField(
      controller: controller,
      obscureText: true,
      keyboardType: TextInputType.number,
      maxLength: 4,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(
        labelText: label,
        helperText: helper,
        helperMaxLines: 2,
        counterText: '',
        prefixIcon: const Icon(Icons.lock_outline),
      ),
      validator: (value) {
        final pin = value ?? '';
        if (optional && pin.isEmpty) return null;
        if (!PinHasher.isValidPin(pin)) return l10n.pinInvalid;
        if (mustMatch != null && pin != mustMatch!()) return l10n.pinMismatch;
        return null;
      },
    );
  }
}
