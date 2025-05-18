import 'dart:convert';
import 'package:http/http.dart' as http;

class LyricService {
  final Map<String, Map<String, dynamic>> _cache = {};

  Future<Map<String, dynamic>> fetchLyric(String songName) async {
    // Check cache first
    if (_cache.containsKey(songName)) {
      return _cache[songName]!;
    }

    final url =
        'https://backend-get-lyric-music.onrender.com/searchlyric/$songName';

    try {
      final response = await http
          .get(Uri.parse(url), headers: {'Connection': 'keep-alive'})
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Save to cache
        _cache[songName] = data;
        return data;
      } else {
        throw Exception('Failed to load lyric: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}
