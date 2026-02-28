// dart std lib
import 'dart:io';
import 'dart:convert';

// flutter pkgs
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

// images and gemini
import "package:image_picker/image_picker.dart";
import 'package:google_generative_ai/google_generative_ai.dart';

// routing
import 'package:path_provider/path_provider.dart';
import 'package:go_router/go_router.dart';
import '../nav.dart';

// tts and stt
import 'package:flutter_tts/flutter_tts.dart' as tts;
import 'package:speech_to_text/speech_to_text.dart' as stt;

// global state
import 'package:provider/provider.dart';
import '../providers/app_state.dart';

// voice ui
import '../components/voice_button.dart';
import '../components/audio_prompt.dart';

// product JSON
import '../models/product.dart';

class AiProductResult {
  final String title;
  final String description;
  final String category;

  AiProductResult({
    required this.title,
    required this.description,
    required this.category,
  });
}


class AddProductWizardPage extends StatefulWidget {
  const AddProductWizardPage({super.key});

  @override
  State<AddProductWizardPage> createState() => _AddProductWizardPageState();
}

class _AddProductWizardPageState extends State<AddProductWizardPage>
    with SingleTickerProviderStateMixin {

  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _speech.initialize();

    // Setup the pulsating animation
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true); // This makes it go back and forth
  }

  @override
  void dispose() {
    _pulseController.dispose(); // Always clean up
    super.dispose();
  }

  int _currentStep = 0;
  final PageController _pageController = PageController();
  final ImagePicker _picker = ImagePicker();
  final stt.SpeechToText _speech = stt.SpeechToText();
  final tts.FlutterTts _tts = tts.FlutterTts();
  bool _isListening = false;
  String _activeField = ""; // To track which field we are dictating

  final String _apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';

  Future<AiProductResult?>? _aiTask;
  File? _imageFile; // To store the actual file

  // Form Data
  String _name = "";
  String _category = "";
  String _description = "";
  String _price = "";
  String _quantity = "";
  bool _hasPhoto = false;
  String? _aiSuggestedName;
  String? _aiSuggestedDescription;
  String? _aiSuggestedCategory;
  bool _isAiDone = false;


  Future<AiProductResult?> _processAndAnalyzeImage(File originalFile) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final targetPath =
          '${tempDir.path}/temp_ai_resize_${DateTime.now().millisecondsSinceEpoch}.jpg';

      var compressedFile = await FlutterImageCompress.compressAndGetFile(
        originalFile.absolute.path,
        targetPath,
        quality: 70,
        minWidth: 800,
        minHeight: 800,
      );

      if (compressedFile == null) return null;

      return _analyzeImageWithGemini(File(compressedFile.path));
    } catch (e) {
      print("Compression Error: $e");
      return null;
    }
  }

  Future<AiProductResult?> _analyzeImageWithGemini(File imageFile) async {
    try {
      final model = GenerativeModel(model: 'gemini-2.5-flash', apiKey: _apiKey);
      final imageBytes = await imageFile.readAsBytes();

      final prompt = TextPart(
        "Act as an e-commerce assistant listing this item for sale. "
            "Analyze the image and generate a sales listing. "
            "Return a single JSON object with these exact keys:\n"
            "- 'title': A short, clear product name (max 5 words).\n"
            "- 'description': ONE attractive sentence describing the item's utility or material. "
            "Do NOT describe the background, lighting, timestamp, or camera angle. Keep it under 15 words.\n"
            "- 'category': A standard e-commerce category.\n"
            "Do not include any other text or markdown.",
      );

      final response = await model.generateContent([
        Content.multi([prompt, DataPart('image/jpeg', imageBytes)]),
      ]);

      if (response.text != null) {
        String cleanText = response.text!
            .replaceAll('```json', '')
            .replaceAll('```', '')
            .trim();

        final Map<String, dynamic> data = jsonDecode(cleanText);

        // AUTO-FILL the form data once AI responds!
        setState(() {
          _aiSuggestedName = data['title'];
          _aiSuggestedDescription = data['description'];
          _aiSuggestedCategory = data['category'];
          _isAiDone = true; // Mark that suggestions are ready
        });

        return AiProductResult(
          title: _aiSuggestedName!,
          description: _aiSuggestedDescription!,
          category: _aiSuggestedCategory!,
        );
      }
    } catch (e) {
      print("AI Critical Error: $e");
    }
    return null;
  }



  void _nextStep() {
    if (_currentStep < 5) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _currentStep++);
    } else {
      // --- SAVE LOGIC ---
      final appState = Provider.of<AppState>(context, listen: false);

      final newProduct = Product(
        id: DateTime.now().toString(), // Temporary ID
        name: _name,
        category: _category,
        description: _description,
        price: double.tryParse(_price) ?? 0.0,
        quantity: int.tryParse(_quantity) ?? 0,
        imageFile: _imageFile,
      );

      // Add to global state
      appState.addProduct(newProduct);

      // Print JSON to console for your teammate to see
      print("READY FOR BACKEND: ${jsonEncode(newProduct.toJson())}");

      // Show success feedback
      _tts.speak(appState.selectedLang == 'Hindi'
          ? "आपका सामान जुड़ गया है"
          : "Product added successfully");

      context.go(AppRoutes.editProducts);
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

  void _listen(String fieldName) async {
    final appState = Provider.of<AppState>(context, listen: false);

    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() {
          _isListening = true;
          _activeField = fieldName;
        });

        _speech.listen(
          localeId: appState.locale,
          onResult: (val) {
            setState(() {
              String text = val.recognizedWords;
              if (fieldName == "name") _name = text;
              if (fieldName == "description") _description = text;
              if (fieldName == "price") _price = text.replaceAll(RegExp(r'[^0-9]'), ''); // Keep only numbers
              if (fieldName == "quantity") _quantity = text.replaceAll(RegExp(r'[^0-9]'), '');
            });

            if (val.finalResult) {
              setState(() => _isListening = false);
            }
          },
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

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
                  title: "Add Product Photo",
                  audioText: "Take a photo of your product",
                  content: _buildPhotoInput(),
                ),
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
                ),
                _buildStep(
                  title: "Set Price (₹)",
                  audioText: "Say the price in rupees",
                  content: _buildPriceInput(),
                ),
                _buildStep(
                  title: "Quantity Available",
                  audioText: "How many items do you have?",
                  content: _buildQuantityInput(),
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
          AudioPrompt(
              text: audioText,
              onPlay: () => _tts.speak(audioText)
          ),
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

  Widget _buildValueDisplay(String value, String placeholder, {bool isAiProcessing = false}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: isAiProcessing
            ? Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.5))
            : null,
      ),
      child: isAiProcessing
          ? Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 12),
          Text("AI is generating...",
              style: TextStyle(color: Theme.of(context).colorScheme.primary)),
        ],
      )
          : Text(
        value.isEmpty ? placeholder : value,
        style: Theme.of(context).textTheme.bodyLarge,
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildNameInput() {
    return SingleChildScrollView(
      child: Column(
        children: [
          VoiceButton(
            onTap: () => _listen("name"),
            isListening: _isListening && _activeField == "name",
            label: "Tap to Speak Name",
          ),
          const SizedBox(height: 20),
          // TextField for manual editing
          TextField(
            controller: TextEditingController(text: _name)..selection = TextSelection.collapsed(offset: _name.length),
            onChanged: (val) => _name = val,
            decoration: const InputDecoration(border: OutlineInputBorder(), labelText: "Product Name"),
          ),

          // Show Suggestion if AI found something different
          if (_aiSuggestedName != null && _aiSuggestedName != _name)
            _buildAiSuggestion(
              suggestion: _aiSuggestedName!,
              onAccept: () => setState(() { _name = _aiSuggestedName!; _aiSuggestedName = null; }),
              onReject: () => setState(() => _aiSuggestedName = null),
            ),

          // Loading state if AI is still working
          if (!_isAiDone && _aiTask != null)
            _buildAiThinking("crafting a name"),
        ],
      ),
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
    final theme = Theme.of(context);
    return SingleChildScrollView( // Added scroll just in case the keyboard pops up
      child: Column(
        children: [
          VoiceButton(
            onTap: () => _listen("description"),
            isListening: _isListening && _activeField == "description",
            label: "Tap to Describe",
          ),
          const SizedBox(height: 24),

          TextField(
            maxLines: 4, // More space for descriptions
            controller: TextEditingController(text: _description)
              ..selection = TextSelection.collapsed(offset: _description.length),
            onChanged: (val) => _description = val,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              labelText: "Product Description",
              hintText: "Enter or speak details about your item...",
              alignLabelWithHint: true,
              // Match system colors
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
              ),
            ),
          ),

          FutureBuilder(
            future: _aiTask,
            builder: (context, snapshot) {
              // 1. Show pulsating "Thinking" if AI is still working
              if (snapshot.connectionState == ConnectionState.waiting) {
                return _buildAiThinking("generating a description");
              }

              // 2. Show AI Suggestion if it exists and is different from current text
              if (_isAiDone &&
                  _aiSuggestedDescription != null &&
                  _aiSuggestedDescription != _description) {
                return _buildAiSuggestion(
                  suggestion: _aiSuggestedDescription!,
                  onAccept: () => setState(() {
                    _description = _aiSuggestedDescription!;
                    _aiSuggestedDescription = null;
                  }),
                  onReject: () => setState(() => _aiSuggestedDescription = null),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPriceInput() {
    final theme = Theme.of(context);
    return Column(
      children: [
        VoiceButton(
          onTap: () => _listen("price"),
          isListening: _isListening && _activeField == "price",
          label: "Tap to Say Price",
        ),
        const SizedBox(height: 40),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text("₹",
                style: theme.textTheme.displayMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold
                )
            ),
            const SizedBox(width: 8),
            IntrinsicWidth( // This makes the text field only as wide as the input
              child: TextField(
                keyboardType: TextInputType.number,
                controller: TextEditingController(text: _price)
                  ..selection = TextSelection.collapsed(offset: _price.length),
                onChanged: (val) => setState(() => _price = val.replaceAll(RegExp(r'[^\d]'), '')),
                style: theme.textTheme.displayMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
                decoration: InputDecoration(
                  hintText: "--",
                  hintStyle: TextStyle(color: theme.colorScheme.outline.withOpacity(0.3)),
                  border: InputBorder.none, // Removes the line
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuantityInput() {
    final theme = Theme.of(context);
    return Column(
      children: [
        VoiceButton(
          onTap: () => _listen("quantity"),
          isListening: _isListening && _activeField == "quantity",
          label: "Tap to Say Quantity",
        ),
        const SizedBox(height: 40),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            IntrinsicWidth(
              child: TextField(
                keyboardType: TextInputType.number,
                controller: TextEditingController(text: _quantity)
                  ..selection = TextSelection.collapsed(offset: _quantity.length),
                onChanged: (val) => setState(() => _quantity = val.replaceAll(RegExp(r'[^\d]'), '')),
                textAlign: TextAlign.center,
                style: theme.textTheme.displayMedium?.copyWith(fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  hintText: "--",
                  hintStyle: TextStyle(color: theme.colorScheme.outline.withOpacity(0.3)),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text("units", style: theme.textTheme.headlineMedium),
          ],
        ),
      ],
    );
  }

  Widget _buildAiSuggestion({
    required String suggestion,
    required VoidCallback onAccept,
    required VoidCallback onReject,
  }) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer.withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.secondary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome, size: 18, color: theme.colorScheme.secondary),
              const SizedBox(width: 8),
              Text("AI Suggestion",
                  style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.secondary,
                      fontWeight: FontWeight.bold
                  )
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(suggestion, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                  onPressed: onReject,
                  child: Text("Discard", style: TextStyle(color: theme.colorScheme.error))
              ),
              ElevatedButton(
                onPressed: onAccept,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                ),
                child: const Text("Accept"),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAiThinking(String label) {
    final theme = Theme.of(context);
    return FadeTransition(
      opacity: CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.auto_awesome, size: 16, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              "AI is $label for you...",
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoInput() {
    return Column(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () async {
              final XFile? photo = await _picker.pickImage(
                source: ImageSource.camera,
                imageQuality: 100,
              );

              if (photo != null) {
                File file = File(photo.path);
                setState(() {
                  _imageFile = file;
                  _hasPhoto = true;
                  // This kicks off the logic from File 1
                  _aiTask = _processAndAnalyzeImage(file);
                });

                // Move to next step immediately while AI works in background
                _nextStep();
              }
            },
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(20),
                image: _hasPhoto && _imageFile != null
                    ? DecorationImage(image: FileImage(_imageFile!), fit: BoxFit.cover)
                    : null,
              ),
              child: !_hasPhoto
                  ? const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.camera_alt, size: 64),
                  SizedBox(height: 16),
                  Text("Tap to Take Photo", style: TextStyle(fontSize: 18)),
                ],
              )
                  : null,
            ),
          ),
        ),
      ],
    );
  }
}
