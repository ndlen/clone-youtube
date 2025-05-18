import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:clone_youtube/service/youtube_service.dart';

class AddVideoPage extends StatefulWidget {
  const AddVideoPage({super.key});

  @override
  State<AddVideoPage> createState() => _AddVideoPageState();
}

class _AddVideoPageState extends State<AddVideoPage>
    with SingleTickerProviderStateMixin {
  final _controller = TextEditingController();
  String? _errorMessage;
  bool _isLoading = false; // Trạng thái tải
  late AnimationController
  _animationController; // Controller cho hiệu ứng scale
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    // Khởi tạo animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

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
    setState(() {
      _isLoading = true; // Hiển thị loading
    });

    try {
      final videoId = _extractVideoId(url);
      if (videoId == null) {
        setState(() {
          _errorMessage = 'URL không hợp lệ';
          _isLoading = false;
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
          SnackBar(
            content: const Text('Thêm video thành công'),
            backgroundColor: Colors.green.shade400,
            animation: CurvedAnimation(
              parent: _animationController,
              curve: Curves.easeInOut,
            ),
          ),
        );
      } else {
        setState(() {
          _errorMessage = 'Video đã tồn tại';
          _isLoading = false;
        });
        return;
      }

      Navigator.pop(context, true);
    } catch (e) {
      setState(() {
        _errorMessage = 'Lỗi khi thêm video: $e';
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _animationController.dispose();
    super.dispose();
  }

  // Hàm ẩn bàn phím
  void _hideKeyboard() {
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _hideKeyboard, // Ẩn bàn phím khi nhấn ra ngoài
      child: Scaffold(
        backgroundColor: const Color(0xFF181818),
        appBar: AppBar(
          title: Row(
            children: [
              const Icon(Icons.add_circle_outline, size: 24),
              const SizedBox(width: 8),
              const Text(
                'Thêm Video YouTube',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF212121),
          foregroundColor: Colors.white,
          elevation: 2,
          shadowColor: Colors.black54,
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _controller,
                decoration: InputDecoration(
                  labelText: 'YouTube Video URL',
                  labelStyle: const TextStyle(
                    color: Colors.white70,
                    fontFamily: 'Roboto',
                    fontSize: 16,
                  ),
                  hintText: 'Ví dụ: https://www.youtube.com/watch?v=abc123',
                  hintStyle: const TextStyle(
                    color: Colors.white38,
                    fontSize: 14,
                    fontFamily: 'Roboto',
                  ),
                  prefixIcon: const Icon(Icons.link, color: Colors.white70),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.white24),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: Colors.redAccent,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  errorText: _errorMessage,
                  errorStyle: const TextStyle(
                    color: Colors.redAccent,
                    fontFamily: 'Roboto',
                    fontSize: 12,
                  ),
                  filled: true,
                  fillColor: const Color(0xFF2A2A2A),
                ),
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'Roboto',
                  fontSize: 16,
                ),
                cursorColor: Colors.redAccent,
              ),
              const SizedBox(height: 24),
              Center(
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: ElevatedButton(
                    onPressed:
                        _isLoading
                            ? null
                            : () {
                              _animationController.forward().then((_) {
                                _animationController.reverse();
                              });
                              setState(() {
                                _errorMessage = null;
                              });
                              if (_controller.text.isNotEmpty) {
                                _saveVideoLink(_controller.text);
                              } else {
                                setState(() {
                                  _errorMessage = 'Vui lòng nhập URL video';
                                });
                              }
                            },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                      shadowColor: Colors.black54,
                    ),
                    child:
                        _isLoading
                            ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                            : const Text(
                              'Thêm Video',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Roboto',
                              ),
                            ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
