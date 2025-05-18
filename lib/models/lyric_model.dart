class LyricResponse {
  final String status;
  final Song song;
  final Lyric lyric;

  LyricResponse({
    required this.status,
    required this.song,
    required this.lyric,
  });

  factory LyricResponse.fromJson(Map<String, dynamic> json) {
    return LyricResponse(
      status: json['status'],
      song: Song.fromJson(json['song']),
      lyric: Lyric.fromJson(json['lyric']),
    );
  }
}

class Song {
  final String key;
  final String title;
  final String artists;
  final String duration;
  final String thumbnail;

  Song({
    required this.key,
    required this.title,
    required this.artists,
    required this.duration,
    required this.thumbnail,
  });

  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      key: json['key'],
      title: json['title'],
      artists: json['artists'],
      duration: json['duration'],
      thumbnail: json['thumbnail'],
    );
  }
}

class Lyric {
  final String title;
  final String lyric;
  final String writer;
  final String composer;

  Lyric({
    required this.title,
    required this.lyric,
    required this.writer,
    required this.composer,
  });

  factory Lyric.fromJson(Map<String, dynamic> json) {
    return Lyric(
      title: json['title'],
      lyric: json['lyric'],
      writer: json['writer'],
      composer: json['composer'],
    );
  }
}
