import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../services/supabase_service.dart';
import '../../widgets/ask_ai_dialog.dart';

class AlertsTab extends StatefulWidget {
  const AlertsTab({super.key});

  @override
  State<AlertsTab> createState() => _AlertsTabState();
}

class _AlertsTabState extends State<AlertsTab> {
  final _searchController = TextEditingController(text: 'react');
  String _ecosystem = 'npm';
  List<dynamic> _vulnerabilities = [];
  bool _isLoading = false;
  final _supabaseService = SupabaseService();

  @override
  void initState() {
    super.initState();
    _fetchAlerts();
  }

  Future<void> _fetchAlerts() async {
    if (_searchController.text.isEmpty) return;
    setState(() => _isLoading = true);
    try {
      final vulns = await ApiService.fetchVulnerabilities(_searchController.text.trim(), _ecosystem == 'pub' ? 'Pub' : 'npm');
      setState(() {
        _vulnerabilities = vulns;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to fetch vulnerabilities: $e')));
    }
  }
  
  Future<void> _saveAlert(dynamic vuln) async {
    try {
      await _supabaseService.saveItem('alert', vuln['id'], {
        'id': vuln['id'],
        'summary': vuln['summary'] ?? vuln['id'],
        'details': vuln['details'] ?? '',
      });
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Alert saved!')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to save: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    labelText: 'Package Name',
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: (_) => _fetchAlerts(),
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
                onPressed: _fetchAlerts,
                child: const Icon(Icons.search),
              ),
            ],
          ),
        ),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _vulnerabilities.isEmpty
                  ? const Center(child: Text('No vulnerabilities found.'))
                  : ListView.builder(
                      itemCount: _vulnerabilities.length,
                      itemBuilder: (context, index) {
                        final vuln = _vulnerabilities[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: ListTile(
                            leading: const Icon(Icons.warning, color: Colors.red),
                            title: Text(vuln['summary'] ?? vuln['id'], style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('ID: ${vuln['id']}'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.auto_awesome, color: Colors.blue),
                                  onPressed: () {
                                    AskAiDialog.show(
                                      context,
                                      title: vuln['id'] ?? 'Vulnerability',
                                      contextData: "ID: \${vuln['id']}\\nSummary: \${vuln['summary'] ?? 'No summary'}\\nDetails: \${vuln['details'] ?? 'No details'}",
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.bookmark_border),
                                  onPressed: () => _saveAlert(vuln),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }
}
