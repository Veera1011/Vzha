import 'package:flutter/material.dart';
import '../../services/supabase_service.dart';

class SavedTab extends StatefulWidget {
  const SavedTab({super.key});

  @override
  State<SavedTab> createState() => _SavedTabState();
}

class _SavedTabState extends State<SavedTab> {
  final _supabaseService = SupabaseService();
  List<Map<String, dynamic>> _savedItems = [];
  bool _isLoading = true;
  String? _filterType;

  @override
  void initState() {
    super.initState();
    _loadSavedItems();
  }

  Future<void> _loadSavedItems() async {
    setState(() => _isLoading = true);
    try {
      final items = await _supabaseService.getSavedItems(type: _filterType);
      setState(() {
        _savedItems = items;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> _deleteItem(String itemId) async {
    try {
      await _supabaseService.deleteSavedItem(itemId);
      _loadSavedItems();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to delete: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ChoiceChip(
                  label: const Text('All'),
                  selected: _filterType == null,
                  onSelected: (val) {
                    if (val) {
                      setState(() => _filterType = null);
                      _loadSavedItems();
                    }
                  },
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('News'),
                  selected: _filterType == 'news',
                  onSelected: (val) {
                    if (val) {
                      setState(() => _filterType = 'news');
                      _loadSavedItems();
                    }
                  },
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Packages'),
                  selected: _filterType == 'package',
                  onSelected: (val) {
                    if (val) {
                      setState(() => _filterType = 'package');
                      _loadSavedItems();
                    }
                  },
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Alerts'),
                  selected: _filterType == 'alert',
                  onSelected: (val) {
                    if (val) {
                      setState(() => _filterType = 'alert');
                      _loadSavedItems();
                    }
                  },
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _savedItems.isEmpty
                  ? const Center(child: Text('No items saved.'))
                  : RefreshIndicator(
                      onRefresh: _loadSavedItems,
                      child: ListView.builder(
                        itemCount: _savedItems.length,
                        itemBuilder: (context, index) {
                          final item = _savedItems[index];
                          final data = item['item_data'];
                          final type = item['item_type'];
                          
                          IconData icon;
                          String title;
                          String subtitle;
                          
                          if (type == 'news') {
                            icon = Icons.article;
                            title = data['title'] ?? 'Unknown News';
                            subtitle = data['source'] ?? '';
                          } else if (type == 'package') {
                            icon = Icons.inventory_2;
                            title = data['name'] ?? 'Unknown Package';
                            subtitle = 'Latest: ${data['latest_version']} (${data['ecosystem']})';
                          } else {
                            icon = Icons.warning;
                            title = data['summary'] ?? data['id'] ?? 'Unknown Alert';
                            subtitle = 'Alert ID: ${data['id']}';
                          }

                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: ListTile(
                              leading: Icon(icon, color: Theme.of(context).primaryColor),
                              title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text(subtitle),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteItem(item['item_id']),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
        ),
      ],
    );
  }
}
