import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../nav.dart';
import '../components/audio_prompt.dart';
import '../providers/app_state.dart';
import '../models/product.dart';

class EditProductsPage extends StatelessWidget {
  const EditProductsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // WATCH the global state (re-builds when a product is added)
    final appState = context.watch<AppState>();
    final products = appState.myProducts;
    final bool isHi = appState.selectedLang == 'Hindi';

    return Scaffold(
      appBar: AppBar(
        title: Text(isHi ? 'मेरे सामान' : 'My Products'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: AudioPrompt(
              onPlay: () {
                // You could add TTS here to read out the count
              },
              text: isHi ? "बदलाव के लिए सामान चुनें" : "Select a product to edit",
            ),
          ),
          Expanded(
            child: products.isEmpty
                ? _buildEmptyState(context, isHi)
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return _ProductCard(
                  product: product,
                  isHi: isHi,
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.addProduct),
        label: Text(isHi ? "नया जोड़ें" : "Add New"),
        icon: const Icon(Icons.add),
        backgroundColor: Theme.of(context).colorScheme.tertiary,
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isHi) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            isHi ? "अभी कोई सामान नहीं है" : "No products added yet",
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Product product;
  final bool isHi;

  const _ProductCard({
    required this.product,
    required this.isHi,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          // For the prototype, we can show the JSON in a snackbar to prove it works
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Backend Ready: ${product.name}")),
          );
        },
        child: Row(
          children: [
            SizedBox(
              width: 100,
              height: 100,
              child: product.imageFile != null
                  ? Image.file(product.imageFile!, fit: BoxFit.cover)
                  : Image.asset(
                'assets/images/Handmade_pottery_brown_1769327617453.jpg', // Fallback
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "₹ ${product.price}",
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 8),
                  _buildStatusBadge(context),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () {},
            ),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context) {
    // For prototype, we'll mark everything as "In Stock" or "स्टॉक में है"
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.withOpacity(0.5)),
      ),
      child: Text(
        isHi ? "स्टॉक में है" : "In Stock",
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: Colors.green,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}