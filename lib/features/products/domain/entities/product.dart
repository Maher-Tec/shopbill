class Product {
  const Product({
    required this.id,
    this.userId,
    required this.createdAt,
    required this.updatedAt,
    required this.isDeleted,
    required this.name,
    this.sku,
    this.barcode,
    this.categoryId,
    required this.costPrice,
    required this.salePrice,
    required this.stockQty,
    required this.reorderLevel,
    required this.unit,
    required this.isActive,
  });

  final String id;
  final String? userId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;
  final String name;
  final String? sku;
  final String? barcode;
  final String? categoryId;

  final int costPrice;

  final int salePrice;
  final int stockQty;
  final int reorderLevel;
  final String unit;
  final bool isActive;
}
