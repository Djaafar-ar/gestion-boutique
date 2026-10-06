// Money is always handled as whole centimes (int): 12,50 DA == 1250.
// Doubles are never used for money, so totals never drift by 0,01 DA.

/// Formats centimes the Algerian way: `125000` -> `1 250,00 DA`.
///
/// Uses plain spaces so the same text also works on the thermal printer.
/// Set [withSymbol] to false to get only `1 250,00`.
String formatDA(int centimes, {bool withSymbol = true}) {
  final negative = centimes < 0;
  final abs = centimes.abs();
  final whole = (abs ~/ 100).toString();
  final cents = (abs % 100).toString().padLeft(2, '0');

  final grouped = StringBuffer();
  for (var i = 0; i < whole.length; i++) {
    if (i > 0 && (whole.length - i) % 3 == 0) grouped.write(' ');
    grouped.write(whole[i]);
  }

  final amount = '${negative ? '-' : ''}$grouped,$cents';
  return withSymbol ? '$amount DA' : amount;
}

/// Same as [formatDA] but safe inside Arabic (right-to-left) text: the
/// amount is kept left-to-right so `1 250,00 DA` never shows up reversed.
String formatDAForUi(int centimes) =>
    '${String.fromCharCode(_ltrIsolate)}${formatDA(centimes)}'
    '${String.fromCharCode(_popIsolate)}';

const _ltrIsolate = 0x2066; // LEFT-TO-RIGHT ISOLATE
const _popIsolate = 0x2069; // POP DIRECTIONAL ISOLATE

/// Reads a price typed by a person into centimes.
///
/// Accepts `1250`, `1250,5`, `1 250,50`, `1250.50` or `1 250,50 DA`.
/// Returns null when the text is not a number.
int? parseDA(String? text) {
  if (text == null) return null;
  var cleaned = text
      .replaceAll(RegExp(r'da', caseSensitive: false), '')
      .replaceAll(RegExp(r'[\s  ]'), '')
      .replaceAll(',', '.');
  if (cleaned.isEmpty) return null;
  // Only one decimal separator is allowed.
  if ('.'.allMatches(cleaned).length > 1) return null;
  if (!RegExp(r'^-?\d*\.?\d{0,2}$').hasMatch(cleaned)) return null;
  if (cleaned == '-' || cleaned == '.' || cleaned == '-.') return null;
  if (cleaned.startsWith('.')) cleaned = '0$cleaned';
  final value = double.tryParse(cleaned);
  if (value == null) return null;
  return (value * 100).round();
}

/// Turns centimes back into text for an input field: `125050` -> `1250,50`.
String centimesToInput(int centimes) =>
    formatDA(centimes, withSymbol: false).replaceAll(' ', '');
