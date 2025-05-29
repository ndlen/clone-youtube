import 'package:shared_preferences/shared_preferences.dart';

class VideoModel {
  String? videoId;
  String? title;
  String? author;
  String? duration;

  VideoModel({this.videoId, this.title, this.author, this.duration});

  String get videoUrl => 'https://youtube.com/watch?v=$videoId';
  String get thumbnailUrl =>
      'https://img.youtube.com/vi/$videoId/mqdefault.jpg';
}

Future<List<VideoModel>> getVideos() async {
  final staticVideoIds = ['FN7ALfpGxiI', '_AL4IwHuHlY'];
  final prefs = await SharedPreferences.getInstance();
  final dynamicVideoIds = prefs.getStringList('video_ids') ?? [];
  final allVideoIds = [...staticVideoIds, ...dynamicVideoIds].toSet().toList();

  final videos = <VideoModel>[];
  for (var id in allVideoIds) {
    final titleKey = 'video_title_$id';
    final authorKey = 'video_author_$id';
    final durationKey = 'video_duration_$id';
    videos.add(
      VideoModel(
        videoId: id,
        title: prefs.getString(titleKey),
        author: prefs.getString(authorKey),
        duration: prefs.getString(durationKey),
      ),
    );
  }
  return videos;
}
