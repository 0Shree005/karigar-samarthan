import 'package:flutter/material.dart';
import '../components/audio_prompt.dart';

class MyOrdersPage extends StatelessWidget {
  const MyOrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Orders')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: AudioPrompt(
              onPlay: () {},
              text: "Tap an order to hear details",
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _OrderCard(
                  orderId: "#ORD-001",
                  productName: "Handcrafted Clay Pot",
                  image:
                      "assets/images/Handmade_pottery_brown_1769327617453.jpg",
                  status: "New Order",
                  statusColor: Colors.blue,
                  date: "Today, 10:30 AM",
                ),
                _OrderCard(
                  orderId: "#ORD-002",
                  productName: "Silk Saree",
                  image:
                      "assets/images/Handloom_saree_textle_red_1769327618321.jpg",
                  status: "Packed",
                  statusColor: Colors.orange,
                  date: "Yesterday",
                ),
                _OrderCard(
                  orderId: "#ORD-003",
                  productName: "Wooden Toy",
                  image:
                      "assets/images/Wooden_handicraft_brown_1769327620084.jpg",
                  status: "Shipped",
                  statusColor: Colors.green,
                  date: "2 Days Ago",
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final String orderId;
  final String productName;
  final String image;
  final String status;
  final Color statusColor;
  final String date;

  const _OrderCard({
    required this.orderId,
    required this.productName,
    required this.image,
    required this.status,
    required this.statusColor,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          // Play voice summary
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Playing order summary...')),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      image,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              orderId,
                              style: Theme.of(context).textTheme.labelLarge
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.secondary,
                                  ),
                            ),
                            Text(
                              date,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          productName,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, size: 20, color: statusColor),
                    const SizedBox(width: 8),
                    Text(
                      status,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.volume_up,
                      size: 20,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
