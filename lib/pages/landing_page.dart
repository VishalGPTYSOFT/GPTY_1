import 'package:flutter/material.dart';
import 'dart:async';
import 'home_screen.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {

  @override
  void initState() {
    super.initState();

    // Auto navigation after 2 seconds
    Timer(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
            child: Image.asset(
              "assets/images/logo.png",
              width: 226,   // adjust size
              height: 208,  // adjust size
              fit: BoxFit.contain,
            ),
        ),
      ),
    );
  }
}
