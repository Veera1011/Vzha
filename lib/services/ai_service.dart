import 'dart:convert';
import 'package:http/http.dart' as http;

class AiService {
  static const String _apiKey = String.fromEnvironment('GROQ_API_KEY', defaultValue: 'YOUR_API_KEY_HERE');
  static const String _endpoint = 'https://api.groq.com/openai/v1/chat/completions';

  Future<String> askAI(String context, String question) async {
    final prompt = '''
Context:
$context

Question/Request:
$question
''';

    final response = await http.post(
      Uri.parse(_endpoint),
      headers: {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': 'llama-3.3-70b-versatile',
        'messages': [
          {
            'role': 'user',
            'content': prompt,
          }
        ],
        'temperature': 1,
        'max_completion_tokens': 8192,
        'top_p': 1,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['choices'][0]['message']['content'];
    } else {
      throw Exception('Failed to get AI response: ${response.body}');
    }
  }
}
