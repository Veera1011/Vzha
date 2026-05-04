import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../services/supabase_service.dart';
import '../../widgets/ask_ai_dialog.dart';

class PackagesTab extends StatefulWidget {
  const PackagesTab({super.key});

  @override
  State<PackagesTab> createState() => _PackagesTabState();
}

class _PackagesTabState extends State<PackagesTab> {
  final _searchController = TextEditingController();
  String _ecosystem = 'npm';
  Map<String, dynamic>? _packageData;
  bool _isLoading = false;
  final _supabaseService = SupabaseService();

  Future<void> _searchPackage() async {
    if (_searchController.text.isEmpty) return;
    setState(() => _isLoading = true);
    
    try {
      Map<String, dynamic> data;
      if (_ecosystem == 'npm') {
        data = await ApiService.fetchNpmPackage(_searchController.text.trim());
      } else {
        data = await ApiService.fetchPubPackage(_searchController.text.trim());
      }
      setState(() {
        _packageData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _packageData = null;
        _isLoading = false;
      });
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> _savePackage() async {
    if (_packageData == null) return;
    try {
      await _supabaseService.saveItem('package', _packageData!['name'], {
        'name': _packageData!['name'],
        'latest_version': _packageData!['latest_version'],
        'ecosystem': _ecosystem,
      });
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Package saved!')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to save: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    labelText: 'Package Name',
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: (_) => _searchPackage(),
                ),
              ),
              const SizedBox(width: 8),
              DropdownButton<String>(
                value: _ecosystem,
                items: const [
                  DropdownMenuItem(value: 'npm', child: Text('npm')),
                  DropdownMenuItem(value: 'pub', child: Text('pub.dev')),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _ecosystem = val);
                },
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _searchPackage,
                child: const Icon(Icons.search),
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (_isLoading) const CircularProgressIndicator(),
          if (_packageData != null && !_isLoading)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(_packageData!['name'], style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 8),
                    if (_packageData!['description'] != null) ...[
                      Text(_packageData!['description']),
                      const SizedBox(height: 8),
                    ],
                    Text('Latest Version: ${_packageData!['latest_version']}', 
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.bookmark),
                            label: const Text('Save Package'),
                            onPressed: _savePackage,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.auto_awesome, color: Colors.blue),
                            label: const Text('Ask AI'),
                            onPressed: () {
                              AskAiDialog.show(
                                context,
                                title: _packageData!['name'],
                                contextData: "Package Name: \${_packageData!['name']}\\nDescription: \${_packageData!['description'] ?? 'No description'}\\nLatest Version: \${_packageData!['latest_version']}\\nEcosystem: \$_ecosystem",
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
