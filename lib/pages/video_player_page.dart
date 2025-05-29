import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'package:clone_youtube/service/youtube_service.dart';
import 'package:clone_youtube/service/lyric_service.dart';

class VideoPlayerPage extends StatefulWidget {
  final String videoId;

  const VideoPlayerPage({super.key, required this.videoId});

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage>
    with AutomaticKeepAliveClientMixin {
  late YoutubePlayerController _controller;
  final YoutubeService _ytService = YoutubeService();
  final LyricService _lyricService = LyricService();
  Map<String, String> _videoInfo = {
    'title': 'Loading...',
    'author': 'Loading...',
  };
  String? _lyric;
  String? _lyricError;
  bool _showLyrics = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController.fromVideoId(
      videoId: widget.videoId,
      autoPlay: true,

      params: const YoutubePlayerParams(
        mute: false,
        showControls: false,
        showFullscreenButton: true,
        enableCaption: false,
        strictRelatedVideos: false,
        playsInline: true,
        showVideoAnnotations: false,
      ),
    );
    _fetchVideoInfo();
  }

  Future<void> _fetchVideoInfo() async {
    try {
      final video = await _ytService.client.videos.get(
        'https://youtube.com/watch?v=${widget.videoId}',
      );
      setState(() {
        _videoInfo = {'title': video.title, 'author': video.author};
      });
    } catch (e) {
      setState(() {
        _videoInfo = {
          'title': 'Error loading title',
          'author': 'Error loading author',
        };
      });
    }
  }

  // Thêm biến để lưu cache lyrics đã split
  List<String>? _lyricLines;

  Future<void> _fetchLyric(String title) async {
    try {
      final lyricResponse = await _lyricService.fetchLyric(title);
      if (lyricResponse['status'] == 'success') {
        setState(() {
          _lyric = lyricResponse['lyric']['lyric'].replaceAll('<br />', '\n');
        });
      } else {
        setState(() {
          _lyricError = 'API không tìm thấy bài hát';
        });
      }
    } catch (e) {
      setState(() {
        _lyricError = 'Lỗi khi lấy lời bài hát: $e';
      });
    }
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Phát Video'),
        systemOverlayStyle: SystemUiOverlayStyle.light,
        backgroundColor: const Color.fromARGB(255, 39, 36, 36),
        foregroundColor: Colors.white,
      ),
      body: CustomScrollView(
        physics: const ClampingScrollPhysics(),
        cacheExtent: 2000,
        slivers: [
          SliverToBoxAdapter(
            child: YoutubePlayer(
              controller: _controller,
              aspectRatio: 16 / 9,
              enableFullScreenOnVerticalDrag: false,
              backgroundColor: Colors.black,
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _videoInfo['title']!,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _videoInfo['author']!,
                    style: const TextStyle(fontSize: 14, color: Colors.white70),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _showLyrics = !_showLyrics;
                      });
                    },
                    child: Text(
                      _showLyrics ? 'Ẩn lời bài hát' : 'Hiện lời bài hát',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_showLyrics && _lyric != null)
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final line = _lyric!.split('\n')[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 2.0,
                    ),
                    child: Text(
                      line,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                        height: 1.5,
                      ),
                    ),
                  );
                },
                childCount: _lyric!.split('\n').length,
                addAutomaticKeepAlives: true,
                findChildIndexCallback: (Key key) {
                  final ValueKey<String> valueKey = key as ValueKey<String>;
                  final index = _lyric!.split('\n').indexOf(valueKey.value);
                  return index >= 0 ? index : null;
                },
                semanticIndexCallback: (Widget widget, int localIndex) {
                  return localIndex;
                },
              ),
            ),
          if (_showLyrics && _lyric == null && _lyricError != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  _lyricError!,
                  style: const TextStyle(fontSize: 14, color: Colors.red),
                ),
              ),
            ),
          if (_showLyrics && _lyric == null && _lyricError == null)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}
