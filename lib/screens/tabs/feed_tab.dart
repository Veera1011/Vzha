import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/supabase_service.dart';
import '../../widgets/ask_ai_dialog.dart';
import '../../widgets/shimmer_skeleton.dart';
import 'package:share_plus/share_plus.dart';

class FeedTab extends StatefulWidget {
  const FeedTab({super.key});

  @override
  State<FeedTab> createState() => _FeedTabState();
}

class _FeedTabState extends State<FeedTab> with SingleTickerProviderStateMixin {
  static const _sources = ['All', 'Dev.to', 'Hacker News', 'GitHub Trending'];
  late TabController _tabController;
  final _supabaseService = SupabaseService();

  // One list + loading flag per tab
  final List<List<dynamic>> _articles = List.generate(_sources.length, (_) => []);
  final List<bool> _loading = List.generate(_sources.length, (_) => false);
  final List<bool> _loaded = List.generate(_sources.length, (_) => false);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _sources.length, vsync: this);
    _tabController.addListener(_onTabChange);
    _loadTab(0); // preload "All"
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChange);
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChange() {
    if (!_tabController.indexIsChanging) {
      final i = _tabController.index;
      if (!_loaded[i]) _loadTab(i);
    }
  }

  Future<void> _loadTab(int index, {bool refresh = false}) async {
    if (_loading[index]) return;
    setState(() => _loading[index] = true);
    try {
      final news = await _supabaseService.getNewsFeed(_sources[index]);
      if (!mounted) return;
      setState(() {
        _articles[index] = news;
        _loaded[index] = true;
        _loading[index] = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading[index] = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> _openArticle(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _saveArticle(dynamic article) async {
    try {
      await _supabaseService.saveItem('news', article['external_id'] ?? article['url'], {
        'title': article['title'],
        'url': article['url'],
        'source': article['source'] ?? 'Dev.to',
        'image_url': article['image_url'],
      });
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Article saved!')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to save: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      children: [
        // ── TabBar ──────────────────────────────────────────────────────────
        Material(
          color: cs.surface,
          elevation: 0,
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            labelColor: cs.primary,
            unselectedLabelColor: cs.onSurfaceVariant,
            indicatorColor: cs.primary,
            indicatorWeight: 2.5,
            dividerColor: cs.outlineVariant,
            tabs: _sources.map((s) => Tab(text: s)).toList(),
          ),
        ),

        // ── TabBarView ───────────────────────────────────────────────────────
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: List.generate(_sources.length, (i) {
              return _FeedList(
                articles: _articles[i],
                isLoading: _loading[i],
                onRefresh: () => _loadTab(i, refresh: true),
                onOpenArticle: _openArticle,
                onSaveArticle: _saveArticle,
              );
            }),
          ),
        ),
      ],
    );
  }
}

// ── Feed list widget ─────────────────────────────────────────────────────────

class _FeedList extends StatelessWidget {
  final List<dynamic> articles;
  final bool isLoading;
  final Future<void> Function() onRefresh;
  final Future<void> Function(String) onOpenArticle;
  final Future<void> Function(dynamic) onSaveArticle;

  const _FeedList({
    required this.articles,
    required this.isLoading,
    required this.onRefresh,
    required this.onOpenArticle,
    required this.onSaveArticle,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    if (isLoading) return const ShimmerListLoading();

    if (articles.isEmpty) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.article_outlined, size: 56, color: cs.outlineVariant),
          const SizedBox(height: 12),
          Text('No articles yet', style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: onRefresh,
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh'),
          ),
        ]),
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: articles.length,
        itemBuilder: (context, index) {
          final article = articles[index];
          return _ArticleCard(
            article: article,
            onTap: () => onOpenArticle(article['url']),
            onSave: () => onSaveArticle(article),
          );
        },
      ),
    );
  }
}

class _ArticleCard extends StatelessWidget {
  final dynamic article;
  final VoidCallback onTap;
  final VoidCallback onSave;

  const _ArticleCard({required this.article, required this.onTap, required this.onSave});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Cover image
            if (article['image_url'] != null)
              Image.network(
                article['image_url'],
                height: 160,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),

            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Source chip
                        if (article['source'] != null)
                          Chip(
                            label: Text(article['source'], style: tt.labelSmall),
                            padding: EdgeInsets.zero,
                            visualDensity: VisualDensity.compact,
                          ),
                        const SizedBox(height: 4),
                        Text(
                          article['title'] ?? '',
                          style: tt.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (article['description'] != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            article['description'],
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                          ),
                        ],
                      ],
                    ),
                  ),
                  // Actions column
                  Column(
                    children: [
                      IconButton(
                        icon: Icon(Icons.auto_awesome, color: cs.primary, size: 20),
                        tooltip: 'Ask AI',
                        onPressed: () {
                          AskAiDialog.show(
                            context,
                            title: article['title'] ?? 'Article',
                            contextData:
                                "Title: ${article['title']}\nDescription: ${article['description'] ?? 'No description'}",
                          );
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.share_outlined, color: cs.onSurfaceVariant, size: 20),
                        tooltip: 'Share',
                        onPressed: () => Share.share('${article['title']}\n${article['url']}'),
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
          ],
        ),
      ),
    );
  }
}
