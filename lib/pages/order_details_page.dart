import 'package:flutter/material.dart';

class OrderDetailsPage extends StatelessWidget {
  const OrderDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Order Details')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          ListTile(title: Text('Product'), subtitle: Text('Handwoven Bag')),
          ListTile(title: Text('Address'), subtitle: Text('Delhi, India')),
          ListTile(title: Text('Payment'), subtitle: Text('Paid')),
        ],
      ),
    );
  }
}
