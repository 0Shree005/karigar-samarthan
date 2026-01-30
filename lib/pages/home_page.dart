import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../nav.dart';
import '../components/action_card.dart';
import '../components/voice_button.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Namaste, Artisan',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'What would you like to do?',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    ],
                  ),
                  const CircleAvatar(
                    radius: 24,
                    backgroundImage: AssetImage(
                      'assets/images/Indian_artisan_working_brown_1769327616488.jpg',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Expanded(
                child: ListView(
                  children: [
                    ActionCard(
                      icon: Icons.person_outline,
                      label: 'Edit My Account',
                      audioHint: 'Edit Account',
                      onTap: () {}, // TODO: Implement profile edit
                    ),
                    ActionCard(
                      icon: Icons.add_circle_outline,
                      label: 'Add New Product',
                      audioHint: 'Add Product',
                      color: Theme.of(context).colorScheme.primary,
                      onTap: () => context.push(AppRoutes.addProduct),
                    ),
                    ActionCard(
                      icon: Icons.edit_note,
                      label: 'Edit Products',
                      audioHint: 'Edit Products',
                      onTap: () => context.push(AppRoutes.editProducts),
                    ),
                    ActionCard(
                      icon: Icons.shopping_bag_outlined,
                      label: 'My Orders',
                      audioHint: 'Check Orders',
                      onTap: () => context.push(AppRoutes.myOrders),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: VoiceButton(
                  onTap: () {
                    // Global voice command listener
                  },
                  label: "Speak Command",
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
