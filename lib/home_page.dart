import 'package:clone_youtube/components/video_item.dart';
import 'package:clone_youtube/models/video_model.dart';
import 'package:clone_youtube/pages/add_video_page.dart';
import 'package:clone_youtube/service/youtube_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin {
  List<VideoModel> videos = [];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadVideos();
  }

  Future<void> _loadVideos() async {
    try {
      final loadedVideoIds = await getVideos();
      final yt = YoutubeService().client;
      final prefs = await SharedPreferences.getInstance();
      final loadedVideos = <VideoModel>[];

      for (var video in loadedVideoIds) {
        if (video.title == null) {
          try {
            final ytVideo = await yt.videos.get(
              'https://youtube.com/watch?v=${video.videoId}',
            );
            loadedVideos.add(
              VideoModel(
                videoId: video.videoId,
                title: ytVideo.title,
                author: ytVideo.author,
                duration: ytVideo.duration?.toString() ?? '',
              ),
            );
            await prefs.setString(
              'video_title_${video.videoId}',
              ytVideo.title,
            );
            await prefs.setString(
              'video_author_${video.videoId}',
              ytVideo.author,
            );
            await prefs.setString(
              'video_duration_${video.videoId}',
              ytVideo.duration?.toString() ?? '',
            );
          } catch (e) {
            print('Error loading video ${video.videoId}: $e');
            loadedVideos.add(video); // Giữ video ngay cả khi lỗi
          }
        } else {
          loadedVideos.add(video);
        }
      }

      if (videos != loadedVideos) {
        setState(() {
          videos = loadedVideos;
        });
      }
    } catch (e) {
      print('Error loading videos: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load videos: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 71, 66, 66),
      appBar: AppBar(
        title: const Text('Lưu Video YouTube'),
        backgroundColor: const Color.fromARGB(255, 39, 36, 36),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.separated(
          key: UniqueKey(),
          cacheExtent: 1000.0,
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: videos.length,
          itemBuilder: (context, index) {
            VideoModel video = videos[index];
            return VideoItem(
              key: ValueKey(video.videoId),
              videoModel: video,
              onDelete: _loadVideos,
            );
          },
          separatorBuilder: (context, index) => const SizedBox(height: 16),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromARGB(255, 163, 132, 130),
        foregroundColor: Colors.white,
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddVideoPage()),
          );
          if (result == true) {
            await _loadVideos();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
