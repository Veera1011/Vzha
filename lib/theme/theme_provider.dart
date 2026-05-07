import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _colorKey = 'primary_color';
  static const String _fontKey = 'font_family';
  static const String _sizeKey = 'font_size';
  static const String _darkKey = 'is_dark_mode';
  static const String _fontColorKey = 'font_color';


  final List<String> availableFonts = const [
    'Inter',
    'Roboto',
    'Poppins',
    'Outfit'
  ];

  final List<double> availableSizes = const [0.8, 1.0, 1.2]; // Small, Normal, Large

  // Current states
  Color _primaryColor = const Color(0xFF007185);
  Color? _fontColor;
  String _fontFamily = 'Inter';
  double _fontSizeScale = 1.0;
  bool _isDarkMode = false;

  // Getters
  Color get primaryColor => _primaryColor;
  Color? get fontColor => _fontColor;
  String get fontFamily => _fontFamily;
  double get fontSizeScale => _fontSizeScale;
  bool get isDarkMode => _isDarkMode;

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
    
    // Load Dark Mode
    _isDarkMode = prefs.getBool(_darkKey) ?? false;

    // Load Font Color
    int? fontColorValue = prefs.getInt(_fontColorKey);
    if (fontColorValue != null) {
      _fontColor = Color(fontColorValue);
    }
    
    notifyListeners();
  }

  Future<void> setPrimaryColor(Color color) async {
    _primaryColor = color;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt(_colorKey, color.value);
  }

  Future<void> setFontColor(Color? color) async {
    _fontColor = color;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    if (color == null) {
      prefs.remove(_fontColorKey);
    } else {
      prefs.setInt(_fontColorKey, color.value);
    }
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

  Future<void> toggleDarkMode() async {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool(_darkKey, _isDarkMode);
  }
}
