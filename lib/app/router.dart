import 'package:go_router/go_router.dart';
import 'package:shopbill/features/products/presentation/products_page.dart';

final appRouter = GoRouter(
  initialLocation: '/products',
  routes: [
    GoRoute(
      path: '/products',
      builder: (context, state) => const ProductsPage(),
    ),
  ],
);
