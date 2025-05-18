import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class YoutubeService {
  static final YoutubeService _instance = YoutubeService._internal();
  final YoutubeExplode _yt = YoutubeExplode();

  factory YoutubeService() => _instance;
  YoutubeService._internal();

  YoutubeExplode get client => _yt;

  void close() => _yt.close();
}
