import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/theme_provider.dart';

import 'package:flutter_colorpicker/flutter_colorpicker.dart';

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
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: themeProvider.primaryColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey, width: 2),
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      Color pickerColor = themeProvider.primaryColor;
                      return AlertDialog(
                        title: const Text('Pick a color!'),
                        content: SingleChildScrollView(
                          child: ColorPicker(
                            pickerColor: pickerColor,
                            onColorChanged: (Color color) {
                              pickerColor = color;
                            },
                          ),
                        ),
                        actions: <Widget>[
                          ElevatedButton(
                            child: const Text('Apply'),
                            onPressed: () {
                              themeProvider.setPrimaryColor(pickerColor);
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
                child: const Text('Pick Color'),
              ),
            ],
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
