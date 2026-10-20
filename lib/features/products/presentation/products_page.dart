import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopbill/app/app.dart';
import 'package:shopbill/features/products/domain/entities/product.dart';
import 'package:shopbill/features/products/domain/repositories/products_repository.dart';

final productsProvider = StreamProvider<List<Product>>((ref) {
  return ref.watch(productsRepositoryProvider).watchAll();
});

final addProductProvider = Provider<AddProduct>((ref) {
  return AddProduct(ref.watch(productsRepositoryProvider));
});

class AddProduct {
  AddProduct(this._repository);

  final ProductsRepository _repository;

  Future<void> call(String name) async {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) return;

    final now = DateTime.now().toUtc();
    await _repository.upsert(
      Product(
        id: '',
        createdAt: now,
        updatedAt: now,
        isDeleted: false,
        name: trimmedName,
        costPrice: 0,
        salePrice: 0,
        stockQty: 0,
        reorderLevel: 5,
        unit: 'pcs',
        isActive: true,
      ),
    );
  }
}

class ProductsPage extends ConsumerWidget {
  const ProductsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(productsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Products')),
      body: products.when(
        data: (items) => items.isEmpty
            ? const Center(child: Text('No products yet'))
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: items.length,
                itemBuilder: (context, index) =>
                    Card(child: ListTile(title: Text(items[index].name))),
              ),
        error: (error, stackTrace) =>
            Center(child: Text('Could not load products: $error')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddProductDialog(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Add product'),
      ),
    );
  }

  Future<void> _showAddProductDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final name = await showDialog<String>(
      context: context,
      builder: (_) => const AddProductDialog(),
    );

    if (name != null) await ref.read(addProductProvider)(name);
  }
}

class AddProductDialog extends StatefulWidget {
  const AddProductDialog({super.key});

  @override
  State<AddProductDialog> createState() => _AddProductDialogState();
}

class _AddProductDialogState extends State<AddProductDialog> {
  late final TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add product'),
      content: TextField(
        controller: _nameController,
        autofocus: true,
        decoration: const InputDecoration(labelText: 'Product name'),
        textCapitalization: TextCapitalization.sentences,
        onSubmitted: _save,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => _save(_nameController.text),
          child: const Text('Save'),
        ),
      ],
    );
  }

  void _save(String name) => Navigator.of(context).pop(name);
}
