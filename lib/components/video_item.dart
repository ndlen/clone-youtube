import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:clone_youtube/models/video_model.dart';
import 'package:clone_youtube/pages/video_player_page.dart';

class VideoItem extends StatelessWidget {
  final VideoModel videoModel;
  final VoidCallback onDelete;

  const VideoItem({
    super.key,
    required this.videoModel,
    required this.onDelete,
  });

  Future<void> _deleteVideo(String? videoId) async {
    if (videoId == null) return;

    final prefs = await SharedPreferences.getInstance();
    final videoIds = prefs.getStringList('video_ids') ?? [];

    if (videoIds.contains(videoId)) {
      videoIds.remove(videoId);
      await prefs.setStringList('video_ids', videoIds);
      await prefs.remove('video_title_$videoId');
      await prefs.remove('video_author_$videoId');
      await prefs.remove('video_duration_$videoId');
      onDelete();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (videoModel.title == null) {
      // Skeleton UI khi dữ liệu chưa tải
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 39, 36, 36),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 180,
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(height: 18),
            Container(width: 200, height: 20, color: Colors.grey[800]),
            const SizedBox(height: 10),
            Container(width: 150, height: 16, color: Colors.grey[800]),
          ],
        ),
      );
    }

    return Dismissible(
      key: ValueKey(videoModel.videoId),
      direction: DismissDirection.endToStart,
      background: Container(
        color: const Color.fromARGB(255, 10, 9, 9),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                backgroundColor: const Color.fromARGB(255, 39, 36, 36),
                title: const Text(
                  'Xóa Video',
                  style: TextStyle(color: Colors.white),
                ),
                content: const Text(
                  'Bạn có chắc chắn muốn xóa video này không?',
                  style: TextStyle(color: Colors.white70),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text(
                      'Hủy bỏ',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      await _deleteVideo(videoModel.videoId);
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Xóa video thành công'),
                          backgroundColor: const Color.fromARGB(
                            255,
                            236,
                            83,
                            83,
                          ),
                        ),
                      );
                    },
                    child: const Text(
                      'Chắc chắn',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
        );
      },
      onDismissed: (direction) {
        _deleteVideo(videoModel.videoId);
      },
      child: GestureDetector(
        onTap: () {
          if (videoModel.videoId != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => VideoPlayerPage(videoId: videoModel.videoId!),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('ID video không hợp lệ')),
            );
          }
        },
        onLongPress: () {
          if (videoModel.videoId != null) {
            showDialog(
              context: context,
              builder:
                  (context) => AlertDialog(
                    backgroundColor: const Color.fromARGB(255, 39, 36, 36),
                    title: const Text(
                      'Xóa Video',
                      style: TextStyle(color: Colors.white),
                    ),
                    content: const Text(
                      'Bạn có chắc chắn muốn xóa video này không?',
                      style: TextStyle(color: Colors.white70),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          'Hủy bỏ',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          await _deleteVideo(videoModel.videoId);
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Xóa video thành công'),
                              backgroundColor: const Color.fromARGB(
                                255,
                                236,
                                83,
                                83,
                              ),
                            ),
                          );
                        },
                        child: const Text(
                          'Chắc chắn',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
            );
          }
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 39, 36, 36),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1), // Giảm hiệu ứng nặng
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: videoModel.thumbnailUrl,
                  width: double.infinity,
                  height: 180,
                  fit: BoxFit.cover,
                  placeholder:
                      (context, url) => Container(
                        color: Colors.grey[800],
                        height: 180,
                        width: double.infinity,
                      ),
                  errorWidget:
                      (context, url, error) =>
                          const Icon(Icons.error, color: Colors.red),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                videoModel.title ?? 'Loading...',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.person, color: Colors.white54, size: 18),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      videoModel.author ?? 'Loading...',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.timer, color: Colors.white54, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    videoModel.duration ?? 'Loading...',
                    style: const TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
