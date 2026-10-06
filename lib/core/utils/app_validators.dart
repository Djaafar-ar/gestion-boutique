import 'package:flutter/widgets.dart';

import '../l10n/app_localizations.dart';
import 'money.dart';

class AppValidators {
  static FormFieldValidator<String> required(String message) {
    return (String? value) {
      if (value == null || value.trim().isEmpty) {
        return message;
      }
      return null;
    };
  }

  /// Checks a price typed in DA, such as `1250` or `1 250,50`.
  static FormFieldValidator<String> price(AppLocalizations l10n) {
    return (String? value) {
      if (value == null || value.trim().isEmpty) return l10n.priceRequired;
      final centimes = parseDA(value);
      if (centimes == null) return l10n.priceInvalid;
      if (centimes < 0) return l10n.priceNegative;
      return null;
    };
  }
}
