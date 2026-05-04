import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _colorKey = 'primary_color';
  static const String _fontKey = 'font_family';
  static const String _sizeKey = 'font_size';

  // Available options
  final List<Color> availableColors = const [
    Color(0xFF2563EB), // Electric Blue
    Color(0xFF10B981), // Emerald Green
    Color(0xFF8B5CF6), // Purple
    Color(0xFFEF4444), // Red
  ];
  
  final List<String> availableFonts = const [
    'Inter',
    'Roboto',
    'Poppins',
    'Outfit'
  ];

  final List<double> availableSizes = const [0.8, 1.0, 1.2]; // Small, Normal, Large

  // Current states
  Color _primaryColor = const Color(0xFF2563EB);
  String _fontFamily = 'Inter';
  double _fontSizeScale = 1.0;

  // Getters
  Color get primaryColor => _primaryColor;
  String get fontFamily => _fontFamily;
  double get fontSizeScale => _fontSizeScale;

  ThemeProvider() {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Load Color
    int? colorValue = prefs.getInt(_colorKey);
    if (colorValue != null) {
      _primaryColor = Color(colorValue);
    }
    
    // Load Font
    _fontFamily = prefs.getString(_fontKey) ?? 'Inter';
    
    // Load Size
    _fontSizeScale = prefs.getDouble(_sizeKey) ?? 1.0;
    
    notifyListeners();
  }

  Future<void> setPrimaryColor(Color color) async {
    _primaryColor = color;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt(_colorKey, color.value);
  }

  Future<void> setFontFamily(String font) async {
    _fontFamily = font;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(_fontKey, font);
  }

  Future<void> setFontSizeScale(double scale) async {
    _fontSizeScale = scale;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.setDouble(_sizeKey, scale);
  }
}
