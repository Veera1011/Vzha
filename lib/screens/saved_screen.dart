import 'package:flutter/material.dart';
import '../../services/supabase_service.dart';

/// Saved items screen — pushed from the Drawer.
/// Has inner tabs: All | News | Packages | Alerts
class SavedScreen extends StatefulWidget {
  const SavedScreen({super.key});

  @override
  State<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends State<SavedScreen> with SingleTickerProviderStateMixin {
  static const _filters = <String, String?>{
    'All': null,
    'News': 'news',
    'Packages': 'package',
    'Alerts': 'alert',
  };

  late TabController _tabController;
  final _supabaseService = SupabaseService();

  final List<List<Map<String, dynamic>>> _items =
      List.generate(4, (_) => []);
  final List<bool> _loading = List.generate(4, (_) => false);
  final List<bool> _loaded = List.generate(4, (_) => false);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        final i = _tabController.index;
        if (!_loaded[i]) _loadTab(i);
      }
    });
    _loadTab(0);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadTab(int index) async {
    if (_loading[index]) return;
    setState(() => _loading[index] = true);
    try {
      final typeFilter = _filters.values.elementAt(index);
      final items = await _supabaseService.getSavedItems(type: typeFilter);
      if (!mounted) return;
      setState(() {
        _items[index] = items;
        _loaded[index] = true;
        _loading[index] = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading[index] = false);
    }
  }

  Future<void> _deleteItem(int tabIndex, String itemId) async {
    try {
      await _supabaseService.deleteSavedItem(itemId);
      _loadTab(tabIndex);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to delete: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: cs.primary,
          unselectedLabelColor: cs.onSurfaceVariant,
          indicatorColor: cs.primary,
          indicatorWeight: 2.5,
          dividerColor: cs.outlineVariant,
          tabs: _filters.keys.map((label) => Tab(text: label)).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: List.generate(4, (i) {
          return _SavedList(
            items: _items[i],
            isLoading: _loading[i],
            onRefresh: () => _loadTab(i),
            onDelete: (id) => _deleteItem(i, id),
          );
        }),
      ),
    );
  }
}

// ── Saved list ────────────────────────────────────────────────────────────────

class _SavedList extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  final bool isLoading;
  final Future<void> Function() onRefresh;
  final void Function(String) onDelete;

  const _SavedList({
    required this.items,
    required this.isLoading,
    required this.onRefresh,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    if (isLoading) return const Center(child: CircularProgressIndicator());

    if (items.isEmpty) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.bookmark_border, size: 64, color: cs.outlineVariant),
          const SizedBox(height: 12),
          Text('Nothing saved here yet', style: tt.titleMedium?.copyWith(color: cs.onSurfaceVariant)),
        ]),
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          final data = item['item_data'] as Map<String, dynamic>? ?? {};
          final type = item['item_type'] as String? ?? '';

          final (IconData icon, String title, String subtitle, Color iconBg, Color iconFg) = switch (type) {
            'news' => (
                Icons.article_outlined,
                data['title'] ?? 'Unknown Article',
                data['source'] ?? '',
                cs.primaryContainer,
                cs.onPrimaryContainer,
              ),
            'package' => (
                Icons.inventory_2_outlined,
                data['name'] ?? 'Unknown Package',
                'v${data['latest_version'] ?? '?'} · ${data['ecosystem'] ?? ''}',
                cs.secondaryContainer,
                cs.onSecondaryContainer,
              ),
            _ => (
                Icons.warning_amber_outlined,
                data['summary'] ?? data['id'] ?? 'Unknown Alert',
                'ID: ${data['id'] ?? '?'}',
                cs.errorContainer,
                cs.onErrorContainer,
              ),
          };

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconFg, size: 22),
              ),
              title: Text(title, style: tt.titleSmall?.copyWith(fontWeight: FontWeight.bold), maxLines: 2, overflow: TextOverflow.ellipsis),
              subtitle: Text(subtitle, style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
              trailing: IconButton(
                icon: Icon(Icons.delete_outline, color: cs.error),
                tooltip: 'Remove',
                onPressed: () => onDelete(item['item_id'] as String),
              ),
            ),
          );
        },
      ),
    );
  }
}
