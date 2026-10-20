import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopbill/app/app.dart';
import 'package:shopbill/features/products/domain/entities/product.dart';
import 'package:shopbill/features/products/domain/repositories/products_repository.dart';

class _FakeProductsRepository implements ProductsRepository {
  final _products = <Product>[];
  final _updates = StreamController<List<Product>>.broadcast();

  @override
  Stream<List<Product>> watchAll() async* {
    yield List.unmodifiable(_products);
    yield* _updates.stream;
  }

  @override
  Future<void> upsert(Product product) async {
    _products.add(product);
    _updates.add(List.unmodifiable(_products));
  }

  Future<void> dispose() => _updates.close();
}

void main() {
  testWidgets('initial route shows the products screen', (tester) async {
    final repository = _FakeProductsRepository();
    final container = ProviderContainer(
      overrides: [productsRepositoryProvider.overrideWithValue(repository)],
    );
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const ShopBillApp(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Products'), findsOneWidget);
    expect(find.text('No products yet'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    container.dispose();
    await repository.dispose();
  });

  testWidgets(
    'saving a product keeps the dialog controller alive until teardown',
    (tester) async {
      final repository = _FakeProductsRepository();
      final container = ProviderContainer(
        overrides: [productsRepositoryProvider.overrideWithValue(repository)],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const ShopBillApp(),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.tap(find.text('Add product'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Basmati Rice');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(find.text('Basmati Rice'), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.pumpWidget(const SizedBox.shrink());
      container.dispose();
      await repository.dispose();
    },
  );
}
