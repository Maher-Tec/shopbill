import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopbill/app/router.dart';
import 'package:shopbill/app/theme/app_theme.dart';
import 'package:shopbill/core/database/app_database.dart';
import 'package:shopbill/features/products/data/repositories/drift_products_repository.dart';
import 'package:shopbill/features/products/domain/repositories/products_repository.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase.open();
  ref.onDispose(database.close);
  return database;
});

final productsRepositoryProvider = Provider<ProductsRepository>((ref) {
  return DriftProductsRepository(ref.watch(appDatabaseProvider));
});

class ShopBillApp extends StatelessWidget {
  const ShopBillApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'ShopBill',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      routerConfig: appRouter,
    );
  }
}
