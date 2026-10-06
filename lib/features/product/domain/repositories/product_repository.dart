import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failure.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/product_change.dart';

abstract class ProductRepository {
  Future<Either<Failure, List<Product>>> getProducts();
  Future<Either<Failure, Product>> getProductByBarcode(String barcode);
  Future<Either<Failure, void>> addProduct(Product product);

  /// Saves the product and writes one history line per changed field.
  Future<Either<Failure, void>> updateProduct(Product product);
  Future<Either<Failure, void>> archiveProduct(String id);

  /// The product's changes, newest first.
  Future<Either<Failure, List<ProductChange>>> getHistory(String productId);

  Future<Either<Failure, List<Category>>> getCategories();
  Future<Either<Failure, Category>> addCategory(String name);
}
