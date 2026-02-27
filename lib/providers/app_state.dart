import 'package:flutter/material.dart';
import '../models/product.dart';

class AppState extends ChangeNotifier {
  // Our global state variables
  String _selectedLang = 'English';
  String _locale = 'en-US';

  String get selectedLang => _selectedLang;
  String get locale => _locale;

  // The "Setter" that notifies the whole app
  void setLanguage(String lang, String localeCode) {
    _selectedLang = lang;
    _locale = localeCode;

    // rebuild UI on state change
    notifyListeners();
  }

  final List<Product> _myProducts = [];
  List<Product> get myProducts => _myProducts;

  void addProduct(Product product) {
    _myProducts.add(product);
    notifyListeners();
  }
}