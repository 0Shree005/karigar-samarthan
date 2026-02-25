import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ProductReviewPage extends StatelessWidget {
  const ProductReviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Review Product')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const ListTile(
              title: Text('Product Name'), subtitle: Text('Handmade Vase')),
          const ListTile(title: Text('Price'), subtitle: Text('₹1200')),
          const ListTile(
              title: Text('Availability'), subtitle: Text('Ready in 3 days')),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.go('/product-published'),
            child: const Text('Publish Product'),
          ),
        ],
      ),
    );
  }
}
