import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../nav.dart';
import '../components/voice_button.dart';
import '../components/audio_prompt.dart';

class AddProductWizardPage extends StatefulWidget {
  const AddProductWizardPage({super.key});

  @override
  State<AddProductWizardPage> createState() => _AddProductWizardPageState();
}

class _AddProductWizardPageState extends State<AddProductWizardPage> {
  int _currentStep = 0;
  final PageController _pageController = PageController();

  // Form Data
  String _name = "";
  String _category = "";
  String _description = "";
  String _price = "";
  String _quantity = "";
  bool _hasPhoto = false;

  void _nextStep() {
    if (_currentStep < 5) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() {
        _currentStep++;
      });
    } else {
      // Submit
      context.pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product Added Successfully!')),
      );
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() {
        _currentStep--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Step ${_currentStep + 1} of 6'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (_currentStep > 0) {
              _prevStep();
            } else {
              context.pop();
            }
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildStep(
                  title: "What is the name of your product?",
                  audioText: "Say the product name",
                  content: _buildNameInput(),
                ),
                _buildStep(
                  title: "Select Category",
                  audioText: "Choose a category",
                  content: _buildCategoryInput(),
                ),
                _buildStep(
                  title: "Describe your product",
                  audioText: "Describe the product details",
                  content: _buildDescriptionInput(),
                  aiAction: "Improve Description",
                ),
                _buildStep(
                  title: "Set Price (₹)",
                  audioText: "Say the price in rupees",
                  content: _buildPriceInput(),
                  aiAction: "Suggest Better Price",
                ),
                _buildStep(
                  title: "Quantity Available",
                  audioText: "How many items do you have?",
                  content: _buildQuantityInput(),
                ),
                _buildStep(
                  title: "Add Product Photo",
                  audioText: "Take a photo of your product",
                  content: _buildPhotoInput(),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_currentStep < 5)
                  TextButton(
                    onPressed: () {
                      // Skip logic if needed
                      _nextStep();
                    },
                    child: const Text('Skip'),
                  )
                else
                  const SizedBox(width: 60),

                FloatingActionButton.extended(
                  onPressed: _nextStep,
                  label: Text(_currentStep == 5 ? 'Finish' : 'Next'),
                  icon: Icon(
                    _currentStep == 5 ? Icons.check : Icons.arrow_forward,
                  ),
                  backgroundColor: Theme.of(context).colorScheme.tertiary,
                  foregroundColor: Theme.of(context).colorScheme.onTertiary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep({
    required String title,
    required String audioText,
    required Widget content,
    String? aiAction,
  }) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AudioPrompt(onPlay: () {}, text: audioText),
          const SizedBox(height: 24),
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Expanded(child: content),
          if (aiAction != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.secondaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.auto_awesome,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    aiAction,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.secondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNameInput() {
    return Column(
      children: [
        VoiceButton(
          onTap: () {
            setState(() {
              _name = "Handcrafted Clay Pot";
            });
          },
          label: "Tap to Speak Name",
        ),
        const SizedBox(height: 24),
        if (_name.isNotEmpty)
          Text(
            _name,
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
      ],
    );
  }

  Widget _buildCategoryInput() {
    final categories = [
      {'icon': Icons.brush, 'label': 'Pottery'},
      {'icon': Icons.checkroom, 'label': 'Textiles'},
      {'icon': Icons.diamond, 'label': 'Jewelry'},
      {'icon': Icons.chair, 'label': 'Woodwork'},
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
        final isSelected = _category == cat['label'];
        return InkWell(
          onTap: () => setState(() => _category = cat['label'] as String),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected
                  ? Theme.of(context).colorScheme.primaryContainer
                  : Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(
                        context,
                      ).colorScheme.outline.withValues(alpha: 0.2),
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
                Text(
                  cat['label'] as String,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDescriptionInput() {
    return Column(
      children: [
        VoiceButton(
          onTap: () {
            setState(() {
              _description =
                  "Beautiful handmade clay pot with traditional Warli painting. Perfect for home decor.";
            });
          },
          label: "Tap to Describe",
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(
              context,
            ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            _description.isEmpty
                ? "Spoken description will appear here..."
                : _description,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      ],
    );
  }

  Widget _buildPriceInput() {
    return Column(
      children: [
        VoiceButton(
          onTap: () {
            setState(() {
              _price = "500";
            });
          },
          label: "Tap to Say Price",
        ),
        const SizedBox(height: 24),
        Text(
          _price.isEmpty ? "₹ --" : "₹ $_price",
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildQuantityInput() {
    return Column(
      children: [
        VoiceButton(
          onTap: () {
            setState(() {
              _quantity = "10";
            });
          },
          label: "Tap to Say Quantity",
        ),
        const SizedBox(height: 24),
        Text(
          _quantity.isEmpty ? "-- units" : "$_quantity units",
          style: Theme.of(
            context,
          ).textTheme.displayMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildPhotoInput() {
    return Column(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _hasPhoto = true),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline,
                  style: BorderStyle.solid,
                ),
                image: _hasPhoto
                    ? const DecorationImage(
                        image: AssetImage(
                          'assets/images/Handmade_pottery_brown_1769327617453.jpg',
                        ),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: _hasPhoto
                  ? null
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.camera_alt,
                          size: 64,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Tap to Take Photo",
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ],
    );
  }
}
