// import 'dart:io';
// import 'dart:convert';
// // import 'package:google_generative_ai/google_generative_ai.dart';
//
// class AiProductResult {
//   final String title;
//   final String description;
//   final String category;
//
//   AiProductResult({required this.title, required this.description, required this.category});
// }
//
// class AiService {
//   static const String _apiKey = 'YOUR_API_KEY'; // Use environment variables for safety
//
//   static Future<AiProductResult?> analyzeImage(File imageFile) async {
//     try {
//       final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: _apiKey);
//       final imageBytes = await imageFile.readAsBytes();
//
//       final prompt = TextPart(
//           "Analyze this item and return a JSON object with keys 'title' (max 5 words), "
//               "'description' (max 15 words), and 'category'. Do not include markdown."
//       );
//
//       final response = await model.generateContent([
//         Content.multi([prompt, DataPart('image/jpeg', imageBytes)]),
//       ]);
//
//       if (response.text != null) {
//         final Map<String, dynamic> data = jsonDecode(response.text!.replaceAll('```json', '').replaceAll('```', '').trim());
//         return AiProductResult(
//           title: data['title'] ?? "Unknown Item",
//           description: data['description'] ?? "",
//           category: data['category'] ?? "General",
//         );
//       }
//     } catch (e) {
//       print("Gemini Error: $e");
//     }
//     return null;
//   }
// }