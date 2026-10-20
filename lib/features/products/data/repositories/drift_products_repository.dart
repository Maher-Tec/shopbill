import 'package:drift/drift.dart';
import 'package:shopbill/core/database/app_database.dart' as db;
import 'package:shopbill/features/products/domain/entities/product.dart';
import 'package:shopbill/features/products/domain/repositories/products_repository.dart';
import 'package:uuid/uuid.dart';

class DriftProductsRepository implements ProductsRepository {
  DriftProductsRepository(this._database);

  final db.AppDatabase _database;
  static const _uuid = Uuid();

  @override
  Stream<List<Product>> watchAll() {
    final query = _database.select(_database.products)
      ..where((product) => product.isDeleted.equals(false))
      ..orderBy([(product) => OrderingTerm.asc(product.name)]);

    return query.watch().map(
      (rows) => rows.map(_mapToDomain).toList(growable: false),
    );
  }

  @override
  Future<void> upsert(Product product) async {
    final now = DateTime.now().toUtc();
    final existing = await (_database.select(
      _database.products,
    )..where((row) => row.id.equals(product.id))).getSingleOrNull();

    await _database
        .into(_database.products)
        .insertOnConflictUpdate(
          db.ProductsCompanion.insert(
            id: product.id.isEmpty ? _uuid.v4() : product.id,
            userId: Value(product.userId),
            createdAt: Value(existing?.createdAt ?? now),
            updatedAt: Value(now),
            isDeleted: Value(product.isDeleted),
            name: product.name,
            sku: Value(product.sku),
            barcode: Value(product.barcode),
            categoryId: Value(product.categoryId),
            costPrice: product.costPrice,
            salePrice: product.salePrice,
            stockQty: Value(product.stockQty),
            reorderLevel: Value(product.reorderLevel),
            unit: Value(product.unit),
            isActive: Value(product.isActive),
          ),
        );
  }

  Product _mapToDomain(db.Product row) => Product(
    id: row.id,
    userId: row.userId,
    createdAt: row.createdAt,
    updatedAt: row.updatedAt,
    isDeleted: row.isDeleted,
    name: row.name,
    sku: row.sku,
    barcode: row.barcode,
    categoryId: row.categoryId,
    costPrice: row.costPrice,
    salePrice: row.salePrice,
    stockQty: row.stockQty,
    reorderLevel: row.reorderLevel,
    unit: row.unit,
    isActive: row.isActive,
  );
}
