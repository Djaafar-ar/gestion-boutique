import 'entities/stock_batch.dart';

// The stock rules, as plain functions without a database, so the tests
// can check every case. In simple words:
// - each delivery is a batch,
// - items always leave from the batch that expires first (FEFO),
// - stock = delivered - taken out + put back.

/// "Expires first, goes out first": earliest expiry first, batches
/// without an expiry date last, then the oldest delivery first.
int compareFefo(StockBatch a, StockBatch b) {
  final ea = a.expiryDate, eb = b.expiryDate;
  if (ea != null && eb != null && ea != eb) return ea.compareTo(eb);
  if (ea == null && eb != null) return 1;
  if (ea != null && eb == null) return -1;
  final byDate = a.receivedAt.compareTo(b.receivedAt);
  return byDate != 0 ? byDate : a.deliveryId.compareTo(b.deliveryId);
}

/// What is left of each batch of one product.
class BatchState {
  /// Sorted "expires first" first.
  final List<StockBatch> batches;

  /// Items sold or lost while the stock was empty and not yet covered by
  /// a later delivery. They make the stock go below zero.
  final int missing;

  const BatchState(this.batches, this.missing);

  int get stock =>
      batches.fold<int>(0, (sum, b) => sum + b.remaining) - missing;

  /// Batches that still have items, "expires first" first.
  List<StockBatch> get onShelf =>
      batches.where((b) => b.remaining > 0).toList();
}

/// Computes what is left in each batch.
///
/// [delivered] are the batches with `remaining` = quantity received.
/// [takenByDelivery] is the sum of stock allocations per delivery id;
/// the `null` key holds items taken when no batch had stock left.
///
/// Two phones may both take the last items of a batch before they sync:
/// that batch then goes below zero. The extra is moved to the next batch
/// that expires first, so every phone computes the same numbers.
BatchState computeBatches(
    List<StockBatch> delivered, Map<String?, int> takenByDelivery) {
  final sorted = [...delivered]..sort(compareFefo);
  var missing = takenByDelivery[null] ?? 0;
  final batches = <StockBatch>[];
  for (final batch in sorted) {
    final left = batch.quantity - (takenByDelivery[batch.deliveryId] ?? 0);
    if (left < 0) missing += -left;
    batches.add(batch.withRemaining(left < 0 ? 0 : left));
  }
  // Items sold without stock are covered by any stock left now,
  // "expires first" first (this is what a later delivery does).
  for (var i = 0; i < batches.length && missing > 0; i++) {
    final cover =
        batches[i].remaining < missing ? batches[i].remaining : missing;
    if (cover == 0) continue;
    batches[i] = batches[i].withRemaining(batches[i].remaining - cover);
    missing -= cover;
  }
  // A negative "missing" (more put back than taken without a batch, very
  // rare) simply counts as extra stock in [BatchState.stock].
  return BatchState(batches, missing);
}

/// How many items to take from which batch for [quantity] items.
/// [preferred] (for example the expired batch of a loss) goes first,
/// then "expires first". Items with no stock left get a `null` batch.
List<({String? deliveryId, int quantity, int unitCost})> planTakeOut(
  BatchState state,
  int quantity, {
  String? preferred,
  required int fallbackCost,
}) {
  final order = state.onShelf
    ..sort((a, b) {
      if (a.deliveryId == preferred) return -1;
      if (b.deliveryId == preferred) return 1;
      return compareFefo(a, b);
    });
  final plan = <({String? deliveryId, int quantity, int unitCost})>[];
  var left = quantity;
  for (final batch in order) {
    if (left == 0) break;
    final take = batch.remaining < left ? batch.remaining : left;
    plan.add((
      deliveryId: batch.deliveryId,
      quantity: take,
      unitCost: batch.buyPrice
    ));
    left -= take;
  }
  if (left > 0) {
    plan.add((deliveryId: null, quantity: left, unitCost: fallbackCost));
  }
  return plan;
}

/// Average buying price per item of a [planTakeOut] result (centimes).
int averageCost(List<({String? deliveryId, int quantity, int unitCost})> plan) {
  final items = plan.fold<int>(0, (sum, p) => sum + p.quantity);
  if (items == 0) return 0;
  final cost = plan.fold<int>(0, (sum, p) => sum + p.quantity * p.unitCost);
  return (cost / items).round();
}

/// Where returned items go back: into the batches the sale line took them
/// from, the last one taken first. [outstanding] is, per batch, how many
/// items of that sale line are still out (taken minus already returned),
/// in the order they were taken.
List<({String? deliveryId, int quantity})> planPutBack(
    List<({String? deliveryId, int quantity})> outstanding, int quantity) {
  final plan = <({String? deliveryId, int quantity})>[];
  var left = quantity;
  for (final entry in outstanding.reversed) {
    if (left == 0) break;
    if (entry.quantity <= 0) continue;
    final give = entry.quantity < left ? entry.quantity : left;
    plan.add((deliveryId: entry.deliveryId, quantity: give));
    left -= give;
  }
  return plan;
}
