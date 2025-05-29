import 'package:flutter/material.dart';

void main() {
  runApp(OnboardingApp());
}

class OnboardingApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Onboarding Carousel',
      debugShowCheckedModeBanner: false,
      home: OnboardingScreen(),
    );
  }
}

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController(viewportFraction: 0.8);
  int currentPage = 0;

  final List<OnboardingData> onboardingData = [
    OnboardingData("Chào mừng bạn!", "assets/images/image1.jpg"),
    OnboardingData("Tính năng", "assets/images/image2.jpg"),
    OnboardingData("Quản lý dễ dàng", "assets/images/image3.jpg"),
    OnboardingData("Bắt đầu ngay!", "assets/images/image4.jpg"),
  ];

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      final page = _pageController.page?.round() ?? 0;
      if (page != currentPage) {
        setState(() {
          currentPage = page;
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void nextPage() {
    if (currentPage < onboardingData.length - 1) {
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    } else {
      // TODO: Điều hướng sang màn hình chính
      print("Hoàn tất onboarding");
    }
  }

  void prevPage() {
    if (currentPage > 0) {
      _pageController.previousPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    }
  }

  // Widget để tạo các chấm chỉ mục
  Widget buildDotsIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        onboardingData.length,
        (index) => AnimatedContainer(
          duration: Duration(milliseconds: 300),
          margin: EdgeInsets.symmetric(horizontal: 4.0),
          height: 8.0,
          width: currentPage == index ? 24.0 : 8.0,
          decoration: BoxDecoration(
            color:
                currentPage == index
                    ? const Color.fromARGB(255, 163, 132, 130) // Màu nút FAB
                    : Colors.grey,
            borderRadius: BorderRadius.circular(4.0),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(
        255,
        71,
        66,
        66,
      ), // Màu nền HomePage
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: onboardingData.length,
              itemBuilder: (context, index) {
                return AnimatedBuilder(
                  animation: _pageController,
                  builder: (context, child) {
                    double value = 1.0;
                    if (_pageController.position.haveDimensions) {
                      value = _pageController.page! - index;
                      value = (1 - (value.abs() * 0.3)).clamp(0.8, 1.0);
                    }

                    return Center(
                      child: Opacity(
                        opacity: value.clamp(0.6, 1.0),
                        child: Transform.scale(scale: value, child: child),
                      ),
                    );
                  },
                  child: OnboardingCard(data: onboardingData[index]),
                );
              },
            ),
          ),
          // Chấm chỉ mục
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: buildDotsIndicator(),
          ),
          // Phần nút điều hướng
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: currentPage > 0 ? prevPage : null,
                  child: Text(
                    "Trước",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white, // Màu chữ giống AppBar
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: nextPage,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    backgroundColor: const Color.fromARGB(
                      255,
                      163,
                      132,
                      130,
                    ), // Màu nút FAB
                    foregroundColor: Colors.white, // Màu chữ/icon
                  ),
                  child: Text(
                    currentPage == onboardingData.length - 1
                        ? "Hoàn tất"
                        : "Tiếp",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingData {
  final String title;
  final String imagePath;

  OnboardingData(this.title, this.imagePath);
}

class OnboardingCard extends StatelessWidget {
  final OnboardingData data;

  const OnboardingCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 450,
      height: 650,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 40),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: const Color.fromARGB(255, 39, 36, 36), // Màu nền AppBar
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            data.title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white, // Màu chữ giống AppBar
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          AspectRatio(
            aspectRatio: 9 / 16,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(data.imagePath, fit: BoxFit.cover),
            ),
          ),
        ],
      ),
    );
  }
}
