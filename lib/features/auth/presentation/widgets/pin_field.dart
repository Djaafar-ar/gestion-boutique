import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/security/pin_hasher.dart';

/// A hidden PIN input of [length] digits.
///
/// - [anyOwnerLength]: accept 4 or 6 digits (to type a current owner PIN),
/// - [optional]: an empty field is accepted,
/// - [mustMatch]: returns the other field's text, for "confirm".
class PinField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? helper;
  final int length;
  final bool anyOwnerLength;
  final bool optional;
  final String Function()? mustMatch;

  const PinField({
    super.key,
    required this.controller,
    required this.label,
    this.helper,
    this.length = PinHasher.workerLength,
    this.anyOwnerLength = false,
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
      maxLength: anyOwnerLength ? PinHasher.ownerLengths.last : length,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(
        labelText: label,
        helperText: helper,
        helperMaxLines: 3,
        counterText: '',
        prefixIcon: const Icon(Icons.lock_outline),
      ),
      validator: (value) {
        final pin = value ?? '';
        if (optional && pin.isEmpty) return null;
        if (anyOwnerLength) {
          final ok = PinHasher.ownerLengths
              .any((l) => PinHasher.isValidPin(pin, length: l));
          if (!ok) return l10n.pinInvalidAny;
        } else if (!PinHasher.isValidPin(pin, length: length)) {
          return l10n.pinInvalidN(length);
        }
        if (mustMatch != null && pin != mustMatch!()) return l10n.pinMismatch;
        return null;
      },
    );
  }
}

/// "4 digits / 6 digits" choice, only offered to the owner.
class PinLengthPicker extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;

  const PinLengthPicker(
      {super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.pinLengthLabel,
            style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant)),
        const SizedBox(height: 8),
        SegmentedButton<int>(
          showSelectedIcon: false,
          segments: [
            for (final length in PinHasher.ownerLengths)
              ButtonSegment(value: length, label: Text(l10n.pinDigits(length))),
          ],
          selected: {value},
          onSelectionChanged: (selection) => onChanged(selection.first),
        ),
      ],
    );
  }
}
