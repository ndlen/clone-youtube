import 'package:clone_youtube/home_page.dart';
import 'package:clone_youtube/pages/splase_page.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(useMaterial3: true),

      debugShowCheckedModeBanner: false,
      home: SplasePage(),
    );
  }
}
