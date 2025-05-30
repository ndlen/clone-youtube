import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:clone_youtube/home_page.dart';
import 'package:clone_youtube/pages/onboarding.dart';
import 'package:clone_youtube/pages/login_page.dart'; // giả sử bạn có file này

class SplasePage extends StatefulWidget {
  const SplasePage({super.key});

  @override
  State<SplasePage> createState() => _SplasePageState();
}

class _SplasePageState extends State<SplasePage> {
  @override
  void initState() {
    super.initState();
    _navigateAfterDelay();
  }

  Future<void> _navigateAfterDelay() async {
    await Future.delayed(const Duration(seconds: 2));
    final prefs = await SharedPreferences.getInstance();

    final isFirstTime = prefs.getBool('isFirstTime') ?? true;
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (isFirstTime) {
      // Đặt isFirstTime thành false để không hiển thị lại nữa
      await prefs.setBool('isFirstTime', false);
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => OnboardingApp()),
      );
    } else if (isLoggedIn) {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (context) => HomePage()));
    } else {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (context) => LoginPage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          color: const Color.fromARGB(255, 9, 9, 9),
          child: Center(
            child: Image.asset('assets/images/logo.png', width: 250),
          ),
        ),
      ),
    );
  }
}
