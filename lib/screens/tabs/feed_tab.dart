import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/api_service.dart';
import '../../services/supabase_service.dart';

class FeedTab extends StatefulWidget {
  const FeedTab({super.key});

  @override
  State<FeedTab> createState() => _FeedTabState();
}

class _FeedTabState extends State<FeedTab> {
  List<dynamic> _articles = [];
  bool _isLoading = true;
  final _supabaseService = SupabaseService();

  @override
  void initState() {
    super.initState();
    _loadNews();
  }

  Future<void> _loadNews() async {
    try {
      final news = await ApiService.fetchTechNews();
      setState(() {
        _articles = news;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
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
      await _supabaseService.saveItem('news', article['id'].toString(), {
        'title': article['title'],
        'url': article['url'],
        'source': 'Dev.to',
      });
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Article saved!')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to save: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    return RefreshIndicator(
      onRefresh: _loadNews,
      child: ListView.builder(
        itemCount: _articles.length,
        padding: const EdgeInsets.all(8.0),
        itemBuilder: (context, index) {
          final article = _articles[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16.0),
              title: Text(article['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(article['description'] ?? '', maxLines: 2, overflow: TextOverflow.ellipsis),
              trailing: IconButton(
                icon: const Icon(Icons.bookmark_border),
                onPressed: () => _saveArticle(article),
              ),
              onTap: () => _openArticle(article['url']),
            ),
          );
        },
      ),
    );
  }
}
