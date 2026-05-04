import 'package:supabase_flutter/supabase_flutter.dart';
import 'api_service.dart';

class SupabaseService {
  final _supabase = Supabase.instance.client;

  // Database (News Feed Caching)
  Future<List<Map<String, dynamic>>> getNewsFeed(String source) async {
    final cutoff = DateTime.now().subtract(const Duration(hours: 6)).toIso8601String();
    
    // Check Cache
    var query = _supabase.from('news_feed').select().gte('created_at', cutoff).order('published_at', ascending: false).limit(30);
    
    if (source != 'All') {
      query = _supabase.from('news_feed').select().eq('source', source).gte('created_at', cutoff).order('published_at', ascending: false).limit(30);
    }

    final cachedNews = await query;
    if (cachedNews.isNotEmpty) {
      return cachedNews;
    }

    // Fetch from APIs if cache is empty or stale
    List<Map<String, dynamic>> newsToInsert = [];

    try {
      if (source == 'All' || source == 'Dev.to') {
        final devNews = await ApiService.fetchTechNews();
        for (var article in devNews) {
          newsToInsert.add({
            'external_id': 'dev_${article['id']}',
            'title': article['title'],
            'description': article['description'],
            'url': article['url'],
            'source': 'Dev.to',
            'image_url': article['social_image'] ?? article['cover_image'],
            'published_at': article['published_at'],
          });
        }
      }

      if (source == 'All' || source == 'Hacker News') {
        final hnNews = await ApiService.fetchHackerNews();
        for (var article in hnNews) {
          newsToInsert.add({
            'external_id': 'hn_${article['objectID']}',
            'title': article['title'],
            'description': 'Points: ${article['points']} | Comments: ${article['num_comments']}',
            'url': article['url'] ?? 'https://news.ycombinator.com/item?id=${article['objectID']}',
            'source': 'Hacker News',
            'image_url': null,
            'published_at': article['created_at'],
          });
        }
      }

      if (source == 'All' || source == 'GitHub Trending') {
        final ghNews = await ApiService.fetchGitHubTrending();
        for (var repo in ghNews) {
          newsToInsert.add({
            'external_id': 'gh_${repo['id']}',
            'title': repo['full_name'],
            'description': '${repo['description'] ?? ''}\n⭐ ${repo['stargazers_count']} stars | ${repo['language'] ?? 'Unknown'}',
            'url': repo['html_url'],
            'source': 'GitHub Trending',
            'image_url': repo['owner']['avatar_url'],
            'published_at': repo['created_at'],
          });
        }
      }

      if (newsToInsert.isNotEmpty) {
        // Sort if 'All'
        if (source == 'All') {
          newsToInsert.sort((a, b) => (b['published_at'] ?? '').compareTo(a['published_at'] ?? ''));
          newsToInsert = newsToInsert.take(50).toList();
        }

        await _supabase.from('news_feed').upsert(
          newsToInsert,
          onConflict: 'external_id',
        );
      }

      return newsToInsert;
    } catch (e) {
      // Fallback
      var fallbackQuery = _supabase.from('news_feed').select().order('published_at', ascending: false).limit(30);
      if (source != 'All') {
        fallbackQuery = _supabase.from('news_feed').select().eq('source', source).order('published_at', ascending: false).limit(30);
      }
      return await fallbackQuery;
    }
  }

  // Auth
  Future<AuthResponse> signUp(String email, String password) async {
    return await _supabase.auth.signUp(email: email, password: password);
  }

  Future<AuthResponse> signIn(String email, String password) async {
    return await _supabase.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  User? get currentUser => _supabase.auth.currentUser;

  // Database (Saved Items)
  Future<void> saveItem(String type, String itemId, Map<String, dynamic> data) async {
    if (currentUser == null) throw Exception('Not logged in');
    await _supabase.from('saved_items').insert({
      'user_id': currentUser!.id,
      'item_type': type,
      'item_id': itemId,
      'item_data': data,
    });
  }

  Future<List<Map<String, dynamic>>> getSavedItems({String? type}) async {
    if (currentUser == null) throw Exception('Not logged in');
    
    var query = _supabase
        .from('saved_items')
        .select()
        .eq('user_id', currentUser!.id);
        
    if (type != null) {
      query = query.eq('item_type', type);
    }
    
    return await query.order('created_at', ascending: false);
  }

  Future<void> deleteSavedItem(String itemId) async {
    if (currentUser == null) throw Exception('Not logged in');
    await _supabase
        .from('saved_items')
        .delete()
        .match({'user_id': currentUser!.id, 'item_id': itemId});
  }
}
