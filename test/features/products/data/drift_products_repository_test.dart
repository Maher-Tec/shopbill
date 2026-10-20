import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopbill/core/database/app_database.dart' hide Product;
import 'package:shopbill/features/products/data/repositories/drift_products_repository.dart';
import 'package:shopbill/features/products/domain/entities/product.dart';

void main() {
  late AppDatabase database;
  late DriftProductsRepository repository;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    repository = DriftProductsRepository(database);
  });

  tearDown(() async {
    await database.close();
  });

  test('upserted products appear in the local product stream', () async {
    final now = DateTime.utc(2026, 10, 20);
    final product = Product(
      id: '',
      createdAt: now,
      updatedAt: now,
      isDeleted: false,
      name: 'Rice',
      costPrice: 15000,
      salePrice: 18000,
      stockQty: 10,
      reorderLevel: 5,
      unit: 'pcs',
      isActive: true,
    );

    await repository.upsert(product);
    final products = await repository.watchAll().first.timeout(
      const Duration(seconds: 5),
    );

    expect(products, hasLength(1));
    expect(products.single.name, 'Rice');
    expect(products.single.salePrice, 18000);
    expect(products.single.id, isNotEmpty);
    expect(products.single.createdAt, isNotNull);
    expect(products.single.updatedAt, isNotNull);
  });
}
