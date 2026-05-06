import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../services/supabase_service.dart';
import '../../widgets/ask_ai_dialog.dart';
import 'package:share_plus/share_plus.dart';

/// Combined "Tools" tab — inner tabs: Packages | Alerts
class ToolsTab extends StatefulWidget {
  const ToolsTab({super.key});

  @override
  State<ToolsTab> createState() => _ToolsTabState();
}

class _ToolsTabState extends State<ToolsTab> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      children: [
        Material(
          color: cs.surface,
          child: TabBar(
            controller: _tabController,
            labelColor: cs.primary,
            unselectedLabelColor: cs.onSurfaceVariant,
            indicatorColor: cs.primary,
            indicatorWeight: 2.5,
            dividerColor: cs.outlineVariant,
            tabs: const [
              Tab(icon: Icon(Icons.inventory_2_outlined, size: 18), text: 'Packages'),
              Tab(icon: Icon(Icons.warning_amber_outlined, size: 18), text: 'Alerts'),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: const [
              _PackagesView(),
              _AlertsView(),
            ],
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Packages sub-tab
// ═══════════════════════════════════════════════════════════════════════════

class _PackagesView extends StatefulWidget {
  const _PackagesView();

  @override
  State<_PackagesView> createState() => _PackagesViewState();
}

class _PackagesViewState extends State<_PackagesView> {
  final _searchController = TextEditingController();
  String _ecosystem = 'npm';
  Map<String, dynamic>? _packageData;
  bool _isLoading = false;
  final _supabaseService = SupabaseService();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchPackage() async {
    if (_searchController.text.isEmpty) return;
    setState(() => _isLoading = true);
    try {
      final data = _ecosystem == 'npm'
          ? await ApiService.fetchNpmPackage(_searchController.text.trim())
          : await ApiService.fetchPubPackage(_searchController.text.trim());
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Search row ─────────────────────────────────────────────────
          Row(
            children: [
              // Ecosystem toggle chips
              _EcosystemToggle(
                value: _ecosystem,
                onChanged: (v) => setState(() => _ecosystem = v),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: _ecosystem == 'npm' ? 'e.g. react, axios…' : 'e.g. provider, dio…',
                    prefixIcon: const Icon(Icons.search),
                  ),
                  onSubmitted: (_) => _searchPackage(),
                ),
              ),
              const SizedBox(width: 10),
              FilledButton(
                onPressed: _searchPackage,
                child: const Text('Search'),
              ),
            ],
          ),

          const SizedBox(height: 24),

          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (_packageData != null)
            _PackageResultCard(
              data: _packageData!,
              ecosystem: _ecosystem,
              onSave: _savePackage,
            )
          else
            _PackagePlaceholder(ecosystem: _ecosystem),
        ],
      ),
    );
  }
}

class _EcosystemToggle extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;
  const _EcosystemToggle({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SegmentedButton<String>(
      style: SegmentedButton.styleFrom(
        selectedBackgroundColor: cs.primaryContainer,
        selectedForegroundColor: cs.onPrimaryContainer,
      ),
      segments: const [
        ButtonSegment(value: 'npm', label: Text('npm'), icon: Icon(Icons.javascript, size: 16)),
        ButtonSegment(value: 'pub', label: Text('pub.dev'), icon: Icon(Icons.flutter_dash, size: 16)),
      ],
      selected: {value},
      onSelectionChanged: (s) => onChanged(s.first),
    );
  }
}

class _PackagePlaceholder extends StatelessWidget {
  final String ecosystem;
  const _PackagePlaceholder({required this.ecosystem});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.inventory_2_outlined, size: 64, color: cs.outlineVariant),
        const SizedBox(height: 16),
        Text('Search for a package', style: tt.titleMedium?.copyWith(color: cs.onSurfaceVariant)),
        const SizedBox(height: 4),
        Text(
          ecosystem == 'npm' ? 'Search NPM packages by name' : 'Search pub.dev packages by name',
          style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
          textAlign: TextAlign.center,
        ),
      ]),
    );
  }
}

