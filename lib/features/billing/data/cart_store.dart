import 'dart:convert';

import '../../../core/settings/settings_store.dart';
import '../../product/domain/repositories/product_repository.dart';
import '../domain/entities/cart_item.dart';

/// Keeps the cart in the database at every change, so it comes back after
/// the app or the phone stopped suddenly (battery, crash...).
class CartStore {
  final SettingsStore settings;
  final ProductRepository products;

  static const key = 'saved_cart';

  CartStore(this.settings, this.products);

  Future<void> save(List<CartItem> items) => settings.set(
      key,
      items.isEmpty
          ? null
          : jsonEncode([
              for (final item in items)
                {'id': item.product.id, 'q': item.quantity},
            ]));

  /// The saved cart, with today's products and prices. A product deleted
  /// or archived meanwhile is left out.
  Future<List<CartItem>> load() async {
    final text = settings.get(key);
    if (text == null) return const [];
    try {
      final saved = (jsonDecode(text) as List).cast<Map>();
      final all = (await products.getProducts()).getOrElse((_) => const []);
      final byId = {for (final p in all) p.id: p};
      return [
        for (final line in saved)
          if (byId[line['id']] case final product? when !product.archived)
            CartItem(product: product, quantity: (line['q'] as num).toInt()),
      ];
    } catch (_) {
      return const [];
    }
  }
}
