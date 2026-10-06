// Tests for the cart total shown on the Sell and Checkout screens.
//
// Run with: flutter test

import 'package:billing_app/features/billing/domain/entities/cart_item.dart';
import 'package:billing_app/features/billing/presentation/bloc/billing_bloc.dart';
import 'package:billing_app/features/product/domain/entities/product.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Two sample products to put in the cart. Prices are in centimes.
  const juice =
      Product(id: '1', name: 'Jus Rouiba 1L', barcode: '111', sellPrice: 18000);
  const soda = Product(
      id: '2', name: 'Hamoud Boualem 33cl', barcode: '222', sellPrice: 6050);

  test('cart total is price x quantity, added up for every item', () {
    const state = BillingState(cartItems: [
      CartItem(product: juice, quantity: 2), // 2 x 180,00 = 360,00 DA
      CartItem(product: soda, quantity: 1), // 1 x 60,50 = 60,50 DA
    ]);

    expect(state.totalAmount, 42050);
    expect(state.itemCount, 3);
  });

  test('an empty cart has a total of zero', () {
    const state = BillingState();

    expect(state.totalAmount, 0);
    expect(state.itemCount, 0);
  });
}
