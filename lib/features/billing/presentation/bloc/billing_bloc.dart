import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/receipt_printer.dart';
import '../../domain/entities/cart_item.dart';
import '../../domain/entities/sale.dart';
import '../../domain/repositories/sale_repository.dart';
import 'package:billing_app/features/product/domain/entities/product.dart';
import 'package:billing_app/features/product/domain/usecases/product_usecases.dart';
import 'package:billing_app/features/shop/domain/entities/shop.dart';

part 'billing_event.dart';
part 'billing_state.dart';

class BillingBloc extends Bloc<BillingEvent, BillingState> {
  final GetProductByBarcodeUseCase getProductByBarcodeUseCase;
  final SaleRepository saleRepository;
  final ReceiptPrinter receiptPrinter;

  BillingBloc({
    required this.getProductByBarcodeUseCase,
    required this.saleRepository,
    required this.receiptPrinter,
  }) : super(const BillingState()) {
    on<ScanBarcodeEvent>(_onScanBarcode);
    on<AddProductToCartEvent>(_onAddProductToCart);
    on<RemoveProductFromCartEvent>(_onRemoveProductFromCart);
    on<UpdateQuantityEvent>(_onUpdateQuantity);
    on<ClearCartEvent>(_onClearCart);
    on<CheckoutEvent>(_onCheckout);
  }

  Future<void> _onScanBarcode(
      ScanBarcodeEvent event, Emitter<BillingState> emit) async {
    final result = await getProductByBarcodeUseCase(event.barcode);
    result.fold(
      (failure) => emit(state.copyWith(
          error: BillingError.productNotFound, errorDetail: event.barcode)),
      (product) {
        add(AddProductToCartEvent(product));
      },
    );
  }

  void _onAddProductToCart(
      AddProductToCartEvent event, Emitter<BillingState> emit) {
    final existingIndex = state.cartItems
        .indexWhere((item) => item.product.id == event.product.id);
    if (existingIndex >= 0) {
      final existingItem = state.cartItems[existingIndex];
      final items = List<CartItem>.from(state.cartItems);
      items[existingIndex] =
          existingItem.copyWith(quantity: existingItem.quantity + 1);
      emit(state.copyWith(cartItems: items));
    } else {
      final newItem = CartItem(product: event.product);
      emit(state.copyWith(cartItems: [...state.cartItems, newItem]));
    }
  }

  void _onRemoveProductFromCart(
      RemoveProductFromCartEvent event, Emitter<BillingState> emit) {
    final updatedList = state.cartItems
        .where((item) => item.product.id != event.productId)
        .toList();
    emit(state.copyWith(cartItems: updatedList));
  }

  void _onUpdateQuantity(
      UpdateQuantityEvent event, Emitter<BillingState> emit) {
    if (event.quantity <= 0) {
      add(RemoveProductFromCartEvent(event.productId));
      return;
    }

    final index = state.cartItems
        .indexWhere((item) => item.product.id == event.productId);
    if (index >= 0) {
      final items = List<CartItem>.from(state.cartItems);
      items[index] = items[index].copyWith(quantity: event.quantity);
      emit(state.copyWith(cartItems: items));
    }
  }

  void _onClearCart(ClearCartEvent event, Emitter<BillingState> emit) {
    emit(const BillingState());
  }

  /// Saves the sale first, then prints if asked. A printing problem never
  /// loses the sale: it stays saved and can be reprinted from the history.
  Future<void> _onCheckout(
      CheckoutEvent event, Emitter<BillingState> emit) async {
    if (state.cartItems.isEmpty || state.isProcessing) return;
    emit(state.copyWith(isProcessing: true));

    final saved = await saleRepository.saveSale(state.cartItems);
    if (saved.isLeft()) {
      emit(state.copyWith(
        isProcessing: false,
        error: BillingError.saveFailed,
        errorDetail: saved.getLeft().toNullable()?.message,
      ));
      return;
    }
    final sale = saved.getRight().toNullable()!;

    PrintResult? printed;
    if (event.print) {
      printed = await receiptPrinter.printSale(sale, event.shop);
    }

    // A fresh state empties the cart for the next customer.
    emit(BillingState(
      completedSale: sale,
      printOutcome: printed?.outcome,
      errorDetail: printed?.error,
    ));
  }
}
