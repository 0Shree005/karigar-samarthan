import 'dart:io';
import 'package:dio/dio.dart';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';


class WooCommerceService {
  static final String _ck = dotenv.env['CK'] ?? '';
  static final String _cs = dotenv.env['CS'] ?? '';
  static final String _wpUser = dotenv.env['WPusername'] ?? '';
  static final String _wpPass = dotenv.env['AP'] ?? '';


  final String baseUrl = "https://jstrust.in/wp-json/wc/v3/";
  final String consumerKey = _ck;
  final String consumerSecret = _cs;
  final String wpUsername = _wpUser;
  final String wpPassword = _wpPass;

  late Dio _dio;

  WooCommerceService() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      headers: {
        'Authorization': 'Basic ${base64Encode(utf8.encode('$consumerKey:$consumerSecret'))}',
        'Content-Type': 'application/json',
      },
    ));
  }

  Future<int?> uploadImage(File imageFile) async {
    try {
      String fileName = imageFile.path.split('/').last;
      List<int> imageBytes = await imageFile.readAsBytes();

      String wpAuth = base64Encode(utf8.encode('$wpUsername:$wpPassword'));

      final response = await _dio.post(
        "https://jstrust.in/wp-json/wp/v2/media",
        data: Stream.fromIterable(imageBytes.map((e) => [e])),
        options: Options(
          headers: {
            'Authorization': 'Basic $wpAuth',
            'Content-Disposition': 'attachment; filename="$fileName"',
            'Content-Type': 'image/jpeg', // Force the type
          },
        ),
      );

      if (response.statusCode == 201) {
        print("✅ IMAGE UPLOADED! Media ID: ${response.data['id']}");
        return response.data['id']; 
      }
    } on DioException catch (e) {
      // THIS IS THE CRITICAL LOG:
      print("❌ SERVER ERROR MESSAGE: ${e.response?.data}");
      print("❌ STATUS CODE: ${e.response?.statusCode}");
    }
    return null;
  }

  // Pushes the product to the website
Future<bool> pushProduct({
    required String name,
    required String description,
    required String price,
    required int categoryId,
    int? imageId, // New parameter
    String? karigarName,
  }) async {
    try {
      final Map<String, dynamic> productData = {
        "name": name,
        "type": "simple",
        "regular_price": price,
        "description": description,
        "status": "pending",
        "categories": [{"id": categoryId}],
        "meta_data": [
          {"key": "_ks_karigar_name", "value": karigarName ?? "App User"},
          {"key": "_ks_needs_review", "value": "yes"},
          {"key": "_created_via", "value": "Karigar-Samarthan-Flutter"}
        ],
      };

      // If we have an image ID, attach it!
      if (imageId != null) {
        productData["images"] = [
          {"id": imageId}
        ];
      }

      final response = await _dio.post("products", data: productData);
      return response.statusCode == 201;
    } catch (e) {
      print("❌ PUSH ERR: $e");
      return false;
    }
  }
  
  // Helper to fetch all categories dynamically
  Future<List<dynamic>> getCategories() async {
    try {
      final response = await _dio.get("products/categories");
      return response.data;
    } catch (e) {
      print("❌ FETCH CAT ERR: $e");
      return [];
    }
  }
}