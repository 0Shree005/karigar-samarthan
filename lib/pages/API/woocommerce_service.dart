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
// lib/pages/API/woocommerce_service.dart

  Future<String?> pushProduct({
    required String name,
    required String description,
    required String price,
    required int categoryId,
    int? imageId,
    String? karigarName,
  }) async {
    try {
      final Map<String, dynamic> productData = {
        "name": name,
        "type": "simple",
        "regular_price": price,
        "description": description,
        "status": "publish", // CHANGE: Products go live immediately!
        "categories": [{"id": categoryId}],
        "meta_data": [
          {"key": "_ks_karigar_name", "value": karigarName ?? "App User"},
          // Removed "_ks_needs_review" as it's no longer mandatory for the app
          {"key": "_created_via", "value": "Karigar-Samarthan-Flutter"}
        ],
      };

      if (imageId != null) {
        productData["images"] = [{"id": imageId}];
      }

      final response = await _dio.post("products", data: productData);
    
      if (response.statusCode == 201) {
        return response.data['permalink']; 
      }
    } catch (e) {
      print("❌ PUSH ERR: $e");
    }
    return null;
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