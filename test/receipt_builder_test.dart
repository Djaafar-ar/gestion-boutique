import 'package:billing_app/core/printing/receipt_builder.dart';
import 'package:billing_app/features/billing/domain/entities/sale.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  ReceiptData receipt({
    List<SaleLine>? lines,
    int discount = 0,
    String footer = 'Merci, à bientôt !',
  }) {
    final items = lines ??
        const [
          SaleLine(
              productId: '1',
              productName: 'Hamoud Boualem 33cl',
              sellPrice: 6000,
              unitCost: 4500,
              quantity: 2),
        ];
    final subtotal = items.fold<int>(0, (sum, l) => sum + l.total);
    return ReceiptData(
      shopName: 'Épicerie El Baraka',
      address1: 'Rue 5, Bab Ezzouar',
      address2: '',
      phone: '0555 12 34 56',
      footer: footer,
      saleNumber: 42,
      date: DateTime(2026, 10, 6, 14, 32),
      lines: items,
      subtotal: subtotal,
      discount: discount,
      total: subtotal - discount,
    );
  }

  test('every line fits the 58mm paper (32 characters)', () {
    final lines = buildReceiptBody(receipt(lines: const [
      SaleLine(
          productId: '1',
          productName: "Jus d'orange Rouiba 1L avec pulpe et vitamines",
          sellPrice: 1234567,
          unitCost: 0,
          quantity: 12),
    ]));

    for (final line in lines) {
      expect(line.length, lessThanOrEqualTo(receiptWidth), reason: line);
    }
  });

  test('a long product name wraps instead of being cut', () {
    final lines = buildReceiptBody(receipt(lines: const [
      SaleLine(
          productId: '1',
          productName: "Jus d'orange Rouiba 1L avec pulpe",
          sellPrice: 18000,
          unitCost: 0,
          quantity: 2),
    ]));

    final text = lines.join('\n');
    expect(text, contains("Jus d'orange Rouiba 1L avec"));
    expect(text, contains('pulpe'));
    expect(text, contains('2 x 180,00 DA'));
    expect(text, contains('360,00 DA'));
  });

  test('shows ticket number, date, total in DA and the footer', () {
    final text = buildReceiptBody(receipt()).join('\n');

    expect(text, contains('Ticket no 0042'));
    expect(text, contains('06/10/2026 14:32'));
    expect(text, contains('Tel : 0555 12 34 56'));
    expect(text, matches(RegExp(r'TOTAL\s+120,00 DA')));
    expect(text, contains('Merci, a bientot !'));
  });

  test('accents are removed for printers that do not support them', () {
    expect(toPrinterAscii('Épicerie Crème brûlée œuf'),
        'Epicerie Creme brulee oeuf');
    expect(toPrinterAscii('Nº ☺'), 'N? ?');
  });

  test('a discount adds sub-total and discount lines', () {
    final text = buildReceiptBody(receipt(discount: 2000)).join('\n');

    expect(text, matches(RegExp(r'Sous-total\s+120,00 DA')));
    expect(text, matches(RegExp(r'Remise\s+-20,00 DA')));
    expect(text, matches(RegExp(r'TOTAL\s+100,00 DA')));
  });

  test('wrapText breaks between words and cuts very long words', () {
    expect(wrapText('un deux trois', 7), ['un deux', 'trois']);
    expect(wrapText('abcdefghij', 4), ['abcd', 'efgh', 'ij']);
    expect(wrapText('  ', 10), isEmpty);
  });
}
