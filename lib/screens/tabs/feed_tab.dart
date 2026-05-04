import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/supabase_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../widgets/ask_ai_dialog.dart';

class FeedTab extends StatefulWidget {
  const FeedTab({super.key});

  @override
  State<FeedTab> createState() => _FeedTabState();
}

class _FeedTabState extends State<FeedTab> {
  List<dynamic> _articles = [];
  bool _isLoading = true;
  final _supabaseService = SupabaseService();
  String _selectedSource = 'All';
  
  final List<String> _availableSources = ['All', 'Dev.to', 'Hacker News', 'GitHub Trending'];

  @override
  void initState() {
    super.initState();
    _loadPreferencesAndNews();
  }

  Future<void> _loadPreferencesAndNews() async {
    final prefs = await SharedPreferences.getInstance();
    final savedSource = prefs.getString('preferred_news_source');
    if (savedSource != null && _availableSources.contains(savedSource)) {
      _selectedSource = savedSource;
    }
    _loadNews();
  }

  Future<void> _loadNews() async {
    setState(() => _isLoading = true);
    try {
      final news = await _supabaseService.getNewsFeed(_selectedSource);
      setState(() {
        _articles = news;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }
  
  Future<void> _changeSource(String newSource) async {
    setState(() {
      _selectedSource = newSource;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('preferred_news_source', newSource);
    _loadNews();
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
    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            children: _availableSources.map((source) {
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ChoiceChip(
                  label: Text(source),
                  selected: _selectedSource == source,
                  onSelected: (selected) {
                    if (selected) _changeSource(source);
                  },
                ),
              );
            }).toList(),
          ),
        ),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: _loadNews,
                  child: ListView.builder(
                    itemCount: _articles.length,
                    padding: const EdgeInsets.all(8.0),
                    itemBuilder: (context, index) {
                      final article = _articles[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: () => _openArticle(article['url']),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (article['image_url'] != null)
                                Image.network(
                                  article['image_url'],
                                  height: 180,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const SizedBox(height: 10),
                                ),
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(article['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                          const SizedBox(height: 4),
                                          if (article['description'] != null)
                                            Text(article['description'], maxLines: 2, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodyMedium),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.auto_awesome, color: Colors.blue),
                                      onPressed: () {
                                        AskAiDialog.show(
                                          context,
                                          title: article['title'] ?? 'Article',
                                          contextData: "Title: \${article['title']}\\nDescription: \${article['description'] ?? 'No description'}",
                                        );
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.bookmark_border),
                                      onPressed: () => _saveArticle(article),
                                    ),
                                  ],
                                ),
                              ),
                            ],
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
