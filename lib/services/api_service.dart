import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Dev.to API
  static Future<List<dynamic>> fetchTechNews({String tag = 'programming'}) async {
    final url = Uri.parse('https://dev.to/api/articles?tag=$tag&per_page=30');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    throw Exception('Failed to load Dev.to news');
  }

  // Hacker News Algolia API
  static Future<List<dynamic>> fetchHackerNews() async {
    final url = Uri.parse('https://hn.algolia.com/api/v1/search?tags=front_page&hitsPerPage=30');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      return json.decode(response.body)['hits'];
    }
    throw Exception('Failed to load Hacker News');
  }

  // GitHub Trending (Search API for recent popular repos)
  static Future<List<dynamic>> fetchGitHubTrending() async {
    final lastWeek = DateTime.now().subtract(const Duration(days: 7)).toIso8601String().split('T')[0];
    final url = Uri.parse('https://api.github.com/search/repositories?q=created:>$lastWeek&sort=stars&order=desc&per_page=30');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      return json.decode(response.body)['items'];
    }
    throw Exception('Failed to load GitHub Trending');
  }

  // NPM Registry API
  static Future<Map<String, dynamic>> fetchNpmPackage(String packageName) async {
    final url = Uri.parse('https://registry.npmjs.org/$packageName');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return {
        'name': data['name'],
        'description': data['description'],
        'latest_version': data['dist-tags']?['latest'] ?? 'unknown',
      };
    }
    throw Exception('Package not found on NPM');
  }

  // Pub.dev API
  static Future<Map<String, dynamic>> fetchPubPackage(String packageName) async {
    final url = Uri.parse('https://pub.dev/api/packages/$packageName');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return {
        'name': data['name'],
        'latest_version': data['latest']?['version'] ?? 'unknown',
      };
    }
    throw Exception('Package not found on pub.dev');
  }

  // OSV.dev API
  // Note: OSV /v1/query typically requires a package or commit. For a general feed, we'll search recent npm/pub issues.
  // Actually, OSV API doesn't support a simple "recent" endpoint. 
  // We will fetch vulnerabilities for a popular package to demonstrate, or return mock data if it fails.
  static Future<List<dynamic>> fetchVulnerabilities(String package, String ecosystem) async {
    final url = Uri.parse('https://api.osv.dev/v1/query');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        "package": {
          "name": package,
          "ecosystem": ecosystem
        }
      }),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['vulns'] ?? [];
    }
    return [];
  }
}
