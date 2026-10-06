import 'package:intl/intl.dart';

import '../../features/billing/domain/entities/sale.dart';
import '../../features/shop/domain/entities/shop.dart';
import '../utils/money.dart';

/// Characters per line on a 58mm thermal printer with the normal font.
const receiptWidth = 32;

/// Characters per line when the text is printed double size.
const receiptLargeWidth = 16;

/// Everything printed on a receipt. Receipts are always in French.
class ReceiptData {
  final String shopName;
  final String address1;
  final String address2;
  final String phone;
  final String footer;
  final int saleNumber;
  final DateTime date;
  final List<SaleLine> lines;
  final int subtotal;
  final int discount;
  final int total;

  const ReceiptData({
    required this.shopName,
    required this.address1,
    required this.address2,
    required this.phone,
    required this.footer,
    required this.saleNumber,
    required this.date,
    required this.lines,
    required this.subtotal,
    required this.discount,
    required this.total,
  });

  factory ReceiptData.fromSale(Sale sale, Shop shop) => ReceiptData(
        shopName: shop.name,
        address1: shop.addressLine1,
        address2: shop.addressLine2,
        phone: shop.phoneNumber,
        footer: shop.footerText,
        saleNumber: sale.number,
        date: sale.createdAt,
        lines: sale.items,
        subtotal: sale.subtotal,
        discount: sale.discount,
        total: sale.total,
      );
}

/// The lines under the shop name, each exactly fitting [receiptWidth].
/// The shop name itself is printed large by the printer code.
///
/// With [asciiOnly] (the default) accents are removed first, because most
/// printers print them as strange symbols.
List<String> buildReceiptBody(ReceiptData data, {bool asciiOnly = true}) {
  String p(String text) => asciiOnly ? toPrinterAscii(text) : text;
  final out = <String>[];
  final dashes = '-' * receiptWidth;

  for (final text in [data.address1, data.address2]) {
    if (text.trim().isNotEmpty) out.addAll(_centered(p(text)));
  }
  if (data.phone.trim().isNotEmpty) {
    out.addAll(_centered(p('Tél : ${data.phone}')));
  }
  out.addAll(
      _centered(DateFormat('dd/MM/yyyy HH:mm', 'en_US').format(data.date)));
  out.addAll(
      _centered(p('Ticket n° ${data.saleNumber.toString().padLeft(4, '0')}')));

  out.add(dashes);
  out.add(_leftRight('Article', 'Montant'));
  out.add(dashes);

  for (final line in data.lines) {
    out.addAll(wrapText(p(line.productName), receiptWidth));
    out.addAll(_amountRow('  ${line.quantity} x ${formatDA(line.sellPrice)}',
        formatDA(line.total)));
  }

  out.add(dashes);
  if (data.discount > 0) {
    out.addAll(_amountRow('Sous-total', formatDA(data.subtotal)));
    out.addAll(_amountRow('Remise', formatDA(-data.discount)));
  }
  out.addAll(_amountRow('TOTAL', formatDA(data.total)));
  out.add(dashes);

  if (data.footer.trim().isNotEmpty) out.addAll(_centered(p(data.footer)));
  return out;
}

/// Splits [text] into lines of at most [width] characters, breaking
/// between words when possible. A word longer than a line is cut.
List<String> wrapText(String text, int width) {
  final lines = <String>[];
  var current = '';
  for (var word in text.trim().split(RegExp(r'\s+'))) {
    if (word.isEmpty) continue;
    while (word.length > width) {
      if (current.isNotEmpty) {
        lines.add(current);
        current = '';
      }
      lines.add(word.substring(0, width));
      word = word.substring(width);
    }
    if (current.isEmpty) {
      current = word;
    } else if (current.length + 1 + word.length <= width) {
      current = '$current $word';
    } else {
      lines.add(current);
      current = word;
    }
  }
  if (current.isNotEmpty) lines.add(current);
  return lines;
}

List<String> _centered(String text) => wrapText(text, receiptWidth).map((l) {
      final left = (receiptWidth - l.length) ~/ 2;
      return (' ' * left + l).padRight(receiptWidth);
    }).toList();

String _leftRight(String left, String right) =>
    left + right.padLeft(receiptWidth - left.length);

/// A label on the left and an amount on the right. When both do not fit
/// on one line, the amount goes on its own line, still right-aligned.
List<String> _amountRow(String left, String amount) {
  if (left.length + 1 + amount.length <= receiptWidth) {
    return [_leftRight(left, amount)];
  }
  return [left.padRight(receiptWidth), amount.padLeft(receiptWidth)];
}

/// Most cheap printers only know plain ASCII by default, so accents are
/// removed: "Café crème" -> "Cafe creme".
String toPrinterAscii(String text) {
  const map = {
    'à': 'a',
    'â': 'a',
    'ä': 'a',
    'á': 'a',
    'ç': 'c',
    'é': 'e',
    'è': 'e',
    'ê': 'e',
    'ë': 'e',
    'î': 'i',
    'ï': 'i',
    'í': 'i',
    'ô': 'o',
    'ö': 'o',
    'ó': 'o',
    'ù': 'u',
    'û': 'u',
    'ü': 'u',
    'ú': 'u',
    'ÿ': 'y',
    'ñ': 'n',
    'À': 'A',
    'Â': 'A',
    'Ä': 'A',
    'Á': 'A',
    'Ç': 'C',
    'É': 'E',
    'È': 'E',
    'Ê': 'E',
    'Ë': 'E',
    'Î': 'I',
    'Ï': 'I',
    'Í': 'I',
    'Ô': 'O',
    'Ö': 'O',
    'Ó': 'O',
    'Ù': 'U',
    'Û': 'U',
    'Ü': 'U',
    'Ú': 'U',
    'Ñ': 'N',
    'œ': 'oe',
    'Œ': 'OE',
    'æ': 'ae',
    'Æ': 'AE',
    '°': 'o',
    '’': "'",
    '‘': "'",
    '«': '"',
    '»': '"',
    '“': '"',
    '”': '"',
    '–': '-',
    '—': '-',
    '€': 'EUR',
  };
  final buffer = StringBuffer();
  for (final rune in text.runes) {
    final char = String.fromCharCode(rune);
    final replacement = map[char];
    if (replacement != null) {
      buffer.write(replacement);
    } else if (rune < 128) {
      buffer.write(char);
    } else {
      buffer.write('?');
    }
  }
  return buffer.toString();
}
