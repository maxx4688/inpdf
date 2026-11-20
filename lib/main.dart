import 'package:flutter/material.dart';
import 'package:inpdf/pages/boarding/splash.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: Colors.lightBlue),
      ),
      home: const SplashScreen(),
    );
  }
}