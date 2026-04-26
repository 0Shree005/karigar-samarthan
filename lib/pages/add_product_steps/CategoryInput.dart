import 'package:flutter/material.dart';

class CategoryInput extends StatelessWidget {
  final int? selectedCategoryId;
  final Function(int) onCategorySelected;

  const CategoryInput({
    super.key,
    required this.selectedCategoryId,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
  final categories = [
    {'icon': Icons.brush, 'label': 'Ceramics', 'id': 306}, // Matches "Ceramics"
    {'icon': Icons.checkroom, 'label': 'Textiles', 'id': 278}, // Matches "Dupattas/Textiles"
    {'icon': Icons.shopping_bag, 'label': 'Bags', 'id': 276}, // Matches "Bags"
    {'icon': Icons.chair, 'label': 'Home Decor', 'id': 282}, // Matches "Home Decor"
  ];

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.2,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final cat = categories[index];
        final id = cat['id'] as int;
        final isSelected = selectedCategoryId == id;

        return InkWell(
          onTap: () => onCategorySelected(id),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected
                  ? Theme.of(context).colorScheme.primaryContainer
                  : Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.outline.withOpacity(0.2),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  cat['icon'] as IconData,
                  size: 32,
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurface,
                ),
                const SizedBox(height: 8),
                Text(cat['label'] as String, style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
          ),
        );
      },
    );
  }
}