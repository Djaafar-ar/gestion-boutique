import 'package:billing_app/features/stock/domain/entities/stock_batch.dart';
import 'package:billing_app/features/stock/domain/stock_math.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  StockBatch batch(String id, int quantity,
          {DateTime? expiry, int day = 1, int buyPrice = 100}) =>
      StockBatch(
        deliveryId: id,
        productId: 'soda',
        quantity: quantity,
        remaining: quantity,
        buyPrice: buyPrice,
        expiryDate: expiry,
        receivedAt: DateTime(2026, 10, day),
      );

  // The example from the plan: 10 sodas expiring 12/10, 24 on 30/11.
  final october = batch('oct', 10, expiry: DateTime(2026, 10, 12));
  final november = batch('nov', 24, expiry: DateTime(2026, 11, 30), day: 2);
  final noDate = batch('none', 5, day: 3);

  group('expires first, goes out first', () {
    test('earliest expiry first, no date last', () {
      final sorted = [noDate, november, october]..sort(compareFefo);
      expect(sorted.map((b) => b.deliveryId), ['oct', 'nov', 'none']);
    });

    test('without dates, the oldest delivery first', () {
      final a = batch('a', 1, day: 5), b = batch('b', 1, day: 2);
      expect(([a, b]..sort(compareFefo)).first.deliveryId, 'b');
    });

    test('selling 12 takes 10 from October and 2 from November', () {
      final state = computeBatches([october, november], {});
      final plan = planTakeOut(state, 12, fallbackCost: 0);
      expect(plan.map((p) => (p.deliveryId, p.quantity)),
          [('oct', 10), ('nov', 2)]);
    });
  });

  group('what is left', () {
    test('delivered minus taken, per batch', () {
      final state = computeBatches([october, november], {'oct': 10, 'nov': 2});
      expect(state.batches.map((b) => b.remaining), [0, 22]);
      expect(state.stock, 22);
      expect(state.onShelf.single.deliveryId, 'nov');
    });

    test('items sold with no stock make it negative...', () {
      final state = computeBatches([], {null: 3});
      expect(state.stock, -3);
      expect(state.missing, 3);
    });

    test('...until a later delivery covers them', () {
      final state = computeBatches([batch('late', 10)], {null: 3});
      expect(state.stock, 7);
      expect(state.missing, 0);
      expect(state.batches.single.remaining, 7);
    });

    test('two phones emptying the same batch: the extra moves on', () {
      // Both phones sold the last 6 of October before syncing (12 > 10).
      final state = computeBatches([october, november], {'oct': 12});
      expect(state.batches.map((b) => b.remaining), [0, 22]);
      expect(state.stock, 22);
    });
  });

  group('taking out', () {
    test('a chosen batch goes first (for example the expired one)', () {
      final state = computeBatches([october, november], {});
      final plan = planTakeOut(state, 3, preferred: 'nov', fallbackCost: 0);
      expect(plan.single.deliveryId, 'nov');
    });

    test('missing items get no batch and the product buying price', () {
      final state = computeBatches([batch('a', 2, buyPrice: 100)], {});
      final plan = planTakeOut(state, 5, fallbackCost: 130);
      expect(plan.map((p) => (p.deliveryId, p.quantity, p.unitCost)),
          [('a', 2, 100), (null, 3, 130)]);
      // (2 x 100 + 3 x 130) / 5 = 118
      expect(averageCost(plan), 118);
    });
  });

  test('returned items go back to the batches they came from', () {
    final plan = planPutBack([
      (deliveryId: 'oct', quantity: 10),
      (deliveryId: 'nov', quantity: 2),
    ], 3);
    // The last batch taken first: 2 to November, 1 to October.
    expect(
        plan.map((p) => (p.deliveryId, p.quantity)), [('nov', 2), ('oct', 1)]);
  });

  group('expiry colour', () {
    final today = DateTime(2026, 10, 6, 15);
    ExpiryStatus status(DateTime? d) =>
        expiryStatusOf(d, warnDays: 3, today: today);

    test('expired, soon, fine, none', () {
      expect(status(DateTime(2026, 10, 5)), ExpiryStatus.expired);
      expect(status(DateTime(2026, 10, 6)), ExpiryStatus.soon);
      expect(status(DateTime(2026, 10, 9)), ExpiryStatus.soon);
      expect(status(DateTime(2026, 10, 10)), ExpiryStatus.ok);
      expect(status(null), ExpiryStatus.none);
    });
  });
}
