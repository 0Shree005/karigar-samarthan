import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../nav.dart';
import '../components/audio_prompt.dart';

class EditProductsPage extends StatelessWidget {
  const EditProductsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Products')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: AudioPrompt(onPlay: () {}, text: "Select a product to edit"),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _ProductCard(
                  name: "Handcrafted Clay Pot",
                  price: "₹ 500",
                  status: "Active",
                  image:
                      "assets/images/Handmade_pottery_brown_1769327617453.jpg",
                  statusColor: Colors.green,
                ),
                _ProductCard(
                  name: "Silk Saree",
                  price: "₹ 2500",
                  status: "Low Stock",
                  image:
                      "assets/images/Handloom_saree_textle_red_1769327618321.jpg",
                  statusColor: Colors.orange,
                ),
                _ProductCard(
                  name: "Gold Necklace",
                  price: "₹ 15000",
                  status: "Sold Out",
                  image:
                      "assets/images/Gold_jewelry_Indian_yellow_1769327619213.jpg",
                  statusColor: Colors.red,
                ),
                _ProductCard(
                  name: "Wooden Toy",
                  price: "₹ 300",
                  status: "Active",
                  image:
                      "assets/images/Wooden_handicraft_brown_1769327620084.jpg",
                  statusColor: Colors.green,
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.addProduct),
        label: const Text("Add New"),
        icon: const Icon(Icons.add),
        backgroundColor: Theme.of(context).colorScheme.tertiary,
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final String name;
  final String price;
  final String status;
  final String image;
  final Color statusColor;

  const _ProductCard({
    required this.name,
    required this.price,
    required this.status,
    required this.image,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          // Navigate to edit flow (reusing add product wizard for simplicity or new edit flow)
          // For prototype, we'll just show a snackbar or go to add product as "Edit"
          context.push(AppRoutes.addProduct);
        },
        child: Row(
          children: [
            SizedBox(
              width: 100,
              height: 100,
              child: Image.asset(image, fit: BoxFit.cover),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(price, style: Theme.of(context).textTheme.bodyLarge),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: statusColor.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Text(
                      status,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            IconButton(icon: const Icon(Icons.edit_outlined), onPressed: () {}),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }
}
