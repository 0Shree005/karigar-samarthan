import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OnboardingVolumePage extends StatelessWidget {
  const OnboardingVolumePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.volume_up, size: 96),
            const SizedBox(height: 24),
            const Text(
              'Please turn up your volume.\nWe will guide you using voice.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                // TODO: play audio sample before allowing navigation
                context.go('/language-selection');
              },
              child: const Text('I can hear clearly'),
            ),
          ],
        ),
      ),
    );
  }
}
