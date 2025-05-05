import 'dart:async';
import 'package:flutter/material.dart';
import './wadrobe/presentation/wadrobe_screen.dart';

class SplashScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    startTimer();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward();
  }

  startTimer() async {
    await Future.delayed(Duration(seconds: 4));
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => WardrobeScreen()),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Color(0xFF121212), // Dark background
    body: Center(
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 80,
              width: 80,
              decoration: BoxDecoration(
                color: Color(0xFF3A8DFF), // Primary accent
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.home,
                size: 40,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 24),
            Text(
              "My Smart Mirror",
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                letterSpacing: 0.8,
              ),
            ),
            SizedBox(height: 12),
            Text(
              "Powered by AI Style Suggestions",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Colors.grey[400],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
}