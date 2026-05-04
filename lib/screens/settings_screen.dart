import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text('Theme Color', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            children: themeProvider.availableColors.map((color) {
              final isSelected = themeProvider.primaryColor == color;
              return GestureDetector(
                onTap: () => themeProvider.setPrimaryColor(color),
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? Colors.black : Colors.transparent,
                      width: 3,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          const Text('Font Family', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Card(
            margin: EdgeInsets.zero,
            child: Column(
              children: themeProvider.availableFonts.map((font) {
                return RadioListTile<String>(
                  title: Text(font, style: TextStyle(fontFamily: font)),
                  value: font,
                  groupValue: themeProvider.fontFamily,
                  onChanged: (value) {
                    if (value != null) themeProvider.setFontFamily(value);
                  },
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 24),
          const Text('Font Size', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  const Text('A', style: TextStyle(fontSize: 14)),
                  Expanded(
                    child: Slider(
                      value: themeProvider.fontSizeScale,
                      min: 0.8,
                      max: 1.2,
                      divisions: 2,
                      label: themeProvider.fontSizeScale == 0.8 
                        ? 'Small' 
                        : (themeProvider.fontSizeScale == 1.2 ? 'Large' : 'Normal'),
                      onChanged: (value) {
                        themeProvider.setFontSizeScale(value);
                      },
                    ),
                  ),
                  const Text('A', style: TextStyle(fontSize: 24)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
