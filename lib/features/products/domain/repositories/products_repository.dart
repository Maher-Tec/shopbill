import 'package:shopbill/features/products/domain/entities/product.dart';

abstract interface class ProductsRepository {
  Stream<List<Product>> watchAll();

  Future<void> upsert(Product product);
}
