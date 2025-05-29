import 'dart:async';

import 'package:clone_youtube/home_page.dart';
import 'package:clone_youtube/pages/onboarding.dart';
import 'package:flutter/material.dart';

class SplasePage extends StatefulWidget {
  const SplasePage({super.key});

  @override
  State<SplasePage> createState() => _SplasePageState();
}

class _SplasePageState extends State<SplasePage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Timer(Duration(seconds: 2), () {
      Route route = MaterialPageRoute(builder: (context) => OnboardingApp());
      Navigator.of(context).pushAndRemoveUntil(route, (route) => false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(color: const Color.fromARGB(255, 9, 9, 9)),
          child: Center(
            child: Image.asset('assets/images/logo.png', width: 250),
          ),
        ),
      ),
    );
  }
}
