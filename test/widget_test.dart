// Tests for the cart total shown on the Home and Checkout screens.
//
// Run with: flutter test

import 'package:billing_app/features/billing/domain/entities/cart_item.dart';
import 'package:billing_app/features/billing/presentation/bloc/billing_bloc.dart';
import 'package:billing_app/features/product/domain/entities/product.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Two sample products to put in the cart.
  const rice = Product(
      id: '1', name: 'Basmati Rice 1kg', barcode: '111', price: 120.0);
  const dal =
      Product(id: '2', name: 'Toor Dal 500g', barcode: '222', price: 85.5);

  test('cart total is price x quantity, added up for every item', () {
    const state = BillingState(cartItems: [
      CartItem(product: rice, quantity: 2), // 2 x 120.00 = 240.00
      CartItem(product: dal, quantity: 1), // 1 x 85.50 = 85.50
    ]);

    expect(state.totalAmount, 325.5);
  });

  test('an empty cart has a total of zero', () {
    const state = BillingState();

    expect(state.totalAmount, 0);
  });
}
