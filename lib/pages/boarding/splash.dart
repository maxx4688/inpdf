import 'package:flutter/material.dart';
import 'package:inpdf/pages/home/dashboard.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    Future.delayed(Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => DashBoardPage(),),
        );
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF27F8FF), Color(0xFF3890FD)],
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  "Presenting",
                  style: TextStyle(
                    fontFamily: "Magic",
                    fontSize: 24,
                    color: Colors.white,
                  ),
                ),
                SizedBox(),
                CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 3,
                  strokeCap: StrokeCap.round,
                ),
              ],
            ),
          ),
          Center(child: Image.asset("lib/assets/images/monochrome.png")),
        ],
      ),
    );
  }
}