class _PackageResultCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final String ecosystem;
  final VoidCallback onSave;

  const _PackageResultCard({required this.data, required this.ecosystem, required this.onSave});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: cs.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.inventory_2, color: cs.onPrimaryContainer, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(data['name'] ?? '', style: tt.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      Text(ecosystem, style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: cs.tertiaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'v${data['latest_version'] ?? '—'}',
                    style: tt.labelMedium?.copyWith(color: cs.onTertiaryContainer, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            if (data['description'] != null) ...[
              const SizedBox(height: 12),
              Text(data['description'], style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    icon: const Icon(Icons.bookmark, size: 16),
                    label: const Text('Save'),
                    onPressed: onSave,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: Icon(Icons.auto_awesome, size: 16, color: cs.primary),
                    label: const Text('Ask AI'),
                    onPressed: () {
                      AskAiDialog.show(
                        context,
                        title: data['name'],
                        contextData:
                            "Package: ${data['name']}\nDescription: ${data['description'] ?? 'N/A'}\nLatest Version: ${data['latest_version']}\nEcosystem: $ecosystem",
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              icon: const Icon(Icons.share_outlined, size: 16),
              label: const Text('Share Package'),
              onPressed: () {
                final url = ecosystem == 'npm'
                    ? 'https://www.npmjs.com/package/${data['name']}'
                    : 'https://pub.dev/packages/${data['name']}';
                Share.share('Check out this package: ${data['name']} (v${data['latest_version']})\n$url');
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Alerts sub-tab
// ═══════════════════════════════════════════════════════════════════════════

class _AlertsView extends StatefulWidget {
  const _AlertsView();

  @override
  State<_AlertsView> createState() => _AlertsViewState();
}

class _AlertsViewState extends State<_AlertsView> {
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchAlerts() async {
    if (_searchController.text.isEmpty) return;
    setState(() => _isLoading = true);
    try {
      final vulns = await ApiService.fetchVulnerabilities(
        _searchController.text.trim(),
        _ecosystem == 'pub' ? 'Pub' : 'npm',
      );
      setState(() {
        _vulnerabilities = vulns;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
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
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Column(
      children: [
        // ── Search header ──────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _EcosystemToggle(
                value: _ecosystem,
                onChanged: (v) => setState(() => _ecosystem = v),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        hintText: 'Package name (e.g. react)',
                        prefixIcon: Icon(Icons.search),
                      ),
                      onSubmitted: (_) => _fetchAlerts(),
                    ),
                  ),
                  const SizedBox(width: 10),
                  FilledButton(
                    onPressed: _fetchAlerts,
                    style: FilledButton.styleFrom(backgroundColor: cs.errorContainer, foregroundColor: cs.onErrorContainer),
                    child: const Text('Scan'),
                  ),
                ],
              ),
            ],
          ),
        ),

        // ── Results ────────────────────────────────────────────────────────
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _vulnerabilities.isEmpty
                  ? Center(
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        Icon(Icons.verified_user_outlined, size: 64, color: cs.outlineVariant),
                        const SizedBox(height: 12),
                        Text('No vulnerabilities found', style: tt.titleMedium?.copyWith(color: cs.onSurfaceVariant)),
                        Text('Package appears clean', style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                      ]),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: _vulnerabilities.length,
                      itemBuilder: (context, index) {
                        final vuln = _vulnerabilities[index];
                        return _VulnCard(vuln: vuln, onSave: () => _saveAlert(vuln));
                      },
                    ),
        ),
      ],
    );
  }
}

class _VulnCard extends StatelessWidget {
  final dynamic vuln;
  final VoidCallback onSave;

  const _VulnCard({required this.vuln, required this.onSave});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: cs.errorContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.warning_amber_rounded, color: cs.onErrorContainer, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    vuln['summary'] ?? vuln['id'] ?? 'Unknown',
                    style: tt.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text('ID: ${vuln['id']}', style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
                ],
              ),
            ),
            Column(
              children: [
                IconButton(
                  icon: Icon(Icons.auto_awesome, color: cs.primary, size: 20),
                  tooltip: 'Ask AI',
                  onPressed: () {
                    AskAiDialog.show(
                      context,
                      title: vuln['id'] ?? 'Vulnerability',
                      contextData: "ID: ${vuln['id']}\nSummary: ${vuln['summary'] ?? 'N/A'}\nDetails: ${vuln['details'] ?? 'N/A'}",
                    );
                  },
                ),
                IconButton(
                  icon: Icon(Icons.share_outlined, color: cs.onSurfaceVariant, size: 20),
                  tooltip: 'Share',
                  onPressed: () => Share.share('Security Alert: ${vuln['id']}\nSummary: ${vuln['summary'] ?? 'No summary'}\nhttps://osv.dev/vulnerability/${vuln['id']}'),
                ),
                IconButton(
                  icon: Icon(Icons.bookmark_border, color: cs.onSurfaceVariant, size: 20),
                  tooltip: 'Save',
                  onPressed: onSave,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
