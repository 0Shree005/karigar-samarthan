import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LanguageConfirmPage extends StatelessWidget {
  const LanguageConfirmPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'You selected Hindi.\nIs this correct?',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('Yes, continue'),
            ),
            TextButton(
              onPressed: () => context.pop(),
              child: const Text('Change language'),
            ),
          ],
        ),
      ),
    );
  }
}
