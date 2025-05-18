import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:clone_youtube/service/youtube_service.dart';

class AddVideoPage extends StatefulWidget {
  const AddVideoPage({super.key});

  @override
  State<AddVideoPage> createState() => _AddVideoPageState();
}

class _AddVideoPageState extends State<AddVideoPage> {
  final _controller = TextEditingController();
  String? _errorMessage;

  String? _extractVideoId(String url) {
    url = url.trim();
    if (url.isEmpty) return null;
    final RegExp regex = RegExp(
      r'(?:youtube\.com\/(?:[^\/]+\/.+\/|(?:v|e(?:mbed)?)\/|.*[?&]v=)|youtu\.be\/|youtube\.com\/shorts\/)([a-zA-Z0-9_-]{11})',
      caseSensitive: false,
    );
    final match = regex.firstMatch(url);
    return match?.group(1);
  }

  Future<void> _saveVideoLink(String url) async {
    try {
      final videoId = _extractVideoId(url);
      if (videoId == null) {
        setState(() {
          _errorMessage = 'Invalid YouTube URL';
        });
        return;
      }

      final yt = YoutubeService().client;
      final video = await yt.videos.get('https://youtube.com/watch?v=$videoId');

      final prefs = await SharedPreferences.getInstance();
      final videoIds = prefs.getStringList('video_ids') ?? [];
      if (!videoIds.contains(videoId)) {
        videoIds.add(videoId);
        await prefs.setStringList('video_ids', videoIds);
        await prefs.setString('video_title_$videoId', video.title);
        await prefs.setString('video_author_$videoId', video.author);
        await prefs.setString(
          'video_duration_$videoId',
          video.duration?.toString() ?? '',
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Video added successfully')),
        );
      } else {
        setState(() {
          _errorMessage = 'Video already exists';
        });
        return;
      }

      Navigator.pop(context, true);
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: Invalid or inaccessible video';
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 71, 66, 66),
      appBar: AppBar(
        title: const Text('Add YouTube Video'),
        backgroundColor: const Color.fromARGB(255, 39, 36, 36),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'YouTube Video URL',
                labelStyle: const TextStyle(color: Colors.white70),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.white54),
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.white),
                  borderRadius: BorderRadius.circular(8),
                ),
                errorText: _errorMessage,
                hintText: 'e.g., https://www.youtube.com/watch?v=abc123',
                hintStyle: const TextStyle(color: Colors.white38),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _errorMessage = null;
                });
                if (_controller.text.isNotEmpty) {
                  _saveVideoLink(_controller.text);
                } else {
                  setState(() {
                    _errorMessage = 'Please enter a URL';
                  });
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 163, 132, 130),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Add Video'),
            ),
          ],
        ),
      ),
    );
  }
}
