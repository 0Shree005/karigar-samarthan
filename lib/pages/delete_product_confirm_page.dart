import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DeleteProductConfirmPage extends StatelessWidget {
  const DeleteProductConfirmPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Delete Product?'),
      content: const Text('This action cannot be undone.'),
      actions: [
        TextButton(
          onPressed: () => context.pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            // TODO: delete logic
            context.go('/');
          },
          child: const Text('Delete'),
        ),
      ],
    );
  }
}
