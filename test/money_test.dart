import 'package:billing_app/core/utils/money.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('formatDA', () {
    test('groups thousands with a space and uses a comma', () {
      expect(formatDA(125000), '1 250,00 DA');
      expect(formatDA(123456789), '1 234 567,89 DA');
    });

    test('small amounts', () {
      expect(formatDA(0), '0,00 DA');
      expect(formatDA(5), '0,05 DA');
      expect(formatDA(99999), '999,99 DA');
      expect(formatDA(100000), '1 000,00 DA');
    });

    test('negative amounts and no symbol', () {
      expect(formatDA(-4200), '-42,00 DA');
      expect(formatDA(125000, withSymbol: false), '1 250,00');
    });

    test('the screen version keeps the amount left-to-right', () {
      final text = formatDAForUi(125000);
      expect(text.runes.first, 0x2066);
      expect(text.runes.last, 0x2069);
      expect(text, contains('1 250,00 DA'));
    });
  });

  group('parseDA', () {
    test('reads the ways people type prices', () {
      expect(parseDA('1250'), 125000);
      expect(parseDA('1250,5'), 125050);
      expect(parseDA('1 250,50'), 125050);
      expect(parseDA('1250.50'), 125050);
      expect(parseDA('1 250,50 DA'), 125050);
      expect(parseDA(',5'), 50);
      expect(parseDA('0'), 0);
    });

    test('rejects text that is not a price', () {
      expect(parseDA(null), isNull);
      expect(parseDA(''), isNull);
      expect(parseDA('abc'), isNull);
      expect(parseDA('12,5,0'), isNull);
      expect(parseDA('12,345'), isNull); // more than 2 decimals
    });

    test('goes back and forth with the input format', () {
      expect(centimesToInput(125050), '1250,50');
      expect(parseDA(centimesToInput(987654)), 987654);
    });
  });
}
