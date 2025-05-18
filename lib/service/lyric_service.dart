import 'dart:convert';
import 'package:http/http.dart' as http;

class LyricService {
  Future<Map<String, dynamic>> fetchLyric(String songName) async {
    final encodedSongName = Uri.encodeComponent(songName);
    final url =
        'https://backend-get-lyric-music.onrender.com/searchlyric/$encodedSongName';
    print('Calling API: $url'); // Debug
    final response = await http
        .get(Uri.parse(url), headers: {'Connection': 'keep-alive'})
        .timeout(const Duration(seconds: 10));

    print('API status code: ${response.statusCode}'); // Debug
    print('API response body: ${response.body}'); // Debug

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load lyric: ${response.statusCode}');
    }
  }
}
