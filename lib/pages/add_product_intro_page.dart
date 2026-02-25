import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AddProductIntroPage extends StatelessWidget {
  const AddProductIntroPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add New Product')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text(
              'We will help you step by step.\nYou can use your voice anytime.',
              style: TextStyle(fontSize: 18),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () => context.go('/add-product'),
              child: const Text('Start'),
            ),
          ],
        ),
      ),
    );
  }
}
