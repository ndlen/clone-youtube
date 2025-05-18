import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
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
  bool _showLyrics = false; // Thêm nút bật/tắt lời bài hát

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: widget.videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: false, // Tắt autoPlay để giảm tải
        mute: false,
        enableCaption: false, // Tắt phụ đề
        disableDragSeek: false,
        loop: false,
        forceHD: false, // Tắt HD
        showLiveFullscreenButton: false,
      ),
    )..addListener(() {
      // Giới hạn xử lý sự kiện
      if (_controller.value.isPlaying &&
          _controller.value.position.inSeconds % 5 == 0) {
        print('Video time: ${_controller.value.position}');
      }
    });
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
      await _fetchLyric(video.title);
    } catch (e) {
      setState(() {
        _videoInfo = {
          'title': 'Error loading title',
          'author': 'Error loading author',
        };
      });
    }
  }

  Future<void> _fetchLyric(String title) async {
    try {
      String songName = title;
      print('Original title: $title');
      print('Song name sent to API: ${Uri.encodeComponent(songName)}');
      final lyricResponse = await _lyricService.fetchLyric(songName);
      print('API response: ${lyricResponse.toString()}');
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
      print('Error fetching lyric: $e');
      setState(() {
        _lyricError = 'Lỗi khi lấy lời bài hát: $e';
      });
    }
  }

  @override
  void dispose() {
    _controller.pause();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return YoutubePlayerBuilder(
      player: YoutubePlayer(
        controller: _controller,
        showVideoProgressIndicator: true,
        progressIndicatorColor: Colors.red,
        progressColors: const ProgressBarColors(
          playedColor: Colors.red,
          handleColor: Colors.redAccent,
        ),
      ),
      builder: (context, player) {
        return Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            title: const Text('Phát Video'),
            systemOverlayStyle: SystemUiOverlayStyle.light,
            backgroundColor: const Color.fromARGB(255, 39, 36, 36),
            foregroundColor: Colors.white,
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                player,
                Padding(
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
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
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
                      if (_showLyrics) ...[
                        Text(
                          'Lời bài hát',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (_lyric != null)
                          SizedBox(
                            height: 300, // Giới hạn chiều cao
                            child: ListView.separated(
                              physics:
                                  const ClampingScrollPhysics(), // Cuộn mượt hơn
                              cacheExtent: 1000, // Cache để tối ưu
                              itemCount: _lyric!.split('\n').length,
                              itemBuilder: (context, index) {
                                final line = _lyric!.split('\n')[index];
                                return Text(
                                  line,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.white70,
                                    height: 1.5,
                                  ),
                                );
                              },
                              separatorBuilder:
                                  (context, index) => const SizedBox(height: 4),
                            ),
                          )
                        else if (_lyricError != null)
                          Text(
                            _lyricError!,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.red,
                            ),
                          )
                        else
                          const CircularProgressIndicator(),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
